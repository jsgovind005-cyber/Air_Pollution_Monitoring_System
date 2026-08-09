module uart_tx #(
    parameter integer CLK_FREQ_HZ = 10,
    parameter integer BAUD_RATE   = 2
)(
    input  logic        clk,
    input  logic        rst,
    input  logic [103:0] data_in,
    input  logic         data_valid,

    output logic        tx,
    output logic        busy
);
    /*
     * Raw packet serializer for simulation.
     * Each packet bit is held for BAUD_DIV clocks.
     *
     * This intentionally exposes a simple serial waveform.
     * A conventional 8-N-1 byte UART can replace this block
     * when targeting a physical FPGA/UART interface.
     */
    localparam integer BAUD_DIV = (CLK_FREQ_HZ / BAUD_RATE < 1)
                                ? 1 : (CLK_FREQ_HZ / BAUD_RATE);

    logic [103:0] shift_reg;
    integer baud_count;
    integer bit_index;

    always_ff @(posedge clk) begin
        if (rst) begin
            tx         <= 1'b1;
            busy       <= 1'b0;
            shift_reg  <= 104'd0;
            baud_count <= 0;
            bit_index  <= 0;
        end else begin
            if (!busy) begin
                tx <= 1'b1;
                if (data_valid) begin
                    shift_reg  <= data_in;
                    bit_index  <= 0;
                    baud_count <= 0;
                    busy       <= 1'b1;
                    tx         <= data_in[103];
                end
            end else begin
                if (baud_count >= BAUD_DIV-1) begin
                    baud_count <= 0;
                    if (bit_index >= 103) begin
                        busy <= 1'b0;
                        tx   <= 1'b1;
                    end else begin
                        bit_index <= bit_index + 1;
                        tx <= shift_reg[102-bit_index];
                    end
                end else begin
                    baud_count <= baud_count + 1;
                end
            end
        end
    end
endmodule
