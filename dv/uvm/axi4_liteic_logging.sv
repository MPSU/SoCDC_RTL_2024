//---------------------------------------------------------
// Library: AXI4 LiteIC logging library
//---------------------------------------------------------

// This library contains classes, typedefs and etc.
// for AXI4 LiteIC logging routines


//---------------------------------------------------------
// Class: axi4_liteic_seq_info
//---------------------------------------------------------

// This class contains logging information about sequence

class axi4_liteic_seq_info extends uvm_object;

    `uvm_object_utils(axi4_liteic_seq_info)
    `uvm_object_new


    //---------------------------------------------------------
    // Fields
    //---------------------------------------------------------

    // Start and end time of sequence

    time start_time;
    time end_time;

    // Access type

    axi4_liteic_acc_type_e acc_type;

    // Sequence address

    longint unsigned addr;

    // Sequence priority

    priority_t prior;


    //---------------------------------------------------------
    // Functions: Do-hooks
    //---------------------------------------------------------
    
    virtual function void do_copy(uvm_object rhs);
        axi4_liteic_seq_info that;
        if (!$cast(that, rhs)) begin
            `uvm_error( get_name(), "rhs is not an axi4_liteic_seq_info" )
            return;
        end
        super.do_copy(rhs);
        this.start_time = that.start_time;
        this.end_time   = that.end_time;
        this.acc_type   = that.acc_type;
        this.addr       = that.addr;
    endfunction


endclass


//---------------------------------------------------------
// Class: axi4_liteic_seq_info_base
//---------------------------------------------------------

// Class for collecting AXI4 LiteIC transactions info
// into single database

class axi4_liteic_seq_info_base extends uvm_object;

    `uvm_object_utils(axi4_liteic_seq_info_base)
    `uvm_object_new


    //---------------------------------------------------------
    // Field: base
    //---------------------------------------------------------
    
    // Collection of AXI4 LiteIC transactions infos

    protected axi4_liteic_seq_info base [$];


    //---------------------------------------------------------
    // Function: clear
    //---------------------------------------------------------
    
    // Clear database

    virtual function void clear();
        base.delete();
    endfunction


    //---------------------------------------------------------
    // Function: add_info
    //---------------------------------------------------------
    
    // Add sequence info to the database

    virtual function void add_info(axi4_liteic_seq_info info);
        base.push_back(info);
    endfunction


    //---------------------------------------------------------
    // Function: create_log_file
    //---------------------------------------------------------
    
    // Create log file with all sequences info
    // Detailed seqeuences logging can be enabled
    // via ~en_logging~

    virtual function void create_log_file(
        string log_file_name,
        bit    en_logging
    );

        // Write header
        `uvm_info("LOGGING", $sformatf( {"Transactions log will ",
            "be saved to %s"}, log_file_name), UVM_NONE);
        main_header_log_file(log_file_name);

        // Write statistics
        `uvm_info("LOGGING", "Calculating statistics...", UVM_NONE);
        add_log_file(log_file_name, $sformatf(
            "\n\nAXI4 LiteIC simulation statistics at %s", get_date()), "a");
        avg_latency_log_file      (log_file_name);
        avg_prior_latency_log_file(log_file_name);
        avg_throughput_log_file   (log_file_name);

        // Write sequence info
        if( en_logging ) begin
            `uvm_info("LOGGING", "Obtaining transactions info...", UVM_NONE);
            add_log_file(log_file_name, $sformatf(
                "\n\nAXI4 LiteIC transactions log at %s", get_date()), "a");
            table_main_header_log_file(log_file_name);
            append_infos_log_file(log_file_name, base);
        end

    endfunction


    //---------------------------------------------------------
    // Function: add_log_file
    //---------------------------------------------------------
    
    // This function add string ~data~ to log file with
    // ~log_file_name~ name. File is opened with ~access~ access

    virtual function void add_log_file(
        string log_file_name,
        string data,
        string access
    );

        // Open file for logging
        int fd = $fopen(log_file_name, access);

        // Write info
        $fwrite(fd, data);

        // Close file
        $fclose(fd);
    
    endfunction


    //---------------------------------------------------------
    // Function: main_header_log_file
    //---------------------------------------------------------

    // This function creates log file with ~log_file_name~ name

    virtual function void main_header_log_file(
        string log_file_name
    );

        // Write header
        add_log_file(log_file_name,
            "\nSoC Design Challenge 2024. MIET & Yadro\n", "w");
    
    endfunction


    //---------------------------------------------------------
    // Function: table_main_header_log_file
    //---------------------------------------------------------

    // This function creates table header in the log file with
    // ~log_file_name~ name with ~comment~ comment

    virtual function void table_main_header_log_file(
        string log_file_name,
        string comment = ""
    );

        string str;

        // Open file for logging
        int fd = $fopen(log_file_name, "a");

        // Write table header
        $fwrite(fd, comment);
        $fwrite(fd, $sformatf("%s", {"\n", {150{"-"}}, "\n"}));
        $fwrite(fd, $sformatf("%s", {
            { 4{" "}}, "Access type", { 8{" "}},
            { 6{" "}}, "Address",     {15{" "}},
            {17{" "}}, "Priority",    { 6{" "}},
            {15{" "}}, "Start time",  {14{" "}},
            { 9{" "}}, "End time"
        }));
        $fwrite(fd, $sformatf("%s", {"\n", {150{"-"}}, "\n"}));

        $fclose(fd);
    
    endfunction


    //---------------------------------------------------------
    // Function: append_infos_log_file
    //---------------------------------------------------------

    // This function appends ~infos~ to the log file with
    // ~log_file_name~ name

    virtual function void append_infos_log_file(
        string               log_file_name,
        axi4_liteic_seq_info infos [$]
    );

        // Open file for logging
        int fd = $fopen(log_file_name, "a");

        // Write info
        foreach(infos[i]) begin
            $fwrite(fd, $sformatf({
                "\n",
                {8{" "}}, "%s"  , {8{" "}},
                {8{" "}}, "%16h", {8{" "}},
                {8{" "}}, "%16d", {8{" "}},
                {8{" "}}, "%16t", {8{" "}},
                {8{" "}}, "%16t", {8{" "}},
                "\n"
            }, infos[i].acc_type,
               infos[i].addr,
               infos[i].prior,
               infos[i].start_time,
               infos[i].end_time
            ));
        end

        $fclose(fd);
    
    endfunction


    //---------------------------------------------------------
    // Function: avg_latency_log_file
    //---------------------------------------------------------

    // This function calculates average database latency and 
    // writes result to the log file with ~log_file_name~ name

    virtual function void avg_latency_log_file(
        string log_file_name
    );

        time latency [$]; real avg_latency;

        // Calculate latency for each sequence
        foreach(base[i]) begin
            latency.push_back(base[i].end_time - base[i].start_time);
        end

        // Calculate average latency
        avg_latency = real'(latency.sum()) / latency.size();

        // Write average latency
        add_log_file(log_file_name, $sformatf({"\n Average latency (ns): ",
            "%0d / %0d = %.4f \n"}, latency.sum(), latency.size(), avg_latency), "a");
        
        // Write average latency in cycles
        add_log_file(log_file_name, $sformatf({"\n Average latency (cycles): ",
            "%0.4f / %0d = %.4f \n"}, avg_latency, CLK_PERIOD,
                avg_latency / CLK_PERIOD ), "a");
    
    endfunction


    //---------------------------------------------------------
    // Function: avg_prior_latency_log_file
    //---------------------------------------------------------

    // This function calculates average database latency and 
    // writes result to the log file with ~log_file_name~ name

    virtual function void avg_prior_latency_log_file(
        string log_file_name
    );

        time latency [$]; real avg_prior_latency;

        // Calculate latency depending priority for each sequence
        foreach(base[i]) begin
            latency.push_back(
                (base[i].end_time - base[i].start_time) * (base[i].prior + 1)
            );
        end

        // Calculate average latency
        avg_prior_latency = real'(latency.sum()) / latency.size();

        // Write average latency
        add_log_file(log_file_name, $sformatf({"\n Average latency with priority (ns): ",
            "%0d / %0d = %.4f \n"}, latency.sum(), latency.size(), avg_prior_latency), "a");
        
        // Write average latency in cycles
        add_log_file(log_file_name, $sformatf({"\n Average latency with priority (cycles): ",
            "%0.4f / %0d = %.4f \n"}, avg_prior_latency, CLK_PERIOD,
                avg_prior_latency / CLK_PERIOD ), "a");
    
    endfunction



    //---------------------------------------------------------
    // Function: avg_throughput_log_file
    //---------------------------------------------------------

    // This function calculates average database throughput and 
    // writes result to the log file with ~log_file_name~ name

    virtual function void avg_throughput_log_file(
        string log_file_name
    );

        real avg_throughput; axi4_liteic_seq_info infos [2];

        // Find the first started sequence
        base.sort(x) with (x.start_time); $cast(infos[0], base[0].clone());

        // Find the last ended sequence
        base.rsort(x) with (x.end_time); $cast(infos[1], base[0].clone());

        // Calculate average throughput (bit/ns)
        avg_throughput = real'(base.size()) / (infos[1].end_time - infos[0].start_time) * DATA_WIDTH;

        // Convert throughput to mbit/s
        avg_throughput = (avg_throughput * 10**9) / 10.0**6;

        // Write average latency
        add_log_file(log_file_name, $sformatf({"\n Average throughput (MBit/s): ",
            "%0d / (%0d - %0d) * %0d = %.4f \n"}, base.size(), infos[1].end_time,
                infos[0].start_time, DATA_WIDTH, avg_throughput), "a");
    
    endfunction


endclass
