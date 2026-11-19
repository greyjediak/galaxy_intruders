`timescale 1ns / 1ps

//**WIP**
//481 Baseline Requirement/simpler version for the 581 comparison extension
//Same command interface as the keyboard logic,
//Player input using the Basys3 buttons

module button_input #(parameter int debouncer = 1_000_000) (
    input logic clk,
    input logic rst,
    input logic btnC,
    input logic btnU,
    input logic btnL,
    input logic btnR,
    input logic btnD,
    output logic cmd_left,
    output logic cmd_right,
    output logic cmd_shoot,
    output logic cmd_start,
    output logic cmd_reset
);

    debouncer #(/* debounce */()) u_dbL (

    );

     debouncer #(/* debounce */()) u_dbR (

    );

     debouncer #(/* debounce */()) u_dbU (

    );

     debouncer #(/* debounce */()) u_dbD (

    );

endmodule