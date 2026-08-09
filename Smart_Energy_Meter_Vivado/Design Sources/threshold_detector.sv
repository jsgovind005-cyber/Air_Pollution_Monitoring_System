module threshold_detector #(
    parameter integer WARNING_POWER_W = 1500,
    parameter integer DANGER_POWER_W  = 2500
)(
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] power_w,

    output logic warning,
    output logic danger
);
    always_ff @(posedge clk) begin
        if (rst) begin
            warning <= 1'b0;
            danger  <= 1'b0;
        end else begin
            warning <= (power_w >= WARNING_POWER_W);
            danger  <= (power_w >= DANGER_POWER_W);
        end
    end
endmodule
