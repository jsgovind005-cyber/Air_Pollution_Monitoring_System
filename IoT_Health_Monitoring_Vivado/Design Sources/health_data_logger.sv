`timescale 1ns/1ps

module health_data_logger #(
    parameter integer DEPTH      = 8,
    parameter integer ADDR_WIDTH = 3
)(
    input  logic                  clk,
    input  logic                  rst,
    input  logic                  sample_en,

    input  logic [15:0]           heart_rate,
    input  logic [15:0]           temperature,
    input  logic [15:0]           spo2,
    input  logic [1:0]            status,

    input  logic [ADDR_WIDTH-1:0] read_addr,

    output logic [15:0]           read_heart_rate,
    output logic [15:0]           read_temperature,
    output logic [15:0]           read_spo2,
    output logic [1:0]            read_status,

    output logic [ADDR_WIDTH-1:0] write_addr
);

    logic [15:0] heart_rate_mem [0:DEPTH-1];
    logic [15:0] temperature_mem[0:DEPTH-1];
    logic [15:0] spo2_mem       [0:DEPTH-1];
    logic [1:0]  status_mem     [0:DEPTH-1];

    integer i;

    always_ff @(posedge clk) begin
        if (rst) begin
            write_addr <= '0;

            for (i = 0; i < DEPTH; i = i + 1) begin
                heart_rate_mem[i]  <= 16'd0;
                temperature_mem[i] <= 16'd0;
                spo2_mem[i]        <= 16'd0;
                status_mem[i]      <= 2'b00;
            end
        end
        else if (sample_en) begin
            heart_rate_mem[write_addr]  <= heart_rate;
            temperature_mem[write_addr] <= temperature;
            spo2_mem[write_addr]        <= spo2;
            status_mem[write_addr]      <= status;

            if (write_addr == DEPTH-1)
                write_addr <= '0;
            else
                write_addr <= write_addr + 1'b1;
        end
    end

    always_comb begin
        read_heart_rate  = heart_rate_mem[read_addr];
        read_temperature = temperature_mem[read_addr];
        read_spo2        = spo2_mem[read_addr];
        read_status      = status_mem[read_addr];
    end

endmodule
