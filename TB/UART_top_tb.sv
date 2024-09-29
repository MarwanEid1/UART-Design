
/* ----------------------------------------------------------------------------------------------- //
Project Title: Digital Design of UART 
By: Marwan Eid
File Description: UART Top Testbench Module
Last Updated: 20/09/2024
Email: eid.marwan.work@gmail.com
// ----------------------------------------------------------------------------------------------- */

`timescale 1ns/1ps

module top_tb;

    // parameters
    parameter int W_DATA = 'd8;
    parameter int W_DVSR = 'd16;

    // local parameters
    localparam int P_CLK = 'd25;
    localparam shortreal HALF_P_CLK = P_CLK / 2.0;
    localparam int OVRSMPL = 'd16;
    localparam int DVSR = 16'd260;
    localparam int DELAY = OVRSMPL * P_CLK * DVSR * 'd2;

    // signals
    logic clk;
    logic rst_n;
    logic [W_DVSR - 1 : 0] dvsr;
    logic Rx_din;
    logic rd_uart;
    logic wr_uart;
    logic [W_DATA - 1 : 0] wr_data;
    logic [W_DATA - 1 : 0] rd_data;
    logic Tx_dout;
    logic Rx_full;
    logic Rx_empty;
    logic Tx_full;
    logic parity_error;
    logic framing_error;

    // DUT instantiation
    top top_inst (
        .clk (clk),
        .rst_n (rst_n),
        .dvsr (dvsr),
        .Rx_din (Rx_din),
        .rd_uart (rd_uart),
        .wr_uart (wr_uart),
        .wr_data (wr_data),
        .rd_data (rd_data),
        .Tx_dout (Tx_dout),
        .Rx_full (Rx_full),
        .Rx_empty (Rx_empty),
        .Tx_full (Tx_full),
        .parity_error (parity_error),
        .framing_error (framing_error)
    );

    // write Rx character task
    task write_Rx_char;
        logic [W_DATA - 1 : 0] Rx_char;
        // idle
        Rx_din = 'b1;
        repeat (2) #DELAY;
        // start
        Rx_din = 'b0;
        #DELAY;
        // data
        for (int i = 'd0; i < 'd8; i++) begin
            Rx_din = $urandom_range(0, 1);
            #DELAY;
            Rx_char[i] = Rx_din;
        end
        // parity
        Rx_din = ^Rx_char;
        #DELAY;
        // stop
        Rx_din = 'b1;
        repeat (3) #DELAY;
    endtask: write_Rx_char

    // write Tx character task
    task write_Tx_char;
        wr_data = $urandom_range(0, 255);
        #P_CLK;
    endtask: write_Tx_char

    // clock generation
    initial clk = 'b0;
    always #(HALF_P_CLK) clk = !clk;

    // reset generation
    initial begin
        rst_n = 'b0;
        #P_CLK;
        rst_n = 'b1;
    end

    // initial values
    initial begin
        dvsr = DVSR;
        Rx_din = 'b1;
        rd_uart = 'b0;
        wr_uart = 'b0;
        wr_data = 'd0;
    end

    // sstimulus generation
    initial begin
        #P_CLK;
        fork
            begin
                // Rx Read -----------------------------------------------------------------
                repeat (6) begin
                    write_Rx_char;
                end
                // Rx Write ----------------------------------------------------------------
                rd_uart = 'b1;
                #DELAY;
            end
            begin
                // Tx Read and write -------------------------------------------------------
                wr_uart = 'b1;
                repeat (6) begin
                    write_Tx_char;
                end
                wr_uart = 'b0;
            end
        join
        repeat (10) #P_CLK;
        $stop;
    end

endmodule: top_tb
