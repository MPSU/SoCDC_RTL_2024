//---------------------------------------------------------
// Class: axi4_liteic_test_cfg_base
//---------------------------------------------------------

// AXI4 LiteIC test configuration

class axi4_liteic_test_cfg_base extends uvm_object;

    `uvm_object_utils(axi4_liteic_test_cfg_base)


    //---------------------------------------------------------
    // Field: clp
    //---------------------------------------------------------
    
    // Commandline processor inst

    static uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();


    //---------------------------------------------------------
    // Field: test_timeout_clks
    //---------------------------------------------------------
    
    int unsigned test_timeout_clks = 1000000;


    //---------------------------------------------------------
    // Field: seq_timeout_clks
    //---------------------------------------------------------
    
    int unsigned seq_timeout_clks = 50000;


    //---------------------------------------------------------
    // Fields: Sequences settings
    //---------------------------------------------------------

    // Amount of sequences

    int unsigned seq_am = 100;

    // Amount of items per sequence

    int unsigned item_per_seq_am = 10;
    

    //---------------------------------------------------------
    // Field: en_stats
    //---------------------------------------------------------
    
    // This flag enables statistics

    bit en_stats = 0;


    //---------------------------------------------------------
    // Field: en_logging
    //---------------------------------------------------------
    
    // This flag enables logging
    // Only active if ~en_stats~ is 1

    bit en_logging = 0;


    //---------------------------------------------------------
    // Field: log_file_name
    //---------------------------------------------------------
    
    // Log file name

    string log_file_name = "hack_2024_rtl_stats.txt";


    //---------------------------------------------------------
    // Function: new
    //---------------------------------------------------------
    
    function new (string name = "");
        super.new( name );
        get_plusargs();
    endfunction


    //---------------------------------------------------------
    // Function: get_plusargs
    //---------------------------------------------------------
    
    virtual function void get_plusargs();
        string str;
        if(clp.get_arg_value("+test_timeout_clks=", str))
            test_timeout_clks = str.atoi();
        if(clp.get_arg_value("+seq_timeout_clks=", str))
            seq_timeout_clks = str.atoi();
        if(clp.get_arg_value("+seq_am=", str))
            seq_am = str.atoi();
        if(clp.get_arg_value("+item_per_seq_am=", str))
            item_per_seq_am = str.atoi();
        if(clp.get_arg_value("+en_stats=", str))
            en_stats = str.atoi();
        if(clp.get_arg_value("+en_logging=", str))
            en_logging = str.atoi();
        if(clp.get_arg_value("+log_file_name=", str))
            log_file_name = str;
    endfunction


endclass