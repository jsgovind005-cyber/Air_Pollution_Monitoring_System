module sensor_model#(
    parameter integer NOMINAL_VOLTAGE_X10 = 2300
)(
    input  logic        clk,
    input  logic        rst,
    input  logic        sample_tick,
    input  logic [31:0] load_power_w,

    output logic [15:0] voltage_x10,
    output logic [15:0] current_x100
);
    /*
     * Software-only sensor model:
     * voltage_x10  = voltage in units of 0.1 V
     * current_x100 = current in units of 0.01 A
     *
     * Current is derived from simulated load:
     * I = P / V
     * current_x100 = P * 100 / V
     */
    always_ff @(posedge clk) begin
        if (rst) begin
            voltage_x10  <= NOMINAL_VOLTAGE_X10[15:0];
            current_x100 <= 16'd0;
        end else if (sample_tick) begin
            voltage_x10 <= NOMINAL_VOLTAGE_X10[15:0];

            if (load_power_w == 0)
                current_x100 <= 16'd0;
            else
                current_x100 <= (load_power_w * 100) / (NOMINAL_VOLTAGE_X10 / 10);
        end
    end
endmodule
