> [!tip] The module
> I highly suspect my tranceiver module. I used the `CAN.h` library and when I opened the serial I found nothing. I connected the GPIO4 to GPIO5 pin on the sender esp and starting seeing sending and done.

*Loopback test*
```
CAN Sender

Sending packet ... done

Sending extended packet ... done

Sending packet ... done

Sending extended packet ... done

Sending packet ... done

Sending extended packet ... done

Sending packet ... done

Sending extended packet ... done

Sending packet ... done

Sending extended packet ... done

Sending packet ... done

Sending extended packet ... done

Sending packet ... done

Sending extended packet ... done

Sending packet ... done
```

> [!tip] The chip
> I looked carefully on my board and found it is actually using this chip: `SIT65HVD230`

> [!note] I tried lowering the baud rate still no luck.

> [!note] I added the SEL jumper cap and looked on the pcb and found that the RS pin is grounded. Still no luck.


We could do a multimeter test:

| **Pins to Measure** | **Expected Voltage (Recessive/Idle)** | **What it means if it's different**                                              |
| ------------------- | ------------------------------------- | -------------------------------------------------------------------------------- |
| **CANH to GND**     | **~1.6V to 2.3V**                     | If 0V, the chip isn't powered or is dead.                                        |
| **CANL to GND**     | **~1.6V to 2.3V**                     | Should be nearly identical to CANH.                                              |
| **CANH to CANL**    | **0V**                                | If you see 2V+ here while idle, the transceiver is stuck in "Dominant" (broken). |