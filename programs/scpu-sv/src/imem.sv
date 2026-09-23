module imem (
    input  logic [3:0] addr, //to locate the instr
    output logic [7:0] instr //8 bit long instrs
);

    logic [7:0] mem [15:0]; //8bits long, 15
    initial begin
        $readmemh("mem/prog.bin", mem);
    end

    assign instr = mem[addr];
endmodule


