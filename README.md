Module-SPI---RISC-V

El propósito del módulo SPI (Serial Peripheral Interface) es proporcionar una interfaz de comunicación síncrona y serial entre un microcontrolador RISC-V y uno o varios dispositivos periféricos externos, como sensores, memorias, convertidores o módulos de comunicación, siguiendo el protocolo estándar SPI.

Este módulo actúa como maestro SPI, siendo responsable de generar las señales necesarias para controlar la transmisión de datos: reloj serial (SCLK), selección de esclavos (SS o CS_n), y las líneas de datos (MOSI y MISO). Además, se encuentra diseñado para ser completamente configurable y controlado por el procesador RISC-V a través de una interfaz de memoria mapeada, lo que permite su integración directa en sistemas embebidos personalizados. El módulo actúa únicamente como dispositivo maestro y es posible configurar su frecuencia (SPI comunication), además cuenta con una transmisión FULL-DUPLEX que soporta 8, 16, 24 y 32 bits de información implementando un orden para los bits y 4 modos de operación. Finalmente cuando la transmisión concluye se genera una interrupción.

Los datos son muestreados cuando:

Clock Phase (CPHA) 

CPHA = 1: Se realiza el muestreo de los datos cuando se presenta un flanco de subida en la señal SCLK
CPHA = 0: Se raliza el muestreo de los datos cuando se presenta un flanco de bajada en la señal SCLK

Clock Polarity (CPOL)

CPOL = 1: La señal SCLK está arriba (1) cuando está inactiva
CPOL = 0: La señal SCLK está abajo (0) cuando está inactiva

Registros del Módulo SPI
1. SPI_BITRATE (32 bits)
Descripción: Divisor de reloj para generar la velocidad de transmisión deseada.

Fórmula:

Reloj_SPI = FACTOR × Reloj_CPU / SPI_BITRATE
Uso: Configura la frecuencia de operación del SPI (ej: para 1 MHz, ajustar SPI_BITRATE según la frecuencia de la CPU).

2. SPI_DATA_OUT (32 bits)
Descripción: Registro de escritura. Contiene los datos a transmitir al dispositivo esclavo.

Formato: Soporta valores de 8, 16, 24 o 32 bits.

Uso:

Escribir aquí los datos antes de iniciar la transmisión (activando SPI_START en SPI_CTRL).

3. SPI_DATA_IN (32 bits)
Descripción: Registro de lectura. Almacena el último dato recibido del esclavo.

Condiciones:

Solo debe leerse cuando el flag SPI_START (en SPI_CTRL) esté en 0 (transmisión completada).

Leer durante una transmisión (SPI_START = 1) devuelve valores inválidos.

4. SPI_CTRL (8 bits)
Descripción: Registro de control y estado.

Funciones clave:

SPI_START:

1: Inicia una transmisión full-duplex (lectura/escritura simultánea).

0: Indica que la transmisión ha finalizado.

Otros bits: Configuran modo SPI (CPOL/CPHA), tamaño de dato, etc.

Notas importantes
Transmisión Full-Duplex:

El módulo SPI lee (SPI_DATA_IN) y escribe (SPI_DATA_OUT) simultáneamente.

El presente repositorio contiene la información y archivos desarrollados respecto del módulo para la comunicación SPI descripto en Verilog, además de los archivos generados en la síntesis por la herramienta Openlane.

Se definieron dos partes fundamentales en el diseño del módulo para la comunicación SPI, la primera realiza toda la lógica de la comunicación donde aparte de mandar y recibir datos simultáneamente se debe configurar todos los parámetros según el registro de control y bitrate, la segunda parte se encarga de controlar los registros según el usuario.

![image](https://github.com/user-attachments/assets/f62240db-3ef8-4061-b1b2-f58559bf791f)

Inicialmente se diseñó la parte de la lógica de la comunicación, la cual se divide en 3 módulos como se muestra en la siguiente figura.

![image](https://github.com/user-attachments/assets/9d1b18b1-f243-4411-8b0e-b84085ba6d4e)

Primero se desarrolló un módulo para dividir la frecuencia del reloj de la CPU con el fin de generar el reloj interno SCK, el cual debe tener una frecuencia menor y ajustable por el usuario. Este módulo implementa un reloj SPI configurable mediante el uso de un divisor de frecuencia (Divider_clock_SPI), que ajusta la velocidad de comunicación (SCK) en función de la señal SPI_BITRATE y el reloj principal del sistema (clk_cpu). El diseño cumple con el requerimiento de frecuencia configurable al permitir:  

1.Control flexible: La señal SPI_BITRATE define el divisor de frecuencia, adaptando la velocidad del reloj SPI (SCK) a diferentes necesidades del protocolo.  
2. Sincronización robusta: El módulo opera bajo el reloj principal (clk_cpu) y un reset (rst), asegurando estabilidad en la generación de SCK.  
3. Habilitación selectiva: La señal en activa/desactiva el módulo, optimizando el consumo de recursos cuando no está en uso.  

Esta implementación garantiza compatibilidad con múltiples dispositivos SPI, ya que la frecuencia de SCK puede ajustarse dinámicamente sin modificar el hardware.

![image](https://github.com/user-attachments/assets/515adb51-d40d-4347-a163-011cecc3139a)

Este módulo de control SPI gestiona la comunicación serial configurable mediante un diseño jerárquico que integra temporización, procesamiento de datos y lógica de control. El divisor de frecuencia (clk_divider) ajusta la velocidad del reloj SPI (SCK) a partir del reloj principal (clk_cpu), mientras que la señal **SPI_CTRL** configura parámetros como el modo de operación y el bitrate. El módulo procesa datos de entrada (SPI_DATA_IN) y salida (SPI_DATA_OUT) con base en la longitud definida (SPI_DATA_LEN), sincronizados por las señales **load_data** y **load_data_in**. La lógica de control (**SPI_logic_Control**) coordina la generación de SCK, la activación de la línea SS (slave select) y las señales de estado (**done**), asegurando una transferencia confiable. Las señales intermedias (**SCK_inter**, **en_SCK**) optimizan la generación del reloj, mientras que **NEW_SPI_DATA_IN/OUT** reflejan los datos actualizados en tiempo real. Este diseño permite flexibilidad en frecuencia, formato de datos y modos SPI, cumpliendo con requisitos de adaptabilidad y eficiencia.

Este diseño mejora la velocidad de respuesta del controlador, permitiendo que ciertas señales de control (como SPI_FRAME_START o SS) cambien de forma inmediata ante condiciones específicas sin esperar un ciclo de reloj completo. Esto resulta útil en sistemas con alta sensibilidad temporal, como transmisiones SPI sincronizadas a bordes de reloj.

Al tener estos dos módulos se realiza una máquina de estados, la cual se encarga de manejar toda la lógica de control de la comunicación.

![image](https://github.com/user-attachments/assets/ad339214-2a01-49d5-a12f-4664fe07b0cc)

El módulo SPI_Controller es la unidad de control secuencial del sistema SPI Master, responsable de coordinar el proceso de comunicación con dispositivos esclavos SPI. En esta versión, se implementa como una máquina de estados finitos (FSM) tipo Mealy, lo cual permite generar salidas que dependen tanto del estado actual como de las entradas del sistema.

![image](https://github.com/user-attachments/assets/3462f697-143c-4b52-a792-f34f30ca7476)

El módulo **PISO_SIPO** es un componente fundamental para la comunicación **SPI full-duplex**, encargado de realizar la conversión entre datos paralelos y seriales de forma bidireccional. Durante la transmisión, toma un bloque de datos en paralelo (como un valor de 8, 16 o 32 bits) y lo convierte en una secuencia de bits que se envía de manera serial a través de la línea **MOSI**, siguiendo la configuración de longitud definida en **SPI_DATA_LEN**. Simultáneamente, en la recepción, captura los bits entrantes desde la línea **MISO** y los reconstruye en un dato paralelo, listo para ser leído por el sistema. Gestiona la sincronización mediante señales de control que indican cuándo cargar nuevos datos y cuándo la operación ha finalizado, asegurando una transferencia precisa y eficiente. Este módulo es esencial para integrar periféricos SPI en sistemas digitales, permitiendo una comunicación flexible y adaptable a diferentes tamaños de datos.

Los registros y el protocolo de bit durante la lectura y escritura son los siguientes: 

1. El usuario configura la bandera SPI_FRAME_START en el registro SPI_CTRL para iniciar una trama.
2. El usuario escribe datos en el resgistro SPI_DATA_OUT. Este paso puede saltarse durante una trama de solo lectura.
3. El usuario establece la bandera SPI_START en el SPI_CTRL para realizar la transmisión. Esta acción se realiza en un ciclo de lectura y escritura proporcionando transmisión full-duplex.
4. El módulo SPI limpia la bandera SPI_START cuando la transmsión es completada y genera una solicitud de interrupción si fue habilitada.
5. Los pasos 2 y 3 se repiten para todos los datos en la trama.
6. El usaurio limpia la bandera SPI_FRAME_START en el registro SPI_CTRL para detener la trama. Esta acción retorna las lineas MOSI, SCLK, and SS lines a sus estados de inactividad de acuerdo al modo seleccionado.

Representación Máquina de estados Mealy

![image](https://github.com/user-attachments/assets/fb904973-1aa4-476c-9ca9-08ec20279f3d)

Flujo de Operación SPI (Versión Concisa)
Paso 1: Preparación

Escribir datos a transmitir en SPI_DATA_OUT (ej: 0xA5).

Configurar parámetros (SPI_BITRATE, SPI_DATA_LEN).

Paso 2: Inicio

Activar SPI_START = 1 (inicia transmisión/recepción full-duplex).

Paso 3: Espera

Monitorizar SPI_START:

Mientras =1: Transmisión en curso.

Cuando =0: Operación completada (auto-limpieza por hardware).

Paso 4: Lectura

Leer SPI_DATA_IN para obtener datos del esclavo (válido solo si SPI_START = 0).

La máquina de estados describe el flujo de control de un módulo SPI con los siguientes estados y transiciones:

Comienza en estado **IDLE** (inactivo) cuando tanto `SPL_ON` como `SPL_FRAME_START` están en 0. Al activarse estas señales (`SPL_ON = 1` y `SPL_FRAME_START = 1`), la máquina pasa a una fase de **configuración** donde se prepara la comunicación. Luego, cuando `SPL_START` cambia de 0 a 1, se inicia el estado **TRANSMIT** (transmisión), activando `LOAD_DATA = 1` para cargar datos y `EN_SCK = 1` para habilitar el reloj SPI. Finalmente, al completarse la transferencia, el sistema entra al estado **DONE**, donde se genera una interrupción (`IRQ = 1`) para indicar la finalización, antes de volver al estado inactivo. Esta secuencia garantiza una operación ordenada: inicialización → transmisión → notificación, con control preciso de las señales críticas como el reloj (SCK) y la carga de datos.

Entradas y Salidas Principales

Entradas:

CPU_Clock: Reloj del sistema principal. Se utiliza para sincronizar todas las operaciones internas del módulo SPI.

Native memory interface: Conjunto de señales que permiten al CPU leer y escribir registros internos del SPI.

EN_SPI: Señal de habilitación del módulo SPI. Cuando está desactivada, el módulo no responde a comandos.

MISO: Master In Slave Out: línea por la que el esclavo SPI envía datos hacia el maestro.

Salidas:

MOSI: Master Out Slave In: línea por la que el SPI Master envía datos hacia el esclavo.

SCLK: Clock SPI: señal de reloj generada por el maestro y enviada al esclavo.

SS:Slave Select: línea de selección del esclavo (activo en bajo). También se le puede llamar CS_n.

IRQ_SPI: Señal de interrupción al CPU. Se activa al finalizar una transmisión SPI o cuando se presenta una condición especial (según implementación del FSM).

Elementos de la especificación que fueron cubiertos:

✔ Comunicación SPI en modo maestro.

✔ Soporte para transferencia de 8,16,24 y 32 bits.

✔ Generación de señales: MOSI, MISO, SCLK, SS.

✔ Implementación de máquina de estados (FSM) para control del flujo de transmisión.

✔ Interfaz de memoria mapeada compatible con CPU RISC-V.

✔ Control de transmisión vía registros (spi_bitrate, spi_data_out, spi_data_in, spi_ctrl, etc.).

✔ Opción de habilitación (EN_SPI) y señal de interrupción (IRQ_SPI).

✔ Diseño estructurado y modular, compatible con síntesis digital (OpenLane).

Elementos pendientes o en desarrollo futuro:

❌ No se implementó el soporte para múltiples esclavos (es decir, múltiples líneas SS). Actualmente solo se controla un esclavo SPI.

❌ No se añadió detección de errores o timeouts en caso de transmisiones fallidas o esclavo desconectado.

En el desarrollo de este módulo SPI, se ha cubierto satisfactoriamente la funcionalidad esencial del protocolo SPI en modo maestro, integrándose con el procesador RISC-V mediante una interfaz de memoria mapeada y generando las señales estándar del protocolo. Además, se ha diseñado una FSM robusta y se han contemplado mecanismos de control y señalización como interrupciones.

La vista RTL presentada corresponde a la estructura jerárquica del módulo SPI en su integración con el procesador RISC-V y otros componentes internos. En esta representación se identifican claramente los bloques funcionales principales y la interconexión de señales de control, datos y sincronización. El bloque central del diseño, encargado del control SPI, recibe señales como SPI_CTRL, clk_cpu, rst, load_data, y clk_divider, y genera señales esenciales como SCK, SS, IRQ_SPI, y done.

Se observan módulos auxiliares como el registro de desplazamiento (piso/sipo SPI), responsable de manejar las líneas de datos MOSI y MISO, el cual se conecta directamente al módulo controlador para intercambiar datos (data_in, data_out) y sincronizarse con el reloj SPI. También se visualiza un módulo divisor de reloj (clock_divider) que toma el reloj del CPU y genera la señal SCK de acuerdo con la velocidad configurada en el registro SPI_BITRATE. El sistema cuenta con rutas de datos de 32 bits para SPI_DATA_IN, SPI_DATA_OUT y control de carga de datos, lo cual permite transmitir palabras completas al periférico SPI. El control de longitud de palabra (SPI_DATA_LEN) permite adaptar el tamaño de las transferencias.

En conjunto, esta vista RTL permite verificar que el diseño cumple con una estructura modular clara, facilitando tanto la verificación como su posterior síntesis. Las conexiones están organizadas para soportar modos de operación programables y un flujo de datos eficiente entre el CPU, el controlador SPI, y el registro de desplazamiento

![image](https://github.com/user-attachments/assets/6629d331-eab4-4dbc-8556-9ee17fc361d6)

Con el fin de validar el correcto funcionamiento del módulo SPI desarrollado, se diseñaron y ejecutaron una serie de pruebas mediante testbenchs escritos en Verilog. Estas pruebas permiten verificar de forma controlada el comportamiento del módulo bajo diferentes condiciones operativas, asegurando que se cumplan los requerimientos funcionales establecidos en la especificación. En particular, se evaluaron los distintos modos de operación del protocolo SPI definidos por la configuración de las señales CPOL (Clock Polarity) y CPHA (Clock Phase), los cuales afectan la sincronización de los datos en las líneas MOSI y MISO respecto a los flancos del reloj serial SCLK. Para cada modo, se simularon escenarios completos de transmisión y recepción de datos, observando la integridad del flujo de información, la correcta activación de señales de control como SS, y la generación oportuna de señales de estado como done e irq_spi. Estas pruebas resultan fundamentales no solo para validar la lógica interna del sistema, sino también para asegurar su integridad temporal de cara a una futura síntesis física o implementación en FPGA o ASIC.

la siguiente prueba tiene los siguientes parametros:

Configuración del protocolo:
SPI_MODE = 00 = modo 0
SPI_DATA_LEN = 00 = 8bits
SPI_ORDER = 0 = LSB primero

![image](https://github.com/user-attachments/assets/d5049f00-07bd-4301-9115-7c67c45fe77a)

Datos transmitidos y recibidos:

Primer byte (Time 000-005):

MOSI (Tx): 9 (hex 0x09, binario 00001001). Se envía como secuencia serial: 1 (LSB), 0, 0, 1, 0, 0, 0, 0.

MISO (Rx): 26 (hex 0x1A, binario 00011010).

Segundo byte (Time 105-107):

MOSI (Tx): 169 (hex 0xA9, binario 10101001). Secuencia serial: 1, 0, 0, 1, 0, 1, 0, 1.

MISO (Rx): 33 (hex 0x21, binario 00010001).

Señales de control:

Contador (counter_bit): Aumenta de 0 a 7 por cada byte, validando los 8 bits.


Configuración del protocolo:

SPI_MODE = 01 = modo 3
SPI_DATA_LEN = 11 = 32bits
SPI_ORDER = 1 = MSB primero

![image](https://github.com/user-attachments/assets/ce25397a-1401-4f99-bc59-44168a6ce1d4)

El testbench muestra una comunicación SPI en modo 3 donde se transmiten 32 bits en orden MSB primero. Según los datos observados:

Dato recibido (MOSI): 2147483661 (0x8000000D en hexadecimal, 10000000000000000000000000001101 en binario).

Dato enviado (MISO): 851987 (0xD0013 en hexadecimal, 011010000000000010011 en binario).

La señal SCK (reloj) sincroniza la transferencia bit a bit, comenzando por el MSB. El valor 851987 se envía por MOSI, mientras que el esclavo responde con 2147483661. La señal SS (slave select) se mantiene baja durante la transmisión, y IRQ_SPI se activa al finalizar. El contador (counter_bit) confirma la transferencia de los 32 bits. Esta prueba valida la correcta configuración del modo SPI y la integridad de los datos en ambas direcciones.

![image](https://github.com/user-attachments/assets/c58cb935-acfe-45b8-9d65-aee5bca255a2)

La estrategia seleccionada para la implementación final fue AREA 3, la cual logró un balance entre lo compacto del diseño y cumplimiento de temporización. Esta estrategia generó un circuito con 1210 compuertas y un área total de 11,282.07 µm², garantizando un desempeño temporal adecuado con un worst setup slack de +5.86 ns y sin violaciones de tiempo (Total -ve Setup Slack = 0.0 ns). A pesar de que otras estrategias (AREA 2, por ejemplo) ofrecieron un área ligeramente menor (8548.19 µm² con 777 compuertas), presentaron violaciones severas de tiempo (–5.35 ns), lo cual comprometería la confiabilidad del sistema.

En comparación con las estrategias de tipo DELAY, si bien todas ellas lograron eliminar violaciones de tiempo, lo hicieron a costa de un incremento considerable en área, con valores que alcanzan hasta 11,013.06 µm² (DELAY 1). Por ello, se determinó que AREA 3 representa la mejor opción global, al satisfacer las restricciones temporales y mantener el área dentro de límites aceptables para la implementación física del chip.

Este perfil de síntesis fue utilizado como base para la generación del layout final del módulo, garantizando su integración eficiente dentro de un sistema RISC-V y facilitando la implementación en flujos de diseño digital como OpenLane.

Acontinuación se presenta la ilustración correspondiente al Layout de nuestro módulo SPI visualizado desde Klayout:

![image](https://github.com/user-attachments/assets/a6801ed6-47d6-47d4-bf5f-68412c0d2017)



