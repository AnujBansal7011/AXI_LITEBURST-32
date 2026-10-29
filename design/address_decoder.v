module address_decoder #(
    parameter ADDR_WIDTH = 8,
    parameter MEM_WORDS = 16
)(
    input  wire [ADDR_WIDTH-1:0] addr,
    output wire                  addr_valid,
    output wire [$clog2(MEM_WORDS)-1:0] word_index
);
    wire aligned = (addr[1:0] == 2'b00);
    wire in_range = (addr < (MEM_WORDS * 4));
    assign addr_valid = aligned && in_range;
    assign word_index = addr[$clog2(MEM_WORDS)+1:2];
endmodule
