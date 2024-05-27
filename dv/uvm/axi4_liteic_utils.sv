//---------------------------------------------------------
// Utility: LiteIc AXI4 utilities
//---------------------------------------------------------

// UVM object new

`define uvm_object_new \
    function new (string name = ""); \
        super.new( name ); \
    endfunction

// UVM component new

`define uvm_component_new \
    function new(string name , uvm_component parent); \
        super.new(name, parent); \
    endfunction

// AXI4 parameters instance

`define PARAMS_INST \
    .AXI4_ADDRESS_WIDTH   ( axi4_liteic_dv_pkg::ADDR_WIDTH      ), \
    .AXI4_RDATA_WIDTH     ( axi4_liteic_dv_pkg::DATA_WIDTH      ), \
    .AXI4_WDATA_WIDTH     ( axi4_liteic_dv_pkg::DATA_WIDTH      ), \
    .AXI4_ID_WIDTH        ( axi4_liteic_dv_pkg::ID_WIDTH        ), \
    .AXI4_USER_WIDTH      ( axi4_liteic_dv_pkg::USER_WIDTH      ), \
    .AXI4_REGION_MAP_SIZE ( axi4_liteic_dv_pkg::REGION_MAP_SIZE )

// Function for getting current date and time as string

function automatic string get_date();    
    int fd; string date;
    void'($system("date > localtime"));
    fd = $fopen("localtime", "r");
    void'($fgets(date, fd));
    $fclose(fd);
    void'($system("rm localtime"));
    return date;
endfunction