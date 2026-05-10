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
apb_regfile DUT (PCLK,apbif.PRESETn,apbif.PSEL,apbif.PENABLE,apbif.PWRITE,apbif.PADDR,apbif.PWDATA,
                apbif.dut_PRDATA,apbif.dut_PREADY,apbif.dut_PSLVERR,apbif.dut_cfg_en,apbif.dut_cfg_mstr,apbif.dut_cfg_mode,
                apbif.dut_cfg_lsb_first,apbif.dut_cfg_loopback,apbif.dut_cfg_width,apbif.dut_cfg_clk_div,apbif.dut_cfg_delay,
                apbif.dut_SS_n,apbif.dut_tx_word,apbif.dut_tx_empty,apbif.tx_pop,apbif.rx_push_valid,apbif.rx_push_data,
                apbif.busy_in,apbif.transfer_done_pulse,apbif.dut_IRQ);

// GOLDEN MODEL
apb_regfile_gm apb_golden_model (PCLK,apbif.PRESETn,apbif.PSEL,apbif.PENABLE,apbif.PWRITE,apbif.PADDR,apbif.PWDATA,
                        apbif.PRDATA,apbif.PREADY,apbif.PSLVERR,apbif.cfg_en,apbif.cfg_mstr,apbif.cfg_mode,
                        apbif.cfg_lsb_first,apbif.cfg_loopback,apbif.cfg_width,apbif.cfg_clk_div,apbif.cfg_delay,
                        apbif.SS_n,apbif.tx_word,apbif.tx_empty,apbif.tx_pop,apbif.rx_push_valid,apbif.rx_push_data,
                        apbif.busy_in,apbif.transfer_done_pulse,apbif.IRQ);

// Bind assertion
bind apb_regfile apb_SVA apb_sva_inst(apbif.DUT);
// run test using run_test task
initial begin
    uvm_config_db#(virtual apb_if)::set(null,"uvm_test_top","APB_IF",apbif);
    run_test("apb_access_test");
end

endmodule