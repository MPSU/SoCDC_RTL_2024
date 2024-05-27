//---------------------------------------------------------
// Class: axi4_liteic_priority_pool
//---------------------------------------------------------

// Priority pool class. This singleton is shared between all
// sequences. Any sequence can request priority in via
// ~request_prior~

class axi4_liteic_priority_pool extends uvm_object;

    `uvm_object_utils(axi4_liteic_priority_pool)


    //---------------------------------------------------------
    // Field: m_inst
    //---------------------------------------------------------
    
    // Singleton

    protected static axi4_liteic_priority_pool m_inst;


    //---------------------------------------------------------
    // Field: test_config
    //---------------------------------------------------------
    
    // Test config

    axi4_liteic_test_cfg_base test_config;


    //---------------------------------------------------------
    // Field: pool
    //---------------------------------------------------------
    
    protected priority_t pool [$];


    //---------------------------------------------------------
    // Function: new
    //---------------------------------------------------------

    protected function new(string name = "");
        super.new(name);
        if(!uvm_resource_db #( axi4_liteic_test_cfg_base )::read_by_name( get_full_name(),
            "test_config", test_config )) `uvm_fatal(get_name() , "uvm_config_db \
                #( axi4_liteic_test_cfg_base )::get cannot find resource test_config")
        create_pool();
    endfunction


    //---------------------------------------------------------
    // Function: get_inst
    //---------------------------------------------------------
    
    // Get singleton

    static function axi4_liteic_priority_pool get_inst();
        if( m_inst == null ) begin
            m_inst = axi4_liteic_priority_pool::type_id::create("priority_pool");
        end
        return m_inst;
    endfunction


    //---------------------------------------------------------
    // Function: create_pool
    //---------------------------------------------------------
    
    // Function creates priority pool

    function void create_pool();

        // Values amount for each priority and in common
        int comm_am; int prior_am;

        // Find how many values we need in common
        // x2 multiplier because write and read sequences
        comm_am = 2 * axi4_liteic_dv_pkg::MASTERS_AMOUNT *
            test_config.seq_am * test_config.item_per_seq_am;

        // Find how many values for each priority we need
        prior_am = comm_am / 2**PRIORITY_WIDTH;

        // Fill address pool
        for(int i = 0; i < 2**PRIORITY_WIDTH; i = i + 1) begin
            repeat(prior_am) begin
                pool.push_back(i);
            end
        end

        // Fill the last values with highest priority
        comm_am = comm_am - pool.size();
        repeat( comm_am  ) begin
            pool.push_back(2**PRIORITY_WIDTH-1);
        end

        // Shuffle priority pool
        pool.shuffle();

    endfunction


    //---------------------------------------------------------
    // Function: request_prior
    //---------------------------------------------------------
    
    // Function returns random priority from pool

    function priority_t request_prior();
        
        return pool.pop_front();

    endfunction


endclass
