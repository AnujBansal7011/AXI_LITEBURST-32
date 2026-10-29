`timescale 1ns/1ps
module tb_write_data_path;
 reg [31:0] wdata; reg [3:0] wstrb; wire [31:0] data_out; wire [3:0] strb_out; integer e=0;
 write_data_path dut(
        .wdata(wdata),
        .wstrb(wstrb),
        .data_out(data_out),
        .strb_out(strb_out)
    );
 initial begin wdata=32'h89ABCDEF; wstrb=4'b0101; #1;
 if(data_out!==wdata || strb_out!==wstrb)e=e+1;
 $display("write_data_path: %s (errors=%0d)",e==0?"PASS":"FAIL",e);$finish;end
endmodule
