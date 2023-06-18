.syntax unified
.thumb
.text

@ Simbolos exportados
.global asm_svc
.global asm_sum
.global asm_zeros
.global asm_productoEscalar32
.global asm_productoEscalar16
.global asm_productoEscalar12
.global asm_filtroVentana10
.global asm_pack32to16
.global asm_max
.global asm_downsampleM
.global asm_invertir
.global asm_addEcoVector
.global asm_simd_addEcoVector
.global asm_corr
.global asm_simd_corr

.equ WINDOW_SIZE, 11
.equ HALF_WINDOW, 5

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_svc (void)
@
.thumb_func
    asm_svc:
        svc 0
        bx lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   uint32_t asmSum (uint32_t firstOperand, uint32_t secondOperand)
@
@ Parametros recibidos:
@   r0: firstOperand
@   r1: secondOperand
@
@ Valor de retorno:
@   r0: resultado de la suma de firstOperand y secondOperand
@
.thumb_func
    asm_sum:
        add r0, r1  @ r0 = r0 + r1
        bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                    @ es la direccion, en el codigo del programa, de la
                    @ instruccion "bl asm_sum" usada para saltar a
                    @ esta funcion, entonces "lr" contiene ese "pc" + 4).
                    @ el valor de retorno debe quedar en el registro r0.
                    @ En este caso, r0 es el resultado de r0 + r1.

        @ Otras alternativas para el retorno
        @ mov pc,lr
        @ bx lr
        @ push {lr} ... pop {pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_zeros (uint32_t* vector, uint32_t longitud);
@
@ Parametros recibidos:
@   r0: dirección del vector
@   r1: longitud
@
@ Valor de retorno: ---

.thumb_func
    asm_zeros:
    	mov r2,#0
     _for_zeros:
    	str r2, [r0],#4		@pone el contenido de r2 en *r1 y aumenta en 4 r0 por ser de 32 bits
		subs r1,#1			@resta 1 a r1 que se corresponde con longitud y actualiza flags
		bne _for_zeros		@vuele al for si longitud no llega a cero

        bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                    @ es la direccion, en el codigo del programa

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_productoEscalar32 (uint32_t * vectorIn, uint32_t * vectorOut, uint32_t longitud, uint32_t escalar);
@
@ Parametros recibidos:
@   r0: dirección del vector de entrada
@   r1: dirección del vector de salida
@   r2: longitud
@   r3: escalar a multiplicar
@
@ Valor de retorno: ---

.thumb_func
    asm_productoEscalar32:
    push {r4}
     _for_prodEsc32:

     	ldr r4,[r0],#4		@carga el contenido de vectorIn en r4 y aumenta la dirección de r0 en 4 bytes
     	mul r4,r4,r3		@r4=r4*r3, r3 es el escalar
    	str r4, [r1],#4		@pone el contenido de r4 en *r1 y aumenta en 4 r0 por ser de 32 bits

		subs r2,#1
		bne _for_prodEsc32		@vuele al for si longitud no llega a cero

	pop {r4}
    bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                @ es la direccion, en el codigo del programa

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_productoEscalar16 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar);

@ Parametros recibidos:
@   r0: dirección del vector de entrada
@   r1: dirección del vector de salida
@   r2: longitud
@   r3: escalar a multiplicar
@
@ Valor de retorno: ---

.thumb_func
    asm_productoEscalar16:
    push {r4}
     _for_prodEsc16:

     	ldrh r4,[r0],#2		@carga el contenido de vectorIn en r4 (media palabra)y aumenta la dirección de r0 en 2 bytes
     	mul r4,r4,r3		@r4=r4*r3, r3 es el escalar
    	strh r4, [r1],#2		@pone el contenido de r4 en *r1 y aumenta en 2 r0 por ser de 16 bits

		subs r2,#1
		bne _for_prodEsc16		@vuele al for si longitud no llega a cero

	pop {r4}
    bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                @ es la direccion, en el codigo del programa

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_productoEscalar12 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar);

@ Parametros recibidos:
@   r0: dirección del vector de entrada
@   r1: dirección del vector de salida
@   r2: longitud
@   r3: escalar a multiplicar
@
@ Valor de retorno: ---

.thumb_func
    asm_productoEscalar12:
    push {r4}
     _for_prodEsc12:

     	ldrh r4,[r0],#2		@carga el contenido de vectorIn en r4 (media palabra)y aumenta la dirección de r0 en 2 bytes
     	mul r4,r4,r3		@r4=r4*r3, r3 es el escalar
     	usat r4,#12,r4		@saturo el valor de r4 en 12 bits y lo vuelvo a almacenar en r4
    	strh r4, [r1],#2		@pone el contenido de r4 en *r1 y aumenta en 2 r0 por ser de 16 bits

		subs r2,#1
		bne _for_prodEsc12		@vuele al for si longitud no llega a cero

	pop {r4}
    bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                @ es la direccion, en el codigo del programa

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_filtroVentana10(uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitudVectorIn);

@ Parametros recibidos:
@   r0: dirección del vector de entrada
@   r1: dirección del vector de salida
@   r2: longitud
@
@ Valor de retorno: ---

.thumb_func
    asm_filtroVentana10:
    push {r4-r9}
    mov r3,#0				@analogo a lo utilizado como i
     _for_filtroVentana:

		mov r4,#0					@analogo a lo utilizado como temp
    	mov r5,#0					@analogo a lo utilizado como windowStart
    	add r6,r3,HALF_WINDOW		@analogo a lo utilizado como windowEnd r6 = r3 + HALF_WINDOW
    	add r6,#1					@para una correcta delimitación

    	cmp r3,HALF_WINDOW
    	bls _i_less_halfWindow		@si es menor o igual salta y no ejecuta la asignación a continuación
    	sub r5,r3,HALF_WINDOW		@reemplaza a windowStart = i-HALF_WINDOW;

    	_i_less_halfWindow:

    	cmp r6,r2
    	bls _window_end_less_long	@si es menor o igual salta (lower same unsigned)
    	mov r6,r2					@ analogo a windowEnd = longitudVectorIn;

    	_window_end_less_long:		@salta asignación
    	mov r7,r5;					@j=windowStart

    	_for_j_temp:

    	ldrh r8,[r0,r7,LSL 1]		@ carga el contenido de la dirección r0 agregando como offset el valor de r7 con un shift
    								@ en una posición (multiplicado por 2) por ser elementos de 16 bits
    	add r4,r8					@temp += vectorIn[i]
    	add r7,#1					@j++;
    	cmp r7,r6
    	blt _for_j_temp				@si j<=windowEnd vuelve a ejecutar el for (solo es less than porque se incrementó antes)


		mov r9,#0					@a esta altura ya se tiene el resultado final sin dividir en r4
		div_loop:
    	subs r4,r4,#WINDOW_SIZE
    	bmi _end_div_loop			@si el resultado de la resta es negativo termina el loop
    	add r9,#1					@agrega 1 al resultado si la resta es positiva
    								@ es una manera iterativa extremadamente lenta
    	b div_loop


		_end_div_loop:

    	strh r9,[r1],#2				@almaceno el valor de 16 bits en vector out y aumento 2 bytes su direccion

		add r3,#1					@i++
		cmp r3,r2
		blt _for_filtroVentana		@si j<=windowEnd vuelve a ejecutar el for (solo less than  por lo mismo que lo anterior)


	pop {r4-r9}
    bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                @ es la direccion, en el codigo del programa


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_pack32to16 (int32_t * vectorIn, int16_t *vectorOut, uint32_t longitud);

@ Parametros recibidos:
@   r0: dirección del vector de entrada
@   r1: dirección del vector de salida
@   r2: longitud
@
@ Valor de retorno: ---

.thumb_func
    asm_pack32to16:
     _for_pack:

     ldr r3,[r0],4		@obtengo el valor de vectIn
     lsr r3,16			@shift 16 bits a la derecha para ontener los mas significativos
     strh r3,[r1],2	@se guarda solamente media palabra
     subs r2,#1			@se disminuye en 1 longitud para controlar el ciclo
     bne _for_pack		@si es igual a cero hay que salir del lazo


    bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                @ es la direccion, en el codigo del programa

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   int32_t asm_max (int32_t * vectorIn, uint32_t longitud);

@ Parametros recibidos:
@   r0: dirección del vector de entrada
@   r1: longitud
@
@ Valor de retorno: r0 indice de valor máximo

.thumb_func
    asm_max:

    push {r4}

	sub r1,#1				@para usarlo directamente como indice

	ldr r2,[r0,r1,lsl 2]	@cargo lo que está en la ultima posición y lo multiplico por 4 por ser 4 bytes
							@r2 se va a usar para mantener el valor máximo

	mov r3,r1				@r3 se va a usar para guardar el indice del valor máximo

     _for_max:

	 subs r1,#1
	 bmi end_max_loop			@si el resultado es negativo significa que ya se recorrio el array completo

     ldr r4,[r0,r1,lsl 2]		@obtengo el valor de vectIn
     cmp r4,r2
     blt _not_greater			@en caso de que r4 no sea mayor se salta la parte de asignación

     mov r2,r4					@asigno nuevo cvalor maximo
     mov r3,r1					@asigno nuevo indice

	_not_greater:
     b _for_max					@si es igual a cero hay que salir del lazo

     end_max_loop:

     mov r0,r3			@asigno a r0 el valor de retorno (indice del mayor)

     pop {r4}


    bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                @ es la direccion, en el codigo del programa

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   asm_downsampleM (int32_t * vectorIn, int32_t * vectorOut, uint32_t longitud, uint32_t N);

@ Parametros recibidos:
@   r0: dirección del vector de entrada
@   r1: dirección del vector de salida
@   r2: longitud
@   r3: factor de diezmado
@
@ Valor de retorno: -

.thumb_func
    asm_downsampleM:

    push {r4-r7}

	mov r4,#0	@r4 representa la variable sampleCounter
	mov r5,#0	@r5 representa la variable currentInSample
	mov r6,#0	@r6 representa la variable currentOutSample

				@r7 va a ser el contenido en la dirrecion actual del vector de entrada
				@r8 va a ser el contenido en la dirrecion actual del vector de salida

	sub r3,#1	@utilizado en el condicional del if

	_downsample_loop:

		cmp r4,r3
		bne _comp_downsample_not_equal
		mov r4,#0
		add r5,#1			@salteo de posición de 32 bits

		_comp_downsample_not_equal:

		@acá va la asignación

		ldr r7,[r0,r5,lsl 2]		@cargo valor actual del vector de entrada
		str r7,[r1,r6,lsl 2]		@lo asigno a la posición actual del vector de salida

		add r4,#1			@aumento sampleCounter
		add r5,#1			@aumento currentInSample
		add r6,#1			@aumento currentOutSample

		cmp r5,r2
		blo _downsample_loop


	pop {r4-r7}
    bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                @ es la direccion, en el codigo del programa

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_invertir (uint16_t * vector, uint32_t longitud);

@ Parametros recibidos:
@   r0: dirección del vector de entrada
@   r1: longitud del vector
@
@ Valor de retorno: -

.thumb_func
    asm_invertir:

    push {r4-r6}

    mov r2,#0	@ utilizado como temp

    mov r3,r1
    lsr r3,1		@para utilizarlo al igual que la variable flipTimes

    _invertir_loop:

    sub r4,r3,#1			@utilizarlo para indexar a flipTimes -1
    ldrh r2,[r0,r4,lsl #1]	@valores de 16 bits

    sub r5,r1,r3			@utilizado para indexar a longitud-flipTimes
    ldrh r6,[r0,r5,lsl #1]

    strh r6,[r0,r4,lsl #1]	@guardo el contenido de longitud-flipTimes en flipTimes-1
    strh r2,[r0,r5,lsl #1]	@guardo el contenido de flipTimes-1  en longitud-flipTimes

    subs r3,#1

    bne _invertir_loop 		@mientras que flipTimes sea mayor a cero sigo ejecutando

	pop {r4-r6}

    bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                @ es la direccion, en el codigo del programa

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_addEcoVector(int16_t* vector,uint16_t longitud, uint16_t sampleDelay);

@ Parametros recibidos:
@   r0: dirección del vector
@   r1: longitud
@	r2: delay en muestras, en este caso 882
@
@ Valor de retorno: -

.thumb_func

    asm_addEcoVector:

    push {r4-r6}			@r5 tendrá el valor en 0 del array
    						@r6 tendrá el valor con offset en 882 muestras

	mov r3,#0				@r3 analogo a i
	mov r4,r2				@cargo en r4 882

     _for_eco_loop:

     	ldrsh r5,[r0,r3,lsl #1]	@cargo lo que está en la posición i y lo multiplico por 2 por ser datos de 16 bits
								@r2 se va a usar para mantener el valor de delay

		ldrsh r6,[r0,r4,lsl #1]	@cargo lo que está en la posición 882+i y lo multiplico por 2 por ser datos de 16 bits
								@r2 se va a usar para mantener el valor de delay

		add r6,r6,r5,asr #1		@equivalente a N1 = N1 + N2>>1
		ssat r6,16,r6

		strh r6,[r0,r4,lsl 1]  	@guardo resultado en 882+i y lo multiplico por 2 por ser datos de 16 bits

		add r3,#1
		add r4,#1

		cmp r4,r1

	 bne _for_eco_loop			@si son diferentes longitud e i sigo con el lazo

     pop {r4-r6}


    bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                @ es la direccion, en el codigo del programa

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_simd_addEcoVector(int16_t* vector,uint16_t longitud, uint16_t sampleDelay);

@ Parametros recibidos:
@   r0: dirección del vector
@   r1: longitud
@	r2: delay en muestras, en este caso 882
@
@ Valor de retorno: -

.thumb_func

    asm_simd_addEcoVector:

    push {r4-r6}			@r5 tendrá el valor en 0 del array
    						@r6 tendrá el valor con offset en 882 muestras

	mov r3,#0				@r3 analogo a i
	mov r4,r2				@cargo en r4 882
	asr r4,#1				@división por dos del shift porque los elementos seran traidos de a dos
	asr r1,#1				@la longitud ahora tambien será la mitad

     _for_eco_simd_loop:

		ldr r5,[r0,r3,lsl #2]	@cargo lo que está en la posición i y lo multiplico por 4 por ser 2 datos de 16 bits
								@r2 se va a usar para mantener el valor de delay

		mov r6,#0

		shadd16 r5,r5,r6		@ es equivalente a r5=(r5+r6)/2 pero r6 vale cero
								@ es un mecanismo para obtener una division por 2 del contenido en la posición i

		ldr r6,[r0,r4,lsl #2]	@cargo lo que está en la posición 441+i y lo multiplico por 4 por ser 2 datos de 16 bits
								@r2 se va a usar para mantener el valor de delay

		qadd16 r6,r6,r5			@equivalente a N1 = N1 + N2/2
								@utilizo suma en SIMD con saturacion en 16 bits

		str r6,[r0,r4,lsl 2]  	@guardo resultado en 441+i y lo multiplico por 4 por ser 2 datos de 16 bits

		add r3,#1
		add r4,#1

		cmp r4,r1

	 bne _for_eco_simd_loop			@si son diferentes longitud e i sigo con el lazo

     pop {r4-r6}


    bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                @ es la direccion, en el codigo del programa

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_corr (int16_t *vectorX, int16_t * vectorY, int16_t* vectorCorr, uint32_t longitud);

@ Parametros recibidos:
@   r0: dirección del vectorX
@   r1: dirección del vectorY
@   r2: dirección del vectorCorr
@   r3: longitud
@
@ Valor de retorno:-

.thumb_func

    asm_corr:

    push {r4-r8}

    mov r4,#0		@utilizado como acc
    mov r5,#0		@utilizado como l

    _corr_l_loop:

        mov r6,r5		@utilizado como n=l en inicilización del loop

    _corr_n_loop:

    ldrsh r7,[r0,r6,lsl 1]		@carga de contenido de vectorX en la posición n
    ldrsh r8,[r1,r6,lsl 1]		@carga de contenido de vectorY en la posición n

    mul r7,r7,r8				@r7=r7*r8

    add r4,r4,r7				@r4 = r7*r8 + r4
    							@b hace referencia a la parte baja de cada registro
    							@t puede usarse b o t (bottom o top)

    ssat r4,16,r4				@saturo en 16 bits el resultado para ser almacenado

    add r6,#1
    cmp r6,r3			@compara n y longitud
    bne _corr_n_loop	@si sale de acá ya terminé el primer loop

    str r4,[r2,r5,lsl 1]	@asignación de acc a verctor corr en la posición l
    mov r4,#0				@reinicia acc

    add r5,#1
    cmp r5,r3			@compara l y longitud
    bne _corr_l_loop	@si sale de acá ya termino el segundo for

    pop {r4-r8}


    bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                @ es la direccion, en el codigo del programa

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_simd_corr (int16_t *vectorX, int16_t * vectorY, int16_t* vectorCorr, uint32_t longitud);

@ Parametros recibidos:
@   r0: dirección del vectorX
@   r1: dirección del vectorY
@   r2: dirección del vectorCorr
@   r3: longitud
@
@ Valor de retorno:-

.thumb_func

    asm_simd_corr:

    push {r4-r9}

    mov r4,#0		@utilizado como acc
    mov r5,#0		@utilizado como l
    mov r9,r3		@para mantener el valor de long en r3
    sub r9,#1		@límite de N-2 por lo que se explica mas abajo

    _corr_simd_l_loop:

        mov r6,r5		@utilizado como n=l en inicilización del loop

    _corr_simd_n_loop:

    ldr r7,[r0,r6,lsl 1]		@carga de contenido de vectorX en la posición n
    ldr r8,[r1,r6,lsl 1]		@carga de contenido de vectorY en la posición n

    @al cargar 4 bytes hay que tener cuidado con el valor de n actual, si n vale
    @18 por ejemplo, se tomarán un dato fuera de la memoria en los dos array
    @por eso el límite para el primer for es N-2

    smlad r4,r7,r8,r4			@r4 = r7*r8 + r4 (multiplico parte alta y baja en una instrucción)
    							@es decir el elemento en n y en n-1 y la suma se coloca en r4

    ssat r4,16,r4				@saturo en 16 bits el resultado para ser almacenado

    add r6,#2				@sumo de a dos porque se cargan 4 bytes de la memoria
    cmp r6,r9				@compara n y la longitud
    ble _corr_simd_n_loop	@si sale de acá ya terminé el primer loop
    						@la condición es menor o igual porque se dan saltos de a dos y puede saltarse la condición de igual

    str r4,[r2,r5,lsl 1]	@asignación de acc a verctor corr en la posición l
    mov r4,#0				@reinicia acc

    add r5,#1
    cmp r5,r3				@compara l y longitud total
    ble _corr_simd_l_loop	@si sale de acá ya termino el segundo for

    pop {r4-r8}


    bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                @ es la direccion, en el codigo del programa
