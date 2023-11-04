`timescale 1us/1us

module tb_Seven;
    localparam CLK = 10;
    localparam HCLK = CLK/2;

    logic clk , start , rst_n;
    logic [3:0] i_speed;
    initial clk = 0;
    always #HCLK clk = ~clk;

    Seven test(
        .i_speed( i_speed ),
        .o_fast_or_slow( fast_or_slow ),
        .o_speed( o_speed )
    );

    initial begin
        $fsdbDumpfile("SEVEN.fsdb");
        $fsdbDumpvars;
        for (int j = 0; j < 16; j++) begin
            i_speed <= 4'd0 + j;
            for(int k = 0; k < 10; k++) begin
                @(posedge clk);
            end
        end
        $display("Simulation Done. Check it out!");
        for (int j = 0; j < 10; j++) begin
			@(posedge clk);
		end
        $finish;
    end
endmodule