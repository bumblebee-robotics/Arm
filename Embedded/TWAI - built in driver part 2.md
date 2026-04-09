
```cpp
/**
 * ESP32-S3 CAN (TWAI) send + receive
 * Pins:
 *   ESP32-S3 GPIO12 -> Transceiver TXD
 *   ESP32-S3 GPIO13 <- Transceiver RXD
 * Baud: 500 kbit/s (change if needed)
 *
 * Note: You still need a CAN transceiver (e.g., SN65HVD230/TJA1050).
 * Make sure the bus is terminated with 120 Ω at both ends.
 */

#include "driver/twai.h"

static const gpio_num_t CAN_TX = GPIO_NUM_5; // controller TX -> transceiver TXD
static const gpio_num_t CAN_RX = GPIO_NUM_4; // controller RX <- transceiver RXD

// 500 kbit/s. Use TWAI_TIMING_CONFIG_250KBITS(), etc., if your bus differs.
static const twai_timing_config_t t_config = TWAI_TIMING_CONFIG_500KBITS();
static const twai_filter_config_t f_config = TWAI_FILTER_CONFIG_ACCEPT_ALL();

void setup() {
  Serial.begin(115200);
  delay(200);

  // Normal bus mode (use TWAI_MODE_NO_ACK for single-node bench tests)
  twai_general_config_t g_config =
      TWAI_GENERAL_CONFIG_DEFAULT(CAN_TX, CAN_RX, TWAI_MODE_NORMAL);

  if (twai_driver_install(&g_config, &t_config, &f_config) != ESP_OK) {
    Serial.println("TWAI install failed");
    while (true) { delay(1000); }
  }
  if (twai_start() != ESP_OK) {
    Serial.println("TWAI start failed");
    while (true) { delay(1000); }
  }

  // Optional: auto bus-off recovery
  twai_reconfigure_alerts(TWAI_ALERT_BUS_OFF | TWAI_ALERT_RECOVERY_IN_PROGRESS, nullptr);

  Serial.println("CAN started @ 500 kbit/s. TX every 1s. Listening...");
}

void loop() {
  static uint32_t counter = 0;
  static uint32_t last_tx = 0;
  const uint32_t now = millis();

  // ---- transmit every 1s ----
  if (now - last_tx >= 1000) {
    last_tx = now;

    twai_message_t tx = {};
    tx.identifier = 0xABC;            // 11-bit ID
    tx.extd = 0;                      // standard frame
    tx.rtr = 0;                       // data frame
    tx.data_length_code = 8;
    tx.data[0] = (uint8_t)(counter & 0xFF);
    tx.data[1] = (uint8_t)((counter >> 8) & 0xFF);
    tx.data[2] = (uint8_t)((counter >> 16) & 0xFF);
    tx.data[3] = (uint8_t)((counter >> 24) & 0xFF);
    tx.data[4] = 'S';
    tx.data[5] = '3';
    tx.data[6] = 'C';
    tx.data[7] = 'A';

    esp_err_t res = twai_transmit(&tx, pdMS_TO_TICKS(100));
    if (res == ESP_OK) {
      Serial.printf("TX ID=0x%03X DLC=%d counter=%lu\n",
                    tx.identifier, tx.data_length_code, (unsigned long)counter);
      counter++;
    } else {
      Serial.printf("TX failed (err=%d)\n", (int)res);
    }
  }

  // ---- non-blocking receive ----
  twai_message_t rx;
  if (twai_receive(&rx, 0) == ESP_OK) {
    Serial.print("RX ");
    if (rx.extd) {
      Serial.printf("EXT ID=0x%08lX ", (unsigned long)rx.identifier);
    } else {
      Serial.printf("STD ID=0x%03lX ", (unsigned long)rx.identifier);
    }
    Serial.printf("DLC=%d ", rx.data_length_code);
    if (rx.rtr) {
      Serial.print("RTR\n");
    } else {
      Serial.print("DATA=");
      for (int i = 0; i < rx.data_length_code; ++i) {
        Serial.printf("%02X ", rx.data[i]);
      }
      Serial.println();
    }
  }

  delay(2); // small yield
}
```

When I run it, I get this output on both esp32:
CAN started @ 500 kbit/s. TX every 1s. Listening...
TX ID=0xABC DLC=8 counter=0
TX ID=0xABC DLC=8 counter=1
TX ID=0xABC DLC=8 counter=2
TX ID=0xABC DLC=8 counter=3
TX ID=0xABC DLC=8 counter=4
TX ID=0xABC DLC=8 counter=5
TX failed (err=263)
TX failed (err=263)
TX failed (err=263)
TX failed (err=263)
and so on

> [!note] Note
> I think that [[TWAI - built-in driver|TWAI - built-in driver]] just silently crashed without showing errors

