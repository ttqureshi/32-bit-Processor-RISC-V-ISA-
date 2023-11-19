module csr_reg
(
    input  logic         clk,
    input  logic         rst,
    input  logic [11: 0] addr,
    input  logic [31: 0] wdata,
    input  logic [31: 0] pc,
    input  logic         trap,
    input  logic         csr_rd,
    input  logic         csr_wr,
    input  logic [31: 0] inst,
    output logic [31: 0] rdata,
    output logic [31: 0] epc
);
    // logic [31: 0] mstatus;
    // logic [31: 0] mie;
    // logic [31: 0] mepc;
    // logic [31: 0] mip;

    logic [31: 0] csr_mem [4];

    // asynchronous read
    always_comb
    begin
        if (csr_rd)
        begin
            case (addr)
                12'h300: rdata = csr_mem[0]; // mstatus 
                12'h304: rdata = csr_mem[1]; // mie
                12'h341: rdata = csr_mem[2]; // mepc
                12'h344: rdata = csr_mem[3]; // mip
            endcase
        end
        else
        begin
            rdata = 32'b0;
        end
    end

    // synchronous write
    always_ff @(posedge clk)
    begin
        if (csr_wr)
        begin
            case (addr)
                12'h300: csr_mem[0] <= wdata; // mstatus
                12'h304: csr_mem[1] <= wdata; // mie
                12'h341: csr_mem[2] <= wdata; // mepc
                12'h344: csr_mem[3] <= wdata; // mip
            endcase
        end
    end
endmodule