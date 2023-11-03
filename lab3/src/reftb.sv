`timescale 1us/1us

module tb_I2C;
    localparam CLK = 10;
    localparam HCLK = CLK/2;

    logic clk , start , rst_n;
    logic fin, sclk, sdat, oen;
    initial clk = 0;
    always #HCLK clk = ~clk;

    I2cInitializer test(
        .i_rst_n( rst_n ),
	    .i_clk( clk ),
	    .i_start( start ),
	    .o_finished( fin ),
	    .o_sclk( sclk ),
	    .o_sdat( sdat ),
	    .o_oen( oen )
    );

    initial begin
        $fsdbDumpfile("REF.fsdb");
        $fsdbDumpvars;
        rst_n = 0;
        #(2*CLK);
        rst_n = 1;
        for (int j = 0; j < 10; j++) begin
			@(posedge clk);
		end
        start <= 1;
        @(posedge clk);
        start <= 0;
        for (int j = 0; j < 1000; j++) begin
            @(posedge clk);
        end
        $display("Simulation Done. Check it out!");
        for (int j = 0; j < 100; j++) begin
			@(posedge clk);
		end
        $finish;
    end
endmodule