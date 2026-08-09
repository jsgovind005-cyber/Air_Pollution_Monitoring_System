`timescale 1ns/1ps

module health_monitor_top #(
    parameter integer LOG_DEPTH          = 8,
    parameter integer LOG_ADDR_WIDTH     = 3,
    parameter integer UART_CLKS_PER_BIT  = 4,
    parameter integer HR_CAL_OFFSET      = 0,
    parameter integer TEMP_CAL_OFFSET    = 0,
    parameter integer SPO2_CAL_OFFSET    = 0
)(
    input  logic clk,
    input  logic rst,
    input  logic sample_en,

    input  logic [15:0] heart_rate_raw,
    input  logic [15:0] temperature_raw,
    input  logic [15:0] spo2_raw,

    input  logic [LOG_ADDR_WIDTH-1:0] read_addr,

    output logic [15:0] read_heart_rate,
    output logic [15:0] read_temperature,
    output logic [15:0] read_spo2,
    output logic [1:0]  read_status,

    output logic [15:0] current_heart_rate,
    output logic [15:0] current_temperature,
    output logic [15:0] current_spo2,

    output logic warning,
    output logic danger,
    output logic [1:0] status,

    output logic sensor_valid,
    output logic sensor_stable,
    output logic sensor_error,

    output logic [LOG_ADDR_WIDTH-1:0] write_addr,

    output logic [7:0] tx_data,
    output logic tx_start,
    output logic packet_busy,
    output logic packet_done,
    output logic [3:0] packet_index,

    output logic tx_serial,
    output logic tx_busy,
    output logic tx_done
);

    logic [15:0] heart_rate_cal;
    logic [15:0] temperature_cal;
    logic [15:0] spo2_cal;

    logic warning_comb;
    logic danger_comb;
    logic [1:0] status_comb;

    logic [7:0] uart_tx_data;
    logic uart_tx_start;

    sensor_calibration #(
        .HR_OFFSET(HR_CAL_OFFSET),
        .TEMP_OFFSET(TEMP_CAL_OFFSET),
        .SPO2_OFFSET(SPO2_CAL_OFFSET)
    ) u_calibration (
        .heart_rate_raw(heart_rate_raw),
        .temperature_raw(temperature_raw),
        .spo2_raw(spo2_raw),
        .heart_rate_cal(heart_rate_cal),
        .temperature_cal(temperature_cal),
        .spo2_cal(spo2_cal)
    );

    sensor_stability_checker u_stability (
        .clk(clk),
        .rst(rst),
        .sample_en(sample_en),
        .heart_rate(heart_rate_cal),
        .temperature(temperature_cal),
        .spo2(spo2_cal),
        .sensor_valid(sensor_valid),
        .sensor_stable(sensor_stable),
        .sensor_error(sensor_error)
    );

    health_threshold_detector u_threshold (
        .heart_rate(heart_rate_cal),
        .temperature(temperature_cal),
        .spo2(spo2_cal),
        .warning(warning_comb),
        .danger(danger_comb),
        .status(status_comb)
    );

    health_monitor u_monitor (
        .clk(clk),
        .rst(rst),
        .sample_en(sample_en && sensor_valid),
        .heart_rate_in(heart_rate_cal),
        .temperature_in(temperature_cal),
        .spo2_in(spo2_cal),
        .warning_in(warning_comb),
        .danger_in(danger_comb),
        .status_in(status_comb),
        .current_heart_rate(current_heart_rate),
        .current_temperature(current_temperature),
        .current_spo2(current_spo2),
        .warning(warning),
        .danger(danger),
        .status(status)
    );

    health_data_logger #(
        .DEPTH( LOG_DEPTH ),
        .ADDR_WIDTH( LOG_ADDR_WIDTH )
    ) u_logger (
        .clk(clk),
        .rst(rst),
        .sample_en(sample_en && sensor_valid),
        .heart_rate(heart_rate_cal),
        .temperature(temperature_cal),
        .spo2(spo2_cal),
        .status(status_comb),
        .read_addr(read_addr),
        .read_heart_rate(read_heart_rate),
        .read_temperature(read_temperature),
        .read_spo2(read_spo2),
        .read_status(read_status),
        .write_addr(write_addr)
    );

    health_packetizer u_packetizer (
        .clk(clk),
        .rst(rst),
        .sample_en(sample_en && sensor_valid),
        .heart_rate(heart_rate_cal),
        .temperature(temperature_cal),
        .spo2(spo2_cal),
        .status(status_comb),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .tx_data(uart_tx_data),
        .tx_start(uart_tx_start),
        .packet_busy(packet_busy),
        .packet_done(packet_done),
        .packet_index(packet_index)
    );

    uart_tx #(
        .CLKS_PER_BIT(UART_CLKS_PER_BIT)
    ) u_uart (
        .clk(clk),
        .rst(rst),
        .tx_data(uart_tx_data),
        .tx_start(uart_tx_start),
        .tx_serial(tx_serial),
        .tx_busy(tx_busy),
        .tx_done(tx_done)
    );

    assign tx_data  = uart_tx_data;
    assign tx_start = uart_tx_start;

endmodule
