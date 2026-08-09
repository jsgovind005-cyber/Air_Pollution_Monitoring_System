`timescale 1ns/1ps

module uart_tx #(
    parameter integer CLKS_PER_BIT = 4
)(
    input  logic       clk,
    input  logic       rst,

    input  logic [7:0] tx_data,
    input  logic       tx_start,

    output logic       tx_serial,
    output logic       tx_busy,
    output logic       tx_done
);

    typedef enum logic [1:0] {
        UART_IDLE  = 2'd0,
        UART_START = 2'd1,
        UART_DATA  = 2'd2,
        UART_STOP  = 2'd3
    } uart_state_t;

    uart_state_t state;

    logic [7:0] data_reg;
    logic [2:0] bit_index;
    integer bit_count;

    always_ff @(posedge clk) begin
        if (rst) begin
            state     <= UART_IDLE;
            data_reg  <= 8'd0;
            bit_index <= 3'd0;
            bit_count <= 0;
            tx_serial <= 1'b1;
            tx_busy   <= 1'b0;
            tx_done   <= 1'b0;
        end
        else begin
            tx_done <= 1'b0;

            case (state)
                UART_IDLE: begin
                    tx_serial <= 1'b1;
                    tx_busy   <= 1'b0;
                    bit_count <= 0;

                    if (tx_start) begin
                        data_reg  <= tx_data;
                        bit_index <= 3'd0;
                        bit_count <= 0;
                        tx_busy   <= 1'b1;
                        tx_serial <= 1'b0;
                        state     <= UART_START;
                    end
                end

                UART_START: begin
                    if (bit_count == CLKS_PER_BIT-1) begin
                        bit_count <= 0;
                        tx_serial <= data_reg[0];
                        bit_index <= 3'd0;
                        state     <= UART_DATA;
                    end
                    else begin
                        bit_count <= bit_count + 1;
                    end
                end

                UART_DATA: begin
                    if (bit_count == CLKS_PER_BIT-1) begin
                        bit_count <= 0;

                        if (bit_index == 3'd7) begin
                            tx_serial <= 1'b1;
                            state     <= UART_STOP;
                        end
                        else begin
                            bit_index <= bit_index + 1'b1;
                            tx_serial <= data_reg[bit_index + 1'b1];
                        end
                    end
                    else begin
                        bit_count <= bit_count + 1;
                    end
                end

                UART_STOP: begin
                    if (bit_count == CLKS_PER_BIT-1) begin
                        bit_count <= 0;
                        tx_serial <= 1'b1;
                        tx_busy   <= 1'b0;
                        tx_done   <= 1'b1;
                        state     <= UART_IDLE;
                    end
                    else begin
                        bit_count <= bit_count + 1;
                    end
                end

                default: state <= UART_IDLE;
            endcase
        end
    end

endmodule
