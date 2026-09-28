module step_generator #(
    parameter CLK_FREQ = 100_000_000,
    parameter FAST_RATE = 5_000_000,
    parameter MEDIUM_RATE = 2_000_000,
    parameter SLOW_RATE = 500_000
)(
    input wire clk,
    input wire reset,
    input wire enable,
    input wire direction,
    input wire [1:0] speed_level,

    output reg step,
    output reg dir
);

    reg [31:0] counter;
    reg [31:0] period;

    always @(*) begin
        case (speed_level)
            2'd0: period = CLK_FREQ / SLOW_RATE;
            2'd1: period = CLK_FREQ / MEDIUM_RATE;
            2'd2: period = CLK_FREQ / FAST_RATE;
            default: period = CLK_FREQ / SLOW_RATE;
        endcase
    end

    always @(posedge clk) begin
        if (reset) begin
            counter <= 0;
            step <= 0;
            dir <= 0;
        end
        else begin
            dir <= direction;

            if (!enable) begin
                counter <= 0;
                step <= 0;
            end
            else begin
                if (counter >= period - 1) begin
                    counter <= 0;
                    step <= 1;
                end
                else begin
                    counter <= counter + 1;
                    step <= 0;
                end
            end
        end
    end

endmodule