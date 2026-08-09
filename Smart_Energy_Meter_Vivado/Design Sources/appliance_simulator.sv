module appliance_simulator (
    input  logic        clk,
    input  logic        rst,
    input  logic        sample_tick,

    input  logic        light_on,
    input  logic        fan_on,
    input  logic        tv_on,
    input  logic        computer_on,
    input  logic        ac_on,

    output logic [31:0] load_power_w
);
    localparam integer LIGHT_W    = 60;
    localparam integer FAN_W      = 75;
    localparam integer TV_W       = 120;
    localparam integer COMPUTER_W = 250;
    localparam integer AC_W       = 1500;

    always_ff @(posedge clk) begin
        if (rst) begin
            load_power_w <= 32'd0;
        end else if (sample_tick) begin
            load_power_w <=
                (light_on    ? LIGHT_W    : 0) +
                (fan_on      ? FAN_W      : 0) +
                (tv_on       ? TV_W       : 0) +
                (computer_on ? COMPUTER_W : 0) +
                (ac_on       ? AC_W       : 0);
        end
    end
endmodule
