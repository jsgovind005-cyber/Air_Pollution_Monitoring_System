`timescale 1ns/1ps

module health_threshold_detector #(
    parameter integer HR_LOW_WARN      = 55,
    parameter integer HR_LOW_DANGER    = 50,
    parameter integer HR_HIGH_WARN     = 101,
    parameter integer HR_HIGH_DANGER   = 120,

    parameter integer TEMP_LOW_WARN    = 350,
    parameter integer TEMP_LOW_DANGER  = 350,
    parameter integer TEMP_HIGH_WARN   = 375,
    parameter integer TEMP_HIGH_DANGER = 385,

    parameter integer SPO2_WARN        = 95,
    parameter integer SPO2_DANGER      = 93
)(
    input  logic [15:0] heart_rate,
    input  logic [15:0] temperature,
    input  logic [15:0] spo2,

    output logic        warning,
    output logic        danger,
    output logic [1:0]  status
);

    logic hr_warn;
    logic hr_danger;
    logic temp_warn;
    logic temp_danger;
    logic spo2_warn;
    logic spo2_danger;

    always_comb begin
        hr_danger = (heart_rate < HR_LOW_DANGER) ||
                    (heart_rate >= HR_HIGH_DANGER);

        hr_warn = !hr_danger &&
                  ((heart_rate < HR_LOW_WARN) ||
                   (heart_rate >= HR_HIGH_WARN));

        temp_danger = (temperature < TEMP_LOW_DANGER) ||
                      (temperature >= TEMP_HIGH_DANGER);

        temp_warn = !temp_danger &&
                    ((temperature < TEMP_LOW_WARN) ||
                     (temperature >= TEMP_HIGH_WARN));

        spo2_danger = (spo2 <= SPO2_DANGER);
        spo2_warn   = !spo2_danger && (spo2 <= SPO2_WARN);

        if (hr_danger || temp_danger || spo2_danger) begin
            warning = 1'b0;
            danger  = 1'b1;
            status  = 2'b10;
        end
        else if (hr_warn || temp_warn || spo2_warn) begin
            warning = 1'b1;
            danger  = 1'b0;
            status  = 2'b01;
        end
        else begin
            warning = 1'b0;
            danger  = 1'b0;
            status  = 2'b00;
        end
    end

endmodule
