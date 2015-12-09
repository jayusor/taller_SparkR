# Instrucciones para el taller SparkR
#### Jorge Ayuso Rejas
##### VII JORNADAS DE USUARIOS DE R


1. Tener/Instalar Java.
2. Descargar/clonar este repositorio con los códigos: https://github.com/jayusor/taller_SparkR/archive/master.zip
3. Descargar Spark 1.5.1 y descomprimir en la misma carpeta que el zip anterior:
http://www.apache.org/dyn/closer.lua/spark/spark-1.5.1/spark-1.5.1-bin-hadoop2.6.tgz
4. Descargar y descomprimir el zip `datos_taller_sparkR.zip`: https://www.dropbox.com/s/0o024r5j2e0082g/datos_taller_sparkR.zip.
5. Instalar los siguientes paquetes de R:


```r
paquetes <- c("rmarkdown","magrittr")

if( any(!paquetes %in% rownames(installed.packages())) ){
  install.packages(paquetes[!paquetes %in% rownames(installed.packages())])
}
```

## Guiones del taller:

* [01_Intro.html](01_Intro.html)
* [02_Ejemplos_basicos.html](02_Ejemplos_basicos.html)
* [03_Ejemplo_Parquet.html](03_Ejemplo_Parquet.html)
* [04_Ejemplo_CSV.html](04_Ejemplo_CSV.html)
* [05_Ejemplos_Databricks.html](05_Ejemplos_Databricks.html)
* [06_Conclusiones.html](06_Conclusiones.html)


