module apb_SVA (apb_if.DUT apbif);
// test async reset 
always_comb begin
    if(~apbif.PRESETn)begin
       ctrl_en_rst:         assert final(apbif.dut_cfg_en        == 1'b0);
       cfg_mstr_rst:        assert final(apbif.dut_cfg_mstr      == 1'b0);
       cfg_mode_rst:        assert final(apbif.dut_cfg_mode      == 2'b0);
       cfg_lsb_first_rst:   assert final(apbif.dut_cfg_lsb_first == 1'b0);
       cfg_loopback_rst:    assert final(apbif.dut_cfg_loopback  == 1'b0);
       cfg_width_rst:       assert final(apbif.dut_cfg_width     == 2'b0);

       cfg_delay_rst:       assert final(apbif.dut_cfg_delay     == 8'b0);

       SS_n_rst:            assert final(apbif.dut_SS_n          == 4'b1111);

       cfg_clk_div_rst:     assert final(apbif.dut_cfg_clk_div   == 16'b0);

       tx_word_RST:         assert final(apbif.dut_tx_word   == 32'b0);
       
        tx_empty_rst:       assert final(apbif.dut_tx_empty   == 1'b1);
        IRQ_rst:            assert final(apbif.dut_IRQ   == 1'b0);    

        PRDATA_rst:          assert final(apbif.dut_PRDATA   == 32'b0);   
    end
end

// test setup phase
property setup_phase;
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) $rose(apbif.PSEL) |-> (apbif.PENABLE == 0);
endproperty
setup_phase_as: assert property(setup_phase);
cover property(setup_phase);

// test access phase
property access_phase;
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) ($rose(apbif.PSEL) && ~apbif.PENABLE) |=> (apbif.PSEL && apbif.PENABLE);
endproperty
access_phase_as: assert property(access_phase);
cover property(access_phase);

// test penable in idle case should be zero 
property penable_idle_case;
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) (~apbif.PSEL) |-> (~apbif.PENABLE);
endproperty
penable_idle_case_as: assert property(penable_idle_case);
cover property(penable_idle_case);

// test PWRITE is stable during setup and access phases 
property PWRITE_stable_S_A;
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) (apbif.PSEL && ~apbif.PENABLE) |=> $stable(apbif.PWRITE);
endproperty
PWRITE_stable_S_A_as: assert property(PWRITE_stable_S_A);
cover property(PWRITE_stable_S_A);

// test PWDATA is stable during setup and access phases 
property PWDATA_stable_S_A;
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) (apbif.PSEL && ~apbif.PENABLE) |=> $stable(apbif.PWDATA) ;
endproperty
PWDATA_stable_S_A_as: assert property(PWDATA_stable_S_A);
cover property(PWDATA_stable_S_A);

// test PADDR is stable during setup and access phases 
property PADDR_stable_S_A;
    disable iff(~apbif.PRESETn)
    @(posedge apbif.PCLK) (apbif.PSEL && ~apbif.PENABLE) |=> $stable(apbif.PADDR) ;
endproperty
PADDR_stable_S_A_as: assert property(PADDR_stable_S_A);
cover property(PADDR_stable_S_A);

// test PREADY 
property PREADY_1;
    @(posedge apbif.PCLK) (apbif.dut_PREADY);
endproperty
PREADY_1_as: assert  property(PREADY_1);
cover property(PREADY_1);

// test PSLVERR 
property PSLVERR_0;
    @(posedge apbif.PCLK) ~(apbif.dut_PSLVERR);
endproperty
PSLVERR_0_as: assert  property(PSLVERR_0);
cover property(PSLVERR_0);

// test PADDR is 4 byte allgigned
property PADDR_correct_val;
    @(posedge apbif.PCLK) (apbif.PADDR % 4 == 0);
endproperty
PADDR_correct_val_as: assert  property(PADDR_correct_val);
cover property(PADDR_correct_val);

// test PRDATA is zero if PADDR >= 24
property PRDATA_correct_val;
    @(posedge apbif.PCLK) (apbif.PADDR >= 24) |-> apbif.dut_PRDATA ==0;
endproperty
PRDATA_correct_val_as: assert  property(PRDATA_correct_val);
cover property(PRDATA_correct_val);

// test PRDATA is zero, ignore any write data

property ignore_dut_cfg_en_write;      // read 
    @(posedge apbif.PCLK) ((apbif.PADDR >= 24) && ~apbif.PWRITE ) |=> $stable(apbif.dut_cfg_en);
endproperty
ignore_dut_cfg_en_write_as: assert  property(ignore_dut_cfg_en_write);
cover property(ignore_dut_cfg_en_write);

property ignore_dut_cfg_mstr_write;      // read
    @(posedge apbif.PCLK) ((apbif.PADDR >= 24) && ~apbif.PWRITE ) |=> $stable(apbif.dut_cfg_mstr);
endproperty
ignore_dut_cfg_mstr_write_as: assert  property(ignore_dut_cfg_mstr_write);
cover property(ignore_dut_cfg_mstr_write);

property ignore_dut_dut_cfg_mode_write;      // read
    @(posedge apbif.PCLK) ((apbif.PADDR >= 24) && ~apbif.PWRITE ) |=> $stable(apbif.dut_cfg_mode);
endproperty
ignore_dut_dut_cfg_mode_write_as: assert  property(ignore_dut_dut_cfg_mode_write);
cover property(ignore_dut_dut_cfg_mode_write);

property ignore_dut_cfg_lsb_first_write;      // read
    @(posedge apbif.PCLK) ((apbif.PADDR >= 24) && ~apbif.PWRITE ) |=> $stable(apbif.dut_cfg_lsb_first);
endproperty
ignore_dut_cfg_lsb_first_write_as: assert  property(ignore_dut_cfg_lsb_first_write);
cover property(ignore_dut_cfg_lsb_first_write);

property ignore_dut_cfg_loopback_write;      // read
    @(posedge apbif.PCLK) ((apbif.PADDR >= 24) && ~apbif.PWRITE ) |=> $stable(apbif.dut_cfg_loopback);
endproperty
ignore_dut_cfg_loopback_write_as: assert  property(ignore_dut_cfg_loopback_write);
cover property(ignore_dut_cfg_loopback_write);

property ignore_dut_cfg_width_write;      // read
    @(posedge apbif.PCLK) ((apbif.PADDR >= 24) && ~apbif.PWRITE ) |=> $stable(apbif.dut_cfg_width);
endproperty
ignore_dut_cfg_width_write_as: assert  property(ignore_dut_cfg_width_write);
cover property(ignore_dut_cfg_width_write);

property ignore_dut_cfg_delay_write;      // read
    @(posedge apbif.PCLK) ((apbif.PADDR >= 24) && ~apbif.PWRITE ) |=> $stable(apbif.dut_cfg_delay);
endproperty
ignore_dut_cfg_delay_write_as: assert  property(ignore_dut_cfg_delay_write);
cover property(ignore_dut_cfg_delay_write);

property ignore_dut_SS_n_write;      // read
    @(posedge apbif.PCLK) ((apbif.PADDR >= 24) && ~apbif.PWRITE ) |=> $stable(apbif.dut_SS_n);
endproperty
ignore_dut_SS_n_write_as: assert  property(ignore_dut_SS_n_write);      // dut_cfg_clk_div
cover property(ignore_dut_SS_n_write);

property ignore_dut_cfg_clk_div_write;      // read
    @(posedge apbif.PCLK) ((apbif.PADDR >= 24) && ~apbif.PWRITE ) |=> $stable(apbif.dut_cfg_clk_div);
endproperty
ignore_dut_cfg_clk_div_write_as: assert  property(ignore_dut_cfg_clk_div_write); 
cover property(ignore_dut_cfg_clk_div_write);

property ignore_dut_IRQ_write;      // read
    @(posedge apbif.PCLK) ((apbif.PADDR >= 24) && ~apbif.PWRITE ) |=> $stable(apbif.dut_IRQ);
endproperty
ignore_dut_IRQ_write_as: assert  property(ignore_dut_IRQ_write); 
cover property(ignore_dut_IRQ_write);

property CTRL_write_updates;
    @(posedge apbif.PCLK)
    disable iff(~apbif.PRESETn)

    (apbif.PSEL && apbif.PENABLE &&
     apbif.PWRITE &&
     apbif.PADDR == 8'h00)

    |=> (
        apbif.dut_cfg_width     == $past(apbif.PWDATA[7:6]) &&
        apbif.dut_cfg_loopback  == $past(apbif.PWDATA[5])   &&
        apbif.dut_cfg_lsb_first == $past(apbif.PWDATA[4])   &&
        apbif.dut_cfg_mode      == $past(apbif.PWDATA[3:2]) &&
        apbif.dut_cfg_mstr      == $past(apbif.PWDATA[1])   &&
        apbif.dut_cfg_en        == $past(apbif.PWDATA[0])
    );
endproperty
CTRL_write_updates_as: assert  property(CTRL_write_updates);
cover property(CTRL_write_updates);

property CTRL_read_correct;
    @(posedge apbif.PCLK)
    disable iff(~apbif.PRESETn)

    (apbif.PSEL &&
     apbif.PENABLE &&
     !apbif.PWRITE &&
     apbif.PADDR == 8'h00)

    |-> (
        apbif.dut_PRDATA[7:6] == apbif.dut_cfg_width     &&
        apbif.dut_PRDATA[5]   == apbif.dut_cfg_loopback  &&
        apbif.dut_PRDATA[4]   == apbif.dut_cfg_lsb_first &&
        apbif.dut_PRDATA[3:2] == apbif.dut_cfg_mode      &&
        apbif.dut_PRDATA[1]   == apbif.dut_cfg_mstr      &&
        apbif.dut_PRDATA[0]   == apbif.dut_cfg_en
    );
endproperty
CTRL_read_correct_as: assert  property(CTRL_read_correct);
cover property(CTRL_read_correct);

property CLKDIV_write;
    @(posedge apbif.PCLK)
    disable iff(~apbif.PRESETn)

    (apbif.PSEL && apbif.PENABLE &&
     apbif.PWRITE &&
     apbif.PADDR == 8'h10)

    |=> (apbif.dut_cfg_clk_div == $past(apbif.PWDATA[15:0]));
endproperty
CLKDIV_write_as: assert  property(CLKDIV_write);
cover property(CLKDIV_write);

property CLKDIV_read_correct;
    @(posedge apbif.PCLK)
    disable iff(~apbif.PRESETn)

    (apbif.PSEL &&
     apbif.PENABLE &&
     !apbif.PWRITE &&
     apbif.PADDR == 8'h10)

    |-> (
        apbif.dut_PRDATA[15:0] == apbif.dut_cfg_clk_div
    );
endproperty
CLKDIV_read_correct_as: assert  property(CLKDIV_read_correct);
cover property(CLKDIV_read_correct);

property DELAY_write;
    @(posedge apbif.PCLK)
    disable iff(~apbif.PRESETn)

    (apbif.PSEL && apbif.PENABLE &&
     apbif.PWRITE &&
     apbif.PADDR == 8'h20)

    |=> (apbif.dut_cfg_delay == $past(apbif.PWDATA[7:0]));
endproperty
DELAY_write_as: assert  property(DELAY_write);
cover property(DELAY_write);

property SS_n_correct;
    @(posedge apbif.PCLK)
    disable iff(~apbif.PRESETn)

    (apbif.PSEL &&
     apbif.PENABLE &&
     apbif.PWRITE &&
     apbif.PADDR == 8'h14)

    |=> (
        apbif.dut_SS_n ==
        ((~$past(apbif.PWDATA[3:0])) |
          $past(apbif.PWDATA[7:4]))
    );
endproperty

SS_n_correct_as: assert property(SS_n_correct);
cover property(SS_n_correct);

property DELAY_read_correct;
    @(posedge apbif.PCLK)
    disable iff(~apbif.PRESETn)

    (apbif.PSEL &&
     apbif.PENABLE &&
     !apbif.PWRITE &&
     apbif.PADDR == 8'h20)

    |-> (
        apbif.dut_PRDATA[7:0] == apbif.dut_cfg_delay
    );
endproperty
DELAY_read_correct_as: assert  property(DELAY_read_correct);
cover property(DELAY_read_correct);

property TX_no_push_when_disabled;
    @(posedge apbif.PCLK)
    disable iff(~apbif.PRESETn)

    (apbif.PSEL &&
     apbif.PENABLE &&
     apbif.PWRITE &&
     apbif.PADDR == 8'h08 &&
     !apbif.dut_cfg_en)

    |=> (
        $stable(apbif.dut_tx_empty) &&
        $stable(apbif.dut_tx_word)
    );
endproperty

TX_no_push_when_disabled_as: assert property(TX_no_push_when_disabled);
cover property(TX_no_push_when_disabled);

property PRDATA_stable_during_write;
    @(posedge apbif.PCLK)
    disable iff(~apbif.PRESETn)

    (apbif.PSEL &&
     apbif.PENABLE &&
     apbif.PWRITE)

    |=> $stable(apbif.dut_PRDATA);
endproperty

PRDATA_stable_during_write_as: assert property(PRDATA_stable_during_write);
cover property(PRDATA_stable_during_write);

property phase_sequance;
    @(posedge apbif.PCLK) {apbif.PSEL, apbif.PENABLE} == 2'b00 |-> ##1 {apbif.PSEL, apbif.PENABLE} == 2'b10 |-> ##1 {apbif.PSEL, apbif.PENABLE} == 2'b11;
endproperty

phase_sequance_as: assert property(phase_sequance);
cover property(phase_sequance);

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
    |=> (apbif.dut_IRQ == 1'b0);

endproperty
IRQ_disabled_as: assert property(IRQ_disabled);
cover property(IRQ_disabled);


endmodule