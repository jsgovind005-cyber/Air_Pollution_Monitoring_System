`timescale 1ns/1ps
module air_pollution_tb;
    localparam int LOG_DEPTH = 16;
    localparam int CLKS_PER_BIT = 10;

    logic clk, rst, sample_en;
    logic [15:0] pm25_in, co2_in, temperature_in, humidity_in;
    logic [$clog2(LOG_DEPTH)-1:0] read_addr;
    logic [15:0] read_pm25, read_co2, read_temperature, read_humidity;
    logic [1:0] read_status;
    logic warning, danger;
    logic [1:0] status;
    logic [15:0] current_pm25, current_co2, current_temperature, current_humidity;
    logic [$clog2(LOG_DEPTH)-1:0] log_write_index;
    logic tx_serial, tx_busy, tx_done, packet_busy, packet_done;
    logic [3:0] packet_index;
    logic [7:0] tx_data;

    air_pollution_top #(
        .PM_WARN(35), .PM_DANGER(55), .CO2_WARN(1000), .CO2_DANGER(1500),
        .LOG_DEPTH(LOG_DEPTH), .CLKS_PER_BIT(CLKS_PER_BIT)
    ) dut (
        .clk(clk), .rst(rst), .sample_en(sample_en),
        .pm25_in(pm25_in), .co2_in(co2_in),
        .temperature_in(temperature_in), .humidity_in(humidity_in),
        .read_addr(read_addr), .read_pm25(read_pm25), .read_co2(read_co2),
        .read_temperature(read_temperature), .read_humidity(read_humidity),
        .read_status(read_status), .warning(warning), .danger(danger), .status(status),
        .current_pm25(current_pm25), .current_co2(current_co2),
        .current_temperature(current_temperature), .current_humidity(current_humidity),
        .log_write_index(log_write_index), .tx_serial(tx_serial), .tx_busy(tx_busy),
        .tx_done(tx_done), .packet_busy(packet_busy), .packet_done(packet_done),
        .packet_index(packet_index), .tx_data(tx_data)
    );

    always #5 clk = ~clk;

    task automatic apply_sample(input [15:0] pm, input [15:0] co2_value,
                                input [15:0] temp, input [15:0] hum);
        begin
            wait (!packet_busy);
            @(negedge clk);
            pm25_in = pm; co2_in = co2_value; temperature_in = temp; humidity_in = hum;
            sample_en = 1'b1;
            @(negedge clk);
            sample_en = 1'b0;
            @(negedge clk);
            $display("TIME=%0t ns | PM2.5=%0d | CO2=%0d | TEMP=%0d C | HUM=%0d %% | STATUS=%0d | WARNING=%b | DANGER=%b",
                     $time, current_pm25, current_co2, current_temperature,
                     current_humidity, status, warning, danger);
            wait (!packet_busy);
            $display("TIME=%0t ns | UART PACKET COMPLETE", $time);
        end
    endtask

    integer i;
    initial begin
        clk = 0; rst = 1; sample_en = 0;
        pm25_in = 0; co2_in = 0; temperature_in = 0; humidity_in = 0; read_addr = 0;
        #20 rst = 0;

        apply_sample(16'd20, 16'd450, 16'd28, 16'd60);
        apply_sample(16'd30, 16'd700, 16'd29, 16'd62);
        apply_sample(16'd40, 16'd800, 16'd30, 16'd64);
        apply_sample(16'd25, 16'd1200, 16'd31, 16'd65);
        apply_sample(16'd80, 16'd900, 16'd33, 16'd68);
        apply_sample(16'd30, 16'd1800, 16'd34, 16'd70);
        apply_sample(16'd100, 16'd2200, 16'd35, 16'd75);
        apply_sample(16'd15, 16'd400, 16'd27, 16'd55);

        $display("\n----- STORED HISTORY -----");
        for (i = 0; i < 8; i = i + 1) begin
            @(negedge clk); read_addr = i; #1;
            $display("ADDR=%0d | PM2.5=%0d | CO2=%0d | TEMP=%0d | HUM=%0d | STATUS=%0d",
                     read_addr, read_pm25, read_co2, read_temperature, read_humidity, read_status);
        end
        #100 $finish;
    end

    always @(posedge tx_done) begin
        $display("UART BYTE: packet_index=%0d data=0x%02h (%0d)", packet_index, tx_data, tx_data);
    end
endmodule
