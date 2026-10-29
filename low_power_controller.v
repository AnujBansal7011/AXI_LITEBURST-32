module low_power_controller #(
    parameter COUNTER_WIDTH = 8
)(
    input wire clk,
    input wire resetn,
    input wire activity,
    input wire enable,
    input wire [COUNTER_WIDTH-1:0] idle_threshold,
    output reg idle,
    output wire clock_enable
);
    reg [COUNTER_WIDTH-1:0] idle_count;
    always @(posedge clk) begin
        if (!resetn) begin
            idle_count <= 0;
            idle <= 1'b0;
        end else if (!enable || activity) begin
            idle_count <= 0;
            idle <= 1'b0;
        end else if (!idle) begin
            if (idle_threshold == 0 || idle_count >= idle_threshold - 1'b1)
                idle <= 1'b1;
            else
                idle_count <= idle_count + 1'b1;
        end
    end
    assign clock_enable = !idle || activity;
endmodule
