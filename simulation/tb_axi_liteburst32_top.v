`timescale 1ns/1ps
module tb_axi_liteburst32_top;
    reg clk=0; always #5 clk=~clk;
    reg resetn=0;
    reg [7:0] s_awaddr=0; reg s_awvalid=0; wire s_awready;
    reg [31:0] s_wdata=0; reg [3:0] s_wstrb=4'hF; reg s_wvalid=0; wire s_wready;
    wire [1:0] s_bresp; wire s_bvalid; reg s_bready=0;
    reg [7:0] s_araddr=0; reg s_arvalid=0; wire s_arready;
    wire [31:0] s_rdata; wire [1:0] s_rresp; wire s_rvalid; reg s_rready=0;
    reg low_power_enable=1; reg [7:0] idle_threshold=8'd5; wire low_power_idle;
    integer tests=0, errors=0;
    axi_liteburst32_top dut(
        .clk(clk),
        .resetn(resetn),
        .s_awaddr(s_awaddr),
        .s_awvalid(s_awvalid),
        .s_awready(s_awready),
        .s_wdata(s_wdata),
        .s_wstrb(s_wstrb),
        .s_wvalid(s_wvalid),
        .s_wready(s_wready),
        .s_bresp(s_bresp),
        .s_bvalid(s_bvalid),
        .s_bready(s_bready),
        .s_araddr(s_araddr),
        .s_arvalid(s_arvalid),
        .s_arready(s_arready),
        .s_rdata(s_rdata),
        .s_rresp(s_rresp),
        .s_rvalid(s_rvalid),
        .s_rready(s_rready),
        .low_power_enable(low_power_enable),
        .idle_threshold(idle_threshold),
        .low_power_idle(low_power_idle)
    );

    task tick; begin @(posedge clk); #1; end endtask
    task write_aw_first(input [7:0] addr, input [31:0] data, input [3:0] strb);
    begin
        @(negedge clk); s_awaddr=addr; s_awvalid=1;
        while (!s_awready) tick;
        tick; @(negedge clk); s_awvalid=0;
        repeat(2) tick;
        s_wdata=data; s_wstrb=strb; s_wvalid=1;
        while (!s_wready) tick;
        tick; @(negedge clk); s_wvalid=0; s_bready=0;
        wait(s_bvalid); tick;
        tests=tests+1;
        if (s_bresp !== 2'b00) begin $display("FAIL write response addr=%h resp=%b",addr,s_bresp); errors=errors+1; end
        @(negedge clk); s_bready=1; tick; @(negedge clk); s_bready=0;
    end endtask
    task write_w_first(input [7:0] addr, input [31:0] data);
    begin
        @(negedge clk); s_wdata=data; s_wstrb=4'hF; s_wvalid=1;
        while (!s_wready) tick;
        tick; @(negedge clk); s_wvalid=0;
        repeat(2) tick;
        s_awaddr=addr; s_awvalid=1;
        while (!s_awready) tick;
        tick; @(negedge clk); s_awvalid=0; s_bready=0;
        wait(s_bvalid); tick; tests=tests+1;
        if (s_bresp !== 2'b00) begin $display("FAIL W-first write response"); errors=errors+1; end
        @(negedge clk); s_bready=1; tick; @(negedge clk); s_bready=0;
    end endtask
    task read_check(input [7:0] addr, input [31:0] expected, input [1:0] exp_resp);
    begin
        @(negedge clk); s_araddr=addr; s_arvalid=1;
        while (!s_arready) tick;
        tick; @(negedge clk); s_arvalid=0; s_rready=0;
        wait(s_rvalid); #1; tests=tests+1;
        if (s_rresp !== exp_resp) begin $display("FAIL read resp addr=%h got=%b expected=%b",addr,s_rresp,exp_resp); errors=errors+1; end
        if (s_rdata !== expected) begin $display("FAIL read data addr=%h got=%h expected=%h",addr,s_rdata,expected); errors=errors+1; end
        repeat(2) tick; // response must remain valid while backpressured
        if (!s_rvalid) begin $display("FAIL RVALID dropped during backpressure"); errors=errors+1; end
        @(negedge clk); s_rready=1; tick; @(negedge clk); s_rready=0;
    end endtask

    initial begin
        $dumpfile("tb_axi_liteburst32_top.vcd"); $dumpvars(0,tb_axi_liteburst32_top);
        repeat(3) tick; resetn=1; tick;
        write_aw_first(8'h00,32'h12345678,4'hF);
        read_check(8'h00,32'h12345678,2'b00);
        write_w_first(8'h00,32'hAABBCCDD);
        read_check(8'h00,32'hAABBCCDD,2'b00);
        write_aw_first(8'h00,32'h11223344,4'b0011);
        read_check(8'h00,32'hAABB3344,2'b00);
        // Invalid unaligned address should return SLVERR.
        @(negedge clk); s_awaddr=8'h01; s_awvalid=1; s_wdata=32'hDEADBEEF; s_wstrb=4'hF; s_wvalid=1;
        while (!s_awready || !s_wready) tick;
        tick; @(negedge clk); s_awvalid=0; s_wvalid=0; s_bready=0;
        wait(s_bvalid); #1; tests=tests+1;
        if (s_bresp !== 2'b10) begin $display("FAIL invalid write expected SLVERR got %b",s_bresp); errors=errors+1; end
        @(negedge clk); s_bready=1; tick; @(negedge clk); s_bready=0;
        read_check(8'h01,32'h00000000,2'b10);
        repeat(10) tick;
        tests=tests+1;
        if (!low_power_idle) begin $display("FAIL low power idle did not assert"); errors=errors+1; end
        $display("SUMMARY: tests=%0d errors=%0d",tests,errors);
        if (errors==0) $display("PASS: top-level testbench checks completed");
        else $display("FAIL: top-level testbench has errors");
        $finish;
    end
endmodule
