--
--  MIT License
--
--  Copyright (c) 2026 ksiby
--
--  Permission is hereby granted, free of charge, to any person obtaining
--  a copy of this software and associated documentation files (the "Software"),
--  to deal in the Software without restriction, including without limitation
--  the rights to use, copy, modify, merge, publish, distribute, sublicense,
--  and/or sell copies of the Software, and to permit persons to whom
--  the Software is furnished to do so, subject to the following conditions:
--
--  The above copyright notice and this permission notice shall be included
--  in all copies or substantial portions of the Software.
--
--  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
--  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
--  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
--  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
--  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
--  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
--  OTHER DEALINGS IN THE SOFTWARE.
--
--  WeAct BlackPill STM32F411CEU6
--  GPIOC Pin13 --> LED
--  USART1 RX -->GPIOA Pin10
--  * Feeder controller
--  * LED on for 10 seconds at specified time (HH:MM)
--  * UART outputs prompts for time input and "Feeding..." during LED on
--  * HSI=16 MHz,APB2ENR = 16MHz
--  * Bps/Par/Bits : 115200/-/8N1
--  * Hardware Flow Control = No
--  * Software Flow Control = No
--  *
--
with HAL;
with HAL.Real_Time_Clock;  use HAL.Real_Time_Clock;
with STM32_SVD.RCC;   use STM32_SVD.RCC;
with STM32_SVD.GPIO;  use STM32_SVD.GPIO;
with STM32_SVD.USART; use STM32_SVD.USART;
with STM32_SVD.RTC;   use STM32_SVD.RTC;
with STM32_SVD.PWR;   use STM32_SVD.PWR;

procedure main is

   --  Simple delay loop (approximate, based on 16MHz clock)
   procedure Delay_Ms (Ms : Natural) is
      Counter : Natural;
   begin
      for M in 1 .. Ms loop
         Counter := 2000;  --  Approximate for 1ms at 16MHz (adjusted for accuracy)
         while Counter > 0 loop
            Counter := Counter - 1;
         end loop;
      end loop;
   end Delay_Ms;

   --  Send a character via USART1
   procedure USART1_Send_Char (C : Character) is
   begin
      --  Wait until TXE (Transmit Data Register Empty) is set
      loop
         exit when USART1_Periph.SR.TXE;
      end loop;
      --  Write character to DR
      USART1_Periph.DR.DR := HAL.UInt9 (Character'Pos (C));
   end USART1_Send_Char;

   --  Send a string via USART1
   procedure USART1_Send_String (S : String) is
   begin
      for I in S'Range loop
         USART1_Send_Char (S (I));
      end loop;
   end USART1_Send_String;

   procedure USART1_Init is
  --
  --  // Turn on GPIOA peripheral
  --  RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;
  --  // Turn on USART1 peripheral
  --  RCC->APB2ENR |= RCC_APB2ENR_USART1EN;
  --
  --  // GPIOA Pin10 AF
  --  GPIOA->MODER &= ~GPIO_MODER_MODE10;
  --  GPIOA->MODER |= GPIO_MODER_MODE10_1;
  --  // Set High Speed Pin10
  --  GPIOA->OSPEEDR |= GPIO_OSPEEDR_OSPEED10;
  --
  --  // AFRH AF7 Alternate function Mapping - page 47 datasheet
  --  GPIOA->AFR[1] &= ~GPIO_AFRH_AFSEL10;
  --  GPIOA->AFR[1]
  --    |= GPIO_AFRH_AFSEL10_0 | GPIO_AFRH_AFSEL10_1 | GPIO_AFRH_AFSEL10_2;
  --
  --  // OVER8=1, RX Enable
  --  USART1->CR1 |= USART_CR1_OVER8 | USART_CR1_RE;
  --
  --  // See RM0383 page 518-527
  --  // HSI=16MHz, FPCLK=16MHz, Baud rate = 115200 (Actual 115108), OVER8=1
  --  // (DIV_Fraction[2:0] bits) Tx/Rx baud = fCK/(8*(2-OVER8)*USARTDIV) 115200 =
  --  // 16000000/8*USARTDIV USARTDIV = 16000000/(8*115108)= 17.375 Mantisa = 17 If
  --  // OVER8=1, fraction * 8 Fraction = 8*0.375= 3
  --
  --  USART1->BRR &= ~USART_BRR_DIV_Mantissa;
  --  USART1->BRR |= (17 << USART_BRR_DIV_Mantissa_Pos);
  --  USART1->BRR &= ~USART_BRR_DIV_Fraction;
  --  USART1->BRR |= (3 << USART_BRR_DIV_Fraction_Pos);
  --
  --  // USART1 Enable
  --  USART1->CR1 |= USART_CR1_UE;
  --
   begin
--  	// Turn on GPIOA peripheral
--  	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;
      RCC_Periph.AHB1ENR.GPIOAEN := True;
--  	// Turn on USART1 peripheral
--  	RCC->APB2ENR |= RCC_APB2ENR_USART1EN;
      RCC_Periph.APB2ENR.USART1EN := True;
 --  	// GPIOA Pin9 AF Pin10 AF
--  	GPIOA->MODER &=~(GPIO_MODER_MODE9|GPIO_MODER_MODE10);
--  	GPIOA->MODER |=GPIO_MODER_MODE9_1|GPIO_MODER_MODE10_1;
      GPIOA_Periph.MODER.Arr(9)  := 0;
      GPIOA_Periph.MODER.Arr(10) := 0;
      GPIOA_Periph.MODER.Arr(9)  := 2#10#; -- 10: Alternate function mode
      GPIOA_Periph.MODER.Arr(10) := 2#10#; -- 10: Alternate function mode
--  	// Set High Speed for GPIOA Pin9 & 10
--  	GPIOA->OSPEEDR |=GPIO_OSPEEDR_OSPEED9|GPIO_OSPEEDR_OSPEED10;
      GPIOA_Periph.OSPEEDR.Arr(9) := 2#10#; -- 10: High speed
      GPIOA_Periph.OSPEEDR.Arr(9) := 2#10#; -- 10: High speed
--  	// AFRH AF7 Alternate function Mapping - page 47 datasheet
--  	GPIOA->AFR[1] &= ~(GPIO_AFRH_AFSEL9|GPIO_AFRH_AFSEL10);
--  	GPIOA->AFR[1]|=	GPIO_AFRH_AFSEL9_0|
--  					GPIO_AFRH_AFSEL9_1|
--  					GPIO_AFRH_AFSEL9_2|
--  					GPIO_AFRH_AFSEL10_0|
--  					GPIO_AFRH_AFSEL10_1|
--  					GPIO_AFRH_AFSEL10_2;
      GPIOA_Periph.AFRH.Arr(9)  := 0;
      GPIOA_Periph.AFRH.Arr(10) := 0;
      GPIOA_Periph.AFRH.Arr(9)  := 7;
      GPIOA_Periph.AFRH.Arr(10) := 7;
--  	// OVER8=1, TX & RX Enable
--  	USART1->CR1|= USART_CR1_OVER8|USART_CR1_TE|USART_CR1_RE;
      USART1_Periph.CR1.RE := True;
      USART1_Periph.CR1.TE := True;
      USART1_Periph.CR1.OVER8 := True;
--
--  	// See RM0383 page 518-527
--  	// HSI=16MHz, FPCLK=16MHz, Baud rate = 115200 (Actual 115108), OVER8=1 (DIV_Fraction[2:0] bits)
--  	// Tx/Rx baud = fCK/(8*(2-OVER8)*USARTDIV)
--  	// 115200 = 16000000/8*USARTDIV
--  	// USARTDIV = 16000000/(8*115108)= 17.375
--  	// Mantisa = 17
--  	// If OVER8=1, fraction * 8
--  	// Fraction = 8*0.375= 3
--
--  	USART1->BRR &=~USART_BRR_DIV_Mantissa;
--  	USART1->BRR|=(17 << USART_BRR_DIV_Mantissa_Pos);
--  	USART1->BRR &=~USART_BRR_DIV_Fraction;
--  	USART1->BRR|=(3 << USART_BRR_DIV_Fraction_Pos);
--
      USART1_Periph.BRR.DIV_Mantissa := 0;
      USART1_Periph.BRR.DIV_Mantissa := 17;
      USART1_Periph.BRR.DIV_Fraction := 3;
--  	// USART1 Enable
--  	USART1->CR1|= USART_CR1_UE;
      USART1_Periph.CR1.UE := True;
   end USART1_Init;

--  void
--  GPIOC_Init (void)
--  {
--    // Turn on the GPIOC peripheral
--    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOCEN;
--
--    // Set GPIOC Pin13 Output
--    GPIOC->MODER |= GPIO_MODER_MODE13_0;
--    GPIOC->MODER &= ~GPIO_MODER_MODE13_1;
--  }
   procedure GPIOC_Init is
   begin
      --  Turn on the GPIOC peripheral
      RCC_Periph.AHB1ENR.GPIOCEN := True;
      --  Set GPIOC Pin13 Output
      GPIOC_Periph.MODER.Arr(13) := 2#01#;
   end GPIOC_Init;


--  void
--  USART1_Rx_Data (void)
--  {
--    // Check RXNE flag
--    while (!(USART1->SR & USART_SR_RXNE))
--      {
--      }
--
--    // Turn On LED if Rx data < 0x35
--    if (USART1->DR < 0x35)
--      GPIOC->ODR &= ~GPIO_ODR_OD13;
--    else
--      GPIOC->ODR |= GPIO_ODR_OD13;
--    delay ();
--  }

   procedure USART1_Rx_Data is
      use HAL;
      Received_Char : Character;
      Digit_Count   : Natural := 0;
      Hour_Tens     : Natural := 0;
      Hour_Units    : Natural := 0;
      Min_Tens      : Natural := 0;
      Min_Units     : Natural := 0;
      Target_Hour   : RTC_Hour := 0;
      Target_Min    : RTC_Minute := 0;
   begin
      --  Prompt user for time input
      USART1_Send_String ("Enter feeding time (HH:MM): ");
      
      --  Read 4 digits for HH:MM format
      while Digit_Count < 4 loop
         --  Wait for character
         loop
            exit when USART1_Periph.SR.RXNE;
         end loop;
         
         Received_Char := Character'Val (HAL.UInt9 (USART1_Periph.DR.DR));
         
         --  Echo the character
         USART1_Send_Char (Received_Char);
         
         --  Validate and process digit
         if Received_Char >= '0' and then Received_Char <= '9' then
            case Digit_Count is
               when 0 =>
                  Hour_Tens := Character'Pos (Received_Char) - Character'Pos ('0');
               when 1 =>
                  Hour_Units := Character'Pos (Received_Char) - Character'Pos ('0');
               when 2 =>
                  Min_Tens := Character'Pos (Received_Char) - Character'Pos ('0');
               when 3 =>
                  Min_Units := Character'Pos (Received_Char) - Character'Pos ('0');
               when others =>
                  null;
            end case;
            Digit_Count := Digit_Count + 1;
         elsif Received_Char = ASCII.BS or else Received_Char = ASCII.DEL then
            --  Handle backspace
            if Digit_Count > 0 then
               Digit_Count := Digit_Count - 1;
               USART1_Send_String (ASCII.BS & " " & ASCII.BS);
            end if;
         end if;
      end loop;
      
      --  Calculate hour and minute
      Target_Hour := RTC_Hour (Hour_Tens * 10 + Hour_Units);
      Target_Min  := RTC_Minute (Min_Tens * 10 + Min_Units);
      
      --  Validate time
      if Target_Hour > 23 or else Target_Min > 59 then
         USART1_Send_String (ASCII.LF & ASCII.CR & "Invalid time! Using default 08:00");
         Target_Hour := 8;
         Target_Min  := 0;
      else
         USART1_Send_String (ASCII.LF & ASCII.CR & "Feeding time set to: ");
         if Target_Hour < 10 then
            USART1_Send_Char ('0');
         end if;
         USART1_Send_Char (Character'Val (Character'Pos ('0') + Natural (Target_Hour / 10)));
         USART1_Send_Char (Character'Val (Character'Pos ('0') + Natural (Target_Hour mod 10)));
         USART1_Send_Char (':');
         if Target_Min < 10 then
            USART1_Send_Char ('0');
         end if;
         USART1_Send_Char (Character'Val (Character'Pos ('0') + Natural (Target_Min / 10)));
         USART1_Send_Char (Character'Val (Character'Pos ('0') + Natural (Target_Min mod 10)));
      end if;
      
      USART1_Send_String (ASCII.LF & ASCII.CR);
      
      --  Initialize RTC with target alarm time
      RTC_Init;
      Set_Alarm (Target_Hour, Target_Min);
   end USART1_Rx_Data;

   --  Turn LED on (active low, so set to False)
   procedure LED_On is
   begin
      GPIOC_Periph.ODR.ODR.Arr(13) := False;
   end LED_On;

   --  Turn LED off (active low, so set to True)
   procedure LED_Off is
   begin
      GPIOC_Periph.ODR.ODR.Arr(13) := True;
   end LED_Off;

   --  Initialize RTC peripheral
   procedure RTC_Init is
   begin
      --  Enable PWR peripheral clock
      RCC_Periph.APB1ENR.PWREN := True;
      
      --  Disable write protection for RTC registers
      RTC_Periph.WPR.KEY := 16#CA#;
      RTC_Periph.WPR.KEY := 16#53#;
      
      --  Enter initialization mode
      loop
         exit when RTC_Periph.ISR.INITF;
      end loop;
      RTC_Periph.ISR.INIT := True;
      
      --  Wait for init flag
      loop
         exit when RTC_Periph.ISR.INITF;
      end loop;
      
      --  Set prescaler for 1Hz (assuming LSE = 32.768 kHz)
      RTC_Periph.PRER.PREDIV_A := 16#7F#;  -- 127
      RTC_Periph.PRER.PREDIV_S := 16#FF#;  -- 255
      
      --  Exit initialization mode
      RTC_Periph.ISR.INIT := False;
      
      --  Re-enable write protection
      RTC_Periph.WPR.KEY := 16#FF#;
   end RTC_Init;

   --  Set alarm time for feeding
   procedure Set_Alarm (Hour : RTC_Hour; Minute : RTC_Minute) is
      Hour_Tens  : HAL.UInt2;
      Hour_Units : HAL.UInt4;
      Min_Tens   : HAL.UInt3;
      Min_Units  : HAL.UInt4;
   begin
      --  Disable write protection
      RTC_Periph.WPR.KEY := 16#CA#;
      RTC_Periph.WPR.KEY := 16#53#;
      
      --  Disable Alarm A
      RTC_Periph.CR.ALRAE := False;
      
      --  Wait until ALRAWF is set
      loop
         exit when RTC_Periph.ISR.ALRAWF;
      end loop;
      
      --  Convert hour to BCD
      Hour_Tens  := HAL.UInt2 (Hour / 10);
      Hour_Units := HAL.UInt4 (Hour mod 10);
      
      --  Convert minute to BCD
      Min_Tens   := HAL.UInt3 (Minute / 10);
      Min_Units  := HAL.UInt4 (Minute mod 10);
      
      --  Set alarm time (mask seconds and date to match every day)
      RTC_Periph.ALRMAR.MSK1 := True;  -- Mask seconds
      RTC_Periph.ALRMAR.MSK4 := True;  -- Mask date/day
      
      RTC_Periph.ALRMAR.HT := Hour_Tens;
      RTC_Periph.ALRMAR.HU := Hour_Units;
      RTC_Periph.ALRMAR.MNT := Min_Tens;
      RTC_Periph.ALRMAR.MNU := Min_Units;
      
      --  Enable Alarm A
      RTC_Periph.CR.ALRAE := True;
      
      --  Clear any pending alarm flag
      RTC_Periph.ISR.ALRAF := False;
      
      --  Re-enable write protection
      RTC_Periph.WPR.KEY := 16#FF#;
   end Set_Alarm;

   --  Get current time from RTC
   function Get_Current_Time return RTC_Time is
      Time : RTC_Time;
      HT, HU, MNT, MNU : Natural;
   begin
      --  Wait for RSF (registers synchronized)
      loop
         exit when RTC_Periph.ISR.RSF;
      end loop;
      
      --  Read time register
      HT  := Natural (RTC_Periph.TR.HT);
      HU  := Natural (RTC_Periph.TR.HU);
      MNT := Natural (RTC_Periph.TR.MNT);
      MNU := Natural (RTC_Periph.TR.MNU);
      
      Time.Hour := RTC_Hour (HT * 10 + HU);
      Time.Min  := RTC_Minute (MNT * 10 + MNU);
      Time.Sec  := 0;  --  We don't need seconds for this application
      
      return Time;
   end Get_Current_Time;

   --  Check if alarm has triggered
   function Alarm_Triggered return Boolean is
   begin
      return RTC_Periph.ISR.ALRAF;
   end Alarm_Triggered;

   --  Clear alarm flag
   procedure Clear_Alarm_Flag is
   begin
      RTC_Periph.ISR.ALRAF := False;
   end Clear_Alarm_Flag;

begin
   --  Internal High Speed clock enable
   RCC_Periph.CR.HSION := True;
   loop
      exit when RCC_Periph.CR.HSIRDY;
   end loop;
   USART1_Init;
   GPIOC_Init;
   
   --  Prompt user for feeding time and initialize RTC
   USART1_Rx_Data;
   
   --  Main loop: Feeder controller
   --  Wait for alarm time and turn LED on for 10 seconds
   loop
      --  Wait for alarm to trigger
      loop
         exit when Alarm_Triggered;
      end loop;
      
      --  Clear alarm flag
      Clear_Alarm_Flag;
      
      --  Feeding phase: LED on for 10 seconds
      LED_On;
      USART1_Send_String ("Feeding...");
      USART1_Send_String (ASCII.LF & ASCII.CR);
      Delay_Ms (10000);  --  10 seconds
      
      --  Turn LED off after feeding
      LED_Off;
      USART1_Send_String ("Idle...");
      USART1_Send_String (ASCII.LF & ASCII.CR);
   end loop;
end main;
