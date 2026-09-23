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
    logic [W-1:0] q
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

    assign pc_out = 3'b000;
    always_ff @(posedge clk) begin
        if (rst) pc_out <= '0;
        else if (trigger) pc_out <= pc_out - offset;
        else pc_out <= pc_out + 1;
    end
endmodule


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
    assign rd  = instr[5:4], {rs1, s} = instr[3:2], {rs2, imm} = instr[1:0];
    //assign s   = instr[3:2], imm = instr[
    
    logic [7:0] src1, src2;
    always_comb begin
        case (rs1)
            d2: src1 = r1;
            d3: src1 = r2;
            d4: src1 = r3;
            default: src1 = r0;
        endcase
        case(rs2) 
            d2: src2 = r1;
            d3: src2 = r2;
            d4: src2 = r3;
            default: src1 = r0;
        endcase
    end

    wire logic [7:0] sum, li_val, wdata;
    always_comb begin
        case(op)
            2'b00: wdata = src1 + src2;
            2'b10: wdata = imm << (s << 1);
            2'b11: if (src2 != r0)
            default: wdata = '0;
        endcase
    end 

    //logic i = (4'b0001 << rd)
    always_comb begin
        case (rd) 
            d1: wr0 = 1;
            d2: wr1 = 1;
            d3: wr2 = 1;
            default: wr3 = 1;
        endcase
    end
    
    ff #(8) r0 (clk, rst, we & wr0, wdata, r0); 
    ff #(8) r1 (clk, rst, we & wr1, wdata, r1);
    ff #(8) r2 (clk, rst, we & wr2, wdata, r2);
    ff #(8) r3 (clk, rst, we & wr3, wdata, r3);

    counter pc (clk, rst, trigger, off, pc_out);


endmodule    




















