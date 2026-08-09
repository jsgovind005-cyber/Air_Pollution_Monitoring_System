module uart_tx #(
    parameter int CLKS_PER_BIT = 10
)(
    input  logic       clk,
    input  logic       rst,
    input  logic [7:0] tx_data,
    input  logic       tx_start,
    output logic       tx_serial,
    output logic       tx_busy,
    output logic       tx_done
);
    logic [$clog2(CLKS_PER_BIT+1)-1:0] clk_count;
    logic [3:0] bit_index;
    logic [7:0] data_reg;

    always_ff @(posedge clk) begin
        if (rst) begin
            tx_serial <= 1'b1;
            tx_busy <= 1'b0;
            tx_done <= 1'b0;
            clk_count <= '0;
            bit_index <= 4'd0;
            data_reg <= 8'd0;
        end else begin
            tx_done <= 1'b0;
            if (!tx_busy) begin
                tx_serial <= 1'b1;
                clk_count <= '0;
                bit_index <= 4'd0;
                if (tx_start) begin
                    data_reg <= tx_data;
                    tx_busy <= 1'b1;
                    tx_serial <= 1'b0;
                end
            end else if (clk_count == CLKS_PER_BIT-1) begin
                clk_count <= '0;
                if (bit_index == 4'd9) begin
                    tx_serial <= 1'b1;
                    tx_busy <= 1'b0;
                    tx_done <= 1'b1;
                    bit_index <= 4'd0;
                end else begin
                    bit_index <= bit_index + 1'b1;
                    case (bit_index + 1'b1)
                        4'd1: tx_serial <= data_reg[0];
                        4'd2: tx_serial <= data_reg[1];
                        4'd3: tx_serial <= data_reg[2];
                        4'd4: tx_serial <= data_reg[3];
                        4'd5: tx_serial <= data_reg[4];
                        4'd6: tx_serial <= data_reg[5];
                        4'd7: tx_serial <= data_reg[6];
                        4'd8: tx_serial <= data_reg[7];
                        4'd9: tx_serial <= 1'b1;
                        default: tx_serial <= 1'b1;
                    endcase
                end
            end else begin
                clk_count <= clk_count + 1'b1;
            end
        end
    end
endmodule
