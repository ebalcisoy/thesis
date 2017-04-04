module sha256_core(
	input clk,	
	input rst,
	input EN,	
    input init,
    input [6:0] i,
    input iv_control,
    input [1:0] control,
    input [1:0] compare_control,
    input [31:0] nonce,
	input [31:0] idata,
	input [31:0] iv0,
	input [31:0] iv1,
	input [31:0] iv2,
	input [31:0] iv3,
	input [31:0] iv4,
	input [31:0] iv5,
	input [31:0] iv6,
	input [31:0] iv7,
	output [31:0] Hash0,
	output [31:0] Hash1,
	output [31:0] Hash2,
	output [31:0] Hash3,
	output [31:0] Hash4,
	output [31:0] Hash5,
	output [31:0] Hash6,
	output [31:0] Hash7,
	output reg [31:0] a,
	output reg [31:0] e,
//	output reg [31:0] r9,
	output reg out,
//	output reg [7:0]round,
//	output [31:0] k_delay,
//	output [31:0] wt,
//	output [31:0] wire4,
//	output [31:0] wire2,
//	output [31:0] plus,
	
    output busy
	////output valid	
);


/********************************** reg wire ?éŒ¾****************************************************/
//output—p
reg [31:0] Hash0_r;
reg [31:0] Hash1_r;
reg [31:0] Hash2_r;
reg [31:0] Hash3_r;
reg [31:0] Hash4_r;
reg [31:0] Hash5_r;
reg [31:0] Hash6_r;
reg [31:0] Hash7_r;

//SHA256_INTERFACE ‚Ìstate?§Œä—p
reg busy_r;	

//CTRL‚Ö‚Ìoutput
//reg valid_r;

reg [31:0] /*a,*/b,c,/*e,*/f,g,r7,r8,r9,r10;

wire [31:0] ch,sig0,sig1,maj,wire2,wire3,wire4,wire_in;
wire [31:0] vs1,vc1,vc2,vs2,vc3,vs3,vs4,vc4,plus;
//w schedule reg
reg [31:0] w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10_r,w11_r,w12_r,w13_r,w14 ;
reg [31:0] w16,w15;
//w schedule wire
wire [31:0] wt,vc_w1,vs_w1,sig_w0,sig_w1,vs_w2,vc_w2,w_in1,w_in2,k_in; 
reg [31:0] w10,w11,w12/*,w13*/;

reg [7:0]round;	

reg opt_en;
reg [31:0] k; 
wire [31:0] k_delay;
wire [5:0] addr;
wire rd;

wire [2:0] constant;
assign constant = (rst) ? 3'b000 : (iv_control && (control == 2'b00)) ? 3'b101 : 3'b001;
/****************************************************************************************************/
rom rom(.clk(clk), .K(k_delay), .RD(rd), .addr(addr), .opt_en(opt_en), .control(control), .iv_control(iv_control));      //Kt‚ðROM‚©‚ç“Ç‚Ý??‚Þ

carry_save_adder CSA1(.X(r7), .Y(maj), .Z(sig0), .VS(vs1), .VC(vc1));
carry_save_adder CSA2(.X(r10), .Y(sig1), .Z(ch), .VS(vs2), .VC(vc2));
carry_save_adder CSA3(.X(k_in), .Y(wt), .Z(wire_in), .VS(vs3), .VC(vc3));
carry_save_adder CSA4(.X(r8), .Y(ch), .Z(sig1), .VS(vs4), .VC(vc4));
carry_save_adder CSA_w1(.X(w_in1), .Y(w_in2), .Z(sig_w0), .VS(vs_w1), .VC(vc_w1));
carry_save_adder CSA_w2(.X(vs_w1), .Y(vc_w1), .Z(sig_w1), .VS(vs_w2), .VC(vc_w2));

/****************************************************************************************************/

assign rd = (init || EN) ? 1'b1 : 1'b0;     //EN‚ªHigh‚à‚µ‚­‚Íround‚ª0‚Ì??1
assign addr = (iv_control && control == 2'b00 && (init || round > 'd63))? constant : (((iv_control && ~opt_en) || ~iv_control) && init || (round > 'd63)) ? constant - 1 : (iv_control && (control == 2'b00) && opt_en) ? round[5:0] + 'd2 : round[5:0] + 'd1;
/****************************************************************************************************/

always @(posedge clk)begin
    if(rst)
        opt_en <= 0;
    else if(iv_control && (control == 2'b00) && constant == 3'b101 && round == 67)
        opt_en <= 1;
end

assign k_in = (iv_control && control == 2'b00 && opt_en && round < 15) ? k : k_delay;
assign wire_in = (iv_control && control == 2'b00 && opt_en && round >= 15) ? f : wire4;
assign w_in1 = (iv_control && control == 2'b00 && opt_en && round < 27) ? w1 : w0;
assign w_in2 = (iv_control && control == 2'b00 && opt_en && round < 18) ? w10_r : w9;


always @(posedge clk)begin
    if(rst)
        k <= 32'h00000000;
    else if(init && iv_control && control == 2'b00)
        k <= 32'hb956c25b;
    else if(iv_control && control == 2'b00 && rd)
        k <= k_delay; 
end

always @(posedge clk)begin
    if(rst)
        w10 <= 32'h00000000;
    else if(i==34)
        w10 <= idata;
end

always @(posedge clk)begin
    if(rst)
        w11 <= 32'h00000000;
    else if(i==36)
        w11 <= idata;
end

always @(posedge clk)begin
    if(rst)
        w12 <= 32'h00000000;
    else if(i==38)
        w12 <= idata;
end
//assign w10 = (rst) ? 32'h00000000 : (i==34) ? idata : 32'h00000000/*w10*/;
//assign w11 = (rst) ? 32'h00000000 : (i==36) ? idata : 32'h00000000/*w11*/;
//assign w12 = (rst) ? 32'h00000000 : (i==38) ? idata : 32'h00000000/*w12*/;
//assign w13 = (rst) ? 32'h00000000 : (i==40) ? idata : w13;

always @(posedge clk)begin
	if (rst) round <= 0;
   else begin
      if (init) round <= constant - 1;
      else if (EN) begin
         if(out) round <= 0;   
         else if (round < 'd67) round <= round + 1;
         else if (round == 'd67) round <= 0;
         else round <= round;
      end
   	else round <= round;
   end
end

always @(posedge clk)begin
    if(rst) out <= 0;
    else if(round == 'd66) out <= 1;
    else if((compare_control == 2'b10) && (round == 63) && (Hash7 + e != 32'h00000000)) out <= 1;
    else if((compare_control == 2'b10) && (round == 64) && (Hash6 + e != 32'h00000000) && ~out) out <= 1;
    else out <= 0; 
end
//valid signal ctrl

//assign valid = valid_r;	
//always @(posedge clk or negedge rst)begin
//	if (~rst) valid_r <= 0;			
//   else begin
//      if (init) valid_r <= 0;
//      else if (round == 'd67) valid_r <= 1;	
//      else valid_r <= 0;
//   end
//end

//busy
assign busy = (iv_control && control == 2'b00 && opt_en && EN && ((round >= 'd14) && (round <= 'd65)))? 1: (((iv_control && ~opt_en) || ~iv_control) && EN && ((round >= 'd15) && (round <= 'd66))) ? 1 : 0;                                 //output
//assign busy = busy_r;                                 //output
//always @(posedge clk or negedge rst)begin
//	if (~rst) busy_r <= 0;			                  //reset
//   else begin
//      if (round == 'd15) busy_r <= 1;                 //idata‚ð‚·‚×‚Ä?æ‚è??‚ñ‚¾‚çHigh
//      else if (round == 'd66) busy_r <= 0;            //Œv?Z?I—¹‚ÅLow
//      else busy_r <= busy_r;
//   end
//end

/****************************************************************************************************/

//Hash ctrl
assign Hash0 = Hash0_r;
assign Hash1 = Hash1_r;
assign Hash2 = Hash2_r;
assign Hash3 = Hash3_r;
assign Hash4 = Hash4_r;
assign Hash5 = Hash5_r;
assign Hash6 = Hash6_r;
assign Hash7 = Hash7_r; 

//Hash0
always @(posedge clk)begin
	if (rst) Hash0_r <= 0;
   else begin
      if (init) Hash0_r <= iv0;//32'h9524c593;//32'h6a09e667;//                         //init?M?†‚ªHigh‚Ì???‰Šú‰»
      else if(iv_control && (control == 2'b00) && (i==57)) Hash0_r <= iv0;
      else if(iv_control && (control == 2'b00) && opt_en && round == 66) Hash0_r <= a + Hash0_r; 
      else if(((iv_control && ~opt_en) || ~iv_control) && round == 67) Hash0_r <= a + Hash0_r;
      else Hash0_r <= Hash0_r;
   end
end

//Hash1
always @(posedge clk)begin
	if (rst) Hash1_r <= 0;
   else begin
      if (init) Hash1_r <= iv1;//32'h05c56713;//32'hbb67ae85;//                       //init?M?†‚ªHigh‚Ì???‰Šú‰»
      else if(iv_control && (control == 2'b00) && (i==57)) Hash1_r <= iv1;
      else if(iv_control && (control == 2'b00) && opt_en && round == 65) Hash1_r <= a + Hash1_r;
      else if(((iv_control && ~opt_en) || ~iv_control) && round == 66) Hash1_r <= a + Hash1_r;
      else Hash1_r <= Hash1_r;
   end
end

//Hash2
always @(posedge clk)begin
	if (rst) Hash2_r <= 0;
   else begin
      if (init) Hash2_r <= iv2;//32'h16e669ba;//32'h3c6ef372;//                         //init?M?†‚ªHigh‚Ì???‰Šú‰»
      else if(iv_control && (control == 2'b00) && (i==57)) Hash2_r <= iv2;
      else if(iv_control && (control == 2'b00) && opt_en && round == 64) Hash2_r <= a + Hash2_r;
      else if(((iv_control && ~opt_en) || ~iv_control) && round == 65) Hash2_r <= a + Hash2_r;
      else Hash2_r <= Hash2_r;
   end
end

//Hash3
always @(posedge clk)begin
	if (rst) Hash3_r <= 0;
   else begin
      if (init) Hash3_r <= iv3;//32'h2d2810a0;//32'ha54ff53a;//                         //init?M?†‚ªHigh‚Ì???‰Šú‰»
      else if(iv_control && (control == 2'b00) && (i==57)) Hash3_r <= iv3; 
      else if(iv_control && (control == 2'b00) && opt_en && round == 63) Hash3_r <= a + Hash3_r;
      else if(((iv_control && ~opt_en) || ~iv_control) && round == 64) Hash3_r <= a + Hash3_r;
      else Hash3_r <= Hash3_r;
   end
end

//Hash4
always @(posedge clk)begin
	if (rst) Hash4_r <= 0;
   else begin
      if (init) Hash4_r <= iv4;//32'h07e86e37;//32'h510e527f;//                        //init?M?†‚ªHigh‚Ì???‰Šú‰»
      else if(iv_control && (control == 2'b00) && (i==57)) Hash4_r <= iv4;
      else if(iv_control && (control == 2'b00) && opt_en && round == 65) Hash4_r <= e + Hash4_r;
      else if(((iv_control && ~opt_en) || ~iv_control) && round == 66) Hash4_r <= e + Hash4_r;
      else Hash4_r <= Hash4_r;
   end
end

//Hash5
always @(posedge clk)begin
	if (rst) Hash5_r <= 0;
   else begin
      if (init) Hash5_r <= iv5;//32'h2f56a9da;//32'h9b05688c;//                         //init?M?†‚ªHigh‚Ì???‰Šú‰»
      else if(iv_control && (control == 2'b00) && (i==57)) Hash5_r <= iv5;
      else if(iv_control && (control == 2'b00) && opt_en && round == 64) Hash5_r <= e + Hash5_r;
      else if(((iv_control && ~opt_en) || ~iv_control) && round == 65) Hash5_r <= e + Hash5_r;
      else Hash5_r <= Hash5_r;
   end
end

//Hash6
always @(posedge clk)begin
	if (rst) Hash6_r <= 0;
   else begin
      if (init) Hash6_r <= iv6;//32'hcd5bce69;//32'h1f83d9ab;//                          //init?M?†‚ªHigh‚Ì???‰Šú‰»
      else if(iv_control && (control == 2'b00) && (i==57)) Hash6_r <= iv6;
      else if(iv_control && (control == 2'b00) && opt_en && round == 63) Hash6_r <= e + Hash6_r;
      else if(((iv_control && ~opt_en) || ~iv_control) && round == 64) Hash6_r <= e + Hash6_r;
      else Hash6_r <= Hash6_r;
   end
end

//Hash7
always @(posedge clk)begin
	if (rst) Hash7_r <= 0;
   else begin
      if (init) Hash7_r <= iv7;//32'h7a78da2d;//32'h5be0cd19;//                          //init?M?†‚ªHigh‚Ì???‰Šú‰»
      else if(iv_control && (control == 2'b00) && (i==57)) Hash7_r <= iv7;
      else if(iv_control && (control == 2'b00) && opt_en && round == 62) Hash7_r <= e + Hash7_r;
      else if(((iv_control && ~opt_en) || ~iv_control) && round == 63) Hash7_r <= e + Hash7_r;
      else Hash7_r <= Hash7_r;
   end
end
//end(Hash ctrl)




//main logic

//plus
assign plus = (iv_control && control == 2'b00 && opt_en && round <= 15) ? wire2 + k + wire4 : wire2 + r9;

//maj
assign maj = (a & b) ^ (a & c) ^ (b & c);

//ch
assign ch = (e & f) ^ (~e & g);

//sigma0
assign sig0 = {a[1:0],a[31:2]} ^ {a[12:0],a[31:13]} ^ {a[21:0],a[31:22]};

//sigma1
assign sig1 = {e[5:0],e[31:6]} ^ {e[10:0],e[31:11]} ^ {e[24:0],e[31:25]};

assign wire4 = (round == constant - 1)? Hash7 : (iv_control && control == 2'b00 && opt_en) ? g : f;
assign wire3 = (iv_control && control == 2'b00 && opt_en && round == constant-1) ? Hash5 : (((iv_control && ~opt_en) || ~iv_control) && round == constant) ? Hash5 : e;
assign wire2 = (iv_control && control == 2'b00 && opt_en && round == constant-1) ? Hash3 : (((iv_control && ~opt_en) || ~iv_control) && round == constant) ? Hash3 : b;

//main logic FF
//a
always @(posedge clk) begin
	if(rst) a <= 0;
    else if (EN) begin
      if(iv_control && control == 2'b00 && opt_en)begin
        if(round == constant) a <= Hash0;
        else if (round <= 67) a <= vs1 + vc1;
        else a <= a;
      end
      else begin
        if (round == constant + 1) a <= Hash0;
        else if (round <= 67) a <= vs1 + vc1;
        else a <= a;
      end
    end
    else a <= a;
end


//b
always @(posedge clk) begin
	if (rst) b <= 0; 
    else if (EN) begin
        if(iv_control && control == 2'b00 && opt_en)begin
           if (round == constant - 1) b <= Hash2; 
           else if (round == constant) b <= Hash1;
           else if (round <= 67) b <= a;
           else b <= b;
	    end
	    else begin 
           if (round == constant) b <= Hash2; 
           else if (round == constant + 1) b <= Hash1;
           else if (round <= 67) b <= a;
           else b <= b;
        end
    end
    else b <= b;
end

//c
always @(posedge clk) begin
	if (rst) c <= 0;
   else if (EN) begin
      if (round <= 67) c <= b;
	   else c <= c;
   end
   else c <= c;
end

//e
always @(posedge clk) begin
	if (rst) e <= 0;
    else if (EN) begin
	   if(iv_control && control == 2'b00 && opt_en)begin
           if (round == constant - 1) e <= Hash4;
           else if (round <= 67) e <= vs2 + vc2;
           else e <= e;
	   end
	   else begin
           if (round == constant) e <= Hash4;
           else if (round <= 67) e <= vs2 + vc2;
           else e <= e;
       end
    end
    else e <= e;
end

//f
always @(posedge clk) begin
	if (rst) f <= 0;
    else if (EN) begin
      if(iv_control && control == 2'b00 && opt_en)begin
          if (round <= 67) f <= wire3;
          else f <= f;
      end
      else begin
          if (round == constant - 1) f <= Hash6;
          else if (round <= 67) f <= wire3;
          else f <= f;
      end
    end
    else if (iv_control && control == 2'b00 && opt_en && round == constant - 1) f <= Hash6;
    else f <= f;
end

//g
always @(posedge clk) begin
	if (rst) g <= 0;
   else if (EN) begin
      if (round <= 67) g <= f;
      else g <= g;
   end
   else g <= g;
end
//r7
always @(posedge clk) begin
	if (rst) r7 <= 0;
   else if (EN) begin
      if (round <= 67) r7 <= vs4 + vc4;
	   else r7 <= r7;
   end
   else r7 <= r7;
end

//r8
always @(posedge clk) begin
	if (rst) r8 <= 0;
    else if (EN) begin
       if(iv_control && control == 2'b00 && opt_en)begin
           if (round <= 15) r8 <= k + wire4;
           else if(round >= 16) r8 <= r9;
           else r8 <= r8;
       end
       else begin 
           if (round <= 67) r8 <= r9;
           else r8 <= r8;
       end
    end
    else r8 <= r8;
end


//r9
always @(posedge clk) begin
	if (rst) r9 <= 0;
   else if (EN) begin
      if (round <= 67) r9 <= vs3 + vc3;
      else r9 <= r9;
   end
   else r9 <= r9;
end


//r10
always @(posedge clk) begin
	if (rst) r10 <= 0;
   else if (EN) begin
      if (round <= 67) r10 <= plus;
      else r10 <= r10;
   end
   else r10 <= r10;
end
//end(main logic)

//w schedule

//w FF

//w0
always @(posedge clk) begin
	if (rst) w0 <= 0;
   else begin
      if (init) w0 <= 0;
      else if (EN) w0 <= w1;
      else w0 <= w0;
   end
end

//w1
always @(posedge clk) begin
	if (rst) w1 <= 0;
   else begin
      if (init) w1 <= 0;
      else if (EN) w1 <= w2;
      else w1 <= w1;
   end
end

//w2
always @(posedge clk) begin
	if (rst) w2 <= 0;
   else begin
      if (init) w2 <= 0;
      else if (EN) w2 <= w3;
      else w2 <= w2;
   end
end

//w3
always @(posedge clk) begin
	if (rst) w3 <= 0;
   else begin
      if (init) w3 <= 0;
      else if (EN) w3 <= w4;
      else w3 <= w3;
   end
end

//w4
always @(posedge clk) begin
	if (rst) w4 <= 0;
   else begin
      if (init) w4 <= 0;
      else if (EN) w4 <= w5;
      else w4 <= w4;
   end
end

//w5
always @(posedge clk) begin
	if (rst) w5 <= 0;
   else begin
      if (init) w5 <= 0;
      else if (EN) w5 <= w6;
      else w5 <= w5;
   end
end

//w6
always @(posedge clk) begin
	if (rst) w6 <= 0;
   else begin
      if (init) w6 <= 0;
      else if (EN) w6 <= w7;
      else w6 <= w6;
   end
end

//w7
always @(posedge clk) begin
	if (rst) w7 <= 0;
   else begin
      if (init) w7 <= 0;
	   else if (EN) w7 <= w8;
	   else w7 <= w7;
   end
end

//w8
always @(posedge clk) begin
   if (rst) w8 <= 0;
   else begin
      if (init) w8 <= 0;
      else if (EN) w8 <= w9;
      else w8 <= w8;
   end
end

//w9
always @(posedge clk) begin
   if (rst) w9 <= 0;
   else begin
      if (init) w9 <= 0;
      else if (EN) w9 <= w10_r;
      else w9 <= w9;
   end
end

//w10
always @(posedge clk) begin
   if (rst) w10_r <= 0;
   else begin
      if (init)begin 
        if(iv_control && (control == 2'b00))
            w10_r <= w10;
        else 
            w10_r <= 0;
      end
      else if (EN) w10_r <= w11_r;
      else w10_r <= w10_r;
   end
end

//w11
always @(posedge clk) begin
   if (rst) w11_r <= 0;
   else begin
      if (init)begin 
        if(iv_control && (control == 2'b00))
            w11_r <= w11;
        else 
            w11_r <= 0;
      end
      else if (EN) w11_r <= w12_r;
      else w11_r <= w11_r;
   end
end

//w12
always @(posedge clk) begin
   if (rst) w12_r <= 0;
   else begin
      if (init)begin 
        if(iv_control && (control == 2'b00))
            w12_r <= w12;
        else 
            w12_r <= 0;
      end
      else if (EN) w12_r <= w13_r;
      else w12_r <= w12_r;
   end
end

//w13
always @(posedge clk) begin
   if (rst) w13_r <= 0;
   else begin
      if (init)begin 
        if(iv_control && (control == 2'b00))
            w13_r <= nonce;
        else 
            w13_r <= 0;
      end
      else if (EN) w13_r <= wt;
      else w13_r <= w13_r;
   end
end

//w14
always @(posedge clk) begin
   if (rst) w14 <= 0;
   else begin
      if (init) w14 <= 0;
      else if (EN) w14 <= w15 + w16;
      else w14 <= w14;
   end
end

//w15
always @(posedge clk) begin
   if (rst) w15 <= 0;
   else begin
      if (init) w15 <= 0;
      else if (EN) w15 <= vs_w2; 
      else w15 <= w15;
   end
end

//w16
always @(posedge clk) begin
   if (rst) w16 <= 0;
   else begin
      if (init) w16 <= 0;
      else if (EN) w16 <= vc_w2; 
      else w16 <= w16; 
   end
end

//sig_w0
assign sig_w0 = (iv_control && control == 2'b00 && opt_en && round < 26) ? {w2[6:0],w2[31:7]} ^ {w2[17:0],w2[31:18]} ^ {3'b000,w2[31:3]} : {w1[6:0],w1[31:7]} ^ {w1[17:0],w1[31:18]} ^ {3'b000,w1[31:3]};

//sig_w1
assign sig_w1 = {wt[16:0],wt[31:17]} ^ {wt[18:0],wt[31:19]} ^ {10'b00_0000_0000,wt[31:10]};

assign wt = (iv_control && control == 2'b00 && opt_en && round <= 13) ? idata : (iv_control && control == 2'b00 && opt_en && round == 14) ? 32'h00000280 : (((iv_control && ~opt_en) || ~iv_control) && round <= 15) ? idata : w14;

endmodule
