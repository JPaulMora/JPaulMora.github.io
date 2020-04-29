---
layout: post
lang: es
ref: mining-xmr
title:  "Minería de Monero en Windows10"
date: 2020-03-27 22:56:45 -0600
image: xmr-mining.png
tags:   Monero de criptodivisa Minería de Windows10 
published: true
---

# Introducción

**Si ya tienes la dirección de la cartera, pasa a la parte minig [aquí](#XMR-Stak-RX)**

Las criptomonedas son sistemas sin algo de fondo de confianza, así que funcionen hacen uso de las matemáticas, de esa manera todas las partes pueden confiar (o comprobar) las matemáticas y no el uno al otro. Estas matemáticas son difíciles, pero son valiosas para la red porque validan todas las transacciones, por eso la solución de los problemas matemáticos se incentiva creando nuevas monedas, que se pagan a quien las resuelva correctamente. **Esto se llama minería** o **mining**.

En este tutorial, veremos como minar usando un software especializado llamado **xmr-stak-rx**. También puedes ver este tutorial en formato de vídeo:

<iframe src="https://www.youtube.com/embed/VYPzgN269zw" frameborder="0" allowfullscreen></iframe>

# Requisitos:

## Wallet de Monero

Lo primero y más importante es que necesitamos un lugar donde guardar lo que nos paguen. En términos criptográficos esto se llama una dirección de cartera (wallet address). Así que me adelantaré y descargaré el wallet oficial de la página [https://web.getmonero.org/downloads/](https://web.getmonero.org/downloads/) y obtendré la versión para mi sistema (en este caso, Windows 10).

![get Monero Downloads site](/images/monero-downloads.png)
*sitio de descargas de getMonero*

**Una vez descargado, es muy recomendable que verifiques la descarga siguiendo [este tutorial](https://getmonero.org/resources/user-guides/verification-windows-beginner.html)**

Así que el GUI oficial de Monero se ve así:

![Monero GUI](/images/monero-gui.png)
*Monero GUI*

Adelante y presiona *recibir*, esta página te mostrará un código QR y una larga cadena, esta es **la dirección de tu wallet**, cópiala en algún lugar, o deja el wallet abierto ya que lo usaremos en un rato.

## Piscina minera

A lo largo de los años, la minería ha sido cada vez más difícil de beneficiar, ya que se compite contra el mundo entero por una recompensa determinada, por eso nos unimos a otros y compartimos la recompensa, también conocida como minería en piscina (pool mining).

### Lugares para encontrar un pool:

* [Buscar Monero & MoneroMining subreddits](https://www.reddit.com/r/MoneroMining/search?q=new%20pool&restrict_sr=1)
* [Lista de la piscina de Monero.org](https://monero.org/services/mining-pools/)
* [Lista de estadísticas de piscinas mineras](https://miningpoolstats.stream/monero)
* Siempre puedes [Google It](https://www.google.com/search?hl=en&q=monero%20pools)

En mi caso usaré [SupportXMR](https://supportxmr.com), que se ve así:

![SupportXMR](/images/supportxmr.png)
*SupportXMR*

Generalmente, lo que quieres es encontrar su sección de ayuda/comienzo, ya que aquí es donde se mostrará la URL de la piscina y los puertos disponibles.

### Configuración del pool

![SupportXMR Ports](/images/supportxmr-ports.png)
*Puertos de apoyo XMR*

Seleccionaré el puerto de _diferencia más bajo_, 3333, y en caso de duda, usa el más bajo. También ten en cuenta que algunos puertos tienen funciones o características específicas, en este caso el puerto `9000` soporta SSL/TLS (no te preocupes si no sabes lo que eso significa). Lo que quieres es construir una cadena que tenga "the-pool-url:the-pool-port", así que para mí sería:

```
pool.supportxmr.com:3333
```

## XMR-Stak-RX

### Descarga

Ahora que tenemos todas las piezas necesarias, es hora de descargar el software de minería!

Iremos a [la página de lanzamientos de FireIce xmr-stak-rx](https://github.com/fireice-uk/xmr-stak/releases) y descargaremos la versión para Windows.

![Página de lanzamientos de xmr-stak](/images/xmrstak-releases.png)
*xmr-stak releases page*

### Ajustes

Para ejecutar esto, necesitas extraerlo, así que sácalo de la carpeta zip y colócalo en el lugar que quieras. En el videotutorial uso mi escritorio, pero podría estar en cualquier otro lugar como la carpeta de documentos. 

Ahora navega a la carpeta, y abre el único archivo de la aplicación (.exe), por defecto se llama "xmr-stak-rx.exe". El minero iniciará ahora el proceso de walkthrough donde nos pedirá todos nuestros detalles/configuración previamente adquiridos.

#### Advertencia de Antivirus

Descargar xmr-stak puede hacer que tu antivirus se vuelva loco, no te preocupes **No es un virus**, esto es porque los hackers usan este mismo software como una forma de sacar provecho de los ordenadores pirateados. Simplemente busca las instrucciones de la lista blanca de tu proveedor de antivirus.


![Mi configuración de xmr-stak](/images/xmr-setup.png)
*Mi configuración xmr-stak, el pool de notas y el puerto no son los del tutorial*

### Terminamos!

Una vez que termines el túnel, "XMR-STAK" comenzará la minería! Para detenerlo, cierra la ventana y para reiniciarlo haz clic en el `.exe` de nuevo y recogerá tus configuraciones anteriores.

## Arranque más rápido con BAT Script
### (Opcional)

Busca la carpeta que contiene el minero `.exe`, luego haz clic en la barra de ubicación y copia la ruta.

![Copiar la ruta de la ventana](/images/xmr-path.png)
*Copiar el camino desde la ventana*

Ahora abre **Block de Notas** y pégalo en un nuevo archivo de texto, luego añade el `.exe` así:

![Archivo del bloc de notas con la ruta a exe](/images/xmr-bat.png)
*Archivo de Block de Notas con ruta a exe*

Como pueden ver, añadí un ajuste especial `--noTest`, esto le dice al `xmr-stak` que se salte el auto test y vaya directamente a la minería.

Suerte!