---
layout: post
lang: es
ref: bkp-linux-duplicati
title:  "Hacer copia de seguridad de Linux con Duplicati"
date:   2020-03-22 18:20:02 +0300
image:  duplicati-header.jpg
tags:   Copia Seguridad Linux Herramientas 
published: true
---

# Introducción

**Sólo hay dos tipos de personas: los que tienen copias de seguridad y los que _las tendrán_. ¿Cuál de ellos eres tú?**

En el mundo moderno hay tantas herramientas y tecnologías a nuestra disposición que a menudo olvidamos cuán a menudo todo falla, no se trata de si algo va a fallar o no, sino de _cuándo_ va a fallar.

Sólo el año pasado, dos grandes eventos mostraron que incluso los mejores no son inmunes a los eventuales fallos tecnológicos. Primero, la alta congestión en el área Este de los Estados Unidos [causó un apagón en la nube de Google](https://www.theverge.com/2019/6/2/18649635/youtube-snapchat-down-outage) que derribó a Youtube, Snapchat, Shopify y otros. Luego, sólo un mes más tarde, el gigantesco CDN y el proveedor de proxy Cloudflare que [impulsó por error una regla WAF que consumió la totalidad de sus CPU](https://blog.cloudflare.com/details-of-the-cloudflare-outage-on-july-2-2019/), resultando en interrupciones en todo el mundo.

Lo más probable es que tú y yo tengamos menos redunancia que Google o Cloudflare, por lo que nuestras posibilidades de que algo fatal le ocurra a nuestros servidores o a nuestros datos son mayores, por lo que nuestras copias de seguridad son mucho más valiosas por el mismo orden de magnitud.

# Asunciones

* Este tutorial se hizo con y para: Ubuntu 18.04.3 LTS
* Vamos a hacer copias de seguridad instalaciones de Wordpress (WordOps) y MySQL.
* No tienes miedo de usar la línea de comandos.

# Instalación

Activa un shell, primero vamos a descargar Duplicati de https://www.duplicati.com/download, Duplicati es multiplataforma así que también puedes saltarte los pasos de Ubuntu e ir directamente a Duplicati Setup.

#### Descarga Duplicati para Debian/Ubuntu usando using wget

```bash
wget https://updates.duplicati.com/beta/duplicati_2.0.5.1-1_all.deb
```

#### Instala MONO

Duplicati está escrito en .NET framework, así que instalaremos el paquete `mono` desde su repositorio oficial. **Esto toma algo de tiempo**

```bash
# Añadir el PGP key del repositorio
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF

# Add mono's official repo to /sources.list.d
echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list

# Actualizamos con el nuevo repositorio recién añadido.
sudo apt update

# Instalamos mono y otras dependencias
sudo apt install mono-devel gtk-sharp2 libappindicator0.1-cil libappindicator1 libdbusmenu-glib4 libdbusmenu-gtk4 libindicator7 libmono-2.0-1
```

#### Instalamos Duplicati deb

Nuestro siguiente paso es instalar el duplicati deb, esta primera vez fallará, pero le dirá a `apt` sobre las dependencias requeridas.

```bash
# Instalamos usando DPKG
sudo dpkg -i duplicati_2.0.5.1-1_all.deb
```

En este punto hemos terminado de instalar Duplicati, a continuación vamos a configurar un servicio `systemd` para que se inicie automáticamente.

### Creamos un Systemd service

Asegúrate de que tu `lib/systemd/system/duplicati.service` se vea así, y sea propiedad de la raíz.

```
[Unit]
Description=Duplicati daemon and web-server
After=network.target

[Service]
Nice=19
IOSchedulingClass=idle
EnvironmentFile=-/etc/default/duplicati
ExecStart=/usr/bin/duplicati-server $DAEMON_OPTS
Restart=always

[Install]
WantedBy=multi-user.target
```

The only thing left to do is to start it 

```bash
# Iniciamos el servicio
sudo service duplicati start

# Chequeamos que esté corriendo
sudo service duplicati status
```

En mi caso, `status` se muestra:

```
● duplicati.service - Duplicati web-server
   Loaded: loaded (/lib/systemd/system/duplicati.service; disabled; vendor preset: enabled)
   Active: active (running) since Sun 2020-03-22 19:34:25 MDT; 2s ago
 Main PID: 56770 (mono)
    Tasks: 16 (limit: 9830)
   CGroup: /system.slice/duplicati.service
           ├─56770 DuplicatiServer /usr/lib/duplicati/Duplicati.Server.exe
           └─56774 /usr/bin/mono-sgen /usr/lib/duplicati/Duplicati.Server.exe
           
Mar 22 19:34:25 ubuntu systemd[1]: Started Duplicati web-server.
```

## MySQL binary log (Opcional)

El binlog de MySQL es un registro de todos los cambios realizados en la base de datos, incluye herramientas muy útiles como la restauración a un punto específico en el tiempo, o incluso a una consulta SQL específica. [Revisa mi otro post sobre como habilitarlo]({% post_url 2020-03-22-como-hacer-copia-de-seguridad-adecuada-mysql %}), luego regresa para que podamos hacer una copia de seguridad de esa carpeta también.

# Configuración

Ahora, para acceder al servidor web necesitamos hacer algún reenvío de puertos (port forwarding), el servidor de configuración de Duplicati sólo está disponible localmente por razones de seguridad. Para ello nos desconectaremos de ssh e iniciaremos sesión usando algunas banderas (flags) especiales:

```bash
ssh -L 1234:localhost:8200 DW
```

Este comando significa que el puerto **1234** de tu computadora será reenviado al **localhost:8080** en la máquina remota, puedes cambiar este primer número (1234) a lo que quieras.

En este caso `DW` es el anfitrión con el que me estoy conectando, en tu caso podría parecer `root@190.160.1.123`. Haré una publicación en el blog sobre cómo configurar un alias para tus anfitriones.

Abre tu navegador favorito y ve a: <a href="http://localhost:1234" target="_blank">http://localhost:1234</a> (si tu puerto es 1234 dale click al link).

Esto le mostrará la interfaz web de Duplicati:

![Duplicati en el navegador web](/images/duplicati-config.png)

### Añadir Copia de Seguridad

![Duplicati añadir una nueva copia de seguridad](/images/duplicati-add-backup.png)

Normalmente quieres tener múltiples fuentes de respaldo, recomiendo seguir la [estrategia de respaldo 3-2-1](https://www.backblaze.com/blog/the-3-2-1-backup-strategy/). Básicamente, la estrategia consiste en tener una copia de seguridad fácilmente recuperable **más una copia de seguridad externa**, por esta razón estoy haciendo una copia de seguridad en [Dropbox](https://dropbox.com). Revisa la [Lista de Proveedores de Almacenamiento](https://duplicati.readthedocs.io/en/stable/05-storage-providers/) para ver qué te conviene.

### Fuente de la Información

Estas son las carpetas que estoy agregando a la copia de seguridad, ya que sólo hospedo sitios de Wordpress. Asegúrate de hacer una copia de seguridad de todo lo que usa tu aplicación.

```
/etc/mysql/
/etc/nginx/
/etc/wo/
/var/www/
/var/log/mysql/
```

Cambie la sección de filtros a texto, y puede pegar mis reglas como línea de base:

```
-[.*\.DS_Store]
-[./*.gz]
-[.*\.tmp]
-[.*/?node_modules.*]
-[.*/presta/.*/?cache/\S+]
-[.*/wordpress/.*/?cache/\S+]
-[.*/wordpress/.*app/themes/.*dist.*]
-[.*/wordpress/.*app/themes/.*vendor/.*]
-[.*/wordpress/.*vendor/.*]
-[.*/wordpress/.*fly-images/.*]
-[.*/ruby/.*log/\S+]
-[.*/ruby/.*tmp/\S+]
```

Puedes leer [este post](https://www.duplicati.com/articles/Filters/) en filtros para más información y ejemplos.

![Duplicati añadir nueva copia de seguridad](/images/duplicati-source-data.png)

Como Duplicati trabaja con [copias de seguridad incrementales](https://en.wikipedia.org/wiki/Incremental_backup), creo que es seguro para mi servidor hacer copias de seguridad cada hora sin pérdida de rendimiento y sin ocupar mucho espacio.

![Copias de seguridad por hora 24/7](/images/duplicati-schedule.png)

Pasos Finales

![Duplicati Opciones Finales](/images/duplicati-options.png)

# Realizar copia de seguridad

![Duplicati realizar copia de seguridad](/images/duplicati-start.png)

¡Eso es! Asegúrate de comprobar periódicamente si las copias de seguridad están funcionando, y haz pruebas de restauración de vez en cuando para comprobar la integridad.

Más información: [https://duplicati.readthedocs.io/en/latest/](https://duplicati.readthedocs.io/en/latest/)
