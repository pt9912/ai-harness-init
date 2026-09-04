# MR-039 — Ein fehlendes Pflichtfeld wird nachgetragen, ein retirierter Eintrag bekommt keines

> **ÜBERHOLT: die Deckungs-Messung samt ihrer drei Kommandos über `harness/conventions.md` → [`MR-046`](../conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht).** Setzung 1, 2 und 3 gelten fort — je einzeln geprüft; die Gleichung selbst gilt über das Verzeichnis unverändert.

- **Datum:** 2026-09-02
- **Wirksamkeits-Anlass:** slice-083 — der Form-Vergleich der Re-Baseline, dessen zweiter
  DoD-Punkt `Ersetzt-Baseline-Regel` in jedem Eintrag verlangt.
- **Geltungsbereich:** die **Form** eines Eintrags dieses Blocks, wenn ein adoptierter
  Baseline-Stand ein neues Pflichtfeld einführt. **Nicht** der Inhalt eines akzeptierten Rumpfs —
  kein Satz darin wird dadurch geändert, gestrichen oder umformuliert. **Nicht**
  `docs/plan/adr/`, wo [`AGENTS.md`](../../AGENTS.md) §3.4 unverändert gilt; **nicht** die emittierte
  Ebene.
- **Ersetzt-Baseline-Regel:**
  [`grundlagen-harness-dateien.md`](../../.harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md#harnessconventionsmd-als-konventionsspeicher)
  §harness/conventions.md als Konventionsspeicher — dieselbe Zelle, die
  [`MR-020`](../conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) für den Rumpf eines
  aufgehobenen Eintrags trifft, hier an zwei anderen Punkten: *„Einträge werden nie
  überschrieben"* und *„**Index** der Abweichungen ggü. Baseline"*.
  [`MR-020`](../conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) bleibt unangetastet
  und bindet fort — dies ist eine zweite Ausnahme zu derselben Regel, keine zweite Fassung von ihr
  und keine Schärfung (die Regel wird nicht strenger, sie bekommt einen weiteren Ausnahmefall).
- **Setzung 1 — ein Pflichtfeld wird nachgetragen, und das ist kein Überschreiben.** Führt ein
  adoptierter Baseline-Stand ein neues Pflichtfeld ein, bekommt es **jeder** Eintrag mit vollem
  Rumpf, auch der vor dem Sprung geschriebene. Das Feld tritt **hinzu**; es beantwortet eine
  Frage, die vorher niemand gestellt hat, und ändert an keiner Antwort etwas, die schon dasteht.
  Was die Append-only-Regel schützt, ist die Aussage eines Eintrags über seinen Zeitpunkt — genau
  sie bleibt lesbar. Ohne diese Setzung fiele die Konformität des Registers mit seiner eigenen
  Ziel-Form mit jedem Sprung weiter zurück: ein Kriterium, das nur die Neuzugänge trifft, lässt
  den Rückstand wachsen, den es abbauen soll.
- **Setzung 2 — ein retirierter Eintrag bekommt es nicht.** Ein nach
  [`MR-020`](../conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) auf Kopf und Zeiger
  zurückgeführter Eintrag trägt Nummer, Überschrift wörtlich, `Datum` und **eine** Zeiger-Zeile —
  eine geschlossene Aufzählung, in der kein Pflichtfeld steht. Er trägt auch keine Adaption mehr,
  die an die Stelle einer Baseline-Regel treten könnte; das Feld hätte keinen Gegenstand, und ein
  Feld ohne Gegenstand behauptet einen. Heute sind das vier:
  [`MR-016`](../conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird),
  [`MR-018`](../conventions.md#mr-018--span-schema-der-telemetrie-erfassung),
  [`MR-022`](../conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline) und
  [`MR-023`](../conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung).
- **Setzung 3 — ein Fork bleibt in diesem Block und trägt sein Verdikt im Feld.** Die
  Eintrags-Vorlage nennt einen Eintrag ohne ersetzte Regel einen **Fork**, *„keine Adaption"*; die
  Pflichtgliederung nennt den Block einen *Index der Abweichungen*. Zusammengelesen dürfte ein
  Fork hier nicht stehen. Er steht trotzdem, und zwar mit ausgesprochenem Verdikt in seinem
  `Ersetzt-Baseline-Regel`-Feld. Der Grund ist der Leser: Ein Eintrag, der eine Abweichung
  **bestreitet**, beantwortet dieselbe Frage wie einer, der eine setzt — *weicht dieses Repo hier
  ab?* —, und wer ihn anderswo suchen müsste, fände nichts und schlösse auf Baseline-Default. Ein
  zweiter Ort für dieselbe Frage wäre die zweite Fassung, die driftet.
- **Damit ist die Folge entschieden, die vier Einträge offen ließen.**
  [`MR-031`](../conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline),
  [`MR-033`](../conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist),
  [`MR-034`](../conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand) und
  [`MR-035`](../conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)
  sprechen ihre Fork-Einordnung aus und verweisen die Frage, *was daraus für den Block folgt*, an
  slice-083 §2. Antwort: Setzung 3. Die vier bleiben unangetastet; wo ihr Verweis hinzeigte, steht
  jetzt eine Entscheidung.
- **Folge für die Deckungs-Messung: zwei Zahlen decken sich nicht, und das ist die Form.** Sie
  unterscheiden sich um die retirierten Einträge — drei Kommandos, kein Erwartungswert
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2, alle
  drei wandern mit dem Block):

  ```sh
  grep -c '^### MR-'                             harness/conventions.md   # Einträge gesamt
  grep -c '^- \*\*Ersetzt-Baseline-Regel:\*\*'   harness/conventions.md   # Einträge mit Feld
  grep -c '^- \*\*Aufgehoben durch'              harness/conventions.md   # retiriert, ohne Feld
  ```

  Tragend ist die Gleichung, nicht der Betrag: die erste Zahl ist die Summe der beiden anderen.
  **Welcher** Eintrag fehlt, sagt eine Auswertung über dieselbe Datei —
  `awk '/^### MR-[0-9]/{if(c!=""&&f==0)print c; c=$2; f=0} /^- \*\*Ersetzt-Baseline-Regel:\*\*/{f=1} END{if(c!=""&&f==0)print c}' harness/conventions.md`
  gibt genau die vier aus Setzung 2 aus.
- **Begründung (gemessen, nicht postuliert).** Der Sprung auf `v5.12.0` hat das Feld eingeführt,
  und die Einträge, die es organisch bekamen, waren die **nach** dem Tausch geschriebenen. Ohne
  Setzung 1 träte das Kriterium nur für Neuzugänge in Kraft — dieselbe Klasse Schaden, gegen die
  [`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) und
  [`AGENTS.md`](../../AGENTS.md) §3.7 ihren Cutoff **umgekehrt** setzen: dort ist der Bestand zu groß
  und ein Maßstab über ihn dauerhaft rot; hier ist er abzählbar, und das Nachtragen kostet einen
  Durchgang. Der Unterschied ist die Fläche, nicht das Prinzip — deshalb steht hier kein Cutoff.
- **Kein Wächter, und das gehört dazu.** Kein Modul aus `modules:` der `.d-check.yml` hält einen
  Eintrag dieses Blocks gegen die Pflichtgliederung des vendored Regelwerks — `links` prüft
  Auflösbarkeit, `anchors` Anker, `ids` drei Kennungs-Muster —, und `make comment-claims` hat
  keine Markdown-Datei im Prüfbereich. Das `awk` oben wäre der Sensor und ist keiner: es liegt in
  keinem Ziel. Träger ist der Rollen-Wechsel vor der Änderung und der Form-Vergleich der nächsten
  Re-Baseline.
- **Auflösungs-Trigger:** permanent, solange dieser Block in der **Inline-Form** läuft. Er fällt
  mit dem Umzug in die Verzeichnis-Form, die der adoptierte Stand zum Default macht: dort ist der
  Zustand die Verzeichnis-Position, ein aufgelöster Eintrag wandert nach `conventions/done/`, und
  was eine gewanderte Datei an Feldern trägt, ist dann neu zu entscheiden — Setzung 2 verliert
  ihren Gegenstand, Setzung 1 und 3 sind neu zu prüfen.
