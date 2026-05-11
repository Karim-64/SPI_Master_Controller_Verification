module apb_SVA (apb_if.DUTtt apbif);
// R2
// test reset values of all registers   
always_comb begin
    if(~apbif.PRESETn)begin
       ctrl_en_rst:         assert final(apbif.cfg_en        == 1'b0);
       cfg_mstr_rst:        assert final(apbif.cfg_mstr      == 1'b0);
       cfg_mode_rst:        assert final(apbif.cfg_mode      == 2'b0);
       cfg_lsb_first_rst:   assert final(apbif.cfg_lsb_first == 1'b0);
       cfg_loopback_rst:    assert final(apbif.cfg_loopback  == 1'b0);
       cfg_width_rst:       assert final(apbif.cfg_width     == 2'b0);
       cfg_delay_rst:       assert final(apbif.cfg_delay     == 8'b0);
       SS_n_rst:            assert final(apbif.SS_n          == 4'b1111);
       cfg_clk_div_rst:     assert final(apbif.cfg_clk_div   == 16'b0);
       tx_word_RST:         assert final(apbif.tx_word       == 32'b0);
        tx_empty_rst:       assert final(apbif.tx_empty      == 1'b1);
        IRQ_rst:            assert final(apbif.IRQ           == 1'b0);    
        PRDATA_rst:          assert final(apbif.PRDATA       == 32'b0);

        //Control Register Reset test
        control_reg_rst:        assert final(DUT.ctrl_word      == 32'h0);  
        //Status Register Reset test
        status_reg_rst:         assert final(DUT.status_word    == 32'h0000_0014);
        // Clock Divider Register Reset test
        Clock_Divider_rst:      assert final(DUT.clk_div_word   == 32'h0);
        // Slave Select Control Register Reset test
        Slave_Select_Control:   assert final(DUT.ss_ctrl_word   == 32'h0);
        // INT_STAT Register Reset test
        int_stat_rst:           assert final(DUT.int_stat_word  == 32'h0);
        // DELAY Register Reset test
        DELAY_rst:              assert final(DUT.delay_word     == 32'h0);
        // INT_EN Register Reset test
        INT_EN_rst:             assert final(DUT.int_en_word    == 32'h0);
        // TX_DATA Register Reset test
        tx_rp_rst:              assert final(DUT.tx_rp == 0);
        tx_wp_rst:              assert final(DUT.tx_wp == 0);

        TX_DATA_rst:            assert final((DUT.tx_mem[0] == 0 &&
                                        DUT.tx_mem[1] == 0 &&
                                        DUT.tx_mem[2] == 0 &&
                                        DUT.tx_mem[3] == 0 &&
                                        DUT.tx_mem[4] == 0 &&
                                        DUT.tx_mem[5] == 0 &&
                                        DUT.tx_mem[6] == 0 &&
                                        DUT.tx_mem[7] == 0));
        // RX_DATA Register Reset test
        rx_wp_rst:              assert final(DUT.rx_wp == 0);
        rx_rp_rst:              assert final(DUT.rx_rp == 0);

        RX_DATA_rst:            assert final((DUT.rx_mem[0] == 0 &&
                                        DUT.rx_mem[1] == 0 &&
                                        DUT.rx_mem[2] == 0 &&
                                        DUT.rx_mem[3] == 0 &&
                                        DUT.rx_mem[4] == 0 &&
                                        DUT.rx_mem[5] == 0 &&
                                        DUT.rx_mem[6] == 0 &&
                                        DUT.rx_mem[7] == 0));
    end
end

// test setup phase (psel should be asserted for one cycle and penable should be low)
property setup_phase;
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) $rose(apbif.PSEL) |-> (apbif.PENABLE == 0);
endproperty
setup_phase_as: assert property(setup_phase)
else $error("[ASSERTION_ERROR] setup_phase test fail");
cover property(setup_phase);

// test access phase (after setup phase, psel and penale should be high at the next cycle)
property access_phase;
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) ($rose(apbif.PSEL) && ~apbif.PENABLE) |=> (apbif.PSEL && apbif.PENABLE);
endproperty
access_phase_as: assert property(access_phase)
else $error("[ASSERTION_ERROR] access_phase test fail");
cover property(access_phase);

// test penable in idle case should be zero while psel = zero
property penable_idle_case;
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) (~apbif.PSEL) |-> (~apbif.PENABLE);
endproperty
penable_idle_case_as: assert property(penable_idle_case)
else $error("[ASSERTION_ERROR] penable_idle_case test fail");
cover property(penable_idle_case);

// test PWRITE is stable during setup and access phases  
property PWRITE_stable_S_A;
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) (apbif.PSEL && ~apbif.PENABLE) |=> $stable(apbif.PWRITE);
endproperty
PWRITE_stable_S_A_as: assert property(PWRITE_stable_S_A)
else $error("[ASSERTION_ERROR] PWRITE_stable_S_A test fail");
cover property(PWRITE_stable_S_A);

// test PWDATA is stable during setup and access phases 
property PWDATA_stable_S_A;
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) (apbif.PSEL && ~apbif.PENABLE) |=> $stable(apbif.PWDATA);
endproperty
PWDATA_stable_S_A_as: assert property(PWDATA_stable_S_A)
else $error("[ASSERTION_ERROR] PWDATA_stable_S_A test fail");
cover property(PWDATA_stable_S_A);

// test PADDR is stable during setup and access phases 
property PADDR_stable_S_A;
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) (apbif.PSEL && ~apbif.PENABLE) |=> $stable(apbif.PADDR) ;
endproperty
PADDR_stable_S_A_as: assert property(PADDR_stable_S_A)
else $error("[ASSERTION_ERROR] PADDR_stable_S_A test fail");
cover property(PADDR_stable_S_A);

// ========================== R1==========================================
// check that control register updated correctly after each write operation
property CTRL_write_updates;
    @(posedge apbif.PCLK)
    disable iff(~apbif.PRESETn)

    (apbif.PSEL && apbif.PENABLE &&
     apbif.PWRITE &&
     apbif.PADDR == 8'h00)

    |=> (
        apbif.cfg_width     == $past(apbif.PWDATA[7:6]) &&
        apbif.cfg_loopback  == $past(apbif.PWDATA[5])   &&
        apbif.cfg_lsb_first == $past(apbif.PWDATA[4])   &&
        apbif.cfg_mode      == $past(apbif.PWDATA[3:2]) &&
        apbif.cfg_mstr      == $past(apbif.PWDATA[1])   &&
        apbif.cfg_en        == $past(apbif.PWDATA[0])
    );
endproperty
CTRL_write_updates_as: assert  property(CTRL_write_updates)
else $error("[ASSERTION_ERROR] CTRL_write_updates test fail");
cover property(CTRL_write_updates);

// check that PRDATA is correct after reading from control regisetr 
property CTRL_read_correct;
    @(posedge apbif.PCLK)
    disable iff(~apbif.PRESETn)

    (apbif.PSEL &&
     apbif.PENABLE &&
     !apbif.PWRITE &&
     apbif.PADDR == 8'h00)

    |-> (
        apbif.PRDATA[7:6] == apbif.cfg_width     &&
        apbif.PRDATA[5]   == apbif.cfg_loopback  &&
        apbif.PRDATA[4]   == apbif.cfg_lsb_first &&
        apbif.PRDATA[3:2] == apbif.cfg_mode      &&
        apbif.PRDATA[1]   == apbif.cfg_mstr      &&
        apbif.PRDATA[0]   == apbif.cfg_en
    );
endproperty
CTRL_read_correct_as: assert  property(CTRL_read_correct)
else $error("[ASSERTION_ERROR] CTRL_read_correct test fail");
cover property(CTRL_read_correct);

// check that PRDATA is correct after reading from Status regisetr (Read Only register)
property status_read_correct;
    @(posedge apbif.PCLK)
    disable iff(~apbif.PRESETn)

    (apbif.PSEL &&
     apbif.PENABLE &&
     !apbif.PWRITE &&
     apbif.PADDR == 8'h04)

    |-> (apbif.PRDATA[31:0] == DUT.status_word[31:0]);
endproperty
status_read_correct_as: assert  property(status_read_correct)
else $error("[ASSERTION_ERROR] status_read_correct test fail");
cover property(status_read_correct);

// check that clk divider register updated correctly after each write operation
property CLKDIV_write;
    @(posedge apbif.PCLK)
    disable iff(~apbif.PRESETn)

    (apbif.PSEL && apbif.PENABLE &&
     apbif.PWRITE &&
     apbif.PADDR == 8'h10)

    |=> (apbif.cfg_clk_div == $past(apbif.PWDATA[15:0]));
endproperty
CLKDIV_write_as: assert  property(CLKDIV_write)
else $error("[ASSERTION_ERROR] CLKDIV_write test fail");
cover property(CLKDIV_write);

// check that PRDATA is correct after reading from clk divider register
property CLKDIV_read_correct;
    @(posedge apbif.PCLK)
    disable iff(~apbif.PRESETn)

    (apbif.PSEL &&
     apbif.PENABLE &&
     !apbif.PWRITE &&
     apbif.PADDR == 8'h10)

    |-> (
        apbif.PRDATA[15:0] == apbif.cfg_clk_div
    );
endproperty
CLKDIV_read_correct_as: assert  property(CLKDIV_read_correct)
else $error("[ASSERTION_ERROR] CLKDIV_read_correct test fail");
cover property(CLKDIV_read_correct);

// check that Delay register updated correctly after each write operation
property DELAY_write;
    @(posedge apbif.PCLK)
    disable iff(~apbif.PRESETn)

    (apbif.PSEL && apbif.PENABLE &&
     apbif.PWRITE &&
     apbif.PADDR == 8'h20)

    |=> (apbif.cfg_delay == $past(apbif.PWDATA[7:0]));
endproperty
DELAY_write_as: assert  property(DELAY_write)
else $error("[ASSERTION_ERROR] DELAY_write test fail");
cover property(DELAY_write);

// check that PRDATA is correct after reading from the Delay register
property DELAY_read_correct;
    @(posedge apbif.PCLK)
    disable iff(~apbif.PRESETn)

    (apbif.PSEL &&
     apbif.PENABLE &&
     !apbif.PWRITE &&
     apbif.PADDR == 8'h20)

    |-> (
        apbif.PRDATA[7:0] == apbif.cfg_delay
    );
endproperty
DELAY_read_correct_as: assert  property(DELAY_read_correct)
else $error("[ASSERTION_ERROR] DELAY_read_correct test fail");
cover property(DELAY_read_correct);

// =============================R3=============================
property TX_no_push_when_disabled;
    @(posedge apbif.PCLK)
    disable iff(~apbif.PRESETn)

    (apbif.PSEL &&
     apbif.PENABLE &&
     apbif.PWRITE &&
     apbif.PADDR == 8'h08 &&
     !apbif.cfg_en)

    |=> (
        $stable(apbif.tx_empty) &&
        $stable(apbif.tx_word)
    );
endproperty

TX_no_push_when_disabled_as: assert property(TX_no_push_when_disabled)
else $error("[ASSERTION_ERROR] TX_no_push_when_disabled test fail");
cover property(TX_no_push_when_disabled);

//=====================================R10=====================================
// correct pop from fifo
property pop_correct;   
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) (apbif.PSEL && apbif.PENABLE && ~apbif.PWRITE 
    && apbif.PADDR == 8'h0C && ~DUT.rx_empty_w) 
    |=> (DUT.rx_rp == $past(DUT.rx_rp) + 1);
endproperty
pop_correct_as: assert  property(pop_correct)
else $error("[ASSERTION_ERROR] pop_correct test fail");
cover property(pop_correct);


// ==========================R11==========================
// test tx_empty is fired when tx fifo is empty
property tx_empty_high;   
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) (DUT.tx_count == 0) |-> (apbif.tx_empty == 1);
endproperty
tx_empty_high_as: assert  property(tx_empty_high)
else $error("[ASSERTION_ERROR] tx_empty_high test fail");
cover property(tx_empty_high);

// test full is fired when tx fifo is full
property tx_full_high;   
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) (DUT.tx_count == DUT.FIFO_DEPTH) |-> (DUT.tx_full_w == 1'b1);
endproperty
tx_full_high_as: assert  property(tx_full_high)
else $error("[ASSERTION_ERROR] tx_full_high test fail");
cover property(tx_full_high);

// =====================R12=====================
// test rx empty is fired when rx fifo is empty
property rx_empty_high;   
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) (DUT.rx_count == 1'b0) |-> (DUT.rx_empty_w == 1'b1);
endproperty
rx_empty_high_as: assert  property(rx_empty_high)
else $error("[ASSERTION_ERROR] rx_empty_high test fail");
cover property(rx_empty_high);

// test full is fired when rx fifo is full
property rx_full_high;   
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) (DUT.rx_count == DUT.FIFO_DEPTH) |-> (DUT.rx_full_w == 1'b1);
endproperty
rx_full_high_as: assert  property(rx_full_high)
else $error("[ASSERTION_ERROR] rx_full_high test fail");
cover property(rx_full_high);
// =============================R13=============================
// test tx overflow
property tx_ovf;   
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) (apbif.PSEL && apbif.PENABLE && apbif.PWRITE && apbif.PADDR == 8'h08 && DUT.tx_full_w) 
    |=> ( DUT.int_stat[DUT.IRQ_TX_OVF] == 1'b1);
endproperty
tx_ovf_as: assert  property(tx_ovf)
else $error("[ASSERTION_ERROR] tx_ovf test fail");
cover property(tx_ovf);
// =======================R14=======================
// test rx overflow
property rx_ovf;   
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) (DUT.rx_full_w && DUT.rx_push_valid) |=> ( DUT.int_stat[DUT.IRQ_RX_OVF] == 1'b1);
endproperty
rx_ovf_as: assert  property(rx_ovf)
else $error("[ASSERTION_ERROR] rx_ovf test fail");
cover property(rx_ovf);


// ==============================R15==============================
// read zero when rx fifo is empty 
property rx_empty;   
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) (apbif.PSEL && apbif.PENABLE && ~apbif.PWRITE 
    && apbif.PADDR == 8'h0C && DUT.rx_empty_w) 
    |-> (apbif.PRDATA == 32'b0);
endproperty
rx_empty_as: assert  property(rx_empty)
else $error("[ASSERTION_ERROR] rx_empty test fail");
cover property(rx_empty);

// ==============================R16==============================
property IRQ_disabled;
    @(posedge apbif.PCLK)
    disable iff(~apbif.PRESETn)
    (
        apbif.PSEL &&
        apbif.PENABLE &&
        apbif.PWRITE &&
        apbif.PADDR == 8'h18 &&
        apbif.PWDATA[4:0] == 5'b0
    )
    |=> (apbif.IRQ == 1'b0);

endproperty
IRQ_disabled_as: assert property(IRQ_disabled)
else $error("[ASSERTION_ERROR] IRQ_disabled test fail");
cover property(IRQ_disabled);

// test IRQ equation
property IRQ_equation;   
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) (apbif.IRQ == |(DUT.int_stat & DUT.int_en));
endproperty
IRQ_equation_as: assert  property(IRQ_equation)
else $error("[ASSERTION_ERROR] IRQ_equation test fail");
cover property(IRQ_equation);

property SS_asserted_before_TX_write;
    @(posedge apbif.PCLK)
    disable iff(!apbif.PRESETn)

    (apbif.PSEL &&
     apbif.PENABLE &&
     apbif.PWRITE &&
     apbif.PADDR == 8'h08)

    |-> (apbif.SS_n != 4'b1111);
endproperty

SS_asserted_before_TX_write_as:assert property(SS_asserted_before_TX_write)
else $error("[ASSERTION_ERROR] SS_asserted_before_TX_write test fail");
cover property(SS_asserted_before_TX_write);

// ================================R20================================
// check that slave control register updated correctly after each write operation
property SS_n_correct;
    @(posedge apbif.PCLK)
    disable iff(~apbif.PRESETn)

    (apbif.PSEL &&
     apbif.PENABLE &&
     apbif.PWRITE &&
     apbif.PADDR == 8'h14)

    |=> (
        apbif.SS_n ==
        ((~$past(apbif.PWDATA[3:0])) |
          $past(apbif.PWDATA[7:4]))
    );
endproperty

SS_n_correct_as: assert property(SS_n_correct)
else $error("[ASSERTION_ERROR] SS_n_correct test fail");
cover property(SS_n_correct);

// check that PRDATA is correct after reading from the ssn control register
property SS_CTRL_read_correct;
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK)(apbif.PSEL && apbif.PENABLE && ~apbif.PWRITE && apbif.PADDR == 8'h14)
    |-> (apbif.PRDATA[31:0] == DUT.ss_ctrl_word[31:0]);
endproperty
SS_CTRL_read_correct_as: assert property(SS_CTRL_read_correct)
else $error("[ASSERTION_ERROR] SS_CTRL_read_correct fail");
cover property(SS_CTRL_read_correct);

// check that PRDATA is correct after reading from the INT_EN register
property INT_EN_read_correct;
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK)(apbif.PSEL && apbif.PENABLE && ~apbif.PWRITE && apbif.PADDR == 8'h18)
    |-> (apbif.PRDATA[31:0] == DUT.int_en_word[31:0]);
endproperty
INT_EN_read_correct_as: assert property(INT_EN_read_correct)
else $error("[ASSERTION_ERROR] INT_EN_read_correct fail");
cover property(INT_EN_read_correct);

// check that PRDATA is correct after reading from the INT_STAT register
property INT_STAT_read_correct;
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK)(apbif.PSEL && apbif.PENABLE && ~apbif.PWRITE && apbif.PADDR == 8'h1C)
    |-> (apbif.PRDATA[31:0] == DUT.int_stat_word[31:0]);
endproperty
INT_STAT_read_correct_as: assert property(INT_STAT_read_correct)
else $error("[ASSERTION_ERROR] INT_STAT_read_correct fail");
cover property(INT_STAT_read_correct);

// make sure that TX_DATA is write only register can not read from it 
property TX_DATA_read_zero;
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK)(apbif.PSEL && apbif.PENABLE && ~apbif.PWRITE && apbif.PADDR == 8'h1C)
    |-> (apbif.PRDATA == 32'h0);
endproperty
TX_DATA_read_zero_as: assert property(TX_DATA_read_zero)
else $error("[ASSERTION_ERROR] TX_DATA_read_zero fail");
cover property(TX_DATA_read_zero);

// =========================R22=========================
// test PREADY  should be high all the time 
property PREADY_1;
    @(posedge apbif.PCLK) (apbif.PREADY);
endproperty
PREADY_1_as: assert  property(PREADY_1)
else $error("[ASSERTION_ERROR] PREADY_1 test fail");
cover property(PREADY_1);

// test PSLVERR should be low all the time 
property PSLVERR_0;
    @(posedge apbif.PCLK) ~(apbif.PSLVERR);
endproperty
PSLVERR_0_as: assert  property(PSLVERR_0)
else $error("[ASSERTION_ERROR] PSLVERR_0 test fail");
cover property(PSLVERR_0);

// ==================================R23==================================
// test PADDR is 4 byte allgigned (its first 2 bits always zero or modulus 4 = 0)
property PADDR_correct_val;
    @(posedge apbif.PCLK) (apbif.PADDR % 4 == 0);
endproperty
PADDR_correct_val_as: assert  property(PADDR_correct_val)
else $error("[ASSERTION_ERROR] PADDR_correct_val test fail");
cover property(PADDR_correct_val);

// test PRDATA is zero if PADDR >= 24 in read case      
property PRDATA_correct_val;
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) (apbif.PSEL && apbif.PENABLE && ~apbif.PWRITE &&(apbif.PADDR >= 8'h24))
    |-> apbif.PRDATA == 32'h0;  // read is combinational
endproperty
PRDATA_correct_val_as: assert  property(PRDATA_correct_val)
else $error("[ASSERTION_ERROR] PRDATA_correct_val test fail");
cover property(PRDATA_correct_val);

// ignore any write when PADDR >= 24  (write is sequential)   
property ignore_CTRL_write;      // write 
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) (apbif.PSEL && apbif.PENABLE && apbif.PWRITE &&(apbif.PADDR >= 8'h24))
    |=> $stable(DUT.ctrl_word);
endproperty
ignore_CTRL_write_as: assert  property(ignore_CTRL_write)
else $error("[ASSERTION_ERROR] ignore_CTRL_write test fail");
cover property(ignore_CTRL_write);

property ignore_CLK_DIV_write;      // write
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) (apbif.PSEL && apbif.PENABLE && apbif.PWRITE &&(apbif.PADDR >= 8'h24))
    |=> $stable(DUT.clk_div_word);
endproperty
ignore_CLK_DIV_write_as: assert  property(ignore_CLK_DIV_write)
else $error("[ASSERTION_ERROR] ignore_CLK_DIV_write test fail");
cover property(ignore_CLK_DIV_write);

property ignore_SS_CTRL_write;      // write
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) (apbif.PSEL && apbif.PENABLE &&(apbif.PADDR >= 8'h24) && apbif.PWRITE ) 
    |=> $stable(DUT.ss_ctrl_word);
endproperty
ignore_SS_CTRL_write_as: assert  property(ignore_SS_CTRL_write)
else $error("[ASSERTION_ERROR] ignore_SS_CTRL_write test fail");
cover property(ignore_SS_CTRL_write);

property ignore_INT_EN_write;      // write
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) (apbif.PSEL && apbif.PENABLE && apbif.PWRITE &&(apbif.PADDR >= 8'h24))
    |=> $stable(DUT.int_en_word);
endproperty
ignore_INT_EN_write_as: assert  property(ignore_INT_EN_write)
else $error("[ASSERTION_ERROR] ignore_INT_EN_write test fail");
cover property(ignore_INT_EN_write);

property ignore_Delay_write;      // write
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) (apbif.PSEL && apbif.PENABLE && apbif.PWRITE &&(apbif.PADDR >= 8'h24))
    |=> $stable(DUT.delay_word);
endproperty
ignore_Delay_write_as: assert  property(ignore_Delay_write)
else $error("[ASSERTION_ERROR] ignore_Delay_write test fail");
cover property(ignore_Delay_write);

property ignore_TX_DATA_write;      // write
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) ((apbif.PADDR >= 8'h24) && apbif.PWRITE ) |=> $stable(DUT.tx_mem[7:0]);
endproperty
ignore_TX_DATA_write_as: assert  property(ignore_TX_DATA_write)
else $error("[ASSERTION_ERROR] ignore_TZ_DATA_write test fail");
cover property(ignore_TX_DATA_write);




endmodule