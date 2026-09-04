#!/usr/bin/env bats
# unterkommando-kopplung.bats — haelt die Unterkommando-Namen, die der `Makefile`
# an den Traeger gibt, an den Dispatch in `cmd/ai-harness-init/main.go`. Beide
# Seiten nennen dasselbe Literal, und nichts sonst verbindet sie: der Name reist
# als Zeichenkette vom Ziel in den Prozess.
#
# WARUM DIESE KOPPLUNG EIN EIGENER SENSOR IST. Ein Name, den main() nicht
# dispatcht, ist im Traeger ein Positionsargument des Init-Pfads. Der faellt seit
# der Sperre in run() als Aufruf-Fehler auf (Exit 2), also schreibt ein Vertipper
# nichts mehr — nur sichtbar wird er erst beim Bedienen. Dieser Fall zieht ihn
# nach vorn: er faellt im Gate, bevor jemand `make archive-welle` ruft.
#
# `make comment-claims` hat den `Makefile` dauerhaft ausserhalb seines
# Pruefbereichs (AGENTS.md §4), und keine Go-Stufe liest ihn — ein Kommentar im
# Rezept traegt hier also nichts. NETZLOS (nur Datei-Vergleich), laeuft in
# `make gates`. Docker-only (bats-Image).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  MK="$REPO/Makefile"
  MAIN="$REPO/cmd/ai-harness-init/main.go"
}

@test "jedes Unterkommando hinter \$(HOST_BIN) steht im Dispatch von main()" {
  # Eine NENNUNG ist `$(HOST_BIN)` gefolgt von Zwischenraum — die Rezept-Zeilen
  # und die Kommentar-Zeile daneben, die den Aufruf ausschreibt. Die zwei
  # uebrigen Verwendungen geben den PFAD an ein Skript weiter und tragen direkt
  # hinter der Klammer ein `)` bzw. ein `"`; sie fallen aus dem Muster.
  nennungen="$(grep -cE '\$\(HOST_BIN\)[[:space:]]' "$MK" || true)"
  namen="$(grep -oE '\$\(HOST_BIN\)[[:space:]]+[a-z][a-z-]*' "$MK" | sed -E 's/^.*[[:space:]]//' || true)"
  gefunden="$(printf '%s' "$namen" | grep -c . || true)"

  if [ "$nennungen" -eq 0 ]; then
    echo "keine Nennung von \$(HOST_BIN) mit folgendem Zwischenraum im Makefile —" >&2
    echo "die Kopplung haette keinen Gegenstand und dieser Fall waere ein leeres Gruen." >&2
    return 1
  fi

  # Selbst-Kalibrierung statt Erwartungswert (MR-025): jede Nennung muss einen
  # Namen hergeben. Eine Zeile, aus der das Muster keinen zieht, ist eine Form,
  # die dieser Fall nicht sieht — und ein unbewachtes Literal.
  if [ "$gefunden" -ne "$nennungen" ]; then
    echo "aus $nennungen Nennung(en) von \$(HOST_BIN) sind $gefunden Name(n) gewonnen." >&2
    echo "Eine Nennung traegt eine Form, die dieses Muster nicht liest — sie waere ungekoppelt." >&2
    grep -nE '\$\(HOST_BIN\)[[:space:]]' "$MK" >&2
    return 1
  fi

  for n in $(printf '%s\n' "$namen" | sort -u); do
    if ! grep -qF "case \"$n\":" "$MAIN"; then
      echo "der Makefile gibt dem Traeger '$n', und main() dispatcht diesen Namen nicht." >&2
      echo "Im Traeger ist er ein Positionsargument des Init-Pfads — der Aufruf endet mit Exit 2," >&2
      echo "statt zu tun, was das Ziel danebenschreibt. Der Dispatch fuehrt heute:" >&2
      grep -nE '^[[:space:]]*case "[a-z-]+":' "$MAIN" >&2
      return 1
    fi
  done
}
