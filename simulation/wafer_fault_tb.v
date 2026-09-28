`timescale 1ns/1ps

module wafer_fault_tb;

    // =====================================================
    // TESTBENCH SIGNALS
    // =====================================================

    reg clk;
    reg reset;
    reg start;

    reg [8:0] target_angle;

    // Encoder deliberately frozen
    reg encoder_a;
    reg encoder_b;


    // =====================================================
    // DUT OUTPUTS
    // =====================================================

    wire step;
    wire direction;

    wire [8:0] current_angle;

    wire aligned;
    wire busy;
    wire done;
    wire fault;

    wire [2:0] fsm_state;


    // =====================================================
    // CLOCK
    // =====================================================

    initial begin

        clk = 0;

        forever #5 clk = ~clk;

    end


    // =====================================================
    // DEVICE UNDER TEST
    // =====================================================

    wafer_align_top #(

        .COUNTS_PER_REV(1024),

        .TOLERANCE(1),

        // VERY SMALL TIMEOUT FOR TESTING
        .TIMEOUT_COUNT(100),

        .CLK_FREQ(100000000)

    )
    dut (

        .clk(clk),
        .reset(reset),

        .start(start),

        .target_angle(target_angle),

        .encoder_a(encoder_a),
        .encoder_b(encoder_b),

        .step(step),
        .direction(direction),

        .current_angle(current_angle),

        .aligned(aligned),
        .busy(busy),
        .done(done),
        .fault(fault),

        .fsm_state(fsm_state)

    );


    // =====================================================
    // FAULT TEST
    // =====================================================

    initial begin

        // -----------------------------------------------
        // Initial conditions
        // -----------------------------------------------

        reset = 1'b1;

        start = 1'b0;

        target_angle = 9'd90;

        // Encoder frozen
        encoder_a = 1'b0;
        encoder_b = 1'b0;


        // -----------------------------------------------
        // Reset
        // -----------------------------------------------

        #100;

        reset = 1'b0;

        #100;


        // -----------------------------------------------
        // Start alignment
        // -----------------------------------------------

        start = 1'b1;

        #20;

        start = 1'b0;


        // -----------------------------------------------
        // Wait for FAULT
        // -----------------------------------------------

        wait(fault);


        // -----------------------------------------------
        // Display result
        // -----------------------------------------------

        $display("");
        $display("========================================");
        $display("           FAULT TEST RESULT");
        $display("========================================");

        $display("TARGET ANGLE : %d degrees",
                 target_angle);

        $display("CURRENT ANGLE: %d degrees",
                 current_angle);

        $display("ALIGNED      : %b",
                 aligned);

        $display("BUSY         : %b",
                 busy);

        $display("DONE         : %b",
                 done);

        $display("FAULT        : %b",
                 fault);

        $display("FSM STATE    : %d",
                 fsm_state);


        // -----------------------------------------------
        // PASS / FAIL
        // -----------------------------------------------

        if (fault) begin

            $display("RESULT       : FAULT TEST PASSED");

        end

        else begin

            $display("RESULT       : FAULT TEST FAILED");

        end


        $display("========================================");
        $display("");


        #100;

        $finish;

    end


    // =====================================================
    // LIVE MONITOR
    // =====================================================

    initial begin

        $monitor(
            "TIME=%0t | TARGET=%d | ANGLE=%d | STEP=%b | DIR=%b | ALIGNED=%b | BUSY=%b | DONE=%b | FAULT=%b | STATE=%d",
            $time,
            target_angle,
            current_angle,
            step,
            direction,
            aligned,
            busy,
            done,
            fault,
            fsm_state
        );

    end

endmodule