module pwm_delay (
    input  wire clk,       // 100 MHz clock
    input  wire pwm_in,    // PWM input signal
    input  wire dir,       // Direction control input
    output reg pwm_delayed, // Delayed PWM output
    output reg delay_active_pos,
    output reg delay_active_neg,
    output reg nored,
    output reg anded,
    output reg H1, H2, L1, L2  // Motor driver outputs
);  

    reg [5:0] delay_counter_pos; // Counter for posedge delay (50 cycles for 500 ns)
    reg [5:0] delay_counter_neg; // Counter for negedge delay (50 cycles for 500 ns)
    reg pwm_d;  // Previous clocked value of pwm_in

    wire posedge_detect, negedge_detect;

    always @(posedge clk) begin
        pwm_d <= pwm_in; // Register previous state of pwm_in
    end

    assign posedge_detect = (~pwm_d & pwm_in);  // Detect rising edge
    assign negedge_detect = (pwm_d & ~pwm_in);  // Detect falling edge

    // Delay logic for posedge
    always @(posedge clk) begin
        if (posedge_detect) begin
            delay_active_pos <= 1'b1;  // Start delay on rising edge
            delay_counter_pos <= 6'd0;
        end else if (delay_active_pos) begin
            if (delay_counter_pos == 6'd49) begin
                delay_active_pos <= 1'b0;  // Stop delay after 500 ns
            end else begin
                delay_counter_pos <= delay_counter_pos + 1;
            end
        end
    end

    // Delay logic for negedge
    always @(posedge clk) begin
        if (negedge_detect) begin
            delay_active_neg <= 1'b1;  // Start delay on falling edge
            delay_counter_neg <= 6'd0;
        end else if (delay_active_neg) begin
            if (delay_counter_neg == 6'd49) begin
                delay_active_neg <= 1'b0;  // Stop delay after 500 ns
            end else begin
                delay_counter_neg <= delay_counter_neg + 1;
            end
        end
    end

    // Assign delayed output
    always @(*) begin
        if (delay_active_pos || delay_active_neg) begin
            pwm_delayed = ~pwm_d; // Invert during delay
        end else begin
            pwm_delayed = pwm_d; // Follow stored PWM after delay
        end
    end

    // Logic operations
    always @(*) begin
        nored = ~(pwm_delayed | pwm_d);
        anded = (pwm_delayed & pwm_d);
    end

    // H-Bridge output assignments based on direction
    always @(*) begin
        case (dir)
            1'b0: begin
                H1 = anded;
                L2 = anded ^ nored;
                L1 = nored;
                H2 = 1'b0;
            end
            1'b1: begin
                H2 = anded;
                L1 = anded ^ nored;
                L2 = nored;
                H1 = 1'b0;
            end
        endcase
    end
endmodule
