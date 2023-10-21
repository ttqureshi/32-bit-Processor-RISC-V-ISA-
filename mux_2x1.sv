module mux_2x1
(
    input  logic [31:0] in_1,
    input  logic [31:0] in_2,
    input  logic        select_line,
    output logic [31:0] out
);

    always_comb
    begin
        case (select_line)
            1: out = in_2;
            default: out = in_1;
        endcase
    end

endmodule
