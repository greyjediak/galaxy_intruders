`timescale 1ns / 1ps

/*
    Self-checking testbench for seven-segment score display logic 
    Tests refresh counter logic, select logic, reset, and display enable
    Tests that digits 0-9 map to correctly, 
    Verifies that a BCD exceeding 9 is invalid and turns off display
    Tests leading-zero behavior and blanking behavior

    To Run: Set tb_seg7_score.sv as the top in hierarchy 
    -> Run Behavioral Simulation -> Run All to see full tests
*/

module tb_seg7_score;

    logic clk, rst;
    logic [15:0] score_bcd;
    logic display;
    logic [6:0] seg;
    logic [3:0] an;
    logic dp;

    //Expected values for all inputs and outputs
    logic [1:0] expected_sel;
    logic [3:0] expected_digit;
    logic expected_blank;
    logic [3:0] expected_an;
    logic [6:0] expected_segment;
    logic [3:0] seen_an; //verify which anodes the DUT actually lit during a case
    logic [3:0] expected_mask; //verify digit positions that should have been lit are lit

    int errors = 0;

    seg7_score dut ( //DUT instantiation
        .clk(clk),
        .rst(rst),
        .score_bcd(score_bcd),
        .display(display),
        .seg(seg),
        .an(an),
        .dp(dp)
    );

    //Generate simulated clock signal
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    //Error output check
    task automatic check(
        input logic condition,
        input string message
    );

        if (condition !== 1'b1) begin
            $error("%s", message);
            errors++;
        end
    endtask

    //Segments are lit for each digit, active high. 
    //DUT drives it active low, so expected seg is inverse
    function automatic logic [6:0] seg_on(
        input logic [3:0] num
    );
        case (num)
            4'd0: return 7'b0111111;
            4'd1: return 7'b0000110;
            4'd2: return 7'b1011011;
            4'd3: return 7'b1001111;
            4'd4: return 7'b1100110;
            4'd5: return 7'b1101101;
            4'd6: return 7'b1111101;
            4'd7: return 7'b0000111;
            4'd8: return 7'b1111111;
            4'd9: return 7'b1101111;
            default: return 7'b0000000;
        endcase
    endfunction

    //Which digit positions should light up for a score, i.e. bit n = 1 means digit n is lit
        function automatic logic [3:0] visible_mask(
        input logic [15:0] s //segments
    );
        logic [3:0] m;
        m[0] = 1'b1;    //ones digit always on
        m[1] = (s[15:4] != 12'd0);
        m[2] = (s[15:8] != 8'd0);
        m[3] = (s[15:12] != 4'd0);
        return m;
    endfunction

    logic [16:0] ref_counter; //refresh counter to mirror DUT refresh counter 
    logic check_en = 1'b0; //check enable after reset

    always_ff @(posedge clk) begin
        if (rst) 
            ref_counter <= '0;
        else     
            ref_counter <= ref_counter + 1'b1;
    end

    //Expected logic behavior using select and refresh counter
    always_comb begin
        expected_sel = ref_counter[16:15];

        //BCD byte for selected digit
        case (expected_sel)
            2'b00: expected_digit = score_bcd[3:0];
            2'b01: expected_digit = score_bcd[7:4];
            2'b10: expected_digit = score_bcd[11:8];
            2'b11: expected_digit = score_bcd[15:12];
            default: expected_digit = score_bcd[15:12];
        endcase

        //Lead zero blanks 
        case (expected_sel)
            2'b01: expected_blank = (score_bcd[15:4] == 12'd0);
            2'b10: expected_blank = (score_bcd[15:8] == 8'd0);
            2'b11: expected_blank = (score_bcd[15:12] == 4'd0);
            default: expected_blank = 1'b0;
        endcase

        expected_an = 4'b1111; //anodes active low
            if (display && !expected_blank)
                expected_an[expected_sel] = 1'b0; //if display is on and digit is not supposed to be blank, light up

        expected_segment = ~seg_on(expected_digit);
    end

    //Compare DUT to expected model on every falling edge 
    always @(negedge clk) begin
        if (check_en) begin
            if (an !== expected_an) begin
                $error("an mismatch: got %0b expected %0b (score=%0h display=%0b sel=%0d)",
                    an, expected_an, score_bcd, display, expected_sel);
                errors++;
            end
 
            if (seg !== expected_segment) begin
                $error("seg mismatch: got %0b expected %0b (digit=%0h sel=%0d)",
                    seg, expected_segment, expected_digit, expected_sel);
                errors++;
            end
 
            if (dp !== 1'b1) begin
                $error("dp should always be 1 (off), got %0b", dp);
                errors++;
            end
 
            //At most one digit may be enabled at a time to prevent duplicated digit
            if ($countones(~an) > 1) begin
                $error("more than one anode enabled: an=%0b", an);
                errors++;
            end
 
            //Record every anode that was driven low
            seen_an |= ~an;
        end
    end
 
    //Test case to apply a score, sweep a full refresh cycle where sel goes through each bit config, 
    //check which digits actually lit
    task automatic run_case(
        input logic [15:0] s,
        input logic        d
    );
        //Drive inputs just after posedge so they never race the negedge checker
        @(posedge clk); 
        #1;
        score_bcd = s;
        display   = d;
        seen_an   = '0;
 
        //One full refresh sweep, 2^17 clocks, plus margin
        repeat ((1 << 17) + 16) @(posedge clk);
        #1;
        
        //Determine what digits should be lit
        expected_mask = d ? visible_mask(s) : 4'b0000;
        check(seen_an === expected_mask, $sformatf("Lit digits wrong for score=%0h display=%0b: saw %0b expected %0b",
                        s, d, seen_an, expected_mask));
    endtask
 
    //Main test sequence
    initial begin
        rst = 1'b1; //Defaults
        score_bcd = 16'h0000;
        display = 1'b0;
        seen_an = '0;
 
        //Initial reset
        repeat (3) @(posedge clk);
        #1;
        score_bcd = 16'h1234;
        display = 1'b1;
        rst = 1'b0;
        check_en = 1'b1;
 
        //Right after reset, the counter is 0 -> sel = 0, ones digit (4) selected
        @(negedge clk);
        check(an === 4'b1110, $sformatf("After reset expected an=1110, got %0b", an));
        check(seg === ~seg_on(4'd4), $sformatf("After reset expected seg for digit 4, got %0b", seg));
 
        //Directed scores, display on. Covers all-zero, each digit position alone,
        //every digit value 0-9, full score, and an invalid BCD value.
        run_case(16'h0000, 1'b1);   //only ones digit shown
        run_case(16'h0007, 1'b1);
        run_case(16'h0010, 1'b1);   //tens digit boundary
        run_case(16'h0042, 1'b1);
        run_case(16'h0100, 1'b1);   //hundreds boundary
        run_case(16'h0359, 1'b1);
        run_case(16'h1000, 1'b1);   //thousands boundary
        run_case(16'h1234, 1'b1);
        run_case(16'h5680, 1'b1);
        run_case(16'h9999, 1'b1);
        run_case(16'hA5F3, 1'b1);   //Test invalid BCD -> seg should be all off (1111111)
 
        //Display off, every anode must stay high regardless of score
        run_case(16'h1234, 1'b0);
        run_case(16'h0000, 1'b0);
 
        //Display switched back on
        run_case(16'h4321, 1'b1);
 
        //Mid-run reset, just ensure sel != 0
        //Wait until the counter has moved to sel = 2 so the
        //reset visibly has to pull it back to sel = 0.
        while (ref_counter[16:15] != 2'b10) @(posedge clk);
        #1;

        @(negedge clk);
        check(an === 4'b1011, //score 4321, sel = 2 -> digit 2 (hundreds) enabled
                $sformatf("Before mid-run reset expected an=1011, got %0b", an));

        @(posedge clk); #1;
        rst = 1'b1;
            
        @(posedge clk); #1; //reset sampled here -> counter = 0
        rst = 1'b0;
        
        @(negedge clk);
        check(an === 4'b1110,
                $sformatf("After mid-run reset expected an=1110, got %0b", an));
 
        //Summary
        if (errors == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED with %0d error(s)", errors);
        $finish;
    end
           
endmodule