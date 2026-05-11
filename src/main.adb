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
--  * If ASCII char Rx < 5, Turn On LED
--  * Minicom : press 3, LED On. Press 9, LED Off
--  * HSI=16 MHz,APB2ENR = 16MHz
--  * Bps/Par/Bits : 115200/-/8N1
--  * Hardware Flow Control = No
--  * Software Flow Control = No
--  *
--
with HAL;
with STM32_SVD.RCC;   use STM32_SVD.RCC;
with STM32_SVD.GPIO;  use STM32_SVD.GPIO;
with STM32_SVD.USART; use STM32_SVD.USART;

procedure main is

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
   begin
      --  Этот бит устанавливается аппаратно,
      --  когда содержимое сдвигового регистра RDR передано в регистр USART_DR.
      --  Прерывание генерируется, если RXNEIE=1 в регистре USART_CR1.
      --  Оно сбрасывается при чтении в регистр USART_DR.
      --  Флаг RXNE также можно сбросить, записав в него ноль.
      --  Эта последовательность сброса рекомендуется только
      --  для многобуферной связи.
      --
      --  0: Данные не получены
      --  1: Полученные данные готовы к чтению.
      --  Check RXNE flag
      loop
         exit when USART1_Periph.SR.RXNE ;
      end loop;
      --  Turn On LED if Rx data < 0x35
      if USART1_Periph.DR.DR < UInt9(16#35#)
      then
         GPIOC_Periph.ODR.ODR.Arr(13) := False;
      else
         GPIOC_Periph.ODR.ODR.Arr(13) := True;
      end if;
      null;
      null;
   end USART1_Rx_Data;

begin
   --  Internal High Speed clock enable
   RCC_Periph.CR.HSION := True;
   loop
      exit when RCC_Periph.CR.HSIRDY;
   end loop;
   USART1_Init;
   GPIOC_Init;
   --
   loop
      USART1_Rx_Data;
      null;
   end loop;
end main;
