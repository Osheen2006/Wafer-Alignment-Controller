module wafer_align_top #(
    parameter COUNTS_PER_REV = 1024,
    parameter TOLERANCE = 1,
    parameter TIMEOUT_COUNT = 1000000,
    parameter CLK_FREQ = 100000000,
    parameter INITIAL_POSITION = 0
)(
    input wire clk,
    input wire reset,

    // User command
    input wire start,

    // Target wafer notch angle
    input wire [8:0] target_angle,

    // Encoder
    input wire encoder_a,
    input wire encoder_b,

    // Outputs
    output wire step,
    output wire direction,

    output wire [8:0] current_angle,

    output wire aligned,
    output wire busy,
    output wire done,
    output wire fault,

    // FSM debug output
    output wire [2:0] fsm_state
);


    // =====================================================
    // INTERNAL SIGNALS
    // =====================================================

    wire signed [31:0] position_count;

    wire [1:0] speed_level;

    wire signed [9:0] position_error;

    wire controller_aligned;

    wire detector_aligned;

    wire alignment_error;

    wire motion_enable;


    // =====================================================
    // 1. ENCODER DECODER
    // =====================================================

    encoder_decoder #(
    .COUNTS_PER_REV(COUNTS_PER_REV),
    .INITIAL_POSITION(INITIAL_POSITION)
)
    encoder_inst (

        .clk(clk),
        .reset(reset),

        .encoder_a(encoder_a),
        .encoder_b(encoder_b),

        .position_count(position_count),
        .angle_deg(current_angle)

    );


    // =====================================================
    // 2. POSITION CONTROLLER
    // =====================================================

    position_controller #(
        .TOLERANCE(TOLERANCE)
    )
    controller_inst (

        .clk(clk),
        .reset(reset),

        .target_angle(target_angle),
        .current_angle(current_angle),

        .direction(direction),
        .speed_level(speed_level),

        .aligned(controller_aligned),
        .error(position_error)

    );


    // =====================================================
    // 3. ALIGNMENT DETECTOR
    // =====================================================

    alignment_detector #(
        .TOLERANCE(TOLERANCE)
    )
    detector_inst (

        .clk(clk),
        .reset(reset),

        .target_angle(target_angle),
        .current_angle(current_angle),

        .aligned(detector_aligned),
        .alignment_error(alignment_error)

    );


    // =====================================================
    // 4. ALIGNMENT FSM
    // =====================================================

    alignment_fsm #(
        .TIMEOUT_COUNT(TIMEOUT_COUNT)
    )
    fsm_inst (

        .clk(clk),
        .reset(reset),

        .start(start),

        .aligned(detector_aligned),

        .alignment_error(alignment_error),

        .enable_motion(motion_enable),

        .busy(busy),
        .done(done),
        .fault(fault),

        .state(fsm_state)

    );


    // =====================================================
    // 5. STEP GENERATOR
    // =====================================================

    step_generator #(
        .CLK_FREQ(CLK_FREQ)
    )
    step_inst (

        .clk(clk),
        .reset(reset),

        .enable(motion_enable),

        .direction(direction),
        .speed_level(speed_level),

        .step(step),

        .dir()

    );


    // =====================================================
    // FINAL ALIGNED SIGNAL
    // =====================================================

    assign aligned = detector_aligned;


endmodule