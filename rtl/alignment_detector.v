module alignment_detector #(
    parameter TOLERANCE = 1
)(
    input wire clk,
    input wire reset,

    input wire [8:0] target_angle,
    input wire [8:0] current_angle,

    output reg aligned,
    output reg alignment_error
);

    reg signed [9:0] error;

    // ============================================
    // Calculate shortest circular angular error
    // ============================================

    always @(*) begin

        error =
            $signed({1'b0, target_angle}) -
            $signed({1'b0, current_angle});

        // Handle circular angle
        if (error > 180)
            error = error - 360;

        else if (error < -180)
            error = error + 360;

    end


    // ============================================
    // Alignment decision
    // ============================================

    always @(posedge clk) begin

        if (reset) begin

            aligned <= 0;
            alignment_error <= 0;

        end

        else begin

            // Aligned only when error is within tolerance

            if ((error <= TOLERANCE) &&
                (error >= -TOLERANCE)) begin

                aligned <= 1;
                alignment_error <= 0;

            end

            else begin

                aligned <= 0;
                alignment_error <= 0;

            end

        end

    end

endmodule