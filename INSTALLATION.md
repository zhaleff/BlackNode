<p align="center">
  <img src="./Assets/BlackNode-Logo.png" width="100%" alt="BlackNode Banner">
</p>

###### _<div align="right"><sub>// by zhaleff · HollowSec</sub></div>_
<h1 align="center">BlackNode // Installation Guide</h1>
<div align="center">

<a href="https://github.com/zhaleff/BlackNode/stargazers"><img src="https://img.shields.io/github/stars/zhaleff/BlackNode?style=for-the-badge&logo=starship&color=C9CBFF&logoColor=C9CBFF&labelColor=302D41" alt="stars"></a>&nbsp;&nbsp;
<a href="https://github.com/zhaleff/BlackNode/forks"><img src="https://img.shields.io/github/forks/zhaleff/BlackNode?style=for-the-badge&logo=git&logoColor=f9e2af&label=Forks&labelColor=302D41&color=f9e2af" alt="forks"></a>&nbsp;&nbsp;
<a href="https://github.com/zhaleff/BlackNode/issues"><img src="https://img.shields.io/github/issues/zhaleff/BlackNode?style=for-the-badge&logo=github&logoColor=eba0ac&label=Issues&labelColor=302D41&color=eba0ac" alt="issues"></a>&nbsp;&nbsp;
<a href="https://github.com/zhaleff/BlackNode/commits/main"><img src="https://img.shields.io/github/last-commit/zhaleff/BlackNode?style=for-the-badge&logo=github&logoColor=white&label=Last%20Commit&labelColor=302D41&color=A6E3A1" alt="last commit"></a>&nbsp;&nbsp;
<a href="https://github.com/zhaleff/BlackNode/blob/main/LICENSE"><img src="https://img.shields.io/github/license/zhaleff/BlackNode?style=for-the-badge&logo=open-source-initiative&color=CBA6F7&logoColor=CBA6F7&labelColor=302D41" alt="license"></a>&nbsp;&nbsp;
<a href="https://discord.gg/hollowsec"><img src="https://img.shields.io/badge/chat-discord-5865F2?style=for-the-badge&logo=discord&logoColor=white&labelColor=302D41" alt="discord"></a>

</div>

#

<div align="center">

<a href="#overview"><kbd> <br> Overview <br> </kbd></a>&ensp;&ensp;
<a href="#requirements"><kbd> <br> Requirements <br> </kbd></a>&ensp;&ensp;
<a href="#automated-install"><kbd> <br> Automated Install <br> </kbd></a>&ensp;&ensp;
<a href="#script-internals"><kbd> <br> Script Internals <br> </kbd></a>&ensp;&ensp;
<a href="#post-install"><kbd> <br> Post-Install <br> </kbd></a>&ensp;&ensp;
<a href="https://discord.gg/hollowsec"><kbd> <br> Discord <br> </kbd></a>

</div>

#

<div align="center">
  <h3>The automated gateway to your new environment.</h3>
  <p><i>Understand what goes into your system before it gets deployed.</i></p>
</div>

#

<a id="overview"></a>
<img src="https://readme-typing-svg.herokuapp.com?font=Lexend+Giga&size=22&pause=1000&color=6CB6FF&vCenter=true&width=435&height=25&lines=OVERVIEW" width="435"/>

El script de instalación automatiza la configuración completa del entorno **BlackNode**. Se encarga de gestionar de forma nativa la actualización del sistema, la instalación del backend de paquetes (tanto oficiales como de AUR), el respaldo preventivo de tus archivos de configuración existentes y el despliegue estructurado de enlaces simbólicos (symlinks).

<div align="right">
  <br>
  <a href="#-by-zhaleff--hollowsec"><kbd> <br> 🡅 <br> </kbd></a>
</div>

#

<a id="requirements"></a>
<img src="https://readme-typing-svg.herokuapp.com?font=Lexend+Giga&size=22&pause=1000&color=6CB6FF&vCenter=true&width=435&height=25&lines=REQUIREMENTS" width="435"/>

Este instalador está diseñado y estructurado específicamente para entornos basados en **Arch Linux**.

> [!IMPORTANT]
> El script debe ser ejecutado obligatoriamente desde la raíz del repositorio clonado para que las rutas relativas (`BlackNode/Configs/`) se resuelvan correctamente.

> [!WARNING]
> Si ya cuentas con archivos locales en `~/.config/`, el instalador creará un respaldo automático en tu `$HOME` con la estampa de tiempo exacta antes de vincular el entorno de BlackNode.

<div align="right">
  <br>
  <a href="#-by-zhaleff--hollowsec"><kbd> <br> 🡅 <br> </kbd></a>
</div>

#

<a id="automated-install"></a>
<img src="https://readme-typing-svg.herokuapp.com?font=Lexend+Giga&size=22&pause=1000&color=6CB6FF&vCenter=true&width=435&height=25&lines=AUTOMATED+INSTALL" width="435"/>

Para inicializar el despliegue automático del entorno completo, clona el repositorio en tu espacio de usuario y ejecuta el punto de entrada:

```bash
git clone [https://github.com/zhaleff/BlackNode.git](https://github.com/zhaleff/BlackNode.git) $HOME/BlackNode
cd $HOME/BlackNode
bash path/to/install.sh
