`timescale 1ns/1ps

module sensor_stability_checker #(
    parameter integer HR_MAX_STEP   = 20,
    parameter integer TEMP_MAX_STEP = 20,
    parameter integer SPO2_MAX_STEP = 5
)(
    input  logic        clk,
    input  logic        rst,
    input  logic        sample_en,

    input  logic [15:0] heart_rate,
    input  logic [15:0] temperature,
    input  logic [15:0] spo2,

    output logic sensor_valid, sensor_stable,sensor_error
);

    logic [15:0] prev_hr;
    logic [15:0] prev_temp;
    logic [15:0] prev_spo2;
    logic        first_sample;

    integer hr_diff,temp_diff,spo2_diff;

    // Validity is combinational so the CURRENT sample can be accepted
    // by the monitor/logger/packetizer on the same sample_en pulse.
    always_comb begin
        sensor_valid = (heart_rate > 0) &&
                       (spo2 <= 100) &&
                       (temperature <= 1000);
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            prev_hr       <= 16'd0;
            prev_temp     <= 16'd0;
            prev_spo2     <= 16'd0;
            first_sample  <= 1'b1;
            sensor_stable <= 1'b0;
            sensor_error  <= 1'b0;
        end
        else if (sample_en) begin
            sensor_error <= !sensor_valid;

            if (first_sample) begin
                sensor_stable <= 1'b1;
                first_sample  <= 1'b0;
            end
            else begin
                hr_diff   = heart_rate - prev_hr;
                temp_diff = temperature - prev_temp;
                spo2_diff = spo2 - prev_spo2;

                if (hr_diff < 0)
                    hr_diff = -hr_diff;

                if (temp_diff < 0)
                    temp_diff = -temp_diff;

                if (spo2_diff < 0)
                    spo2_diff = -spo2_diff;

                sensor_stable <= (hr_diff <= HR_MAX_STEP) &&
                                 (temp_diff <= TEMP_MAX_STEP) &&
                                 (spo2_diff <= SPO2_MAX_STEP);
            end

            prev_hr   <= heart_rate;
            prev_temp <= temperature;
            prev_spo2 <= spo2;
        end
    end

endmodule
