
Trying loopback demo

> [!note] Loopback
> Connecting GPIO4 and GPIO5 on the same ESP just to check the library without hardware issues


```cpp
//----------------------------------------------------------------------------------------
//  Board Check
//----------------------------------------------------------------------------------------

#ifndef ARDUINO_ARCH_ESP32
  #error "Select an ESP32 board"
#endif

//----------------------------------------------------------------------------------------
//   Include files
//----------------------------------------------------------------------------------------

#include <ACAN_ESP32.h>
#include <esp_chip_info.h>
#include <esp_flash.h>
#include <core_version.h> // For ARDUINO_ESP32_RELEASE

//----------------------------------------------------------------------------------------
//  ESP32 Desired Bit Rate
//----------------------------------------------------------------------------------------

static const uint32_t DESIRED_BIT_RATE = 1000UL * 1000UL ; // 1 Mb/s

//----------------------------------------------------------------------------------------
//   SETUP
//----------------------------------------------------------------------------------------

void setup () {
//--- Switch on builtin led
  pinMode (LED_BUILTIN, OUTPUT) ;
  digitalWrite (LED_BUILTIN, HIGH) ;
//--- Start serial
  Serial.begin (115200) ;
  delay (100) ;
//--- Display ESP32 Chip Info
  esp_chip_info_t chip_info ;
  esp_chip_info (&chip_info) ;
  Serial.print ("ESP32 Arduino Release: ") ;
  Serial.println (ARDUINO_ESP32_RELEASE) ;
  Serial.print ("ESP32 Chip Revision: ") ;
  Serial.println (chip_info.revision) ;
  Serial.print ("ESP32 SDK: ") ;
  Serial.println (ESP.getSdkVersion ()) ;
  Serial.print ("ESP32 Flash: ") ;
  uint32_t size_flash_chip ;
  esp_flash_get_size (NULL, &size_flash_chip) ;
  Serial.print (size_flash_chip / (1024 * 1024)) ;
  Serial.print (" MB ") ;
  Serial.println (((chip_info.features & CHIP_FEATURE_EMB_FLASH) != 0) ? "(embeded)" : "(external)") ;
  Serial.print ("APB CLOCK: ") ;
  Serial.print (APB_CLK_FREQ) ;
  Serial.println (" Hz") ;
//--- Configure ESP32 CAN
  Serial.println ("Configure ESP32 CAN") ;
  ACAN_ESP32_Settings settings (DESIRED_BIT_RATE) ;
  settings.mRequestedCANMode = ACAN_ESP32_Settings::LoopBackMode ;
//  settings.mRxPin = GPIO_NUM_4 ; // Optional, default Tx pin is GPIO_NUM_4
//  settings.mTxPin = GPIO_NUM_5 ; // Optional, default Rx pin is GPIO_NUM_5
  const uint32_t errorCode = ACAN_ESP32::can.begin (settings) ;
  if (errorCode == 0) {
    Serial.print ("Bit Rate prescaler: ") ;
    Serial.println (settings.mBitRatePrescaler) ;
    Serial.print ("Time Segment 1:     ") ;
    Serial.println (settings.mTimeSegment1) ;
    Serial.print ("Time Segment 2:     ") ;
    Serial.println (settings.mTimeSegment2) ;
    Serial.print ("RJW:                ") ;
    Serial.println (settings.mRJW) ;
    Serial.print ("Triple Sampling:    ") ;
    Serial.println (settings.mTripleSampling ? "yes" : "no") ;
    Serial.print ("Actual bit rate:    ") ;
    Serial.print (settings.actualBitRate ()) ;
    Serial.println (" bit/s") ;
    Serial.print ("Exact bit rate ?    ") ;
    Serial.println (settings.exactBitRate () ? "yes" : "no") ;
    Serial.print ("Distance            ") ;
    Serial.print (settings.ppmFromDesiredBitRate ()) ;
    Serial.println (" ppm") ;
    Serial.print ("Sample point:       ") ;
    Serial.print (settings.samplePointFromBitStart ()) ;
    Serial.println ("%") ;
    Serial.println ("Configuration OK!");
  }else {
    Serial.print ("Configuration error 0x") ;
    Serial.println (errorCode, HEX) ;
  }
}

//----------------------------------------------------------------------------------------

static uint32_t gBlinkLedDate = 0 ;
static uint32_t gReceivedFrameCount = 0 ;
static uint32_t gSentFrameCount = 0 ;

//----------------------------------------------------------------------------------------
//   LOOP
//----------------------------------------------------------------------------------------

void loop () {
  CANMessage frame ;
  if (gBlinkLedDate < millis ()) {
    gBlinkLedDate += 500 ;
    digitalWrite (LED_BUILTIN, !digitalRead (LED_BUILTIN)) ;
    Serial.print ("Sent: ") ;
    Serial.print (gSentFrameCount) ;
    Serial.print (" ") ;
    Serial.print ("Receive: ") ;
    Serial.print (gReceivedFrameCount) ;
    Serial.print (" ") ;
    Serial.print (" STATUS 0x") ;
  //--- Note: TWAI register access from 3.0.0 should name the can channel
  //   < 3.0.0 :  TWAI_STATUS_REG
  //  >= 3.0.0 :  ACAN_ESP32::can.TWAI_STATUS_REG ()
    Serial.print (ACAN_ESP32::can.TWAI_STATUS_REG (), HEX) ;
    Serial.print (" RXERR ") ;
    Serial.print (ACAN_ESP32::can.TWAI_RX_ERR_CNT_REG ()) ;
    Serial.print (" TXERR ") ;
    Serial.println (ACAN_ESP32::can.TWAI_TX_ERR_CNT_REG ()) ;
    const bool ok = ACAN_ESP32::can.tryToSend (frame) ;
    if (ok) {
      gSentFrameCount += 1 ;
    }
  }
  while (ACAN_ESP32::can.receive (frame)) {
    gReceivedFrameCount += 1 ;
  }
}

//----------------------------------------------------------------------------------------
```

***Result***:
I tested the loopback without the tranceiver and it works well. When I connect the tranceiver, I get the error. If I connect the RX to GPIO4 and TX to GPIO5, I get RX errors. If I switch, I get TX errors

*Loopback test*
```
ESP32 Arduino Release: 3_0_3

ESP32 Chip Revision: 301

ESP32 SDK: v5.1.4-497-gdc859c1e67-dirty

ESP32 Flash: 4 MB (external)

APB CLOCK: 80000000 Hz

Configure ESP32 CAN

Bit Rate prescaler: 2

Time Segment 1:     13

Time Segment 2:     6

RJW:                4

Triple Sampling:    no

Actual bit rate:    1000000 bit/s

Exact bit rate ?    yes

Distance            0 ppm

Sample point:       70%

Configuration OK!

Sent: 0 Receive: 0  STATUS 0xC RXERR 0 TXERR 0

Sent: 1 Receive: 1  STATUS 0xC RXERR 0 TXERR 0

Sent: 2 Receive: 2  STATUS 0xC RXERR 0 TXERR 0

Sent: 3 Receive: 3  STATUS 0xC RXERR 0 TXERR 0

Sent: 4 Receive: 4  STATUS 0xC RXERR 0 TXERR 0

Sent: 5 Receive: 5  STATUS 0xC RXERR 0 TXERR 0

Sent: 6 Receive: 6  STATUS 0xC RXERR 0 TXERR 0

Sent: 7 Receive: 7  STATUS 0xC RXERR 0 TXERR 0

Sent: 8 Receive: 8  STATUS 0xC RXERR 0 TXERR 0

Sent: 9 Receive: 9  STATUS 0xC RXERR 0 TXERR 0

Sent: 10 Receive: 10  STATUS 0xC RXERR 0 TXERR 0

Sent: 11 Receive: 11  STATUS 0xC RXERR 0 TXERR 0

Sent: 12 Receive: 12  STATUS 0xC RXERR 0 TXERR 0

Sent: 13 Receive: 13  STATUS 0xC RXERR 0 TXERR 0

Sent: 14 Receive: 14  STATUS 0xC RXERR 0 TXERR 0

Sent: 15 Receive: 15  STATUS 0xC RXERR 0 TXERR 0

Sent: 16 Receive: 16  STATUS 0xC RXERR 0 TXERR 0
```

> [!success] No sketch is available for testing two nodes. Might want to check this

> [!note] Note
> There was an error in the header file (esprissif change their header file variables a lot. I just replaced the type with a normal int, following this [issue](https://github.com/pierremolinaro/acan-esp32/issues/21) because I could not find the updated type)
