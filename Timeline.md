![[MCT333_Project_Competition_Description_Spring2026_v4 (1).pdf#page=10&rect=58,528,543,755&color=yellow|MCT333_Project_Competition_Description_Spring2026_v4 (1), p.10]]
![[MCT333_Project_Competition_Description_Spring2026_v4 (1).pdf#page=12&rect=60,63,537,757&color=yellow|MCT333_Project_Competition_Description_Spring2026_v4 (1), p.12]]
![[MCT333_Project_Competition_Description_Spring2026_v4 (1).pdf#page=13&rect=60,664,536,780&color=yellow|MCT333_Project_Competition_Description_Spring2026_v4 (1), p.13]]
## Innovation Requirement (Functional Analysis + TRIZ)

In addition to VDI 2206, each team must perform the following:
- functional analysis (functional decomposition, function structure, and functional block diagrams)
- and apply TRIZ to generate innovative concepts and resolve key design contradictions. (e.g. speed vs. accuracy; stiffness vs. weight; payload vs. battery life)

> **Note**: evidence of this process must be included in the technical report and design reviews.

**Required Deliverables:**

- Functional decomposition and function structure diagram (functions, flows of energy/material/signal)
- Functional block diagram for the whole system and for each module (base, manipulator, perception, HMI)
- TRIZ worksheet: contradiction statement(s), selected inventive principles, and resulting concept alternatives
- Concept selection rationale (trade-off table/morphological chart) linked back to requirements

---

## Phase 0 - Problem Definition and Requirements

- Translate competition rules into measurable system requirements (speed, payload, accuracy, autonomy level, safety)
- Define interfaces (mechanical, electrical, communication) and success metrics
- Perform risk assessment (FMEA-style) and define mitigation actions

---

## Phase 1 - System-Level Design (Concept & Architecture)

- Select base configuration (3-omni vs 4-omni) and arm DOF/gripper concept
- Define system architecture, module boundaries, and power + communication buses
- Preliminary BOM and budget planning

---

## Phase 2 - Domain-Specific Design

**Mechanical**

- CAD, material selection, manufacturing drawings
- Stress/deflection checks where needed

**Actuation**

- Compute required wheel torque and arm joint torques
- Select motors, gearboxes, and drivers

**Electronics**

- Schematics, PCB, connectors
- Protection (fuse, TVS, reverse polarity) and enclosure

**Control**

- Kinematic modeling
- Controllers for base/arm, state machine, safety interlocks

**Software**

- Perception pipeline, autonomy behaviors
- Calibration procedures, logging and testing tools

---

## Phase 3 - Modeling and Simulation

- Model base holonomic kinematics and validate inverse/forward kinematics
- Simulate actuator sizing (torque/speed profiles) and verify margins
- Simulate control performance (tracking, stability, disturbance rejection)
- Validate perception approach on recorded data or synthetic images

---

## Phase 4 - Implementation and Subsystem Verification

- Fabricate and assemble modules (base and arm)
- Verify each module independently: motor control loops, sensor calibration, communication, safety response
- Document test results and iterate the design

---

## Phase 5 - System Integration, Validation, and Competition Readiness

- Integrate modules using defined interfaces; conduct integration tests with checklists
- Run repeatability tests (perform the task for X times without errors)
- Finalize documentation, datasheet, and demonstration videos