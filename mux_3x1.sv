module mux_3x1
(
    input  logic [31:0] in_0,
    input  logic [31:0] in_1,
    input  logic [31:0] in_2,
    input  logic [ 1:0] select_line,
    output logic [31:0] out
);

    always_comb
    begin
        case (select_line)
            2'b00: out = in_0;
            2'b01: out = in_1;
            2'b10: out = in_2;
            default : out = in_0;
        endcase
    end

endmodule
