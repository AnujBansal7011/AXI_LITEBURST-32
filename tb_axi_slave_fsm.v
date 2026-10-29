`timescale 1ns/1ps
module tb_axi_slave_fsm;
 reg clk=0; always #5 clk=~clk; reg resetn=0,write_pair_available=0,read_available=0,write_response_done=0,read_response_done=0;
 wire write_consume,read_consume; integer e=0;
 axi_slave_fsm dut(
        .clk(clk),
        .write_pair_available(write_pair_available),
        .read_available(read_available),
        .write_response_done(write_response_done),
        .read_response_done(read_response_done),
        .write_consume(write_consume),
        .read_consume(read_consume)
    );
 initial begin repeat(2) @(posedge clk); resetn=1;
 @(negedge clk); write_pair_available=1; read_available=1;
 @(posedge clk); #1; if(!write_consume || !read_consume)e=e+1;
 @(negedge clk); write_response_done=1; read_response_done=1;
 @(posedge clk); #1; if(write_consume || read_consume)e=e+1;
 $display("axi_slave_fsm: %s (errors=%0d)",e==0?"PASS":"FAIL",e);$finish;end
endmodule
