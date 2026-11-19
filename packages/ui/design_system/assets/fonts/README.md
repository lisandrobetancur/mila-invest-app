# Fuentes

| Familia | Archivo | Licencia | Origen |
|---|---|---|---|
| Manrope | `Manrope-Variable.ttf` | `Manrope-OFL.txt` (SIL OFL 1.1) | `google/fonts`, `ofl/manrope/Manrope[wght].ttf` |
| Inter | `Inter-Variable.ttf` | `Inter-OFL.txt` (SIL OFL 1.1) | `google/fonts`, `ofl/inter/Inter[opsz,wght].ttf` |

Las dos son **fuentes variables**: `google/fonts` ya no publica instancias
estáticas. Por eso los tokens de `app_typography.dart` declaran el peso dos
veces, con `fontWeight` (para el fallback del sistema) y con
`FontVariation('wght', ...)` (el eje real de la fuente variable).

Los archivos se copian tal como vienen, sin modificar, junto con su `OFL.txt`,
como pide la licencia.
