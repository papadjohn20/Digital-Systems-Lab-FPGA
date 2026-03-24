module frame_timing(
    input  wire       pixclk,
    input  wire       reset,
    output reg [9:0]  hcount,
    output reg [9:0]  vcount,
    output reg [6:0]  h_rgb_count,
    output reg [6:0]  v_rgb_count,
    output reg       activedraw_sig,
    output reg       hsync_sig,
    output reg       vsync_sig
);

parameter H_LIMIT = 40, V_LIMIT = 30; // 800, 525
parameter H_ACTIVE = 20, V_ACTIVE = 16;// 640, 480
parameter H_FP = 6, V_FP = 8; // 16, 10
parameter H_SYNC = 10, V_SYNC = 2; // 96, 2 
parameter H_BP = 4, V_BP = 4; //48, 33

//states 
parameter IDLE = 3'b000, ACTIVEDRAW = 3'b001, HSYNC = 3'b010, VSYNC = 3'b011, HVSYNC = 3'b100;
reg [2:0] state, next_state;
reg [2:0] temp_h_rgb, temp_v_rgb;

//sequential blocks for hcount, vcount
always @(posedge pixclk or posedge reset) begin
    if (reset)
        hcount <= 0;
    else if (hcount == H_LIMIT - 1)
        hcount <= 0;
    else
        hcount <= hcount + 1;
end

always @(posedge pixclk or posedge reset) begin
    if (reset)
        vcount <= 0;
    else if (hcount == H_LIMIT - 1) begin
        if (vcount == V_LIMIT - 1)
            vcount <= 0;
        else
            vcount <= vcount + 1;
    end
end

//sequential block for rgb counters (h_rgb_count, v_rgb_count)
always @(posedge pixclk or posedge reset) begin
    if (reset) begin
        temp_h_rgb <= 0;
        temp_v_rgb <= 0;
        h_rgb_count <= 0;
        v_rgb_count <= 0;
    end else if (state == ACTIVEDRAW) begin
            if (temp_h_rgb == 4) begin
                    temp_h_rgb <= 0;
                    h_rgb_count <= h_rgb_count + 1;
                end else 
                    temp_h_rgb <= temp_h_rgb + 1;

            if (hcount == H_ACTIVE - 1) begin
                if (temp_v_rgb == 4) begin
                    temp_v_rgb <= 0;
                    v_rgb_count <= v_rgb_count +1;
                end else 
                    temp_v_rgb <= temp_v_rgb + 1;
            end
    end else begin
        h_rgb_count <= 0;
        temp_h_rgb <= 0;
        if (vcount == V_ACTIVE - 1) begin
            v_rgb_count <= 0;
            temp_v_rgb <= 0;
        end 
    end
end

//sequential block for states
always @(posedge pixclk or posedge reset) begin
    if (reset)
        state <= ACTIVEDRAW;
    else 
        state <= next_state;
end

//combiantional block
always @(state or hcount or vcount) begin 
    
    activedraw_sig = 1'b0;
    hsync_sig = 1'b0;
    vsync_sig = 1'b0;

    case (state)
        //----------------------------------------
        ACTIVEDRAW: begin
            activedraw_sig = 1'b1;
            if ((hcount < H_ACTIVE) && (vcount < V_ACTIVE))
                next_state = ACTIVEDRAW;
            else 
                next_state = IDLE;
        end

        //----------------------------------------
        IDLE: begin
            if (hcount == H_ACTIVE + H_FP - 1)
                next_state = HSYNC;
            else if ((hcount == H_LIMIT - 1)  && vcount == V_ACTIVE + V_FP - 1)
                next_state = VSYNC;             
            else if ((hcount == H_LIMIT - 1) && ((vcount < V_ACTIVE - 1) || (vcount == V_LIMIT - 1))) 
                next_state = ACTIVEDRAW;
            else 
                next_state = IDLE; 
        end
        
        //----------------------------------------
        HSYNC: begin
            hsync_sig = 1'b1;
            if (hcount == H_ACTIVE + H_FP + H_SYNC - 1)
                next_state = IDLE;
            else
                next_state = HSYNC;
        end 

        //----------------------------------------
        VSYNC: begin
            vsync_sig = 1'b1;
            if (hcount == H_ACTIVE + H_FP - 1)
                next_state = HVSYNC;
            else if (hcount == H_LIMIT - 1)
                next_state = IDLE;
            else
                next_state = VSYNC;
        end 

        //----------------------------------------
        HVSYNC: begin
            hsync_sig = 1'b1;
            vsync_sig = 1'b1;
            if (hcount == H_ACTIVE + H_FP + H_SYNC - 1)
                next_state = VSYNC;
            else 
                next_state = HVSYNC;
        end
    endcase
end

endmodule