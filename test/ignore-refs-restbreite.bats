#!/usr/bin/env bats
# ignore-refs-restbreite.bats — Waechter fuer die BREITE der Top-Level-`ignore-refs`-
# Ausnahmen in .d-check.yml (ADR-0026, Folgepflicht 2).
#
# Ein solcher Eintrag schaltet nicht eine ZEILE stumm, sondern jede Referenz, die `in`
# und `refs` gemeinsam treffen. Weder die Config noch `make docs-check` sagt, wie viele
# das sind: ein zu breiter Eintrag ist genauso gruen wie ein enger. Dieser Waechter haelt
# darum den Eintrag gegen den Bestand — je Paar hoechstens ein Markdown-Link.
#
# ER SCHREIBT KEINE ANZAHL VON EINTRAEGEN FEST. Verschwindet der Eintrag, deckt d-check
# den Link wieder selbst ab; der Waechter hat dann nichts zu pruefen und ist gruen. Rot
# wird er, wenn eine VORHANDENE Ausnahme mehr deckt als eine Referenz. `ignore-refs` ist
# der Name des Schluessels, nicht der eines Eintrags: jeder kuenftige Eintrag faellt vom
# ersten Lauf an unter dieselbe Messung.
#
# Was der Waechter NICHT ist: eine Schranke gegen einen zweiten EINTRAG. Dass jede
# Verbreiterung eine eigene ADR braucht, ist eine Hard-Rule-Aussage (AGENTS.md 3.5) und
# hat keinen Sensor — ADR-0026 sagt das ausdruecklich.
#
# Gemessen wird der AUFGELOESTE Link-Pfad: `.`- und `..`-Segmente textuell normalisiert,
# relativ zum Verzeichnis der Quelldatei — dieselbe Achse, auf der `refs` matcht.
# NICHT gemessen: Referenz-Links (`[text][ref]`) und Autolinks (`<pfad>`); der Waechter
# sieht die Inline-Form `](ziel)`. Ziele mit Schema (http:, mailto:) zaehlen nicht mit,
# sie koennen kein repo-relatives `refs`-Ziel treffen.
#
# NETZLOS (nur Datei-Lesen), laeuft in `make gates` ueber `make test` -> `test-bats`.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  YML="$REPO/.d-check.yml"
}

# block gibt die Zeilen des TOP-LEVEL-Blocks aus (Schluessel in Spalte 0) — nicht die
# des gleichnamigen Schluessels unter `codepaths:`, der eingerueckt steht und eine
# andere Form traegt (blanke Pfad-Liste statt in/refs-Paare).
block() {
  awk '
    /^ignore-refs:[[:space:]]*$/ { inblk = 1; next }
    inblk && /^[^[:space:]]/     { inblk = 0 }
    inblk                        { print }
  ' "$YML"
}

# pairs gibt je Zeile "<in>\t<ref>" aus. Eine Zeile, die keiner der zwei gelesenen
# Formen entspricht, wird als UNGELESEN durchgereicht statt verschluckt — sonst waere
# eine umformatierte Config still gruen.
pairs() {
  block | awk '
    /^[[:space:]]*(#.*)?$/ { next }
    {
      line = $0
      if (line ~ /^[[:space:]]*-[[:space:]]+in:[[:space:]]*/) {
        src = line
        sub(/^[[:space:]]*-[[:space:]]+in:[[:space:]]*/, "", src)
        gsub(/["]/, "", src)
        sub(/[[:space:]]+$/, "", src)
        next
      }
      if (line ~ /^[[:space:]]+refs:[[:space:]]*\[/) {
        r = line
        sub(/^[[:space:]]+refs:[[:space:]]*\[/, "", r)
        sub(/\][[:space:]]*$/, "", r)
        n = split(r, arr, ",")
        for (i = 1; i <= n; i++) {
          t = arr[i]
          gsub(/[" ]/, "", t)
          if (t != "") print src "\t" t
        }
        next
      }
      print "UNGELESEN\t" line
    }
  '
}

# count_links zaehlt in $1 (repo-relativ) die Inline-Links, deren aufgeloestes Ziel $2 ist.
count_links() {
  awk -v src="$1" -v want="$2" '
    function norm(p,   n, i, o, seg, out, r) {
      n = split(p, seg, "/"); o = 0
      for (i = 1; i <= n; i++) {
        if (seg[i] == "" || seg[i] == ".") continue
        if (seg[i] == "..") { if (o > 0) o--; continue }
        out[++o] = seg[i]
      }
      r = ""
      for (i = 1; i <= o; i++) r = r (i > 1 ? "/" : "") out[i]
      return r
    }
    BEGIN {
      dir = src
      if (!sub(/\/[^\/]*$/, "", dir)) dir = ""
      target = norm(want)
      c = 0
    }
    {
      line = $0
      while (match(line, /\]\([^)]*\)/)) {
        t = substr(line, RSTART + 2, RLENGTH - 3)
        line = substr(line, RSTART + RLENGTH)
        sub(/[[:space:]].*$/, "", t)
        sub(/#.*$/, "", t)
        if (t == "") continue
        if (t ~ /^[a-zA-Z][a-zA-Z0-9+.-]*:/) continue
        if (t ~ /^\//) p = norm(t); else p = norm(dir "/" t)
        if (p == target) c++
      }
    }
    END { print c }
  ' "$REPO/$1"
}

@test "d-check.yml: der Top-Level-ignore-refs-Block wird vollstaendig und in bekannter Form gelesen" {
  # Zwei Zaehlungen derselben Sache aus verschiedenen Richtungen. Faende der Block-
  # Schnitt den Schluessel nicht mehr (umbenannt, eingerueckt, anders geschrieben),
  # lieferte pairs() nichts und der Waechter darunter waere leer und gruen — hier faellt er.
  datei_in="$(grep -cE '^[[:space:]]*-[[:space:]]+in:' "$YML" || true)"
  block_in="$(block | grep -cE '^[[:space:]]*-[[:space:]]+in:' || true)"
  if [ "$datei_in" != "$block_in" ]; then
    echo "in:-Zeilen der Datei: $datei_in, im gelesenen Top-Level-Block: $block_in."
    echo "Der Block-Schnitt trifft nicht mehr, was die Config traegt — die Messung"
    echo "darunter waere leer und gruen, ohne dass die Ausnahme verschwunden ist."
    false
  fi

  ungelesen="$(pairs | grep '^UNGELESEN' || true)"
  if [ -n "$ungelesen" ]; then
    echo "Zeilen im Top-Level-ignore-refs-Block, die dieser Waechter nicht liest:"
    echo "$ungelesen"
    echo "Gelesen werden '- in: <datei>' und 'refs: [<datei>, ...]'. Eine andere Form"
    echo "wird nicht stillschweigend uebergangen: sie waere eine ungemessene Ausnahme."
    false
  fi
}

@test "d-check.yml: jede Top-Level-ignore-refs-Ausnahme deckt hoechstens einen Markdown-Link ihrer Quelldatei" {
  befunde=""
  while IFS="$(printf '\t')" read -r src ref; do
    [ -n "$src" ] || continue
    [ "$src" != "UNGELESEN" ] || continue
    if [ ! -f "$REPO/$src" ]; then
      befunde="$befunde
  $src -> $ref: Quelldatei fehlt"
      continue
    fi
    n="$(count_links "$src" "$ref")"
    if [ "$n" -gt 1 ]; then
      befunde="$befunde
  $src -> $ref: $n aufloesende Links, hoechstens 1 ist gedeckt"
    fi
  done < <(pairs)

  if [ -n "$befunde" ]; then
    echo "Eine ignore-refs-Ausnahme schaltet mehr als eine Referenz stumm."
    echo "Die weiteren fallen aus der Pruefung, ohne dass jemand sie entschieden hat."
    echo "Zu entscheiden ist, ob die zweite Referenz zulaessig ist oder die Ausnahme"
    echo "zu verengen — beides in einer eigenen ADR, nicht als Nachziehen (ADR-0026)."
    echo "$befunde"
    false
  fi
}
