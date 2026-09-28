module position_controller #(
    parameter TOLERANCE = 1
)(
    input  wire        clk,
    input  wire        reset,

    input  wire [8:0]  target_angle,
    input  wire [8:0]  current_angle,

    output reg         direction,
    output reg [1:0]   speed_level,
    output reg         aligned,

    output reg signed [9:0] error
);

    reg signed [9:0] raw_error;

    always @(posedge clk) begin

        if (reset) begin

            direction  <= 0;
            speed_level <= 0;
            aligned    <= 0;
            error      <= 0;

        end

        else begin

            /*
             * Calculate raw error
             */

            raw_error =
                $signed({1'b0, target_angle}) -
                $signed({1'b0, current_angle});

            /*
             * Convert error into shortest
             * circular path.
             */

            if (raw_error > 180)
                error <= raw_error - 360;

            else if (raw_error < -180)
                error <= raw_error + 360;

            else
                error <= raw_error;


            /*
             * Determine whether alignment
             * has been achieved.
             */

            if ((raw_error <= TOLERANCE) &&
                (raw_error >= -TOLERANCE)) begin

                aligned     <= 1;
                speed_level <= 0;

            end

            else begin

                aligned <= 0;

                /*
                 * Direction
                 *
                 * error > 0:
                 * rotate clockwise
                 *
                 * error < 0:
                 * rotate counter-clockwise
                 */

                if (error > 0)
                    direction <= 1;

                else
                    direction <= 0;


                /*
                 * Speed control
                 *
                 * Large error  → FAST
                 * Medium error → MEDIUM
                 * Small error  → SLOW
                 */

                if ((error > 20) || (error < -20))
                    speed_level <= 2;

                else if ((error > 5) || (error < -5))
                    speed_level <= 1;

                else
                    speed_level <= 0;

            end

        end

    end

endmodule