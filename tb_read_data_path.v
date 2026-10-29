`timescale 1ns/1ps
module tb_read_data_path;
 reg [31:0] mem_data; wire [31:0] data_out; integer e=0;
 read_data_path dut(
        .mem_data(mem_data),
        .data_out(data_out)
    );
 initial begin mem_data=32'h76543210; #1; if(data_out!==mem_data)e=e+1;
 $display("read_data_path: %s (errors=%0d)",e==0?"PASS":"FAIL",e);$finish;end
endmodule
