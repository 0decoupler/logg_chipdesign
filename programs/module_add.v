module top_module(
    input [31:0] a,
    input [31:0] b,
    output [31:0] sum
);
    wire [15:0] ada = a[15:0], adaa = a[31:16];
    wire [15:0] adb = b[15:0], adbb = b[31:16];
    wire [15:0] res1, res2;
    wire c1;
    add16 add1 (ada, adb, 0, res1, c1);
    add16 add2 (adaa, adbb, c1, res2, );
    assign sum = {res2, res1};

endmodule
