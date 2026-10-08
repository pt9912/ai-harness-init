# Slice slice-111: Was ein Bootstrap anlegt, steht in der Nutzer-Doku — der Anleger nennt seinen Leser

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-handbuch-zeigt-den-bestand](../welle-handbuch-zeigt-den-bestand.md) — läuft dort
nach slice-191 (Welle-Plan §4).

**Handbuch-Setzung:** das Handbuch trägt nur den Ist-Zustand — keine Kennungen, keine Chronik,
nichts Unimplementiertes.

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

**Verantwortlich:** pt9912.

---

## 1. Ziel

**Der Baum unter *„Was wird angelegt"* zeigt, was ein Lauf heute wirklich anlegt — und wo er eine
Menge zusammenfasst, sagt er, dass er zusammenfasst.**

### Der gemessene Anlass: vier Artefakt-Klassen, null Nennungen

Vier geschlossene Slices haben den emittierten Satz erweitert
([slice-096](../done/slice-096-traeger-liegt-im-ziel.md),
[slice-097](../done/slice-097-rollen-typen-gehen-mit.md),
[slice-098](../done/slice-098-feldliste-ist-ausdruck-des-traegers.md),
[slice-099](../done/slice-099-leser-und-aufraeum-kommando.md)). Das Handbuch hat seither die
Bedienung nachgezogen (§4 *Betriebs-Operationen*), den Rest nicht — Kommando unten.

**Die Eigenschaft, über die gezählt wird:** eine Zeichenkette, die ein Adopter im Baum seines
frisch gebootstrappten Repos sieht oder als `make`-Ziel aufruft. Kommando:

```
for t in span-report span-clean erfassung.mk erfassung-feldliste span-emit state/bin agent.role Rollen-Typ; do
  printf '%-22s %s\n' "$t" "$(grep -rc "$t" README.md docs/user/benutzerhandbuch.md | awk -F: '{s+=$2} END{print s}')"
done
```

→ gemessen am 2026-10-08: **vier** Zeilen mit `0` — `erfassung.mk`, `span-emit`, `agent.role`,
`Rollen-Typ`. Die übrigen vier nennt das Handbuch: `span-report`, `span-clean` und `state/bin` in
§4 *Betriebs-Operationen*, `erfassung-feldliste` als Pfad in der Tabelle zum erneuten Aufsetzen.
Was die Erfassung **aufzeichnet** und welche Rollen-Typen mitkommen, steht nirgends. Die Zahl
wandert mit beiden Dokumenten und ist **kein**
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

- [x] **(1) Die heute unbenannten Zeichenketten sind entweder benannt oder ausdrücklich einer
      genannten Menge zugeordnet.** Für jede der acht aus §1 steht in
      [`docs/user/benutzerhandbuch.md`](../../../user/benutzerhandbuch.md) (§6 *Was wird angelegt*)
      oder in [`README.md`](../../../../README.md) entweder ihr Name oder der Satz, der sie als
      Teil einer benannten Menge ausweist. Der Kommentar zu `harness/mk/` nennt die <!-- d-check:ignore (Pfad im Zielrepo, nicht in diesem) -->
      Bericht-/Aufräum-Klasse oder hört auf, die Klassen aufzuzählen.
      **Rot:** das Kommando aus §1 liefert für keine der acht Zeilen mehr `0` — beziehungsweise
      der Satz, der die Zusammenfassung ausspricht, ist mit `grep` an genau einer Stelle zu
      finden. **Kein Gate färbt diese Zeile rot, und das ist der Befund, keine Vertagung:**
      `make docs-check` prüft Links, Anker, Kennungen und Codepaths, nicht die Vollständigkeit
      einer Aufzählung gegen einen Emitter. Der Sensor dafür ist offen (§6).
- [x] **(2) Der Baum sagt, ob er aufzählt oder zusammenfasst.** An genau einer Stelle steht, wie
      ein Adopter die vollständige Menge selbst erhebt — das `make help` seines Ziels und der
      Blick in `harness/mk/`. Ein Baum ohne diesen Satz bietet Vollständigkeit an, die niemand <!-- d-check:ignore (Pfad im Zielrepo, nicht in diesem) -->
      hält.
      **Rot:** ein `test/mutations/`-Fall ist hier **nicht** möglich, weil der Gegenstand
      Fließtext in einem nicht-emittierten Dokument ist; der Punkt trägt sein Rot über das
      Review, und das steht hier statt eines behaupteten Kommandos.
      — **Abnahme (Planner): erfüllt in der Eigenschaft.** Der Baum sagt, dass er aufzählt
      (*„Der Baum nennt jede Datei und jedes Verzeichnis …"*), und seine Vollständigkeit hält
      `harness/tools/handbuch-baum.sh` in `make full-smoke`; der verlangte `make help`-Satz fehlt,
      weil es keine Zusammenfassung mehr gibt, deren Menge ein Adopter selbst erheben müsste (§7).

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · Doku-Update, falls ein
öffentlicher Vertrag berührt ist — **hier ist es der Gegenstand, nicht die Folge** · Closure-Notiz
mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`docs/user/benutzerhandbuch.md`](../../../user/benutzerhandbuch.md) §6 *Was wird angelegt* | update | DoD (1) und (2) — der Baum und sein `harness/mk/`-Kommentar | <!-- d-check:ignore (Pfad im Zielrepo, nicht in diesem) -->
| [`docs/user/benutzerhandbuch.md`](../../../user/benutzerhandbuch.md) §4 / §9 *Glossar* | update, **soweit betroffen** | die zwei `make`-Ziele und der Zustands-Bereich stehen bereits in §4 *Betriebs-Operationen*; offen ist, was erfasst wird und welche Rollen-Typen mitkommen |
| [`README.md`](../../../../README.md) | update, **soweit betroffen** | die kürzere der beiden Beschreibungen; welche Aussage wohin gehört, entscheidet der Lauf am Text |
| [`AGENTS.md`](../../../../AGENTS.md) §4 und [`harness/README.md`](../../../../harness/README.md) §Sensors | **zu prüfen, nicht vorab gesetzt** | beide beschreiben **unser** `span-report` und sind gemessen weiterhin wahr; ob die zwei **emittierten** Ziele dort hingehören, ist die Frage des Laufs. §4 ist die Gate-Beschreibung — **nicht** der Hard-Rules-Block, für den [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 den Architect setzt |
| `spec/`, `docs/plan/adr/` | **unverändert** | es wächst keine Anforderung und fällt keine Entscheidung; die vier Klassen sind bereits angenommen ([`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren), [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)) — kein Change Request nach [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) |
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | **unverändert** (außer der Marke *In Arbeit*) | die Welle führt den Slice in ihrer Plan-Datei, die Roadmap nur ihren Zeiger |

**Umsetzung (Stand nach slice-191).** Der Baum in §6 zählt auf und sagt das (*„Der Baum nennt
jede Datei und jedes Verzeichnis, das der Lauf anlegt"*), `harness/tools/handbuch-baum.sh` hält ihn
in `make full-smoke`; der `harness/mk/`-Kommentar zählt keine Prüf-Klassen mehr auf. <!-- d-check:ignore (Pfad im Zielrepo, nicht in diesem) -->
Geschrieben ist darum nur der Rest: Handbuch §4 neuer Abschnitt *Was die Erfassung aufzeichnet*
(Hook-Bindung, Ablage, Feldklassen, Rollen-Typen und `agent_role`, Auslesen/Aufräumen, kein
Abschalt-Schalter, Schutz), Verweis darauf aus §6, Etikett von `harness/mk/` und Glossar-Zeile <!-- d-check:ignore (Pfad im Zielrepo, nicht in diesem) -->
*Prüf-Baustein* auf „Prüfungen und Kommandos", Glossar *Erfassung / Span* und *Rollen-Typ*; ein
Satz in [`README.md`](../../../../README.md). [`AGENTS.md`](../../../../AGENTS.md) §4 und
[`harness/README.md`](../../../../harness/README.md) bleiben unverändert — sie beschreiben das
`span-report` dieses Repos, nicht das emittierte (§6, *Zwei Ebenen*). DoD (2) verlangt einen Satz
zur selbst erhobenen Menge *statt* einer Aufzählung; der Baum zählt auf und ist bewacht — ob der
Punkt damit erfüllt oder gegenstandslos ist, ist Übergabe an den Planner.

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
  — **Ausgang:** **entfallen** — den Baum hält seit slice-191 `handbuch-baum.sh` in beide
  Richtungen gegen den realen Lauf; ein Nachzug, der ausbleibt, färbt `make full-smoke` rot.
- **Ein Sensor über *„die Aufzählung ist vollständig"* ist offen und hier nicht mitgeschnitten.**
  Die naheliegende Konstruktion — den emittierten Datei-Satz gegen den Baum halten — hat einen
  Gegner: der Baum ist Prosa mit Kommentaren, und ein Wächter darüber bräuchte erst ein Kriterium,
  was als *genannt* zählt. Die Klasse liegt beim Roadmap-Kandidaten *Regeln ohne
  Feedback-Quadrant schließen*, Achse (1) (Doku ↔ `Makefile` über das `targets`-Modul); ob sie
  eine Aufzählung **innerhalb** einer Prosa-Zeile erreicht, ist dort ausdrücklich als **ungemessen**
  geführt. — **Ausgang:** **entfallen** — der Sensor steht: `handbuch-baum.sh`
  ([slice-191](../done/slice-191-benutzerhandbuch-zeigt-den-vollstaendigen-bestand.md)) hält die
  Pfad-Menge des Baums; das Kriterium *genannt* ist dort ein Pfad im Baum, nicht ein Wort in Prosa.
- **Zwei Ebenen, die leicht verrutschen.** Das Handbuch beschreibt, was ein **Ziel** bekommt;
  [`AGENTS.md`](../../../../AGENTS.md) §4 und [`harness/README.md`](../../../../harness/README.md)
  beschreiben, was **dieses** Repo fährt. Beide Sätze über `span-report` sind heute wahr, und beide
  meinen ein anderes Programm am anderen Ort. Wer sie zusammenzieht, erzeugt die Verwechslung, die
  dieser Slice beheben soll. — **Ausgang:** **entfallen** — [`AGENTS.md`](../../../../AGENTS.md)
  §4 und [`harness/README.md`](../../../../harness/README.md) sind unverändert; das Handbuch
  beschreibt allein das emittierte Ziel (Verifikation: ohne Befund).
- **Der getaggte Stand bleibt, wie er ist.** Ein Release-Text ist außerhalb von `git` und wird von
  keinem Gate erreicht (Roadmap-Kandidat, Achse (7)); dieser Slice zieht die lebenden Dokumente
  nach, nicht die veröffentlichten. — **Ausgang:** **entfallen** — ein veröffentlichter Stand
  wird nicht nachgezogen; die lebenden Dokumente gehen mit dem nächsten Release-Schnitt hinaus, der
  das Handbuch ohnehin trägt.

## 7. Closure-Notiz (nach `done/`)

**Rolle:** Planner · **Datum:** 2026-10-08.

- **Was hat funktioniert:** Handbuch §4 *Was die Erfassung aufzeichnet* und ein README-Satz
  (`8749d5b5`); das Kommando aus §1 liefert keine Zeile `0` mehr (Verifikation, DoD (1) bestätigt).
  Review 0 HIGH / 0 MEDIUM, LOW-1/2 in `e2ce9549`; die geänderten Aussagen (Ablage, 0600,
  `agent_role`) am frisch gebootstrappten Ziel gemessen.
- **Was ging anders als geplant:** DoD (2) war durch slice-191 überholt — der Baum zählt auf und ist
  bewacht, statt eine Menge zusammenzufassen. **Abnahme-Urteil:** erfüllt in der Eigenschaft
  (*der Baum sagt, ob er aufzählt*); der verlangte `make help`-Satz ist gegenstandslos und fehlt.
- **Offen beim Auftraggeber (V-1):** `e2ce9549` hat ohne Plan-Zeile die **emittierte** Feldliste
  geändert (`internal/span/fieldlist.go`, *„nur für den Eigentümer lesbar (Modus 0600)"*) — gegen
  §3 (*nicht die emittierte Doku*), gegen das Out-of-Scope der Welle (*kein emittiertes Byte*) und
  im Widerspruch zu [`LH-FA-14`](../../../../spec/lastenheft.md#lh-fa-14--redaktion-und-erfassungs-umfang)
  §Redaktion und [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
  Festlegung 6 Stück 3 (*„nicht zugriffsbeschränkt"*). Das Verhalten (0600) bestand vorher; zu
  entscheiden ist Change Request + Folge-ADR oder Rücknahme des Satzes. Diese Closure entscheidet es
  nicht und legt keinen Slice an.
- **Grenze:** `TestModeIsOwnerOnly` hat keinen `test/mutations/`-Fall; `TestFeldliste_GrenzeUeberDenBestand`
  hält *„nur für den Eigentümer lesbar"*, nicht *„(Modus 0600)"* und nicht *„Verzeichnis
  auflistbar"* (Verifikation, rot gesehen im Klon).
- **Steering-Loop-Eintrag:** **gezählt, nicht verkörpert** — kein Zielort, darum kein
  `liegt in`-Feld.
- **Beobachtungs-Register (`../observations/`):** drei Belege
  `evidence/slice-111-was-ein-bootstrap-anlegt-steht-in-der-nutzerdoku.md` — in
  [`plan-abweichung-landet-im-commit-bericht-statt-im-plan`](../observations/BEO-ALL/plan-abweichung-landet-im-commit-bericht-statt-im-plan/observation.md)
  (V-1), in
  [`zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel`](../observations/BEO-ALL/zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel/observation.md)
  (Grenze oben) und in
  [`abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt`](../observations/BEO-ALL/abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt/observation.md)
  (DoD (2)). Alle drei tragen ihren Ausgang schon (`verkörpert` · `geplant` · `verkörpert`); kein
  Eintrag steht danach `offen` über der Schwelle
  ([`ADR-0085`](../../adr/0085-slice-closure-mit-schwellen-uebertritt-ist-lese-schritt.md)
  Festlegung 1 greift nicht).
- **Folge-Slices:** keine.
- **Risiken aus §6:** (1) **entfallen** · (2) **entfallen** · (3) **entfallen** · (4) **entfallen**
  — je mit Grund in §6.

- **Paarungen geprüft am 2026-10-08, nach dem `git mv`:** (a) Anker — kein `liegt in`-Feld in §7,
  kein Gegenstand · (b) Folge-Slice — keiner genannt · (c) Register — die drei genannten
  Verzeichnisse existieren, `evidence/*.md` je nicht leer (6 · 9 · 10, `ls …/evidence/*.md | wc -l`,
  keine Erwartung). Grün.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `docs/user/` und die
Wurzel-`README.md` gehören zum Greenfield-Bestand — beide sind in diesem Repo entstanden, keine
Inventur steht zwischen Doku-Aussage und Code-Bestand aus. Der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
