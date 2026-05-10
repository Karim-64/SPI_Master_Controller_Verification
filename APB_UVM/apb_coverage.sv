package apb_coverage_pkg;
    import uvm_pkg::*;
    import apb_shared_pkg::*;
    import apb_sequence_item_pkg::*;
    `include "uvm_macros.svh"
    class apb_coverage extends uvm_component;
        `uvm_component_utils(apb_coverage)
        uvm_analysis_export #(apb_sequence_item) cov_export;
        uvm_tlm_analysis_fifo #(apb_sequence_item) cov_fifo;
        apb_sequence_item seq_item_cov;
        
        /*covergroups*/
        covergroup apb_protocol_cg;
            option.per_instance = 1;

            c_PRESETn: coverpoint seq_item_cov.PRESETn {
                bins reset_active   = {0};
                bins reset_inactive = {1};
                bins reset_asserted = (1 => 0);
                bins reset_released = (0 => 1);
            }

            c_PSEL: coverpoint seq_item_cov.PSEL;
            c_PENABLE: coverpoint seq_item_cov.PENABLE;

            c_protocol_phases: coverpoint ({seq_item_cov.PSEL, seq_item_cov.PENABLE}) {
                bins idle   = {2'b00};
                bins setup  = {2'b10};
                bins access = {2'b11};
                
                bins idle_to_setup   = (2'b00 => 2'b10);
                bins setup_to_access = (2'b10 => 2'b11);
                bins access_to_idle  = (2'b11 => 2'b00);
                ignore_bins access_to_setup = (2'b11 => 2'b10);
            }

            c_PREADY: coverpoint seq_item_cov.PREADY {
                bins ready = {1};
            }

            c_PSLVERR: coverpoint seq_item_cov.PSLVERR {
                bins no_error = {0};
            }

            C_cfg_en: coverpoint seq_item_cov.cfg_en {
                bins disabled = {0};
                bins enabled  = {1};
            }

            c_cfg_mode: coverpoint seq_item_cov.cfg_mode {
                bins mode_0 = {2'b00};
                bins mode_1 = {2'b01};
                bins mode_2 = {2'b10};
                bins mode_3 = {2'b11};
            }

            c_cfg_lsb_first: coverpoint seq_item_cov.cfg_lsb_first {
                bins msb_first = {0};
                bins lsb_first = {1};
            }

            c_cfg_loopback: coverpoint seq_item_cov.cfg_loopback {
                bins normal_operation = {0};
                bins loopback_mode   = {1};
            }

            c_cfg_width: coverpoint seq_item_cov.cfg_width {
                bins width_8  = {0};
                bins width_16 = {1};
                bins width_32 = {2};
            }

            c_tx_pop : coverpoint seq_item_cov.tx_pop {
                bins no_pop = {0};
                bins pop    = {1};
            }

            c_rx_push_valid: coverpoint seq_item_cov.rx_push_valid {
                bins no_push = {0};
                bins push    = {1};
            }

            // c_cfg_clk_div: coverpoint seq_item_cov.cfg_clk_div {
            //     // Zeyad
            // }

            // c_cfg_delay: coverpoint seq_item_cov.cfg_delay {
            //     // Zeyad
            // }

            c_tx_word: coverpoint seq_item_cov.tx_word {
                bins all_zeros   = {32'h00000000};
                bins all_ones    = {32'hFFFFFFFF};
                bins toggle_01   = {32'h55555555};
                bins toggle_10   = {32'hAAAAAAAA};
                bins others_data = default;
            }

            c_IRQ : coverpoint seq_item_cov.IRQ {
                bins no_interrupt = {0};
                bins interrupt    = {1};
            }

            c_tx_empty: coverpoint seq_item_cov.tx_empty {
                bins not_empty = {0};
                bins empty     = {1};
            }
        endgroup

        covergroup apb_transaction_cg;
            option.per_instance = 1;

            c_PADDR: coverpoint seq_item_cov.PADDR {
                bins OFF_CTRL     = {8'h00};
                bins OFF_STATUS   = {8'h04};
                bins OFF_TX_DATA  = {8'h08};
                bins OFF_RX_DATA  = {8'h0C};
                bins OFF_CLK_DIV  = {8'h10};
                bins OFF_SS_CTRL  = {8'h14};
                bins OFF_INT_EN   = {8'h18};
                bins OFF_INT_STAT = {8'h1C};
                bins OFF_DELAY    = {8'h20};
                bins others_addr  = default;

                bins cnfg_to_write = {8'h00 >= 8'h08};
                bins cnfg_to_read  = {8'h00 >= 8'h0C};
            }

            c_PWRITE: coverpoint seq_item_cov.PWRITE {
                bins read_op  = {0};
                bins write_op = {1};
            }

            c_PWDATA: coverpoint seq_item_cov.PWDATA {
                bins all_zeros   = {32'h00000000};
                bins all_ones    = {32'hFFFFFFFF};
                bins toggle_01   = {32'h55555555};
                bins toggle_10   = {32'hAAAAAAAA};
                bins others_data = default;
            }

            c_PRDATA: coverpoint seq_item_cov.PRDATA {
                bins all_zeros   = {32'h00000000};
                bins all_ones    = {32'hFFFFFFFF};
                bins others_data = default;
            }

        endgroup

        function new(string name = "apb_coverage",uvm_component parent = null);
            super.new(name , parent);
            // create covergroup
            apb_protocol_cg = new();
            apb_transaction_cg = new();
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase (phase);
            cov_export = new("cov_export",this);
            cov_fifo = new("cov_fifo",this);
        endfunction

        function void  connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            cov_export.connect(cov_fifo.analysis_export);
        endfunction

        task run_phase (uvm_phase phase);
            super.run_phase (phase);
            forever begin
                cov_fifo.get(seq_item_cov);
                
                apb_protocol_cg.sample();
                
                if (seq_item_cov.PRESETn && seq_item_cov.PSEL && seq_item_cov.PENABLE) begin
                    apb_transaction_cg.sample();
                end
            end
        endtask
    endclass 
endpackage