package apb_monitor_pkg;
    import uvm_pkg::*;
    import apb_shared_pkg::*;
    import apb_sequence_item_pkg::*;
    `include "uvm_macros.svh"
    class apb_monitor extends uvm_monitor ;
        `uvm_component_utils(apb_monitor);

        virtual apb_if vif_cfg; 
        apb_sequence_item rsp_seq_item;

        uvm_analysis_port #(apb_sequence_item) mon_ap;

        function new (string name = "apb_monitor" , uvm_component parent = null);
            super.new(name,parent);
        endfunction

        function void build_phase (uvm_phase phase);
            super.build_phase(phase);
            mon_ap = new("mon_ap",this);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                rsp_seq_item = apb_sequence_item::type_id::create("rsp_seq_item");
                @(negedge vif_cfg.PCLK); 
                rsp_seq_item.PRESETn             = vif_cfg.PRESETn;
                rsp_seq_item.PSEL                = vif_cfg.PSEL;
                rsp_seq_item.PENABLE             = vif_cfg.PENABLE;
                rsp_seq_item.PWRITE              = vif_cfg.PWRITE;
                rsp_seq_item.PADDR               = vif_cfg.PADDR;
                rsp_seq_item.PWDATA              = vif_cfg.PWDATA;
                rsp_seq_item.tx_pop              = vif_cfg.tx_pop;
                rsp_seq_item.rx_push_valid       = vif_cfg.rx_push_valid;
                rsp_seq_item.rx_push_data        = vif_cfg.rx_push_data;
                rsp_seq_item.busy_in             = vif_cfg.busy_in;
                rsp_seq_item.transfer_done_pulse = vif_cfg.transfer_done_pulse;
                
                rsp_seq_item.PREADY         = vif_cfg.PREADY;
                rsp_seq_item.PSLVERR        = vif_cfg.PSLVERR;
                rsp_seq_item.cfg_en         = vif_cfg.cfg_en;
                rsp_seq_item.cfg_mstr       = vif_cfg.cfg_mstr;
                rsp_seq_item.cfg_lsb_first  = vif_cfg.cfg_lsb_first;
                rsp_seq_item.cfg_loopback   = vif_cfg.cfg_loopback;
                rsp_seq_item.tx_empty       = vif_cfg.tx_empty;
                rsp_seq_item.IRQ            = vif_cfg.IRQ;
                rsp_seq_item.cfg_mode       = vif_cfg.cfg_mode;
                rsp_seq_item.cfg_width      = vif_cfg.cfg_width;
                rsp_seq_item.SS_n           = vif_cfg.SS_n;
                rsp_seq_item.cfg_delay      = vif_cfg.cfg_delay;
                rsp_seq_item.cfg_clk_div    = vif_cfg.cfg_clk_div;
                rsp_seq_item.tx_word        = vif_cfg.tx_word;
                rsp_seq_item.PRDATA         = vif_cfg.PRDATA;
                
                rsp_seq_item.dut_PREADY     = vif_cfg.dut_PREADY;
                rsp_seq_item.dut_PSLVERR    = vif_cfg.dut_PSLVERR;
                rsp_seq_item.dut_cfg_en     = vif_cfg.dut_cfg_en;
                rsp_seq_item.dut_cfg_mstr   = vif_cfg.dut_cfg_mstr;
                rsp_seq_item.dut_cfg_lsb_first = vif_cfg.dut_cfg_lsb_first;
                rsp_seq_item.dut_cfg_loopback  = vif_cfg.dut_cfg_loopback;
                rsp_seq_item.dut_tx_empty    = vif_cfg.dut_tx_empty;
                rsp_seq_item.dut_IRQ         = vif_cfg.dut_IRQ;
                rsp_seq_item.dut_cfg_mode    = vif_cfg.dut_cfg_mode;
                rsp_seq_item.dut_cfg_width   = vif_cfg.dut_cfg_width;
                rsp_seq_item.dut_SS_n        = vif_cfg.dut_SS_n;
                rsp_seq_item.dut_cfg_delay   = vif_cfg.dut_cfg_delay;
                rsp_seq_item.dut_cfg_clk_div = vif_cfg.dut_cfg_clk_div;
                rsp_seq_item.dut_tx_word     = vif_cfg.dut_tx_word;
                rsp_seq_item.dut_PRDATA      = vif_cfg.dut_PRDATA;
                mon_ap.write(rsp_seq_item);
                `uvm_info("run_phase",rsp_seq_item.convert2string_stimulus(),UVM_HIGH)
            end
        endtask   
    endclass
endpackage