# Slice slice-gepinnte-bilder-bekommen-einen-schwachstellen-scan: Gepinnte Bilder bekommen einen Schwachstellen-Scan

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — keine Closure-Bedingung, die mehr beobachtet als die DoD.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten),
[`AGENTS.md`](../../../../AGENTS.md) §3.9. Freigabe des Auftraggebers 2026-10-10.

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-10.

---

## 1. Ziel und Abgrenzung

**Ziel:** Ein Werkzeug meldet, welche der per Digest gepinnten Fremd-Bilder des Repos bekannte
Schwachstellen tragen, bevor ein Mensch sie von Hand findet. Anlass: drei Pin-Sprünge
(d-check `v0.86.1`, a-check `v0.23.2`, Go 1.27.x) kamen aus Meldungen des Auftraggebers, nicht aus
einem Sensor (`BEO-ALL/gepinntes-bild-ohne-schwachstellen-scan`).

**Lage**, gemessen (keine Erwartungswerte, [`MR-025`](../../../../harness/conventions.md#mr-025)
Setzung 2):

```sh
git grep -lE '@sha256:[0-9a-f]{64}' -- ':!docs' ':!.harness/baseline' ':!test'
#   Dockerfile, Makefile, d-check.mk, harness/tools/*.sh, internal/emit/templates/enforce/*.sh, MR-Einträge
```

Die Stellen sind uneinheitlich (Dockerfile-`FROM`, Makefile-Variablen, emittierte Skripte); das
Inventar ist Teil von Liefer-Punkt 1.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Release-Blocker, kein Gate in `make gates`.** *Anderer Vorgang:* ein Scan braucht Netz
  (Schwachstellen-Datenbank), `make gates` ist netzlos ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten));
  er läuft nächtlich neben `regelwerk-check` und `baseline-freshness` und hält weder Push noch Release auf.
- **Kein automatischer Pin-Sprung bei Befund.** *Anderer Vorgang:* der Sensor meldet; ob und auf
  welchen Tag gesprungen wird, bleibt Entscheidung mit Mess-Bilanz ([`MR-063`](../../../../harness/conventions.md#mr-063)).
- **Kein Scan des emittierten Ziels oder von Adopter-Bildern.** *Schicht-Abgrenzung:* der Slice
  betrifft die Pins dieses Repos; was das Werkzeug ins Ziel schreibt, ist eine eigene Entscheidung
  (Dogfood gegen emittiert).
- **Der Wächter Tag↔Digest.** *Folge-Slice übernimmt es:*
  `slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor` Teil (b)
  (`BEO-ALL/pin-digest-ohne-waechter`); Gegenstand dort ist die Kopplung, hier die Bewertung.

## 2. Definition of Done

- [ ] **(1) Inventar und Scanner-Wahl.** Jedes per Digest gepinnte Fremd-Bild des Repos ist mit
      Fundstelle aufgelistet; der Scanner ist ein Docker-only-Image, per Digest gepinnt. Die Wahl
      des Werkzeugs ist eine Architektur-Entscheidung: Übergabe an den Architect liegt als eigener
      Commit vor ([`AGENTS.md`](../../../../AGENTS.md) §3.8, ADR oder MR).
- [ ] **(2) Das Target.** `make <target>` scannt das Inventar aus (1), nächtlich im Workflow neben
      den Netz-Sensoren, mit `kein Gate`-Zeile in `harness/README.md` §Werkzeuge. **Rot gesehen:** ein
      bekannt verwundbares, gepinntes Bild färbt den Lauf rot, mit der Meldung gelesen (richtiger
      Grund, nicht Netzfehler); der unveränderte Bestand ist die Gegenprobe.
- [ ] **(3) Die Grenze steht.** Was der Scan nicht sagt (Datenbank-Stand, Findings ohne Fix,
      Bilder ohne Digest) steht am Target in `harness/sensors/<target>.md`.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: `harness/README.md` §Werkzeuge, `harness/sensors/<target>.md`.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind nach dem Move geprüft, §7.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `Makefile` (+ Workflow in `.github/workflows/`) | update | Target und nächtlicher Aufruf (2) |
| `harness/tools/` (Skript, falls das Target mehr als einen Aufruf braucht) | neu | Inventar aus (1) lesen, scannen |
| `harness/sensors/<target>.md`, `harness/README.md` | neu / update | (3), §Werkzeuge |
| `test/` | neu | Zahn zu (2): verwundbares Bild färbt rot |

## 4. Trigger

**Start** (`next` → `in-progress`): `in-progress/` trägt keinen Slice, der Slice ist priorisiert;
die Architect-Übergabe zu (1) darf der Implementer-Lauf auslösen.

**Rückführungen:**

- `in-progress` → `next`: das Inventar zeigt Pin-Formen, die ein Scanner nicht liest (kein
  einheitlicher Zugang) — dann trennt ein Re-Slice nach Pin-Form.
- `in-progress` → `open`: kein Scanner ist ohne Host-Installation und ohne unpinnbares Netz
  lauffähig — Übergabe an den Auftraggeber.

## 5. Closure-Trigger

DoD (1)–(3) mit gelesenem rotem Lauf; `make gates` grün; Review konform, Verifikation bestätigt;
Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Der Scanner meldet Befunde ohne verfügbaren Fix und wird dauerhaft rot. — **Ausgang:** bei Closure.
- Die Schwachstellen-Datenbank braucht Netz an einer Stelle, die der nächtliche Lauf nicht hat. — **Ausgang:** bei Closure.

## 7. Closure-Notiz

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <…>
- **Drei Paarungen:** <…>

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo, `ALL`) und
`harness/tools/` (`TOOLS`); beide erfüllen die Schwelle.

**Vorgelagert — offene Beobachtungen sichten:** Register `BEO-ALL/` gemergter Stand (Zähler:
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, 2026-10-10, keine
Erwartungswerte). Treffer: `gepinntes-bild-ohne-schwachstellen-scan` 3, `geplant` auf diesem Slice
(Gegenstand) · `pin-digest-ohne-waechter` 5, `geplant` auf
`slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor` (Nachbar, siehe §1) ·
`neue-isolation-entzahnt-bestehende-waechter` 1, `offen` (Netz-Target läuft außerhalb der
`--network none`-Gates; kein Treffer auf bestehende Wächter erwartet).

**Modus:** alle berührten Sub-Areas GF.
