`timescale 1ns/1ps
module tb_burst_controller;
 reg clk=0; always #5 clk=~clk; reg resetn=0,start=0,beat_done=0;
 reg [7:0] start_addr=0; reg [4:0] burst_len=0;
 wire active,last; wire [7:0] beat_addr; wire [4:0] beat_index; integer e=0;
 burst_controller dut(
        .clk(clk),
        .resetn(resetn),
        .start(start),
        .start_addr(start_addr),
        .burst_len(burst_len),
        .beat_done(beat_done),
        .active(active),
        .beat_addr(beat_addr),
        .beat_index(beat_index),
        .last(last)
    );
 initial begin
 repeat(2) @(posedge clk); resetn=1;
 @(negedge clk); start_addr=8'h10; burst_len=4; start=1;
 @(negedge clk); start=0; #1; if(!active || beat_addr!=8'h10)e=e+1;
 repeat(3) begin @(negedge clk); beat_done=1; @(negedge clk); beat_done=0; #1; end
 if(!active || beat_addr!=8'h1C || beat_index!=3 || !last)e=e+1;
 @(negedge clk); beat_done=1; @(negedge clk); beat_done=0; #1;
 if(active)e=e+1;
 $display("burst_controller: %s (errors=%0d)",e==0?"PASS":"FAIL",e); $finish;
 end
endmodule
