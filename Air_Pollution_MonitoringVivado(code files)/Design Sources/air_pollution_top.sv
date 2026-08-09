module air_pollution_top #(
    parameter int PM_WARN = 35,
    parameter int PM_DANGER = 55,
    parameter int CO2_WARN = 1000,
    parameter int CO2_DANGER = 1500,
    parameter int LOG_DEPTH = 16,
    parameter int CLKS_PER_BIT = 10
)(
    input logic clk,
    input logic rst,
    input logic sample_en,
    input logic [15:0] pm25_in,
    input logic [15:0] co2_in,
    input logic [15:0] temperature_in,
    input logic [15:0] humidity_in,
    input logic [$clog2(LOG_DEPTH)-1:0] read_addr,
    output logic [15:0] read_pm25,
    output logic [15:0] read_co2,
    output logic [15:0] read_temperature,
    output logic [15:0] read_humidity,
    output logic [1:0] read_status,
    output logic warning,
    output logic danger,
    output logic [1:0] status,
    output logic [15:0] current_pm25,
    output logic [15:0] current_co2,
    output logic [15:0] current_temperature,
    output logic [15:0] current_humidity,
    output logic [$clog2(LOG_DEPTH)-1:0] log_write_index,
    output logic tx_serial,
    output logic tx_busy,
    output logic tx_done,
    output logic packet_busy,
    output logic packet_done,
    output logic [3:0] packet_index,
    output logic [7:0] tx_data
);
    logic tx_start_internal;

    air_quality_monitor #(
        .PM_WARN(PM_WARN), .PM_DANGER(PM_DANGER),
        .CO2_WARN(CO2_WARN), .CO2_DANGER(CO2_DANGER)
    ) u_monitor (
        .clk(clk), .rst(rst), .pm25(pm25_in), .co2(co2_in),
        .temperature(temperature_in), .humidity(humidity_in),
        .warning(warning), .danger(danger), .status(status),
        .pm25_out(current_pm25), .co2_out(current_co2),
        .temperature_out(current_temperature), .humidity_out(current_humidity)
    );

    data_logger #(.DEPTH(LOG_DEPTH)) u_logger (
        .clk(clk), .rst(rst), .sample_en(sample_en),
        .pm25(current_pm25), .co2(current_co2),
        .temperature(current_temperature), .humidity(current_humidity),
        .status(status), .rd_addr(read_addr),
        .rd_pm25(read_pm25), .rd_co2(read_co2),
        .rd_temperature(read_temperature), .rd_humidity(read_humidity),
        .rd_status(read_status), .write_index(log_write_index)
    );

    sensor_packetizer #(
        .PM_WARN(PM_WARN), .PM_DANGER(PM_DANGER),
        .CO2_WARN(CO2_WARN), .CO2_DANGER(CO2_DANGER)
    ) u_packetizer (
        .clk(clk), .rst(rst), .sample_en(sample_en),
        .pm25(pm25_in), .co2(co2_in), .temperature(temperature_in), .humidity(humidity_in),
        .uart_busy(tx_busy), .uart_done(tx_done),
        .tx_data(tx_data), .tx_start(tx_start_internal),
        .packet_busy(packet_busy), .packet_done(packet_done), .packet_index(packet_index)
    );

    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_uart (
        .clk(clk), .rst(rst), .tx_data(tx_data), .tx_start(tx_start_internal),
        .tx_serial(tx_serial), .tx_busy(tx_busy), .tx_done(tx_done)
    );
endmodule
