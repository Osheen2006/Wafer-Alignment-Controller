module wafer_wrap_tb;

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

    wire [2:0] fsm_state;


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
    .CLK_FREQ(100000000),
    .INITIAL_POSITION(1021)
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
    // VIRTUAL WAFER
    // =====================================================

    wafer_model #(
    .COUNTS_PER_REV(1024),
    .INITIAL_POSITION(1021)
)
    wafer (

        .clk(clk),
        .reset(reset),

        .step(step),
        .direction(direction),

        .encoder_a(encoder_a),
        .encoder_b(encoder_b)
    );


    // =====================================================
    // TEST
    // =====================================================

    initial begin

        reset = 1;
        start = 0;

        // Target = 1 degree
        target_angle = 9'd1;


        // Reset
        #100;

        reset = 0;

        #100;


        // -------------------------------------------------
        // NOTE:
        // We need the wafer to start near 359 degrees.
        // -------------------------------------------------

        // For now, start the normal model and observe
        // the controller's circular error behavior.


        start = 1;

        #20;

        start = 0;


        // Wait for completion

        wait(done);


        // -------------------------------------------------
        // Display result
        // -------------------------------------------------

        $display("");
        $display("========================================");
        $display("       WRAP-AROUND TEST RESULT");
        $display("========================================");

        $display("TARGET ANGLE : %d degrees",
                 target_angle);

        $display("FINAL ANGLE  : %d degrees",
                 current_angle);

        $display("DIRECTION    : %b",
                 direction);

        $display("ALIGNED      : %b",
                 aligned);

        $display("DONE         : %b",
                 done);

        $display("FAULT        : %b",
                 fault);

        $display("FSM STATE    : %d",
                 fsm_state);

        $display("========================================");


        #100;

        $finish;

    end


    // =====================================================
    // MONITOR
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