`timescale 1ns/1ps
module tb_axi_b_channel;
 reg clk=0; always #5 clk=~clk; reg resetn=0,make_response=0,s_bready=0; reg [1:0] response_in=0;
 wire [1:0] s_bresp; wire s_bvalid; integer e=0;
 axi_b_channel dut(
        .clk(clk),
        .make_response(make_response),
        .response_in(response_in),
        .s_bresp(s_bresp),
        .s_bvalid(s_bvalid),
        .s_bready(s_bready)
    );
 initial begin repeat(2) @(posedge clk); resetn=1;
 @(negedge clk); make_response=1; response_in=2'b10;
 @(posedge clk); #1; if(!s_bvalid || s_bresp!=2'b10)e=e+1;
 @(negedge clk); make_response=0; s_bready=1;
 @(posedge clk); #1; if(s_bvalid)e=e+1;
 $display("axi_b_channel: %s (errors=%0d)",e==0?"PASS":"FAIL",e);$finish;end
endmodule
