module data_mem
(
    input  logic        clk,
    input  logic        rd_en,
    input  logic [31:0] addr,
    input  logic [ 2:0] mem_acc_mode,
    output logic [31:0] rdata
);
    parameter BYTE              = 3'b000;
    parameter HALFWORD          = 3'b001;
    parameter WORD              = 3'b010;
    parameter BYTE_UNSIGNED     = 3'b011;
    parameter HALFWORD_UNSIGNED = 3'b100;

    logic [7:0] data_mem [1000];

    // asynchronous read
    always_comb
    begin
        if (rd_en)
        begin
            case (mem_acc_mode)
            BYTE:
                rdata = $signed (data_mem[addr]) ;
            HALFWORD:
                rdata = $signed({data_mem[addr], data_mem[addr+1]});
            WORD:
                rdata = $signed({data_mem[addr], data_mem[addr+1], data_mem[addr+2], data_mem[addr+3]});
            BYTE_UNSIGNED:
                rdata = {24'b0, {data_mem[addr]}};
            HALFWORD_UNSIGNED:
                rdata = {16'b0, {data_mem[addr]}, {data_mem[addr+1]}};
            endcase
        end
    end

    //synchronous write
    // always_ff @(posedge clk)
    // begin
        
    // end

endmodule