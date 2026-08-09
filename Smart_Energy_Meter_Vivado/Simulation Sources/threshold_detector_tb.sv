`timescale 1ns/1ps

module threshold_detector_tb;

    logic clk;
    logic rst;
    logic [31:0] power_w;
    logic warning;
    logic danger;

    always #5 clk = ~clk;

    threshold_detector #(
        .WARNING_POWER_W(1500),
        .DANGER_POWER_W(2500)
    ) dut (
        .clk(clk),
        .rst(rst),
        .power_w(power_w),
        .warning(warning),
        .danger(danger)
    );

    initial begin
        clk = 0;
        rst = 1;
        power_w = 0;

        #20 rst = 0;

        power_w = 1000;
        #20;
        $display("NORMAL : P=%0d W, warning=%b danger=%b", power_w, warning, danger);

        power_w = 1500;
        #20;
        $display("WARNING: P=%0d W, warning=%b danger=%b", power_w, warning, danger);

        power_w = 2500;
        #20;
        $display("DANGER : P=%0d W, warning=%b danger=%b", power_w, warning, danger);

        power_w = 500;
        #20;
        $display("NORMAL : P=%0d W, warning=%b danger=%b", power_w, warning, danger);

        $finish;
    end
endmodule
