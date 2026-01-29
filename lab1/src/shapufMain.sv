`timescale 1ns / 1ps

module pufMain#(
//    parameter LEDIntervalMS = 1000,
    parameter counterMax = 10000000, //20 million, run each RO for .1 second
    parameter RO_Count = 9
)(
    input CLK,  //100Mhz Clk
    input btnC,
    input [7:0] switches,
    input [3:0] sseg_sel,
    output logic [RO_Count-2:0] leds = 0,
    output logic doneLED,
    output logic [3:0] an,
    output logic [6:0] segs,
    output logic sha_done
    );  
    logic reset;
    
    //reset to re-compute any time our input changes
    always_comb begin 
        if((storedSEL != switches[3:0]) || (storedBx != switches[7:4])) begin
            reset = 1;
        end else begin
            reset = btnC;
        end
    end
    
    `define counterSize ($clog2(counterMax + 100) + 1)    //ensure at least 100 value lee-way      
        
    logic [3:0] storedSEL;
    logic [3:0] storedBx;
    logic SELUnpacked [3:0];
    logic BxUnpacked [3:0];
    genvar j;
    generate
        for(j=0; j <4; j++) begin : gen
            assign SELUnpacked[j] = storedSEL[j];
            assign BxUnpacked[j] = storedBx[j];
        end
    endgenerate
    
    logic [RO_Count-1:0] enableROs;
    
    genvar i;
    generate 
    for(i=0; i < RO_Count; i++) begin : genROs
        (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
        RingOscilator RO(.enable(enableROs[i]), .sel(SELUnpacked), .bx(BxUnpacked), .generatedClock(oscClock[i]));
        end
    endgenerate
    
    logic [`counterSize - 1:0] counter = 0;

    logic [15:0] sha_in;
    logic sha_start;
    logic sha_rst;
    logic [127:0] sha_out;
    sha128_simple sha128(.CLK(CLK), .DATA_IN(sha_in), .RESET(sha_rst), .START(sha_start), .READY(sha_done), .DATA_OUT(sha_out));
    
    logic sseg_valid;
    logic [15:0] sseg_in;
    sseg_des sseg(.COUNT(sseg_in), .CLK(CLK), .VALID(sseg_valid), .DISP_EN(an), .SEGMENTS(segs));
    
    //oscilator clock
    logic oscClock [RO_Count-1 : 0];
    logic [31:0]oscCounter[1:0]  = '{0,0};
    logic oscCounterEn  = 0;
    logic oscCounterRst = 0;
    
    
    logic [$clog2(RO_Count): 0] ROIndex = 0; //which RO we are currently running   
    assign enableROs = oscCounterEn ? 1 << ROIndex : 0;
     
    
    logic [`counterSize - 1:0] nextCounter;
//    logic nextEnableROs;
    logic nextOscCounterEn;
    logic nextOscCounterRst = 1;
    logic [$clog2(RO_Count): 0] nextROIndex; //which RO we are currently running    
    
    logic nextOutputBit;    
        
    always_ff @(posedge oscClock[ROIndex]) begin
        if(oscCounterRst) begin
            oscCounter[ROIndex[0]] <= 0;
        end else if(oscCounterEn) begin
            oscCounter[ROIndex[0]] <= oscCounter[ROIndex[0]] + 1;
        end
    end
    
    typedef enum logic [3:0] {
        ST_Start,
        ST_Wait,
        ST_Next_RO,
        ST_PREHASH,
        ST_PREHASHWAIT,
        ST_HASH,
        ST_DONE
    } state_t;
    
    state_t state = ST_Start;
    state_t nextState;
    
    always_ff @(posedge CLK) begin
        if ((state != ST_HASH) && (nextState == ST_HASH)) begin //send a 1 cycle start pulse to SHA128
            sha_in [7:0] <= switches;
            sha_in [15:8] <= leds;
            sha_start <= 1;
        end else begin
            sha_start <= 0;
        end
        if(reset) begin
            state <= ST_Start;
            storedSEL <= switches[3:0];
            storedBx <= switches [7:4];
            sha_rst <= 1;
        end else begin
            sha_rst <= 0;
            state <= nextState;
        end
        
        counter <= nextCounter;
//        enableROs <= nextEnableROs;
        ROIndex <= nextROIndex;
        oscCounterEn <= nextOscCounterEn;
        oscCounterRst <= nextOscCounterRst;
        
        if(ROIndex != 0) begin
            leds[ROIndex-1] <= nextOutputBit;
        end
        if ((state == ST_PREHASH)) begin //latch sha_in before start pulse
            sha_in [7:0] <= switches;
            sha_in [15:8] <= leds;
        end
    end
    
    always_comb begin
        nextROIndex = ROIndex;
//        nextEnableROs = enableROs;
        nextCounter = counter;
        nextOscCounterEn = oscCounterEn;
        doneLED = 0;   //not done by default
        sseg_valid = 0;
        
        nextOutputBit = ROIndex == 0 ? leds[ROIndex] : leds[ROIndex-1];
        nextOscCounterRst = 0;
        case (state)
            ST_Start: begin
//                nextEnableROs = 1;
                nextOscCounterRst = 1;
                nextCounter = 0;
                nextROIndex = 0;
                nextOscCounterEn = 1;
                nextState = ST_Wait;
            end
            ST_Wait: begin
//                nextEnableROs = 0; 
                if (counter == 0) begin
                    nextOscCounterRst = 1;
                end
                if(counter >= counterMax) begin
                    //move to next RO
                    nextState = ST_Next_RO;
                    nextCounter = 0;
                    nextOscCounterEn = 0;                    
                end else begin
                    //continue running
                    nextState = ST_Wait;
                    nextCounter =  counter + 1;
                    nextOscCounterEn = 1;  
                end
             end
             ST_Next_RO: begin
                nextOutputBit = (oscCounter[ROIndex[0]] > oscCounter[~ROIndex[0]]); //set our output bit
//                nextOscCounterRst = 1;
                if(ROIndex ==  RO_Count) begin
//                    nextEnableROs = 0;
                    nextCounter = 0;
                    nextOscCounterEn = 0;
                    nextROIndex = 0;
                    nextState = ST_PREHASH;
                end else begin
                    nextROIndex = ROIndex + 1;
//                    nextEnableROs = enableROs << 1; //move our enable for which osc is running
                    nextState = ST_Wait;
                end
             end
             ST_PREHASH: begin 
                nextState = ST_PREHASHWAIT;  
             end
             ST_PREHASHWAIT: begin //
                nextState = ST_HASH;
             end
             ST_HASH: begin
                if(sha_done) begin
                    nextState = ST_DONE;
                end
                else begin
                    nextState = ST_HASH;
                end
             end
             
             ST_DONE: begin
                nextState = ST_DONE;
                if(sseg_sel > 8)begin
                    sseg_in = 16'h0000;
                end
                else if(sseg_sel == 0) begin
                    sseg_in = sha_out[15:0];
                end
                else begin
                    sseg_in = sha_out[(sseg_sel*16)-:16];
                end
                sseg_valid = 1;
                doneLED = 1;
             end
             
             default: begin
                nextState = ST_PREHASH;
             end
                
        endcase
    end
    
endmodule
