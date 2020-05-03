//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com)
// 
// Create Date: 26.04.2020 20:52:25
// Module Name: tb_load_unit
// Project Name: Steel Core
// Description: RISC-V Steel Core Load Unit testbench
// 
// Dependencies: load_unit.v
// 
// Version 0.01
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`include "../globals.vh"


module tb_load_unit();

    reg [1:0] LOAD_SIZE;
    reg LOAD_UNSIGNED;
    reg [31:0] DATA_IN;
    wire [31:0] OUTPUT;
    
    load_unit dut(
    
        .LOAD_SIZE(LOAD_SIZE),
        .LOAD_UNSIGNED(LOAD_UNSIGNED),
        .DATA_IN(DATA_IN),
        .OUTPUT(OUTPUT)
        
        );
    
    integer i;
    
    initial
    begin
        
        $display("Testing Load Unit...");
        
        $display("Testing Load Unit for LB operation.");
        LOAD_SIZE = 2'b00;
        LOAD_UNSIGNED = 1'b0;
        
        for(i = 0; i < 10000; i=i+1)
        begin
        
            DATA_IN = $random;
            
            #10;
            
            if(OUTPUT != { {24{DATA_IN[7]}} , DATA_IN[7:0]})
            begin
                $display("FAIL. Wrong result.");
                $finish;
            end
        
        end
        
        $display("LB operation successfully tested.");
        
        $display("Testing Load Unit for LH operation.");
        LOAD_SIZE = 2'b01;
        LOAD_UNSIGNED = 1'b0;
        
        for(i = 0; i < 10000; i=i+1)
        begin
        
            DATA_IN = $random;
            
            #10;
            
            if(OUTPUT != { {16{DATA_IN[15]}} , DATA_IN[15:0]})
            begin
                $display("FAIL. Wrong result.");
                $finish;
            end
        
        end
        
        $display("LH operation successfully tested.");
        
        $display("Testing Load Unit for LW operation.");
        LOAD_SIZE = 2'b10;
        LOAD_UNSIGNED = 1'b0;
        
        for(i = 0; i < 10000; i=i+1)
        begin
        
            DATA_IN = $random;
            
            #10;
            
            if(OUTPUT != DATA_IN[31:0])
            begin
                $display("FAIL. Wrong result.");
                $finish;
            end
        
        end
        
        $display("LW operation successfully tested.");        
        
        $display("Testing Load Unit for LBU operation.");
        LOAD_SIZE = 2'b00;
        LOAD_UNSIGNED = 1'b1;
        
        for(i = 0; i < 10000; i=i+1)
        begin
        
            DATA_IN = $random;
            
            #10;
            if(OUTPUT != { 24'b0 , DATA_IN[7:0]})
            begin
                $display("FAIL. Wrong result.");
                $finish;
            end
        
        end
        
        $display("LBU operation successfully tested.");
        
        $display("Testing Load Unit for LHU operation.");
        
        LOAD_SIZE = 2'b01;
        LOAD_UNSIGNED = 1'b1;
        
        for(i = 0; i < 10000; i=i+1)
        begin
        
            DATA_IN = $random;
            
            #10;
            
            if(OUTPUT != { 16'b0 , DATA_IN[15:0]})
            begin
                $display("FAIL. Wrong result.");
                $finish;
            end
        
        end
        
        $display("LHU operation successfully tested.");        
        
        $display("Load Unit successfully tested.");
        
    end
                                                                
endmodule
