module wafer_model #(
    parameter COUNTS_PER_REV = 1024,
    parameter INITIAL_POSITION = 0
)(
    input wire clk,
    input wire reset,

    input wire step,
    input wire direction,

    output reg encoder_a,
    output reg encoder_b
);

    reg [31:0] position;


    // =====================================================
    // Quadrature encoder output
    // =====================================================

    always @(*) begin

        case (position % 4)

            0: begin
                encoder_a = 0;
                encoder_b = 0;
            end

            1: begin
                encoder_a = 0;
                encoder_b = 1;
            end

            2: begin
                encoder_a = 1;
                encoder_b = 1;
            end

            3: begin
                encoder_a = 1;
                encoder_b = 0;
            end

            default: begin
                encoder_a = 0;
                encoder_b = 0;
            end

        endcase

    end


    // =====================================================
    // Virtual wafer movement
    // =====================================================

    always @(posedge clk) begin

        if (reset) begin

            position <= INITIAL_POSITION;

        end

        else if (step) begin

            // Forward rotation
            if (direction) begin

                if (position >= COUNTS_PER_REV - 1)

                    position <= 0;

                else

                    position <= position + 1;

            end

            // Reverse rotation
            else begin

                if (position == 0)

                    position <= COUNTS_PER_REV - 1;

                else

                    position <= position - 1;

            end

        end

    end

endmodule