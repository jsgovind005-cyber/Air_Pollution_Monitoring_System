module billing_calculator #(
    parameter integer TARIFF_PAISA_PER_KWH = 700
)(
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] energy_wh,

    output logic [31:0] cost_paisa,
    output logic [31:0] cost_rupees
);
    /*
     * Default tariff = 700 paise/kWh = Rs.7/kWh.
     * This is a simulation-only billing estimate.
     */
    always_ff @(posedge clk) begin
        if (rst) begin
            cost_paisa  <= 32'd0;
            cost_rupees <= 32'd0;
        end else begin
            cost_paisa  <= (energy_wh * TARIFF_PAISA_PER_KWH) / 1000;
            cost_rupees <= cost_paisa / 100;
        end
    end
endmodule
