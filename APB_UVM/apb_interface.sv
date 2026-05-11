interface apb_if (PCLK);
// interface input
input bit PCLK ; 
// input signals
bit PRESETn;
bit PSEL;
bit PENABLE;
bit PWRITE;
bit tx_pop;
bit rx_push_valid;
bit busy_in;
bit transfer_done_pulse;

logic [7:0]   PADDR;
logic [31:0]  PWDATA;
logic [31:0]  rx_push_data;
// dut output signal

bit PREADY;
bit PSLVERR;
bit cfg_en;
bit cfg_mstr;
bit cfg_lsb_first;
bit cfg_loopback;
bit tx_empty;
bit IRQ;

logic [1:0]   cfg_mode;
logic [1:0]   cfg_width;
logic [3:0]   SS_n;
logic [7:0]   cfg_delay;
logic [15:0]  cfg_clk_div;
logic [31:0]  tx_word;
logic [31:0]  PRDATA;

// output signals (golden model)

bit PREADY_expected;
bit PSLVERR_expected;
bit cfg_en_expected;
bit cfg_mstr_expected;
bit cfg_lsb_first_expected;
bit cfg_loopback_expected;
bit tx_empty_expected;
bit IRQ_expected;

logic [1:0]   cfg_mode_expected;
logic [1:0]   cfg_width_expected;
logic [3:0]   SS_n_expected;
logic [7:0]   cfg_delay_expected;
logic [15:0]  cfg_clk_div_expected;
logic [31:0]  tx_word_expected;
logic [31:0]  PRDATA_expected;



modport DUTtt (
    input  PCLK,PRESETn,PSEL,PENABLE,PWRITE,tx_pop,rx_push_valid,busy_in,transfer_done_pulse,PADDR,PWDATA,rx_push_data,  
    output PREADY,PSLVERR,cfg_en,cfg_mstr,cfg_lsb_first,cfg_loopback,tx_empty,IRQ,cfg_mode,
           cfg_width,SS_n,cfg_delay,cfg_clk_div,tx_word,PRDATA
);

modport apb_golden_model (
    input  PCLK,PRESETn,PSEL,PENABLE,PWRITE,tx_pop,rx_push_valid,busy_in,transfer_done_pulse,PADDR,PWDATA,rx_push_data,  
    output PREADY_expected,PSLVERR_expected,cfg_en_expected,cfg_mstr_expected,cfg_lsb_first_expected,cfg_loopback_expected,tx_empty_expected,IRQ_expected,cfg_mode_expected,
           cfg_width_expected,SS_n_expected,cfg_delay_expected,cfg_clk_div_expected,tx_word_expected,PRDATA_expected
);

endinterface