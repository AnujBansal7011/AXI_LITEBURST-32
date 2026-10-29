module axi_r_channel #(parameter DATA_WIDTH=32)(
    input wire clk, resetn,
    input wire make_response,
    input wire [DATA_WIDTH-1:0] data_in,
    input wire [1:0] response_in,
    output reg [DATA_WIDTH-1:0] s_rdata,
    output reg [1:0] s_rresp,
    output reg s_rvalid,
    input wire s_rready
);
    always @(posedge clk) begin
        if (!resetn) begin s_rdata <= 0; s_rresp <= 0; s_rvalid <= 0; end
        else begin
            if (make_response && !s_rvalid) begin
                s_rdata <= data_in; s_rresp <= response_in; s_rvalid <= 1;
            end else if (s_rvalid && s_rready) s_rvalid <= 0;
        end
    end
endmodule
