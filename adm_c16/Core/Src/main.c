/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2022 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "string.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include "asm_func.h"
#include "stdint.h"
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */
#define LIM_12BITS 4095
#define WINDOW_SIZE 11
#define HALF_WINDOW 5
#define MASK_16_MSB_BITS 0xFFFF0000

#define ECO_VECTOR_LENGTH 4096
#define ECO_SAMPLE_DELAY 882

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

ETH_TxPacketConfig TxConfig;
ETH_DMADescTypeDef  DMARxDscrTab[ETH_RX_DESC_CNT]; /* Ethernet Rx DMA Descriptors */
ETH_DMADescTypeDef  DMATxDscrTab[ETH_TX_DESC_CNT]; /* Ethernet Tx DMA Descriptors */

ETH_HandleTypeDef heth;

UART_HandleTypeDef huart3;

PCD_HandleTypeDef hpcd_USB_OTG_FS;

/* USER CODE BEGIN PV */

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
static void MX_ETH_Init(void);
static void MX_USART3_UART_Init(void);
static void MX_USB_OTG_FS_PCD_Init(void);
/* USER CODE BEGIN PFP */

void zeros (uint32_t* vector, uint32_t longitud);
void productoEscalar32 (uint32_t * vectorIn, uint32_t * vectorOut, uint32_t longitud, uint32_t escalar);
void productoEscalar16 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar);
void productoEscalar12 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar);
void filtroVentana10(uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitudVectorIn);
void pack32to16 (int32_t * vectorIn, int16_t *vectorOut, uint32_t longitud);
int32_t max (int32_t * vectorIn, uint32_t longitud);
void downsampleM (int32_t * vectorIn, int32_t * vectorOut, uint32_t longitud, uint32_t N);
void invertir (uint16_t * vector, uint32_t longitud);
void addEcoVector(int16_t* vector,uint16_t longitud, uint16_t sampleDelay);
void corr (int16_t *vectorX, int16_t * vectorY, int16_t* vectorCorr, uint32_t longitud);

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */
static void PrivilegiosSVC (void)
{
    // Obtiene valor del registro de 32 bits del procesador llamado "control".
    // El registro guarda los siguientes estados:
    // bit 2: Uso de FPU en el contexto actual. Usado=1, no usado=0.
    // bit 1: Mapeo del stack pointer(sp). MSP=0, PSP=1.
    // bit 0: Modo de ejecucion en Thread. Privilegiado=0, No privilegiado=1.
    //        Recordar que este valor solo se usa en modo Thread. Las
    //        interrupciones siempre se ejecutan en modo Handler con total
    //        privilegio.
    uint32_t x = __get_CONTROL ();

    // Actividad de debug: Ver registro "control" y valor de variable "x".
    //__BKPT (0);

    x |= 1;
    // bit 0 a modo No privilegiado.
    __set_CONTROL (x);

    // En este punto se estaria ejecutando en modo No privilegiado.
    // Lectura del registro "control" para confirmar.
    x = __get_CONTROL ();

    // Actividad de debug: Ver registro "control" y valor de variable "x".
    //__BKPT (0);

    x &= ~1u;
    // Se intenta volver a modo Privilegiado (bit 0, valor 0).
    __set_CONTROL (x);

    // Confirma que esta operacion es ignorada por estar ejecutandose en modo
    // Thread no privilegiado.
    x = __get_CONTROL ();

    // Actividad de debug: Ver registro "control" y valor de variable "x".
    //__BKPT (0);

    // En este punto, ejecutando en modo Thread no privilegiado, la unica forma
    // de volver a modo privilegiado o de realizar cualquier cambio que requiera
    // modo privilegiado, es pidiendo ese servicio a un hipotetico sistema
    // opertivo de tiempo real.
    // Para esto se invoca por software a la interrupcion SVC (Supervisor Call)
    // utilizando la instruccion "svc".
    // No hay intrinsics para realizar esta tarea. Para utilizar la instruccion
    // es necesario implementar una funcion en assembler. Ver el archivo
    // asm_func.S.
    asm_svc ();

    // El sistema operativo (el handler de SVC) deberia haber devuelto el modo
    // de ejecucion de Thread a privilegiado (bit 0 en valor 0).
    x = __get_CONTROL ();

    // Fin del ejemplo de SVC
}
/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{
  /* USER CODE BEGIN 1 */

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  DWT->CTRL |= 1 << DWT_CTRL_CYCCNTENA_Pos;

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_ETH_Init();
  MX_USART3_UART_Init();
  MX_USB_OTG_FS_PCD_Init();
  /* USER CODE BEGIN 2 */
  PrivilegiosSVC ();

  const uint32_t Resultado = asm_sum (5, 3);

  //Verificación de funciones en C

  uint32_t vectorZeros_C[5]={0xFF,0xFF,0xFF,0xFF,0xFF};
  zeros (vectorZeros_C,5);

  uint32_t vectorProdEsc32In_C[5]={0x1111,0x2222,0x4444,0x8888,0xFFFF};
  uint32_t vectorProdEsc32Out_C[5];
  productoEscalar32 (vectorProdEsc32In_C, vectorProdEsc32Out_C, 5, 0xF);

  uint16_t vectorProdEsc16In_C[5]={0x11,0x22,0x444,0x888,0xFFF};
  uint16_t vectorProdEsc16Out_C[5];
  productoEscalar16 (vectorProdEsc16In_C, vectorProdEsc16Out_C, 5, 0xF);

  uint16_t vectorProdEsc12In_C[5]={0x11,0x22,0x444,0x888,0xFFF};
  uint16_t vectorProdEsc12Out_C[5];
  productoEscalar12 (vectorProdEsc12In_C, vectorProdEsc12Out_C, 5, 0xF);

  uint16_t vectorVentanaIn_C[15]={
		  10,10,10,10,10,
		  10,10,10,10,10,
		  10,10,10,10,10
  };
  uint16_t vectorVentanaOut_C[15];
  filtroVentana10(vectorVentanaIn_C, vectorVentanaOut_C,15);

  int32_t vectorPack32In_C[5]={0x1111,0x22222,0x444444,0x8888888,0x800FFFFF};
  int16_t vectorPack32Out_C[5];
  pack32to16 (vectorPack32In_C,vectorPack32Out_C, 5);

  int32_t vectorMax_C[5]={1,10,-20,-5,5};
  int32_t maxValueIndex_C = max (vectorMax_C, 5);

  int32_t vectorDownSampleIn_C[30]={
		  0,1,2,3,4,5,6,7,8,9,
		  10,11,12,13,14,15,16,17,18,19,
		  20,21,22,23,24,25,26,27,28,29
  };
  int32_t vectorDownSampleOut_C[24];
  downsampleM (vectorDownSampleIn_C, vectorDownSampleOut_C, 30, 5);

  uint16_t vectorInv_C[6]={0,10,20,30,40,50};
  invertir (vectorInv_C, 6);

  int16_t ecoVectorSamples_C[ECO_VECTOR_LENGTH];

  //La idea de asignar así el vector es para utilizar el rango negativo
  for(int i=-ECO_VECTOR_LENGTH/2 ; i< (ECO_VECTOR_LENGTH/2) ; i++){
	  ecoVectorSamples_C[ECO_VECTOR_LENGTH/2+i]=i;
  }

  DWT->CYCCNT = 0;
  addEcoVector(ecoVectorSamples_C,ECO_VECTOR_LENGTH,ECO_SAMPLE_DELAY);
  const volatile uint32_t CiclosEco_C = DWT->CYCCNT;

  int16_t vectorX_C[20] = {
		  0,2,4,6,8,
		  10,12,14,16,18,
		  20,22,24,26,28,
		  30,32,34,36,38
  };

  int16_t vectorY_C[20] = {
  		  0,2,4,6,8,
  		  10,12,14,16,18,
  		  20,22,24,26,28,
  		  30,32,34,36,38
    };

  int16_t vectorCorr_C[20];

  DWT->CYCCNT = 0;
  corr(vectorX_C,vectorY_C,vectorCorr_C,20);
  const volatile uint32_t CiclosCorr_C = DWT->CYCCNT;


  //Verificación de funciones en ASM

  uint32_t vectorZeros_ASM[5]={0xFF,0xFF,0xFF,0xFF,0xFF};
  asm_zeros(vectorZeros_ASM,5);

  uint32_t vectorProdEsc32In_ASM[5]={0x1111,0x2222,0x4444,0x8888,0xFFFF};
  uint32_t vectorProdEsc32Out_ASM[5];
  asm_productoEscalar32 (vectorProdEsc32In_ASM, vectorProdEsc32Out_ASM, 5, 0xF);

  uint16_t vectorProdEsc16In_ASM[5]={0x11,0x22,0x444,0x888,0xFFF};
  uint16_t vectorProdEsc16Out_ASM[5];
  asm_productoEscalar16 (vectorProdEsc16In_ASM, vectorProdEsc16Out_ASM, 5, 0xF);

  uint16_t vectorProdEsc12In_ASM[5]={0x11,0x22,0x444,0x888,0xFFF};
  uint16_t vectorProdEsc12Out_ASM[5];
  asm_productoEscalar12 (vectorProdEsc12In_ASM, vectorProdEsc12Out_ASM, 5, 0xF);

  uint16_t vectorVentanaIn_ASM[15]={
		  10,10,10,10,10,
		  10,10,10,10,10,
		  10,10,10,10,10
  };
  uint16_t vectorVentanaOut_ASM[15];
  asm_filtroVentana10(vectorVentanaIn_ASM, vectorVentanaOut_ASM,15);

  int32_t vectorPack32In_ASM[5]={0x1111,0x22222,0x444444,0x8888888,0x800FFFFF};
  int16_t vectorPack32Out_ASM[5];
  asm_pack32to16 (vectorPack32In_ASM,vectorPack32Out_ASM, 5);

  int32_t vectorMax_ASM[5]={1,10,-20,-5,5};
  int32_t maxValueIndex_ASM = asm_max (vectorMax_ASM, 5);

  int32_t vectorDownSampleIn_ASM[30]={
		  0,1,2,3,4,5,6,7,8,9,
		  10,11,12,13,14,15,16,17,18,19,
		  20,21,22,23,24,25,26,27,28,29
  };
  int32_t vectorDownSampleOut_ASM[24];
  asm_downsampleM (vectorDownSampleIn_ASM, vectorDownSampleOut_ASM, 30, 5);

  uint16_t vectorInv_ASM[6]={0,10,20,30,40,50};
  asm_invertir (vectorInv_ASM, 6);

  int16_t ecoVectorSamples_ASM[ECO_VECTOR_LENGTH];

  //La idea de asignar así el vector es para utilizar el rango negativo
  for(int i=-ECO_VECTOR_LENGTH/2 ; i< (ECO_VECTOR_LENGTH/2) ; i++){
	  ecoVectorSamples_ASM[ECO_VECTOR_LENGTH/2+i]=i;
  }

  DWT->CYCCNT = 0;
  asm_addEcoVector(ecoVectorSamples_ASM,ECO_VECTOR_LENGTH,ECO_SAMPLE_DELAY);
  const volatile uint32_t CiclosEco_ASM = DWT->CYCCNT;

  int16_t ecoVectorSamples_ASM_SIMD[ECO_VECTOR_LENGTH];

  for(int i=-ECO_VECTOR_LENGTH/2 ; i< (ECO_VECTOR_LENGTH/2) ; i++){
	  ecoVectorSamples_ASM_SIMD[ECO_VECTOR_LENGTH/2+i]=i;
  }

  DWT->CYCCNT = 0;
  asm_simd_addEcoVector(ecoVectorSamples_ASM_SIMD,ECO_VECTOR_LENGTH,ECO_SAMPLE_DELAY);
  const volatile uint32_t CiclosEco_ASM_SIMD = DWT->CYCCNT;

  int16_t vectorX_ASM[20] = {
		  0,2,4,6,8,
		  10,12,14,16,18,
		  20,22,24,26,28,
		  30,32,34,36,38
  };

  int16_t vectorY_ASM[20] = {
  		  0,2,4,6,8,
  		  10,12,14,16,18,
  		  20,22,24,26,28,
  		  30,32,34,36,38
    };

  int16_t vectorCorr_ASM[20];

  DWT->CYCCNT = 0;
  asm_corr(vectorX_ASM,vectorY_ASM,vectorCorr_ASM,20);
  const volatile uint32_t CiclosCorr_ASM = DWT->CYCCNT;

  int16_t vectorX_ASM_SIMD[20] = {
		  0,2,4,6,8,
		  10,12,14,16,18,
		  20,22,24,26,28,
		  30,32,34,36,38
  };

  int16_t vectorY_ASM_SIMD[20] = {
  		  0,2,4,6,8,
  		  10,12,14,16,18,
  		  20,22,24,26,28,
  		  30,32,34,36,38
    };

  int16_t vectorCorr_ASM_SIMD[20];

  DWT->CYCCNT = 0;
  asm_simd_corr(vectorX_ASM,vectorY_ASM,vectorCorr_ASM_SIMD,20);
  const volatile uint32_t CiclosCorr_ASM_SIMD = DWT->CYCCNT;

  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
  }
  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Configure the main internal regulator output voltage
  */
  __HAL_RCC_PWR_CLK_ENABLE();
  __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1);

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_BYPASS;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
  RCC_OscInitStruct.PLL.PLLM = 4;
  RCC_OscInitStruct.PLL.PLLN = 168;
  RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
  RCC_OscInitStruct.PLL.PLLQ = 7;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV4;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV2;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_5) != HAL_OK)
  {
    Error_Handler();
  }
}

/**
  * @brief ETH Initialization Function
  * @param None
  * @retval None
  */
static void MX_ETH_Init(void)
{

  /* USER CODE BEGIN ETH_Init 0 */

  /* USER CODE END ETH_Init 0 */

   static uint8_t MACAddr[6];

  /* USER CODE BEGIN ETH_Init 1 */

  /* USER CODE END ETH_Init 1 */
  heth.Instance = ETH;
  MACAddr[0] = 0x00;
  MACAddr[1] = 0x80;
  MACAddr[2] = 0xE1;
  MACAddr[3] = 0x00;
  MACAddr[4] = 0x00;
  MACAddr[5] = 0x00;
  heth.Init.MACAddr = &MACAddr[0];
  heth.Init.MediaInterface = HAL_ETH_RMII_MODE;
  heth.Init.TxDesc = DMATxDscrTab;
  heth.Init.RxDesc = DMARxDscrTab;
  heth.Init.RxBuffLen = 1524;

  /* USER CODE BEGIN MACADDRESS */

  /* USER CODE END MACADDRESS */

  if (HAL_ETH_Init(&heth) != HAL_OK)
  {
    Error_Handler();
  }

  memset(&TxConfig, 0 , sizeof(ETH_TxPacketConfig));
  TxConfig.Attributes = ETH_TX_PACKETS_FEATURES_CSUM | ETH_TX_PACKETS_FEATURES_CRCPAD;
  TxConfig.ChecksumCtrl = ETH_CHECKSUM_IPHDR_PAYLOAD_INSERT_PHDR_CALC;
  TxConfig.CRCPadCtrl = ETH_CRC_PAD_INSERT;
  /* USER CODE BEGIN ETH_Init 2 */

  /* USER CODE END ETH_Init 2 */

}

/**
  * @brief USART3 Initialization Function
  * @param None
  * @retval None
  */
static void MX_USART3_UART_Init(void)
{

  /* USER CODE BEGIN USART3_Init 0 */

  /* USER CODE END USART3_Init 0 */

  /* USER CODE BEGIN USART3_Init 1 */

  /* USER CODE END USART3_Init 1 */
  huart3.Instance = USART3;
  huart3.Init.BaudRate = 115200;
  huart3.Init.WordLength = UART_WORDLENGTH_8B;
  huart3.Init.StopBits = UART_STOPBITS_1;
  huart3.Init.Parity = UART_PARITY_NONE;
  huart3.Init.Mode = UART_MODE_TX_RX;
  huart3.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  huart3.Init.OverSampling = UART_OVERSAMPLING_16;
  if (HAL_UART_Init(&huart3) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN USART3_Init 2 */

  /* USER CODE END USART3_Init 2 */

}

/**
  * @brief USB_OTG_FS Initialization Function
  * @param None
  * @retval None
  */
static void MX_USB_OTG_FS_PCD_Init(void)
{

  /* USER CODE BEGIN USB_OTG_FS_Init 0 */

  /* USER CODE END USB_OTG_FS_Init 0 */

  /* USER CODE BEGIN USB_OTG_FS_Init 1 */

  /* USER CODE END USB_OTG_FS_Init 1 */
  hpcd_USB_OTG_FS.Instance = USB_OTG_FS;
  hpcd_USB_OTG_FS.Init.dev_endpoints = 4;
  hpcd_USB_OTG_FS.Init.speed = PCD_SPEED_FULL;
  hpcd_USB_OTG_FS.Init.dma_enable = DISABLE;
  hpcd_USB_OTG_FS.Init.phy_itface = PCD_PHY_EMBEDDED;
  hpcd_USB_OTG_FS.Init.Sof_enable = ENABLE;
  hpcd_USB_OTG_FS.Init.low_power_enable = DISABLE;
  hpcd_USB_OTG_FS.Init.lpm_enable = DISABLE;
  hpcd_USB_OTG_FS.Init.vbus_sensing_enable = ENABLE;
  hpcd_USB_OTG_FS.Init.use_dedicated_ep1 = DISABLE;
  if (HAL_PCD_Init(&hpcd_USB_OTG_FS) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN USB_OTG_FS_Init 2 */

  /* USER CODE END USB_OTG_FS_Init 2 */

}

/**
  * @brief GPIO Initialization Function
  * @param None
  * @retval None
  */
static void MX_GPIO_Init(void)
{
  GPIO_InitTypeDef GPIO_InitStruct = {0};

  /* GPIO Ports Clock Enable */
  __HAL_RCC_GPIOC_CLK_ENABLE();
  __HAL_RCC_GPIOH_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();
  __HAL_RCC_GPIOB_CLK_ENABLE();
  __HAL_RCC_GPIOD_CLK_ENABLE();
  __HAL_RCC_GPIOG_CLK_ENABLE();

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOB, LD1_Pin|LD3_Pin|LD2_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(USB_PowerSwitchOn_GPIO_Port, USB_PowerSwitchOn_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pin : USER_Btn_Pin */
  GPIO_InitStruct.Pin = USER_Btn_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_IT_RISING;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(USER_Btn_GPIO_Port, &GPIO_InitStruct);

  /*Configure GPIO pins : LD1_Pin LD3_Pin LD2_Pin */
  GPIO_InitStruct.Pin = LD1_Pin|LD3_Pin|LD2_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  /*Configure GPIO pin : USB_PowerSwitchOn_Pin */
  GPIO_InitStruct.Pin = USB_PowerSwitchOn_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(USB_PowerSwitchOn_GPIO_Port, &GPIO_InitStruct);

  /*Configure GPIO pin : USB_OverCurrent_Pin */
  GPIO_InitStruct.Pin = USB_OverCurrent_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(USB_OverCurrent_GPIO_Port, &GPIO_InitStruct);

}

/* USER CODE BEGIN 4 */

void zeros (uint32_t* vector, uint32_t longitud){
	for(;longitud;longitud--){
		vector[longitud-1]=0;
	}
}

void productoEscalar32 (uint32_t * vectorIn, uint32_t * vectorOut, uint32_t longitud, uint32_t escalar){
	for(;longitud;longitud--){
		vectorOut[longitud-1]=escalar*vectorIn[longitud-1];
	}
}

void productoEscalar16 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar){
	for(;longitud;longitud--){
		vectorOut[longitud-1]=escalar*vectorIn[longitud-1];
	}
}

void productoEscalar12 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar){
	for(;longitud;longitud--){
		vectorOut[longitud-1] = escalar*vectorIn[longitud-1];

		if(vectorOut[longitud-1]>LIM_12BITS){
			vectorOut[longitud-1]=LIM_12BITS;
		}
	}
}

void filtroVentana10(uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitudVectorIn){
	for(int i=0;i<longitudVectorIn;i++){
		uint32_t temp=0;
		int windowStart=0;
		int windowEnd=i+HALF_WINDOW+1;

		if(i>HALF_WINDOW)
			windowStart = i-HALF_WINDOW;

		if(windowEnd>longitudVectorIn)
			windowEnd = longitudVectorIn;

		for(int j=windowStart;j<windowEnd;j++){
			temp+=vectorIn[j];
		}

		vectorOut[i]=(uint16_t) (temp/WINDOW_SIZE);

	}
}

void pack32to16 (int32_t * vectorIn, int16_t *vectorOut, uint32_t longitud){
	for(;longitud;longitud--){
		vectorOut[longitud-1]=(int16_t) ((vectorIn[longitud-1]&MASK_16_MSB_BITS)>>16); //usar shift con signo en asm
	}
}

int32_t max (int32_t * vectorIn, uint32_t longitud){

	int32_t maxValue = vectorIn[longitud-1];
	int32_t maxIndex = longitud-1;
	longitud--;

	for(;longitud;longitud--){

		if(vectorIn[longitud-1]>maxValue){
			maxValue = vectorIn[longitud-1];
			maxIndex = longitud-1;
		}
	}

	return maxIndex;
}

void downsampleM (int32_t * vectorIn, int32_t * vectorOut, uint32_t longitud, uint32_t N){

	int sampleCounter=0;
	int currentInSample=0;
	int currentOutSample=0;

	do{
		if(sampleCounter==N-1){
			sampleCounter=0;
			currentInSample++;	//saltea muestra de entrada actual
		}

		vectorOut[currentOutSample]=vectorIn[currentInSample];
		sampleCounter++;
		currentInSample++;
		currentOutSample++;

	}while(currentInSample<longitud);
}

void invertir (uint16_t * vector, uint32_t longitud){
	uint16_t temp=0;

	uint32_t flipTimes = longitud;

	flipTimes &= ~0x1;
	flipTimes = flipTimes>>1;		//Divido longitud en 2 para hacer un flip entre los valores del vector

	do{
		temp = vector[flipTimes-1];
		vector[flipTimes-1]=vector[longitud-flipTimes];
		vector[longitud-flipTimes] =temp;
		flipTimes--;

	}while(flipTimes);

}

void addEcoVector(int16_t* vector,uint16_t longitud, uint16_t sampleDelay){

	for(int i=sampleDelay ; i<longitud ;i++){
		vector[i] = vector[i-sampleDelay]/2 + vector[i];
	}
}

void corr (int16_t *vectorX, int16_t *vectorY, int16_t *vectorCorr, uint32_t longitud){

	int16_t acc=0;

	for(int l=0;l<longitud;l++){

		for(int n=l;n<longitud;n++){
			acc+=vectorX[n]*vectorY[n];
		}

		vectorCorr[l]=acc;
		acc=0;

	}
}
/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}

#ifdef  USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
