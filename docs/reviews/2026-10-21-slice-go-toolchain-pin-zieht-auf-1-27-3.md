# Review slice-go-toolchain-pin-zieht-auf-1-27-3

Rolle Reviewer · Diff `a40fc0a6..5c91a7a1` (ein Implementer-Commit, 5 Dateien, 6 Zeilen) · Plan: Slice `slice-go-toolchain-pin-zieht-auf-1-27-3` (wellenlos).

## Findings

Keine HIGH, keine MEDIUM, keine LOW.

- `kategorie`: INFO · `quelle`: AGENTS.md §3.9 / MR-089 · `pfad`: Commit 5c91a7a1 (Message) · `befund`: Alle Belege dieses Reviews (Digest-Lesung, bats, go test) entstanden auf macOS/colima, nicht im gepinnten Linux-CI-Lauf; der tragende Beleg für `make gates` unter dem neuen Image ist der CI-Lauf nach dem Push. Der Implementer-Commit nennt das nicht ausdrücklich. · `verifizierbar`: ja (CI nach Push) · `klasse`: Messbedingung des Belegs nicht genannt
- `kategorie`: INFO · `quelle`: Maintainability · `pfad`: Plan §2 DoD 2 · `befund`: Die Grenze „Fall 5 und Makefile-Pin allein nicht gebrochen" gilt nicht: beide Brüche wurden hier rot gesehen (siehe Belege 3). Die Plan-Aussage ist zu vorsichtig, nicht zu weit. · `verifizierbar`: ja · `klasse`: Grenzaussage enger als der Befund
- `kategorie`: INFO · `quelle`: Maintainability · `pfad`: Commit 5c91a7a1 · `befund`: Ein Commit statt je Liefer-Punkt: Punkt 2 ist reiner Test-Beleg, Punkt 3 ein Lauf; alle Pin-Stellen sind gekoppelt und ein Teil-Commit liefe rot (TestGoProfile_PinsMatchRepo). Abweichung von der Plan-Konvention plausibel, kein Befund. · `verifizierbar`: nein · `klasse`: Commit-Zuschnitt

## Belege

1. **Vollständigkeit.** `git grep -nE '1\.27\.2'` (ohne docs/reviews, done/) nennt nur: den Slice-Plan selbst (Anlass/Pin-Menge, Prosa), Register-Evidenz (datierte Funde), MR-092/MR-093 (datierte Messbild-Aussage, bewusst unverändert) und `test/digest-freshness.bats` Z. 21/27/30/37 (Fixture-Strings der `--compare`-Fälle, lesen den Repo-Pin nicht). Kein vergessener Pin. `git grep -n 'sha256:820153'` nennt nur Zeitdokumente (done/, docs/reviews), keinen Pin.
2. **Digest-Herkunft.** `docker buildx imagetools inspect golang:1.27.3 --format '{{.Manifest.Digest}}'` → `sha256:957861185dbf29d93668ace41e011d091c6e779953d47f0316ef2cc58e28fe2b` = Dockerfile:14. Es ist der Index-Digest, wie im Vorgänger-Muster (Vorgänger-Report belegt `golang:1.27.2` → Index `sha256:820153…`; `cf3b5b81` „Manifest-Digests … per imagetools inspect"). `make freshness-digest`: alle fünf Achsen `aktuell`; `make freshness-go`: `aktuell — gepinnt und latest sind beide 1.27.3`.
3. **Rot-Belege (je mit sofortigem `git checkout`, Baum danach sauber).**
   - smoke.sh-Fallback → `1.27.2`, `make test-bats BATS_TARGET=test/pin-fallbacks.bats`: `not ok 4` mit `smoke.sh: Fallback '1.27.2' != Makefile GO_VERSION '1.27.3' (Pin-Zug ohne Fallback)`; 1–3, 5 grün.
   - full-smoke.sh-Fallback → `1.27.2`: `not ok 5`, übrige grün.
   - Makefile-`GO_VERSION` allein → `1.27.2`: `not ok 4` und `not ok 5` mit der gepinnten Ursache. (Ein erster Lauf direkt nach einem `git checkout` zeigte ein inkonsistentes Bild — Race im Bind-Mount; der Wiederholungslauf ist eindeutig.)
   - `DefaultGoVersion` → `1.27.2`, `make test-go`: `FAIL TestGoProfile_PinsMatchRepo … ARG GO_VERSION: generiert "1.27.2" != Repo-Dockerfile "1.27.3" (Drift, LH-QA-02)`.
4. **Wächter.** Pin-Sprung gehalten: `freshness-go` (Makefile-Pin gegen Upstream, Netz), `freshness-digest` (Digest gegen Tag, Netz), `pin-fallbacks.bats` (Fallbacks gegen Makefile), `TestGoProfile_PinsMatchRepo` (Dockerfile-ARG gegen DefaultGoVersion). Das Makefile-Dockerfile-Paar (Makefile `GO_VERSION` gegen Dockerfile `ARG`) hält kein netzloser Wächter allein; `freshness-digest` bzw. `make build` mit `--build-arg` deckt es. Bestand, vom Plan benannt, kein neuer Pin.
5. **Abgrenzung.** `git diff a40fc0a6 HEAD -- go.mod` leer; `git diff … -- Makefile` ändert nur die `GO_VERSION`-Zeile (TRAEGER_* unberührt); MR-092/093 unverändert.
6. **Mutations-Anker (MR-071).** Fälle 668/669 sind generisch auf den Wert (`[0-9.]*`), Fall 18 ebenso; kein `test/mutations/*.sh` trägt `1.27`, den Digest oder `820153` als Anker. `make mutate-greift` → `762 Fall/Faelle, 762 greifen, 0 Befund(e)`. `make mutate-auswahl` (CI-Branch, Exit 10) wurde von diesem Review nicht gefahren; der Branch-Lauf liegt beim Aufrufer.

## Geprüft, ohne Befund

- Pin-Vollständigkeit und Alt-Digest: ohne Befund.
- Digest-Herkunft: ohne Befund.
- Rot-Belege (§3.6): ohne Befund, drei statt zwei gefahren.
- Wächter-Deckung: ohne Befund.
- go.mod / TRAEGER_*-Abgrenzung: ohne Befund.
- Kommentare (§3.7): der Diff ändert keinen Kommentar; ohne Befund.
- Host-Toolchain (§3.9): nur `make`/`docker`; ohne Befund.
- Gate-Lockerung, ADR-Verstoß: keine.
