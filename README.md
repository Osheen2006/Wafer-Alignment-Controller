# FPGA-Based Wafer Alignment Controller

## Overview

This project implements a Verilog RTL-based closed-loop wafer alignment controller for semiconductor automation applications.

The controller receives a target wafer angle and uses quadrature encoder feedback to determine the current wafer position. It calculates the shortest angular error, selects an appropriate motion speed, generates STEP/DIR control signals, and stops the wafer when the target position is reached.

The design was developed and verified using Xilinx Vivado.

---

## Objectives

- Implement closed-loop angular positioning using encoder feedback.
- Decode quadrature encoder A/B signals.
- Calculate circular angular position error.
- Generate STEP/DIR motion-control signals.
- Implement coarse-to-fine positioning.
- Detect alignment completion.
- Provide timeout-based fault handling.
- Verify 0°/360° angular wrap-around behavior.
- Verify FPGA timing and resource utilization.

---

## System Architecture

```text
                Target Angle
                     |
                     v
          +----------------------+
          | Position Controller  |
          +----------+-----------+
                     |
              Direction / Speed
                     |
                     v
          +----------------------+
          |    STEP Generator    |
          +----------+-----------+
                     |
                  STEP/DIR
                     |
                     v
          +----------------------+
          | Virtual Wafer Model  |
          +----------+-----------+
                     |
                 Encoder A/B
                     |
                     v
          +----------------------+
          | Encoder Decoder      |
          +----------+-----------+
                     |
                Current Angle
                     |
             +-------+-------+
             |               |
             v               v
    +----------------+ +-------------+
    | Alignment      | | Alignment   |
    | Detector       | | FSM         |
    +----------------+ +-------------+
                            |
                    +-------+-------+
                    |       |       |
                   DONE   FAULT    BUSY
