interface spi_core_if (PCLK);
// interface input
input bit PCLK ; 
// input signals
    logic         tx_empty;
    logic         MISO;
    logic         PRESETn;
    logic         cfg_en;
    logic         cfg_mstr;
    logic         cfg_lsb_first;
    logic         cfg_loopback;
    logic [1:0]   cfg_mode;
    logic [1:0]   cfg_width;
    logic [3:0]   ss_n_drive;
    logic [7:0]   cfg_delay;
    logic [15:0]  cfg_clk_div;
    logic [31:0]  tx_word;


// output signals
    logic          tx_pop;
    logic          rx_push_valid;
    logic          busy;
    logic          transfer_done_pulse;
    logic          SCLK;
    logic          MOSI;
    logic  [31:0]  rx_push_data;


// golden model output signal
    logic          tx_pop_expected;
    logic          rx_push_valid_expected;
    logic          busy_expected;
    logic          transfer_done_pulse_expected;
    logic          SCLK_expected;
    logic          MOSI_expected;
    logic  [31:0]  rx_push_data_expected;



    modport DUT (
        input  PCLK,
               PRESETn,
               tx_empty,
               MISO,
               cfg_en,
               cfg_mstr,
               cfg_lsb_first,
               cfg_loopback,
               cfg_mode,
               cfg_width,
               ss_n_drive,
               cfg_delay,
               cfg_clk_div,
               tx_word,

        output tx_pop,
               rx_push_valid,
               busy,
               transfer_done_pulse,
               SCLK,
               MOSI,
               rx_push_data
    );

modport spi_core_golden_model (
        input  PCLK,
               PRESETn,
               tx_empty,
               MISO,
               cfg_en,
               cfg_mstr,
               cfg_lsb_first,
               cfg_loopback,
               cfg_mode,
               cfg_width,
               ss_n_drive,
               cfg_delay,
               cfg_clk_div,
               tx_word,

        output tx_pop_expected,
               rx_push_valid_expected,
               busy_expected,
               transfer_done_pulse_expected,
               SCLK_expected,
               MOSI_expected,
               rx_push_data_expected
    );


endinterface