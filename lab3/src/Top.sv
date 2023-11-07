module Top (
	input i_rst_n,
	input i_clk,
	input i_key_0,
	input i_key_1,
	input i_key_2,
	input [4:0] i_speed, // design how user can decide mode on your own
	
	// AudDSP and SRAM
	output [19:0] o_SRAM_ADDR,
	inout  [15:0] io_SRAM_DQ,
	output        o_SRAM_WE_N,
	output        o_SRAM_CE_N,
	output        o_SRAM_OE_N,
	output        o_SRAM_LB_N,
	output        o_SRAM_UB_N,
	
	// I2C
	input  i_clk_100k,
	output o_I2C_SCLK,
	inout  io_I2C_SDAT,
	
	// AudPlayer
	input  i_AUD_ADCDAT,
	inout  i_AUD_ADCLRCK,
	inout  i_AUD_BCLK,
	inout  i_AUD_DACLRCK,
	output o_AUD_DACDAT,

	// SEVENDECODER (optional display)
	// output [5:0] o_record_time,
	// output [5:0] o_play_time,
	output [6:0] o_speed,
	output [6:0] o_sample,
	output [6:0] o_fast_or_slow,
	output [6:0] o_ten,
	output [6:0] o_one,
	output [2:0] o_state,

	// LCD (optional display)
	// input        i_clk_800k,
	// inout  [7:0] o_LCD_DATA,
	// output       o_LCD_EN,
	// output       o_LCD_RS,
	// output       o_LCD_RW,
	// output       o_LCD_ON,
	// output       o_LCD_BLON,

	// LED
	// output  [8:0] o_ledg,
	output [17:0] o_ledr
);

// design the FSM and states as you like
parameter S_I2C        = 3'b000;
parameter S_IDLE       = 3'b001;
parameter S_RECD       = 3'b010;
parameter S_RECD_PAUSE = 3'b011;
parameter S_RECD_FIN   = 3'b100;
parameter S_PLAY       = 3'b101;
parameter S_PLAY_PAUSE = 3'b110;

logic i2c_oen, i2c_sdat;
logic [19:0] addr_record, addr_play;
logic [15:0] data_record, data_play, dac_data;


assign io_I2C_SDAT = (i2c_oen) ? i2c_sdat : 1'bz;

assign o_SRAM_ADDR = (state_r == S_RECD) ? addr_record : addr_play[19:0];
assign io_SRAM_DQ  = (state_r == S_RECD) ? data_record : 16'dz; // sram_dq as output
assign data_play   = (state_r != S_RECD) ? io_SRAM_DQ : 16'd0; // sram_dq as input

assign o_SRAM_WE_N = (state_r == S_RECD) ? 1'b0 : 1'b1;
assign o_SRAM_CE_N = 1'b0;
assign o_SRAM_OE_N = 1'b0;
assign o_SRAM_LB_N = 1'b0;
assign o_SRAM_UB_N = 1'b0;

// below is a simple example for module division
// you can design these as you like\


//TODO

parameter freq = 32'd50000000;
// logic [3:0] speed_r, speed_w;
// logic display_mode_r, display_mode_w;     //high speed or low speed
// logic display_sample_r, display_sample_w; //constant or linear
logic [2:0] state_r, state_w;
logic i2c_start;
logic i2c_finished;
logic [6:0] o_speed_w, o_fast_or_slow_w, o_smaple_w, o_ten_w, o_one_w, o_state_w;
logic [31:0] counter_w, counter_r;
logic [6:0] seconds_w, seconds_r;

assign o_speed = o_speed_w;
assign o_fast_or_slow = o_fast_or_slow_w;
assign o_sample = o_smaple_w;
assign o_ten = o_ten_w;
assign o_one = o_one_w;
assign o_state = state_w;

//FINISH

// Int_to_seven int1(
// 	.number(state_r),
// 	.seven(o_state_w)
// );

// === I2cInitializer ===
// sequentially sent out settings to initialize WM8731 with I2C protocal
I2cInitializer init0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk_100k),
	.i_start(i2c_start),
	.o_finished(i2c_finished),
	.o_sclk(o_I2C_SCLK),
	.o_sdat(i2c_sdat),
	.o_oen(i2c_oen) // you are outputing (you are not outputing only when you are "ack"ing.)
);

// === AudDSP ===
// responsible for DSP operations including fast play and slow play at different speed
// in other words, determine which data addr to be fetch for player 
AudDSP dsp0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk),
	.i_start(state_r === S_PLAY),
	.i_pause(state_r === S_PLAY_PAUSE),
	.i_stop(state_r === S_RECD_FIN),
	.i_speed(i_speed[2:0]),
	.i_fast(i_speed[4]),
	.i_slow_0(i_speed[3]), // constant interpolation
	.i_slow_1(!i_speed[3]), // linear interpolation
	.i_daclrck(i_AUD_DACLRCK),
	.i_sram_data(data_play),
	.o_dac_data(dac_data),
	.o_sram_addr(addr_play)
);

// === AudPlayer ===
// receive data address from DSP and fetch data to sent to WM8731 with I2S protocal
AudPlayer player0(
	.i_rst_n(i_rst_n),
	.i_bclk(i_AUD_BCLK),
	.i_daclrck(i_AUD_DACLRCK),
	.i_en(state_r === S_PLAY), // enable AudPlayer only when playing audio, work with AudDSP
	.i_dac_data(dac_data), //dac_data
	.o_aud_dacdat(o_AUD_DACDAT)
);

// === AudRecorder ===
// receive data from WM8731 with I2S protocal and save to SRAM
AudRecorder recorder0(
	.i_rst_n(i_rst_n), 
	.i_clk(i_AUD_BCLK),
	// .i_clk(i_clk_100k),
	.i_lrc(i_AUD_ADCLRCK),
	// .i_lrc(1'b0),
	.i_start(state_r === S_RECD),
	.i_pause(state_r === S_RECD_PAUSE),
	.i_stop(state_r === S_RECD_FIN),
	.i_data(i_AUD_ADCDAT),
	.o_address(addr_record),
	.o_data(data_record),
);

Seven seven0(
	.i_speed(i_speed),
	.o_fast_or_slow(o_fast_or_slow_w),
	.o_speed(o_speed_w),
	.o_sample(o_smaple_w)
);

Counter counter0(
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.i_record(state_r === S_RECD),
	.i_play(state_r === S_PLAY),
	.i_fast(i_speed[4]),
	.i_pause(state_r === S_RECD_PAUSE || state_r === S_PLAY_PAUSE),
	.i_speed(i_speed),
	.o_ten(o_ten_w),
	.o_one(o_one_w)
);

// LEDVolume led0(
// 	.i_record(state_r == S_RECD),
// 	.i_data(data_record),
// 	.o_led_r(o_ledr)
// );

always_comb begin
	// design your control here
	case(state_r) 
	S_I2C: begin
		counter_w = 32'd0;
		seconds_w = 7'd0;
		if(i2c_finished) begin
			state_w = S_IDLE;
		end
		else begin
			state_w = state_r;
		end
	end
	S_IDLE: begin
		counter_w = 32'd0;
		seconds_w = 7'd0;
		if(i_key_0) begin
			state_w = S_RECD;
		end
		else begin
			state_w = state_r;
		end
	end
	S_RECD: begin
		// if(counter_r === freq) begin
		// 	counter_w = 32'd0;
		// 	seconds_w = seconds_r + 1;
		// end
		// else begin
		// 	counter_w = counter_r + 1;
		// 	seconds_w = seconds_r;
		// end
		counter_w = counter_r;
		seconds_w = seconds_r;
		if(i_key_1) begin
			state_w = S_RECD_PAUSE;
		end
		else if(i_key_2) begin
			state_w = S_RECD_FIN;
		end
		else if(addr_record === 20'b1111_1111_1111_1111_1110) begin
			state_w = S_RECD_FIN;
		end
		else begin
			state_w = state_r;
		end
	end
	S_RECD_PAUSE: begin
		counter_w = counter_r;
		seconds_w = seconds_r;
		if(i_key_0) begin
			state_w = S_RECD;
		end
		else if(i_key_2) begin
			state_w = S_RECD_FIN;
		end
		else begin
			state_w = state_r;
		end
	end
	S_RECD_FIN: begin
		counter_w = 32'd0;
		seconds_w = 7'd0;
		if(i_key_0) begin
			state_w = S_PLAY;
		end
		else begin
			state_w = state_r;
		end
	end
	S_PLAY: begin
		if(counter_r === freq) begin
			counter_w = 32'd0;
			seconds_w = seconds_r + 1;
		end
		else begin
			counter_w = counter_r + 1;
			seconds_w = seconds_r;
		end
		if(i_key_1) begin
			state_w = S_PLAY_PAUSE;
		end
		else if(i_key_2) begin
			state_w = S_RECD_FIN;
		end
		else if(addr_record < addr_play) begin
			state_w = S_RECD_FIN;
		end
		else begin
			state_w = state_r;
		end
	end
	S_PLAY_PAUSE: begin
		counter_w = counter_r;
		seconds_w = seconds_r;
		if(i_key_0) begin
			state_w = S_PLAY;
		end
		else if(i_key_2) begin
			state_w = S_RECD_FIN;
		end
		else begin
			state_w = state_r;
		end
	end
	default: begin
		counter_w = counter_r;
		seconds_w = seconds_r;
		state_w = state_r;
	end
	endcase
end

always_ff @(posedge i_AUD_BCLK or negedge i_rst_n) begin
	if (!i_rst_n) begin
		// state_r <= S_I2C;
		state_r <= S_I2C;
		i2c_start <= 1'b1;
		counter_r <= 32'd0;
	end
	else begin
		state_r <= state_w;
		i2c_start <= 1'b1;
		counter_r <= counter_w;
	end
end

endmodule
