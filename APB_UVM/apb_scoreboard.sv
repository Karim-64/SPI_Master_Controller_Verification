package apb_scoreboard_pkg;
    import uvm_pkg::*;
    import apb_shared_pkg::*;
    import apb_sequence_item_pkg::*;
    `include "uvm_macros.svh"
    
    class apb_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(apb_scoreboard)
        
        uvm_analysis_export #(apb_sequence_item) sb_export;
        uvm_tlm_analysis_fifo #(apb_sequence_item) sb_fifo;
        apb_sequence_item sb_seq_item;
        
        int error_count , correct_count ;
        
        function new (string name = "apb_scoreboard" , uvm_component parent = null);
            super.new(name,parent);
        endfunction

        function void build_phase (uvm_phase phase);
            super.build_phase(phase);
            sb_export = new("sb_export",this);
            sb_fifo = new("sb_fifo",this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            sb_export.connect(sb_fifo.analysis_export);
        endfunction

        task run_phase (uvm_phase phase);
            super.run_phase(phase);
            forever begin  
                sb_fifo.get(sb_seq_item);
                /*check outputs*/
                if(sb_seq_item.dut_PREADY !== sb_seq_item.PREADY) begin
                    `uvm_error("run_phase", $sformatf("[SCOREBOARD_ERROR] PREADY - mismatch in predicted=%d vs observed=%d", sb_seq_item.PREADY, sb_seq_item.dut_PREADY));
                    error_count++;
                end
                if(sb_seq_item.dut_PSLVERR !== sb_seq_item.PSLVERR) begin
                    `uvm_error("run_phase", $sformatf("[SCOREBOARD_ERROR] PSLVERR - mismatch in predicted=%d vs observed=%d", sb_seq_item.PSLVERR, sb_seq_item.dut_PSLVERR));
                    error_count++;
                end
                if(sb_seq_item.dut_cfg_en !== sb_seq_item.cfg_en) begin
                    `uvm_error("run_phase", $sformatf("[SCOREBOARD_ERROR] cfg_en - mismatch in predicted=%d vs observed=%d", sb_seq_item.cfg_en, sb_seq_item.dut_cfg_en));
                    error_count++;
                end
                if(sb_seq_item.dut_cfg_mstr !== sb_seq_item.cfg_mstr) begin
                    `uvm_error("run_phase", $sformatf("[SCOREBOARD_ERROR] cfg_mstr - mismatch in predicted=%d vs observed=%d", sb_seq_item.cfg_mstr, sb_seq_item.dut_cfg_mstr));
                    error_count++;
                end
                if(sb_seq_item.dut_cfg_lsb_first !== sb_seq_item.cfg_lsb_first) begin
                    `uvm_error("run_phase", $sformatf("[SCOREBOARD_ERROR] cfg_lsb_first - mismatch in predicted=%d vs observed=%d", sb_seq_item.cfg_lsb_first, sb_seq_item.dut_cfg_lsb_first));
                    error_count++;
                end
                if(sb_seq_item.dut_cfg_loopback !== sb_seq_item.cfg_loopback) begin
                    `uvm_error("run_phase", $sformatf("[SCOREBOARD_ERROR] cfg_loopback - mismatch in predicted=%d vs observed=%d", sb_seq_item.cfg_loopback, sb_seq_item.dut_cfg_loopback));
                    error_count++;
                end
                if(sb_seq_item.dut_tx_empty !== sb_seq_item.tx_empty) begin
                    `uvm_error("run_phase", $sformatf("[SCOREBOARD_ERROR] tx_empty - mismatch in predicted=%d vs observed=%d", sb_seq_item.tx_empty, sb_seq_item.dut_tx_empty));
                    error_count++;
                end
                if(sb_seq_item.dut_IRQ !== sb_seq_item.IRQ) begin
                    `uvm_error("run_phase", $sformatf("[SCOREBOARD_ERROR] IRQ - mismatch in predicted=%d vs observed=%d", sb_seq_item.IRQ, sb_seq_item.dut_IRQ));
                    error_count++;
                end
                if(sb_seq_item.dut_cfg_mode !== sb_seq_item.cfg_mode) begin
                    `uvm_error("run_phase", $sformatf("[SCOREBOARD_ERROR] cfg_mode - mismatch in predictede=%d vs observede=%d", sb_seq_item.cfg_mode, sb_seq_item.dut_cfg_mode));
                    error_count++;
                end
                if(sb_seq_item.dut_cfg_width !== sb_seq_item.cfg_width) begin
                    `uvm_error("run_phase", $sformatf("[SCOREBOARD_ERROR] cfg_width - mismatch in predicted_cfg=%d vs observed=%d", sb_seq_item.cfg_width, sb_seq_item.dut_cfg_width));
                    error_count++;
                end
                if(sb_seq_item.dut_SS_n !== sb_seq_item.SS_n) begin
                    `uvm_error("run_phase", $sformatf("[SCOREBOARD_ERROR] SS_n - mismatch in predicted=%d vs observed=%d", sb_seq_item.SS_n, sb_seq_item.dut_SS_n));
                    error_count++;
                end
                if(sb_seq_item.dut_cfg_delay !== sb_seq_item.cfg_delay) begin
                    `uvm_error("run_phase", $sformatf("[SCOREBOARD_ERROR] cfg_delay - mismatch in predicted=%d vs observed=%d", sb_seq_item.cfg_delay, sb_seq_item.dut_cfg_delay));
                    error_count++;
                end
                if(sb_seq_item.dut_cfg_clk_div !== sb_seq_item.cfg_clk_div) begin
                    `uvm_error("run_phase", $sformatf("[SCOREBOARD_ERROR] cfg_clk_div - mismatch in predicted=%d vs observed=%d", sb_seq_item.cfg_clk_div, sb_seq_item.dut_cfg_clk_div));
                    error_count++;
                end
                if(sb_seq_item.dut_tx_word !== sb_seq_item.tx_word) begin
                    `uvm_error("run_phase", $sformatf("[SCOREBOARD_ERROR] tx_word - mismatch in predicted=%d vs observed=%d", sb_seq_item.tx_word, sb_seq_item.dut_tx_word));
                    error_count++;
                end
                if(sb_seq_item.dut_PRDATA !== sb_seq_item.PRDATA) begin
                    `uvm_error("run_phase", $sformatf("[SCOREBOARD_ERROR] PRDATA - mismatch in predicted=%d vs observed=%d", sb_seq_item.PRDATA, sb_seq_item.dut_PRDATA));
                    error_count++;
                end
                if (error_count == 0) begin
                    `uvm_info("run_phase", $sformatf("correct output :%s", sb_seq_item.convert2string()), UVM_HIGH);
                    correct_count++;
                end

            end
        endtask

        function void report_phase (uvm_phase phase);
            super.report_phase(phase);
            `uvm_info ("report_phase",$sformatf("Correct_count = %d , Error_count = %d",correct_count,error_count),UVM_MEDIUM);
        endfunction
    endclass
    
endpackage