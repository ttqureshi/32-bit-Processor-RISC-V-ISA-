module csr_reg
(
    input  logic clk,
    input  logic rst,
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
    logic [31: 0] mstatus;
    logic [31: 0] mip;
    logic [31: 0] mie;
    logic [31: 0] mepc;

    // asynchronous read
    always_comb
    begin
        if (csr_rd)
        begin
            case (addr)
                12'h300: rdata = mstatus;
                12'h304: rdata = mie;
                12'h341: rdata = mepc;
                12'h344: rdata = mip;
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
                12'h300: mstatus <= wdata;
                12'h304: mie     <= wdata;
                12'h341: mepc    <= wdata;
                12'h344: mip     <= wdata; 
            endcase
        end
    end
endmodule