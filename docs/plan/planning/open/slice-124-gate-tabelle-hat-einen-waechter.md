# Slice slice-124: Die Gate-Tabellen werden gegen das Makefile gehalten — von einem Modul, das seit Monaten mitläuft und nichts prüft

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) — Achse (1) des Roadmap-Kandidaten
*Regeln ohne Feedback-Quadrant schließen*. Hermetisch, hängt an keinem anderen Slice der Welle.

**Ebene: Dogfood, nicht emittiert.** Gegenstand sind die Gate-Tabellen **dieses** Repos. Die
emittierte Starter-Config bleibt `modules: [links, anchors]`
([`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed));
ob ein Ziel-Repo `targets` bekommt, entscheidet
[slice-073](slice-073-emittierte-doc-gate-module.md) — dort ist die Frage gestellt, und sie ist
dort eine andere, weil ein frisch gebootstrapptes Ziel andere Utility-Targets hat als wir.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die
Regel, die hier einen Sensor bekommt — *„jeder genannte Gate muss auf frischem Checkout laufen"* —
**und** zugleich die Gegenkraft: ein Modul über leerem Prüfbereich ist selbst der Verstoß),
[`AGENTS.md`](../../../../AGENTS.md) §3.1 (dieselbe Regel als Hard Rule; §4 trägt die Tabelle, die
geprüft wird),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(Gate-*Anheben* → Steering-Loop, kein ADR — die Auflage, unter der dieser Slice steht),
[`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)
(*„Kein Rückfall auf stilles Grün: jede Ventil-Zeile nennt, was sie ausnimmt und warum"* — der
Maßstab für die 19 Ausnahmen, die dieser Slice setzen muss),
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
(Setzung 2 zieht heute die Grenze *behauptet* gegen *advisory*; dieser Slice macht aus einem
advisory-Ziel einen behaupteten Gate und muss die Aufzählung nachziehen),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel).

**Autor:** Planner. **Datum:** 2026-08-28.

---

## 1. Ziel

**Ein Gate, das in [`AGENTS.md`](../../../../AGENTS.md) §4 oder
[`harness/README.md`](../../../../harness/README.md) steht und im
[`Makefile`](../../../../Makefile) fehlt, färbt `make gates` rot — und umgekehrt fällt ein
undokumentiertes Target auf, statt still zu bleiben.**

### Der Anlass: die Regel hat keinen Träger, und das Werkzeug dafür liegt seit Monaten im Image

[`AGENTS.md`](../../../../AGENTS.md) §3.1 verlangt, dass jeder genannte Gate auf frischem Checkout
läuft. Geprüft wird das von nichts: [`.d-check.yml`](../../../../.d-check.yml) führt sechs Module
(`grep -m1 '^modules:' .d-check.yml`), und keines vergleicht Doku gegen Build-Targets. Das Modul
`targets` (`DC-FA-TGT-001`) tut genau das und ist als `doc-targets` in
[`d-check.mk`](../../../../d-check.mk) erzeugt — verdrahtet ist es nirgends
(`grep -rn 'doc-targets' Makefile .github/workflows/*.yml` → kein Treffer, Exit 1).

### Und `make doc-targets` ist heute ein stilles Grün — gemessen, nicht vermutet

Gegen eine Kopie außerhalb des Repos (Stand `1f5741f`, netzlos, `:ro`, Image `v0.65.0` per Digest),
mit einer erfundenen Gate-Zeile ``| `make phantom-gate` | … |`` an
[`AGENTS.md`](../../../../AGENTS.md) angehängt:

| Lauf | Config | Ergebnis |
|---|---|---|
| Flags aus `doc-targets`, Baum **mit** Phantom-Gate | **ohne** `targets:`-Block (heutiger Stand) | `425 Datei(en) geprüft, 0 Befund(e)`, **Exit 0** |
| dieselben Flags, derselbe Baum | **mit** `targets:`-Block | Befunde, Exit 1 |

**Das Ziel läuft, meldet grün und prüft nichts.** Ohne Config-Block ist das Modul inert — die
`targets:`-Sektion ist in `--print-config` auskommentiert und hat keinen Default, der auf dieses
Repo zeigt. `make doc-targets` ist damit heute keine *„verfügbare, nur nicht behauptete"*
Fähigkeit, sondern eine Zusicherung ohne Gegenstand.

### Die Adoptions-Schuld, und sie ist die eigentliche Arbeit

Derselbe Lauf mit `targets:`-Block über den **unveränderten** Baum
(`makefiles: [Makefile]`, `doc-tables: [AGENTS.md, harness/README.md]`, `authority: AGENTS.md`):
**21 Befunde** — **19** × `gate-undocumented`, **2** × `gate-phantom`.

- Die **19** sind Targets im [`Makefile`](../../../../Makefile), die
  [`AGENTS.md`](../../../../AGENTS.md) nicht führt: `help`, `test-bats`, `test-go`, `artifact`,
  `release-artifacts`, `compile`, `smoke`, `full-smoke`, `mutate`, `regelwerk-check`,
  `baseline-freshness`, die vier `freshness-*`, `span-clean`, `span-report`, `hook-overhead`,
  `record-gates`. **Die meisten davon sind zu Recht nicht dort** —
  [`AGENTS.md`](../../../../AGENTS.md) §4 führt die Gates, und `harness/README.md` beschreibt
  ausdrücklich die, die **außerhalb** von `make gates` stehen. Sie brauchen also `exempt-targets`,
  und zwar kuratiert: jede Zeile nennt, was sie ausnimmt und warum
  ([`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)).
  Eine pauschale Liste wäre die Suppression, deren Grund als Nächstes veraltet.
- Die **2** `gate-phantom` (`AGENTS.md:258` und `harness/README.md:43`, beide auf `docs-check`) sind
  **kein Doku-Defekt, sondern ein Config-Defekt meiner Probe**: `docs-check` lebt in
  [`d-check.mk`](../../../../d-check.mk), nicht im [`Makefile`](../../../../Makefile). Die richtige
  Antwort ist `makefiles: [Makefile, d-check.mk]` — und dass die Probe das falsch hatte, ist der
  beste vorhandene Beleg, dass der Config-Block eine **Entscheidung** ist und keine Formsache.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3).

- [ ] **(1) `targets` ist in [`.d-check.yml`](../../../../.d-check.yml) aktiviert und läuft in
      `make gates`.** Aufnahme in `modules:` — nicht als zweites Ziel daneben, sonst entsteht ein
      Gate-Name, den [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
      erst wieder einlösen müsste.
      **Rot:** eine erfundene Zeile ``| `make phantom-gate` | … |`` in
      [`AGENTS.md`](../../../../AGENTS.md) → `make docs-check` fällt und nennt Datei, Zeile und
      `gate-phantom`. Der Lauf **ohne** die Zeile bleibt grün. Beide gehören in den
      Umsetzungs-Commit.
- [ ] **(2) Die 21 Befunde sind aufgelöst — jeder als Doku-Nachzug oder als begründete Ausnahme,
      keiner als stille Liste.** Für jede `exempt-targets`-Zeile steht neben ihr, **warum** das
      Target keine Doku-Pflicht hat; für `docs-check` ist die `makefiles`-Quelle korrigiert statt
      das Target ausgenommen.
      **Rot:** ein `exempt-targets`-Eintrag ohne Begründung, oder eine Liste, die statt der 19
      benannten Targets ein Muster führt — beides macht den Gate über der Ausnahme-Menge blind, und
      genau davor steht
      [`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)
      §Kein Rückfall auf stilles Grün. Mechanisch rot wird der Punkt, wenn nach der Kuratierung ein
      **neues** undokumentiertes Target hinzukommt und `make docs-check` es **nicht** meldet.
- [ ] **(3) Die Grenzziehung in
      [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
      Setzung 2 ist nachgezogen — als Übergabe, nicht als Eigenmacht.** Sie zählt heute `docs-check`
      als **einziges** behauptetes Ziel und die übrigen elf als advisory; nach diesem Slice stimmt
      das nicht mehr.
      **Kein Kommando färbt diesen Punkt rot**, und das ist der Befund, keine Vertagung: der
      Adaptions-Block ist Architect-Eigentum ([`AGENTS.md`](../../../../AGENTS.md) §3.8), und kein
      Modul des Doku-Gates liest den Wahrheitsgehalt einer MR-Aufzählung. Der Slice liefert die
      Messung; der Norm-Text entsteht im Architect-Lauf.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Doku-Update, falls ein öffentlicher Vertrag berührt ist · Closure-Notiz mit
Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`.d-check.yml`](../../../../.d-check.yml) | update | `targets` in `modules:` **und** der `targets:`-Block mit `makefiles`/`doc-tables`/`authority`/`exempt-targets` — der Kern des Slice |
| [`AGENTS.md`](../../../../AGENTS.md) §4 | update | Doku-Nachzug für die Targets, die dort **hingehören**; die Gate-Tabelle ist die `authority` und wird durch den Slice erstmals mechanisch gehalten. **§3 bleibt unberührt** (Hard Rules sind Architect-Eigentum, §3.8) |
| [`harness/README.md`](../../../../harness/README.md) | update | zweite `doc-tables`-Quelle; hier steht, was **außerhalb** von `make gates` läuft — genau die Unterscheidung, die `exempt-targets` mechanisch macht |
| `test/` | neu | der Fall, der die Zusage aus DoD (1) rot färbt, plus sein `test/mutations/`-Zahn |
| [`harness/conventions.md`](../../../../harness/conventions.md) | **nicht durch diesen Slice** | [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) (Modul-Liste) und [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) Setzung 2 (Grenzziehung) sind nachzuziehen — **Übergabe** an den Architect, DoD (3) |
| [`internal/emit/`](../../../../internal/emit) | **unverändert** | Ebene Dogfood (Kopfzeile); die emittierte Modul-Liste entscheidet [slice-073](slice-073-emittierte-doc-gate-module.md) |

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md)
ist gestartet und das WIP-Limit ist frei.** Der Slice ist hermetisch und wartet auf keinen anderen —
insbesondere **nicht** auf [slice-123](slice-123-ci-sieht-die-historie.md): `targets` liest keine
Historie und ist auf einem Klon der Tiefe 1 genauso scharf wie auf einem vollen.

**Rückführungen, vorab benannt:**

- `in-progress` → `next`: die Kuratierung der 19 zeigt, dass die Gate-Tabellen selbst uneinheitlich
  sind — dann ist die Doku-Bereinigung ein eigener Schnitt und die Modul-Aktivierung ein zweiter.
  Ein vierter DoD-Punkt wäre die falsche Antwort.
- `in-progress` → `open`: das Modul verlangt eine Ausnahme-Form, die dieses Repo nicht vertreten
  kann (z. B. nur Muster statt exakter Namen — `exempt-targets` ist laut `--print-config`
  ausdrücklich **exakt, kein Glob**, was hier hilft, aber bei den vier `freshness-*` eine
  Aufzählung erzwingt). Dann ist die Lage ein Carveout nach Modul 7, kein stiller Kompromiss.

## 5. Closure-Trigger

DoD (1) bis (3) erfüllt mit gefahrenen Kommandos, `make gates` grün (**mit** `targets` in der
Modul-Liste), `make mutate` ohne Befund, Review nach Modul 10 und Verifikation nach Modul 11 ohne
blockierenden Befund, Closure-Notiz in §7 mit Steering-Loop-Eintrag und der ausgewiesenen Übergabe
aus DoD (3).

## 6. Risiken und offene Punkte

- **Die 19 Ausnahmen sind die Stelle, an der dieser Slice scheitern kann.** Ein Gate, dessen
  Ausnahme-Liste die Hälfte des [`Makefile`](../../../../Makefile) umfasst, prüft die andere Hälfte
  — das ist zulässig, aber es ist **nicht**, was die Zusage sagt. Die Meldung und
  [`harness/README.md`](../../../../harness/README.md) müssen den Ausschnitt benennen, so wie
  `make comment-claims` seine „N Datei(en) geprueft"-Zeile führt.
- **`authority: AGENTS.md` macht eine Datei zur Vollständigkeits-Quelle, die zwei Rollen gehört.**
  §3 schreibt der Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8), §4 wächst mit den
  Artefakten. Dieser Slice fasst nur §4 an — und das ist eine Grenze, die niemand mechanisch prüft
  (kein Modul des Doku-Gates liest Commits oder Abschnitts-Eigentum). Sie hängt am Rollen-Wechsel,
  nicht an einem Sensor.
- **Ein zweiter, stiller Prüfbereich entsteht mit `doc-tables`.** Wird
  [`harness/README.md`](../../../../harness/README.md) dort geführt, aber nicht als `authority`,
  prüft das Modul in **eine** Richtung (Phantom), nicht in beide. Was das bedeutet, gehört
  aufgeschrieben, sonst liest die nächste Runde „die Tabellen sind bewacht" und meint beide.
- **Der Befund `gate-phantom` auf `docs-check` ist ein Warnschuss für die ganze Welle.** Er kam aus
  einer Config, die eine plausible Annahme traf (`makefiles: [Makefile]`) und damit an einem
  **richtigen** Doku-Eintrag rot wurde. Eine Adoption, die solche Befunde durch Ausnahmen statt
  durch Config-Korrektur beseitigt, baut sich ein stilles Grün ein — dieselbe Klasse, die der Slice
  schließen soll.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example). Ein Begründungsblock
entfällt: der Slice legt keine neue Sub-Area an und berührt keine in BF oder Hybrid. Die
Gate-Konfiguration ist konventionell dicht bis zur Vorschrift: [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
begründet jede aktive Modul-Zeile, und [`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)
setzt den Maßstab für jede Ausnahme.
