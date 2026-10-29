`timescale 1ns/1ps
module tb_reg_mem_bank;
 reg clk=0; always #5 clk=~clk; reg resetn=0,wr_en=0,rd_en=0;
 reg [3:0] wr_index=0,rd_index=0; reg [31:0] wr_data=0; reg [3:0] wr_strb=0; wire [31:0] rd_data; integer e=0;
 reg_mem_bank dut(
        .clk(clk),
        .resetn(resetn),
        .wr_en(wr_en),
        .wr_index(wr_index),
        .wr_data(wr_data),
        .wr_strb(wr_strb),
        .rd_en(rd_en),
        .rd_index(rd_index),
        .rd_data(rd_data)
    );
 initial begin
 repeat(2) @(posedge clk); resetn=1;
 @(negedge clk); wr_en=1; wr_index=2; wr_data=32'h12345678; wr_strb=4'hF;
 @(negedge clk); wr_en=0; rd_en=1; rd_index=2;
 @(posedge clk); #1; if(rd_data!==32'h12345678)e=e+1;
 @(negedge clk); rd_en=0; wr_en=1; wr_index=2; wr_data=32'hAAAA0000; wr_strb=4'b1100;
 @(negedge clk); wr_en=0; rd_en=1;
 @(posedge clk); #1; if(rd_data!==32'hAAAA5678)e=e+1;
 $display("reg_mem_bank: %s (errors=%0d)",e==0?"PASS":"FAIL",e); $finish;
 end
endmodule
