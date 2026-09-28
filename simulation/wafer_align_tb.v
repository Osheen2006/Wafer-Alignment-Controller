`timescale 1ns/1ps

module wafer_align_tb;

    reg clk;
    reg reset;
    reg start;

    reg [8:0] target_angle;

    wire step;
    wire direction;

    wire [8:0] current_angle;

    wire aligned;
    wire busy;
    wire done;
    wire fault;

    wire encoder_a;
    wire encoder_b;


    // =====================================================
    // CLOCK
    // =====================================================

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    // =====================================================
    // DUT
    // =====================================================

    wafer_align_top #(
        .COUNTS_PER_REV(1024),
        .TOLERANCE(1),
        .TIMEOUT_COUNT(10000000),
        .CLK_FREQ(100000000)
    ) dut (

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
        .fault(fault)
    );


    // =====================================================
    // VIRTUAL WAFER
    // =====================================================

    wafer_model #(
        .COUNTS_PER_REV(1024)
    ) wafer (

        .clk(clk),
        .reset(reset),

        .step(step),
        .direction(direction),

        .encoder_a(encoder_a),
        .encoder_b(encoder_b)
    );


    // =====================================================
    // TASK: RUN ONE ALIGNMENT TEST
    // =====================================================

    task run_test;

        input [8:0] test_angle;

        begin

            // -----------------------------
            // Reset system
            // -----------------------------

            reset = 1;
            start = 0;

            #100;

            reset = 0;

            #100;


            // -----------------------------
            // Set target
            // -----------------------------

            target_angle = test_angle;


            // -----------------------------
            // Start alignment
            // -----------------------------

            #20;

            start = 1;

            #20;

            start = 0;


            // -----------------------------
            // Wait for completion
            // -----------------------------

            wait(done);


            // -----------------------------
            // Display result
            // -----------------------------

            $display("----------------------------------------");

            $display("TARGET ANGLE  : %d degrees",
                     target_angle);

            $display("FINAL ANGLE   : %d degrees",
                     current_angle);

            $display("ALIGNED       : %b",
                     aligned);

            $display("DONE          : %b",
                     done);

            $display("FAULT         : %b",
                     fault);

            $display("DIRECTION     : %b",
                     direction);


            // -----------------------------
            // Pass / Fail
            // -----------------------------

            if (aligned && done && !fault)

                $display("RESULT        : PASS");

            else

                $display("RESULT        : FAIL");

            $display("----------------------------------------");


            // Give waveform time to show DONE

            #100;

        end

    endtask


    // =====================================================
    // MAIN TEST SEQUENCE
    // =====================================================

    initial begin

        reset = 1;
        start = 0;
        target_angle = 0;


        // Initial reset

        #100;

        reset = 0;

        #100;


        // =================================================
        // TEST 1
        // =================================================

        run_test(45);


        // =================================================
        // TEST 2
        // =================================================

        run_test(90);


        // =================================================
        // TEST 3
        // =================================================

        run_test(137);


        // =================================================
        // TEST 4
        // =================================================

        run_test(180);


        // =================================================
        // TEST 5
        // =================================================

        run_test(270);


        // =================================================
        // FINISH
        // =================================================

        $display("");
        $display("========================================");
        $display("ALL ALIGNMENT TESTS COMPLETED");
        $display("========================================");

        #100;

        $finish;

    end


    // =====================================================
    // LIVE MONITOR
    // =====================================================

    initial begin

        $monitor(
            "TIME=%0t | TARGET=%d | ANGLE=%d | STEP=%b | DIR=%b | ALIGNED=%b | BUSY=%b | DONE=%b | FAULT=%b",
            $time,
            target_angle,
            current_angle,
            step,
            direction,
            aligned,
            busy,
            done,
            fault
        );

    end

endmodule