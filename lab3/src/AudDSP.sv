module AudDSP(
    input i_rst_n,
    input i_clk,
    input i_start,
    input i_pause,
    input i_stop,
    input i_speed,
    input i_fast,
    input i_slow_0,
    input i_slow_1,
    input i_daclrck,
    input i_sram_data,
    output o_dac_data,
    output o_sram_addr
);

localparam S_IDLE = 0;
localparam S_FAST = 1;
localparam S_SLOW_ZERO = 2;
localparam S_SLOW_LINEAR = 3;

logic state_r, state_w;
logic [19:0] addr_r, addr_w;
logic [19:0] outaddr_r, outaddr_w;
logic [3:0] count_r, count_w;
logic [15:0] out_data_r, out_data_w;
logic signed [15:0] rec1_r, rec1_w;
logic signed [15:0] rec2_r, rec2_w;
logic signed [15:0] rec3_r, rec3_w;

// assign o_dac_data = out_data_r;
assign o_sram_addr = outaddr_r;
assign o_dac_data = (i_daclrck == 0) ? o_dac_data_r : 16'bz;

always_comb begin
    case(state_r)
    S_IDLE: begin
        addr_w = addr_r;
        count_w = count_r;
        rec1_w = rec1_r;
        rec2_w = rec2_r;
        rec3_w = rec3_r;
        out_data_w = out_data_r;
        outaddr_w = outaddr_r;
        if(i_start == 1) begin
            if(i_fast == 1) begin
                state_w = S_FAST;
            end
            else if(i_slow_0 == 1) begin
                state_w = S_SLOW_ZERO;
            end
            else if(i_slow_1 == 1) begin
                state_w = S_SLOW_LINEAR;
            end
            else begin
                state_w = state_r;
            end
        end
        else begin
            state_w = state_r;
        end
    end
    S_FAST: begin
        count_w = count_r;
        rec1_w = rec1_r;
        rec2_w = rec2_r;
        rec3_w = rec3_r;
        if(i_pause == 1)begin
            state_w = state_r;
            addr_w = addr_r;
            out_data_w = 16'b0;
            outaddr_w = addr_r;
        end
        else if(i_stop == 1)begin
            state_w = S_IDLE;
            addr_w = 20'b0;
            out_data_w = 16'b0;
            outaddr_w = 20'b0;
        end
        else begin
            state_w = state_r;
            addr_w = addr_r + i_speed;
            out_data_w = i_sram_data;
            outaddr_w = addr_r + i_speed;
        end
    end
    S_SLOW_ZERO: begin
        rec1_w = rec1_r;
        rec2_w = rec2_r;
        rec3_w = rec3_r;
        if(i_pause == 1)begin
            state_w = state_r;
            addr_w = addr_r;
            count_w = count_r;
            out_data_w = 16'b0;
            outaddr_w = addr_r;
        end
        else if(i_stop == 1)begin
            state_w = S_IDLE;
            addr_w = 20'b0;
            count_w = 4'b0;
            out_data_w = 16'b0;
            outaddr_w = 20'b0;
        end
        else begin
            state_w = state_r;
            if(count_r + 1 >= i_speed)begin
                addr_w = addr_r + 1;
                count_w = 4'b0;
                out_data_w = i_sram_data;
                outaddr_w = addr_r + 1;
            end
            else begin
                addr_w = addr_r;
                count_w = count_r + 1;
                out_data_w = i_sram_data;
                outaddr_w = addr_r;
            end
        end
    end
    S_SLOW_LINEAR: begin
        if(i_pause == 1)begin
            state_w = state_r;
            addr_w = addr_r;
            count_w = count_r;
            rec1_w = rec1_r;
            rec2_w = rec2_r;
            rec3_w = rec3_r;
            out_data_w = 16'b0;
            outaddr_w = addr_r;
        end
        else if(i_stop == 1)begin
            state_w = S_IDLE;
            addr_w = 20'b0;
            count_w = 4'b0;
            rec1_w = 16'b0;
            rec2_w = 16'b0;
            rec3_w = 16'b0;        
            out_data_w = 16'b0;
            outaddr_w = 20'b0;
        end
        else begin
            state_w = state_r;
            if(count_r + 1 >= i_speed)begin
                addr_w = addr_r + 1;
                count_w = 4'b0;
                out_data_w = $signed(out_data_r) + $signed(rec1_r) - $signed(rec2_r);
                outaddr_w = addr_r + 1;
                rec1_w = ($signed(i_sram_data) / $signed(i_speed));
                rec2_w = ($signed(rec3_r) / $signed(i_speed));
                rec3_w = i_sram_data;
            end
            else begin
                addr_w = addr_r;
                count_w = count_r + 1;
                out_data_w = $signed(out_data_r) + $signed(rec1_r) - $signed(rec2_r);
                outaddr_w = addr_r;
                rec1_w = rec1_r;
                rec2_w = rec2_r;
                rec3_w = rec3_r;
            end
        end
    end 
    endcase
end

always_ff @(posedge i_clk, negedge i_rst_n) begin
    if(!i_rst_n) begin
        state_r <= S_IDLE;
        addr_r <= 20'b0;
        count_r <= 4'b0;
        rec1_r <= 16'b0;
        rec2_r <= 16'b0;
        rec3_r <= 16'b0;
        out_data_r <= 16'b0;
        outaddr_r <= 20'b0;
    end
    else begin
        state_r = state_w;
        addr_r <= addr_w;
        count_r <= count_w;
        rec1_r <= rec1_w;
        rec2_r <= rec2_w;
        rec3_r <= rec3_w;
        out_data_r <= out_data_w;
        outaddr_r <= outaddr_w;
    end
end

endmodule