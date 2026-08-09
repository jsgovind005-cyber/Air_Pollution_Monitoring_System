`timescale 1ns/1ps

module health_packetizer (
    input  logic        clk,
    input  logic        rst,
    input  logic        sample_en,

    input  logic [15:0] heart_rate,
    input  logic [15:0] temperature,
    input  logic [15:0] spo2,
    input  logic [1:0]  status,

    input  logic        tx_busy,
    input  logic        tx_done,

    output logic [7:0]  tx_data,
    output logic        tx_start,

    output logic        packet_busy,
    output logic        packet_done,
    output logic [3:0]  packet_index
);

    typedef enum logic [1:0] {
        IDLE    = 2'd0,
        SEND    = 2'd1,
        WAIT_TX = 2'd2
    } state_t;

    state_t state;

    logic [15:0] hr_reg;
    logic [15:0] temp_reg;
    logic [15:0] spo2_reg;
    logic [1:0]  status_reg;
    logic [7:0]  checksum;
    logic [7:0]  current_byte;

    always_comb begin
        case (packet_index)
            4'd0: current_byte = 8'hA5;
            4'd1: current_byte = 8'h5A;
            4'd2: current_byte = hr_reg[7:0];
            4'd3: current_byte = hr_reg[15:8];
            4'd4: current_byte = temp_reg[7:0];
            4'd5: current_byte = temp_reg[15:8];
            4'd6: current_byte = spo2_reg[7:0];
            4'd7: current_byte = spo2_reg[15:8];
            4'd8: current_byte = {6'd0, status_reg};
            4'd9: current_byte = checksum;
            default: current_byte = 8'h00;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            state        <= IDLE;
            hr_reg       <= 16'd0;
            temp_reg     <= 16'd0;
            spo2_reg     <= 16'd0;
            status_reg   <= 2'b00;
            checksum     <= 8'd0;
            packet_index <= 4'd0;
            tx_data      <= 8'd0;
            tx_start     <= 1'b0;
            packet_busy  <= 1'b0;
            packet_done  <= 1'b0;
        end
        else begin
            tx_start    <= 1'b0;
            packet_done <= 1'b0;

            case (state)
                IDLE: begin
                    packet_busy <= 1'b0;

                    if (sample_en) begin
                        hr_reg     <= heart_rate;
                        temp_reg   <= temperature;
                        spo2_reg   <= spo2;
                        status_reg <= status;

                        checksum <= 8'hA5 ^ 8'h5A ^
                                    heart_rate[7:0] ^ heart_rate[15:8] ^
                                    temperature[7:0] ^ temperature[15:8] ^
                                    spo2[7:0] ^ spo2[15:8] ^
                                    {6'd0, status};

                        packet_index <= 4'd0;
                        packet_busy  <= 1'b1;
                        state        <= SEND;
                    end
                end

                SEND: begin
                    packet_busy <= 1'b1;

                    if (!tx_busy) begin
                        tx_data  <= current_byte;
                        tx_start <= 1'b1;
                        state    <= WAIT_TX;
                    end
                end

                WAIT_TX: begin
                    packet_busy <= 1'b1;

                    if (tx_done) begin
                        if (packet_index == 4'd9) begin
                            packet_index <= 4'd0;
                            packet_busy  <= 1'b0;
                            packet_done  <= 1'b1;
                            state        <= IDLE;
                        end
                        else begin
                            packet_index <= packet_index + 1'b1;
                            state        <= SEND;
                        end
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
