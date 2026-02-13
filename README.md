#  Integridad de Datos en Big Data (HDFS)

En este repositorio he hecho la implementación del laboratorio
**Integridad de Datos en Big Data**, utilizando un ecosistema Hadoop
dockerizado proporcionado en el aula.

El objetivo del proyecto es verificar la **integridad de datos en
HDFS**, realizar auditorías, generar copias de seguridad, simular fallos
y recuperar el sistema garantizando que los datos permanecen íntegros.

------------------------------------------------------------------------

## Ejecución del Proyecto

Estos son los comandos ejecutados en orden para completar todo el
pipeline:

``` bash
# Preparación y despliegue
cd docker/clusterA
docker compose up -d --scale dnnm=3

# Ejecución de scripts de control
bash scripts/00_bootstrap.sh
bash scripts/10_generate_data.sh
bash scripts/20_ingest_hdfs.sh
bash scripts/30_fsck_audit.sh
bash scripts/40_backup_copy.sh
bash scripts/50_inventory_compare.sh
bash scripts/70_incident_simulation.sh
bash scripts/80_recovery_restore.sh
```

### 🔧 Variables de entorno utilizadas

``` bash
DT=YYYY-MM-DD        # Fecha de trabajo
NN_CONTAINER=namenode # Contenedor NameNode
```

------------------------------------------------------------------------

##  Servicios y UIs Utilizadas

Durante el proyecto se consultaron las siguientes interfaces para
validar el estado del clúster:

-   NameNode UI: http://localhost:9870\
-   ResourceManager UI: http://localhost:8088\
-   Jupyter (NameNode): http://localhost:8889

------------------------------------------------------------------------

##  Estructura del Repositorio

    docker/
     └── clusterA/        # Despliegue del clúster Hadoop

    scripts/              # Scripts del pipeline completo

    docs/                 # Documentación, enunciado y evidencias

    imagenes/             # Capturas generadas durante la práctica

    notebooks/            # Análisis opcional en Jupyter

------------------------------------------------------------------------

##  Pipeline Realizado (Paso a Paso)

### 1️ Arranque del clúster

Levanté el clúster Hadoop con:

-   1 NameNode\
-   1 ResourceManager\
-   3 DataNodes

``` bash
docker compose up -d --scale dnnm=3
```

------------------------------------------------------------------------

### 2️ Preparación del entorno

``` bash
bash scripts/00_bootstrap.sh
```

Este script creó la estructura base en HDFS:

-   /data\
-   /backup\
-   /audit

------------------------------------------------------------------------

### 3️ Generación e ingesta de datos

Generación local e ingesta en HDFS:

``` bash
bash scripts/10_generate_data.sh
bash scripts/20_ingest_hdfs.sh
```

Rutas utilizadas:

-   /data/logs/raw/dt=YYYY-MM-DD/\
-   /data/iot/raw/dt=YYYY-MM-DD/

------------------------------------------------------------------------

### 4️ Auditoría inicial (FSCK)

``` bash
bash scripts/30_fsck_audit.sh
```

Estado inicial del sistema:

-   HEALTHY\
-   0 bloques corruptos\
-   0 bloques faltantes

------------------------------------------------------------------------

### 5️ Copia de seguridad

``` bash
bash scripts/40_backup_copy.sh
```

Se realizó una copia completa de /data hacia /backup.

------------------------------------------------------------------------

### 6 Inventario origen vs destino

``` bash
bash scripts/50_inventory_compare.sh
```

Validación exitosa:

-   Coincide la cantidad de archivos\
-   Coincide el tamaño total\
-   No se detectan inconsistencias

------------------------------------------------------------------------

### 7️ Simulación del incidente

Se detuvo un DataNode para comprometer la replicación:

``` bash
docker stop clustera-dnnm-1
bash scripts/70_incident_simulation.sh
```

Resultado:

-   Estado: DEGRADED\
-   Bloques: UNDER_REPLICATED

El sistema detectó automáticamente la degradación.

------------------------------------------------------------------------

### 8️ Recuperación del sistema

Reinicio del nodo y ejecución de restauración:

``` bash
docker start clustera-dnnm-1
bash scripts/80_recovery_restore.sh
```

Informe final:

-   Estado: HEALTHY\
-   Replicación restaurada\
-   Sin pérdida de datos

------------------------------------------------------------------------

##  Métricas del Sistema

Durante la ejecución se monitorizó el consumo de recursos con:

``` bash
docker stats
```

Se observó actividad significativa en:

-   NameNode\
-   DataNodes (dnnm-1, dnnm-2, dnnm-3)

Las capturas se encuentran en:

docs/evidencias.md

------------------------------------------------------------------------

##  Conclusión

El sistema Hadoop demostró su capacidad de tolerancia a fallos:

-   Detectó la pérdida de un nodo en tiempo real\
-   Gestionó automáticamente la sub-replicación de bloques\
-   Recuperó la integridad total tras el reinicio del nodo

Los datos permanecieron íntegros y accesibles en todo momento.
