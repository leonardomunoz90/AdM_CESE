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
    	str r2, [r0],4		@pone el contenido de r2 en *r1 y aumenta en 4 r0 por ser de 32 bits
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

     	ldr r4,[r0],4		@carga el contenido de vectorIn en r4 y aumenta la dirección de r0 en 4 bytes
     	mul r4,r4,r3		@r4=r4*r3, r3 es el escalar
    	str r4, [r1],4		@pone el contenido de r4 en *r1 y aumenta en 4 r0 por ser de 32 bits

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

     	ldrh r4,[r0],2		@carga el contenido de vectorIn en r4 (media palabra)y aumenta la dirección de r0 en 2 bytes
     	mul r4,r4,r3		@r4=r4*r3, r3 es el escalar
    	strh r4, [r1],4		@pone el contenido de r4 en *r1 y aumenta en 4 r0 por ser de 32 bits

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

     	ldrh r4,[r0],2		@carga el contenido de vectorIn en r4 (media palabra)y aumenta la dirección de r0 en 2 bytes
     	mul r4,r4,r3		@r4=r4*r3, r3 es el escalar
     	usat r4,#12,r4		@saturo el valor de r4 en 12 bits y lo vuelvo a almacenar en r4
    	strh r4, [r1],4		@pone el contenido de r4 en *r1 y aumenta en 4 r0 por ser de 32 bits

		subs r2,#1
		bne _for_prodEsc12		@vuele al for si longitud no llega a cero

	pop {r4}
    bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                @ es la direccion, en el codigo del programa
