module sensor_packetizer #(
    parameter int PM_WARN    = 35,
    parameter int PM_DANGER  = 55,
    parameter int CO2_WARN   = 1000,
    parameter int CO2_DANGER = 1500
)(
    input  logic        clk,
    input  logic        rst,
    input  logic        sample_en,
    input  logic [15:0] pm25,
    input  logic [15:0] co2,
    input  logic [15:0] temperature,
    input  logic [15:0] humidity,
    input  logic        uart_busy,
    input  logic        uart_done,
    output logic [7:0]  tx_data,
    output logic        tx_start,
    output logic        packet_busy,
    output logic        packet_done,
    output logic [3:0]  packet_index
);
    localparam logic [1:0] STATUS_NORMAL = 2'd0;
    localparam logic [1:0] STATUS_WARNING = 2'd1;
    localparam logic [1:0] STATUS_DANGER = 2'd2;

    logic [15:0] pm25_reg, co2_reg, temp_reg, hum_reg;
    logic [1:0] status_reg;
    logic sample_pending;

    function automatic [1:0] calc_status(input logic [15:0] pm, input logic [15:0] co);
        begin
            if ((pm >= PM_DANGER) || (co >= CO2_DANGER)) calc_status = STATUS_DANGER;
            else if ((pm >= PM_WARN) || (co >= CO2_WARN)) calc_status = STATUS_WARNING;
            else calc_status = STATUS_NORMAL;
        end
    endfunction

    function automatic [7:0] get_byte(input logic [3:0] idx);
        begin
            case (idx)
                4'd0:  get_byte = 8'hA5;
                4'd1:  get_byte = 8'h5A;
                4'd2:  get_byte = pm25_reg[7:0];
                4'd3:  get_byte = pm25_reg[15:8];
                4'd4:  get_byte = co2_reg[7:0];
                4'd5:  get_byte = co2_reg[15:8];
                4'd6:  get_byte = temp_reg[7:0];
                4'd7:  get_byte = temp_reg[15:8];
                4'd8:  get_byte = hum_reg[7:0];
                4'd9:  get_byte = hum_reg[15:8];
                4'd10: get_byte = {6'd0, status_reg};
                4'd11: get_byte = pm25_reg[7:0] ^ pm25_reg[15:8] ^
                                  co2_reg[7:0] ^ co2_reg[15:8] ^
                                  temp_reg[7:0] ^ temp_reg[15:8] ^
                                  hum_reg[7:0] ^ hum_reg[15:8] ^
                                  {6'd0, status_reg};
                default: get_byte = 8'h00;
            endcase
        end
    endfunction

    always_comb tx_data = get_byte(packet_index);

    always_ff @(posedge clk) begin
        if (rst) begin
            pm25_reg <= 0; co2_reg <= 0; temp_reg <= 0; hum_reg <= 0;
            status_reg <= STATUS_NORMAL;
            sample_pending <= 1'b0;
            packet_busy <= 1'b0;
            packet_done <= 1'b0;
            packet_index <= 4'd0;
            tx_start <= 1'b0;
        end else begin
            tx_start <= 1'b0;
            packet_done <= 1'b0;

            if (sample_en && !packet_busy) begin
                pm25_reg <= pm25;
                co2_reg <= co2;
                temp_reg <= temperature;
                hum_reg <= humidity;
                status_reg <= calc_status(pm25, co2);
                sample_pending <= 1'b1;
            end

            if (sample_pending && !packet_busy && !uart_busy) begin
                packet_busy <= 1'b1;
                packet_index <= 4'd0;
                sample_pending <= 1'b0;
                tx_start <= 1'b1;
            end else if (packet_busy && uart_done) begin
                if (packet_index == 4'd11) begin
                    packet_busy <= 1'b0;
                    packet_done <= 1'b1;
                    packet_index <= 4'd0;
                end else begin
                    packet_index <= packet_index + 1'b1;
                    tx_start <= 1'b1;
                end
            end
        end
    end
endmodule
