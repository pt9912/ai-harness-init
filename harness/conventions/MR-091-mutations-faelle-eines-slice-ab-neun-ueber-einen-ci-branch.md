# MR-091 — Ab neun Fällen läuft die Mutations-Probe eines Slice über einen CI-Branch, dessen Ergebnis-Job schreibt

- **Datum:** 2026-10-09
- **Wirksamkeits-Anlass:** slice-mutate-laeuft-ueber-einen-ci-branch — mit ihm laufen
  `make mutate-auswahl` und `.github/workflows/mutate-branch.yml`; die Schwelle setzte der
  Auftraggeber am 2026-10-09.
- **Geltungsbereich:** zwei Sätze zweier Einträge, sonst nichts.
  [`MR-090`](../conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)
  §Grenze, der Halbsatz *„das bleibt beim nächtlichen `make mutate`"*;
  [`MR-014`](../conventions.md#mr-014--ci-auf-frischem-klon-github-actions) §Adaption, der Satz
  *„GitHub Actions fährt bei **jedem Push und PR** …"*, soweit er Pushes nach `mutate/**` erfasst.
  Dazu die Frage, die MR-014 offenlässt: ob ein Workflow-Job schreiben darf. **Nicht** die Regel
  von [`MR-071`](../conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
  — sie bindet die Anlage eines Falls, und kein Satz von ihr nennt einen Lauf-Ort; **nicht** der
  Nacht-Workflow `mutate.yml`; **nicht** Setzung 1 von MR-014 (die CI ruft `make`), die der Weg
  einhält; **nicht** die emittierte Ebene.
- **Ersetzt-Baseline-Regel:** keine — der Eintrag schneidet Sätze eigener Einträge und tritt an
  keine Stelle des Regelwerks; nach dem Wortlaut der Eintrags-Vorlage damit kein Fork, aus demselben
  Grund wie bei [`MR-069`](../conventions.md#mr-069--ein-job-der-bewusst-nicht-auscheckt-trägt-seine-prüfung-inline).
- **Setzung 1 — die Probe läuft je Slice, vor der Verifikation, und ihr Ort folgt der Schwelle.**
  Ob ein Wächter rot wird, wartet für die Fälle eines Slice nicht auf den Nachtlauf: Vor der
  Übergabe an die Verifikation fragt der Implementer `make mutate-auswahl SLICE=<kennung>` und
  folgt dem Urteil — bis 8 Fälle lokal mit `make mutate MUTATE_CASES=…`, ab 9 per Push auf
  `mutate/<kennung>-<sha8>`. Beide Formen sind Pflicht, keine ist Wahl; die Schwelle steht allein
  im Werkzeug (`SCHWELLE` in `harness/tools/mutate-auswahl.sh`), nicht hier. Der Nachtlauf bleibt
  der Vollsweep über alle Fälle. Weg, Ergebnisform und Lese-Schritt stehen in
  [`harness/sensors/mutate.md`](../sensors/mutate.md) §CI-Branch; dort und nicht hier.
- **Setzung 2 — ein Workflow-Job darf schreiben, unter vier Bedingungen.** Zulässig ist
  `contents: write` für einen Job, wenn (a) der Workflow auf `contents: read` steht und das
  Schreibrecht allein am Job hängt; (b) der Schreib-Schritt ein `make`-Ziel ist (Setzung 1 von
  MR-014 bleibt gehalten: `make mutate-branch SCHRITT=ergebnis`); (c) er ohne `--force` genau auf
  den Ref pusht, der den Lauf ausgelöst hat, und dessen Form `mutate/<kennung>-<sha8>` vorher prüft; (d) er
  weder `main` noch einen Tag berührt — im Schreib-Schritt folgt das aus der Form-Prüfung in (c). Der `publish`-Job in `release.yml` schreibt bereits — ein
  Release-Asset, keinen Ref; diese Setzung gilt für Ref-Pushes und lässt ihn, wie er steht.
- **Setzung 3 — `ci.yml` läuft nicht auf `mutate/**`.** Der Satz *„bei jedem Push"* aus MR-014
  gilt für jeden Push außer nach `mutate/**` (`branches-ignore` in `ci.yml`); der geprüfte Commit
  bekommt seinen `ci.yml`-Lauf mit dem Push auf `main`, nicht über den Mutations-Branch.
- **Grenze.** Der Workflow läuft in der Fassung des gepushten Branch: **wer auf `mutate/**` pushen
  darf, bestimmt `mutate-branch.yml` und damit, was der Job mit `contents: write` tut** — auch einen
  Push auf `main`, soweit kein Branch-Schutz ihn verweigert. Die Bedingungen (a)–(d) schützen vor
  einem Ref-Namen, nicht vor dem Inhalt des Branch; das Recht reicht nicht weiter als das Push-Recht
  dessen, der den Branch anlegt, solange `main` nicht enger geschützt ist als `mutate/**`. **Kein
  Sensor hält (a)** — `make ci-lint` prüft Syntax, nicht die Zuordnung der `permissions`;
  (b), (c) und damit (d) im Schreib-Schritt hält `test/mutate-auswahl.bats` über einem `git`-Stub, nicht über einem realen Remote.
  Die Fallmenge wählt `# files:`; was die Auswahl verfehlt, nennt
  [`harness/sensors/mutate.md`](../sensors/mutate.md) §CI-Branch, Absatz Grenze.
- **Begründung:** Ein Satz *„bleibt beim Nachtlauf"* neben einer Pflicht-Probe je Slice verspricht
  zu wenig; der Verifier sucht den Beleg dann nicht. Das Schreibrecht ist die billigste Form, das
  Ergebnis ohne `gh` lesbar zu machen
  ([`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)): ein Actions-Artefakt
  ist nur über die API erreichbar, ein Commit im Branch über `git fetch`. Verworfen: ein
  zusätzlicher Token (mehr Recht, ein Geheimnis mehr) und ein Ergebnis allein als Artefakt (braucht
  `gh` oder die API).
- **Auflösungs-Trigger:** Der CI-Weg entfällt (der lokale Lauf trägt jede Fallmenge in vertretbarer
  Zeit, oder `slice-der-ci-lauf-ist-abrufbar` liefert das Ergebnis ohne Schreib-Commit): dann geht
  dieser Eintrag nach `done/`, und MR-090 §Grenze ist neu zu fassen. Ein zweiter Workflow will
  einen Ref schreiben: Setzung 2 trägt ihn nur, wenn er (a)–(d) erfüllt; sonst eigener Eintrag.
