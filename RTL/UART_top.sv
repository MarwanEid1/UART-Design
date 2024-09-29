
/* ----------------------------------------------------------------------------------------------- //
Project Title: Digital Design of UART 
By: Marwan Eid
File Description: UART Top Design Module
Last Updated: 20/09/2024
Email: eid.marwan.work@gmail.com
// ----------------------------------------------------------------------------------------------- */

module top # (
    parameter int W_DATA = 'd8,
    parameter int W_DVSR = 'd16,
    parameter int D_FIFO = 'd8
) (
    input logic clk,
    input logic rst_n,
    input logic [W_DVSR - 1 : 0] dvsr,
    input logic Rx_din,
    input logic rd_uart,
    input logic wr_uart,
    input logic [W_DATA - 1 : 0] wr_data,
    output logic [W_DATA - 1 : 0] rd_data,
    output logic Tx_dout,
    output logic Rx_full,
    output logic Rx_empty,
    output logic Tx_full,
    output logic parity_error,
    output logic framing_error
);

    // signal declaration
    logic [W_DATA - 1 : 0] Rx_dout;
    logic Rx_done;
    logic Tx_empty;
    logic Tx_start;
    logic Tx_done;
    logic [W_DATA - 1 : 0] Tx_din;

    // Tx logic
    assign Tx_start = !Tx_empty;

    // Rx module instantiation
    Rx # (
        .W_DATA(W_DATA),
        .W_DVSR(W_DVSR)
    ) Rx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .dvsr(dvsr),
        .Rx_din(Rx_din),
        .Rx_dout(Rx_dout),
        .Rx_done(Rx_done),
        .parity_error(parity_error),
        .framing_error(framing_error)
    );

    // Rx FIFO instantiation
    FIFO # (
        .W_DATA(W_DATA),
        .D_FIFO(D_FIFO)
    ) Rx_fifo_inst (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(Rx_done),
        .rd_en(rd_uart),
        .wr_data(Rx_dout),
        .rd_data(rd_data),
        .full(Rx_full),
        .empty(Rx_empty)
    );

    // Tx module instantiation
    Tx # (
        .W_DATA(W_DATA),
        .W_DVSR(W_DVSR)
    ) Tx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .dvsr(dvsr),
        .Tx_start(Tx_start),
        .Tx_din(Tx_din),
        .Tx_dout(Tx_dout),
        .Tx_done(Tx_done)
    );

    // Tx FIFO instantiation
    FIFO # (
        .W_DATA(W_DATA),
        .D_FIFO(D_FIFO)
    ) Tx_fifo_inst (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_uart),
        .rd_en(Tx_done),
        .wr_data(wr_data),
        .rd_data(Tx_din),
        .full(Tx_full),
        .empty(Tx_empty)
    );

endmodule: top
