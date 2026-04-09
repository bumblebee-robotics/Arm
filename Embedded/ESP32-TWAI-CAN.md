I followed the sketch in the documentation:

```cpp
// Example sketch for the ESP32-TWAI-CAN library driver,
// showing how to query OBD2 over TWAI / CAN for coolant temperature.

#include <ESP32-TWAI-CAN.hpp>

// Default for ESP32
#define CAN_TX 5
#define CAN_RX 4

CanFrame rxFrame;

void sendObdFrame(uint8_t obdId) {
    CanFrame obdFrame         = {0};
    obdFrame.identifier       = 0x7DF; // Default OBD2 address;
    obdFrame.extd             = 0;
    obdFrame.data_length_code = 8;
    obdFrame.data[0]          = 2;
    obdFrame.data[1]          = 1;
    obdFrame.data[2]          = obdId;
    obdFrame.data[3]          = 0xAA; // Best use 0xAA (0b10101010) instead of 0
    obdFrame.data[4]          = 0xAA; // TWAI / CAN works better this way, as it
    obdFrame.data[5]          = 0xAA; // needs to avoid bit-stuffing
    obdFrame.data[6]          = 0xAA;
    obdFrame.data[7]          = 0xAA;
    // Accepts both pointers and references
    ESP32Can.writeFrame(obdFrame); // timeout defaults to 1 ms
}

void setup() {
    // Setup serial for debbuging.
    Serial.begin(115200);

    // Set pins
    ESP32Can.setPins(CAN_TX, CAN_RX);

    // You can set custom size for the queues - those are default
    ESP32Can.setRxQueueSize(5);
    ESP32Can.setTxQueueSize(5);

    // .setSpeed() and .begin() functions require to use TwaiSpeed enum,
    // but you can easily convert it from numerical value using .convertSpeed()
    ESP32Can.setSpeed(ESP32Can.convertSpeed(500));

    // You can also just use .begin()..
    if(ESP32Can.begin()) {
        Serial.println("CAN bus started!");
    } else {
        Serial.println("CAN bus failed!");
    }

    // or override everything in one command;
    // It is also safe to use .begin() without .end() as it calls it internally
    if(ESP32Can.begin(ESP32Can.convertSpeed(500), CAN_TX, CAN_RX, 10, 10)) {
        Serial.println("CAN bus started!");
    } else {
        Serial.println("CAN bus failed!");
    }
}

void loop() {
    static uint32_t lastStamp    = 0;
    uint32_t        currentStamp = millis();

    if(currentStamp - lastStamp > 1000) { // sends OBD2 request every second
        lastStamp = currentStamp;
        sendObdFrame(5); // For coolant temperature
    }

    // You can set custom timeout, default is 1000
    if(ESP32Can.readFrame(rxFrame, 1000)) {
        // Comment out if too many frames
        Serial.printf("Received frame: %03X  \r\n", rxFrame.identifier);
        if(rxFrame.identifier == 0x7E8) {                                    // Standard OBD2 frame responce ID
            Serial.printf("Collant temp: %3d°C \r\n", rxFrame.data[3] - 40); // Convert to °C
        }
    }
}
```

I get nothing in the serial. Only "Can bus started!" at the beginning then nothing 

***Some hassle***
When I tried to add some logging messages using AI:
`I just want you to modify the original sketch to show number messages sent, number of messages received, status, RX errors, and TX errors`
It gave me code with errors because it was using an old API version of the library. I tried manually updated the code according to the header file in the library. It threw errors as well. This was because the release of the library was actually older than the one in the repository. I downloaded the new one and manually added it to the library 

*Loopback with diagnostics*
```cpp
#include <ESP32-TWAI-CAN.hpp>

  

#define CAN_TX 5

#define CAN_RX 4

  

CanFrame rxFrame;

uint32_t gSentCount = 0;

uint32_t gReceivedCount = 0;

  

void setup() {

    Serial.begin(115200);

    while(!Serial);

    Serial.println("--- TWAI Two-Node Diagnostic Link ---");

  

    // NORMAL MODE: Requires a second node to ACK the message

    twai_general_config_t g_config = TWAI_GENERAL_CONFIG_DEFAULT(

        (gpio_num_t)CAN_TX,

        (gpio_num_t)CAN_RX,

        TWAI_MODE_NORMAL

    );

  

    if(ESP32Can.begin(ESP32Can.convertSpeed(125), CAN_TX, CAN_RX, 10, 10, nullptr, &g_config)) {

        Serial.println("CAN Online (Normal Mode)");

    } else {

        Serial.println("CAN Init Failed!");

    }

}

  

void loop() {

    static uint32_t lastTx = 0;

    // --- SENDER LOGIC (Board 1) ---

    // If you want one board to be 'silent', just comment this block out on that board

    if(millis() - lastTx > 1000) {

        lastTx = millis();

        CanFrame txFrame = {0};

        txFrame.identifier = 0x100; // Example ID

        txFrame.data_length_code = 4;

        txFrame.data[0] = 0x11; txFrame.data[1] = 0x22;

  

        if(ESP32Can.writeFrame(txFrame)) {

            gSentCount++;

        }

        // --- PRINT DIAGNOSTICS ---

        twai_status_info_t status;

        if (twai_get_status_info(&status) == ESP_OK) {

            Serial.printf("[TX: %u | RX: %u] State: %d | TX Err: %u | RX Err: %u\n",

                          gSentCount, gReceivedCount, status.state,

                          status.tx_error_counter, status.rx_error_counter);

            if(status.state == 4) Serial.println("!!! BUS OFF - Check Wires !!!");

        }

    }

  

    // --- RECEIVER LOGIC ---

    if(ESP32Can.readFrame(rxFrame, 0)) {

        gReceivedCount++;

        Serial.printf("Received Frame! ID: %03X\n", rxFrame.identifier);

    }

}
```

*Two node with diagnostics*
```cpp
#include <ESP32-TWAI-CAN.hpp>

#define CAN_TX 5
#define CAN_RX 4

CanFrame rxFrame;
uint32_t gSentCount = 0;
uint32_t gReceivedCount = 0;

void setup() {
    Serial.begin(115200);
    while(!Serial);
    Serial.println("--- TWAI Two-Node Diagnostic Link ---");

    // NORMAL MODE: Requires a second node to ACK the message
    twai_general_config_t g_config = TWAI_GENERAL_CONFIG_DEFAULT(
        (gpio_num_t)CAN_TX, 
        (gpio_num_t)CAN_RX, 
        TWAI_MODE_NORMAL 
    );

    if(ESP32Can.begin(ESP32Can.convertSpeed(500), CAN_TX, CAN_RX, 10, 10, nullptr, &g_config)) {
        Serial.println("CAN Online (Normal Mode)");
    } else {
        Serial.println("CAN Init Failed!");
    }
}

void loop() {
    static uint32_t lastTx = 0;
    
    // --- SENDER LOGIC (Board 1) ---
    // If you want one board to be 'silent', just comment this block out on that board
    if(millis() - lastTx > 1000) {
        lastTx = millis();
        CanFrame txFrame = {0};
        txFrame.identifier = 0x100; // Example ID
        txFrame.data_length_code = 4;
        txFrame.data[0] = 0x11; txFrame.data[1] = 0x22;

        if(ESP32Can.writeFrame(txFrame)) {
            gSentCount++;
        }
        
        // --- PRINT DIAGNOSTICS ---
        twai_status_info_t status;
        if (twai_get_status_info(&status) == ESP_OK) {
            Serial.printf("[TX: %u | RX: %u] State: %d | TX Err: %u | RX Err: %u\n", 
                          gSentCount, gReceivedCount, status.state, 
                          status.tx_error_counter, status.rx_error_counter);
            
            if(status.state == 4) Serial.println("!!! BUS OFF - Check Wires !!!");
        }
    }

    // --- RECEIVER LOGIC ---
    if(ESP32Can.readFrame(rxFrame, 0)) {
        gReceivedCount++;
        Serial.printf("Received Frame! ID: %03X\n", rxFrame.identifier);
    }
}
```

***Result***
Weirdly, one ESP (this was also what I got with the loopback test):
```
--- TWAI Two-Node Diagnostic Link ---

CAN Online (Normal Mode)

[TX: 1 | RX: 0] State: 1 | TX Err: 0 | RX Err: 0

[TX: 2 | RX: 0] State: 1 | TX Err: 0 | RX Err: 0

[TX: 3 | RX: 0] State: 1 | TX Err: 0 | RX Err: 0

[TX: 4 | RX: 0] State: 1 | TX Err: 0 | RX Err: 0

[TX: 5 | RX: 0] State: 1 | TX Err: 0 | RX Err: 0

[TX: 6 | RX: 0] State: 1 | TX Err: 0 | RX Err: 0

[TX: 6 | RX: 0] State: 1 | TX Err: 0 | RX Err: 0

[TX: 6 | RX: 0] State: 1 | TX Err: 0 | RX Err: 0

[TX: 6 | RX: 0] State: 1 | TX Err: 0 | RX Err: 0

[TX: 6 | RX: 0] State: 1 | TX Err: 0 | RX Err: 0

[TX: 6 | RX: 0] State: 1 | TX Err: 0 | RX Err: 0

[TX: 6 | RX: 0] State: 1 | TX Err: 0 | RX Err: 0

[TX: 6 | RX: 0] State: 1 | TX Err: 0 | RX Err: 0

[TX: 6 | RX: 0] State: 1 | TX Err: 0 | RX Err: 0

[TX: 6 | RX: 0] State: 1 | TX Err: 0 | RX Err: 0

[TX: 6 | RX: 0] State: 1 | TX Err: 0 | RX Err: 0
```

and the other esp:
```
--- TWAI Two-Node Diagnostic Link ---

CAN Online (Normal Mode)

[TX: 1 | RX: 0] State: 1 | TX Err: 0 | RX Err: 0

[TX: 2 | RX: 0] State: 1 | TX Err: 128 | RX Err: 0

[TX: 3 | RX: 0] State: 1 | TX Err: 128 | RX Err: 0

[TX: 4 | RX: 0] State: 1 | TX Err: 128 | RX Err: 0

[TX: 5 | RX: 0] State: 1 | TX Err: 128 | RX Err: 0

[TX: 6 | RX: 0] State: 1 | TX Err: 128 | RX Err: 0

[TX: 6 | RX: 0] State: 1 | TX Err: 128 | RX Err: 0
```

