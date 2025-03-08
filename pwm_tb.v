`timescale 1ns/1ps

module pwm_delay_tb;

    // Testbench signals
    reg clk;
    reg pwm_in;
    reg dir;
    wire pwm_delayed;
    wire delay_active_pos, delay_active_neg;
    wire nored, anded, H1, H2, L1, L2;

    // DUT (Device Under Test) instantiation
    pwm_delay uut (
        .clk(clk),
        .pwm_in(pwm_in),
        .dir(dir),
        .pwm_delayed(pwm_delayed),
        .delay_active_pos(delay_active_pos),
        .delay_active_neg(delay_active_neg),
        .nored(nored),
        .anded(anded),
        .H1(H1),
        .H2(H2),
        .L1(L1),
        .L2(L2)
    );

    // Clock generation: 100 MHz (10 ns period)
    always #5 clk = ~clk; 

    // Generate 1 kHz PWM signal (50% duty cycle)
    initial begin
        clk = 0;
        pwm_in = 0;
        dir = 0;

        // Change direction after some cycles
        #1500000 dir = 1;  // Change dir after 1.5 ms
        #2000000 dir = 0;  // Change back after 2 ms
        #1500000 dir = 1;  // Change again after 1.5 ms
    end

    // Generate PWM
    initial begin
        forever begin
            #500000 pwm_in = 1;  // High for 500 us
            #500000 pwm_in = 0;  // Low for 500 us
        end
    end

    // Monitor signals
    initial begin
        $dumpfile("pwm_delay_tb.vcd");  // VCD file for waveform
        $dumpvars(0, pwm_delay_tb);
        
        // Test for a few PWM cycles
        #5000000;
        $finish;
    end

endmodule
