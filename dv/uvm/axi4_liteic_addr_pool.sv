//---------------------------------------------------------
// Class: axi4_liteic_addr_pool
//---------------------------------------------------------

// Address pool class. This singleton is shared between all
// sequences. Any sequence can request adrresses queue in
// some range via ~request_addr_pool~

class axi4_liteic_addr_pool extends uvm_object;

    `uvm_object_utils(axi4_liteic_addr_pool)


    //---------------------------------------------------------
    // Field: m_inst
    //---------------------------------------------------------
    
    // Singleton

    protected static axi4_liteic_addr_pool m_inst;


    //---------------------------------------------------------
    // Field: addr_history
    //---------------------------------------------------------
    
    // History of generated addresses

    protected addrarr_t addr_history;


    //---------------------------------------------------------
    // Field: pool
    //---------------------------------------------------------
    
    protected addrarr_t pool;


    //---------------------------------------------------------
    // Field: retry_am
    //---------------------------------------------------------
    
    // Address randomization retry amount

    protected static int unsigned retry_am = 100;


    //---------------------------------------------------------
    // Function: new
    //---------------------------------------------------------

    protected function new(string name = "");
        super.new(name);
    endfunction


    //---------------------------------------------------------
    // Function: get_inst
    //---------------------------------------------------------
    
    // Get singleton

    static function axi4_liteic_addr_pool get_inst();
        if( m_inst == null ) begin
            m_inst = axi4_liteic_addr_pool::type_id::create("addr_pool");
        end
        return m_inst;
    endfunction

    
    //---------------------------------------------------------
    // Function: set_retry_cnt
    //---------------------------------------------------------
    
    // Set retry amount

    static function void set_retry_cnt(int unsigned am);
        retry_am = am;
    endfunction


    //---------------------------------------------------------
    // Function: request_addr_pool
    //---------------------------------------------------------
    
    // Function returns random address pool in given range

    function addrarr_t request_addr_pool(
        addr_t        range [2],
        int unsigned  size
    );

        addr_t addr; bit result;

        `uvm_info(get_name(), $sformatf({"Randomizing address pool ",
            "in range [%0d:%0d] with %0d entries..."},
                range[0], range[1], size), UVM_HIGH);

        // Randomize address pool
        pool.delete();
        repeat(size) begin
            repeat(retry_am) begin
                addr = $urandom_range(range[0], range[1]);
                addr[ADDR_ALIGN_WIDTH-1:0] = 'b0;
                if( !(addr inside {addr_history} ) &&
                    !(addr inside {pool}         )
                ) begin
                    pool.push_back(addr);
                    result = 1;
                    break;
                end
            end
            if( !result ) begin
                `uvm_fatal(get_name(), $sformatf({"Address was not randomized",
                    "in %0d attempts! Possible address range issue."}, retry_am));
            end
            result = 0;
        end

        // Update history
        update_addr_history(pool);

        return pool;

    endfunction


    //---------------------------------------------------------
    // Function: update_addr_history
    //---------------------------------------------------------
    
    // Updates address history with ~pool~ address queue

    function void update_addr_history(addrarr_t pool);
        addr_history = {addr_history, pool};
    endfunction


    //---------------------------------------------------------
    // Function: update_addr_history
    //---------------------------------------------------------
    
    // Deletes address history

    function void delete_addr_history();
        addr_history.delete();
    endfunction


endclass