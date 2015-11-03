#' ---
#' title: "Taller: SparkR (R on Spark) III"
#' author: VII JORNADAS DE USUARIOS DE R
#' date: "Salamanca, 5 de noviembre de 2015</br>Jorge Ayuso Rejas"
#' output: 
#'  html_document:
#'    theme: cerulean
#'    highlight: tango
#'    css: img/base.css
#' ---

#+ include=FALSE
knitr::opts_chunk$set(cache=TRUE,fig.align='center',message=FALSE,messagewarning=FALSE)
rm(list = ls());gc()


#' ## Leer datos desde SparkR
#' 
#' En los ejemplos que hemos visto hasta ahora, hemos creado un `DataFrame`
#'  de Spark desde un `data.frame` de R. Pero eso no suele ser así en general,
#'  ya que los datos que solemos trabajar con Spark suelen ser demasiados
#'  grandes para R (por ese motivo usamos Spark).    
#'  
#'  Spark puede leer cualquier formato que pueda leer Hadoop/HDFS y
#'  conectarse a bases de datos por medio de JDBC.
#'  Vamos a ver dos casos: Parquet y CSV.
#'  
#' ## Ejemplo con datos en Parquet
#' 
#' Parquet es un formato de tipo columnar diseñado para el ecosistema *bigdata*.   
#' 
#' <center>
#' ![parquet](img/parquet_logo.png)
#' </center>
#' 
#' > Apache Parquet is a columnar storage format available to any 
#' project in the Hadoop ecosystem, regardless of the choice of data
#'  processing framework, data model or programming language.
#'       
#' Más información: https://parquet.apache.org/.   
#' <br>
#' 
#' 
#' Vamos a leer una tabla generada aleatoriamente y  guardada en ``categorias.parquet``. Esta carpeta
#' contienen varios archivos, esto es normal en este mundo ya
#'  que al trabajar en paralelo y varios ordenadores se suele guardar los datos
#' en trozos.

list.files("categorias.parquet")[1:10]

#' <br><br>
#' Creamos el contexto de Spark para empezar a trabajar:

.libPaths(c(file.path(Sys.getenv("SPARK_HOME"),"R/lib/"),.libPaths()))
library(SparkR)
library(magrittr)
sc <- sparkR.init(master = "local[*]",appName = "Prueba III: Parquet")
sqlContext <- sc %>% sparkRSQL.init()

#' <br>
#' Spark ya tiene las librerías necesarías para leer archivos de tipo Parquet, así que 
#' la manera de leer es muy fácil:


meta <- sqlContext %>% read.df("categorias.parquet")
meta %>% printSchema
meta %>% head

#'
#' <br>
#' 
#' ### Ejercicio
#' Queremos *pivotar* esta tabla. Es decir, conseguir una tabla nueva, donde tengamos
#' una fila por cada `user_id` distinto y tantas columnas como número de categorías distintas para
#' cada una de las tres variables.
#' Esto en R lo haríamos con las funciones `reshape` o `spread` del paquete `tidyr`. Veamos una manera
#' de hacerlo en Spark basándonos en SQL.
#'
#' <br>
#'
#' Primero eliminamos las filas con la categoría vacia y cacheamos el `DataFrame` resultante:

meta <- meta %>% filter(meta$category!="") %>% cache()

#' Veamos cuantas filas tenemos y cuantos `user_id` distintos (el número de filas del `DataFrame` que
#' queremos construir):

meta %>% agg(count(meta$user_id),countDistinct(meta$user_id)) %>% collect()

#' Con `collect` convertimos el `DataFrame` de Spark a un `data.frame` de R.
#' Mucho **cuidado** al usar esta función, porque podemos quedarnos sin memoria si el 
#' `DataFrame` es grande.

categorias <- meta %>% select("category") %>% distinct() %>% collect()
categorias$category

#' Ayudándonos de R, vamos a crear una query  de SQL para crear las columnas
#' de nuestro nuevo `DataFrame` esto lo hacemos con la sentencia `CASE`:

categorias$category %>% 
  sapply(function(x){
    paste0("case when category='",x,"' then variable",1:3,
           " else 0 end as variable",1:3,"_",x %>% tolower(),collapse = ",")
  }) %>% 
  paste(collapse = ", ") %>% 
  paste("select user_id,",.,"from meta") -> query

query

#' Una vez tenemos construida la primera query, registramos el `DataFrame` para
#' poder ejectuarla (si no, no se podría procesar el trozo de "`from meta`"):

meta %>% registerTempTable("meta")
expandido <- sqlContext %>% sql(query)

#' Como ya sabemos, no se ha procesado todavía toda la query porque no ha sido necesario
#' (evaluación perezosa).    
#' <br>
#' Construimos la segunda query necesaria para terminar nuestro ejercicio,
#' necesitamos sumar todas las columnas agrupando por `id_user` y de esta manera conseguir
#' el `DataFrame` que buscamos:
#' 

names(expandido)[-1] %>% 
{paste("select user_id,",paste0("sum(",.,") ",.,collapse = ", ")
         ,"from expandido group by user_id")} -> query2

#' Registramos la tabla intermedia y ejecutamos la segunda query, además cacheamos esta tabla
#' para explorarla:

expandido %>% registerTempTable("expandido")
final <- sqlContext %>% sql(query2) %>% cache
final

final %>% count
# final %>% head

#' Cuando hemos terminado cerramos Spark:
sparkR.stop()

#'
#'<br><br>
#'
#'---
#'
#'<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Licencia de Creative Commons" style="border-width:0" src="img/88x31.png" /></a><br />Este obra está bajo una <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">licencia de Creative Commons Reconocimiento-CompartirIgual 4.0 Internacional</a>.
#'

