Module-SPI---RISC-V

El propósito del módulo SPI (Serial Peripheral Interface) es proporcionar una interfaz de comunicación síncrona y serial entre un microcontrolador RISC-V y uno o varios dispositivos periféricos externos, como sensores, memorias, convertidores o módulos de comunicación, siguiendo el protocolo estándar SPI.

Este módulo actúa como maestro SPI, siendo responsable de generar las señales necesarias para controlar la transmisión de datos: reloj serial (SCLK), selección de esclavos (SS o CS_n), y las líneas de datos (MOSI y MISO). Además, se encuentra diseñado para ser completamente configurable y controlado por el procesador RISC-V a través de una interfaz de memoria mapeada, lo que permite su integración directa en sistemas embebidos personalizados.

El presente repositorio contiene la información y archivos desarrollados respecto del módulo para la comunicación SPI descripto en Verilog, además de los archivos generados en la síntesis por la herramienta Openlane.

El módulo SPI_Controller es la unidad de control secuencial del sistema SPI Master, responsable de coordinar el proceso de comunicación con dispositivos esclavos SPI. En esta versión, se implementa como una máquina de estados finitos (FSM) tipo Mealy, lo cual permite generar salidas que dependen tanto del estado actual como de las entradas del sistema.

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

Representación Máquina de estados Mealy

![image](https://github.com/user-attachments/assets/a8059fd4-cb07-4bc9-abd7-bc1f7306d4a3)

Elementos de la especificación que fueron cubiertos:

✔ Comunicación SPI en modo maestro.

✔ Soporte para transferencia de 8,16,24 y 32 bits.

✔ Generación de señales: MOSI, MISO, SCLK, SS.

✔ Implementación de máquina de estados (FSM) para control del flujo de transmisión.

✔ Interfaz de memoria mapeada compatible con CPU RISC-V.

✔ Control de transmisión vía registros (spi_bitrate, spi_data_out, spi_data_in, spi_ctrl, etc.).

✔ Opción de habilitación (EN_SPI) y señal de interrupción (IRQ_SPI).

✔ Diseño estructurado y modular, compatible con síntesis digital (OpenLane).

Elementos pendientes o en desarrollo futuro Aquí sé sincero, directo y justifica si no lo implementaste, pero también muestra que eres consciente de ello:

❌ No se implementó el soporte para múltiples esclavos (es decir, múltiples líneas CS_n). Actualmente solo se controla un esclavo SPI.

❌ No se añadió detección de errores o timeouts en caso de transmisiones fallidas o esclavo desconectado.

❌ Sin validación formal exhaustiva (por ejemplo, con SymbiYosys).
