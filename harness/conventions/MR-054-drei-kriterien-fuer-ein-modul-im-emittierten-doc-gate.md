# MR-054 — Ein Modul geht ins emittierte Doc-Gate nur mit Erprobung, grünem Start und rotem Gegenbeispiel

- **Datum:** 2026-09-10
- **Wirksamkeits-Anlass:** slice-073.
- **Geltungsbereich:** die **Modul-Zusammensetzung** der Doc-Gate-Startkonfiguration, die das
  Werkzeug in ein Zielrepo schreibt — `internal/emit/templates/d-check.yml` und die `.d-check.yml`,
  die ein frisch gebootstrapptes Ziel daraus bekommt: welches Modul aktiv ist und welches nicht.
  **Nicht** die Positionen *innerhalb* eines aktivierten Moduls — welche Klassen, welche Regeln und
  welche Abschnitts-Ausnahme der `matrix`-Block trägt, setzt dieser Eintrag nicht; das ist eine
  eigene Entscheidung mit eigenem Träger. **Nicht** die `.d-check.yml` dieses Repos, deren
  Schärfung [`MR-001`](../conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  trägt. **Nicht** `docs/plan/adr/`, wo [`AGENTS.md`](../../AGENTS.md) §3.4 unverändert gilt.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  der nach
  [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  Setzung 3 hier steht und sein Verdikt im Feld trägt. Der Grund ist die **Ebene**, und er ist
  gegen den adoptierten Stand `v6.5.0` gemessen statt aus
  [`MR-017`](../conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  übernommen: Die Baseline spricht vom Adopter **ihrer selbst** und an keiner Stelle von dem, was
  ein hier gebautes Werkzeug in ein drittes Repo schreibt.
  `grep -rn 'Adopter' .harness/baseline/v6.5.0/regelwerk/ | wc -l` → **7** Fundstellen (**kein
  Erwartungswert**,
  [`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2); sie treffen die Template-Schichtung, die Bootstrap-Sequenz für Adopter-Repos, die
  Projekt-README und einen Slice-Größen-Beleg. Dass keine davon ein Emissions-Fall ist, ist ein
  **Urteil und kein Muster** ([`AGENTS.md`](../../AGENTS.md) §3.6) und steht deshalb als Satz da,
  nicht als zweite Zahl. Was von der Baseline auf dieser Ebene greift, greift als **Anwendung**:
  Die Ziel-Form der Startkonfiguration trägt ihre eigene Wachstums-Regel
  (`grep -c 'Wächst mit den Artefakten' .harness/baseline/v6.5.0/templates/.d-check.yml` → **1**),
  und die Grenz-Pflicht aus Setzung 4 ist
  [`modul-13-quality-gates.md`](../../.harness/baseline/v6.5.0/regelwerk/modul-13-quality-gates.md#hard-rule-doku-disziplin)
  §Hard Rule (Doku-Disziplin).
- **Setzung 1 — drei Kriterien, alle drei, und das erste bindet auf Modul-Ebene.** Ein Modul geht
  in die emittierte Startkonfiguration, wenn gilt:
  1. **Der Dogfood fährt es selbst.** Was das Werkzeug emittiert, ist hier erprobt; ein Modul, das
     dieses Repo nie unter sich hatte, ist im Ziel eine Behauptung.
  2. **Es ist über dem frisch emittierten Bestand grün.** Ein Ziel, das am ersten Tag rot startet,
     verliert die Zusage, aus der es entsteht.
  3. **Sein Gegenbeispiel wird im Ziel rot.** Grün allein ist von *prüft nichts* nicht zu
     unterscheiden ([`AGENTS.md`](../../AGENTS.md) §3.6).

  Kriterium 1 bindet auf **Modul**-Ebene, nicht auf die Positionen innerhalb eines Moduls: Für die
  ist die Ziel-Form der Startkonfiguration die Autorität, und sie liegt außerhalb des
  Geltungsbereichs oben.
- **Setzung 2 — Kriterium 2 ist die Fail-closed-Regel in dem Fall, den sie selbst ausnimmt.**
  Kriterium 2 und 3 sind die Fassung von
  [`MR-017`](../conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed) für
  diesen Prüfbereich, und Kriterium 2 sieht auf den ersten Blick wie deren Gegenteil aus: Jener
  Eintrag hält den zu strengen Default für die bessere Fehlrichtung, weil er *„beim ersten Lauf
  rot"* wird und *„eine Glob-Zeile in einer Datei"* kostet, die dem Adopter gehört. Dieses
  **Kostenmodell setzt voraus, dass das Rot aus Adopter-Inhalt kommt.** Kommt es aus der
  **emittierten Prosa selbst**, stimmt der Preis nicht: Der Adopter trägt einen Fehlalarm, den das
  Werkzeug erzeugt hat und den er nicht abstellen kann, ohne die Vorlage zu verstehen — genau die
  Lage, für die jener Eintrag *„strenger ist nicht automatisch besser"* schreibt und
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) als
  Gegenkraft nennt. Er bleibt unangetastet und bindet fort; hier steht keine zweite Fassung neben
  ihm, sondern die Frage, die seine Anwendung entscheidet: **woher das Rot kommt.**
- **Setzung 3 — zwei Positionen bleiben aus, jede als begründeter Kommentar-Block, jede mit
  eigenem Trigger.**
  - **Das Modul `codepaths`** — die emittierte Prosa nennt einen Ort, den ein frisches Ziel nicht
    trägt. Ohne Bootstrap-Lauf ist das an zwei Stellen messbar:
    `grep -rl 'docs/plan/planning/observations' internal/emit/templates/commands/ | wc -l` → **3**
    mitemittierte Workflow-Commands nennen das Beobachtungs-Register per Inline-Code, und
    `sed -n '/^func structureGitkeeps/,/^}/p' internal/emit/templates.go | grep -c observations`
    → **0** — angelegt wird der Ort nicht. **Keine Erwartungswerte**; beide wandern mit dem
    Emissions-Bestand. **Auflösungs-Trigger:** die emittierte Prosa nennt keinen Ort mehr, den ein
    frisches Ziel nicht trägt — gleich ob die nennenden Stellen ihn nicht mehr per Inline-Code
    führen oder der Ort mitemittiert wird. Der Trigger nennt die **Eigenschaft** und keine
    Stellen-Liste: Welche Stelle sie trägt, wandert mit dem Emissions-Bestand; die Eigenschaft
    nicht.
  - **Das Requirement-Muster des Moduls `ids`** — das Vertrags-Präfix gehört dem Adopter und ist in
    einem frischen Ziel nicht bekannt; mit dem Beispiel-Präfix gemessen startet das Ziel rot. Das
    Modul selbst geht mit, allein dieses Muster nicht. **Auflösungs-Trigger:** das Werkzeug erfährt
    das Präfix.

  Beide bleiben als **begründeter Kommentar-Block** in der emittierten Datei stehen, nicht als
  Leerstelle. Der Adopter liest damit eine Entscheidung und ihre Bedingung; eine Leerstelle sähe
  aus wie ein Versäumnis, und er träfe sie noch einmal.
- **Setzung 4 — Kriterium 3 bindet, was hinzukommt; die Deckung der ererbten Module steht benannt
  daneben.** Die Ziel-Form der Startkonfiguration führt zwei Module vor jeder Entscheidung dieses
  Eintrags
  (`grep -c '^modules: \[links, anchors\]$' .harness/baseline/v6.5.0/templates/.d-check.yml` →
  **1**); Kriterium 3 bindet, was darüber hinaus aktiviert wird. Die Deckung des emittierten Gates
  fällt damit auseinander, und die Differenz gehört benannt — mit dem Kommando statt der
  eingefrorenen Zahl:

  ```sh
  sed -n 's/^modules: \[\(.*\)\]$/\1/p' internal/emit/templates/d-check.yml   # die aktiven Module
  grep -oE '[A-Za-z-]+-Zahn belegt' harness/tools/full-smoke.sh | sort -u     # die Zaehne im Ziel
  grep -c 'Feldlisten-Ortswahl belegt' harness/tools/full-smoke.sh            # einer unter eigenem Namen
  ```

  **Welcher Zahn welches Modul deckt, liest keines der drei Kommandos ab:** Ein Zahn nennt die
  Befund-Art, und die trägt den Modulnamen nicht durchgehend. Die Zuordnung ist ein **Urteil**
  ([`AGENTS.md`](../../AGENTS.md) §3.6) und lautet: `ids`, `matrix` — zwei Regeln, zwei Zähne — und
  `spans` tragen ihren Zahn im gebootstrappten Ziel, `links` trägt seinen unter eigenem Namen;
  **`anchors` trägt keinen.** Die Vollständigkeits-Zeile des emittierten Gates (*N Datei(en)
  geprüft, 0 Befund(e)*) liest sich als Aussage über alle aktiven Module und ist eine über die, die
  einen Zahn tragen.
- **Setzung 5 — die Entscheidung reicht an ein frisches Ziel und an kein anderes.**
  `.d-check.yml` ist *skip-if-present*
  ([`ADR-0007`](../../docs/plan/adr/0007-bootstrap-phasen.md)) — ein bereits gebootstrapptes Ziel
  bekommt nichts davon, auch beim Re-Lauf nicht. Das ist die Idempotenz-Klasse und kein Versehen:
  Sie schützt den Adopter-Boden. Die Folge gehört trotzdem benannt statt vorausgesetzt — bei jedem
  heute schon gebootstrappten Repo bleibt die Lücke **offen**, und dieser Eintrag trägt keinen
  Migrationspfad dorthin.
- **Was hier nicht entschieden ist, und es ist gemessen.** Auf **Modul**-Ebene ist die Differenz
  zwischen der Liste dieses Repos und der emittierten größer als das eine Modul, das Setzung 3
  nennt:

  ```sh
  grep -m1 '^modules:' .d-check.yml                                          # die Module dieses Repos
  sed -n 's/^modules: \[\(.*\)\]$/\1/p' internal/emit/templates/d-check.yml  # die emittierten
  ```

  **Keine Erwartungswerte** — beide Listen wachsen. Kriterium 1 lässt jedes Modul zu, das dieses
  Repo selbst fährt; über jedes davon entscheiden erst Kriterium 2 und 3, und die verlangen je eine
  Messung am frischen Ziel. Dieser Eintrag trägt sie für die Positionen aus Setzung 3 und für keine
  weitere: Wo die Liste dieses Repos wächst, wächst die **Kandidaten-Menge**, nicht die
  Entscheidung. Ein Modul ohne diese Messung ist **nicht entschieden** — nicht abgelehnt.
- **Begründung (gemessen, nicht postuliert).** Ein Ziel bekommt die volle Doku-Struktur und die
  vendored Regelwerks-Kopie. Ein Doc-Gate, das darüber nur die zwei Module der Ziel-Form führt, hat
  zur Referenz-Richtung nichts zu sagen — es ist nicht rot und nicht grün, es hat zu der Frage
  keine Aussage. Jedes der drei Kriterien schließt dabei eine eigene Fehlrichtung, und jede ist im
  Bestand belegt statt behauptet: Ohne Kriterium 1 emittiert das Werkzeug, was es nie fährt.
  Kriterium 2 hält die zwei Positionen aus Setzung 3 draußen, die im frischen Ziel rot messen, ohne
  dass der Adopter etwas falsch gemacht hätte. Kriterium 3 ist der Grund, warum `matrix` **zwei**
  Zähne trägt und nicht einen: Eine Regel ohne eigenes Gegenbeispiel ist gelistet und unbewacht.
- **Wächter — für das Ergebnis, nicht für die Regel.** Kriterium 2 und 3 haben einen:
  `make full-smoke` fährt das frisch gebootstrappte Ziel grün und jeden Zahn einzeln rot; die
  entschiedene Modul-Liste selbst hält netzlos ein Go-Test samt Mutations-Fällen in `make gates`.
  **Kriterium 1 hat keinen:** Kein Ziel hält die emittierte Liste gegen die dieses Repos, und die
  zwei Listen oben stehen in zwei Dateien ohne Kopplung. Das ist auch keine Lücke, die ein Sensor
  schließen könnte, ohne die Regel zu verfälschen — Kriterium 1 ist eine **Zulassungs**-Bedingung,
  keine Gleichheits-Zusage; ein Sensor auf Gleichheit der zwei Listen färbte genau dann rot, wenn
  dieses Repo ein Modul erprobt, das im Ziel noch nichts zu prüfen hat. Träger ist der
  Rollen-Wechsel vor der Änderung.
- **Auflösungs-Trigger:** permanent, solange das Werkzeug eine Doc-Gate-Startkonfiguration
  emittiert. Die zwei Trigger aus Setzung 3 lösen je ihre Position aus, nicht diesen Eintrag:
  Fällt einer, wächst die emittierte Konfiguration um eine Position samt Zahn, und die Regel, nach
  der sie hineinkommt, bleibt dieselbe. Neu zu prüfen ist der Eintrag, sobald die Baseline die
  **Emissions-Ebene** selbst führt — dann fällt die Fork-Einordnung, und jede der fünf Setzungen
  ist gegen sie zu messen.
