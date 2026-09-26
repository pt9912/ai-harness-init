# Review-Report: ADR-0068 — Kurzrunde vor dem Accept — 2026-09-26

**Review-Art:** Kurzrunde nach einem blockierenden Befund (`ADR-0040` Festlegung 2: der Accept verlangt eine erneute Runde der prüfenden Rolle). Die Konsistenz-Runde `2026-09-26-review-adr-0035-0068-0069-konsistenz` meldete für `ADR-0068` ein MEDIUM (R-68-1) und zwei LOW (R-68-2, R-68-3); der Architect hat korrigiert (Verdikt `2026-09-26-architect-verdikt-korrektur-adr-0035-0068-0069`). Die Kurzrunde `2026-09-26-review-kurzrunde-adr-0035-f5-und-adr-0069-f2` hat `ADR-0068` nicht geprüft. Geprüft wird **nur**, ob die Korrekturen die drei Findings tragen und keine neue Inkonsistenz einführen.

**Gegenstand:** `docs/plan/adr/0068-der-nachzug-nennt-den-zustand-des-tap-nur-soweit-die-antwort-ihn-traegt.md` (Status `Proposed`) in der korrigierten Fassung — Titel, Festlegung 3 samt benanntem Rest, Alternative F, Trigger 3, Fitness-Zeilen, §Grenze — gegen `harness/tools/tap-nachzug-nutzlast.sh`, `test/tap-nachzug.bats`, `ADR-0064` Festlegung 2 und 3, `ADR-0066`, den ADR-Index. HEAD `18cd5bb2`, Baum sauber bei Beginn.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13) · **Modell:** Sonnet 5 · **Datum:** 2026-09-26

**Eigene Läufe** — ausschließlich in Scratchpad-Kopien (`git archive HEAD`), `bats` im gepinnten Bild des Makefiles (`docker run --rm --network none -v <Kopie>:/code:ro …`); kein Schreibzugriff im Repo-Baum, kein Tap-Zugriff, kein `make mutate`, keine Host-Toolchain.

| Lauf | Ergebnis |
|---|---|
| `test/tap-nachzug.bats --filter 'sync (abgelehnt\|teilerfolg)'`, unverändert | `1..2`, beide `ok` |
| Schwächung A: die Bedingung `[ "$geschrieben" = ja ]` in `nicht_lesbar()` (`…-nutzlast.sh:107`) durch `false` ersetzt, `diff` genau eine Zeile | `not ok 2` (*sync teilerfolg*), Ausgabe: `… (HTTP 404) — es wurde nichts verglichen`, `[[ "$stderr" == *"das Schreiben ist bereits erfolgt"* ]]' failed`; `ok 1` |
| Schwächung B: die Meldung nach dem Vollzug (`…-nutzlast.sh:108`) trägt zusätzlich `es wurde nichts verglichen`, `diff` genau eine Zeile | `not ok 2`, `nirgends 'nichts verglichen' "$TMP/stderr-$code"' failed`; `ok 1` — beide Schwächungen der Fitness-Zeile 2 sind reproduziert |
| Zusatzfall (nur in der Kopie, nicht im Repo): `cmp` liefert **nach** dem Schreiben Status 2 (Wrapper prüft `STUB_WRITTEN`), Lauf 1; danach ein erneuter Lauf mit echtem `cmp`, Tap trägt die geschriebenen Bytes | Lauf 1: Exit 2, 1 Schreibaufruf, Meldung ohne `unverändert` und ohne `bereits erfolgt`; Lauf 2: Exit 0, Meldung `gleich`, 0 Schreibaufrufe — die Aussage des benannten Rests (*nie Grün, nie „unverändert", erneuter Lauf meldet „gleich" und schreibt nichts*) gilt **im Stub**; der Signal-Weg ist nicht gefahren |
| Kommandos aus §Kontext (`sed -n '/^schreibe()/,/^}/p' … \| grep -E …`, `grep -nE 'exit (0\|10\|2)\b\|beende 2' …`) | `200`, `401`, `403`, `409`, `000`, `*)` in der genannten Aufteilung; die Nutzlast endet mit den Status 0, 10 und 2 (`trap 'exit 2' …` Zeile 80, `beende 2` Zeile 92, `exit 10` Zeilen 282 und 295) — stimmt |
| `grep -n 'teilerfolg' test/tap-nachzug.bats` | genau ein Fall (Zeile 946); er prüft Lesecodes 404, 401, 403, 429, 500 und 000 nach dem Schreiben (alle drei Zweige von `lese_tap`) und `nirgends 'nichts verglichen'` |
| ADR-Index Zeile 75 gegen die Datei | Titel byte-gleich (`grep -c -F` → 1), Status `Proposed`, Bezug-Liste (ADR-0064, ADR-0066, ADR-0062, ADR-0040, MR-025, LH-QA-02) gleich der Datei; `ADR-0064` und `ADR-0066` nennen `0068` nicht (Folgepflicht 2 gilt) |

---

## Findings

Kein HIGH, kein MEDIUM.

**Die drei Findings der Vorrunde tragen:**

- **R-68-1** (Reichweite von *„jede Meldung"*) — behoben. Titel und Festlegung 3 (Zeilen 1 und 142-151) sprechen nur noch über die Nachkontrolle bei unlesbarem Tap; das entspricht `lese_tap` → `nicht_lesbar()` (`…-nutzlast.sh:106-125`) und ist durch `sync teilerfolg` mit beiden Schwächungen rot gebunden (Läufe A und B). Die drei übrigen Wege (`gleich`, Zweig `*)` in `beende`, Signal-Trap) stehen als benannter Rest (Zeilen 153-164), mit Trigger 3 (Zeilen 257-262) und Fitness-Zeile 4 *„kein Fall"* (Zeile 238). Jede der drei Aussagen des Rests stimmt mit dem Code (`gleich` Zeilen 129-138, `beende` Zeilen 60-77, Trap Zeile 80).
- **R-68-2** (Häufigkeit von 401) — behoben; `grep -n 'häufigste' <ADR>` ohne Treffer, Alternative C (Zeile 177) nennt die Häufigkeit als ungemessene Annahme.
- **R-68-3** (Reichweite) — behoben in §Was die Wahl trägt (Zeilen 104-106) und §Grenze (Zeilen 214-217); die Aussage benennt den Rand. Zu ihr K-68-3 und K-68-5.

### LOW

**K-68-1** — `kategorie`: LOW · `quelle`: `AGENTS.md` §3.6 (die Zusage nennt eine Beobachtungsform, die der Code nicht erzeugt) · `pfad`: `0068-…md:249` (Trigger 1) gegen `harness/tools/tap-nachzug-nutzlast.sh:256` · `befund`: Trigger 1 nennt als beobachtbare Meldung *„Ausgang des Schreibens ungewiss (HTTP <Status>)"*. Der Code schreibt `Ausgang des Schreibens ungewiss: unerwartete Antwort der Schnittstelle (HTTP $code) — …`; die Zeichenfolge der ADR kommt in keiner Ausgabe vor, ein Leser, der danach sucht, findet nichts. · `verifizierbar`: ja (`grep -n 'ungewiss' harness/tools/tap-nachzug-nutzlast.sh`) · `klasse`: „zitierte Meldung im Trigger entspricht nicht der Ausgabe des Codes"

**K-68-2** — `kategorie`: LOW · `quelle`: `AGENTS.md` §3.6, `ADR-0064` Festlegung 2 (Cache-Fenster) · `pfad`: `0068-…md:159-163` (benannter Rest, *„gefahrarm"*) · `befund`: Der Rest sagt, ein weiterer Lauf lese und vergleiche vor jedem Schreiben und melde bei geschriebenen Bytes *„gleich"*. Im Stub gilt das (Zusatzfall oben). Am realen Tap führt `ADR-0064` (§Lage) ein Cache-Fenster (`max-age=60`), dessen Verhalten nach einem Schreiben **nicht beobachtet** ist; liest der erneute Lauf innerhalb des Fensters den Stand davor, endet er nicht mit *„gleich"*, sondern schreibt gegen den alten Blob-Stand und meldet 409 mit *„Tap unverändert"*. Die Zusage ist unbedingt formuliert, ihre Bedingung nicht genannt. · `verifizierbar`: nein (am realen Tap nicht herstellbar; Stub-Lauf belegt nur den ungestörten Fall) · `klasse`: „Wiederholungs-Zusage ohne die Bedingung des bekannten Cache-Fensters"

**K-68-3** — `kategorie`: LOW · `quelle`: `AGENTS.md` §3.6 (Zusage nennt, was passieren müsste, damit sie bricht) · `pfad`: `0068-…md:216-217` (§Grenze, erster Punkt) gegen `:193-196` (Konsequenz Positiv) · `befund`: §Grenze schränkt *„die Zusage ‚nie eine falsche Zustandsaussage'"* auf die Menge unter der Annahme ein. Diese Zeichenfolge steht sonst nirgends in der ADR (`grep -n 'falsche Zustandsaussage'` → Zeile 216 und die Geschichte-Zeile); die Zusage der Konsequenz lautet *„sagt nie mehr über das Tap, als die Antwort trägt"*. Die Einschränkung zitiert also einen Wortlaut, den die ADR nicht führt. · `verifizierbar`: ja (`grep`) · `klasse`: „Einschränkung zitiert eine Zusage, die im Text anders lautet"

**K-68-4** — `kategorie`: LOW · `quelle`: `AGENTS.md` §3.6 · `pfad`: `0068-…md:82-84` (*„kein Fall sie bindet"*), `:238` (Fitness-Zeile 4), `:160-161` (*„kein Ausgang ist je ‚unverändert', der Exit bleibt 2"*) · `befund`: Zwei Ungenauigkeiten an derselben Stelle. (1) *„kein Fall bindet sie"* gilt nur für die Lage **nach** einem 200 des Schreibaufrufs: dieselben Meldungen (`der Vergleich lief nicht (cmp Exit 2)`, `interner Fehler der Nutzlast`) sind in `test/tap-nachzug.bats` gebunden (Zeilen 617, 642, 650, 667) — im Modus `check` bzw. vor dem Schreiben. (2) Die Begründung *„gefahrarm: nie ‚unverändert', Exit 2"* ist selbst eine Zusage über die drei Wege, die Fitness-Zeile 4 als *„Ist-Zustand, kein Versprechen"* und ohne Fall führt; ein Test, der sie über `sync` **nach** dem Schreiben bindet, existiert nicht (ich habe sie im Scratchpad für den `cmp`-Weg gefahren: Exit 2, kein *unverändert*). · `verifizierbar`: ja (`grep -n 'cmp Exit\|interner Fehler der Nutzlast' test/tap-nachzug.bats`) · `klasse`: „*kein Fall* ohne Angabe, für welche Lage"

**K-68-5** — `kategorie`: LOW · `quelle`: `ADR-0040` Festlegung 3 / Baseline `modul-04-adrs.md` (Re-Evaluierungs-Trigger: beobachtbare Bedingung je benanntes Risiko) · `pfad`: `0068-…md:214-217` (§Grenze, Bruch der Annahme) gegen `:248-253` (Trigger 1) · `befund`: R-68-3 ist mit dem Satz *„Bricht sie, ist ‚Tap unverändert' für den betroffenen Status falsch"* behoben; Trigger 1 beobachtet aber nur den Rand **nach außen** (ein Status außerhalb von 401, 403, 409, oder ein Schutz des Tap). Der Bruch **innerhalb** der Menge — eine Meldung *„Tap unverändert"*, auf die ein `make tap-check` das Tap als geschrieben zeigt — hat keinen Trigger; die benannte Grenze ist damit die einzige der drei ohne Beobachtungsbedingung. · `verifizierbar`: nein · `klasse`: „benannte Grenze ohne zugehörigen Trigger"

### INFO

**K-68-6** — Die Tabelle der Alternativen (Zeilen 175-180) führt A, B, C, D, F und dann E (gewählt); ein Leser sucht ein E vor F, der Verweis *„Alternative F"* in Trigger 3 und *„Warum E und nicht F"* lösen jedoch auf. Reine Darstellung.

### Geprüft, ohne Befund

**(a) Festlegung 3 gegen den Code, zeilenweise:** *„Lesen endet mit jedem Status außer 200 oder ohne Antwort"* = `lese_tap` (`case "$code"`, `|| code=000`, Zeilen 115-126); *Meldung nennt den Vollzug und `make tap-check TAG=<tag>`* = `nicht_lesbar()` Zeile 108; *vor dem Schreiben bleibt es bei „nichts verglichen"* = Zeile 110; *Klasse 2* = `fehler` → `beende 2`; `cmp` Exit ≥ 2 = `gleich` Zeile 137; `beende`-Zweig `*)` = Zeilen 71-75; Signal = Trap Zeile 80. **Ehrlichkeit der Fitness-Zeile 4:** nach dem Schreiben bindet kein Fall einen der drei Wege (mit K-68-4). **Rot-Beleg:** Schwächung A und B reproduziert (Tabelle). **(b) Konsistenz mit `ADR-0064` Festlegung 2/3 und `ADR-0066`:** kein Widerspruch; `ADR-0064` nennt Ursachen statt Statuscodes und regelt *„ohne Antwort … ungewiss"* — die Antwort außerhalb beider Fälle füllt `ADR-0068`, ohne einen Satz abzulösen; die Klassen 0, 1, 2 und die Zeile `tap-sync: Exit N` bleiben; *„ungewiss"* ist die sichere Richtung (behauptet nichts über den Zustand, nennt das lesende Werkzeug, Exit bleibt 2, nie Grün). **(c) Zustandsform und Adressen:** die ADR nennt Reviews und Verdikte in Geschichte und Acceptance-Trigger als Kennung, nicht als Pfad-Link (`AGENTS.md` §3.11); die Pfade im Text (`harness/tools/…`, `test/tap-nachzug.bats`, `docs/reviews/` als stehende Ablage) sind ortsfest; keine Slice-Adresse (`grep -n 'slice-\|docs/plan/planning'` → nur die Geschichte-Kennung des Reviews); Kennungs-Form ADR-/MR-/LH-. **Trigger-Liste:** Trigger 1 (Status außerhalb / Schutz), 2 (fünfte Form), 3 (Rest) — vollständig bis auf K-68-5; Wer-beobachtet-Absatz nennt die Lücke des Laufs außerhalb einer Closure. **Acceptance-Trigger:** *„Report ohne blockierenden Befund an der Substanz"* — mit diesem Report erfüllt; die Darstellungs-Findings hindern die Annahme nicht. **(d) Index:** Zeile 75 stimmt mit der Datei (Tabelle).

---

## Accept-Empfehlung ADR-0068: **ja nach Korrektur** (nicht blockierend)

Die Korrekturen tragen R-68-1 bis R-68-3: die eingeschränkte Festlegung 3 stimmt zeilenweise mit dem Code, ist durch `sync teilerfolg` in beiden Schwächungen rot gebunden, und der Rest ist benannt, mit Trigger und ehrlicher Fitness-Zeile *„kein Fall"*. Kein blockierender Befund an der Substanz; der Acceptance-Trigger ist mit diesem Report erfüllt. Nach dem Accept ist die Datei nicht mehr änderbar (`AGENTS.md` §3.4) — die fünf LOW-Tokens sind Darstellung, aber Zusagen-Wortlaut und deshalb **vor dem Accept** zu korrigieren; sie hindern die Annahme, wenn der Auftraggeber sie so annimmt, nicht.

**Tokens vor dem Accept** (Datei `docs/plan/adr/0068-…md`, Zeilen der Fassung HEAD `18cd5bb2`):

1. Zeile 249 (K-68-1): `ungewiss (HTTP <Status>)` → der Ausgabe entsprechend `ungewiss: unerwartete Antwort der Schnittstelle (HTTP <Status>)`.
2. Zeilen 160-163 (K-68-2): die Zusage *„meldet ‚gleich'"* an die Bedingung des Cache-Fensters aus `ADR-0064` binden (oder als im Stub belegt, am realen Tap unbeobachtet kennzeichnen).
3. Zeile 216 (K-68-3): das Zitat *„nie eine falsche Zustandsaussage"* durch den Wortlaut der Konsequenz (Zeile 193, *„nie mehr über das Tap, als die Antwort trägt"*) ersetzen.
4. Zeilen 82-84 und 238 (K-68-4): *„kein Fall"* auf die Lage nach einem 200 des Schreibaufrufs einschränken; die Begründung *„nie ‚unverändert', Exit 2"* als ungebunden kennzeichnen.
5. Zeilen 248-253 (K-68-5): Trigger 1 um den Bruch innerhalb der Menge ergänzen (Meldung *„Tap unverändert"*, nachfolgender `make tap-check` zeigt das Tap als geschrieben). Optional Zeilen 175-180 (K-68-6): Reihenfolge der Alternativen.

Nicht geprüft: das Verhalten des realen Tap (kein Zugriff, keine Messung; das benennt die ADR selbst), der Signal-Weg (nicht gefahren), die Prozedur `docs/user/releasing.md`.

## Zusammenfassung

| Gegenstand | HIGH | MEDIUM | LOW | INFO | Accept-Empfehlung |
|---|---|---|---|---|---|
| ADR-0068 (korrigierte Fassung) | 0 | 0 | 5 (K-68-1 bis K-68-5) | 1 (K-68-6) | ja nach Korrektur (Darstellung, nicht blockierend) |

Übergabe: Architect — die fünf Tokens (Wortlaut der ADR; die Wahl der Formulierung trifft nicht der Reviewer). Steering-Loop-Klassen: „zitierte Meldung im Trigger entspricht nicht der Ausgabe des Codes", „*kein Fall* ohne Angabe, für welche Lage", „benannte Grenze ohne zugehörigen Trigger".
