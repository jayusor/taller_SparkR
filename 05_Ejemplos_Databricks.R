#' ---
#' title: "Taller: SparkR (R on Spark) V"
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


#' # Ejercicios de Python a R
#' 
#' En el blog de databricks (creadores de Spark), existen varios artículos interesantes
#' para aprender el funcionamiento de Spark. Estos artículos suelen estar en python o scala pero
#' pocas veces en R (¡por ahora!). Vamos a seguir el artículo
#' *"Statistical and Mathematical Functions with DataFrames in Spark"* y 
#' a pasar estos ejemplos a SparkR (lo que se pueda).
#' 
#' Link: https://databricks.com/blog/2015/06/02/statistical-and-mathematical-functions-with-dataframes-in-spark.html
#'      
#'      
#' Arrancamos la sesión de Spark y vamos convirtiendo los ejemplos:      


.libPaths(c(file.path(Sys.getenv("SPARK_HOME"),"R/lib/"),.libPaths()))
library(SparkR)
library(magrittr)
sc <- sparkR.init(master = "local[*]",appName = "Prueba V")
sqlContext <- sc %>% sparkRSQL.init()

#' ## Statistical and Mathematical Functions with DataFrames in Spark
#' ### 1. Random Data Generation 
#' 
#' La primera función que utiliza es `range` pero esta función no existe en SparkR por ahora...   
#' Se puede solventar creando un `data.frame` local primero
#' 



df <- sqlContext %>% createDataFrame(data.frame(id=0:9))
        
df %>% collect()


df<- df %>% 
      mutate(
        uniform = rand(10),
        normal  = randn(27)
      )

df %>% head


#' ### 2. Summary and Descriptive Statistics

df %>% describe() %>% collect()
df %>% describe('uniform', 'normal') %>% collect()
df %>% select(mean(.$uniform), min(.$uniform), max(.$uniform)) %>% collect()


#' ### 3. Sample covariance and correlation

df %>% select("id") %>% 
          withColumn('rand1', rand(seed=10)) %>% 
          withColumn('rand2', rand(seed=27)) %>% 
          head

#' Las funciones `cov` y `corr` no están todavía disponibles desde SparkR,
#' está previsto para la versión 1.6: https://issues.apache.org/jira/browse/SPARK-10752.
#' 
#' ### 4. Cross Tabulation (Contingency Table)
#' 
names = c("Alice", "Bob", "Mike")
items = c("milk", "bread", "butter", "apples", "oranges")

df <- sqlContext %>% 
        createDataFrame(
          data.frame(name = names[rep_len(1:3, 100)] ,
                     item = items[rep_len(1:5, 100)]
                     ))

df %>% head(10)

df %>% crosstab('name', 'item') %>% head

#' ### 5. Frequent Items
#' De nuevo la función necesaria `freqItems` no está disponible y
#' se espera para la versión 1.6:  https://issues.apache.org/jira/browse/SPARK-10905
#' <br>
#' 
#' ### 6. Mathematical Functions

df <- sqlContext %>% 
        createDataFrame(data.frame(id=0:9)) %>% 
        withColumn('uniform', rand(seed=10) * 3.14)

df %>% select('uniform') %>% 
  mutate(
    toDegrees(.$uniform),
    (cos(df[['uniform']]) ** 2 + sin(.$uniform) ** 2) %>% alias("cos^2 + sin^2")
  ) %>% head
  

#'  <br>  
#' Cerramos Spark:
sparkR.stop()

#'
#'<br><br>
#'
#'---
#'
#'<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Licencia de Creative Commons" style="border-width:0" src="img/88x31.png" /></a><br />Este obra está bajo una <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">licencia de Creative Commons Reconocimiento-CompartirIgual 4.0 Internacional</a>.
#'

