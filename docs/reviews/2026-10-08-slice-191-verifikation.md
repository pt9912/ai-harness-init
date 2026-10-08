# Verifikations-Bericht: slice-191 — 2026-10-08

**Rolle:** Verifier (Modul 11) · **Modell:** claude-opus-5-5 · **Datum:** 2026-10-08

**Gegenstand:** `36cd07c3`, `f3697747`, `ee0fc36b` gegen slice-191 §2 (DoD) und §3 (Plan);
Review `2026-10-08-slice-191-review.md` (F-1..F-3, in `ee0fc36b` behoben) vollständig gelesen —
Messungen darum als Stichprobe, eigene Rot-Belege dort, wo DoD (2) sie verlangt.

## Verdikte je DoD-Punkt

| DoD | Verdikt | Beleg |
|---|---|---|
| (1) §6 zeigt den vollständigen Bestand, beide Phasen | **bestätigt** | eigener frischer Bootstrap (`ai-harness-init --name vf`, Träger aus `.harness/state/bin/`, HEAD): `bash harness/tools/handbuch-baum.sh docs/user/benutzerhandbuch.md dokument-only <ziel>` → `95 Pfade im Baum … decken den Bestand.`, Exit 0. Bestand dort: `find … -type f` **67**, `-type d` **28** (ohne `.git`, ohne Baseline), `find .harness/baseline -type f \| wc -l` **55** = Zahl im Handbuch. Phase 2: verfügbare Sprachen laut Werkzeug `cpp, go` — beide Delta-Bäume vorhanden; CI `37817812801` (HEAD `ee0fc36b`), Job `full-smoke`: go **13**, cpp **15** Pfade decken den Bestand über der Basis. Erfassungs-Einträge mit *(Erfassung)* etikettiert, Gelingens-Zweig benannt. |
| (2) Baum gegen realen Bestand gehalten, beide Richtungen | **bedingt** | Soll-Quelle ist der reale Lauf aller Stufen (Kandidat 4, §3). `MUTATE_CASES='614-… 615-… 616-…' make mutate` → `3 ok, 0 Befund(e)`, jede Meldung wie `# expect:`; 615 trifft die Erfassungs-Stufe wie verlangt. Eigene Brüche an einer Handbuch-**Kopie** gegen das echte Ziel: Zeile `erfassung-feldliste.md` gestrichen → `vom Lauf angelegt, im Handbuch nicht genannt: [harness/erfassung-feldliste.md];` Exit 1; Baseline-Zahl 55→54 → `.harness/baseline/ traegt im Ziel 55 Dateien, das Handbuch nennt [54];` Exit 1. **Bedingung:** siehe Befund V-1 — die Richtung *emittiert, nicht genannt* ist rot gesehen, aber von keinem `test/mutations/`-Fall gehalten. |
| (3) Register-Ort mit dem Bestand in Übereinstimmung | **bestätigt** | Phase-1-Baum nennt `docs/plan/planning/observations/` als Pfad (`sed -n '500,600p' docs/user/benutzerhandbuch.md \| grep observations`); vom Wächter gegen das Ziel gehalten (Lauf aus (1) grün). |
| `make gates` grün | **bestätigt** | `.harness/state/gates-passed.head` = `ee0fc36b…` = HEAD; CI `37817812801` Job `gates` success. Abschluss-Lauf siehe unten. |
| `make full-smoke` grün | **bestätigt** | CI `37817812801` auf HEAD, Job `full-smoke` (`113450830807`) success, Stufe Handbuch-Baum mit den drei Zeilen oben. |
| `make mutate` grün über die CI | **bedingt** | Teillauf 614–616 lokal grün (oben); der Nacht-Vollsweep nach HEAD liegt noch nicht vor. |
| Register · Risiko-Ausgänge · Paarungen | nicht Gegenstand | Closure-Pflichten des Planners (§3.10); §6 trägt sechs `<offen>`-Ausgänge, §7 ist leer — erwartet vor der Closure. |

## Befunde

- **V-1 (Zusage breiter als ihr Zahn, DoD (2)).** Alle drei Mutations-Fälle enden in derselben
  Vergleichs-Richtung (`im Handbuch genannt, vom Lauf nicht angelegt`): 614 und 615 nehmen eine
  Emission weg, 616 erfindet einen Handbuch-Pfad — beides ist *genannt ohne Emission*. Die zweite
  Richtung (`nur_ziel`, *emittiert ohne Nennung*) hält kein Fall. Gegenprobe an einer Skript-Kopie:
  `nur_ziel=""` statt `comm -13 …` → gegen die gekürzte Handbuch-Kopie `94 Pfade … decken den
  Bestand.`, Exit 0; keiner der Fälle 614–616 würde davon rot. Der Plan selbst schreibt diese Lücke
  vor: sein Rot-Nachweis (Emission wegnehmen + Pfad erfinden) deckt nur eine Richtung, obwohl DoD (2)
  „in beide Richtungen" zusagt. Für die Phase-2-Prüfungen (`kein_delta`, `fehlt_basis`) gilt
  dasselbe; dort hat das Review die Sonden 8/9 synthetisch gefahren. **Adresse:** Planner — ein
  vierter Fall (z. B. Handbuch-Zeile streichen → `vom Lauf angelegt, im Handbuch nicht genannt`)
  oder die Lücke benannt.
- **V-2 (Abnahme-Frage, Plan §4/§6 Risiko 1).** Der Plan rechnete mit **44** Dateien / einem Baum
  von „44 Zeilen statt 12" als Schwelle der Rückführung `in-progress → open`; real trägt der
  Phase-1-Baum **95** Einträge (67 Dateien + 28 Verzeichnisse, gemessen oben; Differenz aus
  slice-190 und Erfassungsschicht). Ob 95 Zeilen in §6 noch Lesehilfe sind oder die Rückführung
  greift, ist Urteil des Planners, kein Befund am Code.

## Plan-vs-Code

- **Plan → Code:** jede Zeile der Umsetzungs-Tabelle §3 ist im Diff (Handbuch §6, `handbuch-baum.sh`,
  Stufe in `full-smoke.sh`, `e2e-abdeckung.md`, Fälle 614–616); `internal/`, `cmd/`,
  `harness/README.md`, `Makefile` unverändert (`git diff --stat 48cdd640 HEAD -- internal cmd
  harness/README.md Makefile` → leer), wie §3 zusagt.
- **Code → Plan:** nichts Ungeplantes; `f3697747` verlegt die Einordnung des ersten d-check-Bezugs
  von Stufe 2 in die neue Stufe — Folge der Stufen-Position aus §3, vom Review gegen die Gleichung
  in `full-smoke.sh` geprüft.

## Negativbefunde

- Handbuch-Setzung: die hinzugefügten Zeilen tragen keine Kennung und keine Chronik (vier
  Muster-Treffer sind Dateinamen `slice-mv.*` bzw. Etiketten `open/`/`next/`).
- `MR-025`: die Zahl 55 steht neben ihrem Kommando und wird vom Wächter gegen das Ziel gehalten
  (eigener Bruch 55→54 rot).
- `ee0fc36b` (Review-Nachlauf) ist von CI-`full-smoke` auf HEAD gedeckt; die neuen Formfehler-Zweige
  nur durch die Review-Sonden (synthetisch), nicht erneut gefahren.

## Offene Punkte für den Planner

- V-1: vierter Mutations-Fall für die Richtung *emittiert, nicht genannt*, oder die Lücke in §7/
  Register benennen.
- V-2: Lesbarkeits-Urteil zu 95 Einträgen gegen die Schwelle aus §4.
- `make mutate` Vollsweep nach HEAD abwarten (DoD-Zeile 4).
