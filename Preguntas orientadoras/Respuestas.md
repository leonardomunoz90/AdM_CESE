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
> De esta manera, la pila utilizada por el kernel del sistema operativo se puede separar de ese uso por parte de las tareas de la aplicación, lo que permite una mayor confiabilidad y un uso óptimo del espacio de la pila. Además permite una mayor confiabilidad y un uso óptimo del espacio de la pila. Para aplicaciones simples sin un sistema operativo, el stack pointer puede usar directamente el MSP.

6. Describa los diferentes modos de privilegio y operación del Cortex M, sus relaciones y como se conmuta de uno al otro. Describa un ejemplo en el que se pasa del modo privilegiado a no priviligiado y nuevamente a privilegiado.
> Cuando el microcontrolador cortex se encuentra en estado de operación Thumb, es decir, cuando está corriendo el código de programa, tiene dos posibles estados de operación:
> - Handler mode: Es un estado con nivel de acceso privilegiado y es el que se asigna a un sistema operativo dentro del microcontrolador o a las rutinas atención de excepciones.
> - Thread mode: Es el asignado para la ejecución de las tareas de usuario, puede tener modo de acceso privilegiado o no privilegiado, esto dependerá del estado del bit nPRV dentro del registro de control.  De tal manera que cuando el bit nPRV se está en modo privilegiado y cuando se coloca un 1 se está en modo no privilegiado
> 
> Una manera de generar la secuencia requerida es la siguiente manera:
> - Por defecto, el microcontrolador inicia en modo privilegiado, pero este puede pasar a modo no privilegiado asignando un 1 en el bit nPRV del registro CONTROL. 
> - Para volver a modo privilegiado, el microcontrolador no permitirá poner en cero el bit nPRV de manera directa. Sino que eso debe hacerse llamando al manejador de excepción SVC, donde es posible ejecutar código en modo privilegiado. Una vez dentro del manejador de interrupción se coloca en cero el bit nPRV para volver a modo privilegiado.

7. ¿Qué se entiende por modelo de registros ortogonal? Dé un ejemplo
> En el caso de los microcontroladores Cortex-M, el modelo de registro ortogonal permite acceder a los registros de propósito general desde cualquier nivel de privilegio, lo que proporciona flexibilidad y facilidad de uso. Por ejemplo, en el caso del registro de SP, ya sea que este apunte a MSP o PSP (inidicado por el bit SPSEL del registro de control) , le es totalmente transparece ya que puede hacerlo en ambos niveles de privilegios (si bien no es muy recomendable utilizar MSP en modo no privilegiado).

8. ¿Qué ventajas presenta el uso de intrucciones de ejecución condicional (IT)? Dé un ejemplo
> EL uso de instrucciones condicionales if-true agregando sufijos a la instrucción ejecutada. En caso de que el condicional de falso, no debe ejecutar nada y se reemplaza por un NOP, sin afectar a la búsqueda y decodificación de instrucciones siguientes. 
> 
> Tiene como ventaja principal que se mantiene el régimen del pipeline de ejecutar una instrucción por ciclo de reloj y no se destruye el pipeline como ocurría con un salto incondicional.

9. Describa brevemente las excepciones más prioritarias (reset, NMI, Hardfault). 
> ARM define 15 interrupciones que se encuentran en las primeras posiciones de NVIC (las siguientes están definidas por cada fabricante que utilice la IP), entre las cuales se encuentran 3 cuya prioridad está establecida con un valor más importante que el resto de las excepciones y no puede modificarse por su gran importancia. Estas son:
> - RESET: es generada al encender o reiniciar el microcontrolador. Cuando se produce el reset, se restablecen todos los registros y se borra la memoria del microcontrolador.
> - NMI: Esta excepción se utiliza para eventos críticos que requieren una respuesta inmediata, como fallas de energía o eventos externos importantes. El NMI tiene la capacidad de interrumpir cualquier tarea en ejecución y no puede ser deshabilitado o enmascarado.
> - HARDFAULT: Esta excepción engloba las interrupciones MemManage, BusFault y Usage Fault, las cuales se ocasionan consecuencia de un fallo en el hardware.

10. Describa las funciones principales de la pila. ¿Cómo resuelve la arquitectura el llamado a funciones y su retorno?
> La pila es una memoria tipo LIFO que se encarga de guardar el entorno de ejecución del microcontrolador cuando occurre un salto en su ejecución, para esto utiliza las instrucciones PUSH y POP. 
> 
> En caso de que ocurra un salto, mediante la instrucción PUSH se coloca el entorno de ejecución al final de la pila y cuando se retorna del salto se utiliza la instrucción POP, la cual extra la última entrada a la pila (por ser una memoria tipo LIFO) y vuelve a cargarse el entorno del microcontrolador en sus registros. 
> 
> Es importante aclarar que, en caso de un salto, el valor del contador de programa (CP) se guarda en el registro link register (LR) para que ocurre el retorno de dicho salto, el microcontrolador pueda continuar la ejecución como lo estaba haciendo.

11. Describa la secuencia de reset del microprocesador. 
> Luego de la posición cero de la memoria flash (que es donde se encuentra el valor del MSP) se encuentra el NVIC (vector de interrupciones), donde la primera posición de este vector contiene la dirección de memoria en la que se encuentra el inicio de la función de reset dentro de la memoria flash (que debe cargarse en el PC). Esta función se encarga de la inicialización de periféricos del fabricante, CMSIS, BSP, entre otras cosas. Una vez finalizado esto, la función de reset llama a la función main para iniciar su ejecución.

12. ¿Qué entiende por “core peripherals”? ¿Qué diferencia existe entre estos y el resto de los periféricos?
> Los core peripherals son todos aquellos periféricos que, en conjunto con el nucleo del procesador conforman un microcontrolador Cortex M. Estos son diseñados por el proveedor de la IP y dependen de la microarquitectura del procesador, entre los que se encuentran NVIC, MPU, WIC, FPU , embedded trace macrocell (ETM), debug access port, entre otros.
> 
> Por otro lado, cada fabricante de silicio que utilice la IP Cortex-M puede agregar perifericos que se comuniquen con el procesador según lo considere para su aplicación, entre los que se encuentran ADC, UART, SPI, USB, CAN, etc.


13. ¿Cómo se implementan las prioridades de las interrupciones? Dé un ejemplo
> Respuesta

14. ¿Qué es el CMSIS? ¿Qué función cumple? ¿Quién lo provee? ¿Qué ventajas aporta?
> Es un proyecto de ARM que permite que la programación de microcontroladorea basados en Cortex-M sea sencilla y migrable a productos de diferentes fabricantes, al proporcionar archivos y una API para las funciones estándar del procesador Cortex-M. Las ventajas que CMSIS aporta son:
> - Mayor reutilización de software : facilita la reutilización de código de software en diferentes proyectos de Cortex-M, lo que reduce el tiempo de comercialización y los esfuerzos de verificación.
> - Mejor compatibilidad de software: al tener una infraestructura de software consistente (por ejemplo, API para funciones de acceso al núcleo del procesador, método de inicialización del sistema, estilo común para definir periféricos), el software de varias fuentes puede trabajar en conjunto, lo que reduce el riesgo en la integración.
> - Independiente del toolchain: los driver de dispositivos compatibles con CMSIS se pueden usar con varias herramientas de compilación.

15. Cuando ocurre una interrupción, asumiendo que está habilitada ¿Cómo opera el microprocesador para atender a la subrutina correspondiente? Explique con un ejemplo
> Cuando ocurre una interrupción, el microcontrolador debe guardar el contexto de operación actual en el stack, esto incluye los registros de propósito general R0 a R3, R12, LR, la dirección a la cual debe retornar una vez termine la interrupción y el registro xPSR (en caso de que se hubiesen utilizado operaciones de punto flotante también deben guardarse estos registros, esto se explicará en una pregunta posterior).
> 
> Durante el proceso de cambio de contexto, también llamado stacking, el microcontrolador busca la dirección de la primera instrucción a ejecutar (puede hacerlo de manera simultánea al stacking por ser una arquitectura Harvard) en la posición del vector de interrupciones correspondiente. Además, una vez que el microcontrolador comienza la ejecución de la rutina de atención a interrupción, pasa a modo handler con nivel privilegiado de ejecución.
> 
>Una vez finalizada la interrupción, el microcontrolador retorna a la dirección que fue previamente guardada en el stack en lugar de utilizar LR, ya que este registro tiene codificado en su interior información de como volver de la rutina de atención a interrupción, por ejemplo, si debe usar PSP o MSP y si debe volver en modo handler o en modo thread. Finalmente busca en el stack los registros previamente guardados y los coloca en los registros para su retorno de ejecución (en caso de que no hubiese ninguna otra interrupción esperando ser atendida).

16. ¿Cómo cambia la operación de stacking al utilizar la unidad de punto flotante? 
> Durante el proceso de stacking, el microcontrolador verifica el bit FPCA en el registro de control, el cual indica si se ha utilizado la unidad de punto flotante. En caso de haberse utilizado, el microcontrolador también debe guardar los registros involucrados con la FPU durante el cambio de contexto. Estos registros son S0 a S15 y FPSCR que posee banderas que se corresponden con el resultado de última operación de la FPU, análogo al registro PSR. Por supuesto, una vez finaliza la rutina de atención a interrupción, estos datos deben extraerse del stack y colocarse en los registros correspondientes para que la tarea que las estaba utilizando previamente puede continuar su flujo de ejecución.
> 
17. Explique las características avanzadas de atención a interrupciones: tail chaining y late arrival.
> Respuesta
18. ¿Qué es el systick? ¿Por qué puede afirmarse que su implementación favorece la portabilidad de los sistemas operativos embebidos?
> SysTick es un temporizador utilizado en muchos sistemas operativos embebidos para proporcionar una base de tiempo y generar interrupciones periódicas, por ejemplo, en freeRTOS donde proporciona una forma de medir el tiempo y ejecutar código en intervalos regulares. Además, favorece la portabilidad de los sistemas operativos embebidos por ser estándar de la arquitectura Cortex-M.


19. ¿Qué funciones cumple la unidad de protección de memoria (MPU)? 
> La MPU es un dispositivo programable que monitorea las transacciones del bus. Esto permite dividir el espacio de memoria en varias regiones y definir los permisos de acceso para cada una de ellas. Cuando se viola una regla de acceso, se genera una excepción de falla al controlador de excepciones.
> 
> Un sistema operativo puede configurar la MPU para proteger los datos utilizados por el kernel del sistema operativo y otras tareas privilegiadas, evitando que los programas de usuario no confiables los dañen. Opcionalmente, el sistema operativo también puede aislar regiones de memoria entre diferentes tareas de usuario. Estas medidas permiten una mejor detección de fallas del sistema y permiten que los sistemas sean más robustos en el manejo de condiciones de error.
> 
> La MPU también se puede usar para hacer que las regiones de la memoria sean de solo lectura, para evitar el borrado accidental de datos en SRAM o la sobrescritura del código de instrucciones. De forma predeterminada, la MPU está deshabilitada y las aplicaciones que no requieren una función de protección de memoria no tienen que inicializarla.

20. ¿Cuántas regiones pueden configurarse como máximo? ¿Qué ocurre en caso de haber solapamientos de las regiones? ¿Qué ocurre con las zonas de memoria no cubiertas por las regiones definidas?
> Respuesta
21. ¿Para qué se suele utilizar la excepción PendSV? ¿Cómo se relaciona su uso con el resto de las excepciones? Dé un ejemplo
> Respuesta
22. ¿Para qué se suele utilizar la excepción SVC? Expliquelo dentro de un marco de un sistema operativo embebido.
> Una tarea de usuario dentro de un sistema operativo no puede realizar una llamada a periféricos o a memoria de manera directa por no poseer privilegios para hacerlo. Sino que esto debe hacerlo el sistema operativo. Una herramienta que dispone el usuario para hacerlo es a través del llamado a la excepción por software SVC, la cual puede llamarse desde modo no privilegiado. 
> 
> Por defecto, la ejecución de la función de manejo de SVC se hace en modo privilegiado. Esto permite invocar al sistema operativo y dar una respuesta a la petición de servicio generada por la tarea de usuario. Esto brinda mayor robustez e inmunidad al funcionamiento del sistema, evitando que una tarea corrompa su funcionamiento.


### ISA

1. ¿Qué son los sufijos y para qué se los utiliza? Dé un ejemplo
> Los sufijos se agregan a la instrucción base de assembly mediante el uso de letras después del mnemónico y se utilizan para proporcionar variantes de las instrucciones básicas, permitiendo operaciones específicas y más flexibilidad en la programación.
> 
> Por ejemplo, el sufijo "B" indica que la instrucción opera con palabras de un byte. Un caso de uso es la instrucción "LDRB", la cual carga un byte de memoria en un registro.

2. ¿Para qué se utiliza el sufijo ‘s’? Dé un ejemplo
> El sufijo "S" hace que la instrucción actualice las banderas de estado del registro APSR, las cuales indican información sobre el resultado de la operación, como el resultado cero, desbordamiento, acarreo, etc. Esto permite tomar decisiones condicionales basadas en el estado de las banderas en instrucciones posteriores.
> Por ejemplo, la instrucción ADDS R1, R2, R3 suma el contenido de los registros R2 y R3 y almacena el resultado en el registro R1. Además, actualiza las banderas de estado según el resultado de la suma.

3. ¿Qué utilidad tiene la implementación de instrucciones de aritmética saturada? Dé un ejemplo con operaciones con datos de 8 bits.
> La implementación de instrucciones de aritmética permite evitar desbordamientos y garantiza que los resultados se mantengan dentro de un rango específico. A nivel físico, un desbordamiento podría visualizarse como una señal que crece hacia un máximo positivo y de manera repentina pasa al valor máximo negativo.
> 
> La aritmética saturada evita este desbordamiento y mantiene el resultado dentro de un rango permitido. Por ejemplo, para variables no signadas de 8 bits mantiene su valor entre 0 y 255, en caso de un desbordamiento, el valor se mantiene en estos valores límites.

4. Describa brevemente la interfaz entre assembler y C ¿Cómo se reciben los argumentos de las funciones? ¿Cómo se devuelve el resultado? ¿Qué registros deben guardarse en la pila antes de ser modificados?
> Generalmente los primeros argumentos de una función se pasan en los registros R0, R1, R2 y R3. Si hay más argumentos, se colocan en la pila en orden inverso. 
> 
> El resultado de una función mayoritariamente se devuelve en el registro R0. En caso de que el resultado sea una estructura o arreglo, se puede pasar un puntero como argumento y la función puede modificar directamente los datos a través del puntero.

5. ¿Qué es una instrucción SIMD? ¿En qué se aplican y que ventajas reporta su uso? Dé un ejemplo.
> Las instrucciones SIMD (Single Instruction, Multiple Data) son un conjunto de instrucciones diseñadas para realizar operaciones paralelas en datos de múltiples elementos en una única instrucción. Estas instrucciones están especialmente optimizadas para trabajar con vectores y matrices de datos, lo que permite acelerar el procesamiento de operaciones numéricas y mejorar el rendimiento de cálculos intensivos.
>
> Cada instrucción SIMD puede procesar múltiples elementos de datos en un solo ciclo de reloj, lo que mejora la eficiencia y el rendimiento en comparación con instrucciones que procesan un solo elemento a la vez.
> 
> Por ejemplo, las instrucciones SIMD permite sumar 4 pares de números de 8 bits en una única instrucción ADD8, a la que además se le puede agregar prefijos para indicar si los operandos son signados (SADD8) o no signados (UADD8) e implementar saturación (QADD8 y UQADD8).

