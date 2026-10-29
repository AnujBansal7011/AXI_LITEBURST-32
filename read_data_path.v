module read_data_path #(parameter DATA_WIDTH=32)(
    input wire [DATA_WIDTH-1:0] mem_data,
    output wire [DATA_WIDTH-1:0] data_out
);
    assign data_out = mem_data;
endmodule
