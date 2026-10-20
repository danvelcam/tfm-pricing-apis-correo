#!/usr/bin/env python3
"""
Estación de revisión de Datasheets ACM2YAML v0.3 (HTML autocontenido).

Para cada dato de la datasheet muestra: valor, semáforo, fuente(s) [Fn] con su
cita literal, y el comentario del YAML. Añade un informe de validación del
formato contra la guía v0.3 del repo `apis_consumption_model`. El autor marca cada
elemento OK / NO / Duda, anota, y exporta un resumen para pegar en el chat.

Uso:
    python3 gen_datasheet_viewer.py salida.html datasheet.yaml fuentes.md [Título] [cambios.json]

cambios.json (opcional) marca la re-revisión: {"banner": "texto…",
"changed": {"<título de fila>": "qué cambió"}} — las filas afectadas salen
con insignia 🆕 y el banner lista los cambios de la pasada.

Sin localStorage (los artefactos no lo admiten): exportar antes de cerrar.
"""
import sys, json, re, html
from ruamel.yaml import YAML

SEMAFOROS = {'🟢': 'verde', '🟡': 'ambar', '🔴': 'rojo'}
PERIOD_UNITS = {'SECOND', 'SEC', 'MIN', 'MINUTE', 'HOUR', 'DAY', 'WEEK', 'MONTH', 'YEAR'}
WINDOW_TYPES = {'rolling', 'fixed_utc_midnight', 'fixed_billing_cycle'}
TYPES = {'full_saas', 'partial_saas', 'api_first'}
KNOWN_UNITS = {'requests', 'emails', 'sms', 'tokens', 'records', 'gb', 'MBs',
               'hours', 'minutes'}


# ----------------------------------------------------------------- fuentes.md
def parse_fuentes(path):
    txt = open(path, encoding='utf-8').read()
    fuentes = {}
    for m in re.finditer(r'^## \[(F\d+)\]\s*(.+?)$([\s\S]*?)(?=^## |\Z)',
                         txt, re.M):
        fid, titulo, cuerpo = m.group(1), m.group(2).strip(), m.group(3)
        url = re.search(r'\*\*URL:\*\*\s*(\S+)', cuerpo)
        fecha = re.search(r'\*\*Fecha de acceso:\*\*\s*([^\n]+)', cuerpo)
        citas = re.findall(r'^\s{2}- (.+?)(?=^\s{2}- |^\-|\Z|^##|^\*\*)',
                           cuerpo, re.M | re.S)
        obs = re.search(r'\*\*Observaci[oó]n(?:es)?(?: cr[ií]tica)?:\*\*\s*([\s\S]+?)(?=\n\n|\Z)',
                        cuerpo)
        fuentes[fid] = {
            'titulo': titulo,
            'url': url.group(1) if url else '',
            'fecha': fecha.group(1).strip() if fecha else '',
            'citas': [re.sub(r'\s+', ' ', c).strip() for c in citas],
            'obs': re.sub(r'\s+', ' ', obs.group(1)).strip() if obs else '',
        }
    nf = re.search(r'^## Fuentes buscadas y NO encontradas[\s\S]*', txt, re.M)
    no_encontradas = []
    if nf:
        for row in re.findall(r'^\|\s*(.+?)\s*\|\s*(.+?)\s*\|$', nf.group(0), re.M):
            if row[0].startswith('Dato') or set(row[0]) <= {'-', ' '}:
                continue
            no_encontradas.append({'dato': row[0], 'resultado': row[1]})
    return fuentes, no_encontradas


# ------------------------------------------------------------ datasheet.yaml
def load_yaml(path):
    yaml = YAML()
    data = yaml.load(open(path, encoding='utf-8'))
    raw = open(path, encoding='utf-8').read().splitlines()
    return data, raw


def line_comment(raw, ln):
    """Comentario '#...' de una línea (0-based), sin el semáforo duplicado."""
    if ln is None or ln >= len(raw):
        return ''
    m = re.search(r'#\s*(.*)$', raw[ln])
    return m.group(1).strip() if m else ''


def block_comments(raw, start, end):
    """Líneas de comentario completas dentro de un rango (bloques 🔴 etc.)."""
    out = []
    for i in range(start, min(end, len(raw))):
        s = raw[i].strip()
        if s.startswith('#'):
            out.append(s.lstrip('# ').rstrip())
    return out


def refs_of(txt):
    return sorted(set(re.findall(r'\[(F\d+)\]', txt)))


def clean_comment(txt):
    """Quita semáforo y refs [Fn] del texto (ya se muestran como chips)."""
    t = re.sub(r'[🟢🟡🔴]', '', txt)
    t = re.sub(r'\[F\d+\]', '', t)
    return re.sub(r'\s+', ' ', t).strip(' ·—-')


def semaforo_of(txt):
    for e in ('🔴', '🟡', '🟢'):
        if e in txt:
            return e
    return ''


def leaf(raw, node, key):
    """(valor, línea) de una clave escalar en un mapping ruamel."""
    if node is None or key not in node:
        return None, None
    ln = node.lc.data.get(key, [None])[0] if hasattr(node, 'lc') else None
    return node[key], ln


def fmt(v):
    if v is None:
        return '∅ vacío'
    if isinstance(v, bool):
        return str(v).lower()
    return str(v)


# ------------------------------------------------------------------ validador
class V:
    def __init__(self):
        self.checks = []

    def add(self, level, path, msg):
        self.checks.append({'level': level, 'path': path, 'msg': msg})

    def ok(self, p, m): self.add('ok', p, m)
    def warn(self, p, m): self.add('warn', p, m)
    def err(self, p, m): self.add('error', p, m)


def validar(d, fuentes, yaml_text):
    v = V()
    # Cabecera
    for req in ('associated_saas', 'type', 'url', 'syntax_version', 'date',
                'currency', 'consumption_units'):
        if d.get(req) is None:
            v.err('cabecera', f'Falta el campo obligatorio `{req}`')
    if d.get('type') in TYPES:
        v.ok('type', f'`type: {d["type"]}` ∈ {{full_saas, partial_saas, api_first}}')
    elif d.get('type'):
        v.err('type', f'`type: {d["type"]}` no es un valor válido de la guía')
    if str(d.get('syntax_version')) == '0.3':
        v.ok('syntax_version', 'Versión de sintaxis 0.3, la de la guía en `main`')
    else:
        v.err('syntax_version', f'`syntax_version: {d.get("syntax_version")}` ≠ 0.3')
    if re.fullmatch(r'\d{4}-\d{2}-\d{2}', str(d.get('date', ''))):
        v.ok('date', f'Fecha en formato YYYY-MM-DD ({d["date"]})')
    else:
        v.err('date', f'`date: {d.get("date")}` no cumple YYYY-MM-DD')
    if re.fullmatch(r'[A-Z]{3}', str(d.get('currency', ''))):
        v.ok('currency', f'Divisa ISO 4217 ({d["currency"]})')
    else:
        v.err('currency', f'`currency: {d.get("currency")}` no parece ISO 4217')
    cu = d.get('consumption_units') or []
    if cu:
        v.ok('consumption_units', f'{len(cu)} unidades declaradas: {", ".join(cu)}')
        for u in cu:
            if u not in KNOWN_UNITS:
                v.warn('consumption_units', f'Unidad `{u}` fuera de la lista de la guía (admisible, la guía es abierta)')
    else:
        v.err('consumption_units', 'Lista de unidades vacía')

    def check_periodo(p, path):
        if not isinstance(p, dict):
            v.err(path, '`period` debe ser objeto {value, unit}')
            return
        if not isinstance(p.get('value'), int) or p['value'] <= 0:
            v.err(path, f'`period.value: {p.get("value")}` debe ser entero > 0')
        if str(p.get('unit')) not in PERIOD_UNITS:
            v.err(path, f'`period.unit: {p.get("unit")}` fuera de {{MIN, HOUR, DAY, MONTH…}} (mayúsculas)')

    # capacity
    cap = d.get('capacity') or {}
    for name, q in cap.items():
        path = f'capacity.{name}'
        if not re.match(r'^quota_[a-z]', name):
            v.warn(path, 'La clave no sigue `quota_[recurso]_[contexto]_[plan]`')
        if re.search(r'\d', name):
            v.warn(path, 'La guía prohíbe números en el nombre de la clave')
        val = q.get('value')
        if val is None:
            v.warn(path, 'Cuota sin `value` — hueco: debe estar justificado con 🔴 y en not_found')
        elif not (isinstance(val, (int, float)) or val == 'custom'):
            v.err(path, f'`value: {val}` no es numérico ni `custom`')
        if q.get('unit') not in cu:
            v.err(path, f'`unit: {q.get("unit")}` no está declarada en consumption_units')
        # B16: dentro de `capacity`, un `period` ausente es hueco deliberado y da AVISO, con
        # el mismo trato que la cuota sin `value` y que el `window_type` ausente. En
        # `max_power` y en `plans` sigue siendo error: alli nada lo declara deliberado.
        if q.get('period') is None:
            v.warn(path, 'Cuota sin `period` — hueco: debe estar justificado con 🔴 y en not_found')
        else:
            check_periodo(q.get('period'), path)
        wt = q.get('window_type')
        if wt is None:
            v.warn(path, 'Sin `window_type` (rolling | fixed_utc_midnight | fixed_billing_cycle)')
        elif wt not in WINDOW_TYPES:
            v.err(path, f'`window_type: {wt}` fuera del enum de la guía')
        oc = q.get('overage_cost')
        if oc is not None:
            if not isinstance(oc.get('price'), (int, float)):
                v.err(path, f'`overage_cost.price: {oc.get("price")}` no numérico')
            if not isinstance(oc.get('value'), (int, float)):
                v.err(path, f'`overage_cost.value: {oc.get("value")}` no numérico')
    if cap:
        v.ok('capacity', f'{len(cap)} cuotas definidas y tipadas')

    # max_power
    mp = d.get('max_power')
    if not mp:
        v.warn('max_power', 'Bloque vacío — hueco DELIBERADO si está justificado (F-01/D-004); '
                            'sin él PRIME4API no puede construir la curva de capacidad')
    else:
        for name, r in mp.items():
            path = f'max_power.{name}'
            if not re.match(r'^rate_[a-z]', name):
                v.warn(path, 'La clave no sigue `rate_[recurso]_[contexto]_[plan]`')
            if r.get('unit') not in cu:
                v.err(path, f'`unit: {r.get("unit")}` no declarada en consumption_units')
            check_periodo(r.get('period'), path)

    # plans
    plans = d.get('plans') or {}
    if not plans:
        v.err('plans', 'No hay planes definidos')
    for pname, p in plans.items():
        path = f'plans.{pname}'
        price = p.get('price')
        if not (isinstance(price, (int, float)) or price == 'custom'):
            v.err(path, f'`price: {price}` no es numérico ni `custom`')
        check_periodo(p.get('period'), path)
        qref = p.get('quota')
        if qref and qref not in cap:
            v.err(path, f'`quota: {qref}` no existe en capacity')
        rref = p.get('rate')
        if rref and rref not in (mp or {}):
            v.err(path, f'`rate: {rref}` no existe en max_power')
        # B8 (D-035, 2026-09-14): cada límite se declara una sola vez. PRIME4API
        # hereda el del plan y le concatena el del endpoint sin deduplicar
        # (`_get_node_scenarios`), así que repetir la referencia duplica el
        # límite en la curva de capacidad.
        def check_una_vez(node, npath):
            if not hasattr(node, 'get'):
                return
            if qref and node.get('quota') == qref:
                v.err(npath, f'B8: `quota: {qref}` ya la declara el plan; repetirla la duplica en el motor')
            if rref and node.get('rate') == rref:
                v.err(npath, f'B8: `rate: {rref}` ya lo declara el plan; repetirlo lo duplica en el motor')

        for ep, e in (p.get('endpoints') or {}).items():
            epath = f'{path}.endpoints.{ep}'
            if e.get('quota') and e['quota'] not in cap:
                v.err(epath, f'`quota: {e["quota"]}` no existe en capacity')
            if e.get('rate') and e['rate'] not in (mp or {}):
                v.err(epath, f'`rate: {e["rate"]}` no existe en max_power')
            check_una_vez(e, epath)
            for alias, sub_ in (e.items() if hasattr(e, 'items') else []):
                if hasattr(sub_, 'get') and alias not in ('quota', 'rate', 'workload'):
                    check_una_vez(sub_, f'{epath}.{alias}')
            w = e.get('workload')
            if w is None:
                if ep == '/*':
                    # El comodin de la guia (README 3.4.1) fija los valores por
                    # defecto del plan; no es un endpoint concreto y por tanto no
                    # tiene carga de trabajo propia.
                    v.ok(epath, 'Comodin `/*`: fija los limites por defecto del plan')
                else:
                    v.warn(epath, 'Endpoint sin `workload`')
                continue
            # DV-01 (2026-08-10): workload es una LISTA de cargas, no un mapa.
            # Se acepta tambien el mapa antiguo para no romper datasheets viejas.
            cargas = w if isinstance(w, list) else [w]
            for k, w in enumerate(cargas):
                wpath = epath if len(cargas) == 1 else f'{epath}[{k}]'
                if not hasattr(w, 'get'):
                    v.err(wpath, f'workload mal formado: {w!r}')
                    continue
                if w.get('unit') not in cu:
                    v.err(wpath, f'`workload.unit: {w.get("unit")}` no declarada en consumption_units')
                if not isinstance(w.get('min'), int):
                    v.err(wpath, f'`workload.min: {w.get("min")}` debe ser entero')
                mx = w.get('max')
                if mx is None:
                    v.warn(wpath, '`workload.max` vacío — hueco deliberado si el comentario lo justifica (F-06)')
                elif not isinstance(mx, int):
                    v.err(wpath, f'`workload.max: {mx}` debe ser entero (o vacío justificado)')
                elif isinstance(w.get('min'), int) and mx < w['min']:
                    v.err(wpath, f'`workload.max` ({mx}) < `min` ({w["min"]})')
                if not w.get('description'):
                    v.warn(wpath, 'workload sin `description` (la guía la incluye siempre)')
    if plans:
        v.ok('plans', f'{len(plans)} planes; referencias quota/rate resueltas donde existen')

    # metadata + provenance
    md = d.get('metadata') or {}
    # E1: toda linea de data_provenance lleva cita literal entre comillas simples
    sin_cita = [l for l in (md.get('data_provenance') or [])
                if isinstance(l, str) and not l.startswith('NOTA') and not re.search(r"'[^']{12,}'", l)]
    if sin_cita:
        v.warn('metadata.data_provenance', f'{len(sin_cita)} línea(s) sin cita literal: no verificables (CRITERIOS E1)')
    else:
        v.ok('metadata.data_provenance', 'todas las líneas llevan cita literal')
    if md.get('sources_visited'):
        v.ok('metadata', f'{len(md["sources_visited"])} URLs en sources_visited')
    else:
        v.warn('metadata', 'Sin sources_visited')
    if md.get('data_provenance'):
        v.ok('metadata', f'{len(md["data_provenance"])} afirmaciones en data_provenance')
    if md.get('not_found'):
        v.ok('metadata', f'{len(md["not_found"])} huecos registrados en not_found')

    # referencias [Fn]
    citados = set(re.findall(r'\[(F\d+)\]', yaml_text))
    if citados:
        sin_fuente = citados - set(fuentes)
        for f in sorted(sin_fuente):
            v.err('fuentes', f'[{f}] citado en la datasheet pero no existe en fuentes.md')
    else:
        v.ok('fuentes', 'Provenance autocontenido (URLs entre corchetes); el registro '
                        f'extendido con citas literales tiene {len(fuentes)} fuentes en fuentes.md')
    return v.checks


# ------------------------------------------------------------------ filas UI
def sub(field, value, sem, refs, comment):
    return {'campo': field, 'valor': fmt(value), 'sem': sem, 'refs': refs,
            'coment': comment}


def row(rid, grupo, titulo, subs, repeat=False, nota_bloque=''):
    sems = [s['sem'] for s in subs if s['sem']]
    worst = '🔴' if '🔴' in sems else ('🟡' if '🟡' in sems else ('🟢' if sems else ''))
    refs = sorted({r for s in subs for r in s['refs']})
    return {'id': rid, 'grupo': grupo, 'titulo': titulo, 'subs': subs,
            'sem': worst, 'refs': refs, 'repeat': repeat, 'nota': nota_bloque}


def build_rows(d, raw, fuentes):
    rows, rid = [], 0

    def nid():
        nonlocal rid
        rid += 1
        return rid

    def leaf_sub(node, key, label=None):
        val, ln = leaf(raw=raw, node=node, key=key)
        c = line_comment(raw, ln)
        return sub(label or key, val, semaforo_of(c), refs_of(c),
                   clean_comment(c))

    # ---- Cabecera
    subs = [leaf_sub(d, k) for k in
            ('associated_saas', 'type', 'url', 'currency', 'base_uri')]
    subs.append(sub('syntax_version / date', f"{d.get('syntax_version')} · {d.get('date')}", '', [], ''))
    subs.append(sub('consumption_units', ', '.join(d.get('consumption_units') or []), '', [], ''))
    rows.append(row(nid(), 'Cabecera', 'Identificación del servicio', subs))

    # ---- capacity
    for name, q in (d.get('capacity') or {}).items():
        start = q.lc.line if hasattr(q, 'lc') else 0
        subs = [leaf_sub(q, 'value'),
                sub('unit · period', f"{q.get('unit')} · {(q.get('period') or {}).get('value')} {(q.get('period') or {}).get('unit')}", '', [], ''),
                leaf_sub(q, 'window_type')]
        oc = q.get('overage_cost')
        if oc is not None:
            subs.append(leaf_sub(oc, 'price', 'overage_cost'))
            subs[-1]['valor'] = f"{oc.get('price')} $/{oc.get('value')} {q.get('unit')}"
        else:
            extra = [c for c in block_comments(raw, start, start + 12) if 'overage' in c.lower()]
            subs.append(sub('overage_cost', '∅ sin sobrecoste', semaforo_of(' '.join(extra)),
                            refs_of(' '.join(extra)), ' '.join(extra)))
        rows.append(row(nid(), 'capacity — cuotas', f'{name}', subs))

    # ---- max_power
    mp = d.get('max_power')
    if not mp:
        ln = d.lc.data.get('max_power', [0])[0] if hasattr(d, 'lc') else 0
        notas = block_comments(raw, max(0, ln - 12), ln)
        rows.append(row(nid(), 'max_power — rates', 'max_power (bloque vacío deliberado)',
                        [sub('estado', '∅ sin rates publicados', '🔴',
                             refs_of(' '.join(notas)), ' · '.join(notas))]))
    else:
        for name, r in mp.items():
            rows.append(row(nid(), 'max_power — rates', name, [
                leaf_sub(r, 'value'),
                sub('unit · period', f"{r.get('unit')} · {(r.get('period') or {}).get('value')} {(r.get('period') or {}).get('unit')}", '', [], '')]))

    # ---- plans
    seen_ep = {}
    for pname, p in (d.get('plans') or {}).items():
        subs = [leaf_sub(p, 'price'),
                sub('period', f"{(p.get('period') or {}).get('value')} {(p.get('period') or {}).get('unit')}", '', [], ''),
                sub('quota →', p.get('quota'), '', [], 'referencia a capacity')]
        rows.append(row(nid(), f'plan · {pname}', f'Plan {pname}', subs))
        for ep, e in (p.get('endpoints') or {}).items():
            w = e.get('workload') or {}
            # DV-01: workload es lista; la estacion muestra la primera carga
            # (el catalogo de correo solo declara una por endpoint) y anota si hay mas.
            extra = ''
            if isinstance(w, list):
                extra = f' (+{len(w)-1} cargas)' if len(w) > 1 else ''
                w = w[0] if w else {}
            desc = str(w.get('description') or '') + extra
            sig = (w.get('unit'), w.get('min'), w.get('max'),
                   re.sub(r'\s+', ' ', desc).strip())
            first = ep not in seen_ep
            repeat = (not first) and seen_ep.get(ep) == sig
            if first:
                seen_ep[ep] = sig
            subs = []
            mxv, mxl = leaf(raw=raw, node=w, key='max')
            cmx = line_comment(raw, mxl)
            subs.append(sub('workload', f"{w.get('unit')} · min {w.get('min')} · max {fmt(mxv)}",
                            semaforo_of(cmx), refs_of(cmx), clean_comment(cmx)))
            if not repeat:
                subs.append(sub('descripción', re.sub(r'\s+', ' ', desc), '',
                                refs_of(desc), ''))
            else:
                subs.append(sub('descripción', desc, '', [], ''))
            rows.append(row(nid(), f'plan · {pname}', f'{ep}', subs,
                            repeat=repeat and not first))
    return rows


# ----------------------------------------------------------------------- main
def main():
    out, ypath, fpath = sys.argv[1], sys.argv[2], sys.argv[3]
    title = sys.argv[4] if len(sys.argv) > 4 else 'Estación de revisión de Datasheets'
    cambios = {}
    if len(sys.argv) > 5:
        cambios = json.load(open(sys.argv[5], encoding='utf-8'))
    fuentes, no_enc = parse_fuentes(fpath)
    d, raw = load_yaml(ypath)
    ytext = '\n'.join(raw)
    checks = validar(d, fuentes, ytext)
    rows = build_rows(d, raw, fuentes)
    md = d.get('metadata') or {}
    stats = {
        'verde': ytext.count('🟢'), 'ambar': ytext.count('🟡'), 'rojo': ytext.count('🔴'),
        'ok': sum(1 for c in checks if c['level'] == 'ok'),
        'warn': sum(1 for c in checks if c['level'] == 'warn'),
        'error': sum(1 for c in checks if c['level'] == 'error'),
        'filas': len(rows),
    }
    data = {
        'title': title,
        'api': d.get('associated_saas', ''),
        'fecha': str(d.get('date', '')),
        'cambios': cambios,
        'stats': stats, 'checks': checks, 'rows': rows,
        'fuentes': fuentes, 'no_encontradas': no_enc,
        'provenance': list(md.get('data_provenance') or []),
        'not_found': list(md.get('not_found') or []),
        'sources_visited': list(md.get('sources_visited') or []),
    }
    j = json.dumps(data, ensure_ascii=False)
    open(out, 'w', encoding='utf-8').write(
        TEMPLATE.replace('/*__DATA__*/null', j))
    print(f'escrito {out} · {stats["filas"]} filas · '
          f'validación: {stats["ok"]} ok / {stats["warn"]} avisos / {stats["error"]} errores')


TEMPLATE = r"""<!DOCTYPE html>
<html lang="es"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Estación de revisión de Datasheets — TFM</title>
<style>
:root{
  --bg:#fbfbfa; --panel:#fff; --ink:#1c1b19; --muted:#6b6862; --line:#e6e3dd;
  --accent:#3d5a80; --ok:#2f7d4f; --no:#b03a2e; --duda:#b8860b;
  --verde:#2f7d4f; --ambar:#b8860b; --rojo:#b03a2e;
  --chip:#eef1f5;
}
@media (prefers-color-scheme:dark){:root{
  --bg:#17181a; --panel:#1e2023; --ink:#e8e6e3; --muted:#9a9792; --line:#32353a;
  --accent:#8ab0d9; --ok:#6fc48d; --no:#e08b7f; --duda:#d8b45c;
  --verde:#6fc48d; --ambar:#d8b45c; --rojo:#e08b7f; --chip:#262a30;}}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--ink);
  font:15px/1.6 -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif}
header{position:sticky;top:0;z-index:10;background:var(--panel);
  border-bottom:1px solid var(--line);padding:13px 22px;
  display:flex;gap:16px;align-items:center;flex-wrap:wrap}
h1{font-size:16px;margin:0;font-weight:600}
.sub{color:var(--muted);font-size:13px}
.spacer{flex:1}
.pill{font-size:12px;padding:3px 10px;border-radius:20px;border:1px solid var(--line);color:var(--muted)}
.pill b{color:var(--ink)}
.seg{display:flex;border:1px solid var(--line);border-radius:7px;overflow:hidden}
.seg button{background:transparent;border:0;padding:6px 12px;color:var(--muted);cursor:pointer;font:13px inherit}
.seg button.on{background:var(--accent);color:#fff}
main{max-width:1180px;margin:0 auto;padding:22px}
.gtitle{font:600 12px ui-monospace,monospace;letter-spacing:.09em;text-transform:uppercase;
  color:var(--muted);margin:26px 4px 8px}
.card{background:var(--panel);border:1px solid var(--line);border-radius:10px;margin-bottom:10px;overflow:hidden}
.card.repeat{opacity:.55}
.card.repeat.hidden{display:none}
.chead{display:flex;gap:10px;align-items:center;padding:9px 14px;
  background:color-mix(in srgb,var(--panel) 93%,var(--ink));font-size:13.5px}
.chead .path{font:600 13px ui-monospace,monospace}
.sem{font-size:13px}
.refchip{font:600 11px ui-monospace,monospace;background:var(--chip);border:1px solid var(--line);
  padding:1px 7px;border-radius:5px;cursor:pointer;color:var(--accent)}
.refchip:hover{border-color:var(--accent)}
.acts{margin-left:auto;display:flex;gap:5px}
.acts button{border:1px solid var(--line);background:transparent;color:var(--muted);
  border-radius:6px;padding:3px 10px;cursor:pointer;font-size:12px;font-family:inherit}
.acts button:hover{border-color:var(--accent)}
.acts button.sel[data-v=ok]{background:var(--ok);border-color:var(--ok);color:#fff}
.acts button.sel[data-v=no]{background:var(--no);border-color:var(--no);color:#fff}
.acts button.sel[data-v=duda]{background:var(--duda);border-color:var(--duda);color:#fff}
.subs{padding:6px 14px 10px}
.srow{display:grid;grid-template-columns:190px 1fr;gap:10px;padding:5px 0;
  border-top:1px dashed color-mix(in srgb,var(--line) 60%,transparent);font-size:13.5px}
.srow:first-child{border-top:0}
.srow .k{color:var(--muted);font:12.5px ui-monospace,monospace;padding-top:1px}
.srow .v{display:flex;gap:8px;flex-wrap:wrap;align-items:baseline}
.srow .val{font:13.5px ui-monospace,monospace}
.srow .c{color:var(--muted);font-size:12.5px;flex-basis:100%}
.note{width:100%;margin:8px 0 2px;background:transparent;border:1px solid var(--line);
  border-radius:6px;color:var(--ink);padding:7px 9px;font:13px/1.5 inherit;resize:vertical;display:none}
.note.show{display:block}
.srcbox{display:none;border-top:1px solid var(--line);background:color-mix(in srgb,var(--panel) 96%,var(--accent));
  padding:10px 14px;font-size:13px}
.srcbox.show{display:block}
.srcbox h4{margin:6px 0 3px;font-size:13px}
.srcbox .u{font:12px ui-monospace,monospace;word-break:break-all}
.srcbox .u a{color:var(--accent)}
.srcbox ul{margin:5px 0 8px;padding-left:20px}
.srcbox li{margin:3px 0;color:var(--muted)}
.srcbox li code{color:var(--ink);background:var(--chip);padding:0 4px;border-radius:4px}
.checks{background:var(--panel);border:1px solid var(--line);border-radius:10px;padding:6px 0;margin-bottom:8px}
.chk{display:flex;gap:10px;padding:5px 16px;font-size:13.5px;align-items:baseline}
.chk .lvl{font:700 11px ui-monospace,monospace;width:52px;flex:none;text-align:center;
  border-radius:5px;padding:1px 0}
.chk.ok .lvl{background:color-mix(in srgb,var(--verde) 18%,transparent);color:var(--verde)}
.chk.warn .lvl{background:color-mix(in srgb,var(--ambar) 18%,transparent);color:var(--ambar)}
.chk.error .lvl{background:color-mix(in srgb,var(--rojo) 18%,transparent);color:var(--rojo)}
.chk .p{font:12px ui-monospace,monospace;color:var(--muted);flex:none}
.meta{background:var(--panel);border:1px solid var(--line);border-radius:10px;padding:12px 16px;
  margin-bottom:10px;font-size:13.5px}
.meta ul{margin:6px 0;padding-left:20px}
.meta li{margin:3px 0;color:var(--muted)}
.meta li b{color:var(--ink)}
.meta.banner{border-left:4px solid var(--accent)}
.card.nuevo{border-color:var(--accent);box-shadow:0 0 0 1px var(--accent)}
.badge{font-size:13px}
.chgnote{margin:4px 0 6px;padding:6px 9px;border-radius:6px;font-size:13px;
  background:color-mix(in srgb,var(--accent) 12%,transparent)}
footer{position:sticky;bottom:0;background:var(--panel);border-top:1px solid var(--line);
  padding:12px 22px;display:flex;gap:14px;align-items:center;flex-wrap:wrap}
footer button{background:var(--accent);color:#fff;border:0;border-radius:7px;
  padding:8px 17px;cursor:pointer;font:14px inherit}
footer button.ghost{background:transparent;color:var(--muted);border:1px solid var(--line)}
#out{display:none;max-width:1180px;margin:0 auto 22px;padding:0 22px}
#out.show{display:block}
#out textarea{width:100%;height:240px;background:var(--panel);color:var(--ink);
  border:1px solid var(--line);border-radius:9px;padding:13px;
  font:13px/1.6 ui-monospace,monospace;resize:vertical}
</style></head><body>

<header>
  <div><h1 id="ttl"></h1><div class="sub" id="sub"></div></div>
  <div class="spacer"></div>
  <span class="pill" id="psem"></span>
  <span class="pill" id="pval"></span>
  <span class="pill" id="prog"></span>
  <div class="seg"><button id="bRep">Mostrar repetidos</button></div>
</header>

<main id="main"></main>

<div id="out"><label class="sub">Pega esto en el chat</label>
  <textarea id="outTxt" readonly></textarea></div>

<footer>
  <button id="bExp">Generar resumen de mi revisión</button>
  <button id="bCopy" class="ghost">Copiar al portapapeles</button>
  <span class="sub" id="tally"></span>
</footer>

<script>
const DATA = /*__DATA__*/null;
const decisions = {};      // sin localStorage: solo memoria
let showRep = false;

const esc = s => String(s??'').replace(/[&<>]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;'}[c]));
const mdq = s => esc(s).replace(/`([^`]+)`/g,'<code>$1</code>');

function srcbox(fid){
  const f = DATA.fuentes[fid]; if(!f) return '';
  return `<h4>[${fid}] ${esc(f.titulo)}</h4>
    <div class="u"><a href="${esc(f.url)}" target="_blank" rel="noopener">${esc(f.url)}</a> · ${esc(f.fecha)}</div>
    <ul>${f.citas.map(c=>'<li>'+mdq(c)+'</li>').join('')}</ul>
    ${f.obs?'<div class="sub">Obs.: '+mdq(f.obs)+'</div>':''}`;
}

function changedNote(r){
  const c = (DATA.cambios && DATA.cambios.changed) || {};
  return c[r.titulo];
}

function card(r){
  const k = 'r'+r.id, d = decisions[k]||{};
  const btn = (v,l)=>`<button data-k="${k}" data-v="${v}" class="${d.v===v?'sel':''}">${l}</button>`;
  const refs = r.refs.map(f=>`<span class="refchip" data-r="${f}" data-k="${k}">[${f}]</span>`).join(' ');
  const chg = changedNote(r);
  return `<div class="card${r.repeat?' repeat'+(showRep?'':' hidden'):''}${chg?' nuevo':''}" id="${k}">
    <div class="chead">
      ${chg?'<span class="badge">🆕</span>':''}
      <span class="sem">${r.sem||''}</span>
      <span class="path">${esc(r.titulo)}</span>
      ${refs}
      <div class="acts">${btn('ok','✓ OK')}${btn('no','✗ NO')}${btn('duda','? Duda')}</div>
    </div>
    <div class="subs">
      ${chg?`<div class="chgnote">🆕 ${mdq(chg)}</div>`:''}
      ${r.subs.map(s=>`<div class="srow">
        <div class="k">${esc(s.campo)}</div>
        <div class="v"><span class="sem">${s.sem||''}</span>
          <span class="val">${esc(s.valor)}</span>
          ${s.refs.map(f=>`<span class="refchip" data-r="${f}" data-k="${k}">[${f}]</span>`).join(' ')}
          ${s.coment?'<span class="c">'+mdq(s.coment)+'</span>':''}
        </div></div>`).join('')}
      <textarea class="note ${d.v==='no'||d.v==='duda'?'show':''}" data-k="${k}"
        placeholder="${d.v==='no'?'¿Qué está mal?':'¿Qué no tienes claro?'}">${esc(d.note||'')}</textarea>
    </div>
    <div class="srcbox" id="src-${k}"></div>
  </div>`;
}

function draw(){
  document.getElementById('ttl').textContent = DATA.title;
  document.getElementById('sub').textContent =
    DATA.api + ' · extracción ' + DATA.fecha + ' · ' + Object.keys(DATA.fuentes).length + ' fuentes con cita literal';
  const st = DATA.stats;
  document.getElementById('psem').innerHTML = `🟢 <b>${st.verde}</b> · 🟡 <b>${st.ambar}</b> · 🔴 <b>${st.rojo}</b>`;
  document.getElementById('pval').innerHTML =
    `formato v0.3: <b>${st.error}</b> errores · <b>${st.warn}</b> avisos`;

  let h = '';
  if (DATA.cambios && DATA.cambios.banner){
    const n = Object.keys((DATA.cambios.changed)||{}).length;
    h += `<div class="gtitle">Qué cambia en esta pasada</div>
      <div class="meta banner"><div>${mdq(DATA.cambios.banner)}</div>
      ${n?'<div class="sub" style="margin-top:6px">'+n+' elementos marcados con 🆕 — con revisar esos basta; el resto no ha cambiado.</div>':''}</div>`;
  }
  h += '<div class="gtitle">Validación de formato — guía v0.3 del repo</div><div class="checks">' +
    DATA.checks.map(c=>`<div class="chk ${c.level}">
      <span class="lvl">${{ok:'OK',warn:'AVISO',error:'ERROR'}[c.level]}</span>
      <span class="p">${esc(c.path)}</span><span>${mdq(c.msg)}</span></div>`).join('') + '</div>';

  let g = '';
  DATA.rows.forEach(r=>{
    if (r.grupo !== g){ g = r.grupo; h += `<div class="gtitle">${esc(g)}</div>`; }
    h += card(r);
  });

  h += '<div class="gtitle">metadata — buscado y NO encontrado</div><div class="meta"><ul>' +
    DATA.not_found.map(x=>'<li>'+mdq(x)+'</li>').join('') + '</ul></div>';
  h += '<div class="gtitle">metadata — data_provenance</div><div class="meta"><ul>' +
    DATA.provenance.map(x=>'<li>'+mdq(x)+'</li>').join('') + '</ul></div>';
  h += '<div class="gtitle">Fuentes completas</div><div class="meta">' +
    Object.keys(DATA.fuentes).map(f=>'<div class="srcbox show" style="border:0;background:transparent;padding:4px 0">'+srcbox(f)+'</div>').join('') +
    '</div>';

  document.getElementById('main').innerHTML = h;

  document.querySelectorAll('.acts button').forEach(b=>b.onclick=()=>{
    const k=b.dataset.k, v=b.dataset.v;
    if (decisions[k] && decisions[k].v===v) delete decisions[k];
    else decisions[k]={v, note:(decisions[k]||{}).note||''};
    draw();
  });
  document.querySelectorAll('.note').forEach(n=>n.oninput=()=>{
    const k=n.dataset.k;
    if(!decisions[k]) decisions[k]={v:'',note:''};
    decisions[k].note=n.value; tally();
  });
  document.querySelectorAll('.refchip').forEach(c=>c.onclick=()=>{
    const box=document.getElementById('src-'+c.dataset.k);
    if(!box) return;
    const cur=box.dataset.r;
    if(cur===c.dataset.r && box.classList.contains('show')){box.classList.remove('show');return;}
    box.dataset.r=c.dataset.r; box.innerHTML=srcbox(c.dataset.r); box.classList.add('show');
  });
  tally();
}

function reviewables(){ return DATA.rows.length; }
function tally(){
  const v=Object.values(decisions).filter(d=>d.v);
  const c=t=>v.filter(d=>d.v===t).length;
  document.getElementById('tally').textContent=`${c('ok')} OK · ${c('no')} NO · ${c('duda')} dudas`;
  document.getElementById('prog').innerHTML=`<b>${v.length}</b>/${reviewables()} revisados`;
}

function exportTxt(){
  let s='# Revisión de datasheet — '+DATA.api+' ('+DATA.fecha+')\n';
  s+='Formato v0.3: '+DATA.stats.error+' errores, '+DATA.stats.warn+' avisos · Semáforo: 🟢'+
     DATA.stats.verde+' 🟡'+DATA.stats.ambar+' 🔴'+DATA.stats.rojo+'\n\n';
  let g='';
  DATA.rows.forEach(r=>{
    const d=decisions['r'+r.id]; if(!d||!d.v) return;
    if(r.grupo!==g){g=r.grupo;s+='## '+g+'\n';}
    const lbl={ok:'[OK]',no:'[NO]',duda:'[DUDA]'}[d.v];
    s+=`${lbl} ${r.titulo} ${r.sem?'('+r.sem+')':''}\n`;
    if(d.note) s+='     -> '+d.note+'\n';
  });
  const pend=reviewables()-Object.values(decisions).filter(d=>d.v).length;
  if(pend) s+='\n('+pend+' elementos sin revisar)\n';
  return s;
}

document.getElementById('bRep').onclick=e=>{
  showRep=!showRep;
  e.target.classList.toggle('on',showRep);
  e.target.textContent=showRep?'Ocultar repetidos':'Mostrar repetidos';
  draw();
};
document.getElementById('bExp').onclick=()=>{
  document.getElementById('outTxt').value=exportTxt();
  document.getElementById('out').classList.add('show');
  document.getElementById('out').scrollIntoView({behavior:'smooth'});
};
document.getElementById('bCopy').onclick=async()=>{
  const t=exportTxt();
  document.getElementById('outTxt').value=t;
  document.getElementById('out').classList.add('show');
  try{await navigator.clipboard.writeText(t);
    document.getElementById('bCopy').textContent='Copiado';
    setTimeout(()=>document.getElementById('bCopy').textContent='Copiar al portapapeles',1600);
  }catch(e){document.getElementById('outTxt').select();}
};

draw();
</script></body></html>
"""

if __name__ == '__main__':
    main()
