`timescale 1ns / 1ps

// Final score of player gets displayed on the four-digit seven segment display during the DONE state
// To illuminate a segment, common anode must be high and cathode signals driven low
// Guide used for display https://www.fpga4student.com/2017/09/seven-segment-led-display-controller-basys3-fpga.html


module seg7_score (
    input logic clk,
    input logic rst,
    input logic [15:0] score_bcd, //Separate into four 4-bit chuncks for each digit on Basys3
    input logic display, //boolean for triggering display; **control signal "display = (state == DONE)"
    output logic [6:0] seg,
    output logic [3:0] an,
    output logic display
);

    logic [16:0] refresh_counter; 
    logic [1:0] sel; 
    logic [3:0] digit;
    logic blank;

    // Refresh cycle for all digits of 1.3ms
    always_ff @(posedge clk) begin
        if (rst)
            refresh_counter <= '0;
        else 
            refresh_counter <= refresh_counter + 1'b1;
    end

    // Selects top 2 bits of refresh_counter for digit selection
    assign sel = refresh_counter[16:15];
    assign dp = 1'b1;

    always_comb begin
        case (sel)
            2'b00: digit = score_bcd[3:0];
            2'b01: digit = score_bcd[7:4];
            2'b10: digit = score_bcd[11:8];
            2'b11: digit = score_bcd[15:12];
            default: digit = score_bcd[15:12];
        endcase 

        // Leave LEDs of leading zeros blank until incremented, ones digit always 0
        case (sel)
            2'b11: blank = (score_bcd[15:12] == 4'd0);
            2'b10: blank = (score_bcd[15:8] == 8'd0);
            2'b01: blank = (score_bcd[15:4] == 12'd0);
            default: blank = 1'b0;
        endcase

        //Set common anodes high, 
        //and when game is on activate the selected digit
        an = 4'b1111;
        if (display & !blank) begin
            an[sel] = 1'b0;
        end

        // {U7,V5,U5,V8,U8,W6,W7} Basys3 mapout
        // {g, f, e, d, c, b, a}  Digit segment
        case (digit)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111;
        endcase
    end

endmodule

