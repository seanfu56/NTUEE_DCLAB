module AudPlayer(
    input i_rst_n,
    input i_bclk, // clk(wait for 1 cycle)
    input i_daclrck, // 1->0 left ?
    input i_en, // can send ?
    input i_dac_data[15:0],
    output o_aud_dacdat
);


localparam IDLE = 2'd0;
localparam SEND = 2'd1;
localparam WAIT = 2'd2;

logic state_r[1:0],state_w[1:0];
logic counter_r[4:0],counter_w[4:0];
logic o_aud_dacdat_r, o_aud_dacdat_w;

assign o_aud_dacdat = o_aud_dacdat_r;

always_comb begin
	 case(state_r) 
        IDLE: begin
            if(i_en && !i_dac_clrck) begin
                state_w = SEND;
                counter_w = 5'd1;
                o_aud_dacdat_w = o_aud_dacdat_r;
            end
            else begin
                state_w = state_r;
                counter_w = counter_r;
                o_aud_dacdat_w = o_aud_dacdat_r;
            end
        end
        SEND: begin
            if(counter_r == 5'd16) begin 
                state_w = WAIT;
                counter_w = 5'd0;
                o_aud_dacdat_w = i_dac_data[16-counter_r];
            end
            else begin 
                state_w = state_r;
                counter_w = counter_r + 5'd1;
                o_aud_dacdat_w = i_dac_data[16-counter_r];
            end
        end
        WAIT: begin 
            if(i_daclrck) begin 
                state_w = IDLE;
                counter_w = counter_r;
                o_aud_dacdat_w = o_aud_dacdat_r;
            end 
            else begin 
                state_w = state_r;
                counter_w = counter_r;
                o_aud_dacdat_w = o_aud_dacdat_r;
            end
        end
     endcase

end

always_ff @(posedge i_bclk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state_r        <= IDLE;
        counter_r      <= 5'd0;
        o_aud_dacdat_r <= 1'd0; /// 不知道要填甚麼給他
    end
    else begin
        state_r        <= state_w;
        counter_r      <= counter_w;
        o_aud_dacdat_r <= o_aud_dacdat_w;
        
    end
end

endmodule