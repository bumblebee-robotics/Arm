Here is the exact equivalent of your original tutorial code, completely rewritten to use the modern, built-in TWAI driver. 

I have set the baud rate back to **500 kbps** (`TWAI_TIMING_CONFIG_500KBITS()`) to match your original setup, and the sender will alternate between sending the standard 11-bit "hello" and the extended 29-bit "world" packets just like the old library did.

### 1. TWAI Receiver Code

```cpp
#include "driver/twai.h"

#define TX_GPIO_NUM 5
#define RX_GPIO_NUM 4

void setup() {
  Serial.begin(115200);
  while (!Serial);
  delay(1000);

  Serial.println("TWAI Receiver");

  // Initialize configuration structures
  twai_general_config_t g_config = TWAI_GENERAL_CONFIG_DEFAULT((gpio_num_t)TX_GPIO_NUM, (gpio_num_t)RX_GPIO_NUM, TWAI_MODE_NORMAL);
  twai_timing_config_t t_config = TWAI_TIMING_CONFIG_500KBITS(); // 500 kbps
  twai_filter_config_t f_config = TWAI_FILTER_CONFIG_ACCEPT_ALL();

  // Install TWAI driver
  if (twai_driver_install(&g_config, &t_config, &f_config) == ESP_OK) {
    Serial.println("Driver installed");
  } else {
    Serial.println("Failed to install driver");
    while(1);
  }

  // Start TWAI driver
  if (twai_start() == ESP_OK) {
    Serial.println("Driver started");
  } else {
    Serial.println("Failed to start driver");
    while(1);
  }
}

void loop() {
  twai_message_t message;

  // Wait for message (blocks for up to 1000 ticks)
  if (twai_receive(&message, pdMS_TO_TICKS(1000)) == ESP_OK) {
    Serial.print("Received ");

    if (message.extd) {
      Serial.print("extended ");
    }

    if (message.rtr) {
      Serial.print("RTR ");
    }

    Serial.print("packet with id 0x");
    Serial.print(message.identifier, HEX);

    if (message.rtr) {
      Serial.print(" and requested length ");
      Serial.println(message.data_length_code);
    } else {
      Serial.print(" and length ");
      Serial.println(message.data_length_code);

      // only print packet data for non-RTR packets
      for (int i = 0; i < message.data_length_code; i++) {
        Serial.print((char)message.data[i]);
      }
      Serial.println();
    }
    Serial.println();
  }
}
```


## TWAI Sender Code
```cpp
#include "driver/twai.h"

#define TX_GPIO_NUM 5
#define RX_GPIO_NUM 4

void setup() {
  Serial.begin(115200);
  while (!Serial);
  delay(1000);

  Serial.println("TWAI Sender");

  twai_general_config_t g_config = TWAI_GENERAL_CONFIG_DEFAULT((gpio_num_t)TX_GPIO_NUM, (gpio_num_t)RX_GPIO_NUM, TWAI_MODE_NORMAL);
  twai_timing_config_t t_config = TWAI_TIMING_CONFIG_500KBITS(); // 500 kbps
  twai_filter_config_t f_config = TWAI_FILTER_CONFIG_ACCEPT_ALL();

  if (twai_driver_install(&g_config, &t_config, &f_config) == ESP_OK) {
    Serial.println("Driver installed");
  } else {
    Serial.println("Failed to install driver");
    while(1);
  }

  if (twai_start() == ESP_OK) {
    Serial.println("Driver started");
  } else {
    Serial.println("Failed to start driver");
    while(1);
  }
}

void loop() {
  twai_message_t message;

  // ----------------------------------------------------
  // Send Standard Packet
  // ----------------------------------------------------
  Serial.print("Sending packet ... ");
  
  message.identifier = 0x12;
  message.extd = 0; // Standard 11-bit ID
  message.rtr = 0;
  message.data_length_code = 5;
  message.data[0] = 'h';
  message.data[1] = 'e';
  message.data[2] = 'l';
  message.data[3] = 'l';
  message.data[4] = 'o';

  if (twai_transmit(&message, pdMS_TO_TICKS(1000)) == ESP_OK) {
    Serial.println("done");
  } else {
    Serial.println("failed");
  }

  delay(1000);

  // ----------------------------------------------------
  // Send Extended Packet
  // ----------------------------------------------------
  Serial.print("Sending extended packet ... ");
  
  message.identifier = 0xabcdef;
  message.extd = 1; // Extended 29-bit ID
  message.rtr = 0;
  message.data_length_code = 5;
  message.data[0] = 'w';
  message.data[1] = 'o';
  message.data[2] = 'r';
  message.data[3] = 'l';
  message.data[4] = 'd';

  if (twai_transmit(&message, pdMS_TO_TICKS(1000)) == ESP_OK) {
    Serial.println("done");
  } else {
    Serial.println("failed");
  }

  delay(1000);
}
```

I get that the sender is sending but I don't get anything at the receiver side.