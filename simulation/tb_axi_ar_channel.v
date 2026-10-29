`timescale 1ns/1ps
module tb_axi_ar_channel;
 reg clk=0; always #5 clk=~clk; reg resetn=0; reg [7:0] s_araddr=0; reg s_arvalid=0,ar_consume=0;
 wire s_arready,ar_pending; wire [7:0] araddr_q; integer e=0;
 axi_ar_channel dut(
        .clk(clk),
        .s_araddr(s_araddr),
        .s_arvalid(s_arvalid),
        .s_arready(s_arready),
        .ar_pending(ar_pending),
        .araddr_q(araddr_q),
        .ar_consume(ar_consume)
    );
 initial begin repeat(2) @(posedge clk); resetn=1;
 @(negedge clk); s_araddr=8'h0C;s_arvalid=1;
 @(posedge clk); #1; if(!ar_pending || araddr_q!=8'h0C)e=e+1;
 @(negedge clk); s_arvalid=0; ar_consume=1;
 @(posedge clk); #1; if(ar_pending)e=e+1;
 $display("axi_ar_channel: %s (errors=%0d)",e==0?"PASS":"FAIL",e);$finish;end
endmodule
