module threshold_detector #(
    parameter int PM_WARN    = 35,
    parameter int PM_DANGER  = 55,
    parameter int CO2_WARN   = 1000,
    parameter int CO2_DANGER = 1500
)(
    input  logic [15:0] pm25,
    input  logic [15:0] co2,
    output logic        warning,
    output logic        danger,
    output logic [1:0]  status
);
    localparam logic [1:0] STATUS_NORMAL  = 2'd0;
    localparam logic [1:0] STATUS_WARNING = 2'd1;
    localparam logic [1:0] STATUS_DANGER  = 2'd2;

    always_comb begin
        warning = 1'b0;
        danger  = 1'b0;
        status  = STATUS_NORMAL;
        if ((pm25 >= PM_DANGER) || (co2 >= CO2_DANGER)) begin
            danger = 1'b1;
            status = STATUS_DANGER;
        end else if ((pm25 >= PM_WARN) || (co2 >= CO2_WARN)) begin
            warning = 1'b1;
            status = STATUS_WARNING;
        end
    end
endmodule
