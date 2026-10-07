/*  7  6  5  4  3   2  1   0
+--+--+--+--+---+--+--+--+
| 00 | rd | rs1 | rs2 | R[rd]=R[rs1]+R[rs2]
+--+--+--+--+---+--+--+--+
| 10 | rd | s |  imm  | R[rd]=imm << (s << 1)
+--+--+--+--+---+--+--+--+
| 11 |  offset  | rs2 | if (R[0]!=R[rs2]) PC=PC+sign_ext(offset)
+--+--+--+--+---+--+--+--+
*/

module ff #(parameter int W = 8) (
    input  logic clk, rst, en, 
    input  logic [W-1:0] d,
    output logic [W-1:0] q
);

    always_ff @(posedge clk) begin
        if (rst) q <= '0;
        else if (en) q <= d;
    end
endmodule

module counter (
    input  logic clk, rst,
    input  logic trigger,
    input  logic [3:0] offset,
    output logic [3:0] pc_out
    );

    // err: assign pc_out = 3'b000;
    always_ff @(posedge clk) begin
        if (rst) ff #(4) pc (clk, rst, 1, '0, pc_out);
        else if (trigger) ff #(4) pc (clk, rst, 1, pc - off, pc_out);
        else ff #(4) pc (clk, rst, 1, pc + 1, pc_out);
    end
endmodule


module scpu (
    input  logic clk, rst, en,
    output logic [3:0] pc_out,
    output logic [7:0] r0, r1, r2, r3
);
    logic [7:0] instr;
    imem u_imem (.addr(pc), .instr(instr));

    logic [1:0] op, rd, rs1, rs2, s, imm;
    logic [3:0] off;
    assign op  = instr[7:6];
    // err: assign rd  = instr[5:4], {rs1, s} = instr[3:2], {rs2, imm} = instr[1:0];
    assign rs1 = instr[3:2];
    assign s   = instr[3:2];
    assign rs2 = instr[1:0];
    assign imm = {6'b0, instr[1:0]};
    assign off = instr[5:2]; // +: forgot
    //assign s   = instr[3:2], imm = instr[
    
    logic [7:0] src1, src2;
    always_comb begin
        case (rs1)
            default: src1 = r0;
            2'd1: src1 = r1; // err: d2 -> 2'd2
            2'd2: src1 = r2;
            2'd3: src1 = r3;
        endcase
        case(rs2) 
            default: src2 = r0; //oops sr1 -> src2
            2'd1: src2 = r1;
            2'd2: src2 = r2;
            2'd3: src2 = r3;
        endcase
    end

    logic [7:0] sum, li_val, wdata;
    assign take_br = (op == 2'b11) && (src2 != r0);
    always_comb begin
        case(op)
            2'b00: wdata = src1 + src2;
            2'b10: wdata = imm << (s << 1); // note: 8'b10 << (2'b11 << 1) but result in 8bits -> 8'b1000_0000
            // no need, declared before with take_br: 2'b11: if (src2 != r0) 
            default: wdata = 8'b0;
        endcase
    end 

    logic [3:0] wr;
    assign we = en && (op == 2'b10 || op == 2'b00);
    assign wr = we ? (4'b0001 << rd) : 4'b0000; // turns out it was good idea
    
    ff #(8) u_r0 (clk, rst, wr == 1, wdata, r0); 
    ff #(8) u_r1 (clk, rst, wr == 2, wdata, r1);
    ff #(8) u_r2 (clk, rst, wr == 3, wdata, r2);
    ff #(8) u_r3 (clk, rst, wr == 4, wdata, r3);

    counter pc (clk, rst, take_br, off, pc_out);


endmodule    




















