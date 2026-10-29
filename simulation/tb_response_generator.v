`timescale 1ns/1ps
module tb_response_generator;
 reg valid_address; wire [1:0] response; integer e=0;
 response_generator dut(.valid_address(valid_address),.response(response));
 initial begin
 valid_address=1; #1; if(response!==2'b00)e=e+1;
 valid_address=0; #1; if(response!==2'b10)e=e+1;
 $display("response_generator: %s (errors=%0d)",e==0?"PASS":"FAIL",e); $finish;
 end
endmodule
