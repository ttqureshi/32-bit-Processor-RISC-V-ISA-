// In RISC-V XLEN denotes the bits of CPU. XLEN=32 

module pc 
(
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] pc_in,
    output logic [31:0] pc_out
);
    logic [31:0] pc_reg [1];

    always_ff @(posedge clk)
    begin
        if(rst)
        begin
            pc_out <= 0;
            pc_reg[0] = 0;
        end
        else
        begin
            pc_out <= pc_in;
            pc_reg[0] = pc_in;
        end
    end

endmodule
