module mux_2x1
(
    input  logic [31:0] rdata2,
    input  logic [31:0] imm_val,
    input  logic        sel_b,
    output logic [31:0] opr_b
);

    always_comb
    begin
        case (sel_b)
            1: opr_b = imm_val;
            default: opr_b = rdata2;
        endcase
    end

endmodule
