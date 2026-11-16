`timescale 1ns / 1ps
// PS2Clk and PS2Data pass through 2 flip flops before using since they have no timing relationship to Basys clock
// Turns PS2Clk low into a one cylce pulse on our 100MHz clock
// Ouputs the synchronized data and the 1 cycle pulse
// referenced Digilent's PS2Receiver and debouncer.sv files on their Github https://github.com/Digilent/Basys-3-Keyboard/blob/master/src/hdl/PS2Receiver.v

//C17 and B17 are the raw two wired from the keyboard

module ps2_sync(
    input logic clk,
    input logic rst,
    input logic ps2_clk, //raw pin C17
    input logic ps2_data, // raw pin B17
    output logic data_s, //safe synced data that the rest of the design will read
    output logic clk_fall //1 tick pulse saying that PS2Clk went high-> low, so take bit now
    );
    logic [2:0] clk_sr; // shift register for PS/2 clock
    logic [1:0] data_sr; // 2 bit reigster for data
    
    always_ff @(posedge clk) begin
        if (rst) begin   // fill both registers with 1s for idle high
            clk_sr <= 3'b111; // PS2 idles high4
            data_sr <= 2'b11;
         end 
         else begin 
            clk_sr <= {clk_sr[1:0], ps2_clk}; // concatenate first look, second look, and raw pin
            data_sr <= {data_sr[0], ps2_data}; // concatenate first look, and raw pin
         end
    end
    assign data_s   = data_sr[1]; // this is the safe data bit
    assign clk_fall = clk_sr[2] & ~clk_sr[1];   // edge detector
endmodule
