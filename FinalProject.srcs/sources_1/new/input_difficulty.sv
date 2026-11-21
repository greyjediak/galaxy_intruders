`timescale 1ns / 1ps

//runtime configuration using sw[1:0] to determine game difficulty
//the input switches are synchronized using 2 FFs as they occur outside of the Basys3 clock

module input_difficulty (
    input logic clk,
    input logic rst,    //active high synchronous reset
    input logic [1:0] sw_diff,  //Basys3 switches sw[1:0]
    input logic capture_configuration, //Capture switch configuration on game start
    output logic [1:0] diff_mode,
    output logic [7:0] step_period
);
    // ASYNC_REG keeps synchronizer registers intact and physically close to resolve metastability
    (* ASYNC_REG = "TRUE" *) logic [1:0] sw_meta, sw_sync;

    always_ff @(posedge clk) begin
        if (rst) begin
            sw_meta <= '0;
            sw_sync <= '0;
            diff_mode <= '0;
        end
        else begin
            sw_meta <= sw_diff;
            sw_sync <= sw_meta;
        if (capture_configuration)
            diff_mode <= sw_sync;
        end
    end

    // Game difficulty logic for each switch configuration
    always_comb begin
        case (diff_mode)
            2'b00: step_period = 8'd45; // Easy mode, 0.75s per step
            2'b01: step_period = 8'd30; // Medium/Normal mode, 0.5s per step
            2'b10: step_period = 8'd18; // Hard mode, 0.3s per step
            2'b11: step_period = 8'd6;  // Extreme mode, 0.1s per step
            default: step_period = 8'd30;
        endcase 
    end
endmodule 


