#!/usr/bin/env bats
# ignore-refs-restbreite.bats — Waechter fuer die BREITE der Top-Level-`ignore-refs`-
# Ausnahmen in .d-check.yml (ADR-0026 Folgepflicht 2, Maßstab neu gefasst in ADR-0039
# Festlegung 2).
#
# Ein solcher Eintrag schaltet nicht eine ZEILE stumm, sondern jede Referenz, die `in`
# und `refs` gemeinsam treffen — je Wert entweder ein Dateiname oder ein Glob in der
# Form `<verzeichnis>/**` (ADR-0039 Festlegung 1). Weder die Config noch `make docs-check`
# sagt, wie viele Referenzen das sind: ein zu breiter Eintrag ist genauso gruen wie ein
# enger. Jeder Eintrag deklariert darum am Ort seiner Definition per Kommentarzeile
# "# Deckung: N", wie viele Markdown-Links er deckt; dieser Waechter haelt die Zahl in
# BEIDE Richtungen — deckt ein Eintrag mehr oder weniger als N, ist er rot. Eine fehlende
# Deklaration ist ebenfalls rot: eine unbezifferte Ausnahme waere sonst still gruen.
# "Deckung: 0" ist eine Deklaration und KEINE fehlende — sie wird gemessen wie jede
# andere Zahl und faerbt rot, sobald der erste Markdown-Link hinzutritt.
#
# `ignore-refs` ist der Name des Schluessels, nicht der eines Eintrags: jeder kuenftige
# Eintrag faellt vom ersten Lauf an unter dieselbe Messung.
#
# Was der Waechter NICHT ist: eine Schranke gegen einen zweiten EINTRAG. Dass jede
# Verbreiterung eine eigene ADR braucht, ist eine Hard-Rule-Aussage (AGENTS.md 3.5) und
# hat keinen Sensor — ADR-0026/ADR-0039 sagen das ausdruecklich.
#
# Gemessen wird der AUFGELOESTE Link-Pfad: `.`- und `..`-Segmente textuell normalisiert,
# relativ zum Verzeichnis der jeweiligen Quelldatei — dieselbe Achse, auf der `refs`
# matcht. NICHT gemessen: Referenz-Links (`[text][ref]`) und Autolinks (`<pfad>`); der
# Waechter sieht die Inline-Form `](ziel)`. Ziele mit Schema (http:, mailto:) zaehlen
# nicht mit, sie koennen kein repo-relatives `refs`-Ziel treffen. Eine Code-Span-Referenz
# (kein `](...)`) zaehlt ebenfalls nicht — ADR-0030 Folgepflicht 2 benennt das als
# eigene, hier nicht geschlossene Luecke.
#
# Ein `in:`-Wert in Glob-Form (`<verzeichnis>/**`) listet den Baum ueber `git ls-files`
# und summiert die Treffer aller darin gefuehrten Dateien; ein `refs:`-Wert in Glob-Form
# zaehlt jeden aufgeloesten Pfad, der unter dem genannten Verzeichnis liegt (Praefix-
# Vergleich auf dem normalisierten Pfad).
#
# NETZLOS (nur Datei-Lesen und `git ls-files`), laeuft in `make gates` ueber `make test`
# -> `test-bats`.

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

# pairs gibt je Zeile "<in>\t<ref>\t<deckung>" aus. <deckung> ist der Zahlwert der
# Kommentarzeile "# Deckung: N", die unmittelbar (ohne dazwischenliegende `- in:`-Zeile)
# vor dem jeweiligen Eintrag steht — leer, wenn keine solche Zeile davorstand. Eine
# Zeile, die keiner der zwei gelesenen Formen entspricht, wird als UNGELESEN
# durchgereicht statt verschluckt — sonst waere eine umformatierte Config still gruen.
pairs() {
  block | awk '
    /^[[:space:]]*(#.*)?$/ {
      if ($0 ~ /^[[:space:]]*#[[:space:]]*Deckung:[[:space:]]*[0-9]+[[:space:]]*$/) {
        d = $0
        sub(/^[[:space:]]*#[[:space:]]*Deckung:[[:space:]]*/, "", d)
        gsub(/[[:space:]]/, "", d)
        pending = d
        havepending = 1
      }
      next
    }
    {
      line = $0
      if (line ~ /^[[:space:]]*-[[:space:]]+in:[[:space:]]*/) {
        src = line
        sub(/^[[:space:]]*-[[:space:]]+in:[[:space:]]*/, "", src)
        gsub(/["]/, "", src)
        sub(/[[:space:]]+$/, "", src)
        decl = havepending ? pending : ""
        havepending = 0
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
          if (t != "") print src "\t" t "\t" decl
        }
        next
      }
      print "UNGELESEN\t" line
    }
  '
}

# is_glob: ein Wert in der Form "<verzeichnis>/**" ist ein Baum-Glob (ADR-0039
# Festlegung 1); jeder andere Wert ist ein literaler Dateiname.
is_glob() {
  case "$1" in
    *"/**") return 0 ;;
    *) return 1 ;;
  esac
}

# count_links_one zaehlt in der Datei $1 (repo-relativ) die Inline-Links, deren
# aufgeloestes Ziel $2 trifft — exakt, wenn $2 ein Dateiname ist, als Praefix-Treffer
# unter dem Verzeichnis vor "/**", wenn $2 ein Glob ist. Ein Link auf das Verzeichnis
# SELBST (ohne weiteres Segment dahinter, z. B. `.harness/baseline` ohne Tag) zaehlt
# im Praefix-Modus NICHT: er zeigt nicht in ein <tag>-gescoptes Vendoring-Verzeichnis
# und bricht mit dem Bump nicht — dieselbe Grenze wie in ADR-0039 Festlegung 2 (die
# dortige Messung verlangt ebenfalls ein "/" plus Rest hinter dem Praefix).
count_links_one() {
  local src="$1" want="$2" mode="exact" prefix=""
  if is_glob "$want"; then
    mode="prefix"
    prefix="${want%/**}"
  fi
  awk -v src="$src" -v want="$want" -v mode="$mode" -v prefix="$prefix" '
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
        if (mode == "prefix") {
          if (index(p, prefix "/") == 1) c++
        } else {
          if (p == target) c++
        }
      }
    }
    END { print c }
  ' "$REPO/$src"
}

# count_total summiert count_links_one ueber die Dateimenge, die $1 bezeichnet — die
# eine Datei selbst, wenn $1 literal ist, oder alle unter dem Verzeichnis vor "/**"
# liegenden Dateien, wenn $1 ein Glob ist. Gelistet wird ueber `find` und nicht ueber
# `git ls-files`: das gepinnte BATS_IMAGE (Makefile test-bats) fuehrt kein `git`, und
# der Baum liegt ohnehin als Bind-Mount vor. Gibt bei einem Glob ohne getroffene Datei
# "LEER" statt einer Zahl aus (eigener Befund, kein stiller 0).
count_total() {
  local src="$1" ref="$2" total=0 n f
  if is_glob "$src"; then
    local dir="${src%/**}"
    local files
    files="$(cd "$REPO" && find "$dir" -type f 2>/dev/null | sort)"
    if [ -z "$files" ]; then
      echo "LEER"
      return
    fi
    while IFS= read -r f; do
      [ -n "$f" ] || continue
      n="$(count_links_one "$f" "$ref")"
      total=$((total + n))
    done <<< "$files"
    echo "$total"
  else
    if [ ! -f "$REPO/$src" ]; then
      echo "FEHLT"
      return
    fi
    count_links_one "$src" "$ref"
  fi
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

@test "d-check.yml: jede Top-Level-ignore-refs-Ausnahme deckt genau die an ihr deklarierte Anzahl Markdown-Links" {
  befunde=""
  while IFS="$(printf '\t')" read -r src ref decl; do
    [ -n "$src" ] || continue
    [ "$src" != "UNGELESEN" ] || continue

    if [ -z "$decl" ]; then
      befunde="$befunde
  $src -> $ref: keine Deckung-Deklaration (# Deckung: N fehlt am Eintrag)"
      continue
    fi

    n="$(count_total "$src" "$ref")"
    if [ "$n" = "FEHLT" ]; then
      befunde="$befunde
  $src -> $ref: Quelldatei fehlt"
      continue
    fi
    if [ "$n" = "LEER" ]; then
      befunde="$befunde
  $src -> $ref: kein Quell-Baum getroffen (git ls-files liefert nichts)"
      continue
    fi
    if [ "$n" != "$decl" ]; then
      befunde="$befunde
  $src -> $ref: $n aufloesende(r) Link(s), deklariert sind $decl"
    fi
  done < <(pairs)

  if [ -n "$befunde" ]; then
    echo "Eine ignore-refs-Ausnahme deckt nicht so viele Referenzen, wie sie deklariert."
    echo "Deckt sie MEHR: eine Referenz faellt aus der Pruefung, die niemand entschieden hat."
    echo "Deckt sie WENIGER: die Deklaration ist ein zu hohes, vorab bewilligtes Budget fuer"
    echo "kuenftiges Stummschalten. Beides ist zu entscheiden und die Deklaration anzupassen"
    echo "oder der Bestand zu korrigieren — in einer eigenen ADR bei einer Verbreiterung des"
    echo "Eintrags selbst, nicht als Nachziehen (ADR-0026, ADR-0039)."
    echo "$befunde"
    false
  fi
}
