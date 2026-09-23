module scpu_tb;
    logic clk, rst;
    logic [3:0] pc_out;

    scpu dut (
        .clk(clk),
        .rst(rst),
        .pc(pc_out)
    );

    always #5 clk = ~clk; //every 5 time units clk ticks

    initial begin
        clk = 0;
        rst = 1;
        #10 rst = 0; //release rst after 10 tu
        
        #10; //full clock edge pass
        if (pc_out !== 4'b0000)
            $display("FAIL: PC didnt reset to 0, got %h", pc_out);
        else
            $display("PASS: PC reset correctly");
        #10; //next cycle

        // CHECK 1ST INSTR SHOULD HAVE DONE -----
        // like did a reg change? did pc advance the value expected?
    
        #100 $finish; // nupon
    end
endmodule
