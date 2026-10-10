# Slice slice-a-check-pin-bringt-den-go-sicherheitsfix: a-check v0.23.2 mit dem Go-1.27.2-Image

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD dieses Slice; Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht.

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren),
[`ADR-0009`](../../adr/0009-hexslice-arch-realisierung.md),
[`MR-063`](../../../../harness/conventions.md#mr-063) (Gegenmessung),
[`MR-084`](../../../../harness/conventions.md#mr-084) (Muster des Pin-Eintrags). Freigabe des
Auftraggebers 2026-10-10 („ja").

**Berührte Spec-Stellen:** `—` — der Pin ist eine Code-Konstante.

**Verantwortlich:** pt9912 (Implementer)

**Autor:** Planner. **Datum:** 2026-10-10.

---

## 1. Ziel und Abgrenzung

**Ziel:** a-check `v0.23.2` steht als emittierter Default (`internal/emit/archgate.go`,
`DefaultArchImage`/`DefaultArchDigest`) auf dem Index-Digest. Anlass ist der Sicherheitsgrund:
der Auftraggeber hat die Go-CVEs der Standardbibliothek bei a-check gemeldet; `v0.23.2` baut mit
Go 1.27.2.

**Lage**, gemessen am lokalen Klon `$A` von a-check (nur gelesen; keine Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025) Setzung 2):

```sh
git -C "$A" show v0.23.2:Makefile | grep -n '^GO_VERSION'          # 1.27.2
git -C "$A" diff --stat v0.23.0 v0.23.2 -- internal cmd Dockerfile go.mod Makefile
#   nur Dockerfile und Makefile — kein Produkt-Code
```

**Pin-Stellen, gemessen über diesem Arbeitsbaum:**

```sh
git grep -nE 'a-check:v0\.2|97cb6d4' -- ':!docs' ':!.harness/baseline'
#   internal/emit/archgate.go — DefaultArchImage, DefaultArchDigest, Kopfkommentar (Tag)
```

Der **Dogfood** pinnt a-check nicht: er ist flach und fährt kein Arch-Gate
([`harness/README.md`](../../../../harness/README.md) §Safety and scope boundaries). Das
emittierte **Fragment** `a-check.mk` hat keine statische Kopie: es entsteht beim Bootstrap aus
`a-check --print-mk` und wird auf die erzeugende Referenz umgepinnt (`adaptArchMK`, Wächter
`TestAdaptArchMK_PinsProducingRef`, Fall `test/mutations/66-archgate-pin.sh`). Eine einzige
Stelle also; **kein** Wächter koppelt Tag und Digest
(`TestArchImagePin_CouplesToDirectionPorts` hält Tag ≥ `v0.20.0` und die Digest-Form).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Ein Schwachstellen-Scan für gepinnte Bilder.** *Anderer Vorgang:* das ist der Gegenstand von
  `BEO-ALL/gepinntes-bild-ohne-schwachstellen-scan`; dieser Slice hebt einen Pin aus
  gemeldetem Anlass, er baut keinen Sensor. Den Ausgang des Eintrags trägt §6.
- **Der Kommentar in `internal/emit/emit_test.go` über die Ausgabe von a-check `v0.23.0`.**
  *Bestand bleibt:* er nennt die Fassung, an der die Kennungs-Zeilen gemessen sind, nicht den Pin;
  zudem berührt der parallele Sprung-Slice `internal/emit/*_test.go` (§4).
- **Ein Wächter, der Tag und Digest koppelt.** *Anderer Vorgang:* `BEO-ALL/pin-digest-ohne-waechter`
  steht auf `geplant`; dieser Slice liefert einen Beleg, keinen Sensor.
- **Der MR-Eintrag zum Pin.** *Anderer Vorgang:* Architect-Artefakt
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8); dieser Slice liefert das Mess-Material (§2 Doku-Update).
- **Kein Produkt-Verhalten.** *Schicht-Abgrenzung:* geändert werden eine Konstante und ihr
  Kopfkommentar, sonst nichts unter `internal/` und `cmd/`.

## 2. Definition of Done

- [x] **1 — a-check `v0.23.2`:** `DefaultArchImage`/`DefaultArchDigest` in
      `internal/emit/archgate.go` auf den Index-Digest, samt Tag im Kopfkommentar
      (`docker buildx imagetools inspect ghcr.io/pt9912/a-check:v0.23.2`, Kommando im Commit).
      **Rot gesehen am echten Pin** ([`AGENTS.md`](../../../../AGENTS.md) §3.6): `DefaultArchDigest`
      einmal verfälscht — `make full-smoke` scheitert mit einer Meldung über genau diese Referenz
      (Meldung gelesen). Dass ein Tag, der nicht zum Digest passt, durchgeht, nennt der Commit als
      Lücke (`BEO-ALL/pin-digest-ohne-waechter`).
- [x] **2 — Gegenmessung des Arch-Gates im Ziel** nach
      [`MR-063`](../../../../harness/conventions.md#mr-063): je gebootstrapptem Ziel `hexslice`-go,
      -cpp und -kotlin `make a-check` am alten und am neuen Digest; grünes Skelett mit leerem
      `diff` der Ausgaben alt gegen neu, und ein verbotener Import färbt das Gate an beiden
      Digests rot mit `core-impurity` (Meldung gelesen). Kommandos und Befund-Zahlen im
      Umsetzungs-Commit.
- [x] **3 — Sicherheitsgrund gemessen:** die Go-Fassung des a-check-Binärs ist ≥ 1.27.2, gemessen
      am Image selbst für `linux/amd64` und `linux/arm64` (Docker-only, Kommando im
      Umsetzungs-Commit), nicht am Makefile von a-check.
- [x] `make gates` grün; `make full-smoke` EXIT 0 (emittierter Pin im Ziel).
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: Übergabe an den Architect liegt als eigener Commit vor — MR-Eintrag zum
      a-check-Pin `v0.23.2` nach dem Muster von [`MR-084`](../../../../harness/conventions.md#mr-084),
      mit der Gegenmessung aus Liefer-Punkt 2 und der Go-Fassung aus Liefer-Punkt 3 (Übergabe
      unten).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind nach dem Move geprüft, §7.

**Übergabe an den Architect** (Eingang für den MR-Eintrag): Quellen sind dieser Plan,
[`MR-084`](../../../../harness/conventions.md#mr-084) als Muster und
[`MR-063`](../../../../harness/conventions.md#mr-063) für die Bilanz; Mess-Material sind die
Kommandos und Zahlen aus dem Umsetzungs-Commit (Index-Digest, Gegenmessung je Sprache, Go-Fassung
je Plattform). Geltungsbereich `internal/emit/archgate.go`; setzt
[`MR-084`](../../../../harness/conventions.md#mr-084) für den a-check-Teil fort. Der Eintrag nennt
keine Adresse in den vendored Baum (§4, Überschneidung).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/archgate.go` | update | `DefaultArchImage`/`DefaultArchDigest` und Tag im Kopfkommentar (Liefer-Punkt 1, [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) |
| `internal/emit/archgate_test.go`, `internal/gen/archgate_test.go` | unverändert | lesen die Konstanten, nennen keinen Tag |
| `harness/tools/full-smoke.sh` | unverändert, gefahren | Beleg im Ziel ([`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)) |

## 4. Trigger

**Start** (`next` → `in-progress`): Freigabe des Auftraggebers vom 2026-10-10 liegt vor; ein
Implementer-Lauf hat einen freien WIP-Slot. Den Übergang setzt der Orchestrator.

**Überschneidung mit `slice-sprung-auf-v6180-wird-vollzogen`** (in `in-progress/`), gemessen an
dessen §3: die Datei-Mengen sind disjunkt. Dieser Slice ändert allein `internal/emit/archgate.go`;
der Sprung ändert unter `internal/emit/` `baumaussage.go`, `templates.go`, `werkzeugindex.go`,
`templates/d-check.yml` und `*_test.go`, dazu `harness/tools/full-smoke.sh`, die er hier nur
fährt. Der Lauf ist darum **parallel** zulässig, unter zwei Bedingungen:

1. Dieser Plan und der MR-Eintrag führen keine Adresse in `.harness/baseline/<tag>/` — sonst
   hinterließe ein Push vor dem Sprung eine Adresse, die dessen Liefer-Punkt 1 nachziehen müsste.
2. Gegenmessung und `make full-smoke` laufen in einem eigenen Klon, nicht über einem Baum, den der
   Sprung-Lauf gerade schreibt. Der Index `harness/conventions.md` bekommt aus beiden Läufen
   Zeilen; der Architect zieht vor seinem Commit `main` nach.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: die Gegenmessung zeigt in einem der drei Ziele eine abweichende Ausgabe
  zwischen altem und neuem Digest — dann hat sich das Prüfverhalten geändert, und die Änderung
  braucht ihre Entscheidung ([`AGENTS.md`](../../../../AGENTS.md) §3.5) vor dem Pin.
- `in-progress` → `open`: der Index trägt `linux/amd64` oder `linux/arm64` nicht, der Digest löst
  im gepinnten Docker-Lauf nicht auf, oder die gemessene Go-Fassung liegt unter 1.27.2 —
  Übergabe an den Auftraggeber als Anforderung an a-check.

## 5. Closure-Trigger

1. `make gates` grün und `make full-smoke` EXIT 0 mit a-check `v0.23.2`.
2. Gegenmessung und Go-Fassung im Umsetzungs-Commit, MR-Eintrag als eigener Architect-Commit.

**Lerneintrag** in einer der drei Formen, §7; die Closure schreibt der Planner
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

- **Schwellen-Übertritt `gepinntes-bild-ohne-schwachstellen-scan`** — der Eintrag steht bei 2
  Belegen, `offen`; auch dieser Pin-Sprung kommt aus einer Meldung, nicht aus einem Sensor. Trägt
  die Closure den Beleg dieses Slice ein, steht er bei 3×, und die Closure ist Lese-Schritt
  ([`ADR-0085`](../../adr/0085-slice-closure-mit-schwellen-uebertritt-ist-lese-schritt.md)): Ausgang
  *verkörpert* oder *geplant* mit Kennung, wofür ein Folge-Slice die Freigabe des Auftraggebers
  braucht. — **Ausgang:** eingetreten: `slice-gepinnte-bilder-bekommen-einen-schwachstellen-scan`
  (`open/`, Freigabe des Auftraggebers 2026-10-10).
- **Digest ohne Wächter** — kein Sensor hält den Digest gegen den Tag;
  `BEO-ALL/pin-digest-ohne-waechter` steht bei 5 Belegen, `geplant`. — **Ausgang:** weiter offen:
  `BEO-ALL/pin-digest-ohne-waechter` (6. Beleg angelegt, Stand `geplant`).
- **Fremdes Image ohne Go-Werkzeug** — liegt im a-check-Image kein Werkzeug, das die Go-Fassung
  ausgibt, muss Liefer-Punkt 3 das Binär aus dem Image holen und in einem gepinnten Go-Image lesen;
  ein Host-`go` ist ausgeschlossen ([`AGENTS.md`](../../../../AGENTS.md) §3.9). — **Ausgang:**
  entfallen: die Go-Fassung ist am Binär in einem gepinnten Go-Image gemessen
  ([`MR-093`](../../../../harness/conventions.md#mr-093)); kein Host-`go`.

## 7. Closure-Notiz

Geschrieben vom Planner in eigenem Kontext bei der Closure ([`AGENTS.md`](../../../../AGENTS.md)
§3.10). **Rolle:** Planner · **Datum:** 2026-10-10

- **Was hat funktioniert:** Alle Liefer-Punkte bestätigt
  ([Verifikation](../../../reviews/2026-10-10-slice-a-check-pin-bringt-den-go-sicherheitsfix-verify.md),
  `6493e771`, 0 Findings): Pin `v0.23.2` als Index-Digest an der einen Stelle, am echten Pin rot
  gesehen (verfälschter Digest, `full-smoke` nennt genau diese Referenz), Gegenmessung go mit
  `core-impurity` an beiden Digests, `make full-smoke` EXIT 0. Review
  ([Report](../../../reviews/2026-10-10-slice-a-check-pin-bringt-den-go-sicherheitsfix.md),
  `a0120715`): 0 HIGH, 0 MEDIUM, LOW-1 behoben in `278d9eca`. Mutation: 5 Fälle lokal `ok`, ein
  Teillauf ohne Beleg; sie prüfen Verdrahtung und Adaption, nicht den Pin-Wert.
- **Architect-Übergabe:** [`MR-093`](../../../../harness/conventions.md#mr-093) (`d3868345`,
  `278d9eca`) erfüllt sie.
- **Was ging anders als geplant:** Nichts am Schnitt. **Grenze von Liefer-Punkt 3:** die Go-Fassung
  für `linux/arm64` und für den alten Digest steht nur nach Commit-Message und
  [`MR-093`](../../../../harness/conventions.md#mr-093), das Messbild `golang:1.27.2` ist per Tag
  gewählt; die Verifikation hat amd64 über das Review, nicht selbst, wiederholt. Gegenmessung cpp und
  kotlin ebenso nur nach Commit-Message.
- **Steering-Loop-Eintrag:** Benannte Lücke, kein neuer Sensor: ein Tag-Digest-Paar ohne Wächter
  (`BEO-ALL/pin-digest-ohne-waechter`, 6×, `geplant`) und ein Pin ohne Bewertung der Schwachstellen
  (`BEO-ALL/gepinntes-bild-ohne-schwachstellen-scan`, 3×) blieben auch bei einem dritten Pin-Sprung
  ohne Sensor; der Lese-Schritt dieser Closure gibt dem zweiten seinen Ausgang
  (`slice-gepinnte-bilder-bekommen-einen-schwachstellen-scan`), gezählt, nicht verkörpert.
- **Beobachtungs-Register (`../observations/`):** je ein Beleg dieses Slice:
  - [`BEO-ALL/gepinntes-bild-ohne-schwachstellen-scan`](../observations/BEO-ALL/gepinntes-bild-ohne-schwachstellen-scan/observation.md)
    → 3×, Ausgang *geplant* auf `slice-gepinnte-bilder-bekommen-einen-schwachstellen-scan`
    ([`ADR-0085`](../../adr/0085-slice-closure-mit-schwellen-uebertritt-ist-lese-schritt.md)).
  - [`BEO-ALL/pin-digest-ohne-waechter`](../observations/BEO-ALL/pin-digest-ohne-waechter/observation.md)
    → 6×, Stand `geplant`, unverändert.
  - Weitere in §8 genannte Einträge: kein Beleg aus diesem Slice (Review und Verifikation ohne
    passenden Fund); gezählt wird nicht.
- **Folge-Slices:** `slice-gepinnte-bilder-bekommen-einen-schwachstellen-scan` — ist eine Datei in
  `open/`. Der Wächter Tag↔Digest bleibt bei
  `slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor`, nicht neu angelegt.
- **Trigger-Audit:** Carveouts: keiner berührt. Bootstrap-aware Gates: keines. ADR/MR: kein
  Re-Evaluierungs-Trigger von [`ADR-0009`](../../adr/0009-hexslice-arch-realisierung.md) oder
  [`ADR-0088`](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) durch die
  Pin-Fassung gefeuert (Prüfverhalten unverändert, Gegenmessung). Hard Rules: keine mit
  eingetretenem Auflösungs-Trigger.
- **Archivierung:** entfällt ([`MR-078`](../../../../harness/conventions.md#mr-078); `archive-slice`
  ist nicht gebaut).
- **Risiken aus §6:** jede Zeile in §6 hat ihren Ausgang.
- **Drei Paarungen:** nach dem Move.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist allein `*` (gesamtes Repo, `ALL`); der
emittierte Arch-Gate-Pin bildet keine eigene Sub-Area der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md).

**Vorgelagert — offene Beobachtungen sichten:** Register `BEO-ALL/` gemergter Stand, Treffer zum
Gegenstand (Zahl der Dateien unter `evidence/`, `ls … | wc -l`):
`gepinntes-bild-ohne-schwachstellen-scan` 2, offen (erreicht mit diesem Slice 3×, §6) ·
`pin-digest-ohne-waechter` 5, geplant ·
`strenge-bilanz-eines-pin-sprungs-fehlt-im-umsetzungs-commit` 1, offen (Liefer-Punkt 2 legt die
Bilanz in den Umsetzungs-Commit) · `pin-sprung-feuert-adr-trigger-ohne-nennung` 1, offen (der
Implementer prüft, ob der Sprung einen Re-Evaluierungs-Trigger von
[`ADR-0009`](../../adr/0009-hexslice-arch-realisierung.md) oder
[`ADR-0088`](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) feuert) ·
`aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand` 6, geplant (die Lage in §1 ist
am Klon von a-check gemessen).

**Modus-Begründungsblock:** alle berührten Sub-Areas GF.
