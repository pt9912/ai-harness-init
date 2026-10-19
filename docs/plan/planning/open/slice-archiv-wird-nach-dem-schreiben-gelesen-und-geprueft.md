# Slice slice-archiv-wird-nach-dem-schreiben-gelesen-und-geprueft: Die Archivierung liest ihr Zip nach dem Schreiben zurück und bricht vor dem Kürzen ab, wenn es defekt ist

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD dieses Slice.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(die Zusage „Archiv gelesen und geprüft" trägt einen Zahn, kein bloßes Vorhandensein),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (derselbe Lauf, dasselbe Ergebnis).
Die Archivierung selbst trägt keine eigene `LH-*`-Anforderung (`grep -in archivier spec/lastenheft.md spec/spezifikation.md` → keine Treffer); ihre Festlegung ist
[`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md).

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-19.

---

## 1. Ziel und Abgrenzung

**Ziel:** `internal/archive/anwenden.go` öffnet das fertig geschriebene `archiv.zip` erneut, liest jeden Eintrag vollständig und hält ihn byte-gleich gegen seine Quelle — und bricht **vor** dem Kürzen der Originale und **vor** dem Stub-Schreiben ab, wenn das Archiv defekt ist; ein E2E-Zahn in `harness/tools/full-smoke.sh` prüft an den drei Stellen, die heute nur `[ ! -f …/archiv.zip ]` halten, die Validität.

**Ausgangslage (gemessen am Stand HEAD 050eb809):** `anwenden.go` (um Z. 323–361) prüft nur die Rückgabewerte von `zw.Close()`/`f.Close()`; das Archiv wird vor dem `git mv` zu Stubs nicht gelesen. `TestAnwendenPacktJedesZeitdokumentInsArchiv` liest jeden Eintrag, aber im Unit-Test und nicht im Werkzeuglauf. `full-smoke.sh` prüft an drei Stellen (um Z. 1824, 1920, 2214) die Existenz; weder `unzip -t`, `zip -T` noch `zipinfo` stehen in `harness/tools` oder `test`. Unter `done/` liegt zurzeit kein `archiv*.zip`. Der Stub zeigt per `unzip -p` ins Archiv; ein stilles Defekt-Zip ließe den Volltext nur noch in git.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Kein neues Archivformat — das Zip bleibt, die Probe liest es nur; das Format ist durch [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) gesetzt.
- Keine Rückwirkung auf Bestand — kein Archiv liegt vor, das nachgeprüft werden könnte; ein Nachprüf-Werkzeug hätte keinen Gegenstand.
- Keine Änderung der Stub-Form — der Stub ist durch Modul 6 Schritt 4 und [`MR-072`](../../../../harness/conventions.md#mr-072--ein-review-report-bekommt-beim-archivieren-einen-stub-entgegen-dem-wortlaut-der-ziel-form) bestimmt; die Probe sitzt davor.
- Wellen-/Slice-Auswahl der Operation bleibt unberührt — andere Frage, eigene Tests.
- `make archive-welle` für wellenlose Slices (es gibt kein `archive-slice`-Ziel) — anderer Vorgang; der Rückleseschritt sitzt in der Operation und gilt für jeden Aufrufer.

**Hinweis für den Architect.** Aus der Lektüre von [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) verlangt der Slice keine Änderung der Festlegung: die ADR nennt das Zip aus der Standardbibliothek (Zeile „Das Zip kommt aus der Standardbibliothek") und trifft keine Aussage zu einer Probe nach dem Schreiben; die Probe ergänzt die Operation, ohne eine Festlegung zu berühren. Ob eine Ergänzung der Abbruch-Reihenfolge (Probe vor Kürzen) eine eigene ADR braucht, entscheidet der Architect — der Slice schreibt keine.

## 2. Definition of Done

- [ ] **L1 — Rückleseprobe in der Operation:** nach dem Schreiben öffnet `internal/archive` das Zip per `zip.OpenReader`, liest jeden Eintrag bis zum Ende (CRC) und vergleicht Pfade und Bytes mit der Quelle; bei Befund bricht die Operation ab, bevor ein Original gekürzt oder ein Stub geschrieben wird (Arbeitsbaum unverändert, soweit der Code es hält — die Zusage nennt, was nach dem Abbruch noch vom Zip auf Platte liegt). Unit-Test mit **abgeschnittenem** und **verfälschtem** Zip (Eintrag manipuliert), rot gesehen mit gepinnter Ursache (die Fehlermeldung nennt Archiv und Eintrag), kein Original gekürzt.
- [ ] **L2 — Zahn im E2E:** `full-smoke.sh` prüft an den drei Stellen Validität statt Existenz (im Werkzeuglauf lesend, ohne Host-Toolchain — Zahn im Docker-Lauf des Ziels bzw. im Träger); ein Fall mit verfälschtem Zip färbt den Lauf rot, `# expect:` pinnt die Ursache. Die Zusage nennt den Aufruf, an dem sie gemessen ist (über `make`: Exit 2, `AGENTS.md` §3.6).
- [ ] **L3 — Mutations-Fall:** `test/mutations/771-archiv-rueckleseprobe-ausgehebelt.sh` (Nummer: höchste belegte ist 770) hebt die Rückleseprobe aus (Probe zum No-Op) und färbt den benannten Wächter aus L1 rot; `make mutate-greift` grün, `MUTATE_CASES=771` einmal rot gesehen.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/archive/anwenden.go` | update | Rückleseprobe nach dem Schreiben, vor Kürzen und Stub-Schreiben — L1 |
| `internal/archive/anwenden_test.go` | update | abgeschnittenes und verfälschtes Zip, gepinnte Ursache, Originale unverändert — L1 |
| `harness/tools/full-smoke.sh` | update | drei Existenz-Prüfungen werden Validitäts-Prüfung; Fall mit verfälschtem Zip, `# expect:` pinnt die Ursache — L2 |
| `test/mutations/771-archiv-rueckleseprobe-ausgehebelt.sh` | neu | Probe zum No-Op, Wächter aus L1 wird rot — L3 |

Ansatz: Der Test-Hook für das Verfälschen liegt in der Operation (injizierbarer Schreib-/Lesepunkt), nicht im Produktverhalten; der E2E-Fall verfälscht das Zip zwischen Schreiben und Prüfung nur dort, wo der Lauf es erlaubt — kann er das nicht, benennt L2 die Lücke am selben Ort statt sie zu verdecken.

## 4. Trigger

**Start** (`next` → `in-progress`): keine Abhängigkeit; Priorisierung durch den Nutzer.

**Rückführungen:**

- `in-progress` → `next`: der E2E-Fall braucht einen Eingriff in die Operation, der mehr als den Rücklesepunkt berührt (dritte Schicht oder mehr als drei Liefer-Punkte).
- `in-progress` → `open`: [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) verlangt für die Probe eine Änderung ihrer Festlegung — dann Architect, bevor der Slice weiterläuft.

## 5. Closure-Trigger

DoD vollständig, `make gates` grün, Review- und Verifier-Report liegen vor, Closure-Notiz mit Lerneintrag in Form einer neuen Rückleseprobe samt Mutations-Fall (neuer Sensor).

## 6. Risiken und offene Punkte

- Die Probe liest dieselbe Datei, die der Schreiber gerade schloss; ein Defekt im Dateisystem zwischen Probe und späterem Lesen bleibt unbemerkt — **Ausgang:** entfallen: Die Zusage ist „lesbar und byte-gleich zum Zeitpunkt vor dem Kürzen", nicht Dauerhaftigkeit; der Satz steht so im Doc-Kommentar.
- Der Fall in `full-smoke.sh` pinnt seine Ursache wie die Nachbarfälle womöglich nur grob — **Ausgang:** weiter offen → `BEO-ALL/full-smoke-fall-expect-pinnt-nicht-die-ursache`.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —
- **Drei Paarungen:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo, Kürzel `ALL`, die einzige deklarierte Sub-Area der Beobachtungen); sie erfüllt die Schwelle.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen (`ls -d docs/plan/planning/observations/BEO-ALL/*/`, gelesen am Stand HEAD 050eb809). Treffer, alle `offen`: `BEO-ALL/full-smoke-fall-expect-pinnt-nicht-die-ursache` (2 Belege — berührt der Slice einen weiteren `full-smoke`-Fall mit `# expect:`, wird er zum dritten Beleg und ist dann eine Lücke; der Slice pinnt die Ursache in L2 selbst), `BEO-ALL/archiv-vorschau-rechnet-im-produkt-aus-dateien-und-bewegten-namen` (1 Beleg) und `BEO-ALL/archiv-grenze-ueber-merge-historie-ungemessen` (1 Beleg) — beide betreffen dieselbe Operation `internal/archive`, nicht die Rückleseprobe. `handbuch-sprachbaum-ohne-sensor-in-full-smoke` (3 Belege, verkörpert) ist kein Treffer.

alle berührten Sub-Areas GF
