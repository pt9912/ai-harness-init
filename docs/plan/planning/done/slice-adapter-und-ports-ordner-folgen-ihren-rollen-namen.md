# Slice slice-adapter-und-ports-ordner-folgen-ihren-rollen-namen: Adapter- und Ports-Ordner folgen ihren Rollen-Namen

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
diese DoD — die drei Achsen sind Belege der Liefer-Punkte selbst; ein
repo-weites Mehr über sie hinaus existiert nicht.

**Bezug:**
[`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)
(die Arch-Gate-Config wandert mit — der Glob und die Rollen-Zuordnungen sind
der Punkt, an dem der Fix in die geprüfte Schicht wirkt),
[`ADR-0060`](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)
(Proposed — seine Festlegung 2 schärft
[`ADR-0009`](../../adr/0009-hexslice-arch-realisierung.md) Festlegung 2 in
zwei Gegenständen: die Adapter-Ordner-Namen folgen
`driving`/`driven`, die Ports werden gegliedert);
Setzung des Auftraggebers vom 2026-09-19: drei Achsen, beide Renderer in
einem Vorgang; mit [`ADR-0060`](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)
ist der Ziel-Layout-Schnitt entschieden — hexslice ist der Gegenstand —
Prio 1 nach dem Zielordner-Slice.

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-09-19.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Das hexslice-Skelett beider Renderer richtet sich auf seine eigenen
Rollen-Namen — drei Achsen in einem Vorgang; hexslice ist der Gegenstand, weil
[`ADR-0060`](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)
die Struktur dort entscheidet:

1. **Adapter-Ordner:** `inbound`/`outbound` → `driving`/`driven` — Go
   (`internal/gen/golang.go`: die Skelett-Pfade `:83-85`, die
   Composition-Root-Imports `:450-452`, die Gate-Config
   `internal/adapters/**` `:539-540` und der Kopf `:47`) und C++
   (`internal/gen/cpp.go`: die Skelett-Pfade `:75-77` samt Namespaces in den
   drei Quelldateien `:299`/`:309`/`:332`/`:339` und der Kopf `:38`). Die
   Rollen-Namen existieren bereits
   (`grep -n 'hexagonal-driving\|hexagonal-driven' internal/gen/arch.go` →
   Zeilen 50 und 54) — der Fix richtet das Skeleton auf seine eigenen
   Rollen-Namen, statt einen zweiten Namensraum daneben zu legen.
2. **Ports-Gliederung:** die flachen `ports`-Ordner bekommen
   `ports/{inbound,outbound}/` nach der Rollen-Zuordnung —
   [`ADR-0060`](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)
   Festlegung 2 trägt sie (die `direction:`-Dimension des Arch-Gates bleibt
   leer als Entscheidung; die Ordner-Gliederung kommt in den Baum).
3. **Die Arch-Gate-Config wandert mit** — der Glob und die Rollen-Zuordnungen
   — mit Rot-Beleg gegen den Gate-Test: das ist der Punkt, an dem der Fix in
   die geprüfte Schicht wirkt.

Die Tests tragen die `inbound`/`outbound`-Erwartungen —
`internal/gen/hexslice_test.go:36-38`, `internal/gen/cpp_test.go:182-184` und
`:240-242`, `internal/gen/archgate_test.go:91-93` (die Runde-1-Messung nannte
sie als die Erwartungen, die der Plan „unberührt" ließ und die der Diff
berühren muss); dazu die hexslice-Stufen im Voll-E2E,
`harness/tools/full-smoke.sh` (Zeilen 2261/2338/2376/2461), die die Skeleton-Pfade
fahren.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Keine Release-Berührung** — **anderer Vorgang:** der Renderer-Output
  ändert sich für künftige Bootstraps; das published Release `v0.2.1` bleibt,
  wie es geschnitten ist. Ein Re-Publish würde die Tag-Kopplung
  ([`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  Festlegung 2) für denselben Stand zweimal vollziehen.
- **Kein zweiter Fetch-Weg** — **Bestand bleibt bewusst stehen:** der Fetch
  ([`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  Festlegung 1, [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
  Festlegung 3) bleibt, wo er steht; der Renderer-Fix rührt den Skeleton-Output,
  nicht den Träger-Weg.
- **Keine a-check-Regel-Änderung** — **Bestand bleibt bewusst stehen:** die
  Rollen existieren, die Kanten-Menge bleibt
  ([`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)/[`ADR-0060`](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)
  tragen die Mechanik); der Fix richtet die Ordner und ihre Config auf
  dieselben Namen.
- **Die Ports-Achse ist normativ entschieden** — [`ADR-0060`](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)
  Festlegung 2 trägt sie (die `direction:`-Dimension bleibt leer); kein
  zweiter Vorgang für die Ordner-Gliederung.

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

- [x] **Liefer-Punkt 1 — Adapter-Ordner:** das hexslice-Skelett beider
      Renderer legt seine Adapter unter `driving`/`driven` an — Go
      (`internal/gen/golang.go`: Skelett-Pfaden `:83-85`,
      Composition-Root-Imports `:450-452`, Kopf `:47`) und C++
      (`internal/gen/cpp.go`: Skelett-Pfaden `:75-77`, Namespaces in den
      drei Quelldateien `:299`/`:309`/`:332`/`:339`, Kopf `:38`); die
      Rollen-Namen kommen aus `internal/gen/arch.go`
      (`hexagonal-driving`/`hexagonal-driven`), es entsteht kein zweiter
      Namensraum. Rote Gegenprobe: legt das Skeleton `inbound` an, färbt der
      Renderer-Test (`internal/gen/hexslice_test.go:36-38`,
      `internal/gen/cpp_test.go:182-184`/`:240-242`) rot.
- [x] **Liefer-Punkt 2 — Ports-Gliederung:** die flachen `ports`-Ordner
      bekommen `ports/{inbound,outbound}/` nach der Rollen-Zuordnung, die
      [`ADR-0060`](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)
      Festlegung 2 trägt — der Repository-Port outbound, der CLI-Adapter-Port
      inbound. Rote Gegenprobe: ein Port ohne inbound/outbound-Zuordnung
      färbt den Renderer-Test rot — die Zuordnung ist an der Stelle geprüft,
      an der die Ordner entstehen, nicht in einem Kommentar.
- [x] **Liefer-Punkt 3 — Arch-Gate-Config wandert mit:** der Glob und die
      Rollen-Zuordnungen tragen die neuen Ordner, und der Rot-Beleg steht
      gegen den Gate-Test (`internal/gen/archgate_test.go:91-93`) — der
      Punkt, an dem der Fix in die geprüfte Schicht wirkt. Rote Gegenprobe:
      hält die Config am alten Glob (`internal/adapters/**`), färbt der
      archgate-Test rot — das Skelett ist nicht mehr dort, wo der Gate
      prüft.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt ist (das
      Skelett-Layout im Handbuch bzw. der Nutzer-Doku, falls er es nennt).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen
      Brownfield-Bootstrap und führt die Register-Datei nicht.
- [x] Beobachtungs-Register (`../observations/`) fortgeschritten — neues
      Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen
      `evidence/`; **kein Zähler wird gesetzt**, er folgt aus den Dateien.
      Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7
      notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
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
| `internal/gen/golang.go` | update | Achse 1 (Skelett-Pfaden `:83-85`, Composition-Root-Imports `:450-452`, Gate-Config `internal/adapters/**` `:539-540`, Kopf `:47`) und Achse 2 (Ports-Gliederung) |
| `internal/gen/cpp.go` | update | dieselben zwei Achsen — Skelett-Pfaden `:75-77`, Namespaces `:299`/`:309`/`:332`/`:339`, Kopf `:38`, Ports-Gliederung |
| `internal/gen/hexslice_test.go` | update | die `inbound`/`outbound`-Erwartungen `:36-38` folgen auf `driving`/`driven` samt Ports-Gliederung |
| `internal/gen/cpp_test.go` | update | dieselben Erwartungen `:182-184`/`:240-242` am C++-Renderer |
| `internal/gen/archgate_test.go` | update | der Glob und die Rollen-Zuordnungen `:91-93` — Rot-Beleg gegen den Gate-Test (Achse 3) |
| `harness/tools/full-smoke.sh` | update | die hexslice-Stufen `:2261`/`:2338`/`:2376`/`:2461` fahren die Skeleton-Pfade — sie ziehen mit |
| `docs/user/e2e-abdeckung.md` | update | regeneriert via `make e2e-abdeckung`, wenn eine Stufen-Deklaration sich ändert — nicht hand-edited |

**Ansatz als Liste, wo eine Zeile pro Datei nicht trägt:**

- Die Rollen-Namen sind die Quelle, nicht die Kopie: `internal/gen/arch.go`
  führt `hexagonal-driving`/`hexagonal-driven` bereits; die Ordner-Namen und
  die Arch-Gate-Zuordnung lesen dieselben Konstanten, statt eigene Strings
  daneben zu legen.
- Die Ports-Gliederung zieht die Zuordnung aus den Code-Kommentaren in den
  Baum — der Kommentar („erfüllt den Area-Port durch VERERBUNG") bleibt als
  Kopplungs-Aussage stehen und wird mit der Struktur konsistent geprüft.
- **Verfeinerung 1 (Gemessen am Ist, 2026-09-19):** die zwei Ports des
  Skeletts sind nach der Rollen-Zuordnung **beide outbound** (der
  Repository-Port und der Notifier-Port werden je von einem driven Adapter
  erfüllt — Interface-Erfüllung statt Import) und rücken unter
  `ports/outbound/`. Ein adapter-konsumierter inbound-Port — die Form der
  Referenz — verlangt einen `adapters→ports`-Import: genau die Kante, deren
  **Fehlen** [ADR-0060](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)
  Festlegung 4 verbatim bindet (und ein Port-Interface über die Slice-eigenen
  Command/Result-Typen verlangte `ports→app`). Die Gliederung materialisiert
  sich darum für die Ports, die das Skelett trägt; die inbound-Hälfte der
  Ordner-Form bleibt Struktur. Übergabe an Review/Planner: der Plan-Text
  „der CLI-Adapter-Port inbound" benennt einen Port, den das Skelett vor und
  nach dem Fix nicht trägt — die Kanten-Bindung entscheidet das, nicht dieser
  Lauf.
- **Verfeinerung 2 (Gemessen am Ist, 2026-09-19):** die Gate-Config teilt die
  Adapter-Schicht in `driving`/`driven` (Schichtnamen mit `role: adapter`, je
  explizitem Glob — die Namens-Form des hexagonal-Configs dieses Renderers).
  Die **fünf erlaubten Kanten-Richtungen** aus
  [`ADR-0009`](../../adr/0009-hexslice-arch-realisierung.md) Festlegung 2
  binden unverändert fort — sie stehen unter den neuen Schicht-Namen:
  `driving→app`, `driven→domain` (Go), dazu C++-spezifisch `driven→ports`
  (die Vererbungs-Erfüllung). Keine `driven→ports`-Kante in Go, keine
  `driving→ports`-Kante in beiden; jede deklarierte Kante wird von einem
  realen Import benutzt (Gate-Test-Eigenschaft (b)). Die Rot-Gegenprobe des
  Plans (Config hält den breiten Glob `internal/adapters/**`) färbt dann am
  Gate-Test rot: die Schicht-Namen in der Erwartung sind die neuen.
- **Verfeinerung 3 (Gemessen an der Referenz, 2026-09-19):** die
  Referenz-Anpassung des Auftraggebers trägt die Arch-Gate-Form an a-check
  v0.20.0 — die Port-Schichten sind gesplittet
  (`ports_inbound`/`ports_outbound` mit je `direction:`), die
  Adapter-Schichten heißen `driving_adapters`/`driven_adapters`, der Port-Glob
  endet an der Richtung (der `portScope`-Fix macht die Form lebendig), und die
  Kanten-Menge ist die der Referenz — inklusive `driving_adapters→ports_inbound`
  und der drei bewusst abwesenden Kanten mit ihrem Grund als Kommentar. Der
  Skelett-Vertrag folgt: die Slice trägt einen inbound-Port (das Port-Paket
  trägt Request/Result und das Interface; command/result ziehen aus der Slice
  in den Port), der treibende Adapter spricht ihn und nie die Slice selbst —
  `driving_adapters→app` entfällt. Übergabe an Review/Planner: die
  Kanten-Menge folgt damit der Referenz und nicht mehr dem Wortlaut von
  [ADR-0060](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)
  Festlegung 4 (fünf Kanten verbatim); die normative Aufarbeitung des ADR
  ist Architect-Arbeit, nicht Teil dieses Laufs. Der a-check-Pin wandert auf
  v0.20.0 samt Digest (Registry-verifiziert) — Kopplung am neuen
  `TestArchImagePin_CouplesToDirectionPorts`.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Implementer übernimmt, der Zielordner-Slice
([`slice-zielordner-richtet-das-werkzeug-auf-ein-ziel-repo`](../done/slice-zielordner-richtet-das-werkzeug-auf-ein-ziel-repo.md),
Prio 1) hat den WIP-Slot frei gegeben, WIP-Limit frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Die drei Achsen
  wachsen auseinander — die Ports-Gliederung erzeugt Kanten, die der
  Arch-Gate-Glob nicht mehr deckt, oder die C++-Namespaces brauchen eine
  zweite Schicht. Dann Ports und Gate-Config als eigenen Posten schneiden.
- `in-progress` → `open` (blockiert — Carveout?): Die Rollen-Namen in
  `internal/gen/arch.go` werden umbenannt oder superseded, bevor die Ordner
  folgen — der Fix hätte keinen Ziel-Namen.

**Grund nachgetragen beim Übergang `in-progress` → `open` (2026-09-19):** die
Ursache fällt unter keinen der beiden vorab benannten Trigger — gemessen im
Implementer-Lauf (Übergabe): die Fundstellen des Plans (Skelett-Pfade,
Composition-Root-Imports, Namespaces, Gate-Glob) liegen im **hexslice**-
Renderer, den §1 ausdrücklich ausschließt; das **hexagonal**-Layout ist
bereits rollen-konform (`internal/gen/golang.go` rendert
`internal/adapter/{driven,driving}`, Gate-Globs in derselben Datei,
`internal/gen/hexagonal_test.go` trägt es), und C++ rendert kein hexagonal
(`internal/gen/gen.go` → `cpp: {archFlat, archHexslice}`); die Ports-Gliederung
widerspricht zwei `Accepted`-ADRs ([`ADR-0010`](../../adr/0010-hexagonal-arch-realisierung.md)
— die `direction:`-Dimension bleibt als Entscheidung ungenutzt — und
[`ADR-0009`](../../adr/0009-hexslice-arch-realisierung.md) Festlegung 2 — die
Struktur ist verbatim zu emittieren). Der Plan ist nicht implementierbar, ohne
dass die normative Entscheidung (§6) fällt — blockiert auf sie.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD mit den roten Gegenproben der drei Achsen belegt, und der
Arch-Gate-Rot-Beleg steht gegen den Gate-Test (nicht gegen einen
Kommentarlauf): das hexslice-Skelett beider Renderer liegt unter den
Rollen-Namen, und der Gate prüft genau diese Ordner.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Bestand gebootstrappter Ziele trägt das alte Skelett** — ein Ziel, das
  `v0.2.1` gebootstrapped hat, führt `adapters/{inbound,outbound}`; sein
  Arch-Gate prüft die alten Ordner, während künftige Bootstraps die neuen
  anlegen. — **Ausgang:** *entfallen* →
  [`ADR-0060`](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)
  trägt die Heilung eines Bestands-Ziels (die Heilung eines Ziels ist ein
  Re-Lauf, kein zweiter Fetch-Weg).
- **Die Rollen-Zuordnung steht in Code-Kommentaren** — die Gliederung zieht in
  den Baum, und die Kommentar-Aussagen (Repository-Port outbound,
  „erfüllt den Area-Port durch VERERBUNG") müssen mit der neuen Struktur
  konsistent bleiben. — **Ausgang:** *entfallen* → die Zuordnung ist im Baum
  geprüft (Verifikation: die drei Achsen erfüllt, die Config deklariert die
  neuen Kanten; der C++-Kommentar trägt die Kopplung wörtlich weiter).
- **Die C++-Namespaces sind vier Stellen** — (:299, :309, :332, :339) samt
  Kopf; eine übersehene Stelle bricht erst im C++-Build des Ziel-Skeletts.
  — **Ausgang:** *entfallen* → der C++-Test hält die vier Stellen
  (Verifikation: Achse 1 erfüllt am C++-Renderer mit eigener Messung).
- **Der Zielordner-Slice rührt denselben Träger-Kreis** — sein Dispatch-Griff
  und dieser Renderer-Fix berühren die Aufruf-Ebene. — **Ausgang:**
  *entfallen* → der Zielordner-Slice ist geschlossen; die Kante hat sich mit
  seinem Abschluss erledigt.
- **Der Plan schneidet das falsche Layout** — gemessen im Implementer-Lauf
  (§4, Grund nachgetragen). — **Ausgang:** *entfallen* →
  [`ADR-0060`](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)
  (Proposed, gepusht) trägt die Ports-Achse (Festlegung 2) und entscheidet
  den Ziel-Layout-Schnitt: hexslice ist der Gegenstand; der Blocker des
  Übergangs ist entfallen.
- **Drei gelistete Mutations-Fälle sind stumm** — die Config-Re-Schnitte
  änderten die Literale, auf deren Muster die Fälle **68, 71, 96** ihre sed
  fahren; alle drei sind No-Ops, `make mutate` würde dort BEFUND melden
  (gemessen, [Verifikations-Report](../../../../docs/reviews/2026-09-19-slice-adapter-und-ports-ordner-folgen-ihren-rollen-namen-verifikation.md)
  V-1, statisch gegen ihre Muster). — **Ausgang:** *weiter offen* →
  `slice-stumme-mutations-faelle-folgen-der-config-form` (Datei in `open/`).
- **Das Handbuch weist den Adopter auf einen Layer nach, den die Config nicht
  führt** — `docs/user/benutzerhandbuch.md:298` verweist auf „unter `ports`";
  der pausierte Nachzug trägt die Stelle, seine Menge wächst auf fünf Posten.
  — **Ausgang:** *weiter offen* → der Nachzug-Slice nennt die Stelle neu
  (Adresse: `benutzerhandbuch.md:298`, Richtung `ports_inbound`/`ports_outbound`).
- **Die `ARC-009`-Zelle trägt die neuen Ordner nicht** —
  [`ADR-0060`](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)
  Folgepflicht 3 ist unvollständig: die Prosa-Stellen tragen die neue Form
  (`spec/architecture.md:172-177`, `:218-220`), die Zelle
  (`spec/architecture.md:97`) nicht (gemessen, Verifikation V-3). —
  **Ausgang:** *eingetreten* → Architect-Posten (§3.8), Adresse: `ADR-0060`
  Folgepflicht 3, Zelle `spec/architecture.md:97`.
- **Der Zahn-Kommentar behauptet einen Rot-Beleg, den es nicht gibt** —
  `internal/gen/archgate_test.go:227-232` verweist auf eine Listedung, die es
  nicht gibt; der Rot-Beleg selbst steht (Runde 2, Rot-Probe (c)) —
  gemessen, Verifikation V-4. — **Ausgang:** *weiter offen* →
  `slice-stumme-mutations-faelle-folgen-der-config-form` (mit V-1).

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

- **Was hat funktioniert:** der Blocker-Zug nach `open` mit nachgetragenem
  Grund, der Re-Schnitt auf die gemessene Layout-Achse mit
  [`ADR-0060`](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)
  als tragender Mechanik — der Verifier trägt alle drei Achsen mit eigenen
  Messungen (kein DoD-Bruch), und der DoD-Konflikt (Plan §2 „der
  CLI-Adapter-Port inbound") ist beantwortet: erfüllt — der Port liegt im
  Baum, der treibende Adapter importiert ihn, die Config deklariert die neuen
  Kanten; die Verfeinerung 1 wurde übergangen, nicht still — die Lieferung
  ist die Erweiterung gegen sie, getragen vom `Accepted` `ADR-0060`.
- **Was ging anders als geplant:** der Plan schneidete zuerst das falsche
  Layout (Fundstellen im hexslice-Renderer, §1 schloss hexslice aus, zwei
  `Accepted`-ADRs widersprachen) — der Implementer blockierte, statt zu
  bauen, und der Lifecycle-Zug ging nach `open`. Die Ursache trägt
  `BEO-ALL/dod-testzeile-verortet-verhalten-in-der-falschen-stufe` als
  zweiter Beleg.
- **Steering-Loop-Eintrag:** geschärfte Regel für die Plan-Anlage: „die
  Plan-Anlage misst das Ziel-Layout, bevor sie Fundstellen schneidet" —
  gezählt, nicht verkörpert; die Klasse
  `BEO-ALL/dod-testzeile-verortet-verhalten-in-der-falschen-stufe` trägt 2×,
  die Verkörperung fällt dem Lese-Schritt zu, wenn die Klasse 3× erreicht
  (kein `liegt in`-Feld — kein Zielort vor der Verkörperung).
- **Beobachtungs-Register (`../observations/`):** keine Beobachtung
  angefallen — der bestehende Beleg
  (`BEO-ALL/dod-testzeile-verortet-verhalten-in-der-falschen-stufe/evidence/slice-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md`)
  trägt diesen Vorgang bereits (Zählerstand 2×); die Zählregel „ein Vorgang
  zählt einmal" legt keinen zweiten Beleg an.
- **Folge-Slices:** `slice-stumme-mutations-faelle-folgen-der-config-form`
  (Die drei stummen Mutations-Fälle und der Zahn-Kommentar folgen der
  re-geschnittenen Config-Form) — ist eine Datei in `open/`.
- **Risiken aus §6:** jedes mit genau einem Ausgang — Bestand → *entfallen*
  (ADR-0060 trägt die Heilung), Rollen-Kommentare → *entfallen* (im Baum
  geprüft), C++-Namespaces → *entfallen* (Test hält die vier Stellen),
  Zielordner-Kante → *entfallen* (Slice geschlossen), falsches Layout →
  *entfallen* (ADR-0060), Mutations-Fälle → *weiter offen* (Folge-Slice),
  Handbuch-Adresse → *weiter offen* (Nachzug, fünf Posten), `ARC-009`-Zelle →
  *eingetreten* (Architect-Posten, ADR-0060 Folgepflicht 3),
  Zahn-Kommentar → *weiter offen* (Folge-Slice, mit V-1).
- **Drei Paarungen:** Anker · Folge-Slice · Register, Ergebnis

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — der
Renderer (`internal/gen/`), seine Tests und die Arch-Gate-Config. Die
Sub-Area erfüllt die Schwelle ≥ 2 von 3 Achsen (Inventur-Berührung: ja;
mehrere Dateien: ja; Aussagen-Berührung: ja — die Skelett-Zusagen und die
Gate-Zuordnung). Sie ist nicht zu grob — die Modus-Deklaration in
`harness/conventions.md` führt `*` namentlich.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen am
2026-09-19 (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` →
**151**), Verzeichnisse unter `BEO-ALL/`. Treffer für die Sub-Area:
`BEO-ALL/dod-testzeile-verortet-verhalten-in-der-falschen-stufe` —
**Zählerstand 2×**; ihr zweiter Beleg trägt genau den Defekt, den der
Re-Schnitt dieses Plans korrigiert (Fundstellen in der falschen Layout-Achse).
Der Eintrag erreicht mit dieser Berührung nicht 3× — dieser Plan schreibt den
Zähler nicht hoch. `BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`
(2×) trägt eine andere Klasse (Zusage-vs-Gelingens-Zweig) und wird nicht
hochgeschrieben. Keine weiteren Treffer für die Renderer-Skelett-Klasse —
notiert.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF (`*` steht in der
Modus-Deklaration als Greenfield); kein BF/Hybrid-Block.