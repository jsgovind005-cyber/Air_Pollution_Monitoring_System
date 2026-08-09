module energy_accumulator (
    input  logic        clk,
    input  logic        rst,
    input  logic        sample_tick,
    input  logic [31:0] power_w,

    output logic [31:0] energy_wh,
    output logic [31:0] watt_second_accumulator
);
    /*
     * For a 1 Hz sample_tick:
     *   energy accumulates power in watt-seconds.
     *   3600 watt-seconds = 1 Wh.
     */
    always_ff @(posedge clk) begin
        if (rst) begin
            energy_wh            <= 32'd0;
            watt_second_accumulator <= 32'd0;
        end else if (sample_tick) begin
            if (watt_second_accumulator + power_w >= 32'd3600) begin
                watt_second_accumulator <=
                    watt_second_accumulator + power_w - 32'd3600;
                energy_wh <= energy_wh + 32'd1;
            end else begin
                watt_second_accumulator <=
                    watt_second_accumulator + power_w;
            end
        end
    end
endmodule
