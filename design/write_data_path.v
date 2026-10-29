module write_data_path #(parameter DATA_WIDTH=32)(
    input wire [DATA_WIDTH-1:0] wdata,
    input wire [DATA_WIDTH/8-1:0] wstrb,
    output wire [DATA_WIDTH-1:0] data_out,
    output wire [DATA_WIDTH/8-1:0] strb_out
);
    assign data_out = wdata;
    assign strb_out = wstrb;
endmodule
