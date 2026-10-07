module scpu_tb;
    logic clk, rst, en;
    logic [3:0] pc_out;
    logic [7:0] r0, r1, r2, r3;

    scpu dut (
        .clk(clk), .rst(rst), .en(en),
        .pc(pc_out),
        .r0(r0), .r1(r1), .r2(r2), .r3(r3)
    );

    always #5 clk = ~clk;

    logic [7:0] ref_r [4];
    logic [3:0] ref_pc;
    logic [7:0] ref_mem [16];
    initial $readmemb("mem/prog.bin", ref_mem);

    always @(posedge clk) 
    if (!rst)
        $display("pc=%0d instr=%b r0=%0d r1=%0d r2=%0d r3=%0d", pc_out, dut.instr, r0, r1, r2, r3);

    task automatic ref_step();
        logic [7:0] i = ref_mem[ref_pc];
        case (i[7:6])
            2'b00: begin
                ref_r[i[5:4]] = ref_r[i[3:2]] + ref_r[i[1:0]];
                ref_pc = ref_pc + 1;
            end
            2'b10: begin
                ref_r[i[5:4]] = {6'b0, i[1:0]} << {i[3:2], 1'b0};
                ref_pc = ref_pc + 1;
            end
            2'b11: begin
                if (ref_r[i[1:0]] !== ref_r[0]) ref_pc = ref_pc + i[5:2];
                else ref_pc = ref_pc + 1;
            end
            2'b01: begin
                $display("ERROR: no opcode of this kind exists.");
                $finish;
            end
        endcase
    endtask

    task automatic check(string name, logic [7:0] got, logic [7:0] exp);
        if (got !== exp) $display("FAIL %s: got %0d, expected %0d", name, got, exp);
        else $display ("PASS %s = %0d", name, got);
    endtask

    initial begin
        clk = 0; rst = 1; en  = 0;
        ref_pc = 0;
        for (int k = 0; k < 4; k++) ref_r[k] = 0;

        repeat (2) @(posedge clk);
        @(negedge clk);
        rst = 0; en  = 1;

        repeat (50) begin
            @(negedge clk);
            ref_step();
            if (pc_out !== ref_pc || r0 !== ref_r[0] || r1 !== ref_r[1] || r2 !== ref_r[2] || r3 !== ref_r[3]) begin
                $display("MISMATCH: dut pc=%0d r=%0d %0d %0d %0d | ref pc=%0d r=%0d %0d %0d %0d", pc_out, r0, r1, r2, r3, ref_pc, ref_r[0], ref_r[1], ref_r[2], ref_r[3]);
                $finish;
            end

        end
        $display("PASS: DUT matched reference for 50 cycles");
        check("r2", r2, 8'd55);
        check("r0", r0, 8'd10);
        check("r1", r1, 8'd10);
        check("r3", r3, 8'd1);
        check("pc_out", {4'b0, pc_out}, 8'd9);

        $finish;
    end
endmodule
