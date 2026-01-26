`timescale 1ns / 1ps

module pufMain#(
    parameter counterMax = 10000000, //10 million, run each RO for .1 second
    parameter RO_Count = 9
)(
    input CLK,  //100Mhz Clk
    input btnC,
    input [7:0] switches,
    output logic [RO_Count-2:0] leds = 0,
    output logic doneLED
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

    
    //oscilator clock
    logic oscClock [RO_Count-1 : 0];
    logic [31:0]oscCounter[1:0]  = '{0,0};
    logic oscCounterEn  = 0;
    logic oscCounterRst = 0;
    
    
    logic [$clog2(RO_Count): 0] ROIndex = 0; //which RO we are currently running   
    assign enableROs = oscCounterEn ? 1 << ROIndex : 0;
     
    
    logic [`counterSize - 1:0] nextCounter;
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
        ST_IDLE
    } state_t;
    
    state_t state = ST_IDLE;
    state_t nextState;
    
    always_ff @(posedge CLK) begin
        if(reset) begin
            state <= ST_Start;
            storedSEL <= switches[3:0];
            storedBx <= switches [7:4];
        end else begin
            state <= nextState;
        end
        
        counter <= nextCounter;
        ROIndex <= nextROIndex;
        oscCounterEn <= nextOscCounterEn;
        oscCounterRst <= nextOscCounterRst;
        
        if(ROIndex != 0) begin
            leds[ROIndex-1] <= nextOutputBit;
        end
    end
    
    always_comb begin
        nextROIndex = ROIndex;
        nextCounter = counter;
        nextOscCounterEn = oscCounterEn;
        doneLED = 0;   //not done by default
        
        nextOutputBit = ROIndex == 0 ? leds[ROIndex] : leds[ROIndex-1];
        nextOscCounterRst = 0;
        case (state)
            ST_Start: begin
                nextOscCounterRst = 1;
                nextCounter = 0;
                nextROIndex = 0;
                nextOscCounterEn = 1;
                nextState = ST_Wait;
            end
            ST_Wait: begin
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
                if(ROIndex ==  RO_Count) begin
                    nextCounter = 0;
                    nextOscCounterEn = 0;
                    nextROIndex = 0;
                    nextState = ST_IDLE;
                end else begin
                    nextROIndex = ROIndex + 1;
                    nextState = ST_Wait;
                end
             end
             ST_IDLE: begin
                nextState = ST_IDLE;   
                nextROIndex = 0;   
                nextOscCounterEn = 0;   
                doneLED= 1;   //indicat we are done       
             end
             
             default: begin
                nextState = ST_IDLE;
             end
                
        endcase
    end
    
endmodule
