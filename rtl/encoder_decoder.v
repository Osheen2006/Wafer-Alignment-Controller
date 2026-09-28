module encoder_decoder #(
    parameter COUNTS_PER_REV = 1024,
    parameter INITIAL_POSITION = 0
)(
    input wire clk,
    input wire reset,

    input wire encoder_a,
    input wire encoder_b,

    output reg signed [31:0] position_count,
    output reg [8:0] angle_deg
);

    reg [1:0] prev_state;
    reg [1:0] curr_state;

    reg signed [31:0] next_position;


    // =====================================================
    // Encoder state corresponding to initial position
    // =====================================================

    function [1:0] initial_encoder_state;
        input integer position;
        begin
            case (position % 4)

                0: initial_encoder_state = 2'b00;
                1: initial_encoder_state = 2'b01;
                2: initial_encoder_state = 2'b11;
                3: initial_encoder_state = 2'b10;

                default:
                    initial_encoder_state = 2'b00;

            endcase
        end
    endfunction


    // =====================================================
    // Quadrature decoder
    // =====================================================

    always @(posedge clk) begin

        if (reset) begin

            position_count <= INITIAL_POSITION;

            angle_deg <=
                (INITIAL_POSITION * 360) /
                COUNTS_PER_REV;

            prev_state <=
                initial_encoder_state(INITIAL_POSITION);

        end

        else begin

            curr_state = {encoder_a, encoder_b};

            next_position = position_count;


            // -------------------------------------------------
            // Forward
            // -------------------------------------------------

            case ({prev_state, curr_state})

                4'b0001,
                4'b0111,
                4'b1110,
                4'b1000:

                    next_position = position_count + 1;


                // -------------------------------------------------
                // Reverse
                // -------------------------------------------------

                4'b0010,
                4'b1011,
                4'b1101,
                4'b0100:

                    next_position = position_count - 1;


                default:

                    next_position = position_count;

            endcase


            // -------------------------------------------------
            // Wrap around
            // -------------------------------------------------

            if (next_position >= COUNTS_PER_REV)

                next_position = 0;

            else if (next_position < 0)

                next_position = COUNTS_PER_REV - 1;


            // -------------------------------------------------
            // Store
            // -------------------------------------------------

            position_count <= next_position;


            // -------------------------------------------------
            // Angle
            // -------------------------------------------------

            angle_deg <=
                (next_position * 360) /
                COUNTS_PER_REV;


            // -------------------------------------------------
            // Save encoder state
            // -------------------------------------------------

            prev_state <= curr_state;

        end

    end

endmodule