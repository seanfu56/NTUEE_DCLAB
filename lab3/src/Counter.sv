module Counter(
    input i_clk,
    input i_rst_n,
    input i_record,
    input i_play,
    input i_fast,
    input i_pause,
    input [2:0] i_speed,
    output [6:0] o_ten,
    output [6:0] o_one
);

localparam D0 = 7'b1000000;
localparam D1 = 7'b1111001;
localparam D2 = 7'b0100100;
localparam D3 = 7'b0110000;
localparam D4 = 7'b0011001;
localparam D5 = 7'b0010010;
localparam D6 = 7'b0000010;
localparam D7 = 7'b1011000;
localparam D8 = 7'b0000000;
localparam D9 = 7'b0010000;

localparam freq = 32'd12000000;
logic [3:0] ten;
logic [3:0] one;
logic [6:0] o_ten_w, o_one_w;
logic [31:0] counter_r, counter_w;
logic [6:0] second_r, second_w;
logic [3:0] c_r, c_w;

assign one = second_r % 10;
assign ten = second_r / 10;
assign o_ten = o_ten_w;
assign o_one = o_one_w;

always_comb begin
    if(counter_r === freq) begin
        counter_w = 32'd0;
        second_w = second_r + 1;
        c_w = c_r;
    end
    else if(i_record === 1) begin
        counter_w = counter_r + 1;
        second_w = second_r;        
        c_w = c_r;
    end
    else if(i_play === 1 && i_fast === 1) begin
        counter_w = counter_r + 1 + i_speed;
        second_w = second_r;
        c_w = c_r;
    end
    else if(i_play === 1 && i_fast === 0) begin
        if(c_r >= i_speed) begin
            c_w = 0;
            counter_w = counter_r + 1;
            second_w = second_r;
        end
        else begin
            c_w = c_r + 1;
            counter_w = counter_r;
            second_w = second_r;
        end
    end
    else if(i_pause === 1) begin
        counter_w = counter_r;
        second_w = second_r;
        c_w = c_r;
    end
    else begin
        counter_w = 0;
        second_w = 0;
        c_w = c_r;
    end
    case(one) 
    4'd0: begin
        o_one_w = D0;
    end
    4'd1: begin
        o_one_w = D1;
    end
    4'd2: begin
        o_one_w = D2;
    end
    4'd3: begin
        o_one_w = D3;
    end
    4'd4: begin
        o_one_w = D4;
    end
    4'd5: begin
        o_one_w = D5;
    end
    4'd6: begin
        o_one_w = D6;
    end
    4'd7: begin
        o_one_w = D7;
    end
    4'd8: begin
        o_one_w = D8;
    end
    4'd9: begin
        o_one_w = D9;
    end
    default: begin
        o_one_w = 7'b1111111;
    end
    endcase
    case(ten) 
    4'd0: begin
        o_ten_w = D0;
    end
    4'd1: begin
        o_ten_w = D1;
    end
    4'd2: begin
        o_ten_w = D2;
    end
    4'd3: begin
        o_ten_w = D3;
    end
    4'd4: begin
        o_ten_w = D4;
    end
    4'd5: begin
        o_ten_w = D5;
    end
    4'd6: begin
        o_ten_w = D6;
    end
    4'd7: begin
        o_ten_w = D7;
    end
    4'd8: begin
        o_ten_w = D8;
    end
    4'd9: begin
        o_ten_w = D9;
    end
    default: begin
        o_ten_w = 7'b1111111;
    end
    endcase
end

always_ff @(posedge i_clk, negedge i_rst_n) begin
    if(!i_rst_n) begin
        counter_r <= 32'd0;
        second_r <= 7'd0;
        c_r <= 4'd0;
    end
    else begin
        counter_r <= counter_w;
        second_r <= second_w;
        c_r <= c_w;
    end
end

endmodule


module Int_to_seven(
    input [2:0] number,
    output [6:0] seven
);

localparam D0 = 7'b1000000;
localparam D1 = 7'b1111001;
localparam D2 = 7'b0100100;
localparam D3 = 7'b0110000;
localparam D4 = 7'b0011001;
localparam D5 = 7'b0010010;
localparam D6 = 7'b0000010;
localparam D7 = 7'b1011000;
localparam D8 = 7'b0000000;
localparam D9 = 7'b0010000;
logic [6:0] seven_w;
assign seven = seven_w;

always_comb begin
    case(number) 
    3'd0: begin
        seven_w = D0;
    end
    3'd1: begin
        seven_w = D1;
    end
    3'd2: begin
        seven_w = D2;
    end
    3'd3: begin
        seven_w = D3;
    end
    3'd4: begin
        seven_w = D4;
    end
    3'd5: begin
        seven_w = D5;
    end
    3'd6: begin
        seven_w = D6;
    end
    3'd7: begin
        seven_w = D7;
    end
    endcase    
end

endmodule