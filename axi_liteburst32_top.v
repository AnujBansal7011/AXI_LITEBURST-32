module axi_liteburst32_top #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32,
    parameter MEM_WORDS = 16
)(
    input wire clk, resetn,
    input wire [ADDR_WIDTH-1:0] s_awaddr,
    input wire s_awvalid,
    output wire s_awready,
    input wire [DATA_WIDTH-1:0] s_wdata,
    input wire [DATA_WIDTH/8-1:0] s_wstrb,
    input wire s_wvalid,
    output wire s_wready,
    output wire [1:0] s_bresp,
    output wire s_bvalid,
    input wire s_bready,
    input wire [ADDR_WIDTH-1:0] s_araddr,
    input wire s_arvalid,
    output wire s_arready,
    output wire [DATA_WIDTH-1:0] s_rdata,
    output wire [1:0] s_rresp,
    output wire s_rvalid,
    input wire s_rready,
    input wire low_power_enable,
    input wire [7:0] idle_threshold,
    output wire low_power_idle
);
    localparam INDEX_WIDTH = $clog2(MEM_WORDS);
    wire aw_pending, w_pending, ar_pending;
    wire [ADDR_WIDTH-1:0] awaddr_q, araddr_q;
    wire [DATA_WIDTH-1:0] wdata_q;
    wire [DATA_WIDTH/8-1:0] wstrb_q;
    wire aw_consume, w_consume, ar_consume;
    wire wr_valid, rd_valid;
    wire [INDEX_WIDTH-1:0] wr_index, rd_index;
    wire [DATA_WIDTH-1:0] mem_rdata;
    wire mem_wr_en, mem_rd_en;
    wire [1:0] wr_resp, rd_resp;
    wire make_b, make_r;
    wire [DATA_WIDTH-1:0] wdata_path;
    wire [DATA_WIDTH/8-1:0] wstrb_path;
    wire [DATA_WIDTH-1:0] rdata_path;
    wire activity, clock_enable;

    axi_aw_channel #(.ADDR_WIDTH(ADDR_WIDTH)) awch(
        .clk(clk), .resetn(resetn), .s_awaddr(s_awaddr), .s_awvalid(s_awvalid),
        .s_awready(s_awready), .aw_pending(aw_pending), .awaddr_q(awaddr_q), .aw_consume(aw_consume)
    );
    axi_w_channel #(.DATA_WIDTH(DATA_WIDTH)) wch(
        .clk(clk), .resetn(resetn), .s_wdata(s_wdata), .s_wstrb(s_wstrb), .s_wvalid(s_wvalid),
        .s_wready(s_wready), .w_pending(w_pending), .wdata_q(wdata_q), .wstrb_q(wstrb_q), .w_consume(w_consume)
    );
    axi_ar_channel #(.ADDR_WIDTH(ADDR_WIDTH)) arch(
        .clk(clk), .resetn(resetn), .s_araddr(s_araddr), .s_arvalid(s_arvalid),
        .s_arready(s_arready), .ar_pending(ar_pending), .araddr_q(araddr_q), .ar_consume(ar_consume)
    );

    address_decoder #(.ADDR_WIDTH(ADDR_WIDTH), .MEM_WORDS(MEM_WORDS)) wdec(
        .addr(awaddr_q), .addr_valid(wr_valid), .word_index(wr_index)
    );
    address_decoder #(.ADDR_WIDTH(ADDR_WIDTH), .MEM_WORDS(MEM_WORDS)) rdec(
        .addr(araddr_q), .addr_valid(rd_valid), .word_index(rd_index)
    );
    write_data_path #(.DATA_WIDTH(DATA_WIDTH)) wdp(.wdata(wdata_q), .wstrb(wstrb_q), .data_out(wdata_path), .strb_out(wstrb_path));
    read_data_path #(.DATA_WIDTH(DATA_WIDTH)) rdp(.mem_data(mem_rdata), .data_out(rdata_path));
    response_generator wrespgen(.valid_address(wr_valid), .response(wr_resp));
    response_generator rrespgen(.valid_address(rd_valid), .response(rd_resp));

    assign mem_wr_en = resetn && aw_pending && w_pending && !s_bvalid && wr_valid;
    assign mem_rd_en = resetn && ar_pending && !s_rvalid && rd_valid;
    assign make_b = resetn && aw_pending && w_pending && !s_bvalid;
    assign make_r = resetn && ar_pending && !s_rvalid;

    reg [1:0] bresp_reg;
    reg [1:0] rresp_reg;
    axi_b_channel bch(.clk(clk), .resetn(resetn), .make_response(make_b),
        .response_in(wr_resp), .s_bresp(s_bresp), .s_bvalid(s_bvalid), .s_bready(s_bready));
    axi_r_channel #(.DATA_WIDTH(DATA_WIDTH)) rch(.clk(clk), .resetn(resetn),
        .make_response(make_r), .data_in(rd_valid ? rdata_path : {DATA_WIDTH{1'b0}}),
        .response_in(rd_resp), .s_rdata(s_rdata), .s_rresp(s_rresp),
        .s_rvalid(s_rvalid), .s_rready(s_rready));

    // Consume captured addresses/data only after response handshake. Invalid writes return SLVERR.
    assign aw_consume = s_bvalid && s_bready;
    assign w_consume  = s_bvalid && s_bready;
    assign ar_consume = s_rvalid && s_rready;

    reg [INDEX_WIDTH-1:0] rd_index_q;
    wire [INDEX_WIDTH-1:0] bank_rd_index = rd_valid ? rd_index : rd_index_q;
    always @(posedge clk) begin
        if (!resetn) rd_index_q <= 0;
        else if (ar_pending && !s_rvalid) rd_index_q <= rd_index;
    end
    reg [INDEX_WIDTH-1:0] wr_index_q;
    always @(posedge clk) begin
        if (!resetn) wr_index_q <= 0;
        else if (aw_pending && w_pending && !s_bvalid) wr_index_q <= wr_index;
    end
    // Small internal register bank. Read data is selected combinationally and
    // captured by the R channel when the read response is created.
    reg [DATA_WIDTH-1:0] mem [0:MEM_WORDS-1];
    integer i, b;
    always @(posedge clk) begin
        if (!resetn) begin
            for (i=0;i<MEM_WORDS;i=i+1) mem[i] <= 0;
        end else begin
            if (mem_wr_en) begin
                for (b=0;b<DATA_WIDTH/8;b=b+1)
                    if (wstrb_path[b]) mem[wr_index][8*b +: 8] <= wdata_path[8*b +: 8];
            end
        end
    end
    assign mem_rdata = (rd_valid && ar_pending) ? mem[rd_index] : {DATA_WIDTH{1'b0}};

    low_power_controller lp(.clk(clk), .resetn(resetn),
        .activity(s_awvalid || s_wvalid || s_arvalid || aw_pending || w_pending || ar_pending || s_bvalid || s_rvalid),
        .enable(low_power_enable), .idle_threshold(idle_threshold), .idle(low_power_idle), .clock_enable(clock_enable));

    // These signals are intentionally retained for debug visibility in RTL viewers.
    wire unused_clock_enable = clock_enable;
endmodule
