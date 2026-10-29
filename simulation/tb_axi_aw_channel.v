`timescale 1ns/1ps
module tb_axi_aw_channel;
 reg clk=0; always #5 clk=~clk; reg resetn=0; reg [7:0] s_awaddr=0; reg s_awvalid=0,aw_consume=0;
 wire s_awready,aw_pending; wire [7:0] awaddr_q; integer e=0;
 axi_aw_channel dut(
        .clk(clk),
        .s_awaddr(s_awaddr),
        .s_awvalid(s_awvalid),
        .s_awready(s_awready),
        .aw_pending(aw_pending),
        .awaddr_q(awaddr_q),
        .aw_consume(aw_consume)
    );
 initial begin repeat(2) @(posedge clk); resetn=1;
 @(negedge clk); s_awaddr=8'h24;s_awvalid=1;
 @(posedge clk); #1; if(!aw_pending || awaddr_q!=8'h24)e=e+1;
 @(negedge clk); s_awvalid=0; aw_consume=1;
 @(posedge clk); #1; if(aw_pending)e=e+1;
 $display("axi_aw_channel: %s (errors=%0d)",e==0?"PASS":"FAIL",e);$finish;end
endmodule
