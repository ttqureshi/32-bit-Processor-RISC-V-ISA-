module processor 
(
    input logic clk,
    input logic rst,
    input logic timer_interrupt
); 
    // wires
    logic [31:0] pc_out;
    logic [31:0] pc_out_if;
    logic [31:0] pc_out_id;
    logic [31:0] pc_out_ex;

    logic [31:0] new_pc;

    logic [31:0] inst;
    logic [31:0] inst_if;
    logic [31:0] inst_id;
    logic [31:0] inst_ex;


    logic [ 4:0] rd;
    logic [ 4:0] rs1;
    logic [ 4:0] rs2;
    logic [ 6:0] opcode;
    logic [ 2:0] funct3;
    logic [ 6:0] funct7;

    logic [31:0] rdata1;
    logic [31:0] rdata1_id;
    logic [31:0] rdata1_ex;

    logic [31:0] rdata2;
    logic [31:0] rdata2_id;
    logic [31:0] rdata2_ex;

    logic [31:0] opr_a;
    logic [31:0] opr_b;

    logic [31:0] opr_res;
    logic [31:0] opr_res_ex;
    logic [31:0] opr_res_mem;

    logic [11:0] imm;

    logic [31:0] imm_val;
    logic [31:0] imm_val_id;
    logic [31:0] imm_val_ex;

    logic [31:0] wdata;

    logic [31:0] rdata;

    logic        br_taken;
    logic        br_taken_id;
    logic        br_taken_ex;

    logic [3 :0] aluop;
    logic [3 :0] aluop_id;
    logic [3 :0] aluop_ex;

    logic        rf_en;
    logic        rf_en_id;
    logic        rf_en_ex;

    logic        sel_a;
    logic        sel_a_id;
    logic        sel_a_ex;

    logic        sel_b;
    logic        sel_b_id;
    logic        sel_b_ex;

    logic        rd_en;
    logic        rd_en_id;
    logic        rd_en_ex;

    logic        wr_en;
    logic        wr_en_id;
    logic        wr_en_ex;

    logic [ 1:0] wb_sel;
    logic [ 1:0] wb_sel_id;
    logic [ 1:0] wb_sel_ex;

    logic [ 2:0] mem_acc_mode;
    logic [ 2:0] mem_acc_mode_id;
    logic [ 2:0] mem_acc_mode_ex;

    logic [ 2:0] br_type;
    logic [ 2:0] br_type_id;
    logic [ 2:0] br_type_ex;

    logic        br_take;
    logic        br_take_id;
    logic        br_take_ex;

    logic        csr_rd;
    logic        csr_rd_id;
    logic        csr_rd_ex;

    logic        csr_wr;
    logic        csr_wr_id;
    logic        csr_wr_ex;

    logic        is_mret;
    logic        is_mret_id;
    logic        is_mret_ex;

    logic [31:0] csr_rdata;

    logic [31:0] epc;
    logic        epc_taken;
    logic [31:0] epc_pc;

    // --------------------- Instruction Fetch ---------------------

    // PC MUX
    mux_2x1 mux_2x1_pc
    (
        .in_0        ( pc_out_if + 32'd4 ),
        .in_1        ( opr_res           ),
        .select_line ( br_take           ),
        
        .out         ( new_pc            )
    );


    mux_2x1 mux_2x1_epc
    (
        .in_0        ( new_pc    ),
        .in_1        ( epc       ),
        .select_line ( epc_taken ),
        
        .out         ( epc_pc    ) 
    );


    // program counter
    pc pc_i
    (
        .clk   ( clk            ),
        .rst   ( rst            ),
        .pc_in ( epc_pc         ),

        .pc_out( pc_out_if      )
    );


    // instruction memory
    inst_mem inst_mem_i
    (
        .addr  ( pc_out_if      ),

        .data  ( inst_if        )
    );

    // ------------------------------------------------------

    // IF <-> ID Buffer
    always_ff @( posedge clk )
    begin
        if ( rst )
        begin
            pc_out_id <= 0;
            inst_id  <= 0;
        end
        else
        begin
            pc_out_id <= pc_out_if; // PC 
            inst_id   <= inst_if;   // instruction 
        end
    end

    // --------------------- Instruction Decode ---------------------

    // instruction decoder
    inst_dec inst_dec_i
    (
        .inst  ( inst_id        ),

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
        .rs1   ( rs1            ),
        .rs2   ( rs2            ),
        .rd    ( rd             ),
        .wdata ( wdata          ),

        .rdata1( rdata1_id      ),
        .rdata2( rdata2_id      )
    );


    // immediate generator
    imm_gen imm_gen_i
    (
        .inst   ( inst_id       ),
        
        .imm_val( imm_val_id    )
    );


    // controller
    controller controller_i
    (
        .opcode         ( opcode            ),
        .funct3         ( funct3            ),
        .funct7         ( funct7            ),

        .br_taken       ( br_taken_id       ),
        .aluop          ( aluop_id          ),
        .rf_en          ( rf_en_id          ),
        .sel_a          ( sel_a_id          ),
        .sel_b          ( sel_b_id          ),
        .rd_en          ( rd_en_id          ),
        .wr_en          ( wr_en_id          ),
        .wb_sel         ( wb_sel_id         ),
        .mem_acc_mode   ( mem_acc_mode_id   ),
        .br_type        ( br_type_id        ),
        .br_take        ( br_take_id        ),
        .csr_rd         ( csr_rd_id         ),
        .csr_wr         ( csr_wr_id         ),
        .is_mret        ( is_mret_id        )
    );

    // ------------------------------------------------------

    // ID <-> EX Buffer
    always_ff @(posedge clk)
    begin
        if ( rst )
        begin
            pc_out_ex       <= 0;
            rdata1_ex       <= 0;
            rdata2_ex       <= 0;
            imm_val_ex      <= 0;
            inst_ex         <= 0;

            // control signals
            br_taken_ex     <= 0;
            aluop_ex        <= 0;
            rf_en_ex        <= 0;
            sel_a_ex        <= 0;
            sel_b_ex        <= 0;
            rd_en_ex        <= 0;
            wr_en_ex        <= 0;
            wb_sel_ex       <= 0;
            mem_acc_mode_ex <= 0;
            br_type_ex      <= 0;
            br_take_ex      <= 0;
            csr_rd_ex       <= 0;
            csr_wr_ex       <= 0;
            is_mret_ex      <= 0;
        end
        else
        begin
            pc_out_ex       <= pc_out_id;
            rdata1_ex       <= rdata1_id;
            rdata2_ex       <= rdata2_id;
            imm_val_ex      <= imm_val_id;
            inst_ex         <= inst_id;

            // control signals
            br_taken_ex     <= br_taken_id;
            aluop_ex        <= aluop_id;
            rf_en_ex        <= rf_en_id;
            sel_a_ex        <= sel_a_id;
            sel_b_ex        <= sel_b_id;
            rd_en_ex        <= rd_en_id;
            wr_en_ex        <= wr_en_id;
            wb_sel_ex       <= wb_sel_id;
            mem_acc_mode_ex <= mem_acc_mode_id;
            br_type_ex      <= br_type_id;
            br_take_ex      <= br_take_id;
            csr_rd_ex       <= csr_rd_id;
            csr_wr_ex       <= csr_wr_id;
            is_mret_ex      <= is_mret_id;
        end
    end


    // --------------------- Execute ---------------------

    // ALU opr_a MUX
    mux_2x1 mux_2x1_alu_opr_a
    (
        .in_0           ( pc_out_ex  ),
        .in_1           ( rdata1_ex  ),
        .select_line    ( sel_a_ex   ),

        .out            ( opr_a      )
    );


    // ALU opr_b MUX
    mux_2x1 mux_2x1_alu_opr_b
    (
        .in_0           ( rdata2_ex  ),
        .in_1           ( imm_val_ex ),
        .select_line    ( sel_b_ex   ),

        .out            ( opr_b      )
    );


    // alu
    alu alu_i
    (
        .aluop   ( aluop_ex       ),
        .opr_a   ( opr_a          ),
        .opr_b   ( opr_b          ),

        .opr_res ( opr_res_ex     )
    );


    // br_cond
    br_cond br_cond_i
    (
        .rdata1   ( rdata1_ex   ),
        .rdata2   ( rdata2_ex   ),
        .br_type  ( br_type_ex  ),

        .br_taken ( br_taken )
    );

    // ------------------------------------------------------

    // EX <-> MEM Buffer


    // --------------------- Memory ---------------------


    // data memory
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


    // csr 
    csr_reg csr_reg_i
    (
        .clk       ( clk             ),
        .rst       ( rst             ),
        .addr      ( imm_val         ),
        .wdata     ( rdata1          ),
        .pc        ( pc_out          ),
        .trap      ( timer_interrupt ),
        .csr_rd    ( csr_rd          ),
        .csr_wr    ( csr_wr          ),
        .is_mret   ( is_mret         ),
        .inst      ( inst            ),

        .rdata     ( csr_rdata       ),
        .epc       ( epc             ),
        .epc_taken ( epc_taken       )
    );

    // ------------------------------------------------------

    // MEM <-> WB Buffer
    

    // --------------------- Write Back ---------------------


    // Writeback selection MUX
    mux_4x1 wb_mux
    (
        .in_0           ( pc_out + 32'd4 ),
        .in_1           ( opr_res        ),
        .in_2           ( rdata          ),
        .in_3           ( csr_rdata      ),
        .select_line    ( wb_sel         ),

        .out            ( wdata          )
    );

    // ------------------------------------------------------

    // Feedback from WB to ID


    
endmodule