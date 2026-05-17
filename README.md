# Feeder Controller for WeAct BlackPill STM32F411CEU6

A bare-metal embedded application written in Ada that implements a simple automatic pet feeder controller using the WeAct BlackPill board with STM32F411CEU6 microcontroller.

## Features

- **RTC-based scheduling**: LED turns on for 10 seconds at a specified time (HH:MM)
- **UART communication**: Outputs prompts for time input and "Feeding..." status messages
- **GPIO control**: Controls GPIOC Pin13 for LED indication
- **Real-time Clock**: Uses internal RTC for timekeeping

## Hardware Requirements

- **Board**: WeAct BlackPill STM32F411CEU6
- **LED**: Connected to GPIOC Pin13 (built-in LED on BlackPill)
- **UART**: 
  - RX: GPIOA Pin10
  - TX: GPIOA Pin9
- **Serial settings**: 115200 baud, 8N1, no flow control

## Technical Specifications

- **Clock**: HSI = 16 MHz
- **APB2**: 16 MHz
- **UART Configuration**:
  - Baud rate: 115200
  - Data bits: 8
  - Parity: None
  - Stop bits: 1
  - Hardware flow control: No
  - Software flow control: No

## Project Structure

```
├── src/
│   ├── main.adb              # Main application logic
│   ├── crt0.S                # C runtime startup code
│   ├── link.ld               # Linker script for STM32F4
│   ├── hal/                  # Hardware Abstraction Layer
│   │   ├── hal.ads
│   │   ├── hal-gpio.ads
│   │   ├── hal-uart.ads
│   │   ├── hal-real_time_clock.ads
│   │   └── ...
│   └── stm32f40x/            # STM32F4 peripheral definitions (SVD)
│       ├── stm32_svd.ads
│       ├── stm32_svd-rcc.ads
│       ├── stm32_svd-gpio.ads
│       ├── stm32_svd-usart.ads
│       ├── stm32_svd-rtc.ads
│       └── ...
├── default.gpr               # GNAT project file
├── LICENSE                   # MIT License
└── README.md                 # This file
```

## Build Instructions

### Prerequisites

- GNAT Community or GNAT Pro for ARM Embedded
- `arm-eabi` toolchain
- `gprbuild` (GNAT Project Builder)

### Building

```bash
gprbuild -P default.gpr
```

This will compile the project and produce an ELF binary in the `obj/` directory.

### Flashing

The project is configured to use `st-util` (ST-Link Utility) for programming via GDB remote protocol.

Using OpenOCD:
```bash
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg -c "program obj/main.elf verify reset exit"
```

Using st-util:
```bash
st-util
# In another terminal
arm-eabi-gdb obj/main.elf
(gdb) target extended-remote :4242
(gdb) load
(gdb) continue
```

## Usage

1. Flash the firmware to your BlackPill board
2. Connect to the UART via USB-to-serial adapter (115200 baud)
3. The program will prompt you to enter the feeding time (HH:MM format)
4. When the scheduled time arrives, the LED will turn on for 10 seconds
5. "Feeding..." message will be displayed during the feeding period

## License

MIT License - see [LICENSE](LICENSE) file for details.

Copyright (c) 2026 ksiby

## References

- [STM32F411 Reference Manual (RM0383)](https://www.st.com/resource/en/reference_manual/rm0383-stm32f411xce-advanced-armbased-32bit-mcus-stmicroelectronics.pdf)
- [STM32F411 Datasheet](https://www.st.com/resource/en/datasheet/stm32f411ce.pdf)
- [WeAct BlackPill Wiki](https://github.com/WeActStudio/WeActStudio.MiniSTM32F411)
