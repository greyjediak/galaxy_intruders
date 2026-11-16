`timescale 1ns / 1ps
// frame reciever, 581 feature
// Behavior: collects the 11 bits, checks start bit, stop bit and parity, reset behvaior for stalls


module ps2_rx #(
    parameter int TIMEOUT_TICKS = 200
)(
    input logic clk,
    input logic rst,
    input logic clk_fall, //received from ps2_sync
    input logic data_s, // safe data from ps2_sync
    input logic tick,
    output logic [7:0] data,
    output logic valid, // good byte on `data`
    output logic frame_err,
    output logic timeout // 1 cycle frame stalled, reset
    );
    logic [10:0] shift_reg; // 11 bits
    logic [3:0] bit_count;   // counts bits arrived so far
    logic [$clog2(TIMEOUT_TICKS+1)-1:0] idle_cnt; // ticks since last bit
    
     logic [10:0] frame;
    assign frame = {data_s, shift_reg[10:1]}; // PS/2 sends lowest bit first

    logic start_ok, stop_ok, parity_ok;
    assign start_ok  = (frame[0]  == 1'b0);
    assign stop_ok   = (frame[10] == 1'b1);
    assign parity_ok = ^frame[9:1];

    always_ff @(posedge clk) begin
        valid     <= 1'b0;
        frame_err <= 1'b0;
        timeout   <= 1'b0;

        if (rst) begin
            shift_reg    <= '0;
            bit_count  <= '0;
            idle_cnt <= '0;
            data     <= '0;
        end 
        else if (clk_fall) begin // a bit has arrived, save it, reset idle counter
            shift_reg    <= frame;
            idle_cnt <= '0;
            if (bit_count == 4'd10) begin // if 11the bit, 
                bit_count <= '0; // reset count for next frame
                if (start_ok && stop_ok && parity_ok) begin
                    data  <= frame[8:1];
                    valid <= 1'b1;
                end else begin
                    frame_err <= 1'b1;
                end
            end else begin
                bit_count <= bit_count + 1'b1; // 
            end
        end  // end else if (clk_fall)
        else if (bit_count != 0 && tick) begin // timeout
            if (idle_cnt == TIMEOUT_TICKS) begin
                bit_count  <= '0;
                idle_cnt <= '0;
                timeout  <= 1'b1;
            end else begin
                idle_cnt <= idle_cnt + 1'b1;
            end
        end
    end
    
endmodule
