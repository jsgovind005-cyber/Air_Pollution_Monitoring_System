module power_calculator (
    input  logic        clk,
    input  logic        rst,
    input  logic        sample_tick,
    input  logic [15:0] voltage_x10,
    input  logic [15:0] current_x100,

    output logic [31:0] power_w,
    output logic        power_valid
);
    /*
     * voltage_x10  = V * 10
     * current_x100 = I * 100
     *
     * P(W) = voltage_x10 * current_x100 / 1000
     */
    logic [31:0] product;

    always_ff @(posedge clk) begin
        if (rst) begin
            product      <= 32'd0;
            power_w      <= 32'd0;
            power_valid  <= 1'b0;
        end else begin
            power_valid <= 1'b0;
            if (sample_tick) begin
                product     <= voltage_x10 * current_x100;
                power_w     <= (voltage_x10 * current_x100) / 1000;
                power_valid <= 1'b1;
            end
        end
    end
endmodule
