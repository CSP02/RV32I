module ROM(
    input clk, we, 
    input [7:0] addr,
    input [7:0] data_in,
    output reg [15:0] instruction
);
    reg [15:0] memory [255:0];
    
//    always @(posedge clk) begin
//        if(we) begin
//            memory[addr] <= data_in;
//        end
//    end

    initial begin
        memory[0] = 16'b1100000000010101; // movi R0, 0ah
        memory[1] = 16'b1100001000001101; // movi R1, 06h
memory[2] = 16'b1111000000000000; // nop
memory[3] = 16'b1111000000000000; // nop
memory[4] = 16'b1111000000000000; // nop
memory[5] = 16'b0000010000001000; // add R2, R0, R1
memory[6] = 16'b0001011000001000; // sub R3, R0, R1
memory[7] = 16'b0100100000001000; // and R4, R0, R1
memory[8] = 16'b0101101000001000; // or R5, R0, R1
memory[9] = 16'b0110110000000000; // not R6, R0
    end
    
    always @(*) begin
        instruction <= memory[addr];
    end
endmodule