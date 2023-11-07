module AudDSP(
    input i_rst_n,
    input i_clk,
    input i_start,
    input i_pause,
    input i_stop,
    input [2:0]i_speed,
    input i_fast,
    input i_slow_0,
    input i_slow_1,
    input i_daclrck,
    input [15:0]i_sram_data,
    output [15:0]o_dac_data,
    output [19:0]o_sram_addr
);

localparam S_IDLE = 0;
localparam S_FAST = 1;
localparam S_SLOW_ZERO = 2;
localparam S_SLOW_LINEAR = 3;
localparam S_WAIT1 = 4;
localparam S_WAIT2 = 5;
localparam S_WAIT3 = 6;

logic [2:0] state_r, state_w;
logic [19:0] addr_r, addr_w;
logic [19:0] outaddr_r, outaddr_w;
logic [3:0] count_r, count_w;
logic [15:0] out_data_r, out_data_w;
logic signed [15:0] rec1_r, rec1_w;
logic signed [15:0] rec2_r, rec2_w;
logic signed [15:0] rec3_r, rec3_w;

// assign o_dac_data = out_data_r;
assign o_sram_addr = addr_r;
assign o_dac_data = (i_daclrck == 0) ? out_data_r : 16'bZ;

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
        if(i_pause == 1)begin
            count_w = count_r;
            rec1_w = rec1_r;
            rec2_w = rec2_r;
            rec3_w = rec3_r;
            state_w = state_r;
            addr_w = addr_r;
            out_data_w = 16'bZ;
            outaddr_w = addr_r;
        end
        else if(i_stop == 1)begin
            count_w = count_r;
            rec1_w = rec1_r;
            rec2_w = rec2_r;
            rec3_w = rec3_r;
            state_w = S_IDLE;
            addr_w = 20'b0;
            out_data_w = 16'bZ;
            outaddr_w = 20'b0;
        end
        else if(i_daclrck) begin
            count_w = count_r;
            rec1_w = rec1_r;
            rec2_w = rec2_r;
            rec3_w = rec3_r;
            state_w = state_r;
            addr_w = addr_r;
            out_data_w = out_data_r;
            outaddr_w = outaddr_r;
        end
        else if(i_slow_0 && !i_fast) begin
            count_w = 4'b0;
            rec1_w = rec1_r;
            rec2_w = rec2_r;
            rec3_w = rec3_r;
            state_w = S_SLOW_ZERO;
            addr_w = addr_r;
            out_data_w = 16'bZ;
            outaddr_w = outaddr_r;
        end
        else if(i_slow_1 && !i_fast) begin
            count_w = 4'b0;
            rec1_w = 16'b0;
            rec2_w = 16'b0;
            rec3_w = 16'b0;
            state_w = S_SLOW_LINEAR;
            addr_w = addr_r;
            out_data_w = 16'bZ;
            outaddr_w = outaddr_r;
        end
        else begin
            count_w = count_r;
            rec1_w = rec1_r;
            rec2_w = rec2_r;
            rec3_w = rec3_r;
            state_w = S_WAIT1;
            addr_w = addr_r + i_speed + 1;
            out_data_w = i_sram_data;
            outaddr_w = addr_r + i_speed + 1;
        end
    end
    S_SLOW_ZERO: begin
        if(i_pause == 1)begin
            rec1_w = rec1_r;
            rec2_w = rec2_r;
            rec3_w = rec3_r;
            state_w = state_r;
            addr_w = addr_r;
            count_w = count_r;
            out_data_w = 16'bZ;
            outaddr_w = addr_r;
        end
        else if(i_stop == 1)begin
            rec1_w = rec1_r;
            rec2_w = rec2_r;
            rec3_w = rec3_r;
            state_w = S_IDLE;
            addr_w = 20'b0;
            count_w = 4'b0;
            out_data_w = 16'bZ;
            outaddr_w = 20'b0;
        end
        else if(i_daclrck)begin
            rec1_w = rec1_r;
            rec2_w = rec2_r;
            rec3_w = rec3_r;
            state_w = state_r;
            addr_w = addr_r;
            count_w = count_r;
            out_data_w = i_sram_data;
            outaddr_w = addr_r;
        end
        else if(i_fast) begin
            count_w = count_r;
            rec1_w = rec1_r;
            rec2_w = rec2_r;
            rec3_w = rec3_r;
            state_w = S_FAST;
            addr_w = addr_r;
            out_data_w = 16'bZ;
            outaddr_w = outaddr_r;
        end
        else if(i_slow_1  && !i_fast) begin
            count_w = 4'b0;
            rec1_w = 16'b0;
            rec2_w = 16'b0;
            rec3_w = 16'b0;
            state_w = S_SLOW_LINEAR;
            addr_w = addr_r;
            out_data_w = 16'bZ;
            outaddr_w = outaddr_r;
        end
        else begin
            rec1_w = rec1_r;
            rec2_w = rec2_r;
            rec3_w = rec3_r;
            state_w = S_WAIT2;
            if(count_r + 1 > i_speed)begin
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
            out_data_w = 16'bZ;
            outaddr_w = addr_r;
        end
        else if(i_stop == 1)begin
            state_w = S_IDLE;
            addr_w = 20'b0;
            count_w = 4'b0;
            rec1_w = 16'b0;
            rec2_w = 16'b0;
            rec3_w = 16'b0;        
            out_data_w = 16'bZ;
            outaddr_w = 20'b0;
        end
        else if(i_daclrck)begin
            state_w = state_r;
            addr_w = addr_r;
            out_data_w = i_sram_data;
            outaddr_w = addr_r;
            rec1_w = rec1_r;
            rec2_w = rec2_r;
            rec3_w = rec3_r;
            count_w = count_r;
        end
        else if(i_fast) begin
            count_w = count_r;
            rec1_w = rec1_r;
            rec2_w = rec2_r;
            rec3_w = rec3_r;
            state_w = S_FAST;
            addr_w = addr_r;
            out_data_w = 16'bZ;
            outaddr_w = outaddr_r;
        end
        else if(i_slow_0 && !i_fast) begin
            count_w = 4'b0;
            rec1_w = rec1_r;
            rec2_w = rec2_r;
            rec3_w = rec3_r;
            state_w = S_SLOW_ZERO;
            addr_w = addr_r;
            out_data_w = 16'bZ;
            outaddr_w = outaddr_r;
        end
        else begin
            state_w = S_WAIT3;
            if(count_r + 1 > i_speed)begin
                addr_w = addr_r + 1;
                count_w = 4'b0;
                out_data_w = $signed(out_data_r) + $signed(rec1_r) - $signed(rec2_r);
                outaddr_w = addr_r + 1;
                rec1_w = ($signed(i_sram_data) / ($signed(i_speed) + 1));
                rec2_w = ($signed(rec3_r) / ($signed(i_speed) + 1));
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
    S_WAIT1: begin
        if(!i_daclrck)begin
            state_w = state_r;
            rec1_w = rec1_r;
            rec2_w = rec2_r;
            rec3_w = rec3_r;
            addr_w = addr_r;
            count_w = count_r;
            out_data_w = i_sram_data;
            outaddr_w = addr_r;
        end
        else if(i_slow_0 && !i_fast) begin
            count_w = 4'b0;
            rec1_w = rec1_r;
            rec2_w = rec2_r;
            rec3_w = rec3_r;
            state_w = S_SLOW_ZERO;
            addr_w = addr_r;
            out_data_w = 16'bZ;
            outaddr_w = outaddr_r;
        end
        else if(i_slow_1 && !i_fast) begin
            count_w = 4'b0;
            rec1_w = 16'b0;
            rec2_w = 16'b0;
            rec3_w = 16'b0;
            state_w = S_SLOW_LINEAR;
            addr_w = addr_r;
            out_data_w = 16'bZ;
            outaddr_w = outaddr_r;
        end
        else begin
            state_w = S_FAST;
            rec1_w = rec1_r;
            rec2_w = rec2_r;
            rec3_w = rec3_r;
            addr_w = addr_r;
            count_w = count_r;
            out_data_w = i_sram_data;
            outaddr_w = addr_r;
        end
    end
    S_WAIT2: begin
        if(!i_daclrck)begin
            state_w = state_r;
            rec1_w = rec1_r;
            rec2_w = rec2_r;
            rec3_w = rec3_r;
            addr_w = addr_r;
            count_w = count_r;
            out_data_w = i_sram_data;
            outaddr_w = addr_r;
        end
        else if(i_fast) begin
            count_w = count_r;
            rec1_w = rec1_r;
            rec2_w = rec2_r;
            rec3_w = rec3_r;
            state_w = S_FAST;
            addr_w = addr_r;
            out_data_w = 16'bZ;
            outaddr_w = outaddr_r;
        end
        else if(i_slow_1  && !i_fast) begin
            count_w = 4'b0;
            rec1_w = 16'b0;
            rec2_w = 16'b0;
            rec3_w = 16'b0;
            state_w = S_SLOW_LINEAR;
            addr_w = addr_r;
            out_data_w = 16'bZ;
            outaddr_w = outaddr_r;
        end
        else begin
            state_w = S_SLOW_ZERO;
            rec1_w = rec1_r;
            rec2_w = rec2_r;
            rec3_w = rec3_r;
            addr_w = addr_r;
            count_w = count_r;
            out_data_w = i_sram_data;
            outaddr_w = addr_r;
        end
    end
    S_WAIT3: begin
        if(!i_daclrck)begin
            state_w = state_r;
            rec1_w = rec1_r;
            rec2_w = rec2_r;
            rec3_w = rec3_r;
            addr_w = addr_r;
            count_w = count_r;
            out_data_w = i_sram_data;
            outaddr_w = addr_r;
        end
        else if(i_fast) begin
            count_w = count_r;
            rec1_w = rec1_r;
            rec2_w = rec2_r;
            rec3_w = rec3_r;
            state_w = S_FAST;
            addr_w = addr_r;
            out_data_w = 16'bZ;
            outaddr_w = outaddr_r;
        end
        else if(i_slow_0 && !i_fast) begin
            count_w = 4'b0;
            rec1_w = rec1_r;
            rec2_w = rec2_r;
            rec3_w = rec3_r;
            state_w = S_SLOW_ZERO;
            addr_w = addr_r;
            out_data_w = 16'bZ;
            outaddr_w = outaddr_r;
        end
        else begin
            state_w = S_SLOW_LINEAR;
            rec1_w = rec1_r;
            rec2_w = rec2_r;
            rec3_w = rec3_r;
            addr_w = addr_r;
            count_w = count_r;
            out_data_w = i_sram_data;
            outaddr_w = addr_r;
        end
    end
    default: begin
        state_w = state_r;
        rec1_w = rec1_r;
        rec2_w = rec2_r;
        rec3_w = rec3_r;
        addr_w = addr_r;
        count_w = count_r;
        out_data_w = i_sram_data;
        outaddr_w = addr_r;
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
        out_data_r <= 16'bZ;
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

