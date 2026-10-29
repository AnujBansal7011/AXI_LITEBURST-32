module axi_aw_channel #(parameter ADDR_WIDTH=8)(
    input wire clk, resetn,
    input wire [ADDR_WIDTH-1:0] s_awaddr,
    input wire s_awvalid,
    output wire s_awready,
    output reg aw_pending,
    output reg [ADDR_WIDTH-1:0] awaddr_q,
    input wire aw_consume
);
    assign s_awready = resetn && !aw_pending;
    always @(posedge clk) begin
        if (!resetn) begin aw_pending <= 0; awaddr_q <= 0; end
        else begin
            if (s_awvalid && s_awready) begin aw_pending <= 1; awaddr_q <= s_awaddr; end
            else if (aw_consume && aw_pending) aw_pending <= 0;
        end
    end
endmodule
