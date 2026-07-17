# Slice slice-013: Vorlagen und Slice-Köpfe auf v3.1.0-Form

**Status:** next

**Welle:** ohne Welle (Harness-Wartung). Einordnung *(Kontext, nicht normativ)*:
[roadmap](../in-progress/roadmap.md).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-16. **Überarbeitet:** 2026-07-17
(Ziel-Tag v3.0.0 → v3.1.0; Status-Feld-Teil neu gefasst; Schnitt → slice-014).

---

## 1. Ziel

Die **mechanischen** Nachzüge an Vorlagen und Slice-Köpfen, die alle dieselben
Dateien anfassen und in *einer* Review-Sitzung prüfbar sind. Grundlage ist der
gegen **v3.1.0** verifizierte Stand (2026-07-17; die Befunde des v3.0.0-Modul-Reviews
vom 2026-07-16 wurden gegen v3.1.0 nachgemessen, s. §6).

1. **Kurs-Link-Pins.** `templates-v4` → `v3.1.0`, repo-weit. Falle dabei: die
   Entdidaktisierung hat Abschnitte umbenannt, auf die das Repo verlinkt — **zwei**
   tote Anker, beide gegen v3.1.0 verifiziert:
   - `#worked-example-eine-reviewer-skill-datei-schreiben` → der Abschnitt heißt
     jetzt `### Ziel-Form: Reviewer-Skill` (`regelwerk/modul-10-review-harness.md:44`),
     Anker also `#ziel-form-reviewer-skill`. Er ist auch im gelieferten Template noch
     falsch, also nicht blind kopieren.
   - `#worked-mini-example-bootstrap-modus-pro-sub-area-für-einen-slice-begründen`
     in `docs/plan/planning/slice.template.md:99` → „Worked Mini-Example" kommt in
     v3.1.0 `modul-05` **null Mal** vor; der Abschnitt heißt jetzt
     `### Ziel-Form: Sub-Area-Modus-Begründung` (`modul-05:82`).

   **Anker sind mit `curl` nicht prüfbar** — eine GitHub-Blob-URL liefert HTTP 200
   unabhängig vom Fragment. Der Erreichbarkeits-Beleg aus der DoD deckt also die
   *URL*, nicht den *Anker*; letzterer wird gegen den vendored Baum geprüft (nach
   slice-011 lokal vorhanden) oder gegen `x-v3.1.0/regelwerk/`.
2. **ADR-Platzhalter.** `ADR-<NN>` → `ADR-<NNNN>` — genau der Platzhalter, der heute
   dem Repo-Schema aus [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) und `.d-check.yml` widerspricht und nur wegen
   der Template-Ignore-Regel gate-still bleibt. v3.1.0 führt ihn durchgehend
   vierstillig (verifiziert: alle sieben Vorkommen in `templates/`).
3. **Status-Feld → Lifecycle-Notiz.** Der Slice-Kopf verliert `**Status:**`
   ersatzlos; an seine Stelle tritt die v3.1.0-Notiz, dass **das Verzeichnis der
   Zustand ist**. Das ist reine **Konformität**, keine Abweichung — und damit
   **ohne** Adaptions-Eintrag (s. §6).

**Abgrenzung.** Mechanik/Vendoring: slice-011. Tote Quellen-Pointer und
§Baseline-Stand: slice-012. Die **inhaltlichen** Nachzüge (Reviewer-Skill-Pflichtkontext,
Wellen-Closure-Prozedur): slice-014 — sie fassen andere Dateien an und sind
separat prüfbar. Der d-check-Pin-Sprung (v0.10.0 → 0.43.1, 33 Minors) ist ein
eigener Slice mit eigenem Risiko. **`done/` bleibt Archiv** — die fünf
abgeschlossenen Slices behalten Status-Feld und `templates-v4`-Pins (bewusste
Entscheidung, siehe §6).

## 2. Definition of Done

- [ ] Kurs-Link-Pins `templates-v4` → `v3.1.0` in `docs/plan/planning/slice.template.md`,
      `welle.template.md`, `in-progress/roadmap.md`, `docs/reviews/review-report.template.md`
      und den `open/`-Slices; **beide** toten Anker ersetzt
      (`#ziel-form-reviewer-skill` und `#ziel-form-sub-area-modus-begründung`, s. §1);
      **jeder** geänderte Link per `curl` als erreichbar belegt **und jeder Anker
      zusätzlich gegen den Modul-Text** (`curl` sieht Fragmente nicht —
      [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
- [ ] `ADR-<NN>` → `ADR-<NNNN>` in `docs/plan/adr/NNNN-titel.template.md`,
      `docs/plan/planning/slice.template.md`, `welle.template.md` — Schema-Konsistenz
      mit [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) und `.d-check.yml`.
- [ ] `**Status:**` ist aus `slice.template.md` und **allen aktiven Slices**
      (`open/` + `next/`, einschließlich dieses Slice selbst) entfernt und durch die
      v3.1.0-`**Lifecycle:**`-Notiz ersetzt (Verzeichnis = Zustand, Wechsel nur per
      `git mv`). **`welle.template.md` behält sein `**Status:**`** — v3.1.0 streicht
      das Feld nur im *Slice*-Kopf (verifiziert: `welle.template.md:10` führt es
      unverändert). `docs/plan/planning/README.md:20` bleibt damit die einzige
      Lifecycle-Quelle; `done/` unberührt (Archiv, s. §6).
- [ ] `make gates` grün; Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/plan/planning/slice.template.md` | update | Link-Pins + ADR-Platzhalter + Status → Lifecycle-Notiz |
| `docs/plan/planning/welle.template.md` | update | Link-Pins + ADR-Platzhalter (Status-Feld **bleibt**) |
| `docs/plan/adr/NNNN-titel.template.md` | update | ADR-Platzhalter vierstellig |
| `docs/reviews/review-report.template.md` | update | Link-Pin + toter Anker |
| `docs/plan/planning/in-progress/roadmap.md` | update | Link-Pins |
| `docs/plan/planning/open/slice-0*` | update | Link-Pins + Status-Feld raus (Glob, nicht Aufzählung — der Bestand wächst; Stand 2026-07-17: 001…005 + 015) |
| `docs/plan/planning/next/slice-0*` | update | Status-Feld raus (aktive Slices, s. DoD 3) |

## 4. Trigger

Nach slice-012 (Reihenfolge ist Bequemlichkeit, keine harte Abhängigkeit — die
Änderungen überschneiden sich nicht).

**Überschneidung mit slice-014 — nicht datei-disjunkt.** Der Status-Sweep (DoD 3)
erfasst *alle dann noch aktiven* Slice-Köpfe, also auch `next/slice-014-…md:3`,
solange slice-014 nicht in `done/` liegt. Die Berührung ist **eine Zeile** (das
Kopf-Feld), aber sie existiert: die beiden Slices **nicht parallel** fahren, sonst
Merge-Konflikt genau dort. Reihenfolge egal — läuft slice-014 zuerst durch nach
`done/`, greift für ihn die Archiv-Regel und der Sweep lässt ihn aus; läuft
slice-013 zuerst, nimmt der Sweep slice-014s Kopf mit.

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **Warum dieser Schnitt und nicht der ursprünglich markierte.** Der Vorgänger-Zuschnitt
  trennte den Status-Feld-Teil ab, weil er einen eigenen Adaptions-Eintrag getragen
  hätte und an keinem anderen Punkt hing. Beides ist mit v3.1.0 hinfällig: der
  MR-Eintrag entfällt (Konformität statt Abweichung), und die Status-Änderung fasst
  **dieselben sechs Dateien** an wie die Link-Pins (`slice.template.md`,
  `open/slice-001…005`) — sie abzutrennen hieße, zweimal dieselben Dateien
  anzufassen. Geschnitten ist jetzt nach **Prüfbarkeit und Datei-Lokalität**:
  mechanisch (hier) vs. inhaltlich (slice-014).
- **Offen — die „≤ 3 DoD-Punkte"-Regel ist in v3.1.0 nicht entscheidbar.** Modul 5
  hebt sie von der Faustregel zum **Regeltext**: „**Zu groß**, wenn eines zutrifft:
  mehr als drei DoD-Punkte · mehrere Schichten betroffen · nicht in *einer*
  Review-Sitzung prüfbar" (`modul-05:71-73`), und „Jeder Schnitt-Slice ist **einzeln
  lieferbar** […], hat **≤ 3 DoD-Punkte** und berührt **höchstens zwei Schichten**"
  (`modul-05:78-80`). **Aber v3.1.0 widerspricht sich selbst**
  (die eigene Vorlage liefert **5** DoD-Checkboxen) **und hat die Einheit
  wegdidaktisiert:** das `SL-014`-Worked-Example, das in v1.2.0 noch definierte, was
  ein DoD-Punkt *ist* (`SL-014a` = **ein Satz mit drei Klauseln** = „3 DoD-Punkte"),
  ist ab v3.0.0 ersatzlos entfallen — Modul 5 schrumpfte von **219 auf 120 Zeilen**,
  „Faustregel" und `SL-014` kommen null Mal vor (gemessen 2026-07-17 gegen den
  **adoptierten** v1.2.0-`lab-regelwerk`-Baum, nicht gegen `kurs/de/` — die beiden
  Bäume sind nicht deckungsgleich: die didaktische Kurs-Fassung desselben Moduls
  hat 300 Zeilen und führt `SL-014` weiterhin). Damit ist
  „zählt die Regel Häkchen oder Verhaltens-Zusagen?" **nicht mehr aus dem geltenden
  Text belegbar**, nur noch aus der Historie erschließbar. Wer die Zahl wörtlich auf
  Häkchen anwendet, bricht sie mit der Vorlage der Baseline selbst; wer sie auf
  Zusagen anwendet, liegt bei jedem Repo-Slice weit über 3. **Erst klären, dann
  schneiden** — dieser Slice ist bewusst nach Kriterium 3 („eine Review-Sitzung")
  geschnitten, das in *beiden* Lesarten unstrittig ist, nicht nach der Zahl. Danach
  ggf. eigener Slice, und nur für `open/`. `done/` bleibt unberührt.
- **`done/` bleibt Archiv — bewusste Entscheidung, keine Auslassung.** Die fünf
  abgeschlossenen Slices behalten Status-Feld und `templates-v4`-Pins. Begründung:
  sie sind Nachweis dessen, was zum Abschlusszeitpunkt galt; ein Archiv nachträglich
  auf eine neue Konvention zu ziehen, erzeugt Diff-Rauschen ohne Erkenntnisgewinn.
  Folge, die zu tragen ist: `grep`-Ergebnisse über `docs/plan/planning/` sind ab hier
  gemischt (Archiv alt, aktiv neu) — wer den Bestand zählt, muss `done/` ausnehmen.
- **Kein Handlungszwang bei `closure-note-reviewer.md`.** Der Skill ist **keine** neue
  Pflicht-Rolle (stand schon in v1.2.0; neu ist nur eine Vorlage). Die Vorlage
  verdrahtet ein Python-Tool und wäre 1:1 kopiert ein Verstoß gegen
  [`ADR-0003`](../../adr/0003-go-native-binaries.md) — und nach dem eigenen Reviewer-Skill selbst ein HIGH
  („halluziniertes Gate"). Die vorbestehende Lücke (Closure-Notiz-Pflicht ohne jeden
  Sensor) ist real, aber älter als dieses Upgrade → Kandidat für `open/`.
- **Kein Schema-Wechsel bei LH-IDs.** Modul 3 schreibt `<PREFIX>-FA-NNN`
  (dreistellig), das v3.1.0-eigene `lastenheft.template.md` `<NN>` (zweistellig) —
  ein Widerspruch **innerhalb** v3.1.0. Nicht als Schema-Wechsel lesen;
  `.d-check.yml` bleibt unangetastet.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe
[Kurs Modul 5](https://github.com/pt9912/ai-harness-course/blob/v3.1.0/kurs/de/02-planung/modul-05-planning-harness.md)):
Planning-Doku und Vorlagen teilen die adoptierte Harness-Mechanik
([`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)); GF (Doc führt).
