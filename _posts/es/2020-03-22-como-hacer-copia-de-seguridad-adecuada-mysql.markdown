---
layout: post
lang: es
ref: how-to-properly-backup-mysql
title:  "Cómo hacer una copia de seguridad adecuada de MySQL"
date:   2020-03-22 22:21:55 +0300
image:  mysql.png
tags:   Backup Database Mysql
published: true
---

# Introducción

El objetivo de este post es tener una forma confiable de restaurar una base de datos MySQL a cualquier estado pasado dentro de la ventana de respaldo. Para esto configuraremos dos cosas:

* Volcados diarios de SQL de toda la base de datos
* Habilitar el registro binario de MySQL

# Crear el script de Dump

Crear el archivo "/etc/cron.weekly/mariadb-backup" con "sudo nano /etc/cron.weekly/mariadb-backup" y escribir en él:

```bash
#!/bin/bash
pass=mypass
threads=4
/usr/bin/mysqldump -u root -p$pass -A -R -E --triggers --single-transaction | /usr/bin/xz -T $threads > /var/log/mysql/bak_`/bin/date +%d_%b_%Y_%H_%M_%S`.sql.xz
```

Este script crea una copia de seguridad completa de la instalación de MySQL, y luego la ejecuta a través de **XZ** para la compresión. Asegúrate de cambiar `pass` y `threads` a la contraseña root de MySQL y el número de cores disponibles respectivamente.

También necesitamos establecer permisos en este archivo, cron no lo ejecutará si no están bien establecidos, además almacenaremos una contraseña en texto plano, por lo que es muy importante asegurarse de que nadie pueda leerlo aparte de root.

```bash
chmod 0711 /etc/cron.weekly/mariadb-backup   # -rwx--x--x 
```

# Habilitar log de MySQL binary

El binlog de MySQL es un registro de todos los cambios realizados en la base de datos, incluye herramientas muy útiles como la restauración a un punto específico en el tiempo, o incluso a una consulta SQL específica.

Para habilitar el binlog se necesita editar `/etc/mysql/my.cnf` y habilitar (o añadir):

```bash
server-id               = 1
log_bin                 = /var/log/mysql/mariadb-bin
log_bin_index           = /var/log/mysql/mariadb-bin.index
expire_logs_days        = 7
max_binlog_size         = 100M
binlog_format = MIXED
```

Preferentemente, establece el directorio binlog en el mismo que usa el script anterior, para que podamos hacer una copia de seguridad de un solo directorio.

Se necesita reiniciar mysql:

```bash
sudo service mysql restart
```

Si no se muestran errores al reiniciar, ¡estás listo! Sólo comprueba periódicamente que se están haciendo las copias de seguridad semanales.

# Restaurando

Estamos almacenando los binlogs sólo 7 días porque después de eso, nuestros mysqldumps deberían tenernos cubiertos. Así que la idea es restaurar primero el último dump, y luego "afinar" la posición exacta usando los registros binarios. Configura esta estrategia a tu gusto, puede ser de lunes a semana, de día a hora o ambos.
