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
der Punkt, an dem der Fix in die geprüfte Schicht wirkt);
Setzung des Auftraggebers vom 2026-09-19: drei Achsen, beide Renderer in
einem Vorgang — der Fix-Slice wartet in `open/` auf den Zielordner-Slice
(Prio 1).

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-19.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Das hexagonal-Skelett beider Renderer richtet sich auf seine eigenen
Rollen-Namen — drei Achsen in einem Vorgang:

1. **Adapter-Ordner:** `inbound`/`outbound` → `driving`/`driven` — Go
   (`internal/gen/golang.go`: die Skelett-Pfade, die Composition-Root-Imports,
   der Arch-Gate-Glob `internal/adapters/**` und der Kopf) und C++
   (`internal/gen/cpp.go`: die Skelett-Pfade samt Namespaces in den drei
   Quelldateien und der Kopf). Die Rollen-Namen existieren bereits
   (`grep -n 'hexagonal-driving\|hexagonal-driven' internal/gen/arch.go` →
   Zeilen 50 und 54: `hexagonal-driven` / `hexagonal-driving`) — der Fix
   richtet das Skeleton auf seine eigenen Rollen-Namen, statt einen zweiten
   Namensraum daneben zu legen.
2. **Ports-Gliederung:** die flachen `ports`-Ordner bekommen
   `ports/{inbound,outbound}/` nach derselben Rollen-Zuordnung — der
   Repository-Port ist outbound (der C++-Kommentar sagt es wörtlich:
   „erfuellt den Area-Port durch VERERBUNG", `grep -n 'erfuellt den Area-Port' internal/gen/cpp.go`
   → Zeile 339), der CLI-Adapter treibt die Use-Case und braucht einen
   inbound-Port. Die Gliederung existiert heute nur in Code-Kommentaren, nicht
   im Baum.
3. **Die Arch-Gate-Config wandert mit** — der Glob und die Rollen-Zuordnungen
   — mit Rot-Beleg gegen den Gate-Test: das ist der Punkt, an dem der Fix in
   die geprüfte Schicht wirkt.

Die `internal/gen/{hexagonal_test,archgate_test,hexslice_test,cpp_test}.go`
tragen die `inbound`/`outbound`-Erwartungen — jede Achse zieht ihren Test mit.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Keine Release-Berührung** — **anderer Vorgang:** der Renderer-Output
  ändert sich für künftige Bootstraps; das published Release `v0.2.1` bleibt,
  wie es geschnitten ist. Ein Re-Publish würde die Tag-Kopplung
  ([`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  Festlegung 2) für denselben Stand zweimal vollziehen.
- **Keine a-check-Regel-Änderung** — **Bestand bleibt bewusst stehen:** die
  Rollen-Namen existieren, nur die Ordner folgen ihnen; der Fix ändert keine
  Gate-Schwelle und keine Regel des Arch-Gates, er richtet die Ordner und
  ihre Config auf dieselben Namen.
- **Kein zweiter Fetch-Weg** — **Bestand bleibt bewusst stehen:** der Fetch
  ([`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  Festlegung 1, [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
  Festlegung 3) bleibt, wo er steht; der Renderer-Fix rührt den Skeleton-Output,
  nicht den Träger-Weg.
- **Die `hexslice`-Layouts bleiben unberührt** — **Schicht-Abgrenzung:** der
  Fix trifft das **hexagonal**-Layout; `flat` und `hexslice` bauen ihre
  Ordner, wie sie stehen — ein Griff an ihrem Skelett wäre ein zweiter
  Vorgang mit eigener Deckung.

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

- [ ] **Liefer-Punkt 1 — Adapter-Ordner:** das hexagonal-Skelett beider
      Renderer legt seine Adapter unter `driving`/`driven` an — Go
      (`internal/gen/golang.go`: Skelett-Pfade, Composition-Root-Imports,
      Arch-Gate-Glob, Kopf) und C++ (`internal/gen/cpp.go`: Skelett-Pfade,
      Namespaces in den drei Quelldateien, Kopf); die Rollen-Namen kommen aus
      `internal/gen/arch.go` (`hexagonal-driving`/`hexagonal-driven`), es
      entsteht kein zweiter Namensraum. Rote Gegenprobe: legt das Skeleton
      `inbound` an, färbt der Renderer-Test (`internal/gen/hexagonal_test.go`,
      `internal/gen/cpp_test.go`) rot.
- [ ] **Liefer-Punkt 2 — Ports-Gliederung:** die flachen `ports`-Ordner
      bekommen `ports/{inbound,outbound}/` nach derselben Rollen-Zuordnung —
      der Repository-Port outbound, der CLI-Adapter-Port inbound. Rote
      Gegenprobe: ein Port ohne inbound/outbound-Zuordnung färbt den
      Renderer-Test rot — die Zuordnung ist an der Stelle geprüft, an der die
      Ordner entstehen, nicht in einem Kommentar.
- [ ] **Liefer-Punkt 3 — Arch-Gate-Config wandert mit:** der Glob und die
      Rollen-Zuordnungen tragen die neuen Ordner, und der Rot-Beleg steht
      gegen den Gate-Test (`internal/gen/archgate_test.go`) — der Punkt, an
      dem der Fix in die geprüfte Schicht wirkt. Rote Gegenprobe: hält die
      Config am alten Glob (`internal/adapters/**`), färbt der
      archgate-Test rot — das Skelett ist nicht mehr dort, wo der Gate
      prüft.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist (das
      Skelett-Layout im Handbuch bzw. der Nutzer-Doku, falls er es nennt).
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
| `internal/gen/golang.go` | update | Achse 1 (Skelett-Pfade, Composition-Root-Imports, Arch-Gate-Glob, Kopf) und Achse 2 (Ports-Gliederung) |
| `internal/gen/cpp.go` | update | dieselben zwei Achsen — Skelett-Pfade, Namespaces in den drei Quelldateien, Kopf, Ports-Gliederung |
| `internal/gen/hexagonal_test.go` | update | die `inbound`/`outbound`-Erwartungen folgen auf `driving`/`driven` samt Ports-Gliederung |
| `internal/gen/cpp_test.go` | update | dieselben Erwartungen am C++-Renderer |
| `internal/gen/archgate_test.go` | update | der Glob und die Rollen-Zuordnungen — Rot-Beleg gegen den Gate-Test (Achse 3) |
| `internal/gen/hexslice_test.go` | update | die Deckung, dass das `hexslice`-Layout unberührt bleibt |

**Ansatz als Liste, wo eine Zeile pro Datei nicht trägt:**

- Die Rollen-Namen sind die Quelle, nicht die Kopie: `internal/gen/arch.go`
  führt `hexagonal-driving`/`hexagonal-driven` bereits; die Ordner-Namen und
  die Arch-Gate-Zuordnung lesen dieselben Konstanten, statt eigene Strings
  daneben zu legen.
- Die Ports-Gliederung zieht die Zuordnung aus den Code-Kommentaren in den
  Baum — der Kommentar („erfüllt den Area-Port durch VERERBUNG") bleibt als
  Kopplungs-Aussage stehen und wird mit der Struktur konsistent geprüft.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Implementer übernimmt, der Zielordner-Slice
([`slice-zielordner-richtet-das-werkzeug-auf-ein-ziel-repo`](../in-progress/slice-zielordner-richtet-das-werkzeug-auf-ein-ziel-repo.md),
Prio 1) hat den WIP-Slot frei gegeben, WIP-Limit frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Die drei Achsen
  wachsen auseinander — die Ports-Gliederung erzeugt Kanten, die der
  Arch-Gate-Glob nicht mehr deckt, oder die C++-Namespaces brauchen eine
  zweite Schicht. Dann Ports und Gate-Config als eigenen Posten schneiden.
- `in-progress` → `open` (blockiert — Carveout?): Die Rollen-Namen in
  `internal/gen/arch.go` werden umbenannt oder superseded, bevor die Ordner
  folgen — der Fix hätte keinen Ziel-Namen.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD mit den roten Gegenproben der drei Achsen belegt, und der
Arch-Gate-Rot-Beleg steht gegen den Gate-Test (nicht gegen einen
Kommentarlauf): das hexagonal-Skelegt beider Renderer liegt unter den
Rollen-Namen, und der Gate prüft genau diese Ordner.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Bestand gebootstrappter Ziele trägt das alte Skelett** — ein Ziel, das
  `v0.2.1` gebootstrapped hat, führt `adapters/{inbound,outbound}`; sein
  Arch-Gate prüft die alten Ordner, während künftige Bootstraps die neuen
  anlegen. Ausgang: weiter offen → Sichtung bei der Closure; eingetreten →
  Folge-Slice (Bestands-Migration oder Doku-Hinweis am Fetch).
- **Die Rollen-Zuordnung steht in Code-Kommentaren** — die Gliederung zieht in
  den Baum, und die Kommentar-Aussagen (Repository-Port outbound,
  „erfüllt den Area-Port durch VERERBUNG") müssen mit der neuen Struktur
  konsistent bleiben. Ausgang: entfallen, wenn das Review die Zuordnung im
  Baum gegen die Kommentare geprüft hat; sonst weiter offen → Sichtung.
- **Die C++-Namespaces sind vier Stellen** — (:299, :309, :332, :339) samt
  Kopf; eine übersehene Stelle bricht erst im C++-Build des Ziel-Skeletts.
  Gegenbeispiel ist `internal/gen/cpp_test.go` — Ausgang: entfallen, wenn der
  Test die vier Stellen hält; sonst weiter offen.
- **Der Zielordner-Slice rührt denselben Träger-Kreis** — sein Dispatch-Griff
  und dieser Renderer-Fix berühren die Aufruf-Ebene; die Reihenfolge
  (Zielordner-Slice zuerst, Prio 1) hält die Kante. Ausgang: weiter offen →
  Sichtung bei der Closure dieses Slices.

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
  angelegt, Beleg
  `evidence/slice-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md` |
  `evidence/slice-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md` in
  `BEO-<KUERZEL>/<slug>/` ergänzt — Zähler steht damit bei <N>x | keine
  Beobachtung angefallen>
- **Folge-Slices:** <slice-<Kennung> (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
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
**146**), Verzeichnisse unter `BEO-ALL/`. Treffer für die Sub-Area: keine —
kein Eintrag trägt die Renderer-Skelett-Klasse (Adapter-Ordner,
Ports-Gliederung, Arch-Gate-Glob); der nächste Eintrag in der Nähe,
`BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`
(Zählerstand 2×), trägt eine andere Klasse (Zusage-vs-Gelingens-Zweig), und
dieser Plan schreibt ihn nicht hoch. Keine Treffer sind ebenfalls eine Antwort
und werden notiert.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF (`*` steht in der
Modus-Deklaration als Greenfield); kein BF/Hybrid-Block.