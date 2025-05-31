Module-SPI---RISC-V

El propósito del módulo SPI (Serial Peripheral Interface) es proporcionar una interfaz de comunicación síncrona y serial entre un microcontrolador RISC-V y uno o varios dispositivos periféricos externos, como sensores, memorias, convertidores o módulos de comunicación, siguiendo el protocolo estándar SPI.

Este módulo actúa como maestro SPI, siendo responsable de generar las señales necesarias para controlar la transmisión de datos: reloj serial (SCLK), selección de esclavos (SS o CS_n), y las líneas de datos (MOSI y MISO). Además, se encuentra diseñado para ser completamente configurable y controlado por el procesador RISC-V a través de una interfaz de memoria mapeada, lo que permite su integración directa en sistemas embebidos personalizados.

El presente repositorio contiene la información y archivos desarrollados respecto del módulo para la comunicación SPI descripto en Verilog, además de los archivos generados en la síntesis por la herramienta Openlane.

El módulo SPI_Controller es la unidad de control secuencial del sistema SPI Master, responsable de coordinar el proceso de comunicación con dispositivos esclavos SPI. En esta versión, se implementa como una máquina de estados finitos (FSM) tipo Mealy, lo cual permite generar salidas que dependen tanto del estado actual como de las entradas del sistema.

Representación Máquina de estados Mealy

![image](https://github.com/user-attachments/assets/a8059fd4-cb07-4bc9-abd7-bc1f7306d4a3)

Se definieron dos partes fundamentales en el diseño del módulo para la comunicación SPI, la primera realiza toda la lógica de la comunicación donde aparte de mandar y recibir datos simultáneamente se debe configurar todos los parámetros según el registro de control y bitrate, la segunda parte se encarga de controlar los registros según el usuario.

![image](https://github.com/user-attachments/assets/f62240db-3ef8-4061-b1b2-f58559bf791f)

Inicialmente se diseñó la parte de la lógica de la comunicación, la cual se divide en 3 módulos como se muestra en la siguiente figura.

![image](https://github.com/user-attachments/assets/9d1b18b1-f243-4411-8b0e-b84085ba6d4e)

Primero se desarrolló un módulo para dividir la frecuencia del reloj de la CPU con el fin de generar el reloj interno SCK, el cual debe tener una frecuencia menor y ajustable por el usuario.

![image](https://github.com/user-attachments/assets/515adb51-d40d-4347-a163-011cecc3139a)

Al tener estos dos módulos se realiza una máquina de estados, la cual se encarga de manejar toda la lógica de control de la comunicación.

![image](https://github.com/user-attachments/assets/ad339214-2a01-49d5-a12f-4664fe07b0cc)

Este diseño mejora la velocidad de respuesta del controlador, permitiendo que ciertas señales de control (como SPI_FRAME_START o SS) cambien de forma inmediata ante condiciones específicas sin esperar un ciclo de reloj completo. Esto resulta útil en sistemas con alta sensibilidad temporal, como transmisiones SPI sincronizadas a bordes de reloj.

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

Con el fin de validar el correcto funcionamiento del módulo SPI desarrollado, se diseñaron y ejecutaron una serie de pruebas mediante testbenchs escritos en Verilog. Estas pruebas permiten verificar de forma controlada el comportamiento del módulo bajo diferentes condiciones operativas, asegurando que se cumplan los requerimientos funcionales establecidos en la especificación. En particular, se evaluaron los distintos modos de operación del protocolo SPI definidos por la configuración de las señales CPOL (Clock Polarity) y CPHA (Clock Phase), los cuales afectan la sincronización de los datos en las líneas MOSI y MISO respecto a los flancos del reloj serial SCLK. Para cada modo, se simularon escenarios completos de transmisión y recepción de datos, observando la integridad del flujo de información, la correcta activación de señales de control como SS, y la generación oportuna de señales de estado como done e irq_spi. Estas pruebas resultan fundamentales no solo para validar la lógica interna del sistema, sino también para asegurar su integridad temporal de cara a una futura síntesis física o implementación en FPGA o ASIC.

la siguiente prueba tiene los siguientes parametros:

SPI_MODE = 10 = modo 2
SPI_DATA_LEN = 01 = 16bits
SPI_ORDER = 0 = LSB primero

![image](https://github.com/user-attachments/assets/67ea88f4-58aa-403c-aa7e-86d95f76ba8b)

SPI_MODE = 01 = modo 1
SPI_DATA_LEN = 11 = 32bits
SPI_ORDER = 0 = LSB primero

![image](https://github.com/user-attachments/assets/3249ebbf-5854-4373-8926-9555463060cb)

SPI_MODE = 10 = modo 2
SPI_DATA_LEN = 01 = 16bits
SPI_ORDER = 1 = MSB primero

![image](https://github.com/user-attachments/assets/4c3030c3-fa12-4bb9-8e54-e83200621b2c)

SPI_MODE = 10 = modo 2
SPI_DATA_LEN = 11 = 32bits
SPI_ORDER = 0 = LSB primero

![image](https://github.com/user-attachments/assets/282bb9ee-6dbc-441c-8c7e-91bdcd3dbaa8)

SPI_MODE = 11 = modo 3
SPI_DATA_LEN = 01 = 16bits
SPI_ORDER = 1 = MSB primero

![image](https://github.com/user-attachments/assets/83265d00-64d3-49db-887f-25487299eb52)






