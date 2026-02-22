# 🦾 Manipulator Subsystem - Omni-Wheel Mobile Manipulator

**Mechatronics Engineering Department | Faculty of Engineering, Ain Shams University**

This repository contains the mechanical, electrical, and software design files for the **Manipulator Subsystem (Arm & Gripper)** of the Modular Omni-Wheel Mobile Manipulator, developed for the **Spring 2026 Mechatronics Omni-Challenge**.
## 🔭 Overview

The Manipulator Module is designed as a standalone, professionally packaged subsystem. Its primary objective is to autonomously reach, grasp $5\times5\times5$ cm cubes encoded with QR codes from a 40 cm elevated pedestal, identify their color via an integrated camera, and securely place them into specific onboard storage bins.

It acts as the upper layer of the mobile robot and communicates seamlessly with the Mobile Base via a robust CAN/UART interface.

## ✨ Key Features

- **4-DOF Articulated Design:** Optimized to reach the 40 cm pedestal while folding completely within the strict $50\times50\times70$ cm global starting constraint.
    
- **Smart Serial Actuation:** Utilizes daisy-chained smart serial servos (e.g., Dynamixel/Feetech) with built-in absolute encoders and PID control to minimize weight and wire clutter.
    
- **Eye-in-Hand Perception:** Offset end-effector RGB camera paired with an active constant-current LED ring for flicker-free QR code decoding.
    
- **V-Shaped Interlocking Gripper:** Custom parallel-jaw gripper lined with high-friction silicone pads to ensure cubes are not dropped during aggressive omni-directional base maneuvers.
    
- **Custom Integration PCB:** Dedicated onboard PDU and MCU with hardware debouncing, CAN transceivers, and isolated motor power injection.
    

## 🛠 Hardware Specifications

|Specification|Target / Limit|Notes|
|---|---|---|
|**Degrees of Freedom**|4 (Base, Shoulder, Elbow, Wrist) + 1 (Gripper)|Focused on pick-and-place efficiency.|
|**Max Reach (Horizontal)**|$\ge 40$ cm|Measured from the base joint center.|
|**Payload Capacity**|$250$ g (Nominal) / $500$ g (Max)|For handling $5\times5\times5$ cm cubes.|
|**Module Weight**|$\le 3.0$ kg|Keeps total robot weight under 10 kg.|
|**Operating Voltage**|12V / 24V (Raw)|Stepped down locally to 5V/3.3V.|
|**Comms Protocol**|CAN Bus / RS-485|Optically isolated from motor noise.|

## 🔌 Plug-and-Play Integration

To meet the **< 5-minute integration** constraint, the arm interfaces with the mobile base via a strict modular boundary:

1. **Mechanical:** Chamfered alignment pins and a quick-release latch on the mounting plate.
    
2. **Power:** Single `XT60` or `Anderson Powerpole` connector delivering fused raw battery power.
    
3. **Data:** Single locking `JST-SM` or `Aviation` plug carrying the communication bus lines.
    
4. **Safety:** Software heartbeat watchdog. Loss of comms automatically freezes all servo joints.
    

## 📂 Repository Structure

```
📦 Manipulator-Subsystem
 ┣ 📂 CAD                 # SolidWorks/Fusion360 assemblies and STL files
 ┣ 📂 Electronics         # KiCAD/Altium schematics and PCB layout files
 ┣ 📂 Software            # ESP32/STM32 firmware (Kinematics, CAN, Safety)
 ┣ 📂 Perception          # Python vision scripts for QR/Color detection
 ┣ 📂 Docs                # VDI 2206 Documentation, FMEA, and Requirements
 ┗ 📜 README.md           # Project overview (This file)
```

## 📚 Documentation

Detailed engineering reports generated following the VDI 2206 methodology:

- [Requirements Analysis Document (`Docs/Requirements.pdf`)](https://www.google.com/search?q=./Docs/ "null")
    
- [System Architecture & FBD (`Docs/Architecture.md`)](https://www.google.com/search?q=./Docs/ "null")
    
- [FMEA Risk Assessment Report (`Docs/Risk_Assessment.pdf`)](https://www.google.com/search?q=./Docs/ "null")
    
- [Electromechanical Bill of Materials (BOM) (`Docs/BOM.pdf`)](https://www.google.com/search?q=./Docs/ "null")
    
- [Electrical & Electronics Architecture (`Docs/Electronics.pdf`)](https://www.google.com/search?q=./Docs/ "null")
    