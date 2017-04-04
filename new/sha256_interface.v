module sha256_interface(
	input clk,           
	input rst,  
	input load, 
	input init,
	input iv_control,
	input [1:0] control,
	input [31:0] Hash_end0, 
    input [31:0] Hash_end1,
    input [31:0] Hash_end2, 
    input [31:0] Hash_end3,
    input [31:0] Hash_end4,
    input [31:0] Hash_end5, 
    input [31:0] Hash_end6, 
    input [31:0] Hash_end7,
	output EN,
	output reg [6:0] i,
    input busy, 
    output [31:0] nonce,
    output [31:0] idata32 
);  
reg [2:0] state;
reg [2:0] next_state;
reg [15:0] idata;
reg [4:0] Dnum;

reg [31:0] nonce_r;
//wire [31:0] nonce;

reg [6:0] counter;
reg load_delay;
//reg [6:0] i;
reg [2:0] id;

wire [4:0] constant;
assign constant = (rst) ? 5'b00000 : (iv_control && (control == 2'b00)) ? 5'b10110 : 5'b00000;

    assign EN = ((state == 3'b010) && (~Dnum[0]))? 1'b1 : 1'b0; 

    always @(posedge clk)
    begin
        if(rst) load_delay<=0;
        else load_delay <= load;
    end
    
    always @(posedge clk)
        begin
            if(rst) counter<=0;
            else if(counter == 95 - constant) counter<=0;
            else if(load_delay) counter<=counter + 1;
        end
    
    always @(posedge clk)
        begin
            if(rst) id<=0;
            else if(i == 'd32) id <= 1;
            else if(i == 'd64) id <= 2;
            else if((id == 2) && (i==96)) id <= 1;
        end
    
    always @(posedge clk)
        begin
            if(rst) i<=0;
            else if(init)begin 
                if(iv_control && (control == 2'b00))
                    i<= id*32 + 9;
                else    
                    i<= id*32 + 1;
            end
            else if(counter % 3 == 1) i<= i + 1;
            else if((i == 32) || (i == 64) || (i == 96)) i<=0;
        end

    always @(posedge clk)
    begin
        if(rst) nonce_r <= 32'h9546a140;
        else if((id == 2) && (i == 96)) nonce_r <= nonce_r + 1;
    end

    assign nonce = {nonce_r[7:0],nonce_r[15:8],nonce_r[23:16],nonce_r[31:24]};
    
    always @(posedge clk)
        begin
            case(i)
               7'b0000001: idata <= 16'h0100;  
               7'b0000010: idata <= 16'h0000;
               7'b0000011: idata <= 16'h81cd;
               7'b0000100: idata <= 16'h02ab;
               7'b0000101: idata <= 16'h7e56;
               7'b0000110: idata <= 16'h9e8b;
               7'b0000111: idata <= 16'hcd93;
               7'b0001000: idata <= 16'h17e2;
               7'b0001001: idata <= 16'hfe99;
               7'b0001010: idata <= 16'hf2de;
               7'b0001011: idata <= 16'h44d4;
               7'b0001100: idata <= 16'h9ab2;
               7'b0001101: idata <= 16'hb885;
               7'b0001110: idata <= 16'h1ba4;
               7'b0001111: idata <= 16'ha308;
               7'b0010000: idata <= 16'h0000;
               7'b0010001: idata <= 16'h0000;
               7'b0010010: idata <= 16'h0000;
               7'b0010011: idata <= 16'he320; 
               7'b0010100: idata <= 16'hb6c2;
               7'b0010101: idata <= 16'hfffc;
               7'b0010110: idata <= 16'h8d75;
               7'b0010111: idata <= 16'h0423;
               7'b0011000: idata <= 16'hdb8b;
               7'b0011001: idata <= 16'h1eb9;
               7'b0011010: idata <= 16'h42ae;
               7'b0011011: idata <= 16'h710e;
               7'b0011100: idata <= 16'h951e;
               7'b0011101: idata <= 16'hd797;
               7'b0011110: idata <= 16'hf7af;
               7'b0011111: idata <= 16'hfc88;
               7'b0100000: idata <= 16'h92b0;
               7'b0100001: idata <= 16'hf1fc;
               7'b0100010: idata <= 16'h122b;
               7'b0100011: idata <= 16'hc7f5;
               7'b0100100: idata <= 16'hd74d;
               7'b0100101: idata <= 16'hf2b9;
               7'b0100110: idata <= 16'h441a;
               7'b0100111: idata <= nonce[31:16];
               7'b0101000: idata <= nonce[15:0];
               7'b0101001: idata <= 16'h8000;
               7'b0101010: idata <= 16'h0000;
               7'b0101011: idata <= 16'h0000;
               7'b0101100: idata <= 16'h0000;
               7'b0101101: idata <= 16'h0000;
               7'b0101110: idata <= 16'h0000;
               7'b0101111: idata <= 16'h0000;
               7'b0110000: idata <= 16'h0000;
               7'b0110001: idata <= 16'h0000;
               7'b0110010: idata <= 16'h0000;
               7'b0110011: idata <= 16'h0000;
               7'b0110100: idata <= 16'h0000;
               7'b0110101: idata <= 16'h0000;
               7'b0110110: idata <= 16'h0000;
               7'b0110111: idata <= 16'h0000;
               7'b0111000: idata <= 16'h0000;
               7'b0111001: idata <= 16'h0000;
               7'b0111010: idata <= 16'h0000;
               7'b0111011: idata <= 16'h0000;
               7'b0111100: idata <= 16'h0000;
               7'b0111101: idata <= 16'h0000;
               7'b0111110: idata <= 16'h0000;
               7'b0111111: idata <= 16'h0000;
               7'b1000000: idata <= 16'h0280;
               7'b1000001: idata <= Hash_end0[31:16];
               7'b1000010: idata <= Hash_end0[15:0];
               7'b1000011: idata <= Hash_end1[31:16];
               7'b1000100: idata <= Hash_end1[15:0];
               7'b1000101: idata <= Hash_end2[31:16];
               7'b1000110: idata <= Hash_end2[15:0];
               7'b1000111: idata <= Hash_end3[31:16];
               7'b1001000: idata <= Hash_end3[15:0];
               7'b1001001: idata <= Hash_end4[31:16];
               7'b1001010: idata <= Hash_end4[15:0];
               7'b1001011: idata <= Hash_end5[31:16];
               7'b1001100: idata <= Hash_end5[15:0];
               7'b1001101: idata <= Hash_end6[31:16];
               7'b1001110: idata <= Hash_end6[15:0];
               7'b1001111: idata <= Hash_end7[31:16];
               7'b1010000: idata <= Hash_end7[15:0];
               7'b1010001: idata <= 16'h8000;
               7'b1010010: idata <= 16'h0000;
               7'b1010011: idata <= 16'h0000;
               7'b1010100: idata <= 16'h0000;
               7'b1010101: idata <= 16'h0000;
               7'b1010110: idata <= 16'h0000;
               7'b1010111: idata <= 16'h0000;
               7'b1011000: idata <= 16'h0000;
               7'b1011001: idata <= 16'h0000;
               7'b1011010: idata <= 16'h0000;
               7'b1011011: idata <= 16'h0000;
               7'b1011100: idata <= 16'h0000;
               7'b1011101: idata <= 16'h0000;
               7'b1011110: idata <= 16'h0000;
               7'b1011111: idata <= 16'h0000;
               7'b1100000: idata <= 16'h0100;
            endcase
         end
     
reg [31:0] idata_r; 
always @(posedge clk or negedge rst) begin
   if (rst) Dnum <= 5'd0;                              
   else if ((state == 3'b001) || (state == 3'b100)) Dnum <= Dnum + 1;  
   else if (Dnum == 'd32) Dnum <= 5'd0;
	else Dnum <= Dnum;
end

assign idata32 = idata_r;
always @(posedge clk or negedge rst) begin
	if (rst) idata_r <= 32'h00000000;
	else if (state == 3'b001) idata_r <= {idata_r[15:0],idata};
	else idata_r <= idata_r;
end

always @(posedge clk or negedge rst)begin
	if (rst) state <= 3'b000;
   else state <= next_state;
end


always @(load or state or busy) begin   
   case (state)
      3'b000      : begin                         
         if (load) next_state <= 3'b001;               
         else next_state <= 3'b000;
      end

      3'b001  : next_state <= 3'b010;             
     
      3'b010  : begin                            
         if (~busy) next_state <= 3'b000;        
         else next_state <= 3'b010;
      end         
      
      3'b100  : next_state <= 3'b000;

      default: next_state <= 3'b000;
   endcase
end



endmodule
