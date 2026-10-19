# Slice slice-benutzerhandbuch-fuehrt-java-python-csharp: Das Benutzerhandbuch führt java, python und csharp und hält seine Sprachbäume gegen die Emission

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD dieses Slice. Die Welle
[welle-sprachprofile-java-python-csharp](../welle-sprachprofile-java-python-csharp.md) schließt
den Handbuch-Nachzug ausdrücklich aus (§6 dort); er ist darum kein Mitglied ihrer Slice-Liste.

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) (die
Sprachen, die das Handbuch nennt) ·
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (die Stufe
„Handbuch-Baum" in `full-smoke` trägt diese Kennung) ·
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6).
Auslöser: Auftrag des Auftraggebers vom 2026-10-18 („auch das Handbuch soll auf dem Ist-Zustand
sein"). Das Lastenheft führt keine Anforderung an ein Benutzerhandbuch
(`grep -c -i 'handbuch' spec/lastenheft.md` → `0`); das Handbuch ist Rang 6 der Source Precedence
([`AGENTS.md`](../../../../AGENTS.md) §2), und die Zusage, es trage den Ist-Zustand, hängt allein
an den Sprachen und Bauformen, die [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) und [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) liefern.

**Berührte Spec-Stellen:** —

**Verantwortlich:** dburkard

**Autor:** Planner. **Datum:** 2026-10-19.

---

## 1. Ziel und Abgrenzung


**Ziel:** `docs/user/benutzerhandbuch.md` beschreibt die sechs Sprachen, die `SupportedLangs()` führt
(`go`, `cpp`, `kotlin`, `java`, `python`, `csharp`), mit ihren Bauformen und Knöpfen, und der Baum
jeder Sprache im Handbuch ist in `make full-smoke` gegen die Emission gehalten.

**Gemessener Ist-Zustand** (2026-10-19, `grep -c -i <sprache> docs/user/benutzerhandbuch.md`):
`kotlin` 15, `cpp` 12, `java` 0, `python` 0, `csharp` 0. Das Werkzeug trägt die drei
fehlenden Sprachen mit `flat` und `hexslice` (`langArchs()` in `internal/gen/gen.go`); das
Handbuch sagt an der Bauform-Grenze („`--arch hexslice` liefern alle drei Zielsprachen“), in der
`--lang`-Tabelle, bei den `SKEL_<SPRACHE>_VERSION`-Knöpfen, im Fehlerfall *unbekannte Sprache*
und in den FAQ noch drei. Die Stellen werden **am Muster** gefunden (`grep -n 'kotlin'`, dazu die
Zahlwörter „beide“/„alle drei“), nicht an Zeilennummern — eine Umstrukturierung verschiebt sie
([`BEO-ALL/zeilen-adressen-im-handbuch-wandern-mit-umstrukturierung`](../observations/BEO-ALL/zeilen-adressen-im-handbuch-wandern-mit-umstrukturierung/observation.md)).

**Der Quellstand liegt vor dem ausgelieferten Stand.** `git show v0.9.0:internal/gen/gen.go | grep -c '"java"'`
→ `0`, ebenso `python` und `csharp`: `v0.9.0` kennt keine der drei. Das Handbuch trägt darum an den
Stellen, an denen es die Sprachen aufzählt und am Kopf (`**Software-Stand:**`), **einen** Hinweis,
dass `java`, `python` und `csharp` im Quellbaum liegen und erst das nächste Release sie ausliefert
— sonst bricht ein Nutzer des Downloads an *unbekannte Sprache*, obwohl das Handbuch sie nennt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Versionsnummer** (`**Software-Stand:** v0.9.0` und „aktuell ausgeliefert wird `v0.9.0`“)
  und der Tag-Bezug — der Release-Schnitt trägt sie (Muster:
  `slice-release-schnitt-v070-liefert-kotlin-und-v6180`, dort Liefer-Punkt L2 „Handbuch im
  Ist-Zustand“; [`releasing.md`](../../../user/releasing.md) §Stand-Form). Diesen Slice schneidet
  kein Release, und eine Nummer ohne Tag wäre eine Aussage über etwas, das nicht ausgeliefert ist.
  **Bedingung an den künftigen Release-Schnitt, mangels dessen Plan hier geführt:** er entfernt den
  Quellstand-Hinweis oben, zieht die Nummer und prüft die Sprachaufzählungen gegen den Tag-Baum
  neu. Der Folge-Schnitt hat noch keine Kennung; sie bekommt er mit seinem Anlegen.
- **Jede Aussage im Handbuch über den Quellstand hinaus** (neue Knöpfe, Meldungen, Werkzeuge, die
  nichts mit java/python/csharp zu tun haben) — anderer Vorgang: ein Nachzug über alle Posten gehört
  in den Release-Schnitt, der den Tag-Baum liest; hier nur, was die drei Sprachen und die
  Messung der Bäume berührt.
- **Die `--arch`-Varianten und `add-lang` unter einem Unterpfad im Baum-Sensor** — Bestand bleibt:
  `harness/tools/handbuch-baum.sh` benennt diese Grenze selbst (Wurzel-Variante `--lang`); sie
  bleiben Prosa in §6, und ein Sensor dafür wäre eine zweite Stufe.
- **Die Etiketten hinter den Baum-Namen** — Bestand bleibt: der Sensor prüft die Pfad-Menge, nicht
  den Text; ob ein Etikett stimmt, ist Urteil des Reviewers.
- **`docs/user/benutzerhandbuch-standard.md`, `rollen-laeufe.md`, `releasing.md`,
  `claude-hooks-referenz.md`** — Bestand bleibt: gemessen führen sie keine Sprachliste
  (`grep -c -i 'kotlin\|java\|python\|csharp'` → `0` in allen vier). Das Standard-Dokument ist die
  allgemeine Handbuch-Vorlage ohne Bezug zu diesem Werkzeug. `docs/user/e2e-abdeckung.md` führt die
  Sprachen schon und ist **erzeugt**: Liefer-Punkt 3 zieht sie nach, per `make e2e-abdeckung`, nicht
  von Hand.
- **`README.md`** — Bestand bleibt: die Implementer der Sprach-Slices haben die Sprachliste dort
  gezogen (`grep -c -i 'java'` → `2`).

## 2. Definition of Done

Liefer-Punkte (drei):

- [ ] **L1 — Referenz und Kapitel auf den Ist-Zustand.** Jede Sprachaufzählung und jede Zahl über
  Sprachen in `docs/user/benutzerhandbuch.md` nennt die sechs Sprachen und stimmt mit
  `SupportedLangs()` und `langArchs()` überein: `--lang`-Tabelle, Kapitel *Bauform wählen*
  (hexagonal nur `go`; `hexslice` alle sechs; der Exit-2-Fall für eine Sprache ohne die Bauform),
  `SKEL_JAVA_VERSION`, `SKEL_PYTHON_VERSION`, `SKEL_CSHARP_VERSION` (Image und Form des Tags, gelesen
  aus `ai-harness-init --help`), die Fehlermeldung *unbekannte Sprache* im Wortlaut der echten
  Meldung, FAQ, Toolchain-Voraussetzungen, wo das Handbuch sie für die übrigen Sprachen nennt; dazu
  der Quellstand-Hinweis aus §1.
- [ ] **L2 — die drei Sprachbäume.** Unter „Phase 2“ stehen `java`, `python` und `csharp` mit
  `<!-- baum: <sprache> -->`-Marker, erzeugt aus dem Output eines echten Bootstraps (nicht aus dem
  Gedächtnis), und der Absatz zur geschichteten Bauform nennt den Code-Teil von `hexslice` je Sprache
  (Verzeichnisse und Namensräume, gelesen aus `spec/architecture.md` und dem Renderer).
- [ ] **L3 — der Sensor.** Die Handbuch-Baum-Stufe in `harness/tools/full-smoke.sh` fährt die
  Schleife über `kotlin`, `java`, `python` und `csharp` zusätzlich zu `sprachlos`, `go`, `cpp`;
  `docs/user/e2e-abdeckung.md` ist per `make e2e-abdeckung` neu erzeugt, die Deklaration der Stufe
  nennt die sieben Ziele und ihre Grenze (`--arch`, Etiketten); ein Fall in `test/mutations/` färbt die
  Stufe rot, wenn ein Pfad im Baum einer der vier neuen Sprachen entfällt, und die Stufe wurde mit
  diesem Fall einmal rot gesehen ([`AGENTS.md`](../../../../AGENTS.md) §3.6).

Pflichten, die nicht zählen:

- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8, kein Self-Review.
- [ ] Doku-Update: das Handbuch **ist** die Lieferung; `harness/sensors/full-smoke.md` nachgezogen,
      wo es die drei Ziele der Stufe nennt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang.
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/user/benutzerhandbuch.md` | update | L1, L2 |
| `harness/tools/full-smoke.sh` | update | L3: Schleife und `e2e_abdeckung`-Deklaration der Handbuch-Baum-Stufe |
| `docs/user/e2e-abdeckung.md` | update (erzeugt) | L3: `make e2e-abdeckung`, keine Handarbeit |
| `test/mutations/<nr>-handbuch-baum-<sprache>-….sh` | neu | L3: Rot-Gegenbeispiel, nach den Fällen `614` bis `617` |
| `harness/sensors/full-smoke.md` | update (falls die drei Ziele dort stehen) | Doku-Update |
| `harness/tools/handbuch-baum.sh` | update (nur der Kopf, falls er die Varianten nennt) | die Grenze steht dort |

- Reihenfolge: L2 zuerst (die Bäume sind die Soll-Menge), dann L3 (der Sensor hält sie), dann L1;
  die Proben eines Bootstraps liegen unter `.harness/state/` und sind vor `make gates` gelöscht — das
  Doc-Gate scannt dort. Der Docker-Daemon sieht das Scratchpad nicht.
- Läuft `kotlin` mit dem heutigen Handbuch-Baum rot, ist der Baum falsch und wird gezogen: das ist
  der Befund der Beobachtung, kein Fehler des Sensors.

## 4. Trigger

**Start** (`next` → `in-progress`): kein Start-Trigger außer dem Auftrag; der Zug landet auf
`main` vor der Arbeit ([`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md)).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): L3 wird teurer als eine Schleifen-Erweiterung
  — etwa, wenn `handbuch-baum.sh` für einen der vier Bäume eine neue Form braucht (Verzeichnis-Etiketten,
  Pfade unter `.harness/baseline/`) oder die Stufe die Laufzeit von `full-smoke` über die Grenze
  hebt, die [`MR-089`](../../../../harness/conventions.md#mr-089--eine-laufzeit-aussage-über-einen-emittierten-oder-e2e-lauf-nennt-image-lage-und-variante) benennt. Dann geht L3 als eigener Slice
  `slice-handbuch-baum-sensor-fuer-alle-sprachen` nach `open/`, L1 und L2 schließen allein, und die
  Beobachtung bekommt den Ausgang *geplant* mit dieser Kennung.
- `in-progress` → `open` (blockiert): ein Bootstrap einer der drei Sprachen scheitert im Probelauf
  (Docker, Netz); dann steht der Befund in der Rückführung, nicht in einem Carveout.

## 5. Closure-Trigger

DoD L1 bis L3 abgehakt, `make gates` grün auf HEAD, Reviewer-Report vorhanden, Verifier hat L3 an
einem verfälschten Baum rot gesehen; Closure-Notiz mit Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

- Das Handbuch beschreibt `java`, `python` und `csharp`, der Download `v0.9.0` kennt sie nicht; der
  Hinweis bleibt nach dem Release stehen — **Ausgang:** weiter offen → Register-Eintrag, den die
  Closure anlegt und der die Bedingung an den Release-Schnitt trägt (§1, erster Ausschluss)
- Ein Baum entsteht aus dem Output eines Bootstraps, in dem ein Pfad vom Lauf abhängt (Version im
  Pfad, nicht deterministisch) — **Ausgang:** zu entscheiden bei L2; trifft es zu, nennt die Closure
  den Pfad als Grenze in der Deklaration der Stufe (eingetreten) oder streicht das Risiko mit dem
  Befund (entfallen)
- Der Sensor deckt die `--arch`-Bäume nicht, `hexslice` bleibt Prosa und kann driften —
  **Ausgang:** weiter offen → `BEO-ALL/handbuch-sprachbaum-ohne-sensor-in-full-smoke` (Grenze
  gehört in die Deklaration der Stufe)
- `full-smoke` wird durch vier Bootstraps länger — **Ausgang:** eingetreten → die Rückführung in §4;
  sonst entfallen mit der gemessenen Dauer nach [`MR-089`](../../../../harness/conventions.md#mr-089--eine-laufzeit-aussage-über-einen-emittierten-oder-e2e-lauf-nennt-image-lage-und-variante)

## 7. Closure-Notiz


- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Gegenstand:** <übernommen von `slice-<Kennung>` | entfallen: <Grund>>
  *(nur beim Ausgang ohne Arbeit; sonst Zeile löschen)*
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<KUERZEL>/<slug>` (<slice-kennung-a>, <slice-kennung-b>, <slice-kennung-c> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-<Kennung>.md` | `evidence/slice-<Kennung>.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-<Kennung> (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist allein `*` (gesamtes Repo), die einzige
Sub-Area, die [`harness/conventions.md`](../../../../harness/conventions.md) §Modus-Deklaration für
Dokumente und Werkzeug-Skripte führt (`harness/tools/` trägt `full-smoke.sh`; die Beobachtungen führen
beide unter `*`). Schwelle erfüllt, nicht zu grob.

**Vorgelagert — offene Beobachtungen sichten** (Register gelesen am 2026-10-19):

- [`BEO-ALL/handbuch-sprachbaum-ohne-sensor-in-full-smoke`](../observations/BEO-ALL/handbuch-sprachbaum-ohne-sensor-in-full-smoke/observation.md):
  **2×**, offen (Belege `slice-java-hexslice-layout`, `slice-release-schnitt-v070-liefert-kotlin-und-v6180`).
  Dieser Slice ist der **Lese-Schritt** und zugleich der dritte Beleg: L3 liefert den Sensor, die
  Closure setzt den Ausgang *verkörpert* mit Zielort `harness/tools/full-smoke.sh` — oder, nach der
  Rückführung aus §4, *geplant* mit der Kennung des Folge-Slice.
- [`BEO-ALL/zeilen-adressen-im-handbuch-wandern-mit-umstrukturierung`](../observations/BEO-ALL/zeilen-adressen-im-handbuch-wandern-mit-umstrukturierung/observation.md):
  1×, offen. Dieser Plan adressiert das Handbuch am Muster statt an Zeilen; ob der Lauf eine
  Stelle verfehlt, weil das Muster nicht trägt, ist ein zweiter Beleg, kein Auftrag hier.
- [`BEO-ALL/doku-zusage-nennt-den-test-dessen-fall-nur-einen-ausschnitt-misst`](../observations/BEO-ALL/doku-zusage-nennt-den-test-dessen-fall-nur-einen-ausschnitt-misst/observation.md):
  3×, Stand *geplant*; L3 schreibt eine Zusage („der Baum ist gegen die Emission gehalten“) mit
  einem Sensor daneben — die Deklaration nennt darum, was die Stufe misst und was nicht (§2, L3).
- Übrige Einträge unter `BEO-ALL/` berühren weder Handbuch noch Handbuch-Baum: keine Treffer.

### Sub-Area: `*` (gesamtes Repo)

- **Modus:** GF
- **Konventionen-Dichte:** hoch — `harness/conventions.md` führt die Doku- und Skript-Regeln;
  [`AGENTS.md`](../../../../AGENTS.md) §3.6/§3.7 binden Zusage und Kommentar.
- **Phase-Reife:** Phase 3 — Handbuch und `full-smoke` stehen, die Bäume von `go`, `cpp` und
  `dokument-only` sind gehalten; offen ist der Teil, den dieser Slice liefert.
- **Evidenz-/Diskrepanz-Risiko:** niedrig bis mittel — der Ist-Zustand wird gemessen, nicht
  rekonstruiert; das Risiko ist ein Baum, der gegen die Emission rot läuft (§3, `kotlin`).
- **Reconciliation-Aufwand:** klein; Graduation entfällt (GF). Folge-Schnitt: der Release-Schnitt
  (§1, erster Ausschluss) und, falls L3 zurückgeht, `slice-handbuch-baum-sensor-fuer-alle-sprachen`.
