//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com)
// 
// Create Date: 30.07.2020 18:18:32
// Module Name: tb_compliance
// Project Name: Steel Core
// Description: RISC-V compliance testbench
// 
// Dependencies: globals.vh
//               machine_control.v
//               alu.v
//               integer_file.v
//               branch_unit.v
//               decoder.v
//               csr_file.v
//               imm_generator.v
//               load_unit.v
//               store_unit.v
// 
// Version 0.01
// 
//////////////////////////////////////////////////////////////////////////////////

/*********************************************************************************

MIT License

Copyright (c) 2020 Rafael de Oliveira Calçada

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

********************************************************************************/

`timescale 1ns / 1ps
`include "../globals.vh"

module tb_compliance();

    reg CLK;
    reg RESET;              
    wire [31:0] I_ADDR;
    reg [31:0] INSTR;        
    wire [31:0] D_ADDR;
    wire [31:0] DATA_OUT;
    wire WR_REQ;
    wire [3:0] WR_MASK;
    reg [31:0] DATA_IN;        
    reg E_IRQ;
    reg T_IRQ;
    reg S_IRQ;    
    
    reg [8*50:0] tests [0:53] = {
        "I-ADD-01.elf.mem",
        "I-BLT-01.elf.mem",
        "I-JAL-01.elf.mem",
        "I-MISALIGN_JMP-01.elf.mem",
        "I-SB-01.elf.mem",
        "I-SRA-01.elf.mem",
        "I-ADDI-01.elf.mem",
        "I-BLTU-01.elf.mem",
        "I-JALR-01.elf.mem",
        "I-MISALIGN_LDST-01.elf.mem",
        "I-SH-01.elf.mem",
        "I-SRAI-01.elf.mem",
        "I-AND-01.elf.mem",
        "I-BNE-01.elf.mem",
        "I-LB-01.elf.mem",
        "I-NOP-01.elf.mem",
        "I-SLL-01.elf.mem",
        "I-SRL-01.elf.mem",
        "I-ANDI-01.elf.mem",
        "I-DELAY_SLOTS-01.elf.mem",
        "I-LBU-01.elf.mem",
        "I-OR-01.elf.mem",
        "I-SLLI-01.elf.mem",
        "I-SRLI-01.elf.mem",
        "I-AUIPC-01.elf.mem",
        "I-EBREAK-01.elf.mem",
        "I-LH-01.elf.mem",
        "I-ORI-01.elf.mem",
        "I-SLT-01.elf.mem",
        "I-SUB-01.elf.mem",
        "I-BEQ-01.elf.mem",
        "I-ECALL-01.elf.mem",
        "I-LHU-01.elf.mem",
        "I-RF_size-01.elf.mem",
        "I-SLTI-01.elf.mem",
        "I-SW-01.elf.mem",
        "I-BGE-01.elf.mem",
        "I-ENDIANESS-01.elf.mem",
        "I-LUI-01.elf.mem",
        "I-RF_width-01.elf.mem",
        "I-SLTIU-01.elf.mem",
        "I-XOR-01.elf.mem",
        "I-BGEU-01.elf.mem",
        "I-IO-01.elf.mem",
        "I-LW-01.elf.mem",
        "I-RF_x0-01.elf.mem",
        "I-SLTU-01.elf.mem",
        "I-XORI-01.elf.mem",
        "I-CSRRC-01.elf.mem",
        "I-CSRRCI-01.elf.mem",
        "I-CSRRS-01.elf.mem",
        "I-CSRRSI-01.elf.mem",
        "I-CSRRW-01.elf.mem",
        "I-CSRRWI-01.elf.mem"
        };
        
    reg [8*256:0] signatures [0:53] = {
        "../../../../../compliance/I-ADD-01.signature.output",
        "../../../../../compliance/I-BLT-01.signature.output",
        "../../../../../compliance/I-JAL-01.signature.output",
        "../../../../../compliance/I-MISALIGN_JMP-01.signature.output",
        "../../../../../compliance/I-SB-01.signature.output",
        "../../../../../compliance/I-SRA-01.signature.output",
        "../../../../../compliance/I-ADDI-01.signature.output",
        "../../../../../compliance/I-BLTU-01.signature.output",
        "../../../../../compliance/I-JALR-01.signature.output",
        "../../../../../compliance/I-MISALIGN_LDST-01.signature.output",
        "../../../../../compliance/I-SH-01.signature.output",
        "../../../../../compliance/I-SRAI-01.signature.output",
        "../../../../../compliance/I-AND-01.signature.output",
        "../../../../../compliance/I-BNE-01.signature.output",
        "../../../../../compliance/I-LB-01.signature.output",
        "../../../../../compliance/I-NOP-01.signature.output",
        "../../../../../compliance/I-SLL-01.signature.output",
        "../../../../../compliance/I-SRL-01.signature.output",
        "../../../../../compliance/I-ANDI-01.signature.output",
        "../../../../../compliance/I-DELAY_SLOTS-01.signature.output",
        "../../../../../compliance/I-LBU-01.signature.output",
        "../../../../../compliance/I-OR-01.signature.output",
        "../../../../../compliance/I-SLLI-01.signature.output",
        "../../../../../compliance/I-SRLI-01.signature.output",
        "../../../../../compliance/I-AUIPC-01.signature.output",
        "../../../../../compliance/I-EBREAK-01.signature.output",
        "../../../../../compliance/I-LH-01.signature.output",
        "../../../../../compliance/I-ORI-01.signature.output",
        "../../../../../compliance/I-SLT-01.signature.output",
        "../../../../../compliance/I-SUB-01.signature.output",
        "../../../../../compliance/I-BEQ-01.signature.output",
        "../../../../../compliance/I-ECALL-01.signature.output",
        "../../../../../compliance/I-LHU-01.signature.output",
        "../../../../../compliance/I-RF_size-01.signature.output",
        "../../../../../compliance/I-SLTI-01.signature.output",
        "../../../../../compliance/I-SW-01.signature.output",
        "../../../../../compliance/I-BGE-01.signature.output",
        "../../../../../compliance/I-ENDIANESS-01.signature.output",
        "../../../../../compliance/I-LUI-01.signature.output",
        "../../../../../compliance/I-RF_width-01.signature.output",
        "../../../../../compliance/I-SLTIU-01.signature.output",
        "../../../../../compliance/I-XOR-01.signature.output",
        "../../../../../compliance/I-BGEU-01.signature.output",
        "../../../../../compliance/I-IO-01.signature.output",
        "../../../../../compliance/I-LW-01.signature.output",
        "../../../../../compliance/I-RF_x0-01.signature.output",
        "../../../../../compliance/I-SLTU-01.signature.output",
        "../../../../../compliance/I-XORI-01.signature.output",
        "../../../../../compliance/I-CSRRC-01.signature.output",
        "../../../../../compliance/I-CSRRCI-01.signature.output",
        "../../../../../compliance/I-CSRRS-01.signature.output",
        "../../../../../compliance/I-CSRRSI-01.signature.output",
        "../../../../../compliance/I-CSRRW-01.signature.output",
        "../../../../../compliance/I-CSRRWI-01.signature.output"
        };

    steel_top #(
        
        .BOOT_ADDRESS(32'h00000000)
        
        ) dut (

        .CLK(CLK),
        .RESET(RESET),        
        .REAL_TIME(64'b0),        
        .I_ADDR(I_ADDR),
        .INSTR(INSTR),        
        .D_ADDR(D_ADDR),
        .DATA_OUT(DATA_OUT),
        .WR_REQ(WR_REQ),
        .WR_MASK(WR_MASK),
        .DATA_IN(DATA_IN),        
        .E_IRQ(E_IRQ),
        .T_IRQ(T_IRQ),
        .S_IRQ(S_IRQ)

    );
    
    reg [31:0] ram [0:16383]; // 4KB RAM
    integer f;
    integer i;
    integer j;
    integer k;
    integer m;
    integer n;
            
    always
    begin
        #10 CLK = !CLK;
    end
    
    initial
    begin
    
        for(k = 0; k < 54; k=k+1)
        begin
    
            // LOADS PROGRAM INTO MEMORY 
            for(i = 0; i < 65535; i=i+1) ram[i] = 32'b0;
            $display("Running %s...", tests[k]);
            f = $fopen(signatures[k], "w");
            $readmemh(tests[k],ram);            
            
            // INITIAL VALUES
            RESET = 1'b0;        
            CLK = 1'b0;        
            E_IRQ = 1'b0;
            T_IRQ = 1'b0;
            S_IRQ = 1'b0;
            
            // RESET
            #5;
            RESET = 1'b1;
            #15;
            RESET = 1'b0;
            
            // one second loop
            for(j = 0; j < 50000000; j = j + 1)
            begin
                #20;
                if(WR_REQ == 1'b1 && D_ADDR == 32'h00001000)
                begin           
                    m = ram[2047][16:2];
                    n = ram[2046][16:2];
                    for(m = ram[2047][16:2]; m < n; m=m+1)
                    begin
                        $fwrite(f, "%h\n", ram[m]);
                        $display("%h", ram[m]); 
                    end
                    #20;
                    j = 50000000;
                end
            end
                        
            $fclose(f);
            
        end
        
        $display("All signatures generated. Run the verify.sh script located inside the compliance folder.");
        
    end
    
    always @(posedge CLK or posedge RESET)
    begin
        if(RESET)
        begin
            INSTR = ram[I_ADDR[15:2]];
            DATA_IN = ram[D_ADDR[15:2]];
        end
        else
        begin            
            INSTR = ram[I_ADDR[15:2]];
            DATA_IN = ram[D_ADDR[15:2]];            
            if(WR_REQ)
            begin
                if(WR_MASK[0])
                begin
                    ram[D_ADDR[15:2]][7:0] <= DATA_OUT[7:0];
                end
                if(WR_MASK[1])
                begin
                    ram[D_ADDR[15:2]][15:8] <= DATA_OUT[15:8];
                end
                if(WR_MASK[2])
                begin
                    ram[D_ADDR[15:2]][23:16] <= DATA_OUT[23:16];
                end
                if(WR_MASK[3])
                begin
                    ram[D_ADDR[15:2]][31:24] <= DATA_OUT[31:24];
                end
            end
        end
    end

endmodule

