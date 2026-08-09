module packetizer (
    input  logic        clk,
    input  logic        rst,
    input  logic        update,

    input  logic [15:0] voltage_x10,
    input  logic [15:0] current_x100,
    input  logic [31:0] power_w,
    input  logic [31:0] energy_wh,
    input  logic [31:0] cost_rupees,
    input  logic [1:0]  alert_code,

    output logic [103:0] packet,
    output logic         packet_valid
);
    /*
     * Packet = 13 bytes:
     * AA | VV VV | II II | PP PP | EE EE | CC CC | alert | 55
     *
     * This is an internal simulation protocol, not a cloud protocol.
     */
    always_ff @(posedge clk) begin
        if (rst) begin
            packet       <= 104'd0;
            packet_valid <= 1'b0;
        end else begin
            packet_valid <= 1'b0;
            if (update) begin
                packet <= {
                    8'hAA,
                    voltage_x10,
                    current_x100,
                    power_w[15:0],
                    energy_wh[15:0],
                    cost_rupees[15:0],
                    6'd0,
                    alert_code,
                    8'h55
                };
                packet_valid <= 1'b1;
            end
        end
    end
endmodule
