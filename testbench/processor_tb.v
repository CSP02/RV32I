module Processor_tb;
    reg clk, rst;
    
    // Instantiate the Processor
    Processor uut (
        .clk(clk),
        .rst(rst)
    );
    
    // Clock generation
    always #5 clk = ~clk; // Generate a clock with 10ns period
    
    initial begin

        // Initialize inputs
        clk = 0;
        rst = 1;
        
        // Apply reset
        #5 rst = 0;
        
        // Run the simulation for a few cycles
        #150;
        // End simulation
        $finish;
    end
endmodule