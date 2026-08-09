`timescale 1ns/1ps

module health_monitor (
    input  logic        clk,
    input  logic        rst,
    input  logic        sample_en,

    input  logic [15:0] heart_rate_in,
    input  logic [15:0] temperature_in,
    input  logic [15:0] spo2_in,

    input  logic        warning_in,
    input  logic        danger_in,
    input  logic [1:0]  status_in,

    output logic [15:0] current_heart_rate,
    output logic [15:0] current_temperature,
    output logic [15:0] current_spo2,

    output logic        warning,
    output logic        danger,
    output logic [1:0]  status
);

    always_ff @(posedge clk) begin
        if (rst) begin
            current_heart_rate  <= 16'd0;
            current_temperature <= 16'd0;
            current_spo2        <= 16'd0;
            warning             <= 1'b0;
            danger              <= 1'b0;
            status              <= 2'b00;
        end
        else if (sample_en) begin
            current_heart_rate  <= heart_rate_in;
            current_temperature <= temperature_in;
            current_spo2        <= spo2_in;
            warning             <= warning_in;
            danger              <= danger_in;
            status              <= status_in;
        end
    end

endmodule
