package spi_core_test_pkg;
import spi_core_env_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
  import spi_core_config_pkg::*;
  import spi_core_shared_pkg::*;
  import spi_core_sequence_item_pkg::*;
  import spi_core_sequence_pkg::*;
  import spi_core_config_pkg::*;
  import spi_core_env_pkg::*;

class spi_core_test extends uvm_test;
    `uvm_component_utils(spi_core_test)
    spi_core_env env; 
    spi_core_config spi_core_cfg;
  
    virtual spi_core_if spi_core_vif;


    function new(string name = "spi_core_test",uvm_component parent = null);
      super.new(name,parent);
    endfunction

    function void build_phase (uvm_phase phase);
      super.build_phase(phase);
        env = spi_core_env::type_id::create("env",this);
        spi_core_cfg = spi_core_config::type_id::create("spi_core_cfg");
        // create sequences

      if(!uvm_config_db #(virtual spi_core_if)::get(this,"","spi_core_IF",spi_core_cfg.spi_core_vif))
        `uvm_fatal("build_phase","Test - unable to get the virtual interface of the spi_core from the uvm_config_db")
      uvm_config_db #(spi_core_config)::set(this,"*","spi_core_CFG",spi_core_cfg);
        spi_core_cfg.is_active = UVM_ACTIVE;
    endfunction
  
    task run_phase (uvm_phase phase);
      super.run_phase(phase);
      phase.raise_objection(this);
      // create tests like this

      //`uvm_info("run_phase","rst_seq stimulus generation started",UVM_LOW)
      //    rst_seq.start(env.agent.sqr);
      //`uvm_info("run_phase","rst_seq stimulus generation ended",UVM_LOW)



      phase.drop_objection(this);
    endtask
endclass
endpackage