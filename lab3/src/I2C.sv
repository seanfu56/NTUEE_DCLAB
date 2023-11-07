module I2cInitializer(
	input i_rst_n,
    input i_clk,
    input i_start,
    output o_finished,
    output o_sclk,
    output o_sdat,
    output o_oen,
	output [1:0] o_state
);

localparam S_IDLE = 2'b00;
localparam S_START = 2'b01;
localparam S_SEND = 2'b10;
localparam S_FIN = 2'b11;
// localparam RESET = 24'b0011_0100_000_1111_0_0000_0000; // reset
// localparam AAPC  = 24'b0011_0100_000_0100_0_0001_0101; // analogue audio path control
// localparam DAPC  = 24'b0011_0100_000_0101_0_0000_0000; // digital audio path control
// localparam PDC   = 24'b0011_0100_000_0110_0_0000_0000; // power down control
// localparam DAIF  = 24'b0011_0100_000_0111_0_0100_0010; // digital audio interface format
// localparam SC    = 24'b0011_0100_000_1000_0_0001_1001; // sampling control
// localparam AC    = 24'b0011_0100_000_1001_0_0000_0001; // active control

localparam s1 = 24'b00110100_000_1001_0_0000_0001;
localparam s2 = 24'b00110100_000_1000_0_0001_1001;
localparam s3 = 24'b00110100_000_0111_0_0100_0010;
localparam s4 = 24'b00110100_000_0110_0_0000_0000;
localparam s5 = 24'b00110100_000_0101_0_0000_0000;
localparam s6 = 24'b00110100_000_0100_0_0001_0101;
localparam s7 = 24'b00110100_000_0011_0_0111_1001;
localparam s8 = 24'b00110100_000_0010_0_0111_1001;
localparam s9 = 24'b00110100_000_0001_0_1001_0111;
localparam s10= 24'b00110100_000_0000_0_1001_0111;

logic [1:0] state_r, state_w;
logic o_finished_r, o_finished_w;
logic o_sclk_r, o_sclk_w;
logic o_sdat_r, o_sdat_w;
logic o_oen_r, o_oen_w;
logic [3:0] sentence_r, sentence_w;
logic [4:0] bit_r, bit_w;
logic [1:0] clk_counter_r, clk_counter_w;
logic [1:0] send_counter_r, send_counter_w;
logic block_r, block_w;

assign o_finished = o_finished_r;
assign o_sclk     = o_sclk_r;
assign o_sdat     = o_sdat_r;
assign o_oen      = o_oen_r;
assign o_state    = state_r;

always_comb begin
    case(state_r) 
        S_IDLE: begin
            if(i_start) begin
                state_w = S_START;
                o_finished_w = o_finished_r;
                o_sclk_w = o_sclk_r;
                o_sdat_w = 1'b0;
                o_oen_w = o_oen_r;
                sentence_w = sentence_r;
                bit_w = bit_r;
                clk_counter_w = clk_counter_r;
				send_counter_w = send_counter_r;
				block_w = block_r;
            end
            else begin
                state_w = S_IDLE;
                o_finished_w = o_finished_r;
                o_sclk_w = o_sclk_r;
                o_sdat_w = o_sdat_r;
                o_oen_w = o_oen_r;
                sentence_w = sentence_r;
                bit_w = bit_r;
                clk_counter_w = clk_counter_r;
				send_counter_w = send_counter_r;
				block_w = block_r;
            end
        end
        S_START: begin
            if(clk_counter_r === 2'd0) begin
                clk_counter_w = 2'd1;
                o_sclk_w = 1'b1;
                bit_w = bit_r;
                sentence_w = sentence_r;
                o_sdat_w = o_sdat_r;
                o_finished_w = o_finished_r;
                state_w = state_r;
                o_oen_w = o_oen_r;
				send_counter_w = send_counter_r;
				block_w = block_r;
            end
            else if(clk_counter_r === 2'd1)begin
                clk_counter_w = 2'd2;
                o_sclk_w = 1'b0;
                bit_w = bit_r;
                sentence_w = sentence_r;
                o_sdat_w = o_sdat_r;
                o_finished_w = o_finished_r;
                state_w = state_r;
                o_oen_w = o_oen_r;
				send_counter_w = send_counter_r;
				block_w = block_r;
            end
            else begin
                clk_counter_w = 2'd0;
                if(o_oen_r && bit_r % 8 === 0 && (bit_r !== 0 || (bit_r === 0 && sentence_r !== 0)) ) begin
                    o_finished_w = o_finished_r;
                    if(bit_r === 5'd24 && block_r === 1'b0) begin
						o_sclk_w = 1'b0;
		                o_oen_w = 1'b0;
                    	o_sdat_w = 1'bz;
                        bit_w = bit_r;
                        sentence_w = sentence_r + 1;
						state_w = state_r;
						send_counter_w = 2'd0;
						block_w = 1'b1;
                    end
                    else begin
						o_sclk_w = 1'b0;
		                o_oen_w = 1'b0;
                    	o_sdat_w = 1'bz;
                        bit_w = bit_r;
                        sentence_w = sentence_r;
						state_w = state_r;
						send_counter_w = send_counter_r;
						block_w = block_r;
                    end
                end
				else if(!o_oen_r && bit_r === 5'd24 && block_r === 1'b1) begin
					o_sclk_w = 1'b0;
					o_oen_w = 1'b1;
					o_sdat_w = 1'b0;
					o_finished_w = o_finished_r;
					bit_w = 1;
					sentence_w = sentence_r;
					state_w = S_SEND;
					send_counter_w = 2'd0;
					block_w = 1'b0;
				end
                else begin
					o_sclk_w = 1'b0;
                    o_oen_w = 1'b1;
					send_counter_w = send_counter_r;
					block_w = block_r;
                    if(sentence_r != 4'd10) begin
                        bit_w = bit_r + 1;
                        sentence_w = sentence_r;
                        o_finished_w = o_finished_r;
                        state_w = state_r;
                        case(sentence_r) 
                            4'd0: begin
                                o_sdat_w = s1[23-bit_r];
                            end
                            4'd1: begin
                                o_sdat_w = s2[23-bit_r];
                            end
                            4'd2: begin
                                o_sdat_w = s3[23-bit_r];
                            end
                            4'd3: begin
                                o_sdat_w = s4[23-bit_r];
                            end
                            4'd4: begin
                                o_sdat_w = s5[23-bit_r];
                            end
                            4'd5: begin
                                o_sdat_w = s6[23-bit_r];
                            end
                            4'd6: begin
                                o_sdat_w = s7[23-bit_r];
                            end
							4'd7: begin
								o_sdat_w = s8[23-bit_r];
							end
							4'd8: begin
								o_sdat_w = s9[23-bit_r];
							end
							4'd9: begin
								o_sdat_w = s10[23-bit_r];
							end
                            default: begin
                                o_sdat_w = o_sdat_r;
                            end
                        endcase
                    end
                    // else if(sentence_r === 4'd10) begin
					else begin
                        bit_w = bit_r;
                        sentence_w = sentence_r;
                        o_sdat_w = o_sdat_r;
                        o_finished_w = 1'b1;
                        state_w = S_IDLE;
                    end
                    // else begin
                    //     bit_w = bit_r;
                    //     sentence_w = sentence_r;
                    //     o_sdat_w = o_sdat_r;
                    //     o_finished_w = o_finished_r;
                    //     state_w = state_r;
                    // end
                end
            end
        end
		S_SEND: begin
			if(clk_counter_r == 2'b00 && send_counter_r == 2'b00) begin
				block_w = block_r;
				send_counter_w = 2'b00;
				o_sclk_w = 1'b1;
				o_sdat_w = 1'b0;
				state_w = state_r;
				clk_counter_w = clk_counter_r + 1;
			end
			else if(clk_counter_r == 2'b01 && send_counter_r == 2'b00) begin
				block_w = block_r;
				send_counter_w = 2'b00;
				o_sclk_w = 1'b1;
				o_sdat_w = 1'b1;
				state_w = state_r;
				clk_counter_w = clk_counter_r + 1;
			end
			else if(clk_counter_r == 2'b10 && send_counter_r == 2'b00) begin
				block_w = block_r;
				send_counter_w = 2'b01;
				o_sclk_w = 1'b1;
				o_sdat_w = 1'b0;
				state_w = state_r;
				clk_counter_w = 2'b00;
			end
			else if(clk_counter_r == 2'b00 && send_counter_r == 2'b01) begin
				block_w = block_r;
				send_counter_w = 2'b01;
				o_sclk_w = 1'b0;
				o_sdat_w = 1'b0;
				state_w = state_r;
				clk_counter_w = clk_counter_r + 1;
			end
			else begin
				if(sentence_r === 4'd10) begin
					block_w = block_r;
					send_counter_w = 2'b00;
					o_sclk_w = 1'b0;
					o_sdat_w = 1'b0;
					state_w = S_FIN;
					clk_counter_w = 2'b00;
				end
				else begin
					block_w = block_r;
					send_counter_w = 2'b00;
					o_sclk_w = 1'b0;
					o_sdat_w = 1'b0;
					state_w = S_START;
					clk_counter_w = 2'b00;					
				end

			end
			bit_w = bit_r;
			sentence_w = sentence_r;
			o_finished_w = o_finished_r;
			o_oen_w = 1'b1;

		end
		S_FIN: begin
			block_w = block_r;
			send_counter_w = send_counter_r;
			o_sclk_w = o_sclk_r;
			state_w = S_FIN;
			clk_counter_w = clk_counter_r;
			bit_w = bit_r;
			sentence_w = sentence_r;
			o_finished_w = 1'b1;
			o_oen_w = 1'b1;
			o_sdat_w = o_sdat_r;
		end
    endcase
end


always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state_r       <= S_IDLE;
        o_finished_r  <= 1'b0;
        o_sclk_r      <= 1'b1;
        o_sdat_r      <= 1'b1;
        o_oen_r       <= 1'b1;
        sentence_r    <= 3'd0;
        bit_r         <= 5'd0;
        // counter_r     <= 16'd0;
        clk_counter_r <= 2'd0;
		send_counter_r <= 2'd0;
		block_r <= 1'b0;
    end
    else begin
        state_r       <= state_w;
        o_finished_r  <= o_finished_w;
        o_sclk_r      <= o_sclk_w;
        o_sdat_r      <= o_sdat_w;
        o_oen_r       <= o_oen_w;
        sentence_r    <= sentence_w;
        bit_r         <= bit_w;
        // counter_r     <= counter_w;
        clk_counter_r <= clk_counter_w;
		send_counter_r <= send_counter_w;
		block_r <= block_w;
    end
end

endmodule