module display_slots 
(
    input logic clk, 
    input logic reset_n, 
    input logic active, 
    input logic [9:0] hcount,
    input logic [9:0] vcount,
    output logic [1:0] red,
    output logic [1:0] green,
    output logic [1:0] blue 
);

    //Draw the slots
    logic slot1, slot2, slot3;
    
    assign slot1 = ((vcount >= 120) && (vcount <= 220)) && ((hcount >= 120) && (hcount <= 220));
    assign slot2 = ((vcount >= 120 && (vcount <= 220)) && ((hcount >= 270) && (hcount <= 370)));
    assign slot3 = ((vcount >= 120 && (vcount <= 220)) && ((hcount >= 420) && (hcount <= 520)));

    always_ff @(posedge clk) begin
        if (~active | ~reset_n) begin
            red <= 2'd0;
            green <= 2'd0;
            blue <= 2'd0;
        end
        else if (slot1 || slot2 || slot3) begin
            red <= 2'b11;
            green <= 2'b11;
            blue <= 2'b11;
        end
        else begin
            red <= 2'd0;
            green <= 2'd0;
            blue <= 2'd0;
        end
    end
endmodule: display_slots

// module display_symbols 
// (
//     input logic [1:0] symbol1, 
//     input logic [1:0] symbol2,
//     input logic [1:0] symbol3, 
//     input logic clk, 
//     input logic reset, 
//     input logic active, 
//     input logic [9:0] hcount, 
//     input logic [9:0] vcount, 
//     output logic [1:0] red,
//     output logic [1:0] green, 
//     output logic [1:0] blue
// );

//     //I will complete this module once I get my VGA monitor set up and working
//     //Psudeo code
//     //Basically I will take in the inputted symbols and each symbol value corresponds to a particular symbol
//     //I will draw out all the symbols and case on when a particular symbol will be displayed based on the symbol value
//     // Then I will set the red green blue values accordingly. 


// endmodule: display_symbols

module lfsr_slot1 
(
    input  logic clk,
    input  logic reset_n,
    input logic done_slot1, 
    output logic [1:0] actual_slot1
);

logic [1:0] lfsr_reg;

always_ff @(posedge clk) begin
    if (~reset_n) begin
        lfsr_reg <= 2'b01;  
    end
    else if (~done_slot1) begin
        lfsr_reg <= {lfsr_reg[0], lfsr_reg[1] ^ lfsr_reg[0]};
    end  
    else begin
        lfsr_reg <= lfsr_reg;
    end
end

assign actual_slot1 = lfsr_reg;
endmodule: lfsr_slot1

module lfsr_slot2 
(
    input  logic clk,
    input  logic reset_n,
    input logic done_slot2, 
    output logic [1:0] actual_slot2
);

logic [1:0] lfsr_reg;

always_ff @(posedge clk) begin
    if (~reset_n) begin
        lfsr_reg <= 2'b10;  
    end
    else if (~done_slot2) begin
        lfsr_reg <= {lfsr_reg[0], lfsr_reg[1] ^ lfsr_reg[0]};
    end  
    else begin
        lfsr_reg <= lfsr_reg;
    end
end

assign actual_slot2 = lfsr_reg;

endmodule: lfsr_slot2

module lfsr_slot3 
(
    input  logic clk,
    input  logic reset_n,
    input logic done_slot3, 
    output logic [1:0] actual_slot3
);

logic [1:0] lfsr_reg;

always_ff @(posedge clk) begin
    if (~reset_n) begin
        lfsr_reg <= 2'b11;  
    end
    else if (~done_slot3) begin
        lfsr_reg <= {lfsr_reg[0], lfsr_reg[1] ^ lfsr_reg[0]};
    end  
    else begin
        lfsr_reg <= lfsr_reg;
    end
end

assign actual_slot3 = lfsr_reg;

endmodule: lfsr_slot3


module slot_spinner
(
    input logic start, 
    input logic clk, 
    input logic reset_n,  
    output logic won,
    output logic [1:0] symbol1, 
    output logic [1:0] symbol2, 
    output logic [1:0] symbol3 
);
    logic [1:0] spinning_symbol1; 
    logic [1:0] spinning_symbol2; 
    logic [1:0] spinning_symbol3; 
    
    logic [1:0] acutal_slot1;
    logic [1:0] actual_slot2; 
    logic [1:0] actual_slot3; 

    logic done_slot1, done_slot2, done_slot3; 

    //This will take care of the slot spinning 
    slot_fsm control (.*);

    //This gets the actual slots of the 
    lfsr_slot1 slot1 (.*);
    lfsr_slot2 slot2 (.*);
    lfsr_slot3 slot3 (.*);

    always_comb begin
        //This is the case where all three slots are not done spinning
        if (~done_slot1 & ~done_slot2 & ~done_slot3) begin
            symbol1 = spinning_symbol1; 
            symbol2 = spinning_symbol2; 
            symbol3 = spinning_symbol3; 
            won = 0;
        end
        else if (done_slot1 & ~done_slot2 & ~done_slot3) begin
            symbol1 = actual_slot1; 
            symbol2 = spinning_symbol2; 
            symbol3 = spinning_symbol3; 
            won = 0;
        end
        else if (done_slot1 & done_slot2 & ~done_slot3) begin
            symbol1 = actual_slot1; 
            symbol2 = actual_slot2; 
            symbol3 = spinning_symbol3; 
            won = 0;
        end
        else if (done_slot1 & done_slot2 & done_slot3) begin
            symbol1 = actual_slot1; 
            symbol2 = actual_slot2;
            symbol3 = actual_slot3;
            if ((actual_slot1 == actual_slot3) & (actual_slot1 == actual_slot2) & (actual_slot2 == actual_slot3)) begin
                won = 1;
            end
            else begin
                won = 0;
            end        
        end
        //This is a error case
        else begin
            symbol1 = 3; 
            symbol2 = 2; 
            symbol3 = 0; 
        end
    end
    
endmodule: slot_spinner



//0 is the 7 symbol
//1 is the bomb symbol
//2 is the money symbol
//3 is the crown 
//I am only going to include 4 symbols for now I can add more later
module slot_fsm
(
    input logic start, 
    input logic clk, 
    input logic reset_n, 
    output logic [1:0] spinning_symbol1, 
    output logic [1:0] spinning_symbol2, 
    output logic [1:0] spinning_symbol3,  
    output logic done_slot1; 
    output logic done_slot2; 
    output logic done_slot3;  
);

    enum logic [2:0] {start_state, 
                      spin_slots,
                      done_spinning_slot1, 
                      done_spinning_slot2,  
                      done_spinning_slot3, 
                      idle_state} curr_state, next_state;
    
    //The global count is used to sort of be a timer of sorts that 
    logic [31:0] global_count;
    logic [1:0] final_symbol1;
    logic [1:0] final_symbol2; 
    logic [1:0] final_symbol3; 

    logic symbol1_eq_symbol2; 
    logic symbol1_eq_symbol3; 
    logic symbol2_eq_symbol3; 

    always_comb begin
        global_count = 0;
        case(curr_state) 
            start_state: begin
                //Increment the global counter
                global_count += 1;
                if (start) begin
                    spinning_symbol1 = 0; 
                    spinning_symbol2 = 1;
                    spinning_symbol3 = 2;
                    done_slot1 = 0;
                    done_slot2 = 0;
                    done_slot3 = 0;
                    next_state = spin_slot1;
                end
            end
            spin_slots: begin
                global_count += 1;
                spinning_symbol1 += 1;
                spinning_symbol2 += 1;
                spinning_symbol3 += 2;
                done_slot1 = 0;
                done_slot2 = 0;
                done_slot3 = 0;
                final_symbol1 = symbol1; 
                if (global_count >= 32'd100000)begin
                    next_state = done_spinning_slot1;
                end
                else begin
                    next_state = spin_slots;
                end
            end
            done_spinning_slot1: begin
                global_count += 1;
                spinning_symbol1 = final_symbol1;
                spinning_symbol2 += 2;
                spinning_symbol3 += 1;
                done_slot1 = 0;
                done_slot2 = 0;
                done_slot3 = 0;
                final_symbol2 = symbol2; 
                if (global_count >= 32'd200000) begin
                    next_state = done_spinning_slot2;
                end
                else begin
                    next_state = done_spinning_slot1; 
                end
            end
            done_spinning_slot2: begin
                global_count += 1;
                spinning_symbol1 = final_symbol1; 
                spinning_symbol2 = final_symbol2; 
                spinning_symbol3 += 2;
                done_slot1 = 1;
                done_slot2 = 0;
                done_slot3 = 0;
                final_symbol3 = symbol3; 
                if (global_count >= 32'd300000) begin
                    next_state = done_spinning_slot3; 
                end
                else begin
                    next_state = done_spinning_slot2;
                end
            end
            done_spinning_slot3: begin
                global_count += 1; 
                spinning_symbpl1 = final_symbol1; 
                spinning_symbol2 = final_symbol2; 
                spinning_symbol3 = final_symbol3;
                done_slot1 = 1;
                done_slot2 = 1;
                done_slot3 = 0;
                next_state = idle_state;   
            end
            idle_state: begin
                //Reset the global counter
                global_count = 0; 
                spinning_symbol1 = final_symbol1; 
                spinning_symbol2 = final_symbol2; 
                spinning_symbol3 = final_symbol3; 
                done_slot1 = 1;
                done_slot2 = 1;
                done_slot3 = 1;
                if (start) begin
                    next_state = start_state;
                end
                else begin
                    next_state = idle_state; 
                end
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (~reset_n) begin
            curr_state = start_state;
        end
        else begin
            curr_state = next_state; 
        end
    end


endmodule: slot_fsm

