module sha256(
   input clk,
   input rst,
   input init_start,
   output ack
);   


wire [31:0] iv0;
wire [31:0] iv1;
wire [31:0] iv2;
wire [31:0] iv3;
wire [31:0] iv4;
wire [31:0] iv5;
wire [31:0] iv6;
wire [31:0] iv7;

reg [31:0] iv0_opt;
reg [31:0] iv1_opt;
reg [31:0] iv2_opt;
reg [31:0] iv3_opt;
reg [31:0] iv4_opt;
reg [31:0] iv5_opt;
reg [31:0] iv6_opt;
reg [31:0] iv7_opt;

reg [31:0] iv0_start;
reg [31:0] iv1_start;
reg [31:0] iv2_start;
reg [31:0] iv3_start;
reg [31:0] iv4_start;
reg [31:0] iv5_start;
reg [31:0] iv6_start;
reg [31:0] iv7_start;

reg [31:0] iv0_r;
reg [31:0] iv1_r;
reg [31:0] iv2_r;
reg [31:0] iv3_r;
reg [31:0] iv4_r;
reg [31:0] iv5_r;
reg [31:0] iv6_r;
reg [31:0] iv7_r;

wire [31:0] Hash0;
wire [31:0] Hash1;
wire [31:0] Hash2;
wire [31:0] Hash3;
wire [31:0] Hash4;
wire [31:0] Hash5;
wire [31:0] Hash6;
wire [31:0] Hash7;

wire [31:0] Hash0_in;
wire [31:0] Hash1_in;
wire [31:0] Hash2_in;
wire [31:0] Hash3_in;
wire [31:0] Hash4_in;
wire [31:0] Hash5_in;
wire [31:0] Hash6_in;
wire [31:0] Hash7_in;

wire out;
reg out_delay;
reg out_delay2;

wire busy;
wire EN;
wire [31:0] a,e;
wire [6:0] i;

wire [255:0] difficulty;
reg [31:0] compact;
reg [255:0] compare_hash;
reg [1:0] compare_control;
reg stop;

wire [31:0] idata32;

reg [1:0] control;
reg iv_control;
reg load;
reg [6:0] counter;
reg [1:0] input_control;
wire [31:0] nonce;
wire init;
reg init_delay;
wire [4:0] constant;
assign constant = (rst) ? 5'b00000 : (iv_control && (control == 2'b00)) ? 5'b10110 : 5'b00000;

assign ack = Hash0[31:31];

    always @(posedge clk)begin
        if(rst)
            out_delay <= 0;
        else
            out_delay <= out;
        end
    
    always @(posedge clk)begin
        if(rst)
            out_delay2 <= 0;
        else
            out_delay2 <= out_delay;
        end
    
    always @(posedge clk)begin
        if(rst)
            control <= 2'b01;
        else if(out && (control > 2'b00))
            control <= 2'b10;
        else if((counter == 95) && iv_control)
            control <= 2'b00;
    end
        
    always @(posedge clk)begin
        if(rst)
            iv_control <= 0;
        else if(out_delay)
            iv_control <= ~iv_control;    
        end
        
    always @(posedge clk)begin
        init_delay <= init_start;
    end
    
    assign init = init_delay && (init_delay ^ init_start);

    always @(posedge clk)begin
        if(rst)begin
            iv0_r <= 32'h00000000;
            iv1_r <= 32'h00000000;
            iv2_r <= 32'h00000000;
            iv3_r <= 32'h00000000;
            iv4_r <= 32'h00000000;
            iv5_r <= 32'h00000000;
            iv6_r <= 32'h00000000;
            iv7_r <= 32'h00000000;
         end
         else if(out_delay && (control == 2'b10))begin
            iv0_r <= Hash0;
            iv1_r <= Hash1;
            iv2_r <= Hash2;
            iv3_r <= Hash3;
            iv4_r <= Hash4;
            iv5_r <= Hash5;
            iv6_r <= Hash6;
            iv7_r <= Hash7;
         end   
         else if(out_delay && (control == 2'b00))begin
            iv0_r <= iv0_opt;
            iv1_r <= iv1_opt;
            iv2_r <= iv2_opt;
            iv3_r <= iv3_opt;
            iv4_r <= iv4_opt;
            iv5_r <= iv5_opt;
            iv6_r <= iv6_opt;
            iv7_r <= iv7_opt;
         end
         else if((control == 2'b00) && (i==56))begin
            iv0_r <= iv0_start;
            iv1_r <= iv1_start;
            iv2_r <= iv2_start;
            iv3_r <= iv3_start;
            iv4_r <= iv4_start;
            iv5_r <= iv5_start;
            iv6_r <= iv6_start;
            iv7_r <= iv7_start;
         end 
    end
    
    assign iv0 = (init) ? 32'h6a09e667 : (iv_control) ? iv0_r : 32'h6a09e667;
    assign iv1 = (init) ? 32'hbb67ae85 : (iv_control) ? iv1_r : 32'hbb67ae85;
    assign iv2 = (init) ? 32'h3c6ef372 : (iv_control) ? iv2_r : 32'h3c6ef372;
    assign iv3 = (init) ? 32'ha54ff53a : (iv_control) ? iv3_r : 32'ha54ff53a;
    assign iv4 = (init) ? 32'h510e527f : (iv_control) ? iv4_r : 32'h510e527f;
    assign iv5 = (init) ? 32'h9b05688c : (iv_control) ? iv5_r : 32'h9b05688c;
    assign iv6 = (init) ? 32'h1f83d9ab : (iv_control) ? iv6_r : 32'h1f83d9ab;
    assign iv7 = (init) ? 32'h5be0cd19 : (iv_control) ? iv7_r : 32'h5be0cd19;
    
    always @(posedge clk)begin
        if(rst)
            counter <= 0;
        else if(counter == 95 - constant)
            counter <= 0;    
        else if(init || out_delay2 || (counter > 0))
            counter <= counter + 1;     
    end 

    always @(posedge clk)begin
        if(rst)
            load <= 0;
        else if(init || out_delay2)
            load <= 1;
        else if(counter == 95 - constant)
            load <= 0;    
    end
    
    always @(posedge clk)begin
        if(rst)
            input_control <= 0;
        else if(out)
            input_control <= input_control + 1;
        else if(input_control == 2)
            input_control <= 0;
    end
    
    assign Hash0_in = (input_control == 2) ? Hash0 : Hash0_in;
    assign Hash1_in = (input_control == 2) ? Hash1 : Hash1_in;
    assign Hash2_in = (input_control == 2) ? Hash2 : Hash2_in;
    assign Hash3_in = (input_control == 2) ? Hash3 : Hash3_in;
    assign Hash4_in = (input_control == 2) ? Hash4 : Hash4_in;
    assign Hash5_in = (input_control == 2) ? Hash5 : Hash5_in;
    assign Hash6_in = (input_control == 2) ? Hash6 : Hash6_in;
    assign Hash7_in = (input_control == 2) ? Hash7 : Hash7_in;
    
    always @(posedge clk)begin
        if(rst)
            iv0_opt <= 32'h00000000;
        else if(iv_control && control == 2'b10 && i==47)
            iv0_opt <= a + 32'h01000000;
        else if(iv_control && control == 2'b00 && i==46)
            iv0_opt <= a + 32'h01000000;
    end
    
    always @(posedge clk)begin
        if(rst)
            iv1_opt <= 32'h00000000;
        else if((i==45) && (control == 2'b10))
            iv1_opt <= a;
    end
    
    
    always @(posedge clk)begin
        if(rst)
            iv2_opt <= 32'h00000000;
        else if((i==43) && (control == 2'b10))
            iv2_opt <= a;
    end
    
    
    always @(posedge clk)begin
        if(rst)
            iv3_opt <= 32'h00000000;
        else if((i==41) && (control == 2'b10))
            iv3_opt <= a;
    end
    
    
    always @(posedge clk)begin
        if(rst)
            iv4_opt <= 32'h00000000;
        else if(iv_control && control == 2'b10 && i==45)
            iv4_opt <= e + 32'h01000000;
        else if(iv_control && control == 2'b00 && i==44)
            iv4_opt <= e + 32'h01000000;
    end
    
    
    always @(posedge clk)begin
        if(rst)
            iv5_opt <= 32'h00000000;
        else if((i==43) && (control == 2'b10))
            iv5_opt <= e;
    end
    
    
    always @(posedge clk)begin
        if(rst)
            iv6_opt <= 32'h00000000;
        else if((i==41) && (control == 2'b10))
            iv6_opt <= e;
    end
    
    
    always @(posedge clk)begin
        if(rst)
            iv7_opt <= 32'h00000000;
        else if((i==39) && (control == 2'b10))
            iv7_opt <= e;
    end
    //assign iv0_opt = (rst) ? 32'h00000000 : (i==47) ? a+32'h01000000 : 32'h00000000/*iv0_opt*/;
    //assign iv1_opt = (rst) ? 32'h00000000 : ((i==45) && (control == 2'b10)) ? a : 32'h00000000/*iv1_opt*/;
    //assign iv2_opt = (rst) ? 32'h00000000 : ((i==43) && (control == 2'b10)) ? a : 32'h00000000/*iv2_opt*/;
    //assign iv3_opt = (rst) ? 32'h00000000 : ((i==41) && (control == 2'b10)) ? a : 32'h00000000/*iv3_opt*/;
    //assign iv4_opt = (rst) ? 32'h00000000 : (i==45) ? e+32'h01000000 : 32'h00000000/*iv4_opt*/;
    //assign iv5_opt = (rst) ? 32'h00000000 : ((i==43) && (control == 2'b10)) ? e : 32'h00000000/*iv5_opt*/;
    //assign iv6_opt = (rst) ? 32'h00000000 : ((i==41) && (control == 2'b10)) ? e : 32'h00000000/*iv6_opt*/;
    //assign iv7_opt = (rst) ? 32'h00000000 : ((i==39) && (control == 2'b10)) ? e : 32'h00000000/*iv7_opt*/; 

    
    always @(posedge clk)begin
        if(rst)
            iv0_start <= 32'h00000000;
        else if(out_delay && (control == 2'b10))
            iv0_start <= Hash0;
    end
    
    always @(posedge clk)begin
        if(rst)
            iv1_start <= 32'h00000000;
        else if(out_delay && (control == 2'b10))
            iv1_start <= Hash1;
    end
    
    always @(posedge clk)begin
        if(rst)
            iv2_start <= 32'h00000000;
        else if(out_delay && (control == 2'b10))
            iv2_start <= Hash2;
    end
    
    always @(posedge clk)begin
        if(rst)
            iv3_start <= 32'h00000000;
        else if(out_delay && (control == 2'b10))
            iv3_start <= Hash3;
    end
    
    always @(posedge clk)begin
        if(rst)
            iv4_start <= 32'h00000000;
        else if(out_delay && (control == 2'b10))
            iv4_start <= Hash4;
    end
    
    always @(posedge clk)begin
        if(rst)
            iv5_start <= 32'h00000000;
        else if(out_delay && (control == 2'b10))
            iv5_start <= Hash5;
    end
    
    always @(posedge clk)begin
        if(rst)
            iv6_start <= 32'h00000000;
        else if(out_delay && (control == 2'b10))
            iv6_start <= Hash6;
    end
    
    always @(posedge clk)begin
        if(rst)
            iv7_start <= 32'h00000000;
        else if(out_delay && (control == 2'b10))
            iv7_start <= Hash7;
    end
//    assign iv0_start = (rst) ? 32'h00000000 : (out_delay && (control == 2'b10)) ? Hash0 : /*32'h00000000*/(iv0_start>0) ? iv0_start : 32'h00000000;
//    assign iv1_start = (rst) ? 32'h00000000 : (out_delay && (control == 2'b10)) ? Hash1 : /*32'h00000000*/(iv1_start>0) ? iv1_start : 32'h00000000;
//    assign iv2_start = (rst) ? 32'h00000000 : (out_delay && (control == 2'b10)) ? Hash2 : /*32'h00000000*/(iv2_start>0) ? iv2_start : 32'h00000000;
//    assign iv3_start = (rst) ? 32'h00000000 : (out_delay && (control == 2'b10)) ? Hash3 : /*32'h00000000*/(iv3_start>0) ? iv3_start : 32'h00000000;
//    assign iv4_start = (rst) ? 32'h00000000 : (out_delay && (control == 2'b10)) ? Hash4 : /*32'h00000000*/(iv4_start>0) ? iv4_start : 32'h00000000;
//    assign iv5_start = (rst) ? 32'h00000000 : (out_delay && (control == 2'b10)) ? Hash5 : /*32'h00000000*/(iv5_start>0) ? iv5_start : 32'h00000000;
//    assign iv6_start = (rst) ? 32'h00000000 : (out_delay && (control == 2'b10)) ? Hash6 : /*32'h00000000*/(iv6_start>0) ? iv6_start : 32'h00000000;
//    assign iv7_start = (rst) ? 32'h00000000 : (out_delay && (control == 2'b10)) ? Hash7 : /*32'h00000000*/(iv7_start>0) ? iv7_start : 32'h00000000; 
   
always @(posedge clk)begin
    if(rst)
        compact <= 0;
    else if(i==39)
        compact <= {idata32[7:0],idata32[15:8],idata32[23:16],idata32[31:24]};    
end

always @(posedge clk)begin
    if(rst)
        compare_control <= 0;
    else if(out)
        compare_control <= compare_control + 1;
    else if((compare_control == 3))
        compare_control <= 1;
end

always @(posedge clk)begin
    if(rst)
        compare_hash <= 256'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    else if((control == 2'b00) && (compare_control == 2'b11))
        compare_hash <= {Hash7[7:0],Hash7[15:8],Hash7[23:16],Hash7[31:24],Hash6[7:0],Hash6[15:8],Hash6[23:16],Hash6[31:24],Hash5[7:0],Hash5[15:8],Hash5[23:16],Hash5[31:24],Hash4[7:0],Hash4[15:8],Hash4[23:16],Hash4[31:24],
        Hash3[7:0],Hash3[15:8],Hash3[23:16],Hash3[31:24],Hash2[7:0],Hash2[15:8],Hash2[23:16],Hash2[31:24],Hash1[7:0],Hash1[15:8],Hash1[23:16],Hash1[31:24],Hash0[7:0],Hash0[15:8],Hash0[23:16],Hash0[31:24]};
end

always @(posedge clk)begin
    if(rst)
        stop <= 0;
    else if((control == 2'b00) && (compare_control == 2'b01) && (compare_hash < difficulty))
        stop <= 1;
end

current_target current_target(
    .clk(clk),
    .rst(rst),
    .target32(compact),
    .target256(difficulty)
);
    
sha256_interface sha256_interface(
   .clk(clk),
   .rst(rst),
   .load(load), 
   .busy(busy),
   .init(init || out_delay2),
   .iv_control(iv_control),
   .control(control),
   .EN(EN),
   .Hash_end0(Hash0_in),
   .Hash_end1(Hash1_in),
   .Hash_end2(Hash2_in),
   .Hash_end3(Hash3_in),
   .Hash_end4(Hash4_in),
   .Hash_end5(Hash5_in),
   .Hash_end6(Hash6_in),
   .Hash_end7(Hash7_in),
   .i(i),
   .nonce(nonce),
   .idata32(idata32)
);

sha256_core sha256_core(
   .clk(clk), 
   .rst(rst || stop),
   .busy(busy), 
   .EN(EN),
   .init(init || out_delay2),
   .i(i),
   .nonce(nonce),
   .iv_control(iv_control),
   .control(control),
   .compare_control(compare_control),
   .iv0(iv0),
   .iv1(iv1),
   .iv2(iv2),
   .iv3(iv3),
   .iv4(iv4),
   .iv5(iv5),
   .iv6(iv6),
   .iv7(iv7),
   .Hash0(Hash0),
   .Hash1(Hash1), 
   .Hash2(Hash2), 
   .Hash3(Hash3),
   .Hash4(Hash4), 
   .Hash5(Hash5), 
   .Hash6(Hash6), 
   .Hash7(Hash7),
   .a(a),
   .e(e),
   .out(out),
   .idata(idata32) 
);



ila_0 ila(
   .clk(clk),
   .probe0(Hash0),
   .probe1(Hash1),
   .probe2(Hash2),
   .probe3(Hash3),
   .probe4(Hash4),
   .probe5(Hash5),
   .probe6(Hash6),
   .probe7(Hash7),
   .probe8(out)
);
endmodule
