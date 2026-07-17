# Slice slice-013: Konformitäts-Nachzug auf Baseline v3.0.0

**Status:** next

**Welle:** ohne Welle (Harness-Wartung). Einordnung *(Kontext, nicht normativ)*:
[roadmap](../in-progress/roadmap.md).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-16.

---

## 1. Ziel

Die vier Stellen nachziehen, an denen v3.0.0 inhaltlich **mehr** verlangt als
v1.2.0 oder das Repo auf einen überholten Stand zeigt. Grundlage ist das
Modul-Review vom 2026-07-16 (21 Diffs, ~2.500 Zeilen): v3.0.0 ist ganz
überwiegend Entdidaktisierung — die Substanz-Funde sind klein und hier
vollständig aufgezählt.

1. **Reviewer-Kontext-Eingang.** v3.0.0 hebt ihn vom Beispielblock zum
   „Operativen Pflichtteil" (Modul 10 §Ziel-Form: Reviewer-Skill). Pflicht ist
   u. a. „vorherige Findings am gleichen Modul" — der einzige Punkt, den
   `.harness/skills/reviewer.md` nicht führt.
2. **Wellen-Closure-Prozedur.** Modul 6 schreibt neu fünf Schritte mit Beleg vor
   (inkl. **Wave-Self-Close-Commit** — im alten Regelwerk existiert der Begriff
   nicht). `welle-01-offline-kern.md` §3 deckt Schritt 1 und 3; Carveout-Audit,
   Self-Close-Commit und Roadmap-Fortschreibung fehlen.
3. **Kurs-Link-Pins.** `templates-v4` → `v3.0.0`, repo-weit. Falle dabei: der
   Anker `#worked-example-eine-reviewer-skill-datei-schreiben` existiert in
   v3.0.0 nicht mehr (Abschnitt heißt jetzt „Ziel-Form: Reviewer-Skill") — er ist
   auch im gelieferten v3.0.0-Template noch falsch, also nicht blind kopieren.
4. **ADR-Platzhalter.** v3.0.0 korrigiert `ADR-<NN>` → `ADR-<NNNN>` — genau der
   Platzhalter, der heute dem Repo-Schema aus [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) und `.d-check.yml`
   widerspricht und nur wegen der Template-Ignore-Regel gate-still bleibt.
5. **Status-Feld im Slice-Kopf.** Das Template führt `**Status:**` mit der
   Vier-Zustands-Legende `open → next → in-progress → done` — ein Feld, das vier
   Zustände gleichzeitig behauptet. Alle 10 bestehenden Slices tragen sie
   durchkopiert; **v3.0.0 liefert sie unverändert genauso**. Richtig sieht es im
   selben Repo aus: `welle-01-offline-kern.md:3` → `**Status:** in-progress`, ein
   Wert (und `welle.template.md:10` trennt die Alternativen mit Pipes, nicht mit
   Pfeilen). Die drei Slices aus diesem Zug (`next/slice-011…013`) tragen bereits
   einen Wert; Template und Bestand ziehen hier nach. Weil v3.0.0 die Legende so
   ausliefert, ist das eine **Abweichung von der Baseline** → Adaptions-Eintrag
   mit Begründung und Auflösungs-Trigger.

**Abgrenzung.** Mechanik/Vendoring: slice-011. Tote Quellen-Pointer und
§Baseline-Stand: slice-012. Der d-check-Pin-Sprung (v0.10.0 → 0.43.1, 33 Minors)
ist ein eigener Slice mit eigenem Risiko. **`done/` bleibt Archiv** — die fünf
abgeschlossenen Slices behalten die Legende (bewusste Entscheidung, siehe §6),
ebenso ihre `templates-v4`-Link-Pins.

## 2. Definition of Done

- [ ] `.harness/skills/reviewer.md` §Eingangs-Kontext führt „vorherige Findings
      am gleichen Modul"; Skill-Version gehoben (versioniert, **nicht**
      überschrieben — Modul 10).
- [ ] `welle-01-offline-kern.md` §3 trägt die fehlenden Closure-Schritte
      (Carveout-Audit · Wave-Self-Close-Commit · Roadmap-Fortschreibung) und
      nennt die Closure-Notiz unter `done/` (heute ohne Präfix, `:29`) — konsistent
      mit `docs/plan/planning/README.md:26`.
- [ ] Kurs-Link-Pins `templates-v4` → `v3.0.0` in `docs/plan/planning/slice.template.md`,
      `welle.template.md`, `in-progress/roadmap.md`, `docs/reviews/review-report.template.md`
      und den fünf `open/`-Slices; toter Anker ersetzt; **jeder** geänderte Link
      per `curl` als erreichbar belegt ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
- [ ] `ADR-<NN>` → `ADR-<NNNN>` in `docs/plan/adr/NNNN-titel.template.md`,
      `docs/plan/planning/slice.template.md`, `welle.template.md` — Schema-Konsistenz
      mit [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) und `.d-check.yml`.
- [ ] `**Status:**` trägt **einen** Wert: `slice.template.md` als Platzhalter
      (Lifecycle-Legende raus — sie lebt in `docs/plan/planning/README.md`),
      `open/slice-001…005` → `open`. `done/` unberührt.
- [ ] `docs/plan/planning/README.md` stellt klar, dass das Feld das Verzeichnis
      **spiegelt** (Verzeichnis bleibt führend, `:20`) und die Promotion damit
      reiner `git mv` **plus** separater Feld-Commit ist (Hard Rule „git mv +
      Inhaltsänderung = zwei Commits").
- [ ] Adaptions-Eintrag in `harness/conventions.md` (nächste freie Nummer):
      Status-Feld-Abweichung vom Baseline-Slice-Template, Begründung +
      Auflösungs-Trigger.
- [ ] `make gates` grün; Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.harness/skills/reviewer.md` | update | Pflicht-Kontext-Eingang (Modul 10), Version-Bump |
| `docs/plan/planning/welle-01-offline-kern.md` | update | Closure-Prozedur Schritte 2/4/5 + `done/`-Pfad |
| `docs/plan/planning/slice.template.md` | update | Link-Pins + ADR-Platzhalter + Status-Feld (ein Wert) |
| `docs/plan/planning/welle.template.md` | update | Link-Pins + ADR-Platzhalter |
| `docs/plan/adr/NNNN-titel.template.md` | update | ADR-Platzhalter vierstellig |
| `docs/reviews/review-report.template.md` | update | Link-Pin + toter Anker |
| `docs/plan/planning/in-progress/roadmap.md` | update | Link-Pins |
| `docs/plan/planning/open/slice-001…005` | update | Link-Pins + Status-Feld (`open`) |
| `docs/plan/planning/README.md` | update | Feld spiegelt Verzeichnis (`:20`); Promotion = `git mv` + Feld-Commit |
| `harness/conventions.md` | update | Adaptions-Eintrag: Status-Feld-Abweichung vom Baseline-Template |

## 4. Trigger

Nach slice-012 (Reihenfolge ist Bequemlichkeit, keine harte Abhängigkeit — die
Änderungen überschneiden sich nicht).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **`done/` bleibt Archiv — bewusste Entscheidung, keine Auslassung.** Die fünf
  abgeschlossenen Slices behalten die Vier-Zustands-Legende und ihre
  `templates-v4`-Link-Pins. Begründung: sie sind Nachweis dessen, was zum
  Abschlusszeitpunkt galt; ein Archiv nachträglich auf eine neue Konvention zu
  ziehen, erzeugt Diff-Rauschen ohne Erkenntnisgewinn. Folge, die zu tragen ist:
  `grep`-Ergebnisse über `docs/plan/planning/` sind ab hier gemischt (Archiv alt,
  aktiv neu) — wer den Bestand zählt, muss `done/` ausnehmen.
- **Dieser Slice ist der größte der drei.** Er berührt vier Bereiche
  (`.harness/skills/`, Planning-Doku, Vorlagen, `harness/conventions.md`). Wenn er
  in der Umsetzung nicht in *einer* Review-Sitzung prüfbar ist (Modul 5
  §Ziel-Form: Slice), ist der Status-Feld-Teil (Punkt 5 + zugehöriger
  Adaptions-Eintrag) die natürliche Schnittkante für einen eigenen Slice — er
  hängt an keinem der anderen vier Punkte.
- **Bewusst NICHT in diesem Slice: die „≤ 3 DoD-Punkte"-Regel.** Modul 5 hebt sie
  von der Faustregel zum Regeltext; alle 10 Repo-Slices liegen bei 6–8. Aber
  v3.0.0 **widerspricht sich hier selbst** — das mitgelieferte
  `slice.template.md` gibt fünf DoD-Checkboxen vor. Wer die Zahl wörtlich
  anwendet, bricht sie mit der eigenen Vorlage. Erst klären, ob DoD-Punkte
  Liefereinheiten oder Prüf-Häkchen zählen; dann ggf. eigener Slice, und nur für
  `open/`. `done/` bleibt unberührt.
- **Offen: `lastenheft_refs` vs. Klartext-`**Bezug:**`-Zeile.** Modul 15 streicht
  die Notiz, die die Klartext-Variante ausdrücklich erlaubte; Modul 16 fordert
  unverändert „Slices tragen `lastenheft_refs`" mit Beleg „Frontmatter-Grep".
  Das Repo fährt durchgehend Klartext und hat kein Frontmatter — entlastend
  liefert das v3.0.0-`slice.template.md` **selbst** die Klartext-Form. Nicht akut
  (keine Welle in Freigabe, kein Release-Verzeichnis im Repo), aber die Wahl
  gehört als eigener MR-Eintrag festgeschrieben, bevor sie an einer gestrichenen
  Kurs-Notiz hängt.
- **Kein Handlungszwang bei `closure-note-reviewer.md`.** Der Skill ist **keine**
  neue Pflicht-Rolle (stand schon in v1.2.0; neu ist nur eine Vorlage). Die
  Vorlage verdrahtet ein Python-Tool und wäre 1:1 kopiert ein Verstoß gegen
  [`ADR-0003`](../../adr/0003-go-native-binaries.md) — und nach dem eigenen Reviewer-Skill selbst ein HIGH
  („halluziniertes Gate"). Die vorbestehende Lücke (Closure-Notiz-Pflicht ohne
  jeden Sensor) ist real, aber älter als dieses Upgrade → Kandidat für `open/`.
- **Kein Schema-Wechsel bei LH-IDs.** Modul 3 schreibt `<PREFIX>-FA-NNN`
  (dreistellig), das v3.0.0-eigene `lastenheft.template.md` `<NN>` (zweistellig)
  — ein Widerspruch **innerhalb** v3.0.0. Nicht als Schema-Wechsel lesen;
  `.d-check.yml` bleibt unangetastet.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe
[Kurs Modul 5](https://github.com/pt9912/ai-harness-course/blob/v3.0.0/kurs/de/02-planung/modul-05-planning-harness.md)):
`.harness/skills/`, Planning-Doku und Vorlagen teilen die adoptierte
Harness-Mechanik ([`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)); GF (Doc führt).
