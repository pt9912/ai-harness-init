# MR-017 — Default-Regel für emittierte Prüfbereiche (fail-closed)

- **Datum:** 2026-07-27
- **Geltungsbereich:** jede vom Tool **emittierte** Gate-Konfiguration, die ein Adopter
  danach selbst pflegt (`.a-check.yml`, `.d-check.yml`, `tools/harness/blocked/*`) — also
  jeder Prüfbereich, dessen Schärfe wir für **unbekannte** Nutzer festlegen.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  und die **Ebene** ist der Grund. Der Geltungsbereich oben ist die *emittierte*
  Prüfbereichs-Config, die ein fremder Adopter danach besitzt. Die Baseline am adoptierten Stand
  `v5.12.0` spricht vom Adopter **ihrer selbst** und nirgends von dem, was ein hier gebautes
  Werkzeug in ein drittes Repo schreibt: `grep -rn 'Adopter' .harness/baseline/v5.12.0/regelwerk/`
  nennt Template-Schichtung, Reviewer-Skill, die Baseline-Ablage und die Projekt-README — keinen
  Emissions-Fall. Was von der Baseline hier greift, greift als **Anwendung**: fail-closed ist
  Design-Eigenschaft 1 aus
  [`grundlagen-durchsetzungsschicht.md`](../../.harness/baseline/v5.18.0/regelwerk/grundlagen-durchsetzungsschicht.md#vier-design-eigenschaften)
  (*„Ein Gate, das im Zweifel passieren lässt, ist keiner"*), und die Gegenkraft nennt der Eintrag
  selbst.
- **Warum hier:** die Regel ist in
  [`ADR-0010`](../../docs/plan/adr/0010-hexagonal-arch-realisierung.md) (Festlegung 3)
  entschieden worden, steht dort aber in einer **Layout**-ADR. Wer nach der Default-Regel
  sucht, sucht nicht nach dem hexagonalen Go-Layout — dieser Eintrag ist der Zeiger
  ([`ADR-0010`](../../docs/plan/adr/0010-hexagonal-arch-realisierung.md) Folgepflicht 6). Die
  ADR bleibt die Quelle; dies ist keine zweite Fassung.
- **Setzung:** Defaults für unbekannte Adopter werden **nicht nach vermuteter Präferenz**
  gewählt, sondern nach dem **Fehlerbild**: ein zu **strenger** Default wird beim ersten
  Lauf rot und kostet eine Glob-Zeile in einer Datei, die dem Adopter gehört (die
  emittierten Configs sind *skip-if-present*, sie werden nie überschrieben). Ein zu
  **lascher** Default lässt einen Bereich ungeprüft — und meldet sich **nie**. **Laut
  falsch schlägt leise falsch.**
- **Gelebte Instanzen (Belege, nicht Beispiele):** der Command-Guard trägt seinen
  universellen Boden **gebacken** und liest die Fragmente nur additiv
  ([`MR-003`](../conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Linie,
  nie fail-open); der Mutations-Sensor fährt bei unklarer Erwartung **beide** Stufen; die
  emittierte hexagonale Schicht-Config prüft die treibende Seite **strenger** als die
  Referenz-Repos, aus denen ihr Layout stammt.
- **Was das NICHT heißt:** strenger ist nicht automatisch besser. Die Regel greift genau
  dort, wo wir den Adopter **nicht kennen** und beide Fehlrichtungen offenstehen — nicht
  als Freibrief für Regeln ohne belegten Nutzen (die Gegenkraft bleibt
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6): kein
  Gate über leerem Prüfbereich).
- **Auflösungs-Trigger:** permanent, solange das Tool Prüfbereiche emittiert, die der
  Adopter danach besitzt. Neu zu bewerten, sobald ein Adopter belegt, dass ein strenger
  Default ihn mehr kostet als eine Zeile — dann ist das Fehlerbild falsch modelliert.
