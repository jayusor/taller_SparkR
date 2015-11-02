---
title: "Taller: SparkR (R on Spark)"
author: VII JORNADAS DE USUARIOS DE R
date: "Salamanca, 5 de noviembre de 2015</br>Jorge Ayuso Rejas"
output: 
 html_document:
   theme: cerulean
   highlight: tango
   css: img/base.css
---



# Instrucciones para el taller SparkR

## Opción 1 (Fácil): Valido para todos los sistemas operativos

1. Tener/Instalar VirtualBox: https://www.virtualbox.org/wiki/Downloads.
2. Descargar la máquina virtual del taller: **pendiente link**.

**Nota:** Se necesita como mínimo un ordenador de 64bits y 4gb de ram.

## Opción 2: Valido para Linux/Mac

1. Tener/Instalar Java.
2. Descargar y descomprimir el siguiente zip con los códigos y datos: **pendiente link**
3. Descargar Spark 1.5.1 y descomprimir en la misma carpeta que el zip anterior:
http://www.apache.org/dyn/closer.lua/spark/spark-1.5.1/spark-1.5.1-bin-hadoop2.6.tgz
4. Instalar los siguientes paquetes de R:


```r
paquetes <- c("knitr","magrittr")

if( any(!paquetes %in% rownames(installed.packages())) ){
  install.packages(paquetes[!paquetes %in% rownames(installed.packages())])
}
```


---
title: "README.R"
author: "jorge"
date: "Mon Nov  2 23:03:01 2015"
---
