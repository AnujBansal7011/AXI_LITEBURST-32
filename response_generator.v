module response_generator(
    input wire valid_address,
    output wire [1:0] response
);
    assign response = valid_address ? 2'b00 : 2'b10; // OKAY / SLVERR
endmodule
