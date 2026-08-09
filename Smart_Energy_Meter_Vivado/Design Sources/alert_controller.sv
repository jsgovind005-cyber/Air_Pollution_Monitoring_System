module alert_controller (
    input  logic clk,
    input  logic rst,
    input  logic warning,
    input  logic danger,

    output logic [1:0] alert_code,
    output logic       alert
);
    typedef enum logic [1:0] {
        NORMAL  = 2'b00,
        WARNING = 2'b01,
        DANGER  = 2'b10
    } alert_state_t;

    alert_state_t state, next_state;

    always_comb begin
        case (1'b1)
            danger:  next_state = DANGER;
            warning: next_state = WARNING;
            default: next_state = NORMAL;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst)
            state <= NORMAL;
        else
            state <= next_state;
    end

    always_comb begin
        alert_code = state;
        alert = (state != NORMAL);
    end
endmodule
