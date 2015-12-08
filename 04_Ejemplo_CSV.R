#' ---
#' title: "Taller: SparkR (R on Spark) IV"
#' author: VII JORNADAS DE USUARIOS DE R
#' date: "Salamanca, 5 de noviembre de 2015</br>Jorge Ayuso Rejas"
#' output: 
#'  html_document:
#'    theme: cerulean
#'    highlight: tango
#'    css: img/base.css
#' ---

#+ include=FALSE
knitr::opts_chunk$set(cache=TRUE, fig.align='center', message=FALSE, messagewarning=FALSE)
rm(list = ls());gc()


#' ## Leer datos desde SparkR (CSV)
#' 
#' Ya hemos leído datos desde Parquet, una de las características de estos ficheros es que tienen
#' guardado unos "metadatos". Estos datos contienen información acerca de la tabla como el número de columnas
#' y de qué tipo (`string`, `integer`...) es cada columna.
#' 
#' Cuando leemos datos en texto plano como *CSV* no tenemos esa información en el propio archivo.
#' Por ejemplo en R cuando usamos la función `read.csv` y no definimos los tipos de las columnas, los estima
#' basándose en algunas líneas. Esto mismo lo podemos hacer con
#' Spark gracias a un paquete externo: http://spark-packages.org/package/databricks/spark-csv.
#'
#' 
#' Creamos el contexto de Spark pero añadiendo este paquete (se necesita internet)

.libPaths(c(file.path(Sys.getenv("SPARK_HOME"),"R/lib/"),.libPaths()))
library(SparkR)
library(magrittr)

sc <- sparkR.init(master = "local[*]",
                  appName = "Prueba IV: CSV",
                  sparkPackages = "com.databricks:spark-csv_2.11:1.2.0")

sqlContext <- sc %>% sparkRSQL.init()

#' <br>
#' Probamos si hemos cargado bien el paquete y si se puede leer un csv de manera cómoda:

df1 <- sqlContext %>% read.df("ejemplo_csv/modelo1/1.txt",
                              source = "com.databricks.spark.csv",
                              header="true",
                              inferSchema = "true"
                              )

df1 %>% printSchema()
df1 %>% head
df1 %>% count

#' Con la opción `inferSchema = "true"` conseguimos que automáticamente detecte
#' los tipos de los campos.
#' 
#' ### Ejercicio
#' 
#' En el siguiente ejercicio vamos a leer y unir varios csv. En la carpeta
#' `ejemplo_csv` tenemos la salida de tres modelos (ficticios) que se han realizado previamente:

list.files("ejemplo_csv",full.names = T)

#' Para cada una de estas carpetas hay dos archivos con el mismo
#' formato, cada archivo contienen líneas distintas y la unión de los dos
#' forman la salida de cada modelo:

list.files("ejemplo_csv",full.names = T,recursive = T)

#' Queremos leer todos los archivos y construir un único `DataFrame` con todas las columnas.
#' <br><br>
#' 
#' Como hemos visto en el ejercicio anterior, es normal tener los datos en varios archivos y
#' Spark está diseñado para leer todos a la vez. Por ejemplo si
#' leemos la carpeta del `modelo1` nos lee todos los archivos que contiene,
#' en este caso son dos pero podrían ser muchos más:

sqlContext %>% read.df("ejemplo_csv/modelo1",
                      source = "com.databricks.spark.csv",
                      header="true",
                      inferSchema = "true"
                      ) %>% count

#' Vamos a crear una función `leer`, la variable de entrada será el directorio que tiene que leer,
#' y devolverá un `DataFrame` resultante de leer los archivos del interior de la carpeta
#' y renombrar las columnas para poder identificarlas después. Por ejemplo para el `modelo1`,
#' renombramos las columnas de la siguiente manera:
#' 
#' $$
#' \begin{align*}
#' \text{user_id} &\longrightarrow \text{user_id}  \\
#' \text{predict} &\longrightarrow \text{modelo1_predict}  \\
#' \text{p0} &\longrightarrow \text{modelo1_p0}  \\
#' \text{p1} &\longrightarrow \text{modelo1_p1}
#' \end{align*}
#' $$


leer <- function(x){
  sqlContext %>% read.df(x,
                         source = "com.databricks.spark.csv",
                         header="true",
                         inferSchema = "true"
                        ) %>% 
    withColumnRenamed("predict",paste0(basename(x),"_predict")) %>% 
    withColumnRenamed("p0",paste0(basename(x),"_p0")) %>% 
    withColumnRenamed("p1",paste0(basename(x),"_p1"))
}

#' Aplicamos la función a las tres carpetas, con `lapply`:
lista_df <- list.files("ejemplo_csv",full.names = T) %>% lapply(leer)

#' <br>
#' El resultado es una lista con tres elementos, cada elemento es un `DataFrame` de Spark
#' con el resultado de leer los ficheros y renombras las columnas:

str(lista_df)

lista_df[[2]]
lista_df[[2]] %>% head

#' <br>
#' Ahora queremos ir uniendo estos `DataFrames` por la columnas en común: `user_id`, hasta conseguir
#' un único `DataFrame`. Veamos cómo podemos usar la función `merge` en Spark de manera similar
#' a R:

merge(lista_df[[1]],
     lista_df[[2]],
     lista_df[[1]]$user_id==lista_df[[2]]$user_id
     ) %>% head

#' Funciona, pero el campo `user_id` aparece repetido en el `DataFrame`
#' resultante. Eso es un problema para después
#' seguir uniendo ya que al estar repetida la columna habrá conflictos al seguir trabajando con 
#' este `DataFrame` (esto está solucionado
#' en la versión de python y scala pero no en la de R por ahora).
#' 
#' <br>
#' Construimos una segunda función `unir`, que haga el `merge` que necesitamos, pero que primero
#' renombre una de las columnas `user_id` y así podamos obtener el `DataFrame` de la unión
#' pero sin repetir esta columna:

unir <- function(x,y){
  y_aux  <- y %>% withColumnRenamed("user_id","user_id_aux")
  unido  <- x %>% merge(y_aux,x$user_id==y_aux$user_id_aux)
  quiero <- setdiff(names(unido),"user_id_aux")
  unido %>% select(as.list(quiero))
}

#' Probamos su funcionamiento:
unir(lista_df[[1]],lista_df[[2]])

#' Pata terminar, queremos unir la lista de `DataFrame` con esta función.
#' En nuestro caso solo tenemos 3 pero queremos hacerlo de una manera que funcione igual 
#' para cuando la lista sea más grande. En R este problema podemos solucionarlo con la función 
#' `Reduce` (ver por ejemplo: http://stackoverflow.com/a/17171655).    
#' <br>
#' Con `Reduce` usamos la función `unir` de manera recursiva para todos los
#'  elementos de la lista.

df_unido <- Reduce(unir,lista_df) %>% cache
df_unido
df_unido %>% count()
df_unido %>% head

#' De este modo hemos conseguido leer todos los archivos y conseguir un
#' único `DataFrame` con  toda la información.
#' 
#' <br>
#' 
#' Para terminar, podemos usar `crosstab` para hacer una tabla de conteo. Por ejemplo entre
#' las predicciones del modelo1 y las del modelo2, y después hacer un gráfico:

conteo <- df_unido %>% crosstab("modelo1_predict","modelo2_predict")
conteo

#' Manipulamos el `data.frame` local para usar la función `mosaic`:

rownames(conteo) <- paste0("modelo1_",conteo[,1])
conteo <- conteo[,-1]
colnames(conteo) <- paste0("modelo2_",colnames(conteo))

#' ordeno:
conteo<-conteo[order(rownames(conteo)),order(colnames(conteo))]
conteo

#' y grafico:
mosaicplot(conteo,color=TRUE,main = "modelo1 vs modelo2")


#' Cuando hemos terminado cerramos Spark:
sparkR.stop()



#'
#'<br><br>
#'
#'---
#'
#'<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Licencia de Creative Commons" style="border-width:0" src="img/88x31.png" /></a><br />Este obra está bajo una <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">licencia de Creative Commons Reconocimiento-CompartirIgual 4.0 Internacional</a>.
#'

