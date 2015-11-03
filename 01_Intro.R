#' ---
#' title: "Taller: SparkR (R on Spark) I"
#' author: VII JORNADAS DE USUARIOS DE R
#' date: "Salamanca, 5 de noviembre de 2015</br>Jorge Ayuso Rejas"
#' output: 
#'  html_document:
#'    theme: cerulean
#'    highlight: tango
#'    css: img/base.css
#' ---

#+ include=FALSE
knitr::opts_chunk$set(cache=TRUE,fig.align='center',message=FALSE,warning=FALSE)
rm(list = ls());gc()


#' # Introducción
#' 
#' 
#' ## ¿Qué es *Spark*?
#' 
#' <center>
#' ![spark](img/spark-logo.png)
#' </center>
#' <br>
#' <br>
#' 
#' >"Apache Spark™ is a fast and general engine for large-scale data processing."
#' 
#' ## ¿Por qué Spark? ¿Qué ventajas tiene? <u>Mi resumen</u>
#' 
#' Hadoop nació (~2005) para procesar grandes cantidades de datos en paralelo. Poco a poco
#' han surgido nuevas problemáticas que no se podían resolver con el paradigma *MapReduce* y han ido surgiendo
#' nuevos programas para solventar estas
#' problemáticas, creando así nuevos sistemas especializados:
#' 
#' <center>
#' ![spark](img/mapreduce_ecosystem.png)
#' </center>
#' 
#' Spark es uno de estos nuevos sistemas, cambia la manera de trabajar internamente (utiliza memoria, *RDD*,*DAG*...) y unifica
#' bajo un solo proyecto los grandes problemas de datos hasta el momento: Procesamiento en Batch,
#' en *streaming*, *machine learning*, *SQL*...   
#' 
#' Además incluye en el mismo proyecto varios lenguajes: Scala, Java, python y R.
#' <center><h3>**¡NO SOLO JAVA!**</h3></center>
#' 
#' <center>
#' ![spark](img/esquema2.png)
#' </center>
#' </br></br>
#' Spark se ha hecho famoso y todo el *BigData* mira hacia él. Esto ha hecho que muchas de las 
#' aplicaciones ya existentes se hayan hecho compatibles con Spark y que estén surgiendo nuevas
#' enfocadas en trabajar con Spark. Pero además Spark es compatible con Hadoop así que podemos
#' usar el mismo cluster y los mismos datos con uno u otro.
#' 
#' <center>
#' ![spark](img/ecosystem.png)
#' </center>
#' 
#' Más información: 
#' 
#' * http://www.slideshare.net/pacoid/crash-introduction-to-apache-spark
#' * http://es.slideshare.net/arjones/introduccion-a-apache-spark
#' 
#' 
#' ## Descargamos Spark:
#' 
#' Web: https://spark.apache.org/downloads.html   
#' Precompilado y compatible con Hadoop 2.6: http://www.apache.org/dyn/closer.lua/spark/spark-1.5.1/spark-1.5.1-bin-hadoop2.6.tgz
#' 
#' # SparkR: Usando Spark desde R
#' 
#' SparkR es muy nuevo (junio 2015 en el proyecto oficial), por ahora solo es compatible con la *DataFrame API*.
#' Esto significa que hoy por hoy solo podemos trabajar con datos estructurados
#' (tipo `dplyr`) y no se puede
#' paralelizar código en R (R no hace falta que esté instalado en todos los nodos).    
#' Lo bueno: Al entrar
#' a formar parte del proyecto su evolución está garantizada. Para la versión 1.6
#'  se esperan muchas novedades. 
#' 
#' 
#' Más información:    
#' 
#' * https://spark.apache.org/docs/latest/sparkr.html
#' * https://spark.apache.org/docs/latest/api/R/index.html
#' 
#' ## Primeros pasos con SparkR
#' 
#' 
#' Veamos algunos ejemplos usando SparkR en local (solo necesitamos tener R y Java instalado).
#' Descargamos y configuramos para poder usar el paquete de R, seguimos los siguientes pasos:
#' 
#'  
#' 1. Descargamos Spark (links arriba)
#' 2. Descomprimimos el archivo descargado
#' 3. Introducimos en el archivo `.Renviron` lo siguiente:    
#' 
#'> ``
#'> SPARK_HOME = <Directorio donde hemos descomprimido spark>
#'> ``
#'
#' 4. (Recomendable): En la carpeta `$SPARK_HOME/conf` copiar 
#' `log4j.properties.template` a `log4j.properties` y cambiar la
#' siguiente línea:   
#' 
#'> ``log4j.rootCategory=INFO, console``
#'
#'por
#'
#'> ``log4j.rootCategory=ERROR, console``
#'  
#' 
#+ include=TRUE
#' 
#' Iniciamos R y comprobamos que la variable de entorno está bien configurada:
Sys.getenv("SPARK_HOME")

#' <br><br>
#' Añadimos la librería de *SparkR* al `libPath` y cargamos la librería:

.libPaths(c(file.path(Sys.getenv("SPARK_HOME"),"R/lib/"),.libPaths()))
library(SparkR)
library(magrittr)

#' También vamos a usar la librería `magrittr` para usar `%>%` para programar. 
#' <br>  <br>
#' 
#' Arrancamos Spark, esto lo hacemos creando un *Spark Context* en la variable `sc`.
#' En nuestro caso indicamos que queremos arrancar Spark de manera local y con todos los
#' núcleos disponibles.

sc <- sparkR.init(master = "local[*]",appName = "Primera Prueba")

#' <br>
#' Una vez arrancado Spark, podemos ver la *Spark UI* en http://localhost:4040:  
#' <br>
#' <center style="border:1px solid #021a40;">
#' ![ui](img/spark_ui.png)
#' </center>
#' <br><br>
#' Inicializamos el `sqlContext` para poder hacer uso de la `DataFrame API`
#' 

sqlContext <- sc %>% sparkRSQL.init()

#' <br><br>
#' Podemos crear un `DataFrame` de Spark desde un `data.frame` local:
class(iris)
df_iris <- sqlContext %>% createDataFrame(iris)
class(df_iris)
df_iris
df_iris %>% head

#' La diferencia entre un `DataFrame` de Spark es que no vive en la memoria de R. Si no 
#' en Spark así que podremos trabajar con grandes *datasets* de manera cómoda, por ejemplo:

df_iris %>% filter("Sepal_Length>7") %>% count

#' También podemos registrar el `DataFrame` y usar SQL:
df_iris %>% registerTempTable("iris")
sqlContext %>% tables %>% collect

sqlContext %>% sql("select count(*) from iris where Sepal_Length>7") %>% collect


#' Cuando hemos terminado cerramos Spark:
sparkR.stop()

#'
#'<br><br>
#'
#'---
#'
#'<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Licencia de Creative Commons" style="border-width:0" src="img/88x31.png" /></a><br />Este obra está bajo una <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">licencia de Creative Commons Reconocimiento-CompartirIgual 4.0 Internacional</a>.
#'

