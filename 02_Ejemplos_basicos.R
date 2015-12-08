#' ---
#' title: "Taller: SparkR (R on Spark) II"
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


#' ## Entendiendo (un poco) Spark
#' 
#' Añadimos la librería de *SparkR* y creamos un `sc` y `sqlContext` local:

.libPaths(c(file.path(Sys.getenv("SPARK_HOME"),"R/lib/"),.libPaths()))
library(SparkR)
library(magrittr)
sc <- sparkR.init(master = "local[*]",appName = "Prueba II")
sqlContext <- sc %>% sparkRSQL.init()

#' <br><br>
#' 
#' Creamos de nuevo un `DataFrame` basado en `iris` de nuevo

df_iris <- sqlContext %>% createDataFrame(iris)

#' Spark es vago (*lazy*) en ejecución, ¿qué significa esto? Solo se ejecuta
#' las sentencias cuando son estrictamente necesarias. Por ejemplo: 
#' 
  p <- proc.time()
  df_filtrado <- df_iris %>% filter(df_iris$Species=="setosa")
  proc.time()-p
  
#' Tarda muy poco, porque no ha hecho la operación solo la ha registrado. Usamos una función de acción,
#' por ejemplo contar.

p <- proc.time()
df_filtrado %>% count
proc.time()-p

#' Al ejecutar una función de tipo *acción* (en esta caso `count`)
#' lanza todo los procesos necesarios para conseguir realizar la acción pedida.
#' En este caso sería hacer el filtro y luego contar.
#' Esto se puede ver en Spark UI (la web).    
#' 
#' <br>
#' Si volvemos a ejecutar el mismo código exactamente:

p <- proc.time()
df_filtrado %>% count
proc.time()-p

#' Hace exactamente lo mismo, primer filtra y luego cuenta Ya que por defecto
#' no persiste el `DataFrame` intermedio aunque lo estemos
#' definiendo como `df_filtrado`. 
#' 
#' Si queremos persistir un `DataFrame` intermedio podemos con la función 
#' `persist` o su versión más usada `cache`.
#' 

df_filtrado_cacheado <- df_iris %>% 
                          filter(df_iris$Species=="setosa") %>%
                          cache

p <- proc.time()
df_filtrado_cacheado %>% count
proc.time()-p

p <- proc.time()
df_filtrado_cacheado %>% count
proc.time()-p

#' La primera vez que contamos ejecuta el filtro y guarda el resultado en memoria.
#' Podemos ver que el `DataFrame` está persistido en: http://127.0.0.1:4040/storage/. 
#' La segunda vez que contamos ya no tiene que hacer el filtro porque ese resultado está
#' ya guardado en memoria.    
#' 
#' 
#'En general, siempre que vamos a usar un `DataFrame` intermedio varias veces
#'merece la pena cachearlo. En el momento en el que no vamos a necesitarlo más, podemos
#'eliminarlo de la memoria con `unpersist`
#'

df_filtrado_cacheado %>% unpersist()

#' ## Funciones predefinidas en Spark
#' 
#' Por defecto la API de DataFrame de Spark tiene multitud de
#'  funciones matemáticas, estadísticas,... Veamos algunos ejemplos con
#'  estas funciones.    
#'  <br>
#' La función `describe` que es similar al `summary` de R:
#' 


df_iris %>% describe() %>% collect

#' Podemos operar con estas funciones de forma muy similar al paquete `dplyr`:

nuevo <- df_iris %>% select(
                        .$Sepal_Length %>% log,
                        .$Species %>% lower %>% alias("bajo"),
                        lit(Sys.Date() %>% as.character()) %>% to_date() %>% alias("fecha")
                      ) %>% 
                     mutate(
                      mes=month(.$fecha)
                     )

nuevo %>% limit(10) %>% 
      collect()

nuevo %>% group_by("bajo") %>%
          avg() %>% 
          collect()


#' Más información:
#' 
#' * https://spark.apache.org/docs/latest/api/R/index.html
#' * Ejemplos (pero en python):
#'      + https://databricks.com/blog/2015/06/02/statistical-and-mathematical-functions-with-dataframes-in-spark.html
#'      + https://databricks.com/blog/2015/07/15/introducing-window-functions-in-spark-sql.html
#'    
#'    
#' Cuando hemos terminado cerramos Spark:
sparkR.stop()

#'
#'<br><br>
#'
#'---
#'
#'<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Licencia de Creative Commons" style="border-width:0" src="img/88x31.png" /></a><br />Este obra está bajo una <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">licencia de Creative Commons Reconocimiento-CompartirIgual 4.0 Internacional</a>.
#'

