module burst_controller #(
    parameter ADDR_WIDTH = 8,
    parameter LEN_WIDTH = 5
)(
    input wire clk,
    input wire resetn,
    input wire start,
    input wire [ADDR_WIDTH-1:0] start_addr,
    input wire [LEN_WIDTH-1:0] burst_len, // number of beats: 1..16
    input wire beat_done,
    output reg active,
    output reg [ADDR_WIDTH-1:0] beat_addr,
    output reg [LEN_WIDTH-1:0] beat_index,
    output reg last
);
    reg [LEN_WIDTH-1:0] len_q;
    always @(posedge clk) begin
        if (!resetn) begin
            active <= 1'b0;
            beat_addr <= 0;
            beat_index <= 0;
            len_q <= 0;
            last <= 1'b0;
        end else begin
            if (start && !active) begin
                if (burst_len >= 1 && burst_len <= 16) begin
                    active <= 1'b1;
                    beat_addr <= {start_addr[ADDR_WIDTH-1:2], 2'b00};
                    beat_index <= 0;
                    len_q <= burst_len;
                    last <= (burst_len == 1);
                end
            end else if (active && beat_done) begin
                if (beat_index + 1'b1 >= len_q) begin
                    active <= 1'b0;
                    last <= 1'b0;
                end else begin
                    beat_index <= beat_index + 1'b1;
                    beat_addr <= beat_addr + 4;
                    last <= (beat_index + 2 >= len_q);
                end
            end
        end
    end
endmodule
