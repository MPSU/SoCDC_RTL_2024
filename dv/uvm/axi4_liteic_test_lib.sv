//---------------------------------------------------------
// Library: LiteIc AXI4 test library
//---------------------------------------------------------


//---------------------------------------------------------
// Class: axi4_liteic_test_base
//---------------------------------------------------------

// Base test

class axi4_liteic_test_base extends uvm_test;

    `uvm_component_utils(axi4_liteic_test_base)
    `uvm_component_new


    //---------------------------------------------------------
    // Fields
    //---------------------------------------------------------

    // Test configuration

    axi4_liteic_test_cfg_base test_config;

    // Logging database

    axi4_liteic_seq_info_base info_base;

    // Masters amount

    int masters_amount;

    // Slaves amount

    int slaves_amount;
    
    // Masters configurations, delay databases and agents

    config_t       master_configs [MASTERS_AMOUNT];
    master_delay_t master_delays  [MASTERS_AMOUNT];
    agent_t        masters        [MASTERS_AMOUNT];

    // Slaves configurations, delay databases and agents

    config_t      slave_configs   [SLAVES_AMOUNT];
    slave_delay_t slave_delays    [SLAVES_AMOUNT];
    agent_t       slaves          [SLAVES_AMOUNT];

    // Address map

    addr_map_t addr_map;

    // Handles for possible write sequences

    axi4_liteic_wr_seq_base w_seqs [MASTERS_AMOUNT][$];

    // Handles for possible read sequences

    axi4_liteic_rd_seq_base r_seqs [MASTERS_AMOUNT][$];

    // Priority interfaces

    axi4_liteic_priority_vif w_priority_vifs [MASTERS_AMOUNT];
    axi4_liteic_priority_vif r_priority_vifs [MASTERS_AMOUNT];


    //---------------------------------------------------------
    // Function: build_phase
    //---------------------------------------------------------
    
    // Create AXI4 environment, configure it

    virtual function void build_phase(uvm_phase phase);

        // Create master and slave agents
        create_agents();
        
        // Create configurations
        create_configs();

        // Get interfaces
        get_interfaces();

        // Set common settings
        set_common();

        // Set address map
        set_addr_map();

        // Set master basic settings
        set_master_basic();

        // Set master delays
        set_master_delay();

        // Set slave basic settings
        set_slave_basic();

        // Set slave delays
        set_slave_delay();

    endfunction


    //---------------------------------------------------------
    // Function: create_agents
    //---------------------------------------------------------
    
    // Create agents by dimensions

    virtual function void create_agents();

        foreach(masters[i]) begin
            masters[i] = agent_t::type_id::
                create($sformatf("master[%0d]", i), this);
        end

        foreach(slaves[i]) begin
            slaves[i]  = agent_t::type_id::
                create($sformatf("slave[%0d]", i), this);
        end
    
    endfunction


    //---------------------------------------------------------
    // Function: create_configs
    //---------------------------------------------------------
    
    // Create agents configurations by dimensions
    // Also create test configuration

    virtual function void create_configs();

        // Create agents configs
        foreach(master_configs[i]) begin
            master_configs[i] = config_t::type_id::
                create($sformatf("master_configs[%0d]", i), this);
        end
        foreach(slave_configs[i]) begin
            slave_configs[i]  = config_t::type_id::
                create($sformatf("slave_configs[%0d]", i), this);
        end

        // Create test config and pass it to the resource database
        test_config = axi4_liteic_test_cfg_base::type_id::
            create("test_config");
        uvm_resource_db #( axi4_liteic_test_cfg_base )::
            set("*", "test_config", test_config, this);
    
    endfunction


    //---------------------------------------------------------
    // Function: get_interfaces
    //---------------------------------------------------------
    
    // Gets all neccessary interfaces

    virtual function void get_interfaces();

        foreach(w_priority_vifs[i]) begin
            string intf_name = $sformatf("w_priority_vif[%0d]", i);
            if(!uvm_resource_db #( axi4_liteic_priority_vif )::read_by_name(
                get_full_name(), intf_name, w_priority_vifs[i] )) `uvm_fatal(get_name(),
                    $sformatf( {"uvm_config_db #( axi4_liteic_priority_vif )::get cannot",
                        "find resource %s"}, intf_name))
        end
        
        foreach(r_priority_vifs[i]) begin
            string intf_name = $sformatf("r_priority_vif[%0d]", i);
            if(!uvm_resource_db #( axi4_liteic_priority_vif )::read_by_name(
                get_full_name(), intf_name, r_priority_vifs[i] )) `uvm_fatal(get_name(),
                    $sformatf( {"uvm_config_db #( axi4_liteic_priority_vif )::get cannot",
                        "find resource %s"}, intf_name))
        end
    
    endfunction


    //---------------------------------------------------------
    // Function: set_common
    //---------------------------------------------------------
    
    // Configure setting common for masters and slaves

    virtual function void set_common();

        // Pass configurations to masters and slaves
        foreach(masters[i]) masters[i].cfg = master_configs[i];
        foreach(slaves[i] ) slaves[i].cfg  = slave_configs [i];

        // Obtain AXI4 interfaces
        foreach(master_configs[i]) begin
            string intf_name = $sformatf("AXI4_MASTER_IF_%0d", i);
            if(!uvm_resource_db #( bfm_type )::read_by_name( get_full_name(),
                intf_name, master_configs[i].m_bfm )) `uvm_fatal(get_name() , $sformatf(
                    "uvm_config_db #( bfm_type )::get cannot find resource %s", intf_name))
        end
        foreach(slave_configs[i]) begin
            string intf_name = $sformatf("AXI4_SLAVE_IF_%0d", i);
            if(!uvm_resource_db #( bfm_type )::read_by_name( get_full_name(),
                intf_name, slave_configs[i].m_bfm )) `uvm_fatal(get_name() , $sformatf(
                    "uvm_config_db #( bfm_type )::get cannot find resource %s", intf_name))
        end

    endfunction


    //---------------------------------------------------------
    // Function: set_addr_map
    //---------------------------------------------------------
    
    // Create and set address map

    virtual function void set_addr_map();

        // Define address map entry
        addr_map_entry_s entry;

        // Create address map
        addr_map = convert_addr_map('{
            axi4_liteic_slave_addr_map[0],
            axi4_liteic_slave_addr_map[1]
        });

        // Masters are write to all slaves
        foreach(master_configs[i]) master_configs[i].addr_map = addr_map;

        // Each slave has its own address map
        foreach(slave_configs[i]) begin
            slave_configs [i].addr_map = convert_addr_map('{
                axi4_liteic_slave_addr_map[i]
            });
        end

    endfunction


    //---------------------------------------------------------
    // Function: set_master_basic
    //---------------------------------------------------------
    
    // Configure AXI4 masters scoreboarding, assertions

    virtual function void set_master_basic();

        // Configure AXI4-Lite master
        foreach(master_configs[i]) master_configs[i].agent_cfg.agent_type  = AXI4_MASTER;
        foreach(master_configs[i]) master_configs[i].agent_cfg.if_type     = AXI4_LITE;

        // Enable default scoreboarding
        foreach(master_configs[i]) master_configs[i].agent_cfg.en_sb = 1'b1;

        // Enable assertions
        foreach(master_configs[i]) master_configs[i].m_bfm.config_enable_all_assertions = 1'b1;

        // Enable ready delays from delay db
        foreach(master_configs[i]) master_configs[i].en_ready_control = 1; 

        // Set data and address phase order 50% to 50%
        foreach(master_configs[i]) master_configs[i].m_bfm.config_write_ctrl_first_ratio = 1;
        foreach(master_configs[i]) master_configs[i].m_bfm.config_write_data_first_ratio = 1;

    endfunction


    //---------------------------------------------------------
    // Function: set_master_delay
    //---------------------------------------------------------
    
    // Set AXI4 masters read and write delays

    virtual function void set_master_delay();

        axi4_master_rd_delay_s min_rd_delays [] = new[MASTERS_AMOUNT];
        axi4_master_rd_delay_s max_rd_delays [] = new[MASTERS_AMOUNT];
        axi4_master_wr_delay_s min_wr_delays [] = new[MASTERS_AMOUNT];
        axi4_master_wr_delay_s max_wr_delays [] = new[MASTERS_AMOUNT];

        // Create master delays
        foreach(master_delays[i]) begin
            master_delays[i] = master_delay_t::type_id::
                create($sformatf("master_delays[%0d]", i));
        end

        foreach(master_delays[i]) begin
            master_delays[i].set_config(master_configs[i]);
        end

        // Set default delays for master read database
        // Min
        foreach(min_rd_delays[i]) min_rd_delays[i].rvalid2rready = '{3*i};
        // Max
        foreach(max_rd_delays[i]) max_rd_delays[i].rvalid2rready = '{5*i};
  
        foreach(master_delays[i]) begin
            master_delays[i].set_rd_def_delays(min_rd_delays[i], max_rd_delays[i]);
        end

        // Set default delays for master write database
        // Min
        foreach(min_wr_delays[i]) min_wr_delays[i].addr2data     = 3*i;
        foreach(min_wr_delays[i]) min_wr_delays[i].data2data     = '{3*i};
        foreach(min_wr_delays[i]) min_wr_delays[i].bvalid2bready = 3*i;
        // Max
        foreach(max_wr_delays[i]) max_wr_delays[i].addr2data     = 5*i;
        foreach(max_wr_delays[i]) max_wr_delays[i].data2data     = '{5*i};
        foreach(max_wr_delays[i]) max_wr_delays[i].bvalid2bready = 5*i;

        foreach(master_delays[i]) begin
            master_delays[i].set_wr_def_delays(min_wr_delays[i], max_wr_delays[i]);
        end

        foreach(master_configs[i]) master_configs[i].master_delay = master_delays[i];

    endfunction


    //---------------------------------------------------------
    // Function: set_slave_basic
    //---------------------------------------------------------
    
    // Configure AXI4 slaves's scoreboarding, assertions

    virtual function void set_slave_basic();

        // Configure AXI4-Lite slave
        foreach(slave_configs[i]) slave_configs[i].agent_cfg.agent_type  = AXI4_SLAVE;
        foreach(slave_configs[i]) slave_configs[i].agent_cfg.if_type     = AXI4_LITE;

        // Enable default scoreboarding
        foreach(slave_configs[i]) slave_configs[i].agent_cfg.en_sb = 1'b1;

        // Enable assertions
        foreach(slave_configs[i]) slave_configs[i].m_bfm.config_enable_all_assertions = 1'b1;

        // Disable assertions on protection and strobes
        foreach(slave_configs[i]) slave_configs[i].m_bfm.config_enable_assertion[AXI4_ARPROT_UNKN] = 1'b0;
        foreach(slave_configs[i]) slave_configs[i].m_bfm.config_enable_assertion[AXI4_AWPROT_UNKN] = 1'b0;
        foreach(slave_configs[i]) slave_configs[i].m_bfm.config_enable_assertion[AXI4_WSTRB_UNKN ] = 1'b0;

        // Enable ready delays from delay db
        foreach(slave_configs[i]) slave_configs[i].en_ready_control = 1;

        // Set slave ID
        // TODO: Can ID depend on slave num?
        foreach(slave_configs[i]) slave_configs[i].slave_id = 0;

    endfunction


    //---------------------------------------------------------
    // Function: set_slave_delay
    //---------------------------------------------------------
    
    // Set AXI4 slave read and write delays

    virtual function void set_slave_delay();

        axi4_slave_rd_delay_s min_rd_delays [] = new[SLAVES_AMOUNT];
        axi4_slave_rd_delay_s max_rd_delays [] = new[SLAVES_AMOUNT];
        axi4_slave_wr_delay_s min_wr_delays [] = new[SLAVES_AMOUNT];
        axi4_slave_wr_delay_s max_wr_delays [] = new[SLAVES_AMOUNT];

        foreach(slave_delays[i]) begin
            slave_delays[i] = slave_delay_t::type_id::
                create($sformatf("slave_delays[%0d]", i));
        end

        // Set address map
        foreach(slave_delays[i]) slave_delays[i].set_address_map(slave_configs[i].addr_map);

        // Set AXI4-Lite interface
        foreach(slave_delays[i]) slave_delays[i].set_axi4lite_interface(1);

        // Read database
        // Min
        foreach(min_rd_delays[i]) min_rd_delays[i].arvalid2arready = 3*i;
        foreach(min_rd_delays[i]) min_rd_delays[i].addr2data       = 3*i;
        foreach(min_rd_delays[i]) min_rd_delays[i].data2data       = '{3*i};
        // Max
        foreach(max_rd_delays[i]) max_rd_delays[i].arvalid2arready = 5*i;
        foreach(max_rd_delays[i]) max_rd_delays[i].addr2data       = 5*i;
        foreach(max_rd_delays[i]) max_rd_delays[i].data2data       = '{5*i};
  
        // Set default delays for slave read database
        foreach(slave_delays[i]) begin
            slave_delays[i].set_rd_def_delays(min_rd_delays[i], max_rd_delays[i]);
        end
  
        // Write database
        // Min
        foreach(min_wr_delays[i]) min_wr_delays[i].awvalid2awready = 3*i;
        foreach(min_wr_delays[i]) min_wr_delays[i].wvalid2wready   = '{3*i};
        foreach(min_wr_delays[i]) min_wr_delays[i].wlast2bvalid    = 3*i;
        // Max
        foreach(max_wr_delays[i]) max_wr_delays[i].awvalid2awready = 5*i;
        foreach(max_wr_delays[i]) max_wr_delays[i].wvalid2wready   = '{5*i};
        foreach(max_wr_delays[i]) max_wr_delays[i].wlast2bvalid    = 5*i;

        // Set default delays for slave write database
        foreach(slave_delays[i]) begin
            slave_delays[i].set_wr_def_delays(min_wr_delays[i], max_wr_delays[i]);
        end

        foreach(slave_configs[i]) slave_configs[i].slave_delay = slave_delays[i];

    endfunction


    //---------------------------------------------------------
    // Task: run_phase
    //---------------------------------------------------------
    
    // Main stimulus here

    virtual task run_phase(uvm_phase phase);

        create_w_seqs();
        create_r_seqs();

        fork
            run_seqs(phase);
            test_timeout();
        join_any
        disable fork;

        // If stats is enabled - process logs
        if(test_config.en_stats) write_logs();
    
    endtask


    //---------------------------------------------------------
    // Function: report_phase
    //---------------------------------------------------------

    // This phase end-simulation message

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_name(), {"\n\n*** Test was finished! ",
            "Check if there are errors in the console. ***\n"}, UVM_NONE)
    endfunction


    //---------------------------------------------------------
    // Function: create_w_seqs
    //---------------------------------------------------------

    // This function creates write sequences to run

    virtual function void create_w_seqs();
        axi4_liteic_wr_seq_base seq;
        foreach(w_seqs[i]) begin
            // Run random write sequences
            repeat(test_config.seq_am) begin
                seq = axi4_liteic_wr_seq_base::type_id::create("seq");
                seq.set_sequencer(masters[i].m_sequencer);
                seq.priority_vif = w_priority_vifs[i];
                seq.items_amount = test_config.item_per_seq_am;
                seq.pipelined_probability = 100;
                seq.configure();
                w_seqs[i].push_back(seq);
            end
        end
    endfunction


    //---------------------------------------------------------
    // Function: create_r_seqs
    //---------------------------------------------------------

    // This function creates read sequences to run

    virtual function void create_r_seqs();
        axi4_liteic_rd_seq_base seq;
        foreach(r_seqs[i]) begin
            // Run random read sequences
            repeat(test_config.seq_am) begin
                seq = axi4_liteic_rd_seq_base::type_id::create("seq");
                seq.set_sequencer(masters[i].m_sequencer);
                seq.priority_vif = r_priority_vifs[i];
                seq.items_amount = test_config.item_per_seq_am;
                seq.pipelined_probability = 100;
                seq.configure();
                r_seqs[i].push_back(seq);
            end
            foreach(r_seqs[i][j])
                r_seqs[i][j].host_wr_seq = w_seqs[i][j];
        end
    endfunction


    //---------------------------------------------------------
    // Task: run_seqs
    //---------------------------------------------------------

    // This task runs sequences
    
    virtual task run_seqs(uvm_phase phase);
        phase.raise_objection(this, "Starting sequences");
        fork
            begin
                foreach(w_seqs[i]) begin
                    automatic int j = i;
                    fork
                        run_seq_queue(w_seqs[j], j);
                        wait_seq_queue(w_seqs[j]);
                    join_none
                end
                wait fork;
            end
            begin
                foreach(r_seqs[i]) begin
                    automatic int j = i;
                    fork
                        run_seq_queue(r_seqs[j], j);
                        wait_seq_queue(r_seqs[j]);
                    join_none
                end
                wait fork;
            end
        join
        phase.drop_objection(this, "Sequences were completed");
    endtask


    //---------------------------------------------------------
    // Task: run_seq_queue
    //---------------------------------------------------------

    // This function runs sequences queue on master sequencer
    // defined by ~num~ argument

    virtual task run_seq_queue(axi4_liteic_seq_base seqs [$], input int num);
        `uvm_info(get_name(), $sformatf(
            "Running sequences on master[%0d]...", num), UVM_LOW);
        foreach(seqs[i]) begin
            fork begin
                fork begin
                    fork
                        seqs[i].start(masters[num].m_sequencer); 
                        seq_timeout(num);
                    join_any
                    disable fork;
                end join_none
                wait(seqs[i].start_cnt == seqs[i].items_amount);
            end join
        end
        `uvm_info(get_name(), $sformatf(
            "Sequences on master[%0d] are done!", num), UVM_LOW);
    endtask


    //---------------------------------------------------------
    // Task: wait_seq_queue
    //---------------------------------------------------------

    // This function waits sequences queue ending

    virtual task wait_seq_queue(axi4_liteic_seq_base seqs [$]);
        fork begin
            foreach(seqs[i]) begin
                automatic int j = i;
                fork begin
                    wait(seqs[j].end_cnt == seqs[j].items_amount);
                end join_none
            end
            wait fork;
        end join
    endtask


    //---------------------------------------------------------
    // Tasks: Timeouts
    //---------------------------------------------------------

    // Sequence timeout for ~num~ master
    
    virtual task seq_timeout(int num);
        // We expect at least 1 master
        master_configs[0].wait_for_reset();
        repeat(test_config.seq_timeout_clks)
            master_configs[0].wait_for_clock();
        `uvm_fatal(get_name(), $sformatf(
            "Sequence timeout on master[%0d]!", num));
    endtask

    // Test timeout
    
    virtual task test_timeout();
        // We expect at least 1 master
        master_configs[0].wait_for_reset();
        repeat(test_config.test_timeout_clks)
            master_configs[0].wait_for_clock();
        `uvm_fatal(get_name(), "Test timeout!");
    endtask


    //---------------------------------------------------------
    // Function: write_logs
    //---------------------------------------------------------
    
    // This function parses sequenes start and end times
    // and collects information to the log file which name
    // defined in test configuration ~log_file_name~ field
    
    virtual function void write_logs;

        // Create info base
        info_base = axi4_liteic_seq_info_base::
            type_id::create("info_base");

        // Add all sequences info to the database
        foreach(w_seqs[i]) begin
            axi4_liteic_wr_seq_base seqs [$] = w_seqs[i];
            foreach(seqs[j]) begin
                foreach(seqs[j].seq_info[k]) begin
                    axi4_liteic_seq_info infos [$]= seqs[j].seq_info[k];
                    foreach(infos[l]) begin
                        info_base.add_info(infos[l]);
                    end
                end
            end
        end
        foreach(r_seqs[i]) begin
            axi4_liteic_rd_seq_base seqs [$] = r_seqs[i];
            foreach(seqs[j]) begin
                foreach(seqs[j].seq_info[k]) begin
                    axi4_liteic_seq_info infos [$]= seqs[j].seq_info[k];
                    foreach(infos[l]) begin
                        info_base.add_info(infos[l]);
                    end
                end
            end
        end

        // Create log file
        info_base.create_log_file(
            test_config.log_file_name,
            test_config.en_logging
        );

    endfunction


endclass


//---------------------------------------------------------
// Class: axi4_liteic_custom_addr_map_test
//---------------------------------------------------------

// This test creates custom scenario there first half of
// masters interacts with zero slave only, and the second
// half with 1, 3, 5, 7, 9 slaves

class axi4_liteic_custom_addr_map_test extends axi4_liteic_test_base;

    `uvm_component_utils(axi4_liteic_custom_addr_map_test)
    `uvm_component_new


    //---------------------------------------------------------
    // Function: set_addr_map
    //---------------------------------------------------------
    
    virtual function void set_addr_map();

        axi4_liteic_addr_map_t addr_map_0 = '{
            axi4_liteic_slave_addr_map[0]
        };

        axi4_liteic_addr_map_t addr_map_1 = '{
            axi4_liteic_slave_addr_map[1],
            axi4_liteic_slave_addr_map[3],
            axi4_liteic_slave_addr_map[5],
            axi4_liteic_slave_addr_map[7],
            axi4_liteic_slave_addr_map[9]
        };

        // Map each slave to its address
        for(int i = 0; i < SLAVES_AMOUNT; i = i + 1) begin
            slave_configs[i].addr_map = convert_addr_map(
                '{axi4_liteic_slave_addr_map[i]}
            );
        end

        // Half masters interact with the first address area
        for(int i = 0; i < MASTERS_AMOUNT/2; i = i + 1) begin
            master_configs[i].addr_map = convert_addr_map(
                addr_map_0
            );
        end

        // Half masters interact with the second address area
        for(int i = MASTERS_AMOUNT/2; i < MASTERS_AMOUNT; i = i + 1) begin
            master_configs[i].addr_map = convert_addr_map(
                addr_map_1
            );
        end

    endfunction


endclass


//---------------------------------------------------------
// Class: axi4_liteic_common_test
//---------------------------------------------------------

// Scenario for this test is: all masters to all slaves!
// Delay for master: 0-2 cycles.
// Delay for slave: 0-3 cycles.
// All transactions are pipelined.

class axi4_liteic_common_test extends axi4_liteic_test_base;

    `uvm_component_utils(axi4_liteic_common_test)
    `uvm_component_new


    //---------------------------------------------------------
    // Function: set_addr_map
    //---------------------------------------------------------
    
    virtual function void set_addr_map();

        // Map each slave to its address
        for(int i = 0; i < SLAVES_AMOUNT; i = i + 1) begin
            slave_configs[i].addr_map = convert_addr_map(
                '{axi4_liteic_slave_addr_map[i]}
            );
        end

        // All masters can interact with all slaves
        for(int i = 0; i < MASTERS_AMOUNT; i = i + 1) begin
            master_configs[i].addr_map = convert_addr_map(
                axi4_liteic_slave_addr_map
            );
        end

    endfunction


    //---------------------------------------------------------
    // Function: set_master_delay
    //---------------------------------------------------------
    
    // Set AXI4 masters read and write delays

    virtual function void set_master_delay();

        axi4_master_rd_delay_s min_rd_delays [] = new[MASTERS_AMOUNT];
        axi4_master_rd_delay_s max_rd_delays [] = new[MASTERS_AMOUNT];
        axi4_master_wr_delay_s min_wr_delays [] = new[MASTERS_AMOUNT];
        axi4_master_wr_delay_s max_wr_delays [] = new[MASTERS_AMOUNT];

        // Create master delays
        foreach(master_delays[i]) begin
            master_delays[i] = master_delay_t::type_id::
                create($sformatf("master_delays[%0d]", i));
        end

        foreach(master_delays[i]) begin
            master_delays[i].set_config(master_configs[i]);
        end

        // Set default delays for master read database
        // Min
        foreach(min_rd_delays[i]) min_rd_delays[i].rvalid2rready = '{0};
        // Max
        foreach(max_rd_delays[i]) max_rd_delays[i].rvalid2rready = '{3};
  
        foreach(master_delays[i]) begin
            master_delays[i].set_rd_def_delays(min_rd_delays[i], max_rd_delays[i]);
        end

        // Set default delays for master write database
        // Min
        foreach(min_wr_delays[i]) min_wr_delays[i].addr2data     = 0;
        foreach(min_wr_delays[i]) min_wr_delays[i].data2data     = '{0};
        foreach(min_wr_delays[i]) min_wr_delays[i].bvalid2bready = 0;
        // Max
        foreach(max_wr_delays[i]) max_wr_delays[i].addr2data     = 2;
        foreach(max_wr_delays[i]) max_wr_delays[i].data2data     = '{2};
        foreach(max_wr_delays[i]) max_wr_delays[i].bvalid2bready = 2;

        foreach(master_delays[i]) begin
            master_delays[i].set_wr_def_delays(min_wr_delays[i], max_wr_delays[i]);
        end

        foreach(master_configs[i]) master_configs[i].master_delay = master_delays[i];

    endfunction


    //---------------------------------------------------------
    // Function: set_slave_delay
    //---------------------------------------------------------
    
    // Set AXI4 slave read and write delays

    virtual function void set_slave_delay();

        axi4_slave_rd_delay_s min_rd_delays [] = new[SLAVES_AMOUNT];
        axi4_slave_rd_delay_s max_rd_delays [] = new[SLAVES_AMOUNT];
        axi4_slave_wr_delay_s min_wr_delays [] = new[SLAVES_AMOUNT];
        axi4_slave_wr_delay_s max_wr_delays [] = new[SLAVES_AMOUNT];

        foreach(slave_delays[i]) begin
            slave_delays[i] = slave_delay_t::type_id::
                create($sformatf("slave_delays[%0d]", i));
        end

        // Set address map
        foreach(slave_delays[i]) slave_delays[i].set_address_map(slave_configs[i].addr_map);

        // Set AXI4-Lite interface
        foreach(slave_delays[i]) slave_delays[i].set_axi4lite_interface(1);

        // Read database
        // Min
        foreach(min_rd_delays[i]) min_rd_delays[i].arvalid2arready = 0;
        foreach(min_rd_delays[i]) min_rd_delays[i].addr2data       = 0;
        foreach(min_rd_delays[i]) min_rd_delays[i].data2data       = '{0};
        // Max
        foreach(max_rd_delays[i]) max_rd_delays[i].arvalid2arready = 4;
        foreach(max_rd_delays[i]) max_rd_delays[i].addr2data       = 4;
        foreach(max_rd_delays[i]) max_rd_delays[i].data2data       = '{4};
  
        // Set default delays for slave read database
        foreach(slave_delays[i]) begin
            slave_delays[i].set_rd_def_delays(min_rd_delays[i], max_rd_delays[i]);
        end
  
        // Write database
        // Min
        foreach(min_wr_delays[i]) min_wr_delays[i].awvalid2awready = 0;
        foreach(min_wr_delays[i]) min_wr_delays[i].wvalid2wready   = '{0};
        foreach(min_wr_delays[i]) min_wr_delays[i].wlast2bvalid    = 0;
        // Max
        foreach(max_wr_delays[i]) max_wr_delays[i].awvalid2awready = 4;
        foreach(max_wr_delays[i]) max_wr_delays[i].wvalid2wready   = '{4};
        foreach(max_wr_delays[i]) max_wr_delays[i].wlast2bvalid    = 4;

        // Set default delays for slave write database
        foreach(slave_delays[i]) begin
            slave_delays[i].set_wr_def_delays(min_wr_delays[i], max_wr_delays[i]);
        end

        foreach(slave_configs[i]) slave_configs[i].slave_delay = slave_delays[i];

    endfunction


endclass


//---------------------------------------------------------
// Class: axi4_liteic_1k_test
//---------------------------------------------------------

// Common test with 1k read and 1k write transactions

class axi4_liteic_1k_test extends axi4_liteic_common_test;

    `uvm_component_utils(axi4_liteic_1k_test)
    `uvm_component_new


    //---------------------------------------------------------
    // Function: create_configs
    //---------------------------------------------------------
    
    // Create agents configurations by dimensions
    // Also create test configuration

    virtual function void create_configs();

        super.create_configs();

        test_config.seq_am = 1000 / (MASTERS_AMOUNT * 10);
        test_config.item_per_seq_am = 10;
        // 10000 cycles on sequence from 10 transactions
        test_config.seq_timeout_clks = 10000;
    
    endfunction


endclass


//---------------------------------------------------------
// Class: axi4_liteic_10k_test
//---------------------------------------------------------

// Common test with 10k read and 10k write transactions

class axi4_liteic_10k_test extends axi4_liteic_common_test;

    `uvm_component_utils(axi4_liteic_10k_test)
    `uvm_component_new


    //---------------------------------------------------------
    // Function: create_configs
    //---------------------------------------------------------
    
    // Create agents configurations by dimensions
    // Also create test configuration

    virtual function void create_configs();

        super.create_configs();

        test_config.seq_am = 10000 / (MASTERS_AMOUNT * 10);
        test_config.item_per_seq_am = 10;
        // 10000 cycles on sequence from 10 transactions
        test_config.seq_timeout_clks = 10000;
    
    endfunction


endclass


//---------------------------------------------------------
// Class: axi4_liteic_50k_test
//---------------------------------------------------------

// Common test with 30k read and 30k write transactions

class axi4_liteic_30k_test extends axi4_liteic_common_test;

    `uvm_component_utils(axi4_liteic_30k_test)
    `uvm_component_new


    //---------------------------------------------------------
    // Function: create_configs
    //---------------------------------------------------------
    
    // Create agents configurations by dimensions
    // Also create test configuration

    virtual function void create_configs();

        super.create_configs();

        test_config.seq_am = 30000 / (MASTERS_AMOUNT * 10);
        test_config.item_per_seq_am = 10;
        // 10000 cycles on sequence from 10 transactions
        test_config.seq_timeout_clks = 10000;
    
    endfunction


endclass