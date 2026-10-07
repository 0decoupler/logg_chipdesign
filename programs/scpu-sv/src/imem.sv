`default_nettype none

module imem (
    input  logic [3:0] addr, //to locate the instr
    output logic [7:0] instr
);

    logic [7:0] mem [0:15];
    initial begin
        $readmemb("mem/prog.bin", mem, 0, 9);
    end

    assign instr = mem[addr];
endmodule


