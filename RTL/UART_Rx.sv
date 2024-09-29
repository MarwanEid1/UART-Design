
/* ----------------------------------------------------------------------------------------------- //
Project Title: Digital Design of UART 
By: Marwan Eid
File Description: UART Receiver Design Module
Last Updated: 20/09/2024
Email: eid.marwan.work@gmail.com
// ----------------------------------------------------------------------------------------------- */

// import state encoding package
import state_enc_one_hot_pkg::*;

module Rx # (
    parameter int W_DATA = 'd8,
    parameter int W_DVSR = 'd16
) (
    input logic clk,
    input logic rst_n,
    input logic [W_DVSR - 1 : 0] dvsr,
    input logic Rx_din,
    output logic [W_DATA - 1 : 0] Rx_dout,
    output logic Rx_done,
    output logic parity_error,
    output logic framing_error
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
    logic [W_DATA - 1 : 0] next_Rx_dout;
    logic next_Rx_done;
    logic next_parity_error;
    logic next_framing_error;

    // current state register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
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
            IDLE: begin
                if (!Rx_din) begin
                    next_state = START;
                end
            end
            START: begin
                if (tick_no >= ((max_cnt / 'd2)) - 'd1) begin
                    next_state = DATA;
                    next_tick_no = 'd0;
                    next_bit_no = 'd0;
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
            Rx_dout <= 'd0;
            Rx_done <= 'b0;
            parity_error <= 'b0;
            framing_error <= 'b0;
        end
        else begin
            Rx_dout <= next_Rx_dout;
            Rx_done <= next_Rx_done;
            parity_error <= next_parity_error;
            framing_error <= next_framing_error;
        end
    end

    // next output logic
    always_comb begin
        next_Rx_dout = Rx_dout;
        next_Rx_done = Rx_done;
        next_parity_error = parity_error;
        next_framing_error = framing_error;
        case (state)
            IDLE: begin
                next_Rx_dout = 'd0;
                next_Rx_done = 'b0;
                next_parity_error = 'b0;
                next_framing_error = 'b0;
            end
            START: begin
                next_Rx_dout = 'd0;
                next_Rx_done = 'b0;
                next_parity_error = 'b0;
                next_framing_error = 'b0;
            end
            DATA: begin
                if (tick_no >= (max_cnt - 'd1)) begin
                    next_Rx_dout = {Rx_din, Rx_dout[W_DATA - 1 : 1]};
                end
            end
            PARITY: begin
                if (tick_no >= (max_cnt - 'd1)) begin
                    if (^Rx_dout != Rx_din) begin
                        next_parity_error = 'b1;
                    end
                    else begin
                        next_parity_error = 'b0;
                    end
                end
            end
            STOP: begin
                if (tick_no >= (max_cnt - 'd1)) begin
                    next_Rx_done = 'b1;
                    if (Rx_din) begin
                        next_framing_error = 'b0;
                    end
                    else begin
                        next_framing_error = 'b1;
                    end
                end
            end
            default: begin
                next_Rx_dout = 'd0;
                next_Rx_done = 'b0;
                next_parity_error = 'b0;
                next_framing_error = 'b0;
            end
        endcase 
    end

endmodule: Rx
