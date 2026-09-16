# `make mutate` — Mutations-Sensor zu AGENTS.md §3.6

## Vertrag

Wendet ein kuratiertes Set von Mutationen an (Mutation → erwartet rot färbender Test) und
meldet jeden Wächter, der dabei **grün** bleibt — die Regel ist sonst nur im
Feedforward-Quadranten. Kein Gate ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6));
der Grund ist die Laufzeit: je Fall ein voller Sensor-Lauf.

## Grenze — was das Grün nicht abdeckt

**Vor dem Fall-Satz prüft der Lauf einen Beleg**
([`ADR-0035`](../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)):
war der letzte Lauf über demselben Prüfgegenstand vollständig grün, gibt dieser Lauf diesen
Beleg aus statt den Fall-Satz erneut zu fahren — `MUTATE_FORCE=1` erzwingt den vollen Lauf.
Die Fälle laufen auf mehrere, dynamisch zugeteilte Worker verteilt (`MUTATE_JOBS`), jeder mit
einer eigenen isolierten Kopie außerhalb des Repos; das Verdikt hängt nicht an der
Worker-Zahl (Zeit-, keine Verdikt-Stellschraube). Der Lauf begrenzt seine eigene Stille
(`MUTATE_STALL_SECONDS`) und wird rot, wenn kein Worker mehr zieht oder abschließt.

**Was er nicht deckt, steht im Treiber:** beendet wird der Worker, nicht dessen Kinder, und
ein Hänger im Vorwärmlauf vor dem Fork liegt außerhalb. Ein Abbruch lässt im Arbeitsbaum kein
Residuum zurück; außerhalb bleiben ein Temp-Verzeichnis und, nach hartem Kill, das
Lock-Verzeichnis liegen (bewusst fail-closed). Isolation, Beleg-Mechanik, Bezugsmenge des
Schlüssels (`isolation_key_files`, **nicht** `harness/tools/working-tree-hash.sh`) und jede
weitere Bedingung stehen im Kopf von `harness/tools/mutate.sh`.

**Eine `# files:`-Angabe wird aufgelöst, nicht gelesen** (`resolve_file_spec` in
`harness/tools/mutate.sh`, benutzt sowohl von `mutation_targets`/`target_fingerprint` als auch
von `run_case`): ein Bash-Glob wie `.harness/baseline/*/templates/…` trifft gegen den jeweils
einen vendored Baum, ohne dessen Tag im Fall zu nennen — ein Baseline-Sprung zieht keinen
Nachzug nach sich, solange die Vorlage im neuen Satz unter demselben relativen Pfad liegt. Löst
die Angabe **nicht genau eine** Datei auf (kein Treffer, mehr als einer), nennt die Meldung den
Fall — `mutation_targets` bricht darauf den **ganzen** Lauf ab (vor jeder Isolationskopie),
`run_case` meldet einen Befund für **diesen** Fall, während die übrigen weiterlaufen. **Was die
Auflösung nicht deckt:** eine Angabe, die auf die **falsche**, aber existierende Datei zeigt,
bleibt still grün — Existenz und Eindeutigkeit sind geprüft, Richtigkeit ist es nicht.

## Ausgabe und Ausgänge

| Exit | Bedeutung |
|---|---|
| 0 | jeder Fall färbte seinen Wächter rot (`mutate: <n> ok, 0 Befund(e)`), oder ein Beleg über demselben Prüfgegenstand lag vor und kein Fall lief (`mutate: Beleg fuer Pruefgegenstand … liegt vor`) |
| 1 | mindestens ein Befund (`mutate: BEFUND  <fall>  <grund>` je Fund, Summe in `mutate: <n> ok, <m> Befund(e)`), oder eine Sperre griff |
| 130 | ein Signal beendete den Lauf; berichtet ist, was bis dahin gemessen war, gekennzeichnet `ABGEBROCHEN` |

## Sperren

- `mutate: ABBRUCH — ein Lauf ist bereits aktiv (…)` — das Lock-Verzeichnis unter
  `.harness/state/` besteht → den anderen Lauf abwarten; ein verwaistes Lock von Hand entfernen.
- `mutate: ABBRUCH — MUTATE_JOBS ist keine Worker-Zahl >= 1` → eine ganze Zahl ab 1 setzen.
- `mutate: ABBRUCH — MUTATE_STALL_SECONDS ist keine Sekundenzahl >= 1` → eine ganze Zahl ab 1
  setzen.
- `mutate: … fehlt` bzw. `mutate: keine Faelle in …` — `test/mutations/` fehlt oder ist leer; ein
  leeres Set ist kein grüner Lauf.
- `mutate: ABBRUCH — Fingerabdruck der Mutations-Ziele nicht berechenbar.` — unter anderem, wenn
  eine `# files:`-Angabe nicht genau eine Datei auflöst (§Grenze) → die Angabe berichtigen.
- `mutate: ABBRUCH — unbekannter '# verify: …'` — ein Fall nennt eine Prüfart ohne bekanntes
  Fehlschlag-Muster → den Fall berichtigen.
- `mutate: ABBRUCH — WORK …` — die Isolations-Wurzel ist leer, liegt im Repo oder ist kein
  Verzeichnis; ohne Isolation wird nicht mutiert.

Diese Sperren enden mit Exit 1, bevor ein Fall läuft (`harness/tools/mutate.sh`, `main`). Die
folgende greift während des Laufs:

- Stille über `MUTATE_STALL_SECONDS` hinweg (kein Worker zieht oder schließt einen Fall ab) → Lauf
  bricht selbst ab und wird rot; ein hängender Sensor ist sonst von einem langsamen nicht zu
  unterscheiden.

## Bindung

[`AGENTS.md`](../../AGENTS.md) §3.6; slice-026; kein Gate-Versprechen. Mechanischer Auslöser
ist der **Nacht-Job** `mutate.yml` (`schedule` + `workflow_dispatch`) — die Klassifikation des
Regelwerks ordnet die Mutationstests der Stufe **Post-integration** zu
(`grundlagen-klassifikation.md` §Klassifikation: *„nach Merge : Mutation Tests"*, *„teurer,
aber tolerierbar"*), und der Lauf kostete `49m54s` von `49m58s` eines Pushes
(`gh api "repos/pt9912/ai-harness-init/actions/jobs/<job-id>/logs"`).
