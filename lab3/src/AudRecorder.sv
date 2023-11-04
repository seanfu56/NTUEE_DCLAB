module AudRecorder(
    input i_rst_n,
    input i_clk,  
    input i_lrc,   // 1->0 : left
    input i_start,
    input i_pause, 
    input i_stop,
    input i_data,
    output o_address[19:0],
    output o_data[15:0]
);

localparam S_IDLE = 2'd0;
localparam S_RECORD = 2'd1;
localparam S_PAUSE = 2'd2;
localparam S_WAIT = 2'd3;

logic state_r[2:0],state_w[2:0];
logic counter_r[4:0],counter_w[4:0];  
logic o_address_r[19:0],o_address_w[19:0];
logic o_data_r[15:0],o_data_w[15:0];

assign o_addres = o_address_r;
assign o_data = o_data_r;

always_comb begin
    case(state_r)
        S_IDLE: begin
            if(i_start && !i_lrc) begin   ///left start recording
                state_w     = S_RECORD;
                counter_w   = 5'd1;
                o_data_w    = 16'd0;
                o_address_w = 20'd0;
            end
            else begin
                state_w     = state_r;
                counter_w   = counter_r;
                o_data_w    = 16'd0;
                o_address_w = 20'd0;
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
                state_w   = S_IDLE;
                counter_w = 5'd0;
                o_data_w  = 16'd0;
                o_address_w = o_address_r;
            end
            else if(counter_r <= 16) begin
                state_w     = S_WAIT;
                counter_w   = 5'd0;
                o_data_w    = {o_data_r[14:0],i_data};
                o_address_w = o_address_r;
            end
            else begin 
                state_w     = state_r;
                counter_w   = counter_r + 5'd1;
                o_data_w    = o_data_r;
                o_address_w = o_address_r + 20'd1;
            end
        end
        S_PAUSE: begin 
            if(!i_pause) begin
                state_w     = S_RECORD;
                counter_w   = counter_r;
                o_data_w    = 16'd0;
                o_address_w = o_address_r;
            end
            else if(i_stop) begin
                state_w     = S_IDLE;
                counter_w   = 5'd0;
                o_data_w    = 16'd0;
                o_address_w = 20'd0;
            end
            else begin 
                state_w     = S_PAUSE;
                counter_w   = counter_r;
                o_data_w    = 16'd0;
                o_address_w = o_address_r;
            end
        end
        S_WAIT: begin
            if(i_lrc) begin
                state_w     = S_IDLE;
                counter_w   = counter_r; 
                o_data_w    = 16'd0;
                o_address_w = o_address_r;
            end
            else begin
                state_w     = state_r;
                counter_w   = counter_r;
                o_data_w    = 16'd0;
                o_address_w = o_address_r;
            end
        end
        

    endcase

end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state_r     <= S_IDLE;
        counter_r   <= 5'd0;
        o_data_r    <= 16'd0;
        o_address_w <= 20'd0;
    end
    else begin
        state_r     <= state_w;
        counter_r   <= counter_w;
        o_data_r    <= o_data_w;
        o_address_r <= o_address_w;
    end
end

endmodule