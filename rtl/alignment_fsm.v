module alignment_fsm #(
    parameter TIMEOUT_COUNT = 100_000_000
)(
    input wire clk,
    input wire reset,

    input wire start,
    input wire aligned,
    input wire alignment_error,

    output reg enable_motion,
    output reg busy,
    output reg done,
    output reg fault,

    output reg [2:0] state
);

    // =====================================================
    // STATE ENCODING
    // =====================================================

    localparam IDLE     = 3'd0;
    localparam START    = 3'd1;
    localparam ROTATING = 3'd2;
    localparam ALIGNED  = 3'd4;
    localparam DONE     = 3'd5;
    localparam FAULT    = 3'd6;

    reg [31:0] timeout_counter;


    // =====================================================
    // FSM
    // =====================================================

    always @(posedge clk) begin

        if (reset) begin

            state <= IDLE;

            enable_motion <= 1'b0;
            busy          <= 1'b0;
            done          <= 1'b0;
            fault         <= 1'b0;

            timeout_counter <= 32'd0;

        end

        else begin

            case (state)

                // =========================================
                // IDLE
                // =========================================

                IDLE: begin

                    enable_motion <= 1'b0;
                    busy          <= 1'b0;
                    done          <= 1'b0;
                    fault         <= 1'b0;

                    timeout_counter <= 32'd0;

                    if (start) begin
                        state <= START;
                    end

                end


                // =========================================
                // START
                // =========================================

                START: begin

                    enable_motion <= 1'b1;
                    busy          <= 1'b1;
                    done          <= 1'b0;
                    fault         <= 1'b0;

                    timeout_counter <= 32'd0;

                    state <= ROTATING;

                end


                // =========================================
                // ROTATING
                // =========================================

                ROTATING: begin

                    enable_motion <= 1'b1;
                    busy          <= 1'b1;
                    done          <= 1'b0;
                    fault         <= 1'b0;


                    // Alignment reached
                    if (aligned) begin

                        state <= ALIGNED;

                    end


                    // Explicit alignment error
                    else if (alignment_error) begin

                        state <= FAULT;

                    end


                    // Timeout
                    else if (timeout_counter >= TIMEOUT_COUNT) begin

                        state <= FAULT;

                    end


                    // Continue rotating
                    else begin

                        timeout_counter <=
                            timeout_counter + 1'b1;

                    end

                end


                // =========================================
                // ALIGNED
                // =========================================

                ALIGNED: begin

                    enable_motion <= 1'b0;
                    busy          <= 1'b1;
                    done          <= 1'b0;
                    fault         <= 1'b0;

                    state <= DONE;

                end


                // =========================================
                // DONE
                // =========================================

                DONE: begin

                    enable_motion <= 1'b0;
                    busy          <= 1'b0;
                    done          <= 1'b1;
                    fault         <= 1'b0;

                    // Stay in DONE until a new start
                    if (start) begin

                        timeout_counter <= 32'd0;

                        state <= START;

                    end

                end


                // =========================================
                // FAULT
                // =========================================

                FAULT: begin

                    enable_motion <= 1'b0;
                    busy          <= 1'b0;
                    done          <= 1'b0;
                    fault         <= 1'b1;

                    // Stay in FAULT until reset
                    state <= FAULT;

                end


                // =========================================
                // DEFAULT
                // =========================================

                default: begin

                    state <= IDLE;

                    enable_motion <= 1'b0;
                    busy          <= 1'b0;
                    done          <= 1'b0;
                    fault         <= 1'b0;

                    timeout_counter <= 32'd0;

                end

            endcase

        end

    end

endmodule