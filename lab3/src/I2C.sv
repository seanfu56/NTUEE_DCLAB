module I2cInitializer(
	input i_rst_n,
    input i_clk_100K,
    input i_start,
    output o_finished,
    output o_sclk,
    output o_sdat,
    output o_oen
)

localparam S_IDLE = 1'b0;
localparam S_START = 1'b1;

localparam RESET = 24'b0011_0100_000_1111_0_0000_0000; // reset
localparam AAPC  = 24'b0011_0100_000_0100_0_0001_0101; // analogue audio path control
localparam DAPC  = 24'b0011_0100_000_0101_0_0000_0000; // digital audio path control
localparam PDC   = 24'b0011_0100_000_0110_0_0000_0000; // power down control
localparam DAIF  = 24'b0011_0100_000_0111_0_0100_0010; // digital audio interface format
localparam SC    = 24'b0011_0100_000_1000_0_0001_1001; // sampling control
localparam AC    = 24'b0011_0100_000_1001_0_0000_0001; // active control

logic state_r, state_w;
logic o_finished_r, o_finished_w;
logic o_sclk_r, o_sclk_w;
logic o_sdat_r, o_sdat_w;
logic o_oen_r, o_oen_w;
logic [2:0] sentence_r, sentence_w;
logic [4:0] bit_r, bit_w;

assign o_finished = o_finished_r;
assign o_sclk     = o_sclk_r;
assign o_sdat     = o_sdat_r;
assign o_oen      = o_oen_r;

always_comb begin
    case(state_r) 
        S_IDLE: begin
            if(i_start) begin
                state_w = S_START;
                o_finished_w = o_finished_r;
                o_sclk_w = o_sclk_r;
                o_sdat_w = o_sdat_r;
                o_oen_w = o_oen_r;
                sentence_w = sentence_r;
                bit_w = bit_r;
            end
            else begin
                state_w = S_IDLE;
                o_finished_w = o_finished_r;
                o_sclk_w = o_sclk_r;
                o_sdat_w = o_sdat_r;
                o_oen_w = o_oen_r;
                sentence_w = sentence_r;
                bit_w = bit_r;
            end
        end
        S_START: begin
            if(!o_oen_r) begin
                o_oen_w = !o_oen_r;
            end
            else if(o_oen_r && bit_r % 8 === 0 && bit_r != 0) begin
                o_oen_w = !o_oen_r;
                o_sdat_w = 1'bz;
                if(bit_r === 24) begin
                    bit_w = 0;
                    sentence_w = sentence_r + 1;
                end
                else begin
                    bit_w = bit_r;
                    sentence_w = sentence_r;
                end
            end
            else begin
                o_sclk_w = !o_sclk_r;
                if(o_sclk_r) begin
                    bit_w = bit_r + 1;
                    sentence_w = sentence_r;
                    o_oen_w = o_oen_r;
                    case(sentence_r) 
                        3'd0: begin
                            o_sdat_w = RESET[bit_r];
                        end
                        3'd1: begin
                            o_sdat_w = AAPC[bit_r];
                        end
                        3'd2: begin
                            o_sdat_w = DAPC[bit_r];
                        end
                        3'd3: begin
                            o_sdat_w = PDC[bit_r];
                        end
                        3'd4: begin
                            o_sdat_w = DAIF[bit_r];
                        end
                        3'd5: begin
                            o_sdat_w = SC[bit_r];
                        end
                        3'd6: begin
                            o_sdat_w = AC[bit_r];
                        end
                        default: begin
                        end
                    endcase
                end
                else begin
                    bit_w = bit_r;
                    sentence_w = sentence_r;
                    o_oen_w = o_oen_r;
                    o_sdat_w = o_sdat_r;
                end
            end

        end
    endcase
end

always_ff @(posedge i_clk_100K or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state_r      <= S_IDLE;
        o_finished_r <= 1'b0;
        o_sclk_r     <= 1'b1;
        o_sdat_r     <= 1'b1;
        o_oen_r      <= 1'b1;
        sentence_r   <= 3'd0;
        bit_r        <= 5'd0;
    end
    else begin
        state_r      <= state_w;
        o_finished_r <= o_finished_w;
        o_sclk_r     <= o_sclk_w;
        o_sdat_r     <= o_sdat_w;
        o_oen_r      <= o_oen_w;
        sentence_r   <= sentence_w;
        bit_r        <= bit_w;
    end
end

endmodule