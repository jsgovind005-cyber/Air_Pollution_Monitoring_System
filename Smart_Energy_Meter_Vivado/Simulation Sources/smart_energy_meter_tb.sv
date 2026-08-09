`timescale 1ns/1ps

module smart_energy_meter_tb;

    logic clk;
    logic rst;

    logic light_on;
    logic fan_on;
    logic tv_on;
    logic computer_on;
    logic ac_on;

    logic [31:0] load_power_w;
    logic [15:0] voltage_x10;
    logic [15:0] current_x100;
    logic [31:0] power_w;
    logic [31:0] energy_wh;
    logic [31:0] cost_rupees;

    logic warning;
    logic danger;
    logic alert;
    logic [1:0] alert_code;

    logic uart_tx;
    logic uart_busy;

    /*
     * Simulation settings:
     * CLK = 10 Hz
     * sample_tick = 1 Hz
     *
     * This makes the simulation fast enough to observe.
     */

    always #5 clk = ~clk;

    smart_energy_meter_top #(
        .CLK_FREQ_HZ(10),
        .SAMPLE_HZ(1),
        .WARNING_POWER_W(1500),
        .DANGER_POWER_W(2500),
        .TARIFF_PAISA_PER_KWH(700)
    ) dut (
        .clk(clk),
        .rst(rst),

        .light_on(light_on),
        .fan_on(fan_on),
        .tv_on(tv_on),
        .computer_on(computer_on),
        .ac_on(ac_on),

        .load_power_w(load_power_w),
        .voltage_x10(voltage_x10),
        .current_x100(current_x100),
        .power_w(power_w),
        .energy_wh(energy_wh),
        .cost_rupees(cost_rupees),

        .warning(warning),
        .danger(danger),
        .alert(alert),
        .alert_code(alert_code),

        .uart_tx(uart_tx),
        .uart_busy(uart_busy)
    );

    task automatic print_status(input string name);
        begin
            $display(
                "[%0t] %s | Load=%0d W | V=%0d.%0d V | I=%0d.%02d A | P=%0d W | E=%0d Wh | Cost=Rs.%0d | Warning=%b Danger=%b",
                $time, name,
                load_power_w,
                voltage_x10/10, voltage_x10%10,
                current_x100/100, current_x100%100,
                power_w, energy_wh, cost_rupees,
                warning, danger
            );
        end
    endtask

    initial begin
        clk = 1'b0;
        rst = 1'b1;

        light_on    = 1'b0;
        fan_on      = 1'b0;
        tv_on       = 1'b0;
        computer_on = 1'b0;
        ac_on       = 1'b0;

        #50;
        rst = 1'b0;

        // ------------------------------------------------
        // TEST 1: Light only = 60 W
        // ------------------------------------------------
        light_on = 1'b1;
        #150;
        print_status("TEST 1 - LIGHT");

        // ------------------------------------------------
        // TEST 2: Light + Fan = 135 W
        // ------------------------------------------------
        fan_on = 1'b1;
        #150;
        print_status("TEST 2 - LIGHT + FAN");

        // ------------------------------------------------
        // TEST 3: Add TV = 255 W
        // ------------------------------------------------
        tv_on = 1'b1;
        #150;
        print_status("TEST 3 - LIGHT + FAN + TV");

        // ------------------------------------------------
        // TEST 4: Add computer = 505 W
        // ------------------------------------------------
        computer_on = 1'b1;
        #150;
        print_status("TEST 4 - NORMAL LOAD");

        // ------------------------------------------------
        // TEST 5: AC ON = 2005 W
        // Warning should be asserted.
        // ------------------------------------------------
        ac_on = 1'b1;
        #150;
        print_status("TEST 5 - HIGH POWER");

        // ------------------------------------------------
        // TEST 6: AC + all loads = 2005 W
        // ------------------------------------------------
        #150;
        print_status("TEST 6 - HIGH POWER HOLD");

        // ------------------------------------------------
        // TEST 7: Keep AC + remove smaller loads = 1500 W
        // Boundary test for warning.
        // ------------------------------------------------
        light_on    = 1'b0;
        fan_on      = 1'b0;
        tv_on       = 1'b0;
        computer_on = 1'b0;
        #150;
        print_status("TEST 7 - AC ONLY");

        // ------------------------------------------------
        // TEST 8: AC + computer = 1750 W
        // Warning remains active.
        // ------------------------------------------------
        computer_on = 1'b1;
        #150;
        print_status("TEST 8 - AC + COMPUTER");

        // ------------------------------------------------
        // TEST 9: Force danger by changing AC + loads
        // 1500 + 250 + 120 + 75 + 60 = 2005 W,
        // still below 2500. Add another conceptual high
        // load is not available in this model, so danger
        // threshold is demonstrated in the second TB.
        // ------------------------------------------------

        // Return to normal
        ac_on       = 1'b0;
        computer_on = 1'b0;
        tv_on       = 1'b1;
        fan_on      = 1'b1;
        light_on    = 1'b1;

        #150;
        print_status("TEST 9 - RETURN TO NORMAL");

        #200;

        $display("Simulation completed.");
        $finish;
    end

endmodule
