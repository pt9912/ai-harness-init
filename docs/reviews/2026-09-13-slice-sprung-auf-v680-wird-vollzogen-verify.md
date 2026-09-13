# Verifikation slice-sprung-auf-v680-wird-vollzogen — Baum-Tausch v6.7.2 → v6.8.0

**Rolle:** Verifier (Modul 8/11) — „Bauen wir es richtig?" gegen DoD, Plan und `ADR-0047`. Kein
Self-Review: dieser Lauf hat an keinem der geprüften Commits geschrieben. **Geprüfter Stand:**
`0565f274` (HEAD, `main`), `git status --porcelain` leer. **Gegenstand:** sieben Commits
`f8e602b7`/`8403bbd8`/`2a0b0f9c`/`2d10d5ff` (Implementer) · `355172da`/`47c4cb3b` (Architect) ·
`0565f274` (Reviewer). Alle Sonden unten sind lesend (`git show`, `git diff`, `grep`, `find`,
`sha256sum`); kein Docker-Ziel selbst gefahren.

**Bezug:** [`ADR-0047`](../plan/adr/0047-ziel-fassung-regiert-den-sprung-v680.md),
[`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`LH-FA-09`](../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren).

---

## 1. Ist der Sensor gelaufen?

```sh
bash harness/tools/working-tree-hash.sh
# -> 4dec4d0c138f826a75710baa0e5c401e8b44e92f54a081c5a94a55aed790fe35
```

Deckt sich byte-identisch mit dem Reviewer-Commit-Beleg (`0565f274`: „`make docs-check` gruen:
1299 Datei(en) geprueft, 0 Befund(e)") und mit dem DoD-Anspruch „Stempel deckungsgleich mit
`working-tree-hash.sh` über dem sauberen Arbeitsbaum". Arbeitsbaum ist clean (`git status
--porcelain` leer). `make gates` ist damit real gefahren und über dem finalen Stand — **bestätigt**.

## 2. Deckt der Sensor die Zusage? — der sha256

Der Implementer berichtet, den Pin-Wert nicht übernommen, sondern über einen bewussten
Fehlversuch (`SHA256Mismatch`) ermittelt zu haben. Geprüft, was `Got` in diesem Fehlerpfad
tatsächlich ist:

```go
// internal/fetch/baseline.go:152
if got := hex.EncodeToString(sha256Sum(data)); got != wantSHA {
    return &SHA256Mismatch{Tag: tag, Want: wantSHA, Got: got}
}
```

`data` ist an dieser Stelle bereits `readCapped(rc, maxBaselineBytes)` — die tatsächlich vom
Release-Asset heruntergeladenen Bytes, **vor** jedem Entpacken (Kommentar: „Setzung 1: Hash VOR
dem Entpacken. Danach ist die Herkunft nicht mehr prüfbar"). `Got` ist also der sha256 der real
heruntergeladenen Datei, berechnet mit demselben Code, der später den Pin verifiziert — keine
zweite, unabhängige Quelle, aber auch keine Übernahme aus einer Erwartung. Das erfüllt „gemessen,
nicht erfunden" im Sinne von `AGENTS.md` §3.6/`LH-QA-02`: Der bewusst falsche `wantSHA`-Erstlauf
ist die **rot gesehene** Instanz, und `Got` aus deren Fehlermeldung ist die Messung. Eine separate
`sha256sum` auf eine zweite heruntergeladene Kopie wäre eine unabhängigere Quelle, ist aber nicht
nötig, um die Zusage „gemessen, nicht erfunden" zu tragen — **bestätigt, keine Nacharbeit nötig**.

## 3. Plan-vs-Code — die drei DoD-Liefer-Punkte

### Liefer-Punkt 1 — Adress-Nachzug

```sh
readlink .claude/rules/*.md | grep -c '\.harness/baseline/'                          # 7
readlink .claude/rules/*.md | grep '\.harness/baseline/' | grep -vc 'baseline/v6\.8\.0/'  # 0
PS=( '*.md' ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' \
     ':!docs/plan/carveouts/done' ':!docs/plan/planning/observations' )
git grep -oE '\]\([^)]*\.harness/baseline/v6\.7\.2[^)]*\)' -- "${PS[@]}" | wc -l      # 0
git grep -oE '`[^`]*\.harness/baseline/v6\.7\.2[^`]*`'     -- "${PS[@]}" | wc -l      # 3
```

Null Links, wie zugesagt. Die drei verbliebenen Inline-Treffer sind geprüft: zwei sitzen im
in-progress-Plan selbst (§1/§6, ausdrücklich als Vorzustands-Messung deklariert) bzw. in
`slice-213` (`open/`, dieselbe Klasse — beide vom Implementer-Commit `2a0b0f9c` explizit benannt),
der dritte in `docs/plan/adr/0045-…md:91`, einer **Accepted**-ADR (`Status: Accepted`) — genau die
nach `AGENTS.md` §3.4/§3.11 gesperrte, bewusst stehen gelassene Klasse. Alle drei sind Aussagen,
keine Adressen — **bestätigt**.

### Liefer-Punkt 2 — Freshness-Review des Adaptions-Blocks

Für den einzigen Kandidaten mit ausgeschriebener Substanz-Prüfung (Suchhilfe 3: neue Sektion
`modul-11-verification.md` §Bewusstes Brechen vs. `AGENTS.md` §3.6) liegt in `47c4cb3b` eine
nachvollziehbare, saubere Begründung vor, warum kein neuer `MR`-Eintrag folgt (Ergänzung ohne
Einschränkung ist keine Adaption, MR-031-Präzedenzfall). Für die zehn Suchhilfe-1- und zwei
Suchhilfe-2-Kandidaten (`MR-002/003/010/011/014/024/035/051/054/056`) zeigt `355172da` **nur**
Adress-Nachzug, keine Sach-Prüfung im Diff sichtbar. Das ist mit der Baseline-Regel konsistent —
Ausgang *bleibt gültig* heißt wörtlich „stehen lassen", hinterlässt also **keine** Spur im Eintrag
— aber dieselbe Baseline-Regel macht damit „geprüft und bleibt gültig" von „nicht geprüft"
ununterscheidbar, sobald keine Notiz existiert. Ich kann diese zehn/zwölf Fälle nicht unabhängig
bestätigen; ich kann nur feststellen, dass ihr Fehlen einer Notiz kein Gegenbeweis ist.

**Zur Zuweisung des Durchgangs-Berichts an den Planner (§7):** korrekt. Der Plan selbst sagt es
explizit — „Der Liefer-Punkt ist erfüllt, wenn die Liste vollständig abgearbeitet ist … Ein leeres
Ergebnis ist ein Ergebnis **und wird in §7 notiert**" — und `AGENTS.md` §3.10 bindet die
Closure-Notiz ohnehin an den Planner-Kontext. Das hängt nicht in der Luft; es hat eine benannte
Adresse. Was der Planner beim Schreiben von §7 ergänzen sollte, ist keine neue Arbeit, sondern eine
**Bestätigung**: dass die Sach-Prüfung der zehn/zwölf Kandidaten tatsächlich stattfand (und nicht
nur ihr Adress-Nachzug) — sonst steht im Closure-Log ein „leeres Ergebnis", das niemand außer dem
Architect-Lauf selbst gesehen hat.

### Liefer-Punkt 3 — `docs/migrations/v6.8.0.md`

```sh
find .harness/baseline/v6.8.0/templates -name '*.template.md' | wc -l   # 25
grep -cE '^\| `\.harness/baseline/v6\.8\.0/templates/' docs/migrations/v6.8.0.md   # 21
```

21 Tabellenzeilen (14 Buchstabe a + 7 Buchstabe b) + 4 Bullet-Zeilen unter „Ausgenommen" = 25 —
die Vollständigkeit stimmt.

**Befund, der die zentrale Zusage dieses Liefer-Punkts falsifiziert:** Der Report behauptet „alle
25 Vorlagen sind über die zwei Tags byte-gleich" (Zeile 9, wortgleich in `ADR-0047` §Kein
Vorlagen-Delta) und leitet daraus „durchgehend *schon erfüllt*/*keine Instanz*, nie *übernommen*
oder *bewusst abweichend*" ab. Direkt gegen die in diesem Repo committeten vendored Bäume beider
Tags geprüft:

```sh
for rel in $(git ls-tree -r --name-only f8e602b7 -- .harness/baseline/v6.8.0/templates \
             | sed 's#^\.harness/baseline/v6.8.0/templates/##'); do
  a=$(git show f8e602b7^:".harness/baseline/v6.7.2/templates/$rel" 2>/dev/null | sha256sum)
  b=$(git show f8e602b7:".harness/baseline/v6.8.0/templates/$rel" 2>/dev/null | sha256sum)
  [ "$a" = "$b" ] || echo "DIFFERS: $rel"
done
# -> DIFFERS: AGENTS.template.md
# -> DIFFERS: harness/conventions.template.md
```

Zwei von 25 Vorlagen sind **nicht** byte-gleich — beide unterscheiden sich exakt im eingebetteten
Beispiel-URL-Literal (`.../download/v6.7.2/lab-regelwerk.zip` → `.../v6.8.0/…`), das der
Kurs-Upstream selbst in seinen Skelett-Vorlagen führt. Das ist genau die Klasse, die `AGENTS.md`
§3.6 als Beispiel für eine unbelegte Zusage nennt („Falsch: 'Byte-Gleichheit belegt make smoke',
ohne smoke gelesen zu haben"): Die Aussage „byte-gleich" wurde nicht gegen den eigenen vendored
Baum gemessen (sonst wäre der Widerspruch aufgefallen), sondern aus `ADR-0047`s eigener,
gegen den externen Kurs-Klon gefahrener Messung übernommen.

**Konsequenz für die Zeilen-Klassifikation selbst: keine.** Für beide betroffenen Zeilen bleibt
*schon erfüllt* materiell richtig — `AGENTS.md` und `harness/conventions.md` tragen in diesem Repo
bereits die neue, korrekte Tag-URL (durch Liefer-Punkt 1 nachgezogen), erfüllen also die neue
Vorlagenfassung unabhängig davon, ob die zwei Vorlagenfassungen sich untereinander unterscheiden.
**Aber die im Report zitierte Begründung „byte-gleich `v6.7.2`..`v6.8.0`" ist für genau diese zwei
Zeilen falsch**, und der pauschale Befund-Satz „Kein Ausgang *übernommen* oder *bewusst
abweichend* ist aufgetreten … ohne neue Instanz-Arbeit auszulösen" verdeckt, dass die
Delta-Freiheits-Prämisse selbst nicht uneingeschränkt gilt.

## 4. §6-Risiken — Formkonformität

Alle sechs Risiken tragen weiterhin `<eingetreten / entfallen / weiter offen>` — für einen Slice in
`in-progress/` korrekt (Ausgänge sind Planner-Arbeit bei Closure, `AGENTS.md` §3.10). Kein Risiko
ohne Platzhalter, keines vorzeitig zugewiesen.

## 5. DoD-Häkchen und Rollen-Zuschnitt

Kein Häkchen gesetzt (`grep -c '^- \[x\]'` → 0) — korrekt, das ist Planner-Arbeit. Jeder der sieben
Commits berührt ausschließlich Artefakte einer Rolle und nennt sie in der Message (`§3.8`-Muster
für die zwei Architect-Commits, `ADR-0028` für den Reviewer-Commit) — geprüft per `git show
--stat` über alle sieben, keine Vermischung gefunden.

---

## Verdikt

**DoD erfüllt, mit einer benannten Einschränkung an Liefer-Punkt 3.**

Was der Planner abhaken darf:

1. **Liefer-Punkt 1** (Adress-Nachzug) — vollständig erfüllt, Null-Adressen-Zusage über Links und
   Symlinks bestätigt, die drei verbliebenen Inline-Treffer korrekt als eingefrorene/datierte
   Aussagen erklärt.
2. **`make gates`-Stempel** — real gefahren, Hash deckungsgleich über dem finalen (`0565f274`)
   Stand.
3. **§3.8-Commit-Zuschnitt** — sauber über alle sieben Commits.
4. **Reviewer-Nachzug** (`0565f274`) — korrekt bei der ausführenden Rolle (`ADR-0028`), Ziele
   existieren im neuen Baum.
5. **Der sha256-Mess-Weg** (Punkt 2 oben) — methodisch tragfähig, keine Nacharbeit nötig.

Was in §7 (Closure) gehört, nicht hier entschieden wird:

- Der Freshness-Durchgangsbericht (Liefer-Punkt 2) — korrekt beim Planner, wie der Plan selbst
  vorschreibt; **aber** die Closure-Notiz sollte festhalten, dass die Sach-Prüfung der zehn/zwölf
  Suchhilfe-Kandidaten tatsächlich erfolgt ist (und nicht nur ihr Adress-Nachzug) — sonst ist das
  „leere Ergebnis" eine unbestätigte Behauptung.
- Die `.harness/skills/reviewer.md`-Zeile 4 (`Baseline: v6.7.2 (Kurs-Welle 134)`) ist **keine
  DoD-Verletzung dieses Slice** — sie ist Ziel-Form-Provenienz für Modul 10, das dieser Sprung
  nicht ändert (die vier geänderten Regelwerks-Dateien sind `README.md`, `modul-05`, `modul-11`,
  `modul-13`); der Migrations-Report bestätigt zusätzlich, dass `reviewer.template.md` selbst
  „schon erfüllt" ist. Zu Recht unangetastet, außerhalb des Scopes von §1.

**Offener Punkt, an den Planner zu geben (nicht blockierend für die Closure, aber zu vermerken):**
Liefer-Punkt 3s Beleg-Satz „alle 25 Vorlagen sind byte-gleich" ist für zwei Zeilen
(`AGENTS.template.md`, `harness/conventions.template.md`) sachlich falsch, gemessen direkt gegen
die in diesem Repo committeten vendored Bäume (Befund oben, Abschnitt 3, Liefer-Punkt 3). Die
Zeilen-Klassifikation selbst (*schon erfüllt*) bleibt in der Sache richtig — der Fehler liegt in
der zitierten Begründung, nicht im Ergebnis. Empfehlung: `docs/migrations/v6.8.0.md` Zeile 9 und
die betroffenen Beleg-Zellen präzisieren („alle 25 Vorlagen erfüllen bereits die neue Fassung; 23
sind zudem byte-gleich, 2 unterscheiden sich im Beispiel-URL-Literal") und in der Closure-Notiz als
Steering-Loop-Kandidat vermerken — eine „byte-gleich"-Zusage sollte künftig gegen den **eigenen**
vendored Baum, nicht nur gegen die im ADR zitierte externe Kurs-Klon-Messung geprüft werden. Ob das
einen Adaptions-Eintrag oder nur eine Korrektur des Reports rechtfertigt, ist Architect-/
Planner-Urteil, kein Verifier-Urteil.
