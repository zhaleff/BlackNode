# Waybar → QuickShell

Rediseño completo de la waybar original en QML para [QuickShell](https://quickshell.outfoxxed.me/),
manteniendo la paleta Material-ish que ya usabas (`@define-color`) y la
estética de "islas" flotantes en cápsula.

## Instalación

```bash
mkdir -p ~/.config/quickshell
cp -r ./* ~/.config/quickshell/
qs -c ~/.config/quickshell
```

Para que Hyprland lo lance en vez de waybar, reemplaza tu `exec-once = waybar`
por:

```
exec-once = qs -c ~/.config/quickshell
```

## Dependencias

| Necesario para | Paquete |
|---|---|
| Iconos | `ttf-jetbrains-mono-nerd` (o cualquier Nerd Font, ajusta `font.family`) |
| Workspaces | Hyprland (usa `Quickshell.Hyprland`) |
| Reproductor multimedia | cualquier reproductor con soporte MPRIS |
| Volumen | PipeWire (`Quickshell.Services.Pipewire`) |
| Brillo | `brightnessctl` |
| Actualizaciones pacman | `pacman-contrib` (para `checkupdates`) |
| Actualizaciones AUR (opcional) | `paru` |
| Clima | `curl` (usa `wttr.in`, sin API key) |
| Menú de apagado | `wlogout` (cambia el comando en `QuickToggles.qml` si usas otro) |

## Estructura

```
shell.qml              # punto de entrada
Bar.qml                # PanelWindow, la barra en sí
Colors.qml + qmldir     # singleton de la paleta de colores
Pill.qml                # cápsula reutilizable (equivalente a .hollow-*)
modules/
  Workspaces.qml        # 1-5
  MediaControls.qml      # ⏮ ⏯ ⏭
  QuickToggles.qml        # brillo, volumen, red, apagado
  PackageUpdates.qml       # contador pacman/AUR
  ClockWidget.qml           # hora + icono sol/luna
  SystemStats.qml            # CPU, temperatura, disco
  WeatherWidget.qml            # clima actual
```

## Personalización

- **Colores**: edita `Colors.qml`, todos los módulos leen de ahí — nada de
  colores sueltos por archivo.
- **Radios/paddings de las cápsulas**: `Pill.qml` (`hPad`, `vPad`, y el
  `radius: height / 2` que reemplaza los `border-radius` asimétricos por
  segmento del CSS original).
- **Iconos**: son glyphs de Nerd Font en `\uXXXX`; cámbialos si prefieres
  otro set.
- Si no usas Hyprland, cambia `Workspaces.qml` (usa Sway/river IPC en su
  lugar) y quita el import de `Quickshell.Hyprland`.
