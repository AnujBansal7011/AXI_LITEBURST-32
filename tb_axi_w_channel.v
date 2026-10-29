`timescale 1ns/1ps
module tb_axi_w_channel;
 reg clk=0; always #5 clk=~clk; reg resetn=0; reg [31:0] s_wdata=0; reg [3:0] s_wstrb=0; reg s_wvalid=0,w_consume=0;
 wire s_wready,w_pending; wire [31:0] wdata_q; wire [3:0] wstrb_q; integer e=0;
 axi_w_channel dut(
        .clk(clk),
        .s_wdata(s_wdata),
        .s_wstrb(s_wstrb),
        .s_wvalid(s_wvalid),
        .s_wready(s_wready),
        .w_pending(w_pending),
        .wdata_q(wdata_q),
        .wstrb_q(wstrb_q),
        .w_consume(w_consume)
    );
 initial begin repeat(2) @(posedge clk); resetn=1;
 @(negedge clk); s_wdata=32'hCAFEBABE;s_wstrb=4'b1010;s_wvalid=1;
 @(posedge clk); #1; if(!w_pending || wdata_q!=32'hCAFEBABE || wstrb_q!=4'b1010)e=e+1;
 @(negedge clk); s_wvalid=0; w_consume=1;
 @(posedge clk); #1; if(w_pending)e=e+1;
 $display("axi_w_channel: %s (errors=%0d)",e==0?"PASS":"FAIL",e);$finish;end
endmodule
