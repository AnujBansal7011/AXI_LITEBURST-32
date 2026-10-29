`timescale 1ns/1ps
module tb_low_power_controller;
 reg clk=0; always #5 clk=~clk; reg resetn=0,activity=0,enable=1;
 reg [7:0] idle_threshold=3; wire idle,clock_enable; integer e=0;
 low_power_controller dut(
        .clk(clk),
        .resetn(resetn),
        .activity(activity),
        .enable(enable),
        .idle_threshold(idle_threshold),
        .idle(idle),
        .clock_enable(clock_enable)
    );
 initial begin
 repeat(2) @(posedge clk); resetn=1;
 repeat(5) @(posedge clk); #1; if(!idle || clock_enable)e=e+1;
 @(negedge clk); activity=1; @(posedge clk); #1; if(idle || !clock_enable)e=e+1;
 @(negedge clk); activity=0; repeat(5) @(posedge clk); #1; if(!idle)e=e+1;
 $display("low_power_controller: %s (errors=%0d)",e==0?"PASS":"FAIL",e); $finish;
 end
endmodule
