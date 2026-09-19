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

- [ ] **Liefer-Punkt 1 — Release-Schnitt:** Ein Release-Stand, dessen
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
- [ ] **Liefer-Punkt 2 — Pin-Nachzug:** `TRAEGER_TAG` und die sechs
      `TRAEGER_SHA256_*`-Pins zeigen im Makefile und im Emissions-Default auf
      den neuen Stand, fail-closed gekoppelt (dieselbe Kopplungs-Klasse wie
      `test/sources-pin.bats`; der Kopplungs-Test ist Fall 1 in
      `test/traeger-fetch.bats`). Rote Gegenprobe: weicht einer der sechs
      Digest-Pins vom realen Asset ab, bricht der Negative-Fall des
      bats-Tests fail-closed — unter der geschwächten Zusicherung (Abweichung
      bricht, aber der Träger bleibt liegen) bleibt der zweite Negative-Fall
      rot.
- [ ] **Liefer-Punkt 3 — der laut-Bruch wird am Ziel messbar:** die E2E-Stufe
      misst am realen Ziel den Gelingens-Fall des Konsumenten-Aufrufs mit dem
      gefetchten Träger und den laut-Bruch an einem Träger, der die Sperren
      nicht führt; die GRENZE-Stelle in `full-smoke.sh` trägt danach den
      gemessenen Zustand, nicht mehr die Grenze des gepinnten Standes.
      Rote Gegenprobe: kehrt die Stufe den laut-Bruch in einen stillen
      Init-Pfad-Start zurück, färbt der Fall rot — gemessen am Aufruf, nicht
      an einem Kommentar.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist (Pin-Stand in
      der Werkzeuge-Zeile, E2E-Sicht regeneriert).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen
      Brownfield-Bootstrap und führt die Register-Datei nicht.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschritten — neues
      Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen
      `evidence/`; **kein Zähler wird gesetzt**, er folgt aus den Dateien.
      Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7
      notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im
      Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der
      nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

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
  Release); schlägt er fehl, blockiert der Pin-Nachzug. — **Ausgang:** *offen*
- **Emission berührt sich selbst:** die sieben Pin-Werte liegen doppelt
  (Makefile und Emissions-Default); driftet eine Seite, bricht die Kopplung
  erst im Ziel. Gegenbeispiel ist der Kopplungs-Test (Fall 1 in
  `test/traeger-fetch.bats`, Klasse `test/sources-pin.bats`). — **Ausgang:**
  *offen*
- **Der Bootstrap-Unfall in diesem Lauf:** ein Träger-Aufruf ohne Argument
  fiel in den Init-Pfad und fuhr einen Bootstrap-Lauf gegen das Repo, in dem
  er steht — konvergente Makefile-Ersetzung, Strays; die beschädigte Fassung
  wurde im Pin-Commit committet und trägt den Release-Tag `v0.2.0`. —
  **Ausgang:** *eingetreten* → die Restaurierung (`e34ef1de`, append-only über
  dem Tag-Grund, kein Force-Push) trägt den Schaden; die
  [Register-Beobachtung](../observations/BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad/observation.md)
  `BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad` trägt die Klasse
  (Stand *offen*, 1×)

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

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu
  angelegt, Beleg `evidence/slice-release-schnitt-koppelt-pin-und-fassung.md` |
  `evidence/slice-release-schnitt-koppelt-pin-und-fassung.md` in `BEO-<KUERZEL>/<slug>/`
  ergänzt — Zähler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-<Kennung> (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

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