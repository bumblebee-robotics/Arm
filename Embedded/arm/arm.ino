#include <ESP32Servo.h>

// 1. THE PACKAGE
struct ArmState {
  int base;
  int shoulder;
  int elbow;
  int gripper;
};

// 2. THE HARDWARE
Servo sBase;
Servo sShoulder;
Servo sElbow;
Servo sGripper;

void setup() {
  Serial.begin(115200);

  // Attach servos to ESP32 Super Mini pins
  sBase.attach(2);
  sShoulder.attach(3);
  sElbow.attach(4);
  sGripper.attach(5);

  Serial.println("Send 4 angles separated by commas. Example: 90,90,90,45");
}

// 3. THE ACTION (Moves the arm safely)
void moveArm(ArmState target) {
  int safeBase     = constrain(target.base, 0, 180);
  int safeShoulder = constrain(target.shoulder, 20, 160);
  int safeElbow    = constrain(target.elbow, 0, 180);
  int safeGripper  = constrain(target.gripper, 10, 80);

  sBase.write(safeBase);
  sShoulder.write(safeShoulder);
  sElbow.write(safeElbow);
  sGripper.write(safeGripper);
}

// ==========================================
// NEW: THE SERIAL LISTENER (Simulates ROS)
// ==========================================
bool getSerialState(ArmState &incomingState) {
  // If there is data waiting in the serial buffer...
  if (Serial.available() > 0) {
    
    // Read the next 4 integers it finds
    incomingState.base     = Serial.parseInt();
    incomingState.shoulder = Serial.parseInt();
    incomingState.elbow    = Serial.parseInt();
    incomingState.gripper  = Serial.parseInt();
    
    // Clear out any leftover characters (like the "Enter" key)
    while(Serial.available() > 0) {
      Serial.read();
    }
    
    return true; // We successfully got new data
  }
  
  return false; // No new data available
}

// 4. THE LOOP
void loop() {
  ArmState targetData;

  // Check if we got a new command. 
  // If getSerialState is true, it means targetData is now full of new numbers.
  if (getSerialState(targetData)) {
    
    Serial.println("Command received! Moving arm...");
    moveArm(targetData);
    
  }
}