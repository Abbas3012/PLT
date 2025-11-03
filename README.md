PLT Module and Testbench (Parametrized Look-Up Table)

Introduction
This repository contains the Verilog implementation of a Parametrized Look-Up Table (PLT) module and its associated testbench (PLT_tb). The PLT implements a configurable logic function using a tree structure of 2-input LUTs. It supports three operational modes: Configuration, Usage, and Test (Scan).
Design Under Test (DUT): module PLT
The PLT module is a synthesizable description of a reconfigurable logic block, parameterized by the number of inputs, N.

Parameters
Parameter: N. Default Value: 8. Description: The number of primary input signals (must be a power of 2, e.g., 4, 8, 16).

Ports
Port: mode. Direction: Input. Width: [1:0] Description: Mode Selection: 00=Config, 01=Usage, 10=Test. 
Port: data_in. Direction: Input. Width: [N-1:0]. Description: Primary input signals for logic evaluation in Usage Mode. 
Port: config_in. Direction: Input. Width: [0]. Description: Serial data input for configuration.
Port: scan_in. Direction: Input. Width: [4(N-1)-1:0]. Description: Parallel configuration vector for scan chain input. 
Port: scan_enable. Direction: Input. Width: [0]. Description: Enables parallel scan chain configuration/output. 
Port: clk. Direction: Input. Width: [0]. Description: Clock signal for synchronous operations (Configuration/Test). 
Port: clear. Direction: Input. Width: [0]. Description: Synchronous reset to clear all LUT contents (4'b0000).
Port: out. Direction: Output. Width: [0]. Description: Final output of the PLT logic function (Usage Mode). 
Port: scan_out. Direction: Output. Width: [4(N-1)-1:0]. Description: Scan chain output of the internal configuration bits (Test Mode).

Operational Modes
Configuration (mode = 2'b00): Loads 4-bit configuration data into each of the N-1 LUTs. If scan_enable is High: Configuration is loaded in parallel from scan_in. If scan_enable is Low: Configuration bits are shifted serially from config_in.
Usage (mode = 2'b01): Evaluates the logic function defined by the configured LUTs based on the data_in vector.
Test (mode = 2'b10): When scan_enable is High, the stored internal configuration (config_bits) is driven out onto the scan_out port for verification.

Testbench: module PLT_tb
The PLT_tb module is designed to comprehensively test the functionality of the PLT module with N=8.

Test Scenario Outline
Initialization: A synchronous clear is applied to reset the DUT.
Configuration Test (Scan Chain): A random 28-bit configuration vector (config_bits) is generated. The DUT is placed in Configuration Mode (2'b00) with scan_enable = 1. The configuration vector is loaded via scan_in.
Test Mode Verification: The DUT is switched to Test Mode (2'b10) with scan_enable = 1. The configuration is read out on scan_out and compared against the original config_bits to verify the loading process.
Usage Mode Test: The DUT is switched to Usage Mode (2'b01). The module is tested with 10 cycles of random data_in inputs. Additional tests are run for the all-zeros (8'b00000000) and all-ones (8'b11111111) input vectors.
Simulation Environment
Clock: Generated with a 10ns period (#5 clk = ~clk).
Finish: The simulation terminates using $finish after all tests are completed.

How to Run Simulation
To run the simulation using a standard Verilog simulator (e.g., Icarus Verilog or QuestaSim):
Save the PLT module and PLT_tb into their respective files (e.g., plt.v and plt_tb.v).

Compile and run the testbench (example using Icarus Verilog):

iverilog plt.v plt_tb.v -o plt_sim vvp plt_sim
