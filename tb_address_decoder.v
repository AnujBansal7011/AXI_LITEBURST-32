`timescale 1ns/1ps
module tb_address_decoder;
 reg [7:0] addr; wire valid; wire [3:0] idx; integer e=0;
 address_decoder dut(.addr(addr),.addr_valid(valid),.word_index(idx));
 initial begin
 addr=0; #1; if(!valid || idx!=0)e=e+1;
 addr=8'h0C; #1; if(!valid || idx!=3)e=e+1;
 addr=1; #1; if(valid)e=e+1;
 addr=8'h40; #1; if(valid)e=e+1;
 $display("address_decoder: %s (errors=%0d)",e==0?"PASS":"FAIL",e); $finish;
 end
endmodule
