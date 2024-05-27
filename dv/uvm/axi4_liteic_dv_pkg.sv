//---------------------------------------------------------
// Package: axi4_liteic_dv_pkg
//---------------------------------------------------------

// LiteIc AXI4 DV package

package axi4_liteic_dv_pkg;

    //---------------------------------------------------------
    // Imports
    //---------------------------------------------------------

    `include "uvm_macros.svh"
    import uvm_pkg::*;
    import mvc_pkg::*;

    import mgc_axi4_v1_0_pkg::*;
    import mgc_axi4lite_seq_pkg::*;
    import addr_map_pkg::*;
    import QUESTA_MVC::*;


    //---------------------------------------------------------
    // Include: Utility
    //---------------------------------------------------------

    `include "axi4_liteic_utils.sv"


    //---------------------------------------------------------
    // Parameters: Common
    //---------------------------------------------------------
    
    parameter CLK_PERIOD = 10;


    //---------------------------------------------------------
    // Parameters: LiteIc AXI4
    //---------------------------------------------------------
    
    parameter MASTERS_AMOUNT = 20;
    parameter SLAVES_AMOUNT  = 12;

    parameter DATA_WIDTH       = 32;
    parameter ADDR_WIDTH       = 32;
    parameter ADDR_ALIGN_WIDTH = $clog2(ADDR_WIDTH/8);
    parameter PRIORITY_WIDTH   = 4;


    //---------------------------------------------------------
    // Parameters: AXI4 VIP
    //---------------------------------------------------------

    parameter ID_WIDTH        = 1;
    parameter USER_WIDTH      = 1;
    parameter REGION_MAP_SIZE = 1;


    //---------------------------------------------------------
    // Typedef: Priority
    //---------------------------------------------------------
    
    typedef logic [PRIORITY_WIDTH-1:0] priority_t;


    //---------------------------------------------------------
    // Typedef: Priority virtual interface
    //---------------------------------------------------------
    
    typedef virtual axi4_liteic_priority_if #(PRIORITY_WIDTH)
        axi4_liteic_priority_vif;


    //---------------------------------------------------------
    // Typedef: Access type
    //---------------------------------------------------------

    typedef enum {
        R,
        W
    } axi4_liteic_acc_type_e;

    
    //---------------------------------------------------------
    // Typedef: Address typedefs
    //---------------------------------------------------------
    
    typedef bit [ADDR_WIDTH-1:0] addr_t;
    typedef addr_t addrarr_t [$];


    //---------------------------------------------------------
    // Typedef: bfm_type
    //---------------------------------------------------------
    
    // AXI4 interface with DUT parameters

    typedef virtual mgc_axi4 #(`PARAMS_INST) bfm_type;


    //---------------------------------------------------------
    // Typedef: config_t
    //---------------------------------------------------------
    
    // AXI4 configuration

    typedef axi4_vip_config #(`PARAMS_INST) config_t;


    //---------------------------------------------------------
    // Typedef: agent_t
    //---------------------------------------------------------
    
    // AXI4 agent

    typedef axi4_agent #(`PARAMS_INST) agent_t;


    //---------------------------------------------------------
    // Typedef: master_delay_t
    //---------------------------------------------------------
    
    // AXI4 master delay settings
    
    typedef axi4_master_delay_db #(`PARAMS_INST) master_delay_t;


    //---------------------------------------------------------
    // Typedef: slave_delay_t
    //---------------------------------------------------------
    
    // AXI4 slave delay settings

    typedef axi4_slave_delay_db slave_delay_t;


    //---------------------------------------------------------
    // Typedef: addr_map_t
    //---------------------------------------------------------
    
    // Address map

    typedef addr_map_pkg::address_map addr_map_t;


    //---------------------------------------------------------
    // Include: Objects and components 
    //---------------------------------------------------------

    `include "axi4_liteic_test_cfg.sv"
    `include "axi4_liteic_addr_pool.sv"
    `include "axi4_liteic_priority_pool.sv"
    `include "axi4_liteic_addr_map.sv"
    `include "axi4_liteic_logging.sv"
    `include "axi4_liteic_seq_lib.sv"
    `include "axi4_liteic_test_lib.sv"


endpackage
