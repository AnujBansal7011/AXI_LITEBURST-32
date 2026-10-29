module reg_mem_bank #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 8,
    parameter MEM_WORDS = 16
)(
    input  wire                  clk,
    input  wire                  resetn,
    input  wire                  wr_en,
    input  wire [$clog2(MEM_WORDS)-1:0] wr_index,
    input  wire [DATA_WIDTH-1:0] wr_data,
    input  wire [DATA_WIDTH/8-1:0] wr_strb,
    input  wire                  rd_en,
    input  wire [$clog2(MEM_WORDS)-1:0] rd_index,
    output reg  [DATA_WIDTH-1:0] rd_data
);
    reg [DATA_WIDTH-1:0] mem [0:MEM_WORDS-1];
    integer i, b;
    always @(posedge clk) begin
        if (!resetn) begin
            rd_data <= {DATA_WIDTH{1'b0}};
            for (i = 0; i < MEM_WORDS; i = i + 1)
                mem[i] <= {DATA_WIDTH{1'b0}};
        end else begin
            if (wr_en) begin
                for (b = 0; b < DATA_WIDTH/8; b = b + 1)
                    if (wr_strb[b])
                        mem[wr_index][8*b +: 8] <= wr_data[8*b +: 8];
            end
            if (rd_en)
                rd_data <= mem[rd_index];
        end
    end
endmodule
