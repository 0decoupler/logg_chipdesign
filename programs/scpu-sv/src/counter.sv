`default_nettype none

module counter (
    input  logic clk, rst,
    input  logic trigger,
    input  logic [3:0] offset,
    output logic [3:0] pc_out
    );

    // err: assign pc_out = 3'b000;
    always_ff @(posedge clk) begin
        if (rst)            pc_out <= '0;
        else if (trigger)   pc_out <= pc_out + offset;
        else                pc_out <= pc_out + 4'd1;
        /* err: if (rst) ff #(4) pc (clk, rst, 1, '0, pc_out);
        else if (trigger) ff #(4) pc (clk, rst, 1, pc - off, pc_out);
        else ff #(4) pc (clk, rst, 1, pc + 1, pc_out); */
    end
endmodule

