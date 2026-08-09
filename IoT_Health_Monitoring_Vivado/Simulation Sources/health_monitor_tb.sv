`timescale 1ns/1ps

module health_monitor_tb;

    localparam integer LOG_ADDR_WIDTH = 3;

    logic clk;
    logic rst;
    logic sample_en;

    logic [15:0] heart_rate_raw;
    logic [15:0] temperature_raw;
    logic [15:0] spo2_raw;

    logic [LOG_ADDR_WIDTH-1:0] read_addr;

    logic [15:0] read_heart_rate;
    logic [15:0] read_temperature;
    logic [15:0] read_spo2;
    logic [1:0] read_status;

    logic [15:0] current_heart_rate;
    logic [15:0] current_temperature;
    logic [15:0] current_spo2;

    logic warning;
    logic danger;
    logic [1:0] status;

    logic sensor_valid;
    logic sensor_stable;
    logic sensor_error;

    logic [LOG_ADDR_WIDTH-1:0] write_addr;

    logic [7:0] tx_data;
    logic tx_start;
    logic packet_busy;
    logic packet_done;
    logic [3:0] packet_index;

    logic tx_serial;
    logic tx_busy;
    logic tx_done;

    initial clk = 1'b0;
    always #5 clk = ~clk;

    health_monitor_top dut (
        .clk(clk),
        .rst(rst),
        .sample_en(sample_en),

        .heart_rate_raw(heart_rate_raw),
        .temperature_raw(temperature_raw),
        .spo2_raw(spo2_raw),

        .read_addr(read_addr),
        .read_heart_rate(read_heart_rate),
        .read_temperature(read_temperature),
        .read_spo2(read_spo2),
        .read_status(read_status),

        .current_heart_rate(current_heart_rate),
        .current_temperature(current_temperature),
        .current_spo2(current_spo2),

        .warning(warning),
        .danger(danger),
        .status(status),

        .sensor_valid(sensor_valid),
        .sensor_stable(sensor_stable),
        .sensor_error(sensor_error),

        .write_addr(write_addr),

        .tx_data(tx_data),
        .tx_start(tx_start),
        .packet_busy(packet_busy),
        .packet_done(packet_done),
        .packet_index(packet_index),

        .tx_serial(tx_serial),
        .tx_busy(tx_busy),
        .tx_done(tx_done)
    );

    task automatic apply_sample(
        input integer hr,
        input integer temp_x10,
        input integer oxygen
    );
        begin
            @(negedge clk);

            heart_rate_raw  = hr;
            temperature_raw = temp_x10;
            spo2_raw        = oxygen;
            sample_en       = 1'b1;

            @(negedge clk);
            sample_en = 1'b0;

            #1;

            $display(
                "[%0t ns] HR=%0d | TEMP=%0d.%0d C | SpO2=%0d | VALID=%b | STABLE=%b | ERROR=%b | STATUS=%b | WARNING=%b | DANGER=%b",
                $time,
                hr,
                temp_x10/10,
                temp_x10%10,
                oxygen,
                sensor_valid,
                sensor_stable,
                sensor_error,
                status,
                warning,
                danger
            );

            wait(packet_done == 1'b1);
            @(negedge clk);
        end
    endtask

    integer i;

    initial begin
        rst = 1'b1;
        sample_en = 1'b0;

        heart_rate_raw  = 16'd0;
        temperature_raw = 16'd0;
        spo2_raw        = 16'd0;
        read_addr       = 3'd0;

        repeat (4) @(negedge clk);
        rst = 1'b0;

        // NORMAL
        apply_sample(72, 367, 98);

        // WARNING
        apply_sample(105, 372, 96);

        // DANGER - low SpO2
        apply_sample(78, 370, 91);

        // DANGER - high temperature
        apply_sample(82, 390, 97);

        // DANGER - multiple parameters
        apply_sample(130, 390, 90);

        // NORMAL
        apply_sample(65, 365, 99);

        // DANGER - low heart rate
        apply_sample(45, 366, 98);

        // WARNING - SpO2
        apply_sample(88, 370, 95);

        // INVALID SENSOR TEST
        @(negedge clk);
        heart_rate_raw  = 80;
        temperature_raw = 370;
        spo2_raw        = 110;
        sample_en       = 1'b1;

        @(negedge clk);
        sample_en = 1'b0;
        #1;

        $display(
            "[%0t ns] INVALID TEST | VALID=%b | STABLE=%b | ERROR=%b",
            $time, sensor_valid, sensor_stable, sensor_error
        );

        // STABILITY TEST
        @(negedge clk);
        heart_rate_raw  = 70;
        temperature_raw = 365;
        spo2_raw        = 98;
        sample_en       = 1'b1;

        @(negedge clk);
        sample_en = 1'b0;

        @(negedge clk);
        heart_rate_raw  = 150;
        temperature_raw = 370;
        spo2_raw        = 98;
        sample_en       = 1'b1;

        @(negedge clk);
        sample_en = 1'b0;
        #1;

        $display(
            "[%0t ns] STABILITY TEST | VALID=%b | STABLE=%b | ERROR=%b",
            $time, sensor_valid, sensor_stable, sensor_error
        );

        // HISTORICAL READBACK
        $display("========== HISTORICAL DATA ==========");

        for (i = 0; i < 8; i = i + 1) begin
            @(negedge clk);
            read_addr = i;
            #1;

            $display(
                "ADDR=%0d | HR=%0d | TEMP=%0d.%0d C | SpO2=%0d | STATUS=%b",
                i,
                read_heart_rate,
                read_temperature/10,
                read_temperature%10,
                read_spo2,
                read_status
            );
        end

        $display("========== SIMULATION COMPLETE ==========");

        #100;
        $finish;
    end

endmodule
