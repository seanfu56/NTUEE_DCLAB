module lcd(
    input i_clk;
    inout [7:0] io_lcd_data;
    output o_lcd_on;
    output o_lcd_blon;
    output o_lcd_rw;
    output o_lcd_en;
    output o_lcd_rs;
);
assign o_lcd_on = 1'b1;
assign o_lcd_blon = 1'b1;

wire DLY_RST;
Reset_Delay ro (.i_clk(i_clk), o_reset(dly_rst));

LCD_TEST u5(
    .i_clk(i_clk),
    .i_rst_n(dly_rst),
    .lcd_data(io_lcd_data),
    .lcd_rw(o_lcd_rw),
    .lcd_en(o_lcd_en),
    .lcd_rs(o_lcd_rs)
);

endmodule

module  LCD_TEST (    //    Host Side
    input i_clk,
    input i_rst_n,
    output [7:0] o_lcd_data,
    output o_lcd_rw,
    output o_lcd_en,
    output o_lcd_rs
);
//    Internal Wires/Registers
reg    [5:0]    LUT_INDEX;
reg    [8:0]    LUT_DATA;
reg    [5:0]    mLCD_ST;
reg    [17:0]   mDLY;
reg             mLCD_Start;
reg    [7:0]    mLCD_DATA;
reg             mLCD_RS;
wire            mLCD_Done;

parameter    LCD_INTIAL   =    0;
parameter    LCD_LINE1    =    5;
parameter    LCD_CH_LINE  =    LCD_LINE1+16;
parameter    LCD_LINE2    =    LCD_LINE1+16+1;
parameter    LUT_SIZE     =    LCD_LINE1+32+1;

always_ff@(posedge iCLK or negedge iRST_N)
begin
    if(!iRST_N) begin
        LUT_INDEX    <=    0;
        mLCD_ST      <=    0;
        mDLY         <=    0;
        mLCD_Start   <=    0;
        mLCD_DATA    <=    0;
        mLCD_RS      <=    0;
    end else
    begin
        if(LUT_INDEX<LUT_SIZE)
        begin
            case(mLCD_ST)
            0: begin
                mLCD_DATA    <=    LUT_DATA[7:0];
                mLCD_RS      <=    LUT_DATA[8];
                mLCD_Start   <=    1;
                mLCD_ST      <=    1;
            end
            1: begin
                if(mLCD_Done) begin
                    mLCD_Start    <=    0;
                    mLCD_ST       <=    2;                    
                end
            end
            2: begin
                if(mDLY<18'h3FFFE) begin    // 5.2ms
                    mDLY    <=    mDLY+1;
                end
                else begin
                    mDLY    <=    0;
                    mLCD_ST    <=    3;
                end
            end
            3:  begin
                LUT_INDEX    <=    LUT_INDEX+1;
                mLCD_ST    <=    0;
            end
            endcase
        end
    end
end
 
always
begin
    case(LUT_INDEX)
    //    Initial
    LCD_INTIAL+0:    LUT_DATA    <=    9'h038; //Fun set
    LCD_INTIAL+1:    LUT_DATA    <=    9'h00C; //dis on
    LCD_INTIAL+2:    LUT_DATA    <=    9'h001; //clr dis
    LCD_INTIAL+3:    LUT_DATA    <=    9'h006; //Ent mode
    LCD_INTIAL+4:    LUT_DATA    <=    9'h080; //set ddram address
    //    Line 1
    LCD_LINE1+0:    LUT_DATA    <=    9'h120;    //    http://halflife.cnblogs.com
    LCD_LINE1+1:    LUT_DATA    <=    9'h168; // h
    LCD_LINE1+2:    LUT_DATA    <=    9'h174; // t
    LCD_LINE1+3:    LUT_DATA    <=    9'h174; // t
    LCD_LINE1+4:    LUT_DATA    <=    9'h170; // p
    LCD_LINE1+5:    LUT_DATA    <=    9'h13A; // :
    LCD_LINE1+6:    LUT_DATA    <=    9'h12F; // /
    LCD_LINE1+7:    LUT_DATA    <=    9'h12F; // /
    LCD_LINE1+8:    LUT_DATA    <=    9'h168; // h
    LCD_LINE1+9:    LUT_DATA    <=    9'h161; // a
    LCD_LINE1+10:   LUT_DATA    <=    9'h16C; // l
    LCD_LINE1+11:   LUT_DATA    <=    9'h166; // f
    LCD_LINE1+12:   LUT_DATA    <=    9'h16C; // l
    LCD_LINE1+13:   LUT_DATA    <=    9'h169; // i
    LCD_LINE1+14:   LUT_DATA    <=    9'h166; // f
    LCD_LINE1+15:   LUT_DATA    <=    9'h165; // e
    //    Change Line
    LCD_CH_LINE:    LUT_DATA    <=    9'h0C0;
    //    Line 2
    LCD_LINE2+0:    LUT_DATA    <=    9'h12E;    // .
    LCD_LINE2+1:    LUT_DATA    <=    9'h163; // c
    LCD_LINE2+2:    LUT_DATA    <=    9'h16E; // n
    LCD_LINE2+3:    LUT_DATA    <=    9'h162; // b
    LCD_LINE2+4:    LUT_DATA    <=    9'h16C; // l
    LCD_LINE2+5:    LUT_DATA    <=    9'h16F; // o
    LCD_LINE2+6:    LUT_DATA    <=    9'h167; // g
    LCD_LINE2+7:    LUT_DATA    <=    9'h173; // s\
    LCD_LINE2+8:    LUT_DATA    <=    9'h12E; // .
    LCD_LINE2+9:    LUT_DATA    <=    9'h163; // c
    LCD_LINE2+10:   LUT_DATA    <=    9'h16F; // o
    LCD_LINE2+11:   LUT_DATA    <=    9'h16D; // m
    LCD_LINE2+12:   LUT_DATA    <=    9'h120;
    LCD_LINE2+13:   LUT_DATA    <=    9'h120;
    LCD_LINE2+14:   LUT_DATA    <=    9'h120;
    LCD_LINE2+15:   LUT_DATA    <=    9'h120;
    default:        LUT_DATA    <=    9'h000;
    endcase
end
 
LCD_Controller u0(    //    Host Side
    .iDATA(mLCD_DATA),
    .iRS(mLCD_RS),
    .iStart(mLCD_Start),
    .oDone(mLCD_Done),
    .iCLK(iCLK),
    .iRST_N(iRST_N),
    //    LCD Interface
    .LCD_DATA(LCD_DATA),
    .LCD_RW(LCD_RW),
    .LCD_EN(LCD_EN),
    .LCD_RS(LCD_RS)    
);
 
endmodule
