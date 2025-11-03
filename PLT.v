module PLT #(
    parameter N = 8  // Number of inputs, must be a power of 2
) (
    input wire [1:0] mode,            // Mode selection: 00 = Configuration, 01 = Usage, 10 = Test
    input wire [N-1:0] data_in,       // N input signals for the PLT
    input wire config_in,             // Serial configuration input
    input wire [4*(N-1)-1:0] scan_in, // Scan chain input vector
    input wire scan_enable,           // Scan enable signal
    input wire clk,                   // Clock signal
    input wire clear,                 // Clear signal to reset all LUT contents
    output reg out,                   // Output of the PLT
    output reg [4*(N-1)-1:0] scan_out // Scan output for testing
);

    localparam NUM_LUTS = N - 1;
    reg [3:0] lut_config[NUM_LUTS-1:0]; // LUT configurations
    reg lut_outputs[NUM_LUTS-1:0];      // LUT outputs
    reg [4*(N-1)-1:0] config_bits;      // Configuration bits storage

    integer i;

    // Initialization block
    initial begin
        scan_out = 0;
        out = 0;
        for (i = 0; i < NUM_LUTS; i = i + 1) begin
            lut_config[i] = 4'b0000;
            lut_outputs[i] = 0;
        end
    end

    // Configuration and Clear Mode
    always @(posedge clk) begin
        if (clear) begin
            config_bits <= 0;
            scan_out <= 0;
            out <= 0;
            for (i = 0; i < NUM_LUTS; i = i + 1) begin
                lut_config[i] <= 4'b0000;
                lut_outputs[i] <= 0;
            end
        end
        else if (mode == 2'b00) begin
            if (scan_enable) begin
                // Load configuration via scan chain
                config_bits <= scan_in;
                for (i = 0; i < NUM_LUTS; i = i + 1) begin
                    lut_config[i] <= scan_in[(i+1)*4-1 -: 4];
                    $display("Scan Chain: LUT %0d Config: %b", i, lut_config[i]);
                end
            end
            else begin
                // Serial configuration input
                config_bits <= {config_bits[4*(N-1)-2:0], config_in};
                for (i = 0; i < NUM_LUTS; i = i + 1) begin
                    lut_config[i] <= config_bits[(i+1)*4-1 -: 4];
                    $display("Serial Config: LUT %0d Config: %b", i, lut_config[i]);
                end
            end
        end
    end

    // Usage Mode
    always @(*) begin
        if (mode == 2'b01) begin
            // Evaluate leaf LUTs (first level)
            for (i = 0; i < N/2; i = i + 1) begin
                lut_outputs[i] = (data_in[2*i +: 2] == 2'b00) ? lut_config[i][0] :
                                 (data_in[2*i +: 2] == 2'b01) ? lut_config[i][1] :
                                 (data_in[2*i +: 2] == 2'b10) ? lut_config[i][2] :
                                                                lut_config[i][3];
                $display("Leaf LUT %0d Output: %b", i, lut_outputs[i]);
            end

            // Evaluate intermediate LUTs
            for (i = (N/2); i < NUM_LUTS; i = i + 1) begin
                lut_outputs[i] = (lut_outputs[2*(i - N/2)] == 0 && lut_outputs[2*(i - N/2)+1] == 0) ? lut_config[i][0] :
                                 (lut_outputs[2*(i - N/2)] == 0 && lut_outputs[2*(i - N/2)+1] == 1) ? lut_config[i][1] :
                                 (lut_outputs[2*(i - N/2)] == 1 && lut_outputs[2*(i - N/2)+1] == 0) ? lut_config[i][2] :
                                                                                                        lut_config[i][3];
                $display("Intermediate LUT %0d Output: %b", i, lut_outputs[i]);
            end

            // Assign root output
            out = lut_outputs[NUM_LUTS-1];
            $display("Root Output: %b", out);
        end
    end

    // Test Mode
    always @(posedge clk) begin
        if (clear) begin
            scan_out <= 0;
        end
        else if (mode == 2'b10 && scan_enable) begin
            scan_out <= config_bits;
        end
    end

endmodule

