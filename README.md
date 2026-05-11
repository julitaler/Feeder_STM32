# practic_les2_ada_usart1_rx

--  WeAct BlackPill STM32F411CEU6
--  GPIOC Pin13 --> LED
--  USART1 RX -->GPIOA Pin10
--  * If ASCII char Rx < 5, Turn On LED
--  * Minicom : press 3, LED On. Press 9, LED Off
--  * HSI=16 MHz,APB2ENR = 16MHz
--  * Bps/Par/Bits : 115200/-/8N1
--  * Hardware Flow Control = No
--  * Software Flow Control = No
--  *
--