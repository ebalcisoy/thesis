`timescale 1ns / 1ps

module current_target(
    input clk,
    input rst,
    input [31:0] target32,
    output reg [255:0] target256
    );
    
    reg [7:0] exponent;
    reg [23:0] mantissa;
    
    always @(posedge clk)begin
        if(rst)begin
            exponent <= 1;
            mantissa <= 1;
        end
        else if((target32 > 0) && (exponent == 1))begin
            exponent <= target32[31:24] - 2'h03;
            mantissa <= target32[23:0];    
        end
        /*else if(exponent > 1)
            exponent <= 1;*/ 
    end
    
    always @(posedge clk)begin
        if(rst)
            target256 <= 1;
        else if((target32 > 0) && (exponent > 1) && (target256 == 1))begin
            target256 <= {target256[255:24],mantissa[23:0]};
        end    
        else if((target32 > 0) && (exponent > 1) && (target256 == mantissa))begin
            target256 <= target256 << (exponent*8);
        end
        /*else if(exponent == 3)
            target256 <= target256 * mantissa;*/
    end
endmodule
