# Slice slice-release-schnitt-koppelt-pin-und-fassung: Der Release-Schnitt koppelt Träger-Pin und Werkzeug-Fassung

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Nach dem Test aus Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht beobachtet keine Closure-Bedingung mehr als
diese DoD — der geschnittene Release-Stand, der gezogene Pin und die
E2E-Stufe sind Belege der Liefer-Punkte selbst; ein repo-weites Mehr über sie
hinaus existiert nicht.

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(der Pin trägt Version + sha256, fail-closed gekoppelt — dasselbe Muster wie
Baseline-, d-check- und Träger-Pin),
[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)
(die Plattform-Matrix der Release-Assets),
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)
(der gefetchte Träger wird zum fähigen Träger — der Konsumenten-Aufruf läuft,
statt still den Init-Pfad zu starten),
[`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
Festlegung 2 und Folgepflicht 3 (der Release-Schnitt ist der Träger der
Kopplung aus Pin und Werkzeug-Fassung — ohne ihn driftet der Pin bei jedem
Werkzeug-Fortschritt, der ein Unterkommando ändert). Risikoaufkommen:
Risiko 1 aus
[`slice-traeger-per-fetch-aus-dem-release`](../done/slice-traeger-per-fetch-aus-dem-release.md)
§6 (Ausgang *eingetreten*).

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-09-18.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Ein geschnittener Release-Stand, dessen Unterkommando-Dispatch die
Sperren führt (`archive-welle` als geführtes Unterkommando), wird gepinnt und
veröffentlicht; der Träger-Pin (`TRAEGER_TAG` plus die sechs
`TRAEGER_SHA256_*`-Pins, Makefile und Emissions-Default) zeigt im selben
Vorgang auf diesen Stand. Ab diesem Stand bricht ein Fassungs-Bruch beim
Aufruf mit einem Fehler statt still zu starten ([`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 2 in der
geglätteten Fassung): die E2E-Stufe
(`harness/tools/full-smoke.sh`, Stufe `traeger_fetch_im_ziel`, Abschnitt
GRENZE) trägt heute den Messbefund „der v0.1.1-Träger führt das Unterkommando
nicht, der Aufruf startet den Init-Pfad" — ihr Konsumenten-Teil wird mit
diesem Slice an genau dieser Stelle zum gemessenen Gelingens-Fall.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Fetch selbst** — **übernommen:**
  [`slice-traeger-per-fetch-aus-dem-release`](../done/slice-traeger-per-fetch-aus-dem-release.md)
  hat ihn geliefert (Target, Fragment `traeger.mk`, bats- und E2E-Deckung);
  dieser Slice zieht nur den Pin auf den neuen Stand, er baut keinen zweiten
  Fetch-Weg.
- **Kein Signier-Schritt, keine zweite Asset-Prüfung** — **Bestand bleibt
  bewusst stehen:** der Fetch prüft den **Digest**, nicht die Signatur; die
  Doku sagt genau das ([`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 1).
- **Kein Stempel-Mechanismus** — **anderer Vorgang, entschieden:** Festlegung 2
  trägt den Fassungs-Fit prozedural (der Release-Schnitt koppelt Pin und
  Fassung im selben Vorgang); eine Stempel-Fläche am Werkzeug wäre neue
  öffentliche Oberfläche für einen Wert, den ein Re-Lauf nicht überlebt.
- **Keine Änderung an der Emissions-Struktur** — **Schicht-Abgrenzung:** der
  Pin zieht in den bestehenden Variablen nach (`TRAEGER_TAG`,
  `TRAEGER_SHA256_*`); Fragment-Ort, Target-Form und Prerequisite-Freiheit
  (Festlegung 3) bleiben unverändert.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Suchreihenfolge: Was übernimmt ein **Folge-Slice** (mit
Kennung — und die Kennung muss den Punkt auch annehmen)? Was bleibt als
**Bestand** bewusst stehen (mit Begründung)? Was wäre ein **anderer Vorgang**?
Welche **Schicht** rührt der Slice nicht an?

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [x] **Liefer-Punkt 1 — Release-Schnitt:** Ein Release-Stand, dessen
      Unterkommando-Dispatch `archive-welle` führt, ist geschnitten und als
      Release mit den sechs Plattform-Assets und der `SHA256SUMS` als siebtem
      Asset veröffentlicht — die SUMS erzeugt und publiziert die
      Prozedur-Mechanik (publish-Job bzw. Rezept), nicht ein Akt von Hand
      ([`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
      Folgepflicht 1; Matrix nach
      [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix),
      gehalten von `test/release-matrix.bats`). Rote Gegenprobe: fehlt ein
      Asset der Matrix, färbt der Matrix-Test rot; fehlt die `SHA256SUMS` im
      Release, bricht der Ziel-Fetch laut ab (gemessen am Ziel-Fetch: HTTP
      404) — dieselbe Lücke, an der der Tag-CI des `v0.2.1`-Schnitts brach.
      **Beleg:** Release `v0.2.1` mit sieben Assets (`gh release view v0.2.1
      --json assets` → `assets: 7`), die `SHA256SUMS` byte-identisch zum
      `make release-artifacts`-Bau, die drei Zähne in
      `test/release-matrix.bats` — Verifikations-Report
      ([Verifikations-Report](../../../reviews/2026-09-19-slice-release-schnitt-koppelt-pin-und-fassung-verifikation.md))
      §1/§2.
- [x] **Liefer-Punkt 2 — Pin-Nachzug:** `TRAEGER_TAG` und die sechs
      `TRAEGER_SHA256_*`-Pins zeigen im Makefile und im Emissions-Default auf
      den neuen Stand, fail-closed gekoppelt (dieselbe Kopplungs-Klasse wie
      `test/sources-pin.bats`; der Kopplungs-Test ist Fall 1 in
      `test/traeger-fetch.bats`). Rote Gegenprobe: weicht einer der sechs
      Digest-Pins vom realen Asset ab, bricht der Negative-Fall des
      bats-Tests fail-closed — unter der geschwächten Zusicherung (Abweichung
      bricht, aber der Träger bleibt liegen) bleibt der zweite Negative-Fall
      rot. **Beleg:** `grep -nE '^TRAEGER_(TAG|SHA256)' Makefile` → `:45–51`,
      das Fragment trägt nur den Tag (`grep -c 'TRAEGER_SHA256'
      internal/emit/templates/enforce/traeger.mk` → 0), der Kopplungs-Test ist
      Fall 1 in `test/traeger-fetch.bats:116`, und alle sechs SUMS-Zeilen des
      Releases == die Makefile-Pins — Verifikations-Report §1/§2.
- [x] **Liefer-Punkt 3 — der laut-Bruch wird am Ziel messbar:** die E2E-Stufe
      misst am realen Ziel den Gelingens-Fall des Konsumenten-Aufrufs mit dem
      gefetchten Träger und den laut-Bruch an einem Träger, der die Sperren
      nicht führt; die GRENZE-Stelle in `full-smoke.sh` trägt danach den
      gemessenen Zustand, nicht mehr die Grenze des gepinnten Standes.
      Rote Gegenprobe: kehrt die Stufe den laut-Bruch in einen stillen
      Init-Pfad-Start zurück, färbt der Fall rot — gemessen am Aufruf, nicht
      an einem Kommentar. **Beleg:** `make full-smoke` exit 0, Stufe 4 mit den
      fünf Fällen (a)–(e) am realen Ziel; die GRENZE-Stelle trägt den
      gemessenen Zustand (V-1 gezogen, `9eea0cc2`) — Verifikations-Report
      §1/§3.
- [x] `make gates` grün. **Beleg:** der Lauf des Verifikations-Reports
      (Kopf `28337be5`, Nachweis `.harness/state/gates-passed.diffsha`) und
      die Tag-CI; wiederholt grün über dem Closure- und `done/`-Stand (§7).
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
      **Beleg:** drei Runden
      (`2026-09-18-…-runde-{1,2,3}.md`, Commits `918d76dc`, `7c071065`,
      `8b6a5149`); Runde 3: kein blockierender Befund.
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt ist (Pin-Stand in
      der Werkzeuge-Zeile, E2E-Sicht regeneriert). **Beleg:** Werkzeuge-Zeile
      mit Pin-Stand (`harness/README.md:80`), E2E-Sicht erzeugt
      (`make e2e-abdeckung`, Stufe-4-Zeile) — Verifikations-Report §2.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag. — diese Datei §7.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen
      Brownfield-Bootstrap und führt die Register-Datei nicht.
- [x] Beobachtungs-Register (`../observations/`) fortgeschritten — neues
      Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen
      `evidence/`; **kein Zähler wird gesetzt**, er folgt aus den Dateien.
      Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7
      notiert. **Vollzug:** ein Eintrag neu angelegt, zwei Belege ergänzt —
      siehe §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen). — siehe §6, je genau einer.
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im
      Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der
      nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).
      **Ergebnis:** §7, der Paarungs-Lauf läuft nach dem `git mv`.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| Release-Pipeline (Workflow bzw. Release-Vorgang) | update | schneidet den Stand, dessen Dispatch `archive-welle` führt, und veröffentlicht die sechs Assets; ihre publish-Mechanik erzeugt und publiziert die `SHA256SUMS` als siebtes Asset — die SUMS entsteht heute in keinem Artefakt des Schnitts (weder `release-artifacts`-Rezept noch publish-Job von `.github/workflows/release.yml` erzeugt sie, sie wurde von Hand hochgeladen), [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) Folgepflicht 1 verlangt sie als Mechanik |
| `Makefile` (`TRAEGER_TAG`, `TRAEGER_SHA256_*`) | update | der Pin zeigt auf den neuen Stand |
| `Makefile` (Restaurierung) | refactor | die durch den Bootstrap-Unfall beschädigte Fassung ist restauriert (`e34ef1de`, append-only über dem Tag-Grund, kein Force-Push; `git show --shortstat e34ef1de` → 2 Dateien, 489 insertions(+), 24 deletions(-)) — der Plan führte die Datei nur als Pin-Update; diese Zeile beschreibt den Diff-Umfang, den der Diff hat |
| `internal/emit/templates/enforce/traeger.mk` bzw. die Pin-Default-Stelle der Emission | update | dieselben sieben Werte, fail-closed gekoppelt |
| `test/traeger-fetch.bats` | update | Kopplungs- und Negative-Fälle am neuen Stand; Rote Gegenprobe Liefer-Punkt 2 |
| `harness/tools/full-smoke.sh` (Stufe `traeger_fetch_im_ziel`) | update | GRENZE-Stelle wird zum gemessenen Gelingens-Fall; laut-Bruch als Negative (Liefer-Punkt 3) |
| `docs/user/e2e-abdeckung.md` | update | regeneriert via `make e2e-abdeckung` — nicht hand-edited |

**Verfeinert im Lauf (gemessen, nicht geplant):** der erste `make
release-artifacts`-Lauf brach an `internal/span/emit.go:360` — `syscall.Flock`
ist auf Windows undefined, und die Datei trug keinen Build-Tag; zwei der sechs
Assets der Matrix bauten nicht. Die Spaltung der zwei POSIX-Stellen
(`tryLockExclusive`/`removeStaleDir` je OS, `emit.go` plattformfrei) geht dem
Pin-Commit voraus — sie ist Vorbedingung von Liefer-Punkt 1, nicht eine zweite
Schicht: | `internal/span/emit.go` + `internal/span/lock_unix.go` +
`internal/span/lock_windows.go` | update/neu | die zwei POSIX-Syscalls der
Span-Sperre tragen je-OS-Dateien, sonst bauen windows-amd64/arm64 nicht
([`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)) |

**Verfeinert durch die Mechanik der neuen Entscheidung
([`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md),
Proposed —
das Übergabe-Artefakt, das dieser Slice als Constraint liest):** die
Digest-Spiegelung fällt aus der Emission, der Pin im Fragment trägt nur den Tag,
und der Fetch-Helfer verifiziert gegen die `SHA256SUMS` desselben Releases:
| `harness/tools/traeger-fetch.sh` + emittierter Zwilling | update | zwei Modi
aus einer byte-gleichen Fassung — Dogfood verifiziert gegen den Makefile-Pin
(zwei Kanäle), Ziel gegen den Manifest-Eintrag; ein teilweise exportierter
Digest-Pin bricht, statt still in den Manifest-Kanal zu fallen
([`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
Festlegung 1 und 3) |

**Verfeinert durch die SUMS-Mechanik** (Folgepflicht 1 — die Erzeugung und die
Publikations-Prüfung sind Vorgang, nicht Akt von Hand): |
`harness/tools/release-sums.sh` (neu), `Makefile`-Rezept
`release-artifacts`, publish-Job der Release-Workflow | update/neu | das Rezept
schreibt die `SHA256SUMS` ins `DEST` — sie reist mit den Binaries in den Job und
als siebtes Asset heraus; der Job hält die heruntergeladenen Artefakte gegen die
reisende SUMS, fail-closed vor dem Upload (die Prüfung liest nur das
Download-Verzeichnis, der Job checkt bewusst nicht aus); die drei Zähne tragen
`test/release-matrix.bats` |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): priorisiert, Verantwortlicher gesetzt,
WIP-Limit frei; ein Release-Kanal für den neuen Stand ist erreichbar.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Der Pin-Nachzug
  wächst über die sieben Variablen hinaus — Fragment-Struktur, Target-Form
  oder Prerequisite-Verhältnis ([`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 3) geraten inhaltlich
  unter die Hand. Dann Emission als eigenen Posten schneiden.
- `in-progress` → `open` (blockiert — Carveout?): Kein Release-Kanal für den
  neuen Stand erreichbar — der Pin hätte kein Ziel; oder ein Asset der
  Matrix fehlt dauerhaft ([`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)).

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig mit roten Gegenproben der drei Liefer-Punkte belegt, und
`make full-smoke` grün über der gezogenen GRENZE-Stelle: der
Konsumenten-Aufruf läuft mit dem gefetchten Träger, der laut-Bruch ist am
Ziel messbar.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Release-Kanal außerhalb des Repos:** das Schneiden und Veröffentlichen des
  Stands läuft über einen Kanal, den dieser Slice nicht steuert (GitHub
  Release); schlägt er fehl, blockiert der Pin-Nachzug. — **Ausgang:**
  *entfallen* — die Blockade-Lage trat nicht ein: der Schnitt ist vollzogen
  (Release `v0.2.1` mit sieben Assets, die `SHA256SUMS` als siebtes, die
  SUMS-Zeilen == die `TRAEGER_SHA256_*`-Pins des Makefile an allen sechs
  Plattformen, Release-Workflow und CI am Tag grün — Verifikations-Report §1
  unter `docs/reviews/`), und der Pin-Nachzug steht (`TRAEGER_TAG ?= v0.2.1`,
  Makefile `:45–51`).
- **Emission berührt sich selbst:** die sieben Pin-Werte liegen doppelt
  (Makefile und Emissions-Default); driftet eine Seite, bricht die Kopplung
  erst im Ziel. Gegenbeispiel ist der Kopplungs-Test (Fall 1 in
  `test/traeger-fetch.bats`, Klasse `test/sources-pin.bats`). — **Ausgang:**
  *entfallen* — die Doppelführung der sieben Werte besteht nicht mehr:
  [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) Festlegung 1 zog die Digest-Spiegelung aus der Emission, der
  Fragment-Pin trägt nur den Tag (`grep -c 'TRAEGER_SHA256'
  internal/emit/templates/enforce/traeger.mk` → 0), die sechs Digest-Pins
  stehen allein im Makefile. Die Rest-Kopplung (der Tag an beiden Stellen)
  hält der Kopplungs-Test hermetisch im `make test`-Gate (Fall 1 in
  `test/traeger-fetch.bats:116`; die Folgepflicht 2 von [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) nennt nach
  der Nachrunde F-3 die richtige Test-Datei) — Abweichung bricht lokal, nicht
  erst im Ziel.
- **Der Bootstrap-Unfall in diesem Lauf:** ein Träger-Aufruf ohne Argument
  fiel in den Init-Pfad und fuhr einen Bootstrap-Lauf gegen das Repo, in dem
  er steht — konvergente Makefile-Ersetzung, Strays; die beschädigte Fassung
  wurde im Pin-Commit committet und trägt den Release-Tag `v0.2.0`. —
  **Ausgang:** *weiter offen* → die Klasse ins
  [Beobachtungs-Register](../observations/BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad/observation.md)
  (`BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad`, Stand *offen*,
  1×, Beleg `evidence/slice-release-schnitt-koppelt-pin-und-fassung.md`) —
  der Unfall trat im Vorgang ein, und der Schaden ist mit der Restaurierung
  (`e34ef1de`, append-only über dem Tag-Grund, kein Force-Push) im Slice-Diff
  getragen; kein Carveout und kein Folge-Slice, weil kein Schaden über diesen
  Slice hinaus offengeliegen hat. Der laut-Bruch deckt das fehlende Argument
  am Stand `v0.2.1` (der gepinnte Träger führt die Argument-Sperre, die
  E2E-Stufe misst ihn am Ziel, Fall (e) des Verifikations-Reports); die
  Klasse bleibt über die Alt-Stände (`v0.2.0`, `v0.1.1`) erreichbar und steht
  darum weiter offen im Register.
- **Die Übergabe-Kennung „Plan-L2-Wortlaut" aus den Review-Runden löst in
  keinem Artefakt dieses Slices auf** (Runde 1 und 2, je gemessen per
  `grep`) — sie meint den F-2-Befund des
  [Verifikations-Reports](../../../../docs/reviews/2026-09-18-slice-traeger-per-fetch-aus-dem-release-verifikation.md)
  von [`slice-traeger-per-fetch-aus-dem-release`](../done/slice-traeger-per-fetch-aus-dem-release.md)
  (L2-Wortlaut „anschließend" zur Reihenfolge des `archive-welle`-Aufrufs in
  der E2E-Stufe) und ist dort vollzogen. — **Ausgang:** *entfallen* →
  vollzogen in `slice-traeger-per-fetch-aus-dem-release`, Commit `ff21ce71`;
  sie betrifft den Plan dieses Slices nicht.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

- **Was hat funktioniert:** Der Schnitt koppelt Pin und Fassung im selben
  Vorgang: Release `v0.2.1` trägt sieben Assets, die `SHA256SUMS` ist das
  Erzeugnis der Mechanik (`harness/tools/release-sums.sh generate`,
  byte-identisch zum `make release-artifacts`-Bau), und die sechs SUMS-Zeilen
  sind die `TRAEGER_SHA256_*`-Pins des Makefile an allen sechs Plattformen
  (Verifikations-Report §1). Die Selbstreferenz-Wand ist strukturell
  geschlossen: ein Pin im emittierten Fragment trägt keinen Bau-abhängigen
  Wert — der Digest eines Assets hängt am Pin-Wert, den das Asset selbst
  enthielte —; die Auflösung trägt [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) (`Accepted`, Umschlag
  `ca0b5254`, Beleg-Kennung `2026-09-19-adr-0059-accept-nachrunde` nach
  [`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2): der Fragment-Pin trägt nur den Tag, die
  Verifikation läuft über die `SHA256SUMS` desselben Releases. [`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  bleibt in Kraft, ihre Emissions-Hälfte von Festlegung 1 über den
  Index-Zusatz abgelöst.
- **Was ging anders als geplant:** Der Schnitterlauf brach an der
  Plattform-Matrix (`syscall.Flock` ohne Build-Tag — die Span-Spaltung ging
  dem Pin-Commit voraus), die SUMS-Mechanik wuchs zur Vorgangs-Mechanik
  ([`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) Folgepflicht 1), und der Bootstrap-Unfall fiel in den Init-Pfad
  (Risiko 3). Der Schnitt wurde auf der ungeprüften Zwischenstufe geschnitten
  — der Tag `v0.2.1` liegt vor Accept und Closure; die Verifikation meldete
  V-1 (veraltete Pin-Nummer in der GRENZE-Stelle, gezogen `9eea0cc2`) und V-2
  (die fehlende-`SHA256SUMS`-Klasse bricht per Konstruktion, ohne
  hermetischen Zahn — benannte Lücke, keine Pflicht aus dem DoD). Die
  wiederkehrende Finding-Klasse des Reviews („Fail-closed-Grenze der
  Manifest-Form unbenannt", zwei Instanzen — Runde 2 N-4, Runde 3 M-1) ist in
  beiden Hälften geschlossen: das Skript hält Form und Menge in beide
  Richtungen, der Job trägt dieselben drei am Ruheort der SUMS.
- **Steering-Loop-Eintrag:** benannte Spec-Lücke — der Release-Vorgang (Assets
  bauen, Digests messen, `SHA256SUMS` erzeugen und als siebtes Asset
  publizieren, Pin ziehen, Gates am Tag-Baum vor dem Tag-Push, CI am Tag
  abwarten, bevor der Schnitt vollzogen gemeldet wird) liegt in keinem
  Artefakt; seine Adresse ist
  [`slice-releasing-doku-traegt-den-release-vorgang`](../done/slice-releasing-doku-traegt-den-release-vorgang.md)
  (Datei in `open/`). Die geschärfte Regel der Selbstreferenz-Wand steht in
  [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) — die ADR trägt ihre eigene Kennung, kein zweiter Anker.
- **Beobachtungs-Register (`../observations/`):**
  `BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg/` neu angelegt, Beleg
  `evidence/slice-release-schnitt-koppelt-pin-und-fassung.md` — die Klasse
  „ein ge-tagter/gepushter Stand trägt keinen Gates-Beleg" trägt ihre
  Kennung: drei Fundstellen, alle im selben Vorgang, darum ein Beleg (die
  Zählregel misst Wiederholung über Vorgänge, nicht die Zahl der Funde;
  Fundstellen 1 und 2 sind im Beleg-Kontext des Unfall-Belegs benannt, die
  dritte ist der `v0.2.1`-Tag auf der ungeprüften Zwischenstufe);
  `evidence/slice-release-schnitt-koppelt-pin-und-fassung.md` in
  `BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/` ergänzt.
  Lese-Schritt: kein Eintrag erreicht mit diesem Vorgang neu die
  3×-Schwelle — `BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad`
  1×, der neue Eintrag 1×,
  `BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch` trägt
  seinen Ausgang (*geplant*, Kennung
  `slice-ortswechsel-zieht-sein-zustandsfeld-nach`).
- **Folge-Slices:**
  [`slice-releasing-doku-traegt-den-release-vorgang`](../done/slice-releasing-doku-traegt-den-release-vorgang.md)
  (`releasing.md` trägt den Release-Vorgang) — ist eine Datei in `open/`.
- **Risiken aus §6:** Risiko 1 *entfallen* (Schnitt vollzogen) · Risiko 2
  *entfallen* (Doppelführung durch [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) gezogen, Rest-Kopplung
  hermetisch gebunden) · Risiko 3 *weiter offen* → Register · Risiko 4
  *entfallen* (vollzogen in `slice-traeger-per-fetch-aus-dem-release`) —
  siehe §6.
- **Drei Paarungen:** Anker — kein Eintrag in §7 trägt das Feld `liegt in`;
  die geschärfte Regel steht in [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) (Kennung, kein Zielort-Anker), die
  Paarung hat kein Objekt. · Folge-Slice — die genannte Datei existiert im
  Planning-Lifecycle (`open/`). · Register — die in §6 und §7 genannten
  Einträge existieren als Verzeichnisse, jedes trägt mindestens einen Beleg;
  geprüft im Paarungs-Lauf der Closure nach dem `git mv`.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan — sie hängen weder am Modus noch am Slice-Typ. Bedingt
ist allein der Modus-Begründungsblock am Ende; deshalb nennt der Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `*` (gesamtes Repo) — die
Pin-Stellen (Makefile, Emission) und die Doku — und `harness/tools/` — die
E2E-Stufe und der bats-Test. Beide erfüllen die Schwelle ≥ 2 von 3 Achsen
(Inventur-Berührung: ja; mehrere Dateien: ja; Aussagen-Berührung: ja — die
Werkzeuge-Zeile und die E2E-Sicht). Keine der beiden ist zu grob — die
Modus-Deklaration in `harness/conventions.md` führt beide namentlich.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen am
2026-09-18 (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` →
**146**), Verzeichnisse unter `BEO-ALL/`. Treffer für diese Sub-Areas:
`BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand` —
Zählerstand 4×, Stand *geplant* mit Kennung
`slice-werkzeug-aussage-traegt-quelle-stand-und-messstelle`; dieser Posten
zieht den Träger-Pin auf einen Stand, dessen Dispatch am Quellstand gegengelesen
wird — seine Aussagen über den neuen Träger sind am Quellstand zu
gegenlesen, nicht aus der Werkzeug-Doku zu übernehmen. Er ist nicht der
geplante Vorgang des Eintrags. Kein weiterer Eintrag berührt die Sub-Areas
mit dieser Berührung an der Schwelle.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF (`*` und
`harness/tools/` stehen in der Modus-Deklaration als Greenfield); kein
BF/Hybrid-Block.