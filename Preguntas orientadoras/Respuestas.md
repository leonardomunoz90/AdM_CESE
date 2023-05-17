# Resolución de trabajo práctico

### Preguntas orientadoras

1. Describa brevemente los diferentes perfiles de familias de microprocesadores/microcontroladores de ARM. Explique alguna de sus diferencias características.
> - Cortex A: Familia de microcontroladores especialmente dedicada a aplicaciones donde prima el alto rendimiento y multitarea. Suelen disponer de perifericos para optimización temporal (por ejemplo memoria cache), perifericos para procesamiento de imagen y tienen la capacidad de correr un sistema operativo como Linux o Android. Se encuentran en dispositivos como tablets o smartphones con una frecuencia de reloj en el orden de los GHz.
> - Cortex R: Principalmente utilizado para tareas de tiempo real, buscando un determinismo temporal entre las multiples tareas para lograr sistemas confiables y lo mas predecibles posibles. Se utilizan principalmente e industriales críticos, sector automotiz, médico o aplicaciones de hard real time.
> - Cortex M: Utilizado en amplio rango de sistemas embebidos en general con gran versatiliad, existiendo una amplia oferta según se requeriera mayor poder de prcesamiento, bajo consumo, sistemas compactos, etc.

---

### Cortex M

1. Describa brevemente las diferencias entre las familias de procesadores Cortex M0, M3 y M4.
> - Cortex M0: Utiliza la arquitectura ARMv6-M (con arquitectura de computadora Von Neumann), se utiliza principalmente en aplicaciones de bajo costo y bajo consumo que no requieren de gran cantidad de perifericos. Utilizan de manera parcial el set de instrucciones Thumb y Thumb-2. Existe tambien la familia Cortex M0+ con mayor rendimiento tambien para aplicaciones de bajo consumo, una de sus principales diferencias es la disposición de MPU en algunos casos.
> - Cortex M3: Utiliza la arquitectura ARMv7-M (con arquitectura de computadora de Hardvard). Disponen de la totalidad de las instrucciones Thumb y Thumb-2 con mejoras en lo que refiere a poder de procesamiento, frecuencia de trabajo, incorporación de SRAM y mejoras para implemenación de multiplicación y divisiones. Esto a costa de un incremento en su consumo respecto de un Cortex M0 
> - Cortex M4: Utiliza la arquitectura ARMv7-M. Su principal diferencia respecto de la familia cortex M3 es que dispone de hardware para DSP con posibilidad de unidad de punto flotante

2. ¿Por qué se dice que el set de instrucciones Thumb permite mayor densidad de código? Explique
> Thumb permite utilizar de manera conjunta instrucciones de 16 bits y 32 bits. Esto brinda una mayor densidad de código principalmente por dos motivos:
> - El primero es que las instrucciones más usadas del set de instrucciones ARM de 32 bits tienen correspondencia con  instrucciones Thumb de 16 bits, por lo que se pueden guardar mayor cantidad de instrucciones en un menor espacio de memoria.
> - Además, dispone de instrucciones de 32 bits que ejecutan más de una operación bajo una misma instucciones o opcode (con determinados sufijos) que se ejecutan en único ciclo de reloj.
> Por otro lado, el hecho de tener una mayor densidad de código impacta positivamente en el costo del microcontrolador (al requerir menos memoria) y en el consumo.

3. ¿Qué entiende por arquitectura load-store? ¿Qué tipo de instrucciones no posee este tipo de arquitectura?
> Esto significa que los datos deben cargarse desde la memoria, procesarse y luego volver a escribirse en la memoria utilizando una serie de instrucciones separadas. Por ejemplo, para incrementar un valor de datos almacenado en SRAM, el procesador necesita usar una instrucción para leer los datos de SRAM y colocarlos en un registro dentro del procesador, una segunda instrucción para incrementar el valor del registro y luego una tercera instrucción para escribir el valor de nuevo en la memoria

4. ¿Cómo es el mapa de memoria de la familia? 
> Los procesadores Cortex M disponen de 32 bits de direccionamiento, por lo que son capaces de direccionar hasta 4GB. Sobre este mapa de memoria de encuentran todos los perifericos, datos, código de programa y demás de manera continua.

5. ¿Qué ventajas presenta el uso de los “shadowed pointers” del PSP y el MSP?
> Los microcontrolares disponen de un registro llamado stack pointer, que indica donde comienza el stack de cada tarea dentro de la SRAM. Los shadowed pointers permiten la cohexistencia de dos tipos de stack pointers en los modos de operación privilegiado y no privilegiado.
> - Main stack pointer (MSP): es utilizado por el kernel y las interrupciones en modo privilegiado (Handler mode)
> - Process stack pointer (PSP): es utilizado por las tareas que se ejecutan en modo no privilegiado (Thread mode)
> 
> La separación de los niveles de acceso privilegiado y no privilegiado permite el desarrollo de sistemas  robustos al proporcionar un mecanismo para proteger los accesos a la memoria en regiones críticas.

6. Describa los diferentes modos de privilegio y operación del Cortex M, sus relaciones y como se conmuta de uno al otro. Describa un ejemplo en el que se pasa del modo privilegiado a no priviligiado y nuevamente a privilegiado.
> Respuesta
7. ¿Qué se entiende por modelo de registros ortogonal? Dé un ejemplo
> Respuesta
8. ¿Qué ventajas presenta el uso de intrucciones de ejecución condicional (IT)? Dé un ejemplo
> Respuesta
9. Describa brevemente las excepciones más prioritarias (reset, NMI, Hardfault). 
> Respuesta
10. Describa las funciones principales de la pila. ¿Cómo resuelve la arquitectura el llamado a funciones y su retorno?
> Respuesta
11. Describa la secuencia de reset del microprocesador. 
> Respuesta
12. ¿Qué entiende por “core peripherals”? ¿Qué diferencia existe entre estos y el resto de los periféricos?
> Respuesta
13. ¿Cómo se implementan las prioridades de las interrupciones? Dé un ejemplo
> Respuesta
14. ¿Qué es el CMSIS? ¿Qué función cumple? ¿Quién lo provee? ¿Qué ventajas aporta?
> Respuesta
15. Cuando ocurre una interrupción, asumiendo que está habilitada ¿Cómo opera el microprocesador para atender a la subrutina correspondiente? Explique con un ejemplo
> Respuesta
16. ¿Cómo cambia la operación de stacking al utilizar la unidad de punto flotante? 
> Respuesta
17. Explique las características avanzadas de atención a interrupciones: tail chaining y late arrival.
> Respuesta
18. ¿Qué es el systick? ¿Por qué puede afirmarse que su implementación favorece la portabilidad de los sistemas operativos embebidos?
> Respuesta
19. ¿Qué funciones cumple la unidad de protección de memoria (MPU)? 
> Respuesta
20. ¿Cuántas regiones pueden configurarse como máximo? ¿Qué ocurre en caso de haber solapamientos de las regiones? ¿Qué ocurre con las zonas de memoria no cubiertas por las regiones definidas?
> Respuesta
21. ¿Para qué se suele utilizar la excepción PendSV? ¿Cómo se relaciona su uso con el resto de las excepciones? Dé un ejemplo
> Respuesta
22. ¿Para qué se suele utilizar la excepción SVC? Expliquelo dentro de un marco de un sistema operativo embebido.
> Respuesta

### ISA

1. ¿Qué son los sufijos y para qué se los utiliza? Dé un ejemplo
> Respuesta
2. ¿Para qué se utiliza el sufijo ‘s’? Dé un ejemplo
> Respuesta
3. ¿Qué utilidad tiene la implementación de instrucciones de aritmética saturada? Dé un ejemplo con operaciones con datos de 8 bits.
> Respuesta
4. Describa brevemente la interfaz entre assembler y C ¿Cómo se reciben los argumentos de las funciones? ¿Cómo se devuelve el resultado? ¿Qué registros deben guardarse en la pila antes de ser modificados?
> Respuesta
5. ¿Qué es una instrucción SIMD? ¿En qué se aplican y que ventajas reporta su uso? Dé un ejemplo.
> Respuesta
