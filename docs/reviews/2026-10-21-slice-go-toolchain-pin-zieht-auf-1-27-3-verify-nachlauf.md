# Verifier-Nachlauf: slice-go-toolchain-pin-zieht-auf-1-27-3

Nachtrag zum Report 2026-10-21-slice-go-toolchain-pin-zieht-auf-1-27-3-verify.md (bleibt unveraendert).
Verifizierter Stand: HEAD 0505bb60. Geprueft nur das Neue.

## Verdikt

- DoD-Punkt 1 (Digest gehoert zum Tag): **bestaetigt** fuer den Dockerfile-Pin, mit Einschraenkung unter AGENTS.md 3.9: Laeufe auf macOS sind kein Beleg im Sinne der Norm, Beleg ist die CI nach dem Push.
- Rest-Punkte des Erstreports: unberuehrt (der Nachzug aendert nur eine Zeile).

## Messungen

- (a) `git show 0505bb60 --stat`: Dockerfile | 2 +-, eine Zeile. `git diff 5c91a7a1..HEAD -- . ':!docs'`: nur Dockerfile:14, Digest 957861185dbf... -> 6928d94d1142af58...
- (b) `docker buildx imagetools inspect golang:1.27.3 --format '{{.Manifest.Digest}}'` (2026-10-21 04:38 UTC) = sha256:6928d94d1142af58816fed5a62338d605a266ccd53a0deaab6b1096f19059261 = Dockerfile:14. Tag nicht erneut umgesetzt.
- (c) `make freshness-digest`: alle fuenf Achsen "aktuell" (go-toolchain, golangci-lint, d-check, d-check-emit, a-check-emit), Exit 0. `make freshness-go`: "gepinnt und latest sind beide 1.27.3".
- (d) `git grep -n '957861'` und `git grep -n '820153'` ausserhalb docs/reviews, done/, observations/, Slice-Plan: je rc=1, kein Treffer, kein Pin.
- (e) `make test-go` ok (alle Pakete); `make test-bats BATS_TARGET=test/pin-fallbacks.bats`: 5/5 ok. `make gates`: siehe Commit-Lauf (Ergebnis in der Uebergabe).

## Rot-Beleg Digest-Waechter

- Bewusstes Brechen an der realen Quelle: Dockerfile:14 `...1142af...` -> `...1143af...`, dann `make freshness-digest` -> go-toolchain "DIGEST WEICHT AB — der Digest gehoert nicht (mehr) zum Tag", gepinnt ...1143..., aufgeloest ...1142...; `make` endete mit Fehler (Exit != 0, Aufruf ueber make). Danach `git checkout Dockerfile`, Baum sauber.
- Realer Gegenbeweis: der alte Digest 957861185dbf... war im Erstreport bereits rot (derselbe Waechter, derselbe Text), weil der Tag umgesetzt wurde.

## Offen

- Mutations-CI-Branch mutate/slice-go-toolchain-pin-zieht-auf-1-27-3-5c91a7a1: Ergebnis liefert der Auftraggeber; nicht von mir gelesen. Er prueft Commit 5c91a7a1 (alter Digest); die Faelle haengen nicht am Digest-Wert (Angabe des Auftraggebers, nicht gemessen).
- Der Digest-Waechter prueft Pin gegen den heutigen Tag-Stand; er schuetzt nicht vor einer erneuten Umsetzung des Tags nach dem Push (nur nachts/auf Aufruf).
- Beleg im Sinne von 3.9 ist die CI nach dem Push.
