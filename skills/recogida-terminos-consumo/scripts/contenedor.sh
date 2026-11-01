#!/usr/bin/env bash
# Ejecuta un comando de la lista cerrada de SKILL.md en el contenedor de la skill.
#
#   contenedor.sh CARPETA -- python3 -I <ruta del repo>/scripts/recoger.py ...
#   contenedor.sh --solo-lectura -- python3 -I <ruta del repo>/scripts/validate_result.py ...
#
# Las rutas del comando son relativas a la raíz del repositorio. El repositorio se monta
# de solo lectura en /w; solo CARPETA, que tiene que estar dentro del repositorio, se monta
# con escritura. El proceso corre con el usuario de quien llama, así que lo que escribe
# no queda de root. La imagen se construye la primera vez desde el Dockerfile de al lado.
set -euo pipefail
IMAGEN=tfm-recogida:0.3
AQUI="$(cd "$(dirname "$0")" && pwd)"
RAIZ="$(git -C "$AQUI" rev-parse --show-toplevel)"
[ $# -ge 3 ] || { echo "uso: contenedor.sh CARPETA|--solo-lectura -- comando ..." >&2; exit 2; }
MONTAJES=(-v "$RAIZ":/w:ro)
if [ "$1" != "--solo-lectura" ]; then
  ESCRIBE="$(realpath -m "$1")"
  case "$ESCRIBE" in
    "$RAIZ"/?*) mkdir -p "$ESCRIBE"; MONTAJES+=(-v "$ESCRIBE":"/w/${ESCRIBE#"$RAIZ"/}") ;;
    *) echo "contenedor.sh: $ESCRIBE no es una carpeta dentro de $RAIZ" >&2; exit 2 ;;
  esac
fi
shift
[ "$1" = "--" ] || { echo "contenedor.sh: falta -- antes del comando" >&2; exit 2; }
shift
docker image inspect "$IMAGEN" >/dev/null 2>&1 || docker build -q -t "$IMAGEN" "$AQUI" >/dev/null
exec docker run --rm --user "$(id -u):$(id -g)" -e PYTHONDONTWRITEBYTECODE=1 -e HOME=/tmp \
  "${MONTAJES[@]}" -w /w "$IMAGEN" "$@"
