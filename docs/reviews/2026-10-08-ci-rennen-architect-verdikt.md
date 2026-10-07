# Architect-Verdikt: der `ci`-Lauf am Pin-Commit wartet die Publikation ab

**Rolle:** Architect. **Datum:** 2026-10-08.
**Eingang:** `slice-ci-wartet-die-publikation-des-gepinnten-releases-ab` (in `open/`), DoD-Liefer-Punkt 1;
Register `BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases` (Ausgang *geplant*).
**Bezug:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[ADR-0058](../plan/adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md),
[ADR-0059](../plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md),
[`MR-014`](../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions),
[`MR-069`](../../harness/conventions.md#mr-069--ein-job-der-bewusst-nicht-auscheckt-trägt-seine-prüfung-inline).

## Verdikt

**Keine ADR.** Gewählt ist ein **begrenztes Warten vor `make full-smoke`** im `ci`-Job `full-smoke` —
Variante (a), aber im Workflow, nicht in `traeger-fetch`. Keine fail-closed-Grenze verschiebt sich:
das Warten urteilt nicht, `full-smoke` läuft danach unverändert und bricht bei weiter fehlendem
Asset mit derselben Zeile `AUSGANG LEITUNG` wie heute. Ein Gate wird weder gesenkt noch umgangen
([`AGENTS.md`](../../AGENTS.md) §3.5 greift nicht); keine Accepted-ADR wird berührt.

## Festlegungen an den Implementer

1. **Träger:** ein versioniertes Skript unter `harness/tools/` (von `shell-lint` gedeckt, Regelform
   aus `MR-014`/`MR-069`), aufgerufen über ein eigenes Make-Target — die CI ruft nur `make`-Ziele
   ([`harness/README.md`](../../harness/README.md) §Safety and scope boundaries). Das Target steht in
   §Werkzeuge mit `kein Gate`. Im Job `full-smoke` läuft es als Schritt vor `make full-smoke`, für
   jedes Ereignis — ist das gepinnte Release schon veröffentlicht (jeder Push außer dem Schnitt),
   endet es beim ersten Versuch.
2. **Bedingung:** es fragt die Release-Assets von `TRAEGER_TAG` ab, die der Fetch holt
   (`SHA256SUMS` nach ADR-0059 und das Linux-amd64-Asset des Runners), über dasselbe gepinnte
   curl-Bild wie `harness/tools/traeger-fetch.sh` — kein Host-curl ([`AGENTS.md`](../../AGENTS.md)
   §3.9), keine neue Netz-Annahme: `full-smoke` braucht das Netz an derselben Stelle schon.
3. **Grenze:** höchstens **15 Minuten**, danach Exit 0 mit einer Zeile, dass die Grenze erreicht
   ist — das Urteil fällt in `full-smoke`, nicht im Warten. Maß: `release.yml` brauchte zuletzt
   zwischen 2:36 und 3:15 Minuten
   (`gh run list --workflow release.yml --limit 6 --json createdAt,updatedAt`), die Grenze ist das
   Fünffache des Maximums. Rot gesehen (DoD 2) wird an der realen Quelle: `TRAEGER_TAG` auf einen nie
   veröffentlichten Tag, Grenze per Variable verkürzt — der Lauf endet in `AUSGANG LEITUNG`.
4. **`traeger-fetch` bleibt unberührt**, auch die emittierte Fassung: der Adopter hat kein Rennen,
   sein Pin zeigt auf ein veröffentlichtes Release. Damit entfällt die Rückführung „Workflow und
   Fetch zugleich" aus §4 des Slice-Plans; die Planzeile zu `traeger-fetch.sh` fällt weg, das neue
   Skript und `harness/README.md` kommen hinzu.
5. **`docs/user/releasing.md` Schritt 6:** der Re-Run entfällt im Regelfall; er bleibt der Ausgang,
   wenn die Grenze überschritten ist — dann ist ein falscher Pin oder ein hängender Release-Lauf
   wahrscheinlicher als das Rennen.

## Verworfen

- **(b) Tag zuerst, Pin-Commit danach:** der Tag trüge den alten Pin — bricht die Kopplung von Pin
  und Werkzeug-Fassung im selben Commit (ADR-0058 Festlegung 2, ADR-0059). Wäre eine Folge-ADR mit
  `Supersedes`, für ein Problem, das ohne sie lösbar ist.
- **(c) auf den vorigen Release ausweichen:** misst am Pin-Commit eine andere Fassung als die
  gepinnte — ein Ausweichen, das ADR-0058 Festlegung 2 ausschließt, und eine Senkung nach §3.5.
- **(d) `release.yml` stößt `ci` neu an:** der erste Lauf bleibt rot im Verlauf; der Closure-Trigger
  des Slice (grün im ersten Versuch) bliebe unerreichbar, und ein zweiter Workflow-Pfad koppelt zwei
  Dateien, wo ein Schritt genügt.

## Akzeptiertes Negativ

Ein falsch gesetzter Pin bricht erst nach der Grenze statt sofort (Slice-Plan §6, Risiko 1). Hingenommen,
weil der Fall selten ist, `test/traeger-fetch.bats` die Kopplung
der Pin-Stellen weiter sofort hält und der Bruch nach höchstens 15 Minuten laut kommt. Kein
eigener Register-Eintrag, kein Folge-Slice.
