`timescale 1ns/1ps

module sensor_calibration #(
    parameter integer HR_OFFSET   = 0,
    parameter integer TEMP_OFFSET = 0,
    parameter integer SPO2_OFFSET = 0
)(
    input  logic [15:0] heart_rate_raw,
    input  logic [15:0] temperature_raw,
    input  logic [15:0] spo2_raw,

    output logic [15:0] heart_rate_cal,
    output logic [15:0] temperature_cal,
    output logic [15:0] spo2_cal
);

    integer hr_tmp;
    integer temp_tmp;
    integer spo2_tmp;

    always_comb begin
        hr_tmp   = heart_rate_raw + HR_OFFSET;
        temp_tmp = temperature_raw + TEMP_OFFSET;
        spo2_tmp = spo2_raw + SPO2_OFFSET;

        if (hr_tmp < 0)       hr_tmp = 0;
        if (temp_tmp < 0)     temp_tmp = 0;
        if (spo2_tmp < 0)     spo2_tmp = 0;

        if (hr_tmp > 65535)   hr_tmp = 65535;
        if (temp_tmp > 65535) temp_tmp = 65535;
        if (spo2_tmp > 65535) spo2_tmp = 65535;

        heart_rate_cal  = hr_tmp;
        temperature_cal = temp_tmp;
        spo2_cal        = spo2_tmp;
    end

endmodule
