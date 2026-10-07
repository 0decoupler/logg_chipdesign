/*  7  6  5  4  3   2  1   0
+--+--+--+--+---+--+--+--+
| 00 | rd | rs1 | rs2 | R[rd]=R[rs1]+R[rs2]
+--+--+--+--+---+--+--+--+
| 10 | rd | s |  imm  | R[rd]=imm << (s << 1)
+--+--+--+--+---+--+--+--+
| 11 |  offset  | rs2 | if (R[0]!=R[rs2]) PC=PC+sign_ext(offset)
+--+--+--+--+---+--+--+--+
*/
`default_nettype none

module scpu (
    input  logic clk, rst, en,
    output logic [3:0] pc,
    output logic [7:0] r0, r1, r2, r3
);
    logic [7:0] instr;
    imem u_imem (.addr(pc), .instr(instr));

    logic [1:0] op, rd, rs1, rs2, s, imm;
    logic [3:0] off;
    assign op  = instr[7:6];
    assign rd = instr[5:4]; 
    assign rs1 = instr[3:2];
    assign s   = instr[3:2];
    assign rs2 = instr[1:0];
    assign imm = instr[1:0];
    assign off = instr[5:2]; 
    
    logic [7:0] src1, src2;
    always_comb begin
        case (rs1)
            default: src1 = r0;
            2'd1: src1 = r1; 
            2'd2: src1 = r2;
            2'd3: src1 = r3;
        endcase
        case(rs2) 
            default: src2 = r0; 
            2'd1: src2 = r1;
            2'd2: src2 = r2;
            2'd3: src2 = r3;
        endcase
    end

    logic [7:0] wdata;
    logic take_br, we;
    assign take_br = (op == 2'b11) && (src2 != r0);
    always_comb begin
        case(op)
            2'b00: wdata = src1 + src2;
            2'b10: wdata = {6'b0, imm} << {s, 1'b0};
            default: wdata = 8'b0;
        endcase
    end 

    logic [3:0] wr;
    assign we = en && (op == 2'b10 || op == 2'b00);
    assign wr = we ? (4'b0001 << rd) : 4'b0000; 

    ff #(8) u_r0 (.clk(clk), .rst(rst), .en(wr[0]), .d(wdata), .q(r0)); 
    ff #(8) u_r1 (.clk(clk), .rst(rst), .en(wr[1]), .d(wdata), .q(r1));
    ff #(8) u_r2 (.clk(clk), .rst(rst), .en(wr[2]), .d(wdata), .q(r2));
    ff #(8) u_r3 (.clk(clk), .rst(rst), .en(wr[3]), .d(wdata), .q(r3));

    counter u_pc (.clk(clk), .rst(rst), .trigger(take_br), .offset(off), .pc_out(pc));

endmodule    












