module axi_ar_channel #(parameter ADDR_WIDTH=8)(
    input wire clk, resetn,
    input wire [ADDR_WIDTH-1:0] s_araddr,
    input wire s_arvalid,
    output wire s_arready,
    output reg ar_pending,
    output reg [ADDR_WIDTH-1:0] araddr_q,
    input wire ar_consume
);
    assign s_arready = resetn && !ar_pending;
    always @(posedge clk) begin
        if (!resetn) begin ar_pending <= 0; araddr_q <= 0; end
        else begin
            if (s_arvalid && s_arready) begin ar_pending <= 1; araddr_q <= s_araddr; end
            else if (ar_consume && ar_pending) ar_pending <= 0;
        end
    end
endmodule
