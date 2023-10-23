module processor 
(
    input logic clk,
    input logic rst
); 
    // wires
    logic        rf_en;
    logic        sel_b;
    logic [31:0] pc_out;
    logic [31:0] new_pc;
    logic [31:0] inst;
    logic [ 4:0] rd;
    logic [ 4:0] rs1;
    logic [ 4:0] rs2;
    logic [ 6:0] opcode;
    logic [ 2:0] funct3;
    logic [ 6:0] funct7;
    logic [31:0] rdata1;
    logic [31:0] rdata2;
    logic [31:0] opr_a;
    logic [31:0] opr_b;
    logic [31:0] opr_res;
    logic [11:0] imm;
    logic [31:0] imm_val;
    logic [31:0] wdata;
    logic [3 :0] aluop;
    logic [31:0] rdata;
    logic        rd_en;
    logic        wr_en;
    logic [ 1:0] wb_sel;
    logic        br_taken;
    logic [ 2:0] br_type;
    logic [ 2:0] mem_acc_mode;


    // PC MUX
    mux_2x1 mux_2x1_pc
    (
        .in_0        ( pc_out + 32'd4 ),
        .in_1        ( opr_res        ),
        .select_line ( br_taken       ),
        .out         ( new_pc         )
    );

    // program counter
    pc pc_i
    (
        .clk   ( clk            ),
        .rst   ( rst            ),
        .pc_in ( new_pc         ),
        .pc_out( pc_out         )
    );

    // instruction memory
    inst_mem inst_mem_i
    (
        .addr  ( pc_out         ),
        .data  ( inst           )
    );

    // instruction decoder
    inst_dec inst_dec_i
    (
        .inst  ( inst           ),
        .rs1   ( rs1            ),
        .rs2   ( rs2            ),
        .rd    ( rd             ),
        .opcode( opcode         ),
        .funct3( funct3         ),
        .funct7( funct7         )
    );

    // register file
    reg_file reg_file_i
    (
        .clk   ( clk            ),
        .rf_en ( rf_en          ),
        .rd    ( rd             ),
        .rs1   ( rs1            ),
        .rs2   ( rs2            ),
        .rdata1( rdata1         ),
        .rdata2( rdata2         ),
        .wdata ( wdata          )
    );

    // immediate generator
    imm_gen imm_gen_i
    (
        .inst   ( inst          ),
        .imm_val( imm_val       )
    );

    // ALU opr_a MUX

    mux_2x1 mux_2x1_alu_opr_a
    (
        .in_0           ( pc_out  ),
        .in_1           ( rdata1  ),
        .select_line    ( sel_a   ),
        .out            ( opr_a   )
    );

    // ALU opr_b MUX
    mux_2x1 mux_2x1_alu_opr_b
    (
        .in_0           ( rdata2  ),
        .in_1           ( imm_val ),
        .select_line    ( sel_b   ),
        .out            ( opr_b   )
    );


    // alu
    alu alu_i
    (
        .aluop   ( aluop          ),
        .opr_a   ( opr_a          ),
        .opr_b   ( opr_b          ),
        .opr_res ( opr_res        )
    );


    data_mem data_mem_i
    (
        .clk            ( clk          ),
        .rd_en          ( rd_en        ),
        .wr_en          ( wr_en        ),
        .addr           ( opr_res      ),
        .mem_acc_mode   ( mem_acc_mode ),
        .rdata2         ( rdata2       ),
        .rdata          ( rdata        )
    );


    // Writeback MUX
    mux_3x1 wb_mux
    (
        .in_0           ( pc_out + 32'd4 ),
        .in_1           ( opr_res        ),
        .in_2           ( rdata          ),
        .select_line    ( wb_sel         ),
        .out            ( wdata          )
    );


    // controller
    controller controller_i
    (
        .opcode         ( opcode         ),
        .funct3         ( funct3         ),
        .funct7         ( funct7         ),
        .br_taken       ( br_taken       ),
        .aluop          ( aluop          ),
        .rf_en          ( rf_en          ),
        .sel_a          ( sel_a          ),
        .sel_b          ( sel_b          ),
        .rd_en          ( rd_en          ),
        .wr_en          ( wr_en          ),
        .wb_sel         ( wb_sel         ),
        .mem_acc_mode   ( mem_acc_mode   ),
        .br_type        ( br_type        ),
        .br_take        ( br_taken       )
    );

    
endmodule