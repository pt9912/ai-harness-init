# MR-055 — Eine Stellen-Messung trägt keine Folgerung über eine Eigenschaft

- **Datum:** 2026-09-11
- **Wirksamkeits-Anlass:** slice-194.
- **Geltungsbereich:** die drei Folgerungen, die [`MR-054`](../conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel) aus einer Messung an einer
  **benannten Stelle** zieht — die zwei in Setzung 3 und die eine im Feld
  `Ersetzt-Baseline-Regel` —, und die **Form** einer Messung in einem Eintrag dieses Blocks.
  **Nicht** der Rumpf jenes Eintrags: kein Wort darin wird geändert, und seine fünf Setzungen
  samt den drei Kriterien binden fort. **Nicht** `docs/plan/adr/`, wo
  [`AGENTS.md`](../../AGENTS.md) §3.4 unverändert gilt; **nicht** die emittierte Ebene.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  der nach
  [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  Setzung 3 hier steht und sein Verdikt im Feld trägt; am adoptierten Stand `v6.5.0` ist
  `grep -rn 'Erwartungswert\|neben dem Kommando\|Stellvertreter\|misst nicht' .harness/baseline/v6.5.0/regelwerk/`
  leer (Exit 1). **Welche Wörter die Eigenschaft decken, sagt kein `grep`:** dass die Baseline
  keine Regel über den Beleg einer Folgerung führt, ist ein **Urteil**
  ([`AGENTS.md`](../../AGENTS.md) §3.6) — dieser Eintrag auf sich selbst angewandt.
- **Löst auf:** [`MR-054`](../conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel) — die drei Folgerungen, keine seiner Setzungen. Das Feld
  `Ausgelöst durch Baseline-Stand` bleibt aus, weil die Ablösung repo-intern getrieben ist
  ([`MR-038`](../conventions.md#mr-038--ein-retirierender-eintrag-nennt-den-baseline-stand-der-seinen-trigger-feuerte):
  dann *„gäbe es nichts zu nennen"*).
- **Setzung 1 — die drei Folgerungen sind gestrichen, nicht ersetzt.** Jede steht neben ihrem
  Kommando, jedes Kommando gibt weiter aus, was der Eintrag nennt, und jede reicht über das
  hinaus, was ihr Kommando misst:
  1. `sed -n '/^func structureGitkeeps/,/^}/p' internal/emit/templates.go | grep -c observations`
     → **0**, daneben *„angelegt wird der Ort nicht"*. Angelegt wird er, über `planTemplates()`;
     gemessen ist eine Funktion, behauptet ist das Werkzeug.
  2. `grep -rl 'docs/plan/planning/observations' internal/emit/templates/commands/ | wc -l` →
     **3**, daneben *„die emittierte Prosa nennt einen Ort"*. Der Prüfbereich ist ein
     Unterverzeichnis des Emissions-Baums `internal/emit/templates/`, die Folgerung spricht über
     den Baum; gemessen ist ein Verzeichnis, keine Prosa.
  3. `grep -rn 'Adopter' .harness/baseline/v6.5.0/regelwerk/ | wc -l` → **7**, daneben *„die
     Baseline spricht … an keiner Stelle von dem, was ein hier gebautes Werkzeug in ein drittes
     Repo schreibt"*. Sie spricht davon: `grep -rli emittier .harness/baseline/v6.5.0/regelwerk/`
     nennt `grundlagen-harness-dateien.md` §Emittierte Artefakte tragen keinen Anker und
     `modul-09-implementierung.md` §Werkzeuge, die Repos erzeugen; gemessen ist ein Wort. **Das
     Fork-Verdikt fällt damit nicht:** Keine der zwei Stellen handelt von der
     Modul-Zusammensetzung eines Doc-Gates, und ob eine Baseline-Regel jenen Geltungsbereich
     deckt, ist ein Urteil und keine Fundstelle.

  **Keine Erwartungswerte**
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — die drei Zahlen oben wandern mit dem Bestand, die in Setzung 3 ebenso.
  **Ersetzt wird keines der drei Kommandos:** Ein engeres wäre die nächste Stelle, die wandert,
  während der Satz daneben stehen bleibt.
- **Setzung 2 — eine Messung trägt die Stelle, die sie liest.** Ein Eintrag dieses Blocks schreibt
  neben ein Kommando keinen Satz, der mehr behauptet als dessen Prüfbereich hergibt; was darüber
  hinausgeht, steht als **Urteil** da ([`AGENTS.md`](../../AGENTS.md) §3.6) oder gar nicht.
  [`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  bindet unverändert daneben und wird nicht verschärft: Er verlangt das Kommando **zur Zahl** und
  sagt über den Satz daneben nichts — alle drei Fälle oben erfüllen ihn.
- **Setzung 3 — der Auflösungs-Trigger der Position `codepaths` ist eingetreten; gebucht ist,
  *dass* er fiel.** Er lautet *„… oder der Ort mitemittiert wird"*, und der Ort wird mitemittiert.
  Die **Aktivierung** entscheidet er nicht: Sie läuft über die drei Kriterien aus
  [`MR-054`](../conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel) Setzung 1. Kriterium 1 ist erfüllt (`grep -m1 '^modules:' .d-check.yml` führt
  `codepaths`), Kriterium 3 ist **nicht** erfüllt —
  `grep -c -i codepath harness/tools/full-smoke.sh` → **0**, im Ziel wird kein Gegenbeispiel rot.
  Was fehlt, ist ein Zahn in jenem Skript und der Lauf, der ihn rot sieht; beides sind Artefakte
  anderer Rollen, und dieser Eintrag trägt sie nicht. **Eine Adresse besteht noch nicht:**
  slice-210 wendet dieselben drei Kriterien auf einen benannten Kandidaten an, schließt diese
  Position aber als *Bestand bleibt bewusst stehen* aus — ein Ausschluss, dessen Grund mit dem
  Trigger entfällt. Wer den Vorgang schneidet und unter welcher Kennung, entscheidet der Planner.
- **Begründung (gemessen, nicht postuliert).** Drei Sätze eines **einen Tag alten** Eintrags
  reichen weiter als das Kommando daneben, und einer wurde binnen eines Tages falsch, ohne dass
  seine Zahl sich bewegte — die Lücke liegt nicht bei der Zahl, sondern beim Satz. Im
  Beobachtungs-Register führt `BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen` den
  Stand `geplant` und benennt diese Unterklasse als offen: *„dort ist der Ausgang eine Regel ohne
  Sensor."* Dieser Eintrag ist diese Regel **für diesen Block** und keine zweite Fassung jenes
  Ausgangs — er bindet die Form eines Adaptions-Eintrags, nicht die repo-weite Klasse.
- **Kein Wächter, und das gehört dazu.** Kein Modul aus `modules:` der
  [`.d-check.yml`](../../.d-check.yml) hält einen Satz gegen den Prüfbereich des Kommandos
  daneben (`grep -n '^modules:' .d-check.yml`), und `make comment-claims` erreicht keine
  Markdown-Datei. Ob eine Folgerung ihre Messung übersteigt, ist ein **Urteil, kein Muster**
  ([`AGENTS.md`](../../AGENTS.md) §3.6). Träger ist der Rollen-Wechsel vor der Änderung.
- **Auflösungs-Trigger:** permanent, solange dieser Block Messungen führt.
