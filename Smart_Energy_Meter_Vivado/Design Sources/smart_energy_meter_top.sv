module smart_energy_meter_top #(
    parameter integer CLK_FREQ_HZ = 10,
    parameter integer SAMPLE_HZ   = 1,
    parameter integer WARNING_POWER_W = 1500,
    parameter integer DANGER_POWER_W  = 2500,
    parameter integer TARIFF_PAISA_PER_KWH = 700
)(
    input  logic clk,
    input  logic rst,

    input  logic light_on,
    input  logic fan_on,
    input  logic tv_on,
    input  logic computer_on,
    input  logic ac_on,

    output logic [31:0] load_power_w,
    output logic [15:0] voltage_x10,
    output logic [15:0] current_x100,
    output logic [31:0] power_w,
    output logic [31:0] energy_wh,
    output logic [31:0] cost_rupees,

    output logic warning,
    output logic danger,
    output logic alert,

    output logic [1:0] alert_code,

    output logic uart_tx,
    output logic uart_busy
);
    logic sample_tick;
    logic power_valid;
    logic [31:0] watt_second_accumulator;

    logic [31:0] cost_paisa;

    logic [103:0] packet;
    logic packet_valid;

    clock_tick #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .TICK_HZ(SAMPLE_HZ)
    ) u_tick (
        .clk(clk),
        .rst(rst),
        .tick(sample_tick)
    );

    appliance_simulator u_appliance (
        .clk(clk),
        .rst(rst),
        .sample_tick(sample_tick),
        .light_on(light_on),
        .fan_on(fan_on),
        .tv_on(tv_on),
        .computer_on(computer_on),
        .ac_on(ac_on),
        .load_power_w(load_power_w)
    );

    sensor_model u_sensor (
        .clk(clk),
        .rst(rst),
        .sample_tick(sample_tick),
        .load_power_w(load_power_w),
        .voltage_x10(voltage_x10),
        .current_x100(current_x100)
    );

    power_calculator u_power (
        .clk(clk),
        .rst(rst),
        .sample_tick(sample_tick),
        .voltage_x10(voltage_x10),
        .current_x100(current_x100),
        .power_w(power_w),
        .power_valid(power_valid)
    );

    energy_accumulator u_energy (
        .clk(clk),
        .rst(rst),
        .sample_tick(sample_tick),
        .power_w(power_w),
        .energy_wh(energy_wh),
        .watt_second_accumulator(watt_second_accumulator)
    );

    threshold_detector #(
        .WARNING_POWER_W(WARNING_POWER_W),
        .DANGER_POWER_W(DANGER_POWER_W)
    ) u_threshold (
        .clk(clk),
        .rst(rst),
        .power_w(power_w),
        .warning(warning),
        .danger(danger)
    );

    alert_controller u_alert (
        .clk(clk),
        .rst(rst),
        .warning(warning),
        .danger(danger),
        .alert_code(alert_code),
        .alert(alert)
    );

    billing_calculator #(
        .TARIFF_PAISA_PER_KWH(TARIFF_PAISA_PER_KWH)
    ) u_billing (
        .clk(clk),
        .rst(rst),
        .energy_wh(energy_wh),
        .cost_paisa(cost_paisa),
        .cost_rupees(cost_rupees)
    );

    packetizer u_packetizer (
        .clk(clk),
        .rst(rst),
        .update(sample_tick),
        .voltage_x10(voltage_x10),
        .current_x100(current_x100),
        .power_w(power_w),
        .energy_wh(energy_wh),
        .cost_rupees(cost_rupees),
        .alert_code(alert_code),
        .packet(packet),
        .packet_valid(packet_valid)
    );

    uart_tx #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE(2)
    ) u_uart (
        .clk(clk),
        .rst(rst),
        .data_in(packet),
        .data_valid(packet_valid),
        .tx(uart_tx),
        .busy(uart_busy)
    );

endmodule
