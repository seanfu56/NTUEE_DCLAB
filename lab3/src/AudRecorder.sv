module AudRecorder(
    input i_rst_n,
    input i_clk,  
    input i_lrc,   // 1->0 : left
    input i_start,
    input i_pause, 
    input i_stop,
    input i_data,
    output [19:0] o_address,
    output [15:0] o_data
);

localparam S_IDLE = 3'd0;
localparam S_RECORD = 3'd1;
localparam S_PAUSE = 3'd2;
localparam S_WAIT = 3'd3;
localparam S_STOP = 3'd4;
localparam S_OFF = 3'd5;


logic [2:0] state_r, state_w;
logic [4:0] counter_r, counter_w;  
logic [19:0] o_address_r, o_address_w;
logic [15:0] o_data_r, o_data_w;

assign o_address = o_address_w;
assign o_data = o_data_r;

always_comb begin
    case(state_r)
		S_IDLE: begin
			if(i_start) begin
				state_w = S_OFF;
				counter_w = counter_r;
				o_data_w = o_data_r;
				o_address_w = o_address_r;
			end
			else begin
				state_w = state_r;
				counter_w = counter_r;
				o_data_w = o_data_r;
				o_address_w = o_address_r;				
			end
		end
        S_OFF: begin
            if(i_lrc) begin   ///left start recording
                state_w     = S_RECORD;
                counter_w   = 5'd1;
                o_data_w    = o_data_r;
                o_address_w = o_address_r;
            end
            else begin
                state_w     = state_r;
                counter_w   = counter_r;
                o_data_w    = o_data_r;
                o_address_w = o_address_r;
            end
        end
        S_RECORD: begin 
            if(i_pause) begin 
                state_w   = S_PAUSE;
                counter_w = counter_r;
                o_data_w  = 16'd0;
                o_address_w = o_address_r;
            end
            else if(i_stop) begin
                state_w   = S_STOP;
                counter_w = 5'd0;
                o_data_w  = 16'd0;
                o_address_w = o_address_r;
            end
            else if(counter_r == 16) begin
                state_w     = S_WAIT;
                counter_w   = 5'd1;
                o_data_w    = {o_data_r[14:0],i_data};
                o_address_w = o_address_r + 20'd1;
            end
            else begin 
                state_w     = state_r;
                counter_w   = counter_r + 5'd1;
                o_data_w    = {o_data_r[14:0],i_data};
                o_address_w = o_address_r;
            end
        end
        S_PAUSE: begin 
            if(i_start) begin
                state_w     = S_RECORD;
                counter_w   = counter_r;
                o_data_w    = 16'd0;
                o_address_w = o_address_r;
            end
            else if(i_stop) begin
                state_w     = S_STOP;
                counter_w   = 5'd0;
                o_data_w    = 16'd0;
                o_address_w =o_address_r;
            end
            else begin 
                state_w     = S_PAUSE;
                counter_w   = counter_r;
                o_data_w    = 16'd0;
                o_address_w = o_address_r;
            end
        end
        S_WAIT: begin
            if(!i_lrc) begin
                state_w     = S_OFF;
                counter_w   = counter_r; 
                o_data_w    = o_data_r;
                o_address_w = o_address_r;
            end
            else begin
                state_w     = state_r;
                counter_w   = counter_r;
                o_data_w    = o_data_r;
                o_address_w = o_address_r;
            end
        end
        S_STOP: begin
            state_w     = state_r;
            counter_w   = counter_r; 
            o_data_w    = 16'd0;
            o_address_w = o_address_r;
            
        end
        default: begin
			state_w = state_r;
			counter_w = counter_r;
			o_data_w = o_data_r;
			o_address_w = o_address_r;
		end

    endcase

end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state_r     <= S_IDLE;
        counter_r   <= 5'd0;
        o_data_r    <= 16'd0;
        o_address_r <= 20'b1111_1111_1111_1111_1111;
    end
    else begin
        state_r     <= state_w;
        counter_r   <= counter_w;
        o_data_r    <= o_data_w;
        o_address_r <= o_address_w;
    end
end

endmodule
