# Slice slice-111: Was ein Bootstrap anlegt, steht in der Nutzer-Doku — der Anleger nennt seinen Leser

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Doku-Nachzug, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1: **(1) Bündel?** Nein — ein Nachzug an zwei lebenden Dokumenten, einzeln lieferbar.
**(2) Gemeinsames Closure-Kriterium?** Nein. **(3) Auslöser reaktiv oder gewollt?** Reaktiv: vier
geschlossene Slices haben den emittierten Datei-Satz erweitert und die Standard-DoD-Zeile
*„Doku-Update, falls ein öffentlicher Vertrag berührt ist"* keiner davon bedient (§1). Kein
Fähigkeits-Sprung — das Werkzeug lernt nichts Neues. Nach Setzung 2 steht wellenlose Arbeit
**nicht** in der Roadmap.

**Ebene: die Nutzer-Doku dieses Repos über das, was das Werkzeug emittiert.** Der Gegenstand ist
**nicht** die emittierte Doku eines Ziels — die kommt aus den vendored Vorlagen —, sondern
[`README.md`](../../../../README.md) und
[`docs/user/benutzerhandbuch.md`](../../../user/benutzerhandbuch.md) dieses Repos, die einem
Adopter sagen, was ein Lauf anlegt.

**Bezug:**
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (was ein Bootstrap
anlegt, ist der Gegenstand dieser Anforderung — und damit der Vertrag, den die Nutzer-Doku
beschreibt),
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (die vier
Artefakt-Klassen, die zuletzt dazukamen),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine
Aufzählung, die vollständig aussieht und es nicht ist, sagt einen Umfang zu, den sie nicht hat),
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (**Accepted** —
Festlegung 1, 3, 6 und 7 sind die Herkunft der vier Klassen).

**Autor:** Planner. **Datum:** 2026-08-26.

---

## 1. Ziel

**Der Baum unter *„Was wird angelegt"* zeigt, was ein Lauf heute wirklich anlegt — und wo er eine
Menge zusammenfasst, sagt er, dass er zusammenfasst.**

### Der gemessene Anlass: vier Artefakt-Klassen, null Nennungen

Vier geschlossene Slices haben den emittierten Satz erweitert
([slice-096](../done/slice-096-traeger-liegt-im-ziel.md),
[slice-097](../done/slice-097-rollen-typen-gehen-mit.md),
[slice-098](../done/slice-098-feldliste-ist-ausdruck-des-traegers.md),
[slice-099](../done/slice-099-leser-und-aufraeum-kommando.md)). Die zwei lebenden Beschreibungen
haben sich seither nicht bewegt:
`git log -1 --format='%h %ad' --date=short -- docs/user/benutzerhandbuch.md README.md` → **9a4ad3b
2026-07-28** (slice-058, mitwandernd).

**Die Eigenschaft, über die gezählt wird:** eine Zeichenkette, die ein Adopter im Baum seines
frisch gebootstrappten Repos sieht oder als `make`-Ziel aufruft. Kommando:

```
for t in span-report span-clean erfassung.mk erfassung-feldliste span-emit state/bin agent.role Rollen-Typ; do
  printf '%-22s %s\n' "$t" "$(grep -rc "$t" README.md docs/user/benutzerhandbuch.md | awk -F: '{s+=$2} END{print s}')"
done
```

→ **acht Zeilen, jede mit `0`**. Die Zahl wandert mit beiden Dokumenten und ist **kein**
Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Warum das nicht bloß eine fehlende Zeile ist.** §6 des Handbuchs zeigt einen **Baum** — eine
Form, die Vollständigkeit anbietet, ohne sie zu behaupten. Sein Kommentar zu `harness/mk/` lautet <!-- d-check:ignore (Pfad im Zielrepo, nicht in diesem) -->
heute *„Prüf-Bausteine: Doc-Gate, Regelwerk-Prüfung, Schutz-Hooks"* (`grep -n 'Prüf-Bausteine'
docs/user/benutzerhandbuch.md`); seit
[slice-099](../done/slice-099-leser-und-aufraeum-kommando.md) liegt dort ein Fragment, das keines
der drei ist — es prüft nichts, es berichtet und räumt auf, und es sagt das über sich selbst. Ein
Adopter, der zwei neue `make`-Ziele in seinem `make help` findet, die sein Handbuch nicht kennt,
liest entweder das Handbuch als veraltet oder die Ziele als fremd. Beides ist ein Verlust an
genau der Stelle, an der
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) seinen Vertrag macht.

**Der zweite Teil ist die Form, nicht der Inhalt.** Ein Baum, der jede künftige Datei einzeln
führt, altert bei jedem Slice — genau die Drift, die dieses Repo an vier anderen Stellen schon
gemessen hat. Die Antwort ist nicht mehr Aufzählung, sondern eine **ausgesprochene**
Zusammenfassung: wo der Baum eine Menge bündelt, sagt er, dass er bündelt, und nennt das
Kommando, das die Menge zeigt (`make help` im Ziel).

## 2. Definition of Done

Zwei slice-eigene Punkte (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6). Wo kein Kommando einen Punkt rot färbt, steht das
dabei, statt sich hinter einem anderen zu verstecken.

- [ ] **(1) Die acht heute unbenannten Zeichenketten sind entweder benannt oder ausdrücklich einer
      genannten Menge zugeordnet.** Für jede der acht steht in
      [`docs/user/benutzerhandbuch.md`](../../../user/benutzerhandbuch.md) (§6 *Was wird angelegt*)
      oder in [`README.md`](../../../../README.md) entweder ihr Name oder der Satz, der sie als
      Teil einer benannten Menge ausweist. Der Kommentar zu `harness/mk/` nennt die <!-- d-check:ignore (Pfad im Zielrepo, nicht in diesem) -->
      Bericht-/Aufräum-Klasse oder hört auf, die Klassen aufzuzählen.
      **Rot:** das Kommando aus §1 liefert für keine der acht Zeilen mehr `0` — beziehungsweise
      der Satz, der die Zusammenfassung ausspricht, ist mit `grep` an genau einer Stelle zu
      finden. **Kein Gate färbt diese Zeile rot, und das ist der Befund, keine Vertagung:**
      `make docs-check` prüft Links, Anker, Kennungen und Codepaths, nicht die Vollständigkeit
      einer Aufzählung gegen einen Emitter. Der Sensor dafür ist offen (§6).
- [ ] **(2) Der Baum sagt, ob er aufzählt oder zusammenfasst.** An genau einer Stelle steht, wie
      ein Adopter die vollständige Menge selbst erhebt — das `make help` seines Ziels und der
      Blick in `harness/mk/`. Ein Baum ohne diesen Satz bietet Vollständigkeit an, die niemand <!-- d-check:ignore (Pfad im Zielrepo, nicht in diesem) -->
      hält.
      **Rot:** ein `test/mutations/`-Fall ist hier **nicht** möglich, weil der Gegenstand
      Fließtext in einem nicht-emittierten Dokument ist; der Punkt trägt sein Rot über das
      Review, und das steht hier statt eines behaupteten Kommandos.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · Doku-Update, falls ein
öffentlicher Vertrag berührt ist — **hier ist es der Gegenstand, nicht die Folge** · Closure-Notiz
mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`docs/user/benutzerhandbuch.md`](../../../user/benutzerhandbuch.md) §6 *Was wird angelegt* | update | DoD (1) und (2) — der Baum und sein `harness/mk/`-Kommentar | <!-- d-check:ignore (Pfad im Zielrepo, nicht in diesem) -->
| [`docs/user/benutzerhandbuch.md`](../../../user/benutzerhandbuch.md) §5 *Konfiguration* / §9 *Glossar* | update, **soweit betroffen** | zwei neue `make`-Ziele und ein gitignorierter Zustands-Bereich sind Bedienwissen, nicht nur Baum-Inhalt |
| [`README.md`](../../../../README.md) | update, **soweit betroffen** | die kürzere der beiden Beschreibungen; welche Aussage wohin gehört, entscheidet der Lauf am Text |
| [`AGENTS.md`](../../../../AGENTS.md) §4 und [`harness/README.md`](../../../../harness/README.md) §Sensors | **zu prüfen, nicht vorab gesetzt** | beide beschreiben **unser** `span-report` und sind gemessen weiterhin wahr; ob die zwei **emittierten** Ziele dort hingehören, ist die Frage des Laufs. §4 ist die Gate-Beschreibung — **nicht** der Hard-Rules-Block, für den [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 den Architect setzt |
| `spec/`, `docs/plan/adr/` | **unverändert** | es wächst keine Anforderung und fällt keine Entscheidung; die vier Klassen sind bereits angenommen ([`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren), [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)) — kein Change Request nach [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) |
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | **unverändert** | wellenlose Arbeit wird dort nicht geführt ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 2/3) |

## 4. Trigger

**`open` → `next`:** keine Vorbedingung — die vier Artefakt-Klassen liegen, und das Kommando aus
§1 ist ohne Rückfrage nachfahrbar. **`next` → `in-progress`:** WIP-Limit frei.

**Rückführungen, vorab benannt.** `in-progress` → `next`, wenn der Lauf feststellt, dass der Baum
in §6 nicht nachgezogen, sondern **neu geschnitten** gehört (Phasen-Darstellung gegen
Artefakt-Klassen) — das ist eine Doku-Architektur-Frage und kein Nachzug. `in-progress` → `open`,
wenn die Frage *„gehören die zwei emittierten Ziele in eine Gate-Tabelle dieses Repos?"* nicht
ohne eine Aussage über die Trennung Dogfood/emittiert entscheidbar ist — dann steht eine
Entscheidung aus, und dieser Slice ist nicht ihr Ort.

## 5. Closure-Trigger

DoD (1) und (2) erfüllt mit gefahrenem Kommando, `make gates` grün, Closure-Notiz in §7 mit
Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der Nachzug altert sofort wieder.** Genau das ist beim letzten Mal passiert: die Beschreibung
  hielt vier Slices lang nicht Schritt. Wer nur die acht Zeichenketten einträgt, hat den nächsten
  Nachzug schon bestellt — deshalb DoD (2), das die Form ändert und nicht nur den Inhalt.
- **Ein Sensor über *„die Aufzählung ist vollständig"* ist offen und hier nicht mitgeschnitten.**
  Die naheliegende Konstruktion — den emittierten Datei-Satz gegen den Baum halten — hat einen
  Gegner: der Baum ist Prosa mit Kommentaren, und ein Wächter darüber bräuchte erst ein Kriterium,
  was als *genannt* zählt. Die Klasse liegt beim Roadmap-Kandidaten *Regeln ohne
  Feedback-Quadrant schließen*, Achse (1) (Doku ↔ `Makefile` über das `targets`-Modul); ob sie
  eine Aufzählung **innerhalb** einer Prosa-Zeile erreicht, ist dort ausdrücklich als **ungemessen**
  geführt.
- **Zwei Ebenen, die leicht verrutschen.** Das Handbuch beschreibt, was ein **Ziel** bekommt;
  [`AGENTS.md`](../../../../AGENTS.md) §4 und [`harness/README.md`](../../../../harness/README.md)
  beschreiben, was **dieses** Repo fährt. Beide Sätze über `span-report` sind heute wahr, und beide
  meinen ein anderes Programm am anderen Ort. Wer sie zusammenzieht, erzeugt die Verwechslung, die
  dieser Slice beheben soll.
- **Der getaggte Stand bleibt, wie er ist.** Ein Release-Text ist außerhalb von `git` und wird von
  keinem Gate erreicht (Roadmap-Kandidat, Achse (7)); dieser Slice zieht die lebenden Dokumente
  nach, nicht die veröffentlichten.

## 7. Closure-Notiz (nach `done/`)

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `docs/user/` und die
Wurzel-`README.md` gehören zum Greenfield-Bestand — beide sind in diesem Repo entstanden, keine
Inventur steht zwischen Doku-Aussage und Code-Bestand aus. Der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
