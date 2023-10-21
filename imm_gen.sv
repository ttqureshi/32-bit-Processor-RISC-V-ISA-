module imm_gen
(
    input  logic [31:0] inst,
    output logic [31:0] imm_val
);

    always_comb
    begin
        case(inst[14:12])
        3'b011: imm_val = {20'b0,inst[31:20]}; // SLTIU (SetLessThanImmUnsigned) doing zero-extension since the operation is for unsigned immediate
        3'b101: imm_val = {{27{inst[24]}},inst[24:20]};
        default:
        begin
            imm_val = {{20{inst[24]}},inst[31:20]};
        end
        endcase
    end

endmodule
