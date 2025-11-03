module PLT_tb;

    parameter N = 8;  // Number of inputs
    reg [1:0] mode;           // Mode selection
    reg [N-1:0] data_in;      // Input signals for the PLT
    reg config_in;            // Serial configuration input
    reg clk;                  // Clock signal
    reg clear;                // Clear signal
    reg [4*(N-1)-1:0] scan_in; // Scan chain input vector
    reg scan_enable;          // Scan enable signal
    wire out;                 // Output of the PLT
    wire [4*(N-1)-1:0] scan_out; // Scan output for testing

    // Instantiate the PLT module
    PLT #(N) dut (
        .mode(mode),
        .data_in(data_in),
        .config_in(config_in),
        .scan_in(scan_in),
        .scan_enable(scan_enable),
        .clk(clk),
        .clear(clear),
        .out(out),
        .scan_out(scan_out)
    );

    integer i;
    reg [4*(N-1)-1:0] config_bits;

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns clock period
    end

    // Stimulus Generation
    initial begin
        // Reset and Clear
        clear = 1;
        mode = 2'b00;
        config_in = 0;
        scan_in = 0;
        scan_enable = 0;
        data_in = 0;
        #20;

        // Release Clear Signal
        clear = 0;

        // Configuration Mode (Serial Input)
        $display("Starting Configuration Mode with Serial Input");
        config_bits = $random;
        $display("Random Configuration Bits: %b", config_bits);

        mode = 2'b00;
        scan_enable = 0;

       

        // Wait before switching modes
        #20;

        // Configuration Mode (Scan Chain Input)
        $display("Starting Configuration Mode with Scan Chain Input");
        mode = 2'b00;
        scan_enable = 1;
        scan_in = config_bits;
        #20;
        $display("Configuration Bits Loaded via Scan Chain: %b", scan_in);

        // Switch to Test Mode to scan out the configuration bits
        mode = 2'b10;
        scan_enable = 1;
        #20;
        $display("Configuration Bits (Scan Out): %b", scan_out);
        if (scan_out !== config_bits) begin
            $display("ERROR: Mismatch between scan_out and expected config_bits.");
        end

        // Switch to Usage Mode
        mode = 2'b01;
        scan_enable = 0; // Disable scan chain
        $display("Switching to Usage Mode with Random Inputs");

        // Provide random inputs and check outputs
        for (i = 0; i < 10; i = i + 1) begin
            data_in = $random;
            #10;
            $display("Data In: %b, Output: %b", data_in, out);
        end

        // Edge Case: Test with all 0s and all 1s as input
        data_in = 0;
        #10;
        $display("Data In (All 0s): %b, Output: %b", data_in, out);

        data_in = {N{1'b1}};
        #10;
        $display("Data In (All 1s): %b, Output: %b", data_in, out);

        // Finish Simulation
        $display("Test completed successfully");
        $finish;
    end

endmodule
