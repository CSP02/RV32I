module Processor(
    input clk, rst
);
    //pipeline fetch and decode registers
    reg [15:0] IFD_instruction;
    reg [3:0] IDE_opcode;
    reg [2:0] IDE_dest_addr, IDE_s1_addr, IDE_s2_addr;
    reg IDE_mode, IDE_mem_wr, IDE_res_we, IDE_reg_we;
    reg [7:0] IDE_data, IDE_s1, IDE_s2;
    
    //execution state registers
    reg E_we;
    reg [3:0] E_opcode;
    reg [2:0] E_dest, E_s1_addr, E_s2_addr; 
    reg [7:0] E_s1, E_s2, E_result, E_data;
    reg E_mode, E_mem_wr, E_res_we;

    
    //write back stage registers
    reg W_we, W_mem_wr, W_res_we;
    reg [2:0] W_dest;
    reg [7:0] W_result;
    
    //local registers and wires
    reg [7:0] data_reg;
    wire [7:0] data;
    wire [3:0] opcode;
    wire [2:0] dest_addr, s1_addr, s2_addr;
    
    wire [7:0] pc, s1, s2, alu_result;
    wire [15:0] instruction;
    wire mode, res_we, mem_wr;
    
    wire [7:0] ex_write_data;
    assign ex_write_data = E_mem_wr ? E_data :
                       E_res_we ? alu_result :
                       8'h00;
    
    PC programCounter (.clk(clk), .rst(rst), .new_addr(8'b0), .load(1'b0), .pc(pc));
    
    ROM IM (.clk(clk), .addr(pc), .we(we), .data_in(8'b0), .instruction(instruction)); // To be added next
    
    always @(posedge clk) begin
        if (rst) begin
            IFD_instruction <= 16'b0;

            IDE_opcode <= 4'b0;
            IDE_dest_addr <= 3'b0;
            IDE_s1_addr <= 3'b0;
            IDE_s2_addr <= 3'b0;
            IDE_mode <= 1'b0;
            IDE_mem_wr <= 1'b0;
            IDE_res_we <= 1'b0;
            IDE_reg_we <= 1'b0;
            IDE_data <= 8'b0;
            IDE_s1 <= 8'b0;
            IDE_s2 <= 8'b0;

            E_we <= 1'b0;
            E_opcode <= 4'b0;
            E_dest <= 3'b0;
            E_s1_addr <= 3'b0;
            E_s2_addr <= 3'b0;
            E_s1 <= 8'b0;
            E_s2 <= 8'b0;
            E_result <= 8'b0;
            E_data <= 8'b0;
            E_mode <= 1'b0;
            E_mem_wr <= 1'b0;
            E_res_we <= 1'b0;

            W_we <= 1'b0;
            W_mem_wr <= 1'b0;
            W_res_we <= 1'b0;
            W_dest <= 3'b0;
            W_result <= 8'b0;
        end else begin
            // fetch to decode
            IFD_instruction <= instruction;

            // decode stage registers
            IDE_opcode <= opcode;
            IDE_dest_addr <= dest_addr;
            IDE_s1_addr <= s1_addr;
            IDE_s2_addr <= s2_addr;
            IDE_mode <= mode;
            IDE_s1 <= s1;
            IDE_s2 <= s2;
            IDE_mem_wr <= mem_wr;
            IDE_res_we <= res_we;
            IDE_data <= data;
            IDE_reg_we <= mem_wr | res_we;

            // execute stage registers
            E_opcode <= IDE_opcode;
            E_dest <= IDE_dest_addr;
            E_s1_addr <= IDE_s1_addr;
            E_s2_addr <= IDE_s2_addr;
            E_s1 <= IDE_s1;
            E_s2 <= IDE_s2;
            E_mem_wr <= IDE_mem_wr;
            E_res_we <= IDE_res_we;
            E_mode <= IDE_mode;
            E_data <= IDE_data;
            E_we <= IDE_reg_we;
            E_result <= ex_write_data;

            // writeback stage registers
            W_we <= E_we;
            W_mem_wr <= E_mem_wr;
            W_res_we <= E_res_we;
            W_dest <= E_dest;
            W_result <= ex_write_data;
        end
    end
       
    InstructionDecoder ID (
        .clk(clk), 
        .instruction(IFD_instruction), 
        .opcode(opcode), 
        .dest(dest_addr), 
        .src1(s1_addr), 
        .src2(s2_addr), 
        .data(data), 
        .mode(mode)
    );
    
    ControlUnit CU (
        .opcode(opcode),
        .mode(mode), 
        .clk(clk),
        .res_we(res_we),
        .mem_wr(mem_wr)
    );
    
    RegisterFile RF(
        .clk(clk),
        .we(W_we),
        .write_data(W_result),
        .dest_addr(W_dest),
        .s1_addr(s1_addr),
        .s2_addr(s2_addr),
        .s1(s1),
        .s2(s2)
    );
    
    ALU alu(
        .clk(clk),
        .rst(rst),
        .a(E_s1),
        .b(E_s2),
        .opcode(E_opcode),
        .result(alu_result)
    );
endmodule