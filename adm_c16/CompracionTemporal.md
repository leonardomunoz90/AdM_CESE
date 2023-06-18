# Compración de tiempos de ejecución

A continuación se muestra una tabla comparativa con la cantidad de ciclos que le llevó al microcontrolador ejecutar los ejercicios de Eco y Correlación (ejercicios 10 y 11 de la guia) sobre código en C, en assembly sin utilizar SIMD y assembly utilizando SIMD.

Es importante aclarar que los tiempos de ejecición en C se extrajeron en modo debug, por lo que el compilador no ejecutó ninguna optimización sobre este código.

|                |     C     |  Assembly  |  SIMD  |
|----------------|-----------|------------|--------|
|      Eco       |  186.531  |   48.239   | 28.952 |
|  Correlación   |  10.902   |    2.535   | 1.448  |
