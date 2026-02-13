# Evidencias – Integridad de Datos en HDFS  
**Autora:** Sherezade  
**Fecha:** 2026-02-13  

---

## 1) NameNode UI (9870)

### 1.1 DataNodes vivos
PON AQUÍ LA CAPTURA DE LA WEB DEL NAMENODE  
(URL: http://localhost:9870)
![docker stats durante replicación](./imagenes/Imagen1.png)
![docker stats durante replicación](./imagenes/Imagen2.png)
Debe verse:
- Los 3 DataNodes: `clustera-dnnm-1`, `clustera-dnnm-2`, `clustera-dnnm-3`
- Estado: Live
- Capacidad total y usada

---

## 2) Auditoría fsck

### 2.1 Auditoría inicial
**Captura o enlace de `/audit/fsck_2026-02-13.txt`:**  
![Auditoria inicial](./imagenes/Imagen3.png)


## 3) Backup + validación

### 3.1 Inventario origen vs destino
![Validacion + backup](./imagenes/inventory.png)

### 3.2 Validación

- Tamaño en `/data`: 757826 bytes  
- Tamaño en `/backup`: 757826 bytes  
- **Los tamaños coinciden → Copia correcta**


---

## 4) Incidente + recuperación

### 4.1 Simulación del incidente
- Se detuvo el DataNode: `docker stop clustera-dnnm-1`
- Fecha/hora: 2026-02-13  
- Efecto esperado: bloques **UNDER_REPLICATED**

**Captura del comando o del contenedor detenido:**  
![Incidente + deteccion del incidente](./imagenes/Incident.png)

### 4.2 Detección del incidente
Lo hice todo seguido a la hora de hacerlo asi que esta en una misma captura

Resumen:
- UNDER_REPLICATED: Sí  
- CORRUPT: 0  
- MISSING: 0  
- Estado: **DEGRADED**

### 4.3 Recuperación
- Se arrancó el DataNode: `docker start clustera-dnnm-1`
- Se ejecutó `80_recovery_restore.sh`

![Recuperación](./imagenes/4.3_Recuperacion.png)

Resumen:
- UNDER_REPLICATED: 0  
- CORRUPT: 0  
- MISSING: 0  
- Estado final: **HEALTHY**

---

## 5) Métricas

### 5.1 docker stats durante replicación/copia
Durante la copia/replicación ejecuté `docker stats` para monitorizar el uso de recursos.
Se observa un incremento moderado en CPU y E/S de disco en el NameNode y los DataNodes,
coincidiendo con la operación de backup/recuperación. El resto de contenedores mantienen
un uso estable.
![docker stats durante replicación](./imagenes/docker_stats.png)

PON AQUÍ LAS CAPTURAS DE `docker stats`  
(idealmente durante backup o durante la recuperación)

## 5.2 Tabla de tiempos

| Proceso                         | Tiempo aproximado |
|---------------------------------|-------------------|
| Generación de datos             | 1–2 segundos      |
| Ingesta en HDFS                 | 3–5 segundos      |
| Auditoría fsck inicial          | 1–2 segundos      |
| Backup (copia a /backup)        | 2–4 segundos      |
| Inventario (comparación)        | 1 segundo         |
| Simulación de incidente         | 10–12 segundos    |
| Recuperación del DataNode       | 20–25 segundos    |
| Auditoría fsck final            | 1–2 segundos      |


---

# Conclusión final
El sistema pasó por todo el ciclo completo:
- Generación  
- Ingesta  
- Auditoría  
- Backup  
- Comparación  
- Incidente  
- Recuperación  

Y terminó en estado **HEALTHY**, demostrando que HDFS mantiene la integridad de los datos incluso ante fallos de nodos.

