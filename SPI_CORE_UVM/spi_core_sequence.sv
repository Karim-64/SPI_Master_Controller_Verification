package spi_core_sequence_pkg;
    import uvm_pkg::*;
    import spi_core_shared_pkg::*;
    import spi_core_sequence_item_pkg::*;
    `include "uvm_macros.svh"
    /*write sequences like this*/
    //class spi_core_rst_sequence extends uvm_sequence #(spi_core_sequence_item);
    //    `uvm_object_utils(spi_core_rst_sequence)
    //    
    //    spi_core_sequence_item seq_item ;
    //    
    //    function new(string name = "spi_core_rst_sequence");
    //        super.new(name);
    //    endfunction
    //    
    //    task body ();
    //        seq_item = spi_core_sequence_item::type_id::create("seq_item");
    //        seq_item.constraint_mode(0);
    //        seq_item.main_c.constraint_mode(1);
    //        repeat(5) begin
    //            start_item(seq_item);
    //                seq_item.PRESETn = 0;
    //            finish_item(seq_item);
    //        end      
    //    endtask 
    //endclass
    
    
endpackage