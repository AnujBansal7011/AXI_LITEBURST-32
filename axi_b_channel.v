module axi_b_channel(
    input wire clk, resetn,
    input wire make_response,
    input wire [1:0] response_in,
    output reg [1:0] s_bresp,
    output reg s_bvalid,
    input wire s_bready
);
    always @(posedge clk) begin
        if (!resetn) begin s_bresp <= 0; s_bvalid <= 0; end
        else begin
            if (make_response && !s_bvalid) begin s_bresp <= response_in; s_bvalid <= 1; end
            else if (s_bvalid && s_bready) s_bvalid <= 0;
        end
    end
endmodule
