module controller
(
    input  logic [6:0] opcode,
    input  logic [6:0] funct7,
    input  logic [2:0] funct3,
    output logic [3:0] aluop,
    output logic       rf_en,  // control signal for write operation in register file
    output logic       sel_b,  // control signal to opr_b select MUX to ALU
    output logic       rd_en,  // contorl signal for reading from data memory
    output logic       wb_sel, // control signal for writeback MUX
    output logic [2:0] mem_acc_mode
);
    always_comb
    begin
        case(opcode)
            7'b0110011: //R-Type
            begin
                rf_en = 1'b1;
                sel_b = 1'b0;
                rd_en = 1'b0;
                mem_acc_mode = 3'b111;
                case(funct3)
                    3'b000: 
                    begin
                        case(funct7)
                            7'b0000000: aluop = 4'b0000; //ADD
                            7'b0100000: aluop = 4'b0001; //SUB
                        endcase
                    end
                    3'b001: aluop = 4'b0010; //SLL
                    3'b010: aluop = 4'b0011; //SLT
                    3'b011: aluop = 4'b0100; //SLTU
                    3'b100: aluop = 4'b0101; //XOR
                    3'b101:
                    begin
                        case(funct7)
                            7'b0000000: aluop = 4'b0110; //SRL
                            7'b0100000: aluop = 4'b0111; //SRA
                        endcase
                    end
                    3'b110: aluop = 4'b1000; //OR
                    3'b111: aluop = 4'b1001; //AND
                endcase
            end
            7'b0010011: // I-type - Data processing
            begin
                rf_en = 1'b1;
                sel_b = 1'b1;
                rd_en = 1'b0;
                mem_acc_mode = 3'b111;
                case (funct3)
                    3'b000: aluop = 4'b0000; //ADDI
                    3'b010: aluop = 4'b0011; //SLTI
                    3'b011: aluop = 4'b0100; //SLTIU
                    3'b100: aluop = 4'b0101; //XORI
                    3'b110: aluop = 4'b1000; //ORI
                    3'b111: aluop = 4'b1001; //ANDI
                    3'b001: aluop = 4'b0010; //SLLI
                    3'b101:
                    begin
                        case (funct7)
                            7'b0000000: aluop = 4'b0110; //SRLI
                            7'b0100000: aluop = 4'b0111; //SRAI
                        endcase
                    end
                endcase
            end
            7'b0000011: // I-type - Load Instructions
            begin
                rd_en = 1'b1;
                rf_en = 1'b1;
                sel_b = 1'b1;
                aluop = 4'b0000; // aluop is always addition in case of load instructions
                case(funct3)
                    3'b000: mem_acc_mode = 3'b000; // Byte access
                    3'b001: mem_acc_mode = 3'b001; // Halfword access
                    3'b010: mem_acc_mode = 3'b010; // Word access
                    3'b100: mem_acc_mode = 3'b011; // Byte unsigned access
                    3'b101: mem_acc_mode = 3'b100; // Halfword unsigned access
                endcase
            end
            default:
            begin
                rf_en = 1'b0;
                sel_b = 1'b0;
                rd_en = 1'b0;
                mem_acc_mode = 3'b111;
            end
        endcase
    end

endmodule