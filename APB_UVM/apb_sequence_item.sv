package apb_sequence_item_pkg;
import uvm_pkg::*;
import apb_shared_pkg::*;
`include "uvm_macros.svh"
`define WRITE_ADDR_ins 3'b000
`define WRITE_DATA_ins 3'b001
`define READ_ADDR_ins  3'b110
`define READ_DATA_ins  3'b111

class apb_sequence_item extends uvm_sequence_item;
    `uvm_object_utils(apb_sequence_item)
    
    // randomized signals
    rand bit PRESETn;
    rand bit PSEL;
    rand bit PENABLE;
    rand bit PWRITE;
    rand bit tx_pop;              
    rand bit rx_push_valid;       
    rand bit busy_in;             
    rand bit transfer_done_pulse; 
    rand bit [7:0]   PADDR;
    rand bit [31:0]  PWDATA;
    rand bit [31:0]  rx_push_data;

    // non-randomized signals
    logic PREADY;
    logic PSLVERR;
    logic cfg_en;
    logic cfg_mstr;
    logic cfg_lsb_first;
    logic cfg_loopback;
    logic tx_empty;
    logic IRQ;
    logic [1:0]   cfg_mode;
    logic [1:0]   cfg_width;
    logic [3:0]   SS_n;
    logic [7:0]   cfg_delay;
    logic [15:0]  cfg_clk_div;
    logic [31:0]  tx_word;
    logic [31:0]  PRDATA;

    // expected signals from golden model
    logic PREADY_expected;
    logic PSLVERR_expected;
    logic cfg_en_expected;
    logic cfg_mstr_expected;
    logic cfg_lsb_first_expected;
    logic cfg_loopback_expected;
    logic tx_empty_expected;
    logic IRQ_expected;
    logic [1:0]   cfg_mode_expected;
    logic [1:0]   cfg_width_expected;
    logic [3:0]   SS_n_expected;
    logic [7:0]   cfg_delay_expected;
    logic [15:0]  cfg_clk_div_expected;
    logic [31:0]  tx_word_expected;
    logic [31:0]  PRDATA_expected;

     
    function new(string name = "apb_sequence_item");
        super.new(name);
    endfunction
    // save old values 
    logic oldPSEL = 1'b0;
    logic newPSEL;
    logic oldPENABLE = 1'b0;
    logic newPENABLE;
    logic oldPWRITE = 1'b0; 
    logic [7:0] oldPADDR  = 8'b0;
    logic [31:0] oldPWDATA = 32'b0;
    logic flag = 1;

    function void pre_randomize();
        if({PSEL,PENABLE} === 2'b11 || flag)
        begin
            {newPSEL,newPENABLE} = 2'b00;
            flag =0;
        end
        else if({PSEL,PENABLE} == 2'b10)
        begin
            {newPSEL,newPENABLE} = 2'b11;
        end
        else if({PSEL,PENABLE} == 2'b00)
        begin
            {newPSEL,newPENABLE} = 2'b10;
        end
    endfunction

    function void post_randomize();
        oldPSEL    = newPSEL;
        oldPENABLE = newPENABLE;
        oldPWRITE  = PWRITE;
        oldPADDR   = PADDR;
        oldPWDATA  = PWDATA;
    endfunction
     
    /*constraint blocks*/
    constraint main_c{
        PSEL == newPSEL;
        PENABLE == newPENABLE;
        PADDR[1:0] == 2'b0;     // make it 4 byte allgigned
        if(!PRESETn) busy_in == 1'b0;   // added 
    }

    constraint ctrl_c{
        PRESETn dist {1:/90 , 0:/10};
        PADDR == 8'h00;
        if({PSEL,PENABLE} == 2'b00)
        {
            PWRITE dist {1:/50 , 0:/50};    // PWRITE changes in idle state

            PWDATA[0] dist {1:/50 , 0:/50};
            PWDATA[1] == 1;
            PWDATA[3:2] dist {2'b00:/25 , 2'b01:/25 , 2'b10:/25 , 2'b11:/25};
            PWDATA[4] dist {1:/50 , 0:/50};
            PWDATA[5] dist {1:/25 , 0:/75};
            PWDATA[7:6] dist {2'b00:/30 , 2'b01:/35 , 2'b10:/35};
        }
        else if({PSEL,PENABLE} == 2'b10 || {PSEL,PENABLE} == 2'b11)
        {
            PWDATA == oldPWDATA;
            PADDR == oldPADDR;
            PWRITE == oldPWRITE;               // PWDATA stable at setup and access states
        }
    }

    constraint write_read_c{
        PRESETn dist {1:/90 , 0:/10};
        if({PSEL,PENABLE} == 2'b00)
        {
            PWRITE dist {1:/50 , 0:/50};
            PADDR dist {8'h08:/50 , 8'h0c:/50,[8'h24:$]:/5};
            PWDATA dist {
                32'h00000000 :/ 40,
                32'hFFFFFFFF :/ 40,
                32'h55555555 :/ 40,
                32'hAAAAAAAA :/ 40,
                [32'h00000001 : 32'hFFFFFFFE] :/ 20
            };
        }
        else if({PSEL,PENABLE} == 2'b10 || {PSEL,PENABLE} == 2'b11)
        {
            PWDATA == oldPWDATA;
            PADDR == oldPADDR;
            PWRITE == oldPWRITE;
        }

        rx_push_data dist {
            32'h00000000 :/ 40,
            32'hFFFFFFFF :/ 40,
            32'h55555555 :/ 40,
            32'hAAAAAAAA :/ 40,
            [32'h00000001 : 32'hFFFFFFFE] :/ 20
        };
    }

    constraint TX_FULL_OVF_c{
        PRESETn == 1;
        PADDR == 8'h08;
        PWRITE == 1;
        if({PSEL,PENABLE} == 2'b10 || {PSEL,PENABLE} == 2'b11)
        {
            PWDATA == oldPWDATA;
            PADDR == oldPADDR;
            PWRITE == oldPWRITE;
        }
    }
    constraint TX_empty{
        PRESETn == 1;
        PWDATA == oldPWDATA;
        PADDR == oldPADDR;
        PADDR != 8'h08;
        PWRITE == oldPWRITE;
        if({PSEL,PENABLE} == 2'b11)
        {
            tx_pop == 1;
        }
        else{
            tx_pop == 0;
        }
    }

    constraint RX_EMPTY_c{
        PRESETn == 1;
        PADDR == 8'h0C;
        PWRITE == 0;
        if({PSEL,PENABLE} == 2'b10 || {PSEL,PENABLE} == 2'b11)
        {
            PWDATA == oldPWDATA;
            PADDR == oldPADDR;
            PWRITE == oldPWRITE;
        }
    }

    constraint RX_FULL_c{
        PRESETn == 1;
        rx_push_data dist {
            32'h00000000 :/ 40,
            32'hFFFFFFFF :/ 40,
            32'h55555555 :/ 40,
            32'hAAAAAAAA :/ 40,
            [32'h00000001 : 32'hFFFFFFFE] :/ 20
        };
        if({PSEL,PENABLE} == 2'b11)
        {
            rx_push_valid == 1;
        }
        else{
            rx_push_valid == 0;
        }
        PWDATA == oldPWDATA;
        PADDR == oldPADDR;
        PADDR != 8'h08;
        PWRITE == oldPWRITE;
    }

    constraint status_read_c{
        PRESETn == 1;
        PADDR == 8'h04;
        PWRITE == 0;
        if(!PRESETn) busy_in == 1'b0;
        if({PSEL,PENABLE} == 2'b10 || {PSEL,PENABLE} == 2'b11)
        {
            PWDATA == oldPWDATA;
            PADDR == oldPADDR;
            PWRITE == oldPWRITE;
        }
    }

    constraint clk_div_c{
        PRESETn dist {1:/90 , 0:/10};

        PADDR == 8'h10;

        if({PSEL,PENABLE} == 2'b11 || ({PSEL,PENABLE} == 2'b10))
        {
            PWDATA == oldPWDATA;
            PADDR == oldPADDR;
            PWRITE == oldPWRITE;
        }
        else{
            PWDATA[15:0] dist {0:/25 , 1:/25 , 8:/25 , 16:/25};
            PWRITE dist {1:/90 , 0:/10};
        }
    }
   constraint ss_ctrl_c{
        PRESETn dist {1:/90 , 0:/10};
        PADDR == 8'h14;
        if(({PSEL,PENABLE} == 2'b11) || ({PSEL,PENABLE} == 2'b10))
        {   
            PWDATA == oldPWDATA;
            PADDR == oldPADDR;
            PWRITE == oldPWRITE;
        }
        else
        {   
            PWRITE dist {1:/90 , 0:/10};
            PWDATA[31:8] == 0;

            PWDATA[7:0] dist {

            // no slave enabled
            8'b0000_0000 :/ 10,

            // slave0 selected
            8'b0000_0001 :/ 15,

            // slave1 selected
            8'b0000_0010 :/ 15,

            // slave2 selected
            8'b0000_0100 :/ 15,

            // slave3 selected
            8'b0000_1000 :/ 15,

            // enabled but inactive
            8'b1111_1111 :/ 10,

            // multiple slaves active
            8'b0000_0011 :/ 5,
            8'b0000_0110 :/ 5,
            8'b0000_1100 :/ 5,

            // all slaves active
            8'b0000_1111 :/ 5
        };
        }
    }
     constraint int_EN_c {
        PRESETn dist {1:/90 , 0:/10};
        PADDR  == 8'h18;
       if(({PSEL,PENABLE} == 2'b11) || ({PSEL,PENABLE} == 2'b10))
        {   
            PWDATA == oldPWDATA;
            PADDR == oldPADDR;
            PWRITE == oldPWRITE;
        }
         else
        {   
            PWRITE dist {1:/90 , 0:/10};
         PWDATA dist {
            32'h00000000 :/ 10,   // enable TX_EMPTY interrupt
            32'h00000001 :/ 10,   // enable TX_EMPTY interrupt
           32'h00000002 :/ 10,   // enable RX_FULL interrupt
           32'h00000004 :/ 10,   // enable TX_OVF interrupt
           32'h00000008 :/ 10,   // enable RX_OVF interrupt
           32'h00000010 :/ 10  // enable TRANSFER_DONE interrupt
         };
        }
    }

   
    constraint clr_STAT_c {
        PRESETn dist {1:/90 , 0:/10};
        PADDR  == 8'h1C;
        if(({PSEL,PENABLE} == 2'b11) || ({PSEL,PENABLE} == 2'b10))
        {
            PWDATA == oldPWDATA;
            PADDR == oldPADDR;
            PWRITE == oldPWRITE;
        }
         else
        {   
            PWRITE dist {1:/90 , 0:/10};
       
         PWDATA dist {
            32'h00000001 :/ 10,   // clear TX_EMPTY interrupt
           32'h00000002 :/ 10,   // clear RX_FULL interrupt
           32'h00000004 :/ 10,   // clear TX_OVF interrupt
           32'h00000008 :/ 10,   // clear RX_OVF interrupt
           32'h00000010 :/ 10  // clear TRANSFER_DONE interrupt
         };
        }
    }

   
    constraint delay_c {

    PRESETn dist {1:/90 , 0:/10};

    PADDR  == 8'h20;
    PWRITE dist {1:/50 , 0:/50};
    if(({PSEL,PENABLE} == 2'b11) || ({PSEL,PENABLE} == 2'b10))
    {   
        PWDATA == oldPWDATA;
        PADDR == oldPADDR;
        PWRITE == oldPWRITE;
    }
    else{
        PWDATA[31:8] == 0;

    PWDATA[7:0] dist {
            8'd0   :/ 20,  
            8'd1   :/ 20,   
            8'd2   :/ 10,
            8'd4   :/ 10,
            8'd8   :/ 10,
            8'd16  :/ 10,
            8'd32  :/ 10,
            8'd255 :/ 10   
        };
    }

    
}

    function string convert2string();
        return $sformatf("PRESETn=%0d PSEL=%0d PENABLE=%0d PWRITE=%0d tx_pop=%0d rx_push_valid=%0d busy_in=%0d transfer_done_pulse=%0d, PADDR=%0d PWDATA=%0d rx_push_data=%0d PREADY=%0d PSLVERR=%0d cfg_en=%0d cfg_mstr=%0d cfg_lsb_first=%0d cfg_loopback=%0d, tx_empty=%0d IRQ=%0d cfg_mode=%0b cfg_width=%0b SS_n=%0b cfg_delay=%0d cfg_clk_div=%0d tx_word=%0d PRDATA=%0d",
                          PRESETn, PSEL, PENABLE, PWRITE, tx_pop, rx_push_valid, busy_in, transfer_done_pulse,
                          PADDR, PWDATA, rx_push_data, PREADY, PSLVERR, cfg_en, cfg_mstr, cfg_lsb_first, cfg_loopback,
                          tx_empty, IRQ, cfg_mode, cfg_width, SS_n, cfg_delay, cfg_clk_div, tx_word, PRDATA);
    endfunction

    function string convert2string_stimulus();
        return $sformatf("PRESETn=%0d PSEL=%0d PENABLE=%0d PWRITE=%0d tx_pop=%0d rx_push_valid=%0d busy_in=%0d transfer_done_pulse=%0d, PADDR=%0d PWDATA=%0d rx_push_data=%0d",
                          PRESETn, PSEL, PENABLE, PWRITE, tx_pop, rx_push_valid, busy_in, transfer_done_pulse,
                          PADDR, PWDATA, rx_push_data);
    endfunction        
endclass
endpackage