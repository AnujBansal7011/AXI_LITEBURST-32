module axi_w_channel #(parameter DATA_WIDTH=32)(
    input wire clk, resetn,
    input wire [DATA_WIDTH-1:0] s_wdata,
    input wire [DATA_WIDTH/8-1:0] s_wstrb,
    input wire s_wvalid,
    output wire s_wready,
    output reg w_pending,
    output reg [DATA_WIDTH-1:0] wdata_q,
    output reg [DATA_WIDTH/8-1:0] wstrb_q,
    input wire w_consume
);
    assign s_wready = resetn && !w_pending;
    always @(posedge clk) begin
        if (!resetn) begin w_pending <= 0; wdata_q <= 0; wstrb_q <= 0; end
        else begin
            if (s_wvalid && s_wready) begin
                w_pending <= 1; wdata_q <= s_wdata; wstrb_q <= s_wstrb;
            end else if (w_consume && w_pending) w_pending <= 0;
        end
    end
endmodule
