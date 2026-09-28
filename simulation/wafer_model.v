module wafer_model #(
    parameter COUNTS_PER_REV = 1024
)(
    input wire clk,
    input wire reset,

    input wire step,
    input wire direction,

    output reg encoder_a,
    output reg encoder_b
);

    // Virtual wafer position
    reg [31:0] position;

    // Quadrature encoder state
    reg [1:0] quad_state;

    always @(posedge clk) begin

        if (reset) begin

            position    <= 0;
            quad_state  <= 2'b00;
            encoder_a   <= 0;
            encoder_b   <= 0;

        end

        else if (step) begin

            // --------------------------------
            // Move virtual wafer
            // --------------------------------

            if (direction) begin

                if (position >= COUNTS_PER_REV - 1)
                    position <= 0;
                else
                    position <= position + 1;

            end

            else begin

                if (position == 0)
                    position <= COUNTS_PER_REV - 1;
                else
                    position <= position - 1;

            end


            // --------------------------------
            // Generate quadrature sequence
            // --------------------------------

            if (direction) begin

                case (quad_state)

                    2'b00: quad_state <= 2'b01;
                    2'b01: quad_state <= 2'b11;
                    2'b11: quad_state <= 2'b10;
                    2'b10: quad_state <= 2'b00;

                    default: quad_state <= 2'b00;

                endcase

            end

            else begin

                case (quad_state)

                    2'b00: quad_state <= 2'b10;
                    2'b10: quad_state <= 2'b11;
                    2'b11: quad_state <= 2'b01;
                    2'b01: quad_state <= 2'b00;

                    default: quad_state <= 2'b00;

                endcase

            end

        end

        // --------------------------------
        // Convert quadrature state to A/B
        // --------------------------------

        case (quad_state)

            2'b00: begin
                encoder_a <= 0;
                encoder_b <= 0;
            end

            2'b01: begin
                encoder_a <= 0;
                encoder_b <= 1;
            end

            2'b11: begin
                encoder_a <= 1;
                encoder_b <= 1;
            end

            2'b10: begin
                encoder_a <= 1;
                encoder_b <= 0;
            end

            default: begin
                encoder_a <= 0;
                encoder_b <= 0;
            end

        endcase

    end

endmodule