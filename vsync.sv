module vsync_generator #(
    //Horizontal timing parameters
    parameter h_active = 640,
    parameter h_front_porch = 16,
    parameter h_sync = 96, 
    parameter h_back_porch = 48, 
    parameter h_total = 800,

    //Vertical timing parameters
    parameter v_active = 480, 
    parameter v_front_porch = 10, 
    parameter v_sync = 2, 
    parameter v_back_porch = 33,
    parameter v_total = 525
) (
    input logic clk,
    input logic reset_n,
    output logic hsync,
    output logic vsync,
    output logic active, 
    output logic [9:0] hcount,
    output logic [9:0] vcount
);

    //Horizontal and vertical counting logic 
    always_ff @(posedge clk) begin
        //If we reset then the counters get reset
        if (~reset_n) begin
            hcount <= 0;
            vcount <= 0;
        end
        else begin
            //If the horizontal counter reaches its total (h_total - 1)
            //This means that we are done with the row 
            //So reset the hcounter and move on and check if we are done with iterating through the rows
            if (hcount >= h_total - 1) begin
                hcount <= 0;
                //Check if the vertical counter is done iterating through all the rows
                if (vcount >= v_total - 1) begin
                    vcount <= 0;
                end
                //Otherwise increment the vertical count
                else begin
                    vcount <= vcount + 1;
                end
            end
            //If the hcount is not at the end of the whole row, increment the hcount
            else begin
                hcount <= hcount + 1;
            end
        end
    end
    always_ff @(posedge clk) begin
        // Hsync and vsync is an active low signal that gets set whenever the hcounter and vcounter are 
        //between the end of their front porch times and the end of the sync times
        hsync <= ~((hcount >= h_active + h_front_porch - 1) && (hcount <= h_active + h_front_porch + h_sync - 1));
        vsync <= ~((vcount >= v_active + v_front_porch - 1) && (vcount <= v_active + v_front_porch + v_sync - 1));

        //Active when both the hcount and vcount are in their active ranges
        active <= (hcount < h_active) && (vcount < v_active);
    end

endmodule: vsync_generator