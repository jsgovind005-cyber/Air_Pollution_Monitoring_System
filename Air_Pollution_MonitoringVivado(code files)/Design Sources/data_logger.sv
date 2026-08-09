module data_logger #(
    parameter int DEPTH = 16
)(
    input  logic        clk,
    input  logic        rst,
    input  logic        sample_en,
    input  logic [15:0] pm25,
    input  logic [15:0] co2,
    input  logic [15:0] temperature,
    input  logic [15:0] humidity,
    input  logic [1:0]  status,
    input  logic [$clog2(DEPTH)-1:0] rd_addr,
    output logic [15:0] rd_pm25,
    output logic [15:0] rd_co2,
    output logic [15:0] rd_temperature,
    output logic [15:0] rd_humidity,
    output logic [1:0]  rd_status,
    output logic [$clog2(DEPTH)-1:0] write_index
);
    logic [15:0] pm25_mem [0:DEPTH-1];
    logic [15:0] co2_mem  [0:DEPTH-1];
    logic [15:0] temp_mem [0:DEPTH-1];
    logic [15:0] hum_mem  [0:DEPTH-1];
    logic [1:0]  stat_mem [0:DEPTH-1];
    integer i;

    always_ff @(posedge clk) begin
        if (rst) begin
            write_index <= '0;
            for (i = 0; i < DEPTH; i = i + 1) begin
                pm25_mem[i] <= 16'd0;
                co2_mem[i] <= 16'd0;
                temp_mem[i] <= 16'd0;
                hum_mem[i] <= 16'd0;
                stat_mem[i] <= 2'd0;
            end
        end else if (sample_en) begin
            pm25_mem[write_index] <= pm25;
            co2_mem[write_index] <= co2;
            temp_mem[write_index] <= temperature;
            hum_mem[write_index] <= humidity;
            stat_mem[write_index] <= status;
            if (write_index == DEPTH-1)
                write_index <= '0;
            else
                write_index <= write_index + 1'b1;
        end
    end

    always_comb begin
        rd_pm25 = pm25_mem[rd_addr];
        rd_co2 = co2_mem[rd_addr];
        rd_temperature = temp_mem[rd_addr];
        rd_humidity = hum_mem[rd_addr];
        rd_status = stat_mem[rd_addr];
    end
endmodule
