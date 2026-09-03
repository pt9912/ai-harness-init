# MR-015 — Change Request bei Personalunion von Auftraggeber und Entwickler

> **ÜBERHOLT: dieser Eintrag, mit einer Ausnahme → [`MR-036`](../conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline).** Der Cutoff-Absatz (permanente Ausnahme von rückwirkender Prüfung) bindet als eigenständiges Präzedens fort — [`AGENTS.md`](../../AGENTS.md) §3.7 und [`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) zitieren ihn.

- **Datum:** 2026-07-26
- **Geltungsbereich:** `spec/lastenheft.md` §7 Historie (**Form künftiger** Einträge, nicht die
  bestehenden) und die Commit-Disziplin um diese Datei. [`AGENTS.md`](../../AGENTS.md) bleibt
  **unverändert**: dies ist eine MR-Adaption, **keine** neue Hard Rule — ob die Setzung in den
  Hard-Rule-Katalog gehört, entscheidet der Slice, der ihren Sensor baut (s. §Durchsetzung).
  Adoptiert den Normativ-Delta, den die Baseline `v3.5.2` mitbringt
  (`.harness/baseline/v3.5.2/regelwerk/grundlagen-konventionen.md`, §Spec-Stratifizierung).
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  und der Grund ist derselbe wie bei
  [`MR-008`](../conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert): **die Baseline schreibt die
  Setzung inzwischen selbst.** Die einzige Abweichung, die dieser Eintrag je beanspruchte, ist
  Setzung 3 — *„die einzige Abweichung vom Baseline-Wortlaut"*, sagt sie über sich —, und
  [`grundlagen-source-precedence.md`](../../.harness/baseline/v5.18.0/regelwerk/grundlagen-source-precedence.md#spec-stratifizierung)
  §Spec-Stratifizierung sagt am adoptierten Stand `v5.12.0` genau das: *„Der Träger ist dann der
  **Commit**: Ein angenommener Change Request ändert in einem eigenen Commit ausschließlich das
  Lastenheft und liegt vor dem Slice, der ihn umsetzt; die Verweis-Spalte nennt diesen Vorgang
  statt eines Tickets."* Was nach der Kopf-Marke oben hier fort bindet, ist der
  **Cutoff-Absatz**, und ein Cutoff tritt an keine Stelle einer Regel: er nimmt einen Bestand von
  einer Prüfung aus, die die Baseline nicht kennt. **Welcher Ausgang aus der Deckung folgt**,
  entscheidet ein Nachfolge-Eintrag und nicht dieses Feld —
  [`MR-036`](../conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)
  §Achse 2 führt Setzung 3 bislang als eigenen, nicht eingetretenen Bedarf.
- **Der adoptierte Wortlaut** (verbatim aus dem vendored Baum, nicht paraphrasiert):

  > „Change Request" ist **bewusst kein Harness-Konstrukt** — kein `CR-*`-ID-Schema, keine eigene
  > Datei, kein Gate — sondern der *externe* Vorgang, in dem eine Vertragsänderung mit dem
  > Auftraggeber vereinbart wird. Im Repo hinterlässt ein *angenommener* Change Request nur einen
  > **Fußabdruck**: ein Version-Bump des Lastenhefts, eine Zeile in dessen `## Historie` mit
  > Verweis auf den externen CR (Ticket, Vertragsanhang), und die geänderten `LH-*`/`HSM-*`
  > selbst. Abgelehnte oder schwebende CRs leben außerhalb des Repos. Weil nur dieser externe
  > Prozess das Lastenheft ändern darf, gilt die Hard Rule für *jede* interne Quelle: **weder ADR
  > noch Slice dürfen `LH-*` je ändern** — sie referenzieren nur.

- **Ist-Messung gegen die reale Praxis (2026-07-26, drei Achsen — zwei konform, eine adaptiert):**
  (1) *Kein `CR-*`-ID-Schema, keine CR-Datei, kein Gate* — **konform**: `spec/lastenheft.md` führt
  `CR:`-Prosa in der Änderungs-Spalte, keine IDs, keine Dateien, kein Target.
  (2) *Fußabdruck = Version-Bump + Historie-Zeile + geänderte Anforderungs-IDs* — **konform**:
  13 Zeilen 0.1.0…0.13.0, Spalte „Verweis" vorhanden, Header-Version mitgezogen.
  (3) *Verweis zeigt auf den **externen** CR; keine interne Quelle ändert `LH-*`* — **hier war zu
  entscheiden**: die Verweise zeigen nach innen (`slice-017-Folge`, `Messmethoden-CR`), und
  Zeile 0.13.0 trägt wörtlich „Getrieben von slice-048".
- **Warum das keine Schlamperei ist, sondern eine Struktur-Eigenheit.** Dieses Repo hat keinen
  externen Auftraggeber — es ist sein eigener. Die Auftraggeber-**Rolle** ist besetzt (der Nutzer),
  nur die **Ticket-Form** fehlt. Zu entscheiden war daher nicht „haben wir die Regel gebrochen",
  sondern **woran man nachträglich erkennt**, ob eine Lastenheft-Änderung eine angenommene
  Vertragsänderung war oder ein Nebeneffekt der Implementierung.
- **Setzung 1 — der externe Vorgang ist die Nutzer-Entscheidung, und sie geht dem Slice voraus.**
  Der annehmende Akt ist die Entscheidung des Nutzers in der Sitzung, gefällt **vor** dem
  umsetzenden Slice („Schritt 0, Doc-führt vor Code"). Was die Baseline-Regel trägt, ist nicht die
  Externalität des Ticket-Systems, sondern die **Trennung der Entscheidung von der Umsetzung** —
  und die ist hier real herstellbar.
- **Setzung 2 — die Trennung ist am Commit ablesbar, nicht an der Prosa.** Ein angenommener CR
  landet **ab diesem Eintrag** in einem **eigenen Commit**, der **ausschließlich**
  `spec/lastenheft.md` ändert und **vor** dem `open → in-progress`-Move des umsetzenden Slice
  liegt. Damit ist die Frage nachträglich mechanisch beantwortbar:
  `git log -- spec/lastenheft.md` + `git show --stat`.
- **Setzung 2 ist eine NEUE Disziplin, keine Beschreibung des Ist-Standes** — gemessen, nicht
  geschätzt. *(Die erste Fassung dieses Eintrags behauptete hier das Gegenteil; der Review zu
  slice-049 hat sie widerlegt. Der Befund ist die eigene Klasse dieses Repos —
  [`AGENTS.md`](../../AGENTS.md) §3.6, „Zusage weiter als Abdeckung" — und wird darum stehen
  gelassen statt geglättet.)* **Ist-Messung 2026-07-26:** **16 Commits** berühren
  `spec/lastenheft.md`; **6** ändern sie allein (`5c4930b`, `9ce4721`, `af0d454`, `2c8227b`,
  `2879429`, `27628b5`), **10 bündeln** sie. Die Bündel zerfallen in drei Klassen:
  **sieben Entscheidungs-Bündel**, die das Lastenheft gemeinsam mit dem **ADR** tragen, der die
  Entscheidung trug (`43f1eda`, `65f4bcf`, `ec3af11`, `a0e74f1`, `bc447fe`), bzw. mit
  [`harness/conventions.md`](../conventions.md) (`beec837`) oder einer Slice-Datei (`4b0d0d5`);
  der **Initial-Bootstrap** (`d30db38`, 21 Dateien); und **zwei rein redaktionelle** Berührungen
  (`c615da7` — Link-Form einer Historie-Zeile bei der Doc-Gate-Schärfung; `7b717f4` —
  Zeilenreihenfolge 0.12.0/0.13.0 im slice-048-Fix).
- **Was der Ist-Stand trotzdem belegt.** Keine **Anforderung** wurde je in einem
  Slice-Implementierungs-Commit **inhaltlich** geändert: die beiden slice-nahen Berührungen sind
  genau die zwei redaktionellen. Die **substanzielle** Regel hält also; das **mechanische**
  Merkmal wird hier neu eingeführt. Es gilt **auch für rein redaktionelle** Änderungen —
  `c615da7`/`7b717f4` sind der Beleg, dass genau die das Signal verwischen.
  **Cutoff:** geprüft wird ab dem Commit, der diesen Eintrag trägt. Ein Sensor, der die Historie
  mitprüfte, wäre dauerhaft rot (10 von 16) und entwertete die Setzung, statt sie zu tragen.
- **Setzung 3 — die Verweis-Spalte nennt die annehmende Instanz, die Änderungs-Spalte den Anlass.**
  Künftige Zeilen tragen im Verweis den annehmenden Akt (`Nutzer-Entscheidung YYYY-MM-DD`), nicht
  den umsetzenden Slice; der Anlass (ein ADR, ein Slice-Befund) bleibt in der Änderungs-Spalte.
  Das ist die **einzige** Abweichung vom Baseline-Wortlaut, und sie ist eine Ersetzung des
  fehlenden externen Belegs, keine Aufweichung.
- **Die bestehenden 13 Zeilen werden NICHT umgeschrieben.** Ein Slice, der zur Adoption dieser
  Regel `spec/lastenheft.md` anfasst, widerlegt sie im Vollzug — slice-049 verankert das
  ausdrücklich in seiner DoD. Die Zeilen sind nach dieser Lesart **einzuordnen**, nicht zu
  korrigieren: „Getrieben von slice-048" nennt den **Anlass** der Entscheidung, nicht ihren
  Urheber. Eine Angleichung wäre ein eigener CR mit eigenem Trigger.
- **Durchsetzung — benannt, nicht geschlossen (ehrlich, kein stilles Grün).** Die Regel lebt heute
  allein im **inferential-feedforward**-Quadranten: kein Sensor prüft, ob ein Commit
  `spec/lastenheft.md` gemeinsam mit anderen Dateien ändert. Mechanisierbar wäre sie (genau diese
  Bedingung ist ein Befund) — gebaut ist sie **nicht**. Das ist dieselbe Klasse, aus der
  [`AGENTS.md`](../../AGENTS.md) §3.6 und `make mutate` entstanden sind („Hard Rule nur in einem
  Quadranten ist halb durchgesetzt"); der Sensor ist ein Roadmap-Kandidat, keine Zusage dieses
  Eintrags.
- **Kein ADR nötig.** Die Adoption **verschärft** (eine zusätzliche Commit-Disziplin, eine engere
  Verweis-Form); [`AGENTS.md`](../../AGENTS.md) §3.5 verlangt einen ADR für **Senkungen**, und
  [`MR-001`](../conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) hält „Anheben →
  Steering-Loop" fest. `spec/lastenheft.md` bleibt in slice-049 unberührt (belegt per
  `git diff --stat`).
- **Auflösungs-Trigger:** Setzung 3 fällt, sobald ein **externer** Auftraggeber existiert — dann
  zeigt der Verweis wieder auf Ticket/Vertragsanhang, wie die Baseline es schreibt. Setzung 1 und 2
  bleiben permanent (sie sind die Substanz, nicht der Ersatz). Bei einem Baseline-Bump, der diesen
  Abschnitt erneut ändert, ist die Adaption neu zu prüfen.
