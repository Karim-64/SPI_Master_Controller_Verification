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
// output signals
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

// dut output signal

bit dut_PREADY;
bit dut_PSLVERR;
bit dut_cfg_en;
bit dut_cfg_mstr;
bit dut_cfg_lsb_first;
bit dut_cfg_loopback;
bit dut_tx_empty;
bit dut_IRQ;

logic [1:0]   dut_cfg_mode;
logic [1:0]   dut_cfg_width;
logic [3:0]   dut_SS_n;
logic [7:0]   dut_cfg_delay;
logic [15:0]  dut_cfg_clk_div;
logic [31:0]  dut_tx_word;
logic [31:0]  dut_PRDATA;



modport DUT (
    input  PCLK,PRESETn,PSEL,PENABLE,PWRITE,tx_pop,rx_push_valid,busy_in,transfer_done_pulse,PADDR,PWDATA,rx_push_data,  
    output dut_PREADY,dut_PSLVERR,dut_cfg_en,dut_cfg_mstr,dut_cfg_lsb_first,dut_cfg_loopback,dut_tx_empty,dut_IRQ,dut_cfg_mode,
           dut_cfg_width,dut_SS_n,dut_cfg_delay,dut_cfg_clk_div,dut_tx_word,dut_PRDATA
);

modport apb_golden_model (
    input  PCLK,PRESETn,PSEL,PENABLE,PWRITE,tx_pop,rx_push_valid,busy_in,transfer_done_pulse,PADDR,PWDATA,rx_push_data,  
    output PREADY,PSLVERR,cfg_en,cfg_mstr,cfg_lsb_first,cfg_loopback,tx_empty,IRQ,cfg_mode,
           cfg_width,SS_n,cfg_delay,cfg_clk_div,tx_word,PRDATA
);

endinterface