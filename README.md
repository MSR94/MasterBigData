# Master Big Data

En este trabajo se diseñan y aplicar diferentes modelos para predecir la demanda energética de Baleares. Para ello, se tienen en cuenta variables climatológicas, festividades o épocas del año, entre otras. A partir de un gran número de variables, se aplica un método estadístico para determinar cuáles son las más informativas. Los modelos de predicción son construidos a partir de series temporales, métodos estadísticos y redes neuronales. Para cuantificar la fiabilidad de los modelos se usa el error cuadrático medio y el error porcentual absoluto medio, lo cuáles cuantifican el error cometido por cada método. Los resultados obtenidos sugieren que es mejor usar las redes neuronales o modelos estadísticos frente a las series temporales.


## Objetivos
* Capturar los datos sobre la demanda energética de los últimos años en Mallorca.
* Capturar los datos sobre los estados climatológicos.
* Identificar y analizar los factores que puedan influir en la demanda energética.
* Estudiar y tratar los datos para decidir cuáles serán útiles en el diseño de los modelos.
* Diseñar diferentes modelos de predicción de la demanda energética en función de las variables más informativas.
* Evaluar los resultados obtenidos para valorar la buena aproximación de los modelos diseñados.

## Factores que influyen en la demanda energética
* **Clima.** Las variables climatológicas son posiblemente las que tienen mayores efectos sobre la demanda de energía. Entre otros motivos, los usuarios tienen que decidir si es necesario acondicionar o no el espacio.
* **Factores económicos.** En general, los factores económicos y la demanda energética están relacionados. Algunos de estos factores son la tasa de paro o el producto interior bruto (PIB), por lo que a mayor nivel económico, generalmente hay una mayor demanda y un mayor consumo eléctrico.
* **Calendario Laboral.** La demanda eléctrica presenta cambios según el horario laboral, festividades, época del año, día del mes, etc.
* **Factores no predecibles.** En este apartado se debe tener en cuenta eventos puntuales, como pueden ser huelgas, eventos especiales (festivales musicales o grandes eventos deportivos, entre otros), cierre de instalaciones, etc.

## Estacionalida de la demanda energética
![DDAAnual](https://user-images.githubusercontent.com/44135385/122987799-4bcf3c00-d3a1-11eb-9104-3ecbf930e951.png)
![DDASemana](https://user-images.githubusercontent.com/44135385/122987823-54277700-d3a1-11eb-9043-098427e9e531.png)
![DDAHoras](https://user-images.githubusercontent.com/44135385/122987831-58539480-d3a1-11eb-9df9-dd0543a9558d.png)

## Elección de las variables más informativas
Sobre un total de 31 variables, se aplica el método de las componentes principales para determinar cuáles aportan más información.
![PCAPrincipalesAcum](https://user-images.githubusercontent.com/44135385/122988217-c6985700-d3a1-11eb-8bce-061b217c5778.png)
![ContribucionPCA1](https://user-images.githubusercontent.com/44135385/122988149-b4b6b400-d3a1-11eb-8e97-d76cf9276e46.png)


## Modelos de pronóstico
Máquinas de soporte vectorial:
![SVM8VarGrafica](https://user-images.githubusercontent.com/44135385/122989852-95b92180-d3a3-11eb-89c0-443b26227247.png)
ARIMA:
![ARIMADemanda](https://user-images.githubusercontent.com/44135385/122989880-9ce02f80-d3a3-11eb-87e3-c549f651b753.png)
Redes Neuronales:
![RRNN33Var52Grafica](https://user-images.githubusercontent.com/44135385/122989942-ae293c00-d3a3-11eb-8a15-e16e1f564a8e.png)

## Discusión de los resultados
Se han aplicado los modelos para diferentes configuraciones obteniendo los resultados:

![Captura de pantalla 2021-06-22 a las 21 52 12](https://user-images.githubusercontent.com/44135385/122990497-4c1d0680-d3a4-11eb-9435-d3f3667b4e4b.png)

**Máquinas de soporte vectorial**
* Ventajas:
  * Se necesitan estimar pocos parámetros.
  * No hay optimo local, sino que es global.
  * Método flexible y fácilmente escalable para dimensiones superiores.
* Inconvenientes:
  * Se necesitan metodologías eficientes para determinar la mejor función disponible de las svm.
**ARIMA**
* Ventajas:
  * Ideales para predicciones a corto plazo, debido a su capacidad de aprender rápidamente los cambios en la dinámica de la serie.
  * Bajo coste computacional y rápidos de construir.
  * Capaz de mantener una tendencia uniforme para la gráfica estimada.
* Inconvenientes:
  * El horizonte de pronóstico es a veces muy corto. Poco eficiente en el uso de información.
**Redes Neuronales**
* Ventajas:
  * No es necesario conocer los detalles matemáticos.
  * Modelos sencillos que permiten obtener bajos errores en el pronóstico.
  * Obtiene buenos resultados en corto, medio y largo plazo.
  * Sintetización de los algoritmos e información a través de un proceso de aprendizaje.
  * Solución de problemas no lineales.
  * Redes robustas, por lo que aunque fallen algunos elementos del procesamiento la red continua trabajando.
* Inconvenientes:
  * Hay que indicar la arquitectura más apropiada, por lo que hay una dificultad para diseñar la red óptima.
  * Las redes se deben entrenar para cada problema concreto, además de ser un proceso largo y costoso.
  * Dificultad para realizar pequeños cambios, ya que si se cambian las condiciones iniciales se tiene que entrenar nuevamente la red.
  * El algoritmo puede converger a óptimos locales.





