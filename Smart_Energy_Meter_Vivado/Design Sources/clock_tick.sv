module clock_tick #(
    parameter integer CLK_FREQ_HZ = 10,
    parameter integer TICK_HZ     = 1
)(
    input  logic clk,
    input  logic rst,
    output logic tick
);
    localparam integer COUNT_MAX = CLK_FREQ_HZ / TICK_HZ;
    integer count;

    always_ff @(posedge clk) begin
        if (rst) begin
            count <= 0;
            tick  <= 1'b0;
        end else if (count >= COUNT_MAX-1) begin
            count <= 0;
            tick  <= 1'b1;
        end else begin
            count <= count + 1;
            tick  <= 1'b0;
        end
    end
endmodule
