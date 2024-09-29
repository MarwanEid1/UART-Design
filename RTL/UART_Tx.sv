
/* ----------------------------------------------------------------------------------------------- //
Project Title: Digital Design of UART 
By: Marwan Eid
File Description: UART Transmitter Design Module
Last Updated: 20/09/2024
Email: eid.marwan.work@gmail.com
// ----------------------------------------------------------------------------------------------- */

// import state encoding package
import state_enc_one_hot_pkg::*;

module Tx # (
    parameter int W_DATA = 'd8,
    parameter int W_DVSR = 'd16
) (
    input logic clk,
    input logic rst_n,
    input logic [W_DVSR - 1 : 0] dvsr,
    input logic Tx_start,
    input logic [W_DATA - 1 : 0] Tx_din,
    output logic Tx_dout,
    output logic Tx_done
);

    // local parameters
    localparam int W_DATA_BIT_NO = $clog2(W_DATA);
    localparam int OVRSMPL = 'd16;
    
    // current and next state
    state_e state, next_state;

    // signal declaration
    logic [W_DVSR - 1 : 0] tick_no, next_tick_no;
    logic [W_DATA_BIT_NO - 1 : 0] bit_no, next_bit_no;
    integer max_cnt;
    logic next_Tx_dout;
    logic next_Tx_done;

    // current state register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= PRE_FIRST_IDLE;
            tick_no <= 'd0;
            bit_no <= 'd0;
            max_cnt <= 'd0;
        end
        else begin
            state <= next_state;
            tick_no <= next_tick_no;
            bit_no <= next_bit_no;
            max_cnt <= dvsr * OVRSMPL * 'd2;
        end
    end

    // next state logic
    always_comb begin
        next_state = state;
        next_tick_no = tick_no;
        next_bit_no = bit_no;
        case (state)
            PRE_FIRST_IDLE: begin
                next_state = IDLE;
            end
            IDLE: begin
                if (Tx_start) begin
                    next_state = START;
                end
            end
            START: begin
                if (tick_no >= (max_cnt - 'd1)) begin
                    next_state = DATA;
                    next_tick_no = 'd0;
                end
                else begin
                    next_tick_no = tick_no + 'd1;
                end
            end
            DATA: begin
                if (tick_no >= (max_cnt - 'd1)) begin
                    next_tick_no = 'd0;
                    if (bit_no >= (W_DATA - 'd1)) begin
                        next_state = PARITY;
                        next_bit_no = 'd0;
                    end
                    else begin
                        next_bit_no = bit_no + 'd1;
                    end
                end
                else begin
                    next_tick_no = tick_no + 'd1;
                end
            end
            PARITY: begin
                if (tick_no >= (max_cnt - 'd1)) begin
                    next_state = STOP;
                    next_tick_no = 'd0;
                end
                else begin
                    next_tick_no = tick_no + 'd1;
                end
            end
            STOP: begin
                if (tick_no >= (max_cnt - 'd1)) begin
                    next_state = IDLE;
                    next_tick_no = 'd0;
                end
                else begin
                    next_tick_no = tick_no + 'd1;
                end
            end
            default: begin
                next_state = IDLE;
                next_tick_no = 'd0;
                next_bit_no = 'd0;
            end
        endcase
    end

    // current output register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            Tx_dout <= 'b1;
            Tx_done <= 'b0;
        end
        else begin
            Tx_dout <= next_Tx_dout;
            Tx_done <= next_Tx_done;
        end
    end

    // next output logic
    always_comb begin
        next_Tx_dout = Tx_dout;
        next_Tx_done = Tx_done;
        case (state)
            PRE_FIRST_IDLE: begin
                next_Tx_dout = 'b1;
                next_Tx_done = 'b1;
            end
            IDLE: begin
                next_Tx_dout = 'b1;
                next_Tx_done = 'b0;
            end
            START: begin
                next_Tx_dout = 'b0;
                next_Tx_done = 'b0;
            end
            DATA: begin
                if (bit_no < (W_DATA - 'd1)) begin
                    next_Tx_dout = Tx_din[bit_no];
                end
                else begin
                    next_Tx_dout = Tx_dout;
                end
                next_Tx_done = 'b0;
            end
            PARITY: begin
                next_Tx_dout = ^Tx_din;
                next_Tx_done = 'b0;
            end
            STOP: begin
                next_Tx_dout = 'b1;
                if (tick_no >= (max_cnt - 'd1)) begin
                    next_Tx_done = 'b1;
                end
                else begin
                    next_Tx_done = 'b0;
                end
            end
            default: begin
                next_Tx_dout = 'b1;
                next_Tx_done = 'b0;
            end
        endcase 
    end

endmodule: Tx
