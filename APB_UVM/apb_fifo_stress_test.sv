package fifo_stress_pkg;
import apb_env_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_config_pkg::*;
import apb_shared_pkg::*;
import apb_sequence_item_pkg::*;
import apb_sequence_pkg::*;
import apb_config_pkg::*;
import apb_env_pkg::*;

class apb_fifo_stress_test extends uvm_test;
    `uvm_component_utils(apb_fifo_stress_test)
    apb_env env; 
    apb_config apb_cfg;
    virtual apb_if apb_vif;
    apb_rst_sequence rst_seq;

    function new(string name = "apb_fifo_stress_test",uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        env = apb_env::type_id::create("env",this);
        apb_cfg = apb_config::type_id::create("apb_cfg");
        rst_seq = apb_rst_sequence::type_id::create("rst_seq");

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

        phase.drop_objection(this);
    endtask
endclass
endpackage