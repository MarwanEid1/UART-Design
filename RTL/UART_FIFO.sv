
/* ----------------------------------------------------------------------------------------------- //
Project Title: Digital Design of UART 
By: Marwan Eid
File Description: UART FIFO Design Module
Last Updated: 20/09/2024
Email: eid.marwan.work@gmail.com
// ----------------------------------------------------------------------------------------------- */

module FIFO # (
    parameter int W_DATA = 'd8,
    parameter int D_FIFO = 'd8
) (
    input logic clk,
    input logic rst_n,
    input logic wr_en,
    input logic rd_en,
    input logic [W_DATA - 1 : 0] wr_data,
    output logic [W_DATA - 1 : 0] rd_data,
    output logic full,
    output logic empty
);

    // local parameters
    localparam int W_PTR = $clog2(D_FIFO);

    // signal declaration
    logic [W_DATA - 1 : 0] mem [0 : D_FIFO - 1];
    logic [W_PTR : 0] wr_ptr;
    logic [W_PTR : 0] rd_ptr;

    // flag generation
    always_comb begin
        full = (wr_ptr [W_PTR - 1 : 0] == rd_ptr [W_PTR - 1 : 0]) && (wr_ptr [W_PTR] != rd_ptr [W_PTR]);
        empty = (wr_ptr == rd_ptr);
    end

    // read and write operation
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 'd0;
            rd_ptr <= 'd0;
            rd_data <= 'd0;
        end
        else begin
            if (wr_en && !full) begin
                mem[wr_ptr [W_PTR - 1 : 0]] <= wr_data;
                wr_ptr <= wr_ptr + 1;
            end
            if (rd_en && !empty) begin
                rd_data <= mem[rd_ptr [W_PTR - 1 : 0]];
                rd_ptr <= rd_ptr + 1;
            end
        end
    end

endmodule: FIFO
