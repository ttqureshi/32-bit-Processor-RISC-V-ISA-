module csr_reg
(
    input  logic         clk,
    input  logic         rst,
    input  logic [31: 0] addr,
    input  logic [31: 0] wdata, // data from rs1
    input  logic [31: 0] pc,
    input  logic         trap,
    input  logic         csr_rd, // control signal for read
    input  logic         csr_wr, // control signal for write
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
            case (inst[31:20])
                12'b001100000000: rdata = csr_mem[0]; // mstatus 
                12'b001100000100: rdata = csr_mem[1]; // mie
                12'b001101000001: rdata = csr_mem[2]; // mepc
                12'b001101000100: rdata = csr_mem[3]; // mip
                // default: rdata = csr_mem[0];
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
            case (inst[31:20])
                12'h300: csr_mem[0] <= wdata; // mstatus
                12'h304: csr_mem[1] <= wdata; // mie
                12'h341: csr_mem[2] <= wdata; // mepc
                12'h344: csr_mem[3] <= wdata; // mip
            endcase
        end
    end
endmodule