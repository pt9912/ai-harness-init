#!/usr/bin/env bats
# unterkommando-kopplung.bats — haelt die Unterkommando-Namen, die ein Aufrufer
# dieses Repos dem Traeger gibt, an den Dispatch in
# `cmd/ai-harness-init/main.go`. Zwei Aufrufer nennen solche Namen, und nichts
# sonst verbindet sie mit dem Dispatch: der Name reist als Zeichenkette vom
# Aufrufer in den Prozess.
#
#   `Makefile`              — das Ziel `archive-welle`, der Bedien-Einstieg.
#   `.claude/settings.json` — die Hooks dieses Repos. Sie rufen den Traeger
#                             DIREKT, ohne das Wrapper-Skript, das ein
#                             emittiertes Repo bekommt.
#
# WARUM DIESE KOPPLUNG EIN EIGENER SENSOR IST. Ein Name, den main() nicht
# dispatcht, ist im Traeger ein Positionsargument des Init-Pfads. Der faellt seit
# der Sperre in run() als Aufruf-Fehler auf (Exit 2), also schreibt ein Vertipper
# nichts mehr — sichtbar wird er aber erst beim Bedienen. Am Hook-Kanal kommt
# hinzu, dass 2 der Wert ist, mit dem ein Hook blockiert: die Klemme aus ADR-0011
# Festlegung 6 sitzt IN spanEmit() und deckt, was dort ankommt. Ein Name, der
# spanEmit() nie erreicht, liegt vor ihr. Dieser Fall zieht beides nach vorn — er
# faellt im Gate, bevor jemand `make archive-welle` ruft oder ein Hook feuert.
#
# `make comment-claims` fuehrt weder den `Makefile` noch `.claude/settings.json`
# in seinem Pruefbereich (AGENTS.md §4), `shell-lint` liest beide nicht, und
# keine Go-Stufe oeffnet sie — ein Kommentar in den Quellen traegt hier also
# nichts. NETZLOS (nur Datei-Vergleich), laeuft in `make gates`. Docker-only
# (bats-Image).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  MK="$REPO/Makefile"
  SETTINGS="$REPO/.claude/settings.json"
  MAIN="$REPO/cmd/ai-harness-init/main.go"
}

# kopplung_haelt <quelle> <datei> <nennungs-muster> <namens-muster>
#
# BEIDE ZAEHLUNGEN ZAEHLEN VORKOMMEN, nicht die eine Zeilen und die andere
# Vorkommen: `grep -o`, danach `grep -c .`. Die Selbst-Kalibrierung darunter
# haelt die zwei Zahlen gegeneinander, und das ist nur eine Aussage, solange sie
# ueber derselben Menge sprechen. Kaeme `nennungen` aus `grep -c`, blieben zwei
# Nennungen in DERSELBEN Zeile als eine gezaehlt: die zweite gaebe keinen Namen
# her, die Gleichheit haette trotzdem gehalten, und das Literal waere
# ungekoppelt.
#
# DER NAME IST DURCH TRENNER BEGRENZT, NICHT DURCH EINE ZEICHEN-WEISSLISTE.
# Gelesen wird alles zwischen dem Zwischenraum hinter der Traeger-Nennung und
# dem naechsten Zeichen, das in diesen zwei Dateien ein Wort beendet:
# Zwischenraum, doppeltes Anfuehrungszeichen, Backtick. Damit ist die Menge, aus
# der dieser Fall Namen zieht, ECHT WEITER als die Menge der Namen, die main()
# dispatcht — und genau das ist die Bedingung dafuer, dass ein UNGUELTIGER Name
# ueberhaupt in die Dispatch-Schleife kommt. Eine Weissliste ueber der Form der
# heute gueltigen Namen (`[a-z][a-z-]*`) schneidet am ersten Zeichen ausserhalb
# ab und liefert einen gueltigen Praefix: `span-emit2` laese sie als
# `span-emit`, die Kalibrierung bliebe ausgeglichen, die Schleife faende den
# `case` — fuer einen Namen, den main() mit Exit 2 ablehnt. Die Faelle dazu sind
# test/mutations/259-hostbin-name-mit-ziffer.sh und
# test/mutations/260-span-emit-hook-name-mit-ziffer.sh.
#
# ZWEI GRENZEN, beide fail-closed. Beginnt hinter der Nennung ein Trenner —
# etwa eine Variablen-Referenz in Anfuehrungszeichen —, gibt die Nennung keinen
# Namen her; das faengt die Kalibrierung, nicht die Schleife. Und ein
# Satzzeichen, das in einer Kommentar-Zeile unmittelbar am Namen klebt, wird
# mitgelesen und faellt als unbekannter Name auf: eine Nennung im Fliesstext
# gehoert in Backticks, so wie die vorhandene sie traegt.
#
# DER DISPATCH IST DIE MENGE DER case-MARKEN AM ZEILENANFANG, und Entscheidung
# wie Diagnose lesen sie aus DEMSELBEN Muster. Geprueft wird Mitgliedschaft in
# dieser Menge — ganze Zeile, feste Zeichenkette —, nicht das Vorkommen der
# Zeichenkette irgendwo in main.go: ein `case "…":` in einer KOMMENTAR-Zeile
# dispatcht nichts, und ueber dem switch steht dort ein langer Kommentarblock.
# Der Fall dazu ist test/mutations/261-dispatch-marke-nur-im-kommentar.sh.
# GRENZE, fail-closed: eine Mehrfach-Marke (`case "a", "b":`) faellt aus dem
# Muster und damit aus der Menge — ihr Name faellt als undispatcht auf, nicht
# durch.
kopplung_haelt() {
  local quelle="$1" datei="$2" nennung_muster="$3" name_muster="$4"
  local nennungen namen gefunden n
  local dispatch_muster='^[[:space:]]*case "[^"]*":' dispatch

  dispatch="$(grep -oE "$dispatch_muster" "$MAIN" | sed -E 's/^[[:space:]]*case "//; s/":$//')"
  nennungen="$(grep -oE "$nennung_muster" "$datei" | grep -c . || true)"
  namen="$(grep -oE "$name_muster" "$datei" | sed -E 's/^.*[[:space:]]//' || true)"
  gefunden="$(printf '%s' "$namen" | grep -c . || true)"

  if [ "$nennungen" -eq 0 ]; then
    echo "$quelle nennt den Traeger nicht mehr in der Form, die dieser Fall liest —" >&2
    echo "die Kopplung haette keinen Gegenstand und dieser Fall waere ein leeres Gruen." >&2
    return 1
  fi

  if [ "$gefunden" -ne "$nennungen" ]; then
    echo "aus $nennungen Nennung(en) in $quelle sind $gefunden Name(n) gewonnen." >&2
    echo "Eine Nennung traegt eine Form, die dieses Muster nicht liest — sie waere ungekoppelt." >&2
    grep -nE "$nennung_muster" "$datei" >&2
    return 1
  fi

  for n in $(printf '%s\n' "$namen" | sort -u); do
    if ! grep -qxF "$n" <<<"$dispatch"; then
      echo "$quelle gibt dem Traeger '$n', und main() dispatcht diesen Namen nicht." >&2
      echo "Im Traeger ist er ein Positionsargument des Init-Pfads — der Aufruf endet mit Exit 2," >&2
      echo "statt zu tun, was der Aufrufer danebenschreibt. Der Dispatch fuehrt heute:" >&2
      grep -nE "$dispatch_muster" "$MAIN" >&2
      return 1
    fi
  done
}

@test "jedes Unterkommando hinter \$(HOST_BIN) steht im Dispatch von main()" {
  # Eine NENNUNG ist `$(HOST_BIN)` gefolgt von Zwischenraum — die Rezept-Zeilen
  # und die Kommentar-Zeile daneben, die den Aufruf ausschreibt. Die zwei
  # uebrigen Verwendungen geben den PFAD an ein Skript weiter und tragen direkt
  # hinter der Klammer ein `)` bzw. ein `"`; sie fallen aus dem Muster.
  kopplung_haelt \
    "der Makefile" "$MK" \
    '\$\(HOST_BIN\)[[:space:]]' \
    '\$\(HOST_BIN\)[[:space:]]+[^[:space:]"`]+'
}

@test "jedes Unterkommando hinter dem Traeger in .claude/settings.json steht im Dispatch von main()" {
  # Eine NENNUNG ist hier JEDES Vorkommen des Traeger-Namens, nicht nur eines mit
  # folgendem Zwischenraum. Diese Datei nennt ihn ausschliesslich, um ein
  # Unterkommando zu fahren; ein Vorkommen ohne Namen dahinter waere der Traeger
  # ohne Unterkommando, an einem Hook also der Init-Pfad. Die Kalibrierung faengt
  # ihn, weil sie die Namen gegen ALLE Nennungen haelt und nicht nur gegen die,
  # die schon einen tragen.
  kopplung_haelt \
    ".claude/settings.json" "$SETTINGS" \
    'ai-harness-init' \
    'ai-harness-init[[:space:]]+[^[:space:]"`]+'
}
