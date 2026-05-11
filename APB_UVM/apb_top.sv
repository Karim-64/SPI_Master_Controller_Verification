import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_test_pkg::*;
`timescale 1ns/1ps
module top ();
// PCLK generation
bit PCLK;
initial begin
    PCLK =0;
    forever begin
        #1 PCLK = ~ PCLK;
    end
end

// Instantiate interface and DUT
apb_if apbif(PCLK);
// DUT
apb_regfile_dut DUT (PCLK,apbif.PRESETn,apbif.PSEL,apbif.PENABLE,apbif.PWRITE,apbif.PADDR,apbif.PWDATA,
                apbif.PRDATA,apbif.PREADY,apbif.PSLVERR,apbif.cfg_en,apbif.cfg_mstr,apbif.cfg_mode,
                apbif.cfg_lsb_first,apbif.cfg_loopback,apbif.cfg_width,apbif.cfg_clk_div,apbif.cfg_delay,
                apbif.SS_n,apbif.tx_word,apbif.tx_empty,apbif.tx_pop,apbif.rx_push_valid,apbif.rx_push_data,
                apbif.busy_in,apbif.transfer_done_pulse,apbif.IRQ);

// GOLDEN MODEL
apb_regfile apb_golden_model (PCLK,apbif.PRESETn,apbif.PSEL,apbif.PENABLE,apbif.PWRITE,apbif.PADDR,apbif.PWDATA,
                        apbif.PRDATA_expected,apbif.PREADY_expected,apbif.PSLVERR_expected,apbif.cfg_en_expected,apbif.cfg_mstr_expected,apbif.cfg_mode_expected,
                        apbif.cfg_lsb_first_expected,apbif.cfg_loopback_expected,apbif.cfg_width_expected,apbif.cfg_clk_div_expected,apbif.cfg_delay_expected,
                        apbif.SS_n_expected,apbif.tx_word_expected,apbif.tx_empty_expected,apbif.tx_pop,apbif.rx_push_valid,apbif.rx_push_data,
                        apbif.busy_in,apbif.transfer_done_pulse,apbif.IRQ_expected);

// Bind assertion
bind apb_regfile_dut apb_SVA apb_sva_inst(apbif.DUTtt);
// run test using run_test task
initial begin
    uvm_config_db#(virtual apb_if)::set(null,"uvm_test_top","APB_IF",apbif);
    run_test("apb_access_test");
end

endmodule