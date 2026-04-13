module top 
(
    // input logic start, 
    input logic clk, 
    input logic reset_n, 
    output logic [1:0] red, 
    output logic [1:0] green, 
    output logic [1:0] blue, 
    output logic hsync, 
    output logic vsync
);

    logic [9:0] hcount, vcount;
    logic [1:0] symbol1, symbol2, symbol3; 
    logic active, won;
    
    vsync_generator vsync_gen(.clk(clk), .reset_n(reset_n), .hsync(hsync), .vsync(vsync), .hcount(hcount), .vcount(vcount), .active(active));
    display_slots draw_slots(.clk(clk), .reset_n(reset_n), .active(active), .hcount(hcount), .vcount(vcount), .red(red), .green(green), .blue(blue));
    display_symbols draw_symbols (.clk(clk), .reset_n(reset_n), .symbol1(symbol1), .symbol2(symbol2), .symbol3(symbol3), .hcount(hcount), .vcount(vcount), .active(active), .red(red), .green(green), .blue(blue));
    slot_spinner spin_slots (.start(start), .clk(clk), .reset_n(reset_n), .symbol1(symbol1), .symbol2(symbol2), .symbol3(symbol3), .won(won))

endmodule: top 
