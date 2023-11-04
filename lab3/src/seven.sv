module Seven(
    input [3:0] i_speed,
    output [6:0] o_fast_or_slow,
    output [6:0] o_speed
);

parameter D0 = 7'b1000000;
parameter D1 = 7'b1111001;
parameter D2 = 7'b0100100;
parameter D3 = 7'b0110000;
parameter D4 = 7'b0011001;
parameter D5 = 7'b0010010;
parameter D6 = 7'b0000010;
parameter D7 = 7'b1011000;
parameter D8 = 7'b0000000;
parameter D9 = 7'b0010000;

logic [6:0] o_speed_w;

assign o_fast_or_slow = i_speed[3] ? 7'b0001110 : 7'b0010010;
assign o_speed = o_speed_w;

always_comb begin
    case(i_speed[2:0])
        3'd0: begin
            o_speed_w = D1;
        end
        3'd1: begin
            o_speed_w = D2;
        end
        3'd2: begin
            o_speed_w = D3;
        end
        3'd3: begin
            o_speed_w = D4;
        end
        3'd4: begin
            o_speed_w = D5;
        end
        3'd5: begin
            o_speed_w = D6;
        end
        3'd6: begin
            o_speed_w = D7;
        end
        3'd7: begin
            o_speed_w = D8;
        end
    endcase
end

endmodule