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

always_comb begin
    case(state_r)
    S_IDLE: begin
    end
    S_FAST: begin
        
    end
    S_SLOW_ZERO: begin
    end
    S_SLOW_LINEAR: begin
    end 
    endcase
end

always_ff @(posedge i_clk, negedge i_rst_n) begin
    if(!i_rst_n) begin
        state_r <= S_IDLE;
    end
end

endmodule