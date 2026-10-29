module axi_slave_fsm(
    input wire clk, resetn,
    input wire write_pair_available,
    input wire read_available,
    input wire write_response_done,
    input wire read_response_done,
    output reg write_consume,
    output reg read_consume
);
    // A compact pulse controller. Channel holding registers provide independent AW/W capture.
    always @(posedge clk) begin
        if (!resetn) begin write_consume <= 0; read_consume <= 0; end
        else begin
            write_consume <= write_pair_available && !write_response_done;
            read_consume <= read_available && !read_response_done;
        end
    end
endmodule
