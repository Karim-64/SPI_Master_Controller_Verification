import uvm_pkg::*;
`include "uvm_macros.svh"
import spi_core_test_pkg::*;
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
spi_core_if spicoreif(PCLK);
// DUT
spi_core_dut DUT (
    PCLK,
    spicoreif.PRESETn,
    spicoreif.cfg_en,
    spicoreif.cfg_mstr,
    spicoreif.cfg_mode,
    spicoreif.cfg_lsb_first,
    spicoreif.cfg_loopback,
    spicoreif.cfg_width,
    spicoreif.cfg_clk_div,
    spicoreif.cfg_delay,
    spicoreif.ss_n_drive,
    spicoreif.tx_word,
    spicoreif.tx_empty,
    spicoreif.tx_pop,
    spicoreif.rx_push_valid,
    spicoreif.rx_push_data,
    spicoreif.busy,
    spicoreif.transfer_done_pulse,
    spicoreif.SCLK,
    spicoreif.MOSI,
    spicoreif.MISO
);


// GOLDEN MODEL
spi_core spi_core_golden_model (
    PCLK,
    spicoreif.PRESETn,
    spicoreif.cfg_en,
    spicoreif.cfg_mstr,
    spicoreif.cfg_mode,
    spicoreif.cfg_lsb_first,
    spicoreif.cfg_loopback,
    spicoreif.cfg_width,
    spicoreif.cfg_clk_div,
    spicoreif.cfg_delay,
    spicoreif.ss_n_drive,
    spicoreif.tx_word,
    spicoreif.tx_empty,
    spicoreif.tx_pop_expected,
    spicoreif.rx_push_valid_expected,
    spicoreif.rx_push_data_expected,
    spicoreif.busy_expected,
    spicoreif.transfer_done_pulse_expected,
    spicoreif.SCLK_expected,
    spicoreif.MOSI_expected,
    spicoreif.MISO
);

// Bind assertion

// run test using run_test task
initial begin
    uvm_config_db#(virtual spi_core_if)::set(null,"uvm_test_top","spi_core_IF",spicoreif);
    run_test("spi_core_test");
end

endmodule