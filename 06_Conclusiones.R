#' ---
#' title: "Taller: SparkR (R on Spark) VI"
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



#' 
#' ## Conclusiones
#'
#' * Ya podemos usar Spark desde R un lenguaje sencillo y 
#' conocido para los que trabajamos con los datos.
#' * Por ahora SparkR es limitado y nos permite tratar con grandes `DataFrames` de una manera
#' parecida a `dplyr`.
#' * Si queremos trabajar con más funcionalidades de Spark hay que trabajar con otro lenguaje (¡Python es fácil!).
#' * Se espera que en futuras versiones el paquete sea más completo y poder usar más funcionalidades de Spark.
#'
#'
#' ## ¿Qué más cosas podemos hacer?
#' Además de los ejemplos que hemos visto en este taller podemos hacer algunas más cosas:
#' 
#' * Trabajar con tablas de Hive, y otros formatos de Hadoop como Avro de manera fácil.
#' * Conectarnos a bases de datos libres como MySQL o Postgres y también a 
#' comerciales como  Oracle o Teradata gracias a JDBC como si fuesen `Dataframes`.
#' * Usar R para muestras pequeñas y de manera exploratoria: *Boxplots*,
#'  gráficos de densidades...
#' * Ampliar el funcionamiento de Spark con paquetes: http://spark-packages.org.
#' * Hacer modelos `glm` de manera distribuida. Pero no nativamente, si no usando la librería MLlib de Spark:
#' https://spark.apache.org/docs/latest/sparkr.html#machine-learning.
#'
#'<br><br>
#'
#'---
#'
#'<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Licencia de Creative Commons" style="border-width:0" src="img/88x31.png" /></a><br />Este obra está bajo una <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">licencia de Creative Commons Reconocimiento-CompartirIgual 4.0 Internacional</a>.
#'

