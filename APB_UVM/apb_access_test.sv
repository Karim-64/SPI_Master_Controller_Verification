package apb_test_pkg;
import apb_env_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
  import apb_config_pkg::*;
  import apb_shared_pkg::*;
  import apb_sequence_item_pkg::*;
  import apb_sequence_pkg::*;
  import apb_config_pkg::*;
  import apb_env_pkg::*;

class apb_access_test extends uvm_test;
    `uvm_component_utils(apb_access_test)
    apb_env env; 
    apb_config apb_cfg;
    apb_rst_sequence rst_seq; 
    apb_ctrl_sequence ctrl_seq;
    apb_write_read_sequence write_read_seq;
    apb_status_sequence status_seq;
    apb_CLK_DIV_sequence clk_div_seq;
    apb_ss_ctrl_sequence ss_ctrl_seq;
    virtual apb_if apb_vif;


    function new(string name = "apb_access_test",uvm_component parent = null);
      super.new(name,parent);
    endfunction

    function void build_phase (uvm_phase phase);
      super.build_phase(phase);
        env = apb_env::type_id::create("env",this);
        apb_cfg = apb_config::type_id::create("apb_cfg");
        rst_seq = apb_rst_sequence::type_id::create("rst_seq");
        ctrl_seq = apb_ctrl_sequence::type_id::create("ctrl_seq");
        write_read_seq = apb_write_read_sequence::type_id::create("write_read_seq");
        status_seq = apb_status_sequence::type_id::create("status_seq");
        clk_div_seq = apb_CLK_DIV_sequence::type_id::create("clk_div_seq");
        ss_ctrl_seq = apb_ss_ctrl_sequence::type_id::create("ss_ctrl_seq");
      if(!uvm_config_db #(virtual apb_if)::get(this,"","APB_IF",apb_cfg.apb_vif))
        `uvm_fatal("build_phase","Test - unable to get the virtual interface of the apb from the uvm_config_db")
      uvm_config_db #(apb_config)::set(this,"*","apb_CFG",apb_cfg);
        apb_cfg.is_active = UVM_ACTIVE;
    endfunction
  
    task run_phase (uvm_phase phase);
      super.run_phase(phase);
      phase.raise_objection(this);
      `uvm_info("run_phase","rst_seq stimulus generation started",UVM_LOW)
          rst_seq.start(env.agent.sqr);
      `uvm_info("run_phase","rst_seq stimulus generation ended",UVM_LOW)

      `uvm_info("run_phase","ctrl_seq stimulus generation started",UVM_LOW)
          ctrl_seq.start(env.agent.sqr);
      `uvm_info("run_phase","ctrl_seq stimulus generation ended",UVM_LOW)

      `uvm_info("run_phase","write_read_seq stimulus generation started",UVM_LOW)
          write_read_seq.start(env.agent.sqr);
      `uvm_info("run_phase","write_read_seq stimulus generation ended",UVM_LOW)

      `uvm_info("run_phase","status_seq stimulus generation started",UVM_LOW)
          status_seq.start(env.agent.sqr);
      `uvm_info("run_phase","status_seq stimulus generation ended",UVM_LOW)

      `uvm_info("run_phase","clk_div_seq stimulus generation started",UVM_LOW)
          clk_div_seq.start(env.agent.sqr);
      `uvm_info("run_phase","clk_div_seq stimulus generation ended",UVM_LOW)

      `uvm_info("run_phase","ss_ctrl_seq stimulus generation started",UVM_LOW)
          ss_ctrl_seq.start(env.agent.sqr);
      `uvm_info("run_phase","ss_ctrl_seq stimulus generation ended",UVM_LOW)


      phase.drop_objection(this);
    endtask
endclass
endpackage