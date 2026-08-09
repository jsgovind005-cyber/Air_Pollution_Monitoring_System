module air_quality_monitor #(
    parameter int PM_WARN    = 35,
    parameter int PM_DANGER  = 55,
    parameter int CO2_WARN   = 1000,
    parameter int CO2_DANGER = 1500
)(
    input  logic        clk,
    input  logic        rst,
    input  logic [15:0] pm25,
    input  logic [15:0] co2,
    input  logic [15:0] temperature,
    input  logic [15:0] humidity,
    output logic        warning,
    output logic        danger,
    output logic [1:0]  status,
    output logic [15:0] pm25_out,
    output logic [15:0] co2_out,
    output logic [15:0] temperature_out,
    output logic [15:0] humidity_out
);
    logic warning_comb, danger_comb;
    logic [1:0] status_comb;

    threshold_detector #(
        .PM_WARN(PM_WARN), .PM_DANGER(PM_DANGER),
        .CO2_WARN(CO2_WARN), .CO2_DANGER(CO2_DANGER)
    ) u_threshold_detector (
        .pm25(pm25), .co2(co2), .warning(warning_comb),
        .danger(danger_comb), .status(status_comb)
    );

    always_ff @(posedge clk) begin
        if (rst) begin
            pm25_out <= 16'd0;
            co2_out <= 16'd0;
            temperature_out <= 16'd0;
            humidity_out <= 16'd0;
            warning <= 1'b0;
            danger <= 1'b0;
            status <= 2'd0;
        end else begin
            pm25_out <= pm25;
            co2_out <= co2;
            temperature_out <= temperature;
            humidity_out <= humidity;
            warning <= warning_comb;
            danger <= danger_comb;
            status <= status_comb;
        end
    end
endmodule
