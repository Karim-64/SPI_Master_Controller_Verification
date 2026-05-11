package apb__fifo_stresssequence_pkg;
    import uvm_pkg::*;
    import apb_shared_pkg::*;
    import apb_sequence_item_pkg::*;
    `include "uvm_macros.svh"

    class apb_rst_sequence extends uvm_sequence #(apb_sequence_item);
        `uvm_object_utils(apb_rst_sequence)
        
        apb_sequence_item seq_item ;
        
        function new(string name = "apb_rst_sequence");
            super.new(name);
        endfunction
        
        task body ();
            seq_item = apb_sequence_item::type_id::create("seq_item");
            seq_item.constraint_mode(0);
            seq_item.main_c.constraint_mode(1);
            repeat(5) begin
                start_item(seq_item);
                    seq_item.PRESETn = 0;
                finish_item(seq_item);
            end
        endtask
    endclass

    class apb_status_sequence extends uvm_sequence #(apb_sequence_item);
        `uvm_object_utils(apb_status_sequence)
        
        apb_sequence_item seq_item ;
        
        function new(string name = "apb_status_sequence");
            super.new(name);
        endfunction
        
        task body ();
            seq_item = apb_sequence_item::type_id::create("seq_item");
            seq_item.constraint_mode(0);
            seq_item.main_c.constraint_mode(1);

            repeat(3) begin
                seq_item.ctrl_c.constraint_mode(1);
                start_item(seq_item);
                    assert (seq_item.randomize() with {PWDATA[0] == 1;});
                finish_item(seq_item);
                seq_item.ctrl_c.constraint_mode(0);
            end
            
            // ================== test TX_FULL ==================
            // repeat 8 times to fill the FIFO
            repeat(8) begin
                seq_item.ss_ctrl_c.constraint_mode(1);
                repeat(3) begin
                    start_item(seq_item);
                        assert (seq_item.randomize() with {
                            PWDATA[7:0] == 8'h01;
                        });
                    finish_item(seq_item);
                end
                seq_item.ss_ctrl_c.constraint_mode(0);

                repeat(3) begin
                    seq_item.TX_FULL_OVF_c.constraint_mode(1);
                    start_item(seq_item);
                        assert (seq_item.randomize());
                    finish_item(seq_item);
                    seq_item.TX_FULL_OVF_c.constraint_mode(0);
                end
            end

            // Read the status register to check the TX_FULL bit is set
            seq_item.status_read_c.constraint_mode(1);
            repeat(3) begin
                start_item(seq_item);
                    assert (seq_item.randomize());
                    seq_item.PADDR = 8'h04;
                finish_item(seq_item);
            end
            seq_item.status_read_c.constraint_mode(0);

            // ================== test TX_OVF ==================
            // write another element to make the FIFO overflow

            seq_item.ss_ctrl_c.constraint_mode(1);
                repeat(3) begin
                    start_item(seq_item);
                        assert (seq_item.randomize() with {
                            PWDATA[7:0] == 8'h01;
                        });
                    finish_item(seq_item);
                end
            seq_item.ss_ctrl_c.constraint_mode(0);
            
            seq_item.TX_FULL_OVF_c.constraint_mode(1);
            repeat(3) begin
                start_item(seq_item);
                    assert (seq_item.randomize());
                finish_item(seq_item);
            end
            seq_item.TX_FULL_OVF_c.constraint_mode(0);

            // after overflow the TX_FULL bit should be cleared and the TX_OVF bit should be set, read the status register to check that 
            seq_item.status_read_c.constraint_mode(1);
            repeat(3) begin
                start_item(seq_item);
                    assert (seq_item.randomize());
                    seq_item.PADDR = 8'h04;
                finish_item(seq_item);
            end
            seq_item.status_read_c.constraint_mode(0);

            // ================== test TX_empty ==================
            // pop all the elements in the FIFO
            seq_item.TX_empty.constraint_mode(1);
            repeat(8) begin
                repeat(3) begin
                    start_item(seq_item);
                        assert (seq_item.randomize());
                    finish_item(seq_item);
                end
            end
            seq_item.TX_empty.constraint_mode(0);

            // read the status register to check the TX_empty bit is set
            seq_item.status_read_c.constraint_mode(1);
            repeat(3) begin
                start_item(seq_item);
                    assert (seq_item.randomize());
                    seq_item.PADDR = 8'h04;
                finish_item(seq_item);
            end
            seq_item.status_read_c.constraint_mode(0);
            
            // ================== test RX_FULL ==================
            seq_item.RX_FULL_c.constraint_mode(1);
            repeat(8) begin
                repeat(3) begin
                    start_item(seq_item);
                        assert (seq_item.randomize());
                    finish_item(seq_item);
                end
            end
            seq_item.RX_FULL_c.constraint_mode(0);

            seq_item.status_read_c.constraint_mode(1);
            repeat(3) begin
                start_item(seq_item);
                    assert (seq_item.randomize());
                    seq_item.PADDR = 8'h04;
                finish_item(seq_item);
            end
            seq_item.status_read_c.constraint_mode(0);
            
            // ================== test RX_EMPTY ==================
            seq_item.RX_EMPTY_c.constraint_mode(1);
            repeat(8) begin
                repeat(3) begin
                    start_item(seq_item);
                        assert (seq_item.randomize());
                    finish_item(seq_item);
                end
            end
            seq_item.RX_EMPTY_c.constraint_mode(0);

            // ================== test RX_OVF ==================
            seq_item.RX_FULL_c.constraint_mode(1);
            repeat(3) begin
                start_item(seq_item);
                    assert (seq_item.randomize());
                finish_item(seq_item);
            end
            seq_item.RX_FULL_c.constraint_mode(0);

            seq_item.status_read_c.constraint_mode(1);
            repeat(3) begin
                start_item(seq_item);
                    assert (seq_item.randomize());
                    seq_item.PADDR = 8'h04;
                finish_item(seq_item);
            end
            seq_item.status_read_c.constraint_mode(0);
            
            seq_item.status_read_c.constraint_mode(1);
            repeat(3) begin
                start_item(seq_item);
                    assert (seq_item.randomize());
                    seq_item.PADDR = 8'h04;
                finish_item(seq_item);
            end
            seq_item.status_read_c.constraint_mode(0);
            
        endtask
    endclass


endpackage