`timescale 1ns/1ps
module tb_axi_r_channel;
 reg clk=0; always #5 clk=~clk; reg resetn=0,make_response=0,s_rready=0; reg [31:0] data_in=0; reg [1:0] response_in=0;
 wire [31:0] s_rdata; wire [1:0] s_rresp; wire s_rvalid; integer e=0;
 axi_r_channel dut(
        .clk(clk),
        .make_response(make_response),
        .data_in(data_in),
        .response_in(response_in),
        .s_rdata(s_rdata),
        .s_rresp(s_rresp),
        .s_rvalid(s_rvalid),
        .s_rready(s_rready)
    );
 initial begin repeat(2) @(posedge clk); resetn=1;
 @(negedge clk); make_response=1; data_in=32'hDEADBEEF; response_in=0;
 @(posedge clk); #1; if(!s_rvalid || s_rdata!=32'hDEADBEEF)e=e+1;
 repeat(2) @(posedge clk); #1; if(!s_rvalid)e=e+1;
 @(negedge clk); make_response=0; s_rready=1;
 @(posedge clk); #1; if(s_rvalid)e=e+1;
 $display("axi_r_channel: %s (errors=%0d)",e==0?"PASS":"FAIL",e);$finish;end
endmodule
