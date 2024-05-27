//---------------------------------------------------------
// Library: LiteIc AXI4 sequence library
//---------------------------------------------------------


//---------------------------------------------------------
// Class: axi4_liteic_seq_base
//---------------------------------------------------------

// This class provides base API for running sequences

virtual class axi4_liteic_seq_base extends axi4_master_deparam_seq;

    `uvm_object_utils(axi4_liteic_seq_base)


    //---------------------------------------------------------
    // Fields
    //---------------------------------------------------------

    // Priority interface (must be set explicitly if needed)

    axi4_liteic_priority_vif priority_vif;

    // Priority pool

    axi4_liteic_priority_pool priority_pool;

    // Test config

    axi4_liteic_test_cfg_base test_config;

    // Host agent (on which sequencer sequence is executed)

    agent_t host_agent; 

    // Items amount

    int unsigned items_amount = 100;

    // Pipelined transaction probability

    int unsigned pipelined_probability = 0;

    // Address map and its entries

    addr_map_t addr_map;
    addr_map_entry_s entries [];

    // Address pool

    addr_t addr_pool [$];

    // Used addresses

    addr_t used_addr [$];

    // Sequences logging info

    axi4_liteic_seq_info seq_info [addr_t][$];
    
    // Sequence start and end counters

    int unsigned start_cnt;
    int unsigned end_cnt;


    //---------------------------------------------------------
    // Function: new
    //---------------------------------------------------------
    
    function new (string name = "");
        super.new( name );
    endfunction


    //---------------------------------------------------------
    // Function: configure
    //---------------------------------------------------------

    // This function is used for sequence configuration
    
    virtual function void configure();
        // Get test configuration
        get_test_config();
        // Get agent address map
        get_agent_addr_map();
        // Get address pool
        get_addr_pool();
        // Get priority pool
        get_priority_pool();
    endfunction


    //---------------------------------------------------------
    // Function: get_test_config
    //---------------------------------------------------------
    
    // This function gets test configuration

    virtual function void get_test_config();
        if(!uvm_resource_db #( axi4_liteic_test_cfg_base )::read_by_name( get_full_name(),
            "test_config", test_config )) `uvm_fatal(get_name() , "uvm_config_db \
                #( axi4_liteic_test_cfg_base )::get cannot find resource test_config")
    endfunction


    //---------------------------------------------------------
    // Function: get_agent_addr_map
    //---------------------------------------------------------

    // This function get address map of agent of the target
    // sequencer (on which this sequence is running)

    virtual function void get_agent_addr_map();
        uvm_sequencer_base host_sequencer;
        host_sequencer = get_sequencer();
        $cast(host_agent, host_sequencer.get_parent());
        addr_map = host_agent.cfg.addr_map;
        addr_map.get_full_map(entries);
    endfunction


    //---------------------------------------------------------
    // Function: get_addr_pool
    //---------------------------------------------------------
    
    // This function gets address pool

    virtual function void get_addr_pool(); endfunction


    //---------------------------------------------------------
    // Function: get_priority_pool
    //---------------------------------------------------------
    
    // This function gets priority pool

    virtual function void get_priority_pool(); endfunction


    //---------------------------------------------------------
    // Task: run_seq
    //---------------------------------------------------------
    
    // This does base prepeartion and sequence start

    virtual task run_seq(axi4_master_deparam_seq seq);

        // Execute sequence
        host_agent.cfg.wait_for_reset();
        super.body();
        if(test_config.en_stats) log_seq(seq, 0);
        seq.start(m_sequencer);
        if(test_config.en_stats) log_seq(seq, 1);

    endtask


    //---------------------------------------------------------
    // Function: rand_seq
    //---------------------------------------------------------
    
    // This does sequence randomization

    virtual function void rand_seq(axi4_master_deparam_seq seq);

        if(!seq.randomize())
            `uvm_fatal(this.get_full_name(),"Randomization failure!");

    endfunction


    //---------------------------------------------------------
    // Function: 
    //---------------------------------------------------------

    // This function is called before sequence start with
    // ~start_end~ equal to 0 and after sequence start with
    // ~start_end~ equal to 1
    
    virtual function void log_seq(
        axi4_master_deparam_seq seq,
        bit                     start_end
    );
    endfunction

    //---------------------------------------------------------
    // Function: proc_seq
    //---------------------------------------------------------
    
    // Additional routines function

    virtual function void proc_seq(axi4_master_deparam_seq seq);
    endfunction


endclass


//---------------------------------------------------------
// Class: axi4_liteic_wr_seq_base
//---------------------------------------------------------

// Base write sequence

class axi4_liteic_wr_seq_base extends axi4_liteic_seq_base;

    `uvm_object_utils(axi4_liteic_wr_seq_base)
    `uvm_object_new


    //---------------------------------------------------------
    // Fields
    //---------------------------------------------------------

    // Write sequences array

    typedef axi4lite_wr_data_deparam_seq wr_data_t;
    wr_data_t wr_data [];


    //---------------------------------------------------------
    // Task: body
    //---------------------------------------------------------
    
    virtual task body();
        fork
            run_seqs();
            run_prior();
        join
    endtask


    //---------------------------------------------------------
    // Task: run_seqs
    //---------------------------------------------------------

    virtual task run_seqs();
        // Create and randomize write sequences
        wr_data = new[items_amount];
        foreach (wr_data[i]) begin
            wr_data[i] = wr_data_t::type_id::create("wr_data");
            wr_data[i].set_sequencer(m_sequencer);
            rand_seq(wr_data[i]);
            proc_seq(wr_data[i]);
        end
        fork begin
            foreach(wr_data[i]) begin
                automatic wr_data_t data = wr_data[i];
                if( $urandom_range(0, 100) inside {[0:pipelined_probability]} ) begin
                    fork begin
                        run_seq(data);
                        used_addr.push_back(data.addr);
                    end join_none
                end
                else begin
                    run_seq(data);
                    used_addr.push_back(data.addr);
                end
            end
            wait fork;
        end join
    endtask


    //---------------------------------------------------------
    // Task: run_prior
    //---------------------------------------------------------
    
    // This task runs priorities routines

    virtual task run_prior();

        // Wait for reset
        host_agent.cfg.wait_for_reset();
        
        repeat(items_amount) begin

            // Set priority
            priority_vif.prior <= priority_pool.request_prior();

            // Wait for AWVVALID and AWREADY handshake
            do begin
                host_agent.cfg.wait_for_clock();
            end
            while (!(
                (host_agent.cfg.m_bfm.AWVALID === 1) &&
                (host_agent.cfg.m_bfm.AWREADY === 1)
            ));

        end

    endtask


    //---------------------------------------------------------
    // Function: get_addr_pool
    //---------------------------------------------------------
    
    // This function randomizes address pool

    virtual function void get_addr_pool();

        axi4_liteic_addr_pool pool = axi4_liteic_addr_pool::get_inst();

        // Shuffle entries
        entries.shuffle();

        // All addresses must be inside address map entry
        addr_pool = pool.request_addr_pool(
            {entries[0].addr, entries[0].addr+entries[0].size-1}, items_amount
        );

    endfunction
    

    //---------------------------------------------------------
    // Function: get_priority_pool
    //---------------------------------------------------------
    
    // This function gets priority pool

    virtual function void get_priority_pool();
    
        priority_pool = axi4_liteic_priority_pool::get_inst();

    endfunction


    //---------------------------------------------------------
    // Function: rand_seq
    //---------------------------------------------------------

    virtual function void rand_seq(axi4_master_deparam_seq seq);

        wr_data_t wr_seq; $cast(wr_seq, seq);

        if(!wr_seq.randomize() with {addr inside {addr_pool};})
            `uvm_fatal(this.get_full_name(),"Randomization failure!");

    endfunction

    
    //---------------------------------------------------------
    // Function: log_seq
    //---------------------------------------------------------

    virtual function void log_seq(
        axi4_master_deparam_seq seq,
        bit                     start_end
    );

        // Sequence info
        axi4_liteic_seq_info info;

        // Sequence obtaining
        wr_data_t wr_seq; $cast(wr_seq, seq);

        // Sequence logging
        if(!start_end) begin

            fork begin

                // Wait for AWVVALID and specific address
                do begin
                    host_agent.cfg.wait_for_clock();
                end
                while (!(
                    (host_agent.cfg.m_bfm.AWVALID === 1) &&
                    (host_agent.cfg.m_bfm.AWADDR  === wr_seq.addr)
                ));

                // Save info
                info = axi4_liteic_seq_info::type_id::create("info");
                info.acc_type = W;
                info.start_time = $time();
                info.addr = wr_seq.addr;
                info.prior = priority_vif.prior;
                seq_info[wr_seq.addr].push_back(info);
                start_cnt += 1;

            end join_none

        end
        else begin
            // Set end time for the first write transaction
            // We don't have need to manage this queue
            // transactions order because all addresses
            // are unique
            seq_info[wr_seq.addr][0].end_time = $time();
            end_cnt += 1;
        end

    endfunction


    //---------------------------------------------------------
    // Function: proc_seq
    //---------------------------------------------------------

    virtual function void proc_seq(axi4_master_deparam_seq seq);

        int idx [$]; wr_data_t wr_seq; $cast(wr_seq, seq);

        // Delete address from address pool
        idx = addr_pool.find_first_index with(item == wr_seq.addr);
        addr_pool.delete(idx[0]);

    endfunction


endclass


//---------------------------------------------------------
// Class: axi4_liteic_rd_seq_base
//---------------------------------------------------------

// Base read sequence

class axi4_liteic_rd_seq_base extends axi4_liteic_seq_base;

    `uvm_object_utils(axi4_liteic_rd_seq_base)
    `uvm_object_new


    //---------------------------------------------------------
    // Fields
    //---------------------------------------------------------

    // Single read sequence

    typedef axi4lite_rd_data_deparam_seq rd_data_t;
    rd_data_t rd_data [];

    // Host write sequence. This sequence must be set explicitly
    
    axi4_liteic_wr_seq_base host_wr_seq;

    // Sequence info in progress

    axi4_liteic_seq_info seq_info_ip [addr_t][$];

    // Address phase indicator

    bit addr_phase [addr_t];


    //---------------------------------------------------------
    // Task: body
    //---------------------------------------------------------
    
    virtual task body();
        fork
            run_seqs();
            run_prior();
        join
    endtask

    
    //---------------------------------------------------------
    // Task: run_seqs
    //---------------------------------------------------------

    virtual task run_seqs();
        // Wait for at least one address in host seqeunce
        wait(host_wr_seq.used_addr.size());
        // Create and randomize read sequences
        rd_data = new[items_amount];
        fork begin
            foreach(rd_data[i]) begin
                automatic rd_data_t data;
                // Randomize sequence
                rd_data[i] = rd_data_t::type_id::create("rd_data");
                rd_data[i].set_sequencer(m_sequencer);
                rand_seq(rd_data[i]); data = rd_data[i];
                // If we are at address phase with the same
                // address - wait for it to be executed, as
                // we don't want to log to sequences at the
                // same time
                if( addr_phase.exists(data.addr) ) begin
                    wait(!addr_phase[data.addr]);
                end
                addr_phase[data.addr] = 1;
                if(
                    // We start pipelined read sequences only if half
                    // of write addresses were issued. This is some kind
                    // of guard from issuing all pipilened transactions
                    // by the same address
                    (host_wr_seq.used_addr.size() >= host_wr_seq.items_amount/2) &&
                    ($urandom_range(0, 100) inside {[0:pipelined_probability]})
                ) begin
                    fork begin
                        run_seq(data);
                    end join_none
                end
                else begin
                    run_seq(data);
                end
            end
            wait fork;
        end join
    endtask


    //---------------------------------------------------------
    // Task: run_prior
    //---------------------------------------------------------
    
    // This task runs priorities routines

    virtual task run_prior();

        // Wait for reset
        host_agent.cfg.wait_for_reset();
        
        repeat(items_amount) begin

            // Set priority
            priority_vif.prior <= priority_pool.request_prior();

            // Wait for AWVVALID and AWREADY handshake
            do begin
                host_agent.cfg.wait_for_clock();
            end
            while (!(
                (host_agent.cfg.m_bfm.ARVALID === 1) &&
                (host_agent.cfg.m_bfm.ARREADY === 1)
            ));

        end

    endtask


    //---------------------------------------------------------
    // Function: get_addr_pool
    //---------------------------------------------------------
    
    // This function randomizes address pool

    virtual function void get_addr_pool(); endfunction


    //---------------------------------------------------------
    // Function: get_priority_pool
    //---------------------------------------------------------
    
    // This function gets priority pool

    virtual function void get_priority_pool();
    
        priority_pool = axi4_liteic_priority_pool::get_inst();

    endfunction


    //---------------------------------------------------------
    // Function: rand_seq
    //---------------------------------------------------------

    virtual function void rand_seq(axi4_master_deparam_seq seq);

        rd_data_t rd_seq; $cast(rd_seq, seq);

        if(!rd_seq.randomize() with {addr inside {host_wr_seq.used_addr};})
            `uvm_fatal(this.get_full_name(),"Randomization failure!");

    endfunction

    
    //---------------------------------------------------------
    // Function: log_seq
    //---------------------------------------------------------

    virtual function void log_seq(
        axi4_master_deparam_seq seq,
        bit                     start_end
    );

        // Sequence info
        axi4_liteic_seq_info info;

        // Sequence obtaining
        rd_data_t rd_seq; $cast(rd_seq, seq);

        // Sequence logging
        if(!start_end) begin

            fork begin

                // Wait for ARVALID and specific address
                do begin
                    host_agent.cfg.wait_for_clock();
                end
                while (!(
                    (host_agent.cfg.m_bfm.ARVALID === 1) &&
                    (host_agent.cfg.m_bfm.ARADDR  === rd_seq.addr)
                ));
            
                // Set info
                info = axi4_liteic_seq_info::type_id::create("info");
                info.acc_type = R;
                info.start_time = $time();
                info.addr = rd_seq.addr;
                info.prior = priority_vif.prior;
                seq_info_ip[rd_seq.addr].push_back(info);
                start_cnt += 1;

                // Set address phase done
                addr_phase[rd_seq.addr] = 0;

            end join_none

        end
        else begin
            // Set end time for the first read transaction
            // by this address because we are in order
            seq_info_ip[rd_seq.addr][0].end_time = $time();
            // Now transaction done, push to the final infos
            seq_info[rd_seq.addr].push_back(seq_info_ip[rd_seq.addr].pop_front());
            end_cnt += 1;
        end

    endfunction


endclass
