# Slice slice-tap-check-liest-keine-version-ist-gebunden: Dass `check` keine Version liest, hat einen Zahn

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — es gibt keine Closure-Bedingung, die von der DoD dieses
Slice verschieden ist, siehe Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht (Modul 6).

**Ebene: Dogfood, Test-Slice.** Gegenstand sind ein `bats`-Fall, ein Mutations-Fall und ein Satz der
Nutzer-Doku; kein Produkt-Code, kein Skript-Eingriff, kein `make`-Ziel, kein Workflow.

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(Reproduzierbarkeit — die Kontrolle hält das Tap gegen das veröffentlichte Asset, und eine Zusage darüber
trägt ihren Zahn),
[`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
(**Accepted** — Festlegung 2: die `version`-Zeile ist nur in `sync` Gegenstand, `check` liest sie nicht als
Feld; §Fitness Function: jede Zusage mit dem Gegenbeispiel, das sie brechen lässt),
[`ADR-0066`](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md)
(**Accepted** — die Klasse des Skripts und die Zeile `tap-check: Exit <N>`, die der neue Fall liest).

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-25.

---

## 1. Ziel und Abgrenzung


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Die Eigenschaft *„`check` liest keine `version`-Zeile"* hat einen Zahn: ein `bats`-Fall fährt sie
an **ungleichen Bytes mit größerer Tap-Version** (Exit 1, Zeile `tap-check: Exit 1`, Meldung
Formel-Unterschied), ein Mutations-Fall in `test/mutations/` färbt ihn rot, wenn der Vergleich der Nutzlast
die `version`-Zeilen liest und bei größerer Tap-Version mit Exit 0 endet, und
[`docs/user/releasing.md`](../../../user/releasing.md) Schritt 7 sagt nur zu, was diese zwei binden.

**Der Zustand, an dem der Schnitt hängt** (gemessen am 2026-09-25):

- **Der Text nennt den Zahn als fehlend.** Schritt 7 trennt *gebunden* (gleiche Bytes enden mit Exit 0, auch
  mit einer `version`-Zeile außerhalb der Feldform) von *nicht gebunden* (ein Vergleich, der bei ungleichen
  Bytes die `version`-Zeilen liest und bei größerer Tap-Version mit Exit 0 endet) und endet auf *„der Zahn
  fehlt"* (`grep -n 'der Zahn fehlt' docs/user/releasing.md`).
- **Der Fall, den der Text nennt, fährt nur gleiche Bytes.** Die Kurzrunde
  `2026-09-25-releasing-md-schritt-7-vorbehalte-f-1-bis-f-3-kurzrunde` (Befund M-1) mutierte den Zweig
  *cmp meldet Unterschied* in `gleich()` der Nutzlast so, dass er die `version`-Zeilen liest und bei
  größerer Tap-Version `return 0` gibt: `test/tap-nachzug.bats` lief mit 37 Fällen ohne ein `not ok`; dieselbe
  Stelle mit `!=` statt `>` färbte drei Fälle — die Stelle wird erreicht, das Überleben ist kein Leerlauf.
  Das Register führt die Klasse als
  [`BEO-ALL/doku-zusage-nennt-den-test-dessen-fall-nur-einen-ausschnitt-misst`](../observations/BEO-ALL/doku-zusage-nennt-den-test-dessen-fall-nur-einen-ausschnitt-misst/observation.md).
- **Die Familie der Mutations-Fälle besteht.** `git ls-files 'test/mutations/*tap-check*' | wc -l` → 26,
  alle im Modus 100755; die höchste Nummer im Verzeichnis trägt `ls test/mutations | sort -n | tail -1`
  (451 am 2026-09-25) — Zahlen sind Messungen, keine Erwartungswerte
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Modus `sync` und jeder Fall über die `version`-Zeile in `sync`** — **Folge-Slice
  `slice-tap-nachzug-sync-schreibt-die-formel-ins-tap`**
  (Datei in `open/`): sein Vorwärts-Schutz liest die Zeile *in `sync`*, und die Fälle dazu (Lesbarkeit, `<`,
  Gleichstand) sind Fälle dieses Modus; die Adresse nimmt den Punkt an (dort Liefer-Punkt 1). Der Fall aus
  diesem Slice bleibt der Zahn für `check`: gerät die Zeilen-Lektüre von `sync` in den Vergleich von `check`,
  färbt er sich rot — dafür ist er da.
- **Jede Änderung an `harness/tools/tap-nachzug.sh` und `harness/tools/tap-nachzug-nutzlast.sh`** —
  **Schicht-Abgrenzung:** kein Produkt-Code. Ein Zahn, der den Wächter ändern müsste, um rot werden zu
  können, ist ein anderer Vorgang (§4, Rückführung).
- **Die übrigen Aussagen von Schritt 7, die mit `sync` altern** (der Nachzug als *„Handgriff"*, das
  *„einzige Tap-Ziel im Makefile"*, *„ein Nachzug von Hand hat diesen Schutz nicht"* und das Kommando
  `grep -ci version …` samt dem Satz *„Bytes, keine Versionen"*) — **Folge-Slice
  `slice-tap-nachzug-sync-schreibt-die-formel-ins-tap`**,
  Liefer-Punkt 3: der Umbau hängt am Ziel, das dort entsteht. Hier ändert sich allein der Satz, der das Ziel
  nicht braucht; das Kommando `grep -ci version …` gilt, solange `sync` fehlt, und bleibt stehen.
- **Ein Mutations-Fall je übrige `bats`-Zusage von `check`** — **Bestand bleibt bewusst stehen:** die 26 Fälle
  der Familie sind gemessen; ob eine weitere Zusage ohne Fall dasteht, ist die Klasse
  [`BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall`](../observations/BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall/observation.md)
  und braucht eine Inventur, nicht diesen Slice.
- **Der volle Lauf `make mutate`** — **anderer Vorgang:** er ist kein Gate und läuft nächtlich
  ([`harness/README.md`](../../../../harness/README.md) §Safety and scope boundaries); dieser Slice belegt seinen
  einen Fall einzeln (§2).

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [ ] **Liefer-Punkt 1 — der `bats`-Fall:** `test/tap-nachzug.bats` trägt einen Fall, dessen Name die
      Eigenschaft nennt (`check liest keine Version …`): Asset und Tap tragen **ungleiche Bytes**, die
      `version`-Zeile des Tap ist **größer** als die des Tags, `check` endet mit Exit 1, die Ausgabe nennt
      *Formel-Unterschied*, die letzte stderr-Zeile des Skripts ist `tap-check: Exit 1` (gelesen wird die
      Zeile, nicht der Prozess-Exit; [`ADR-0066`](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md)
      Festlegung 2). Der Fall ist auf unverändertem Code **grün**. **Rot, wenn:** der Vergleich die
      `version`-Zeilen liest und bei größerer Tap-Version mit Exit 0 endet — die Mutation der Kurzrunde. **Zusage,
      auf das Gebundene eingeschränkt:** gebunden ist *ungleiche Bytes, größere Tap-Version → Exit 1*; jede andere
      Form der Versions-Lektüre (kleinere Tap-Version, gleiche Version bei sonst ungleichen Bytes) bindet der Fall
      nicht, und der Name sagt es nicht anders.
- [ ] **Liefer-Punkt 2 — der Mutations-Fall samt Gegenprobe:** ein Fall in `test/mutations/` (Nummer, Name und
      Modus nach [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
      am Anlage-Ort gemessen, nicht aus diesem Plan übernommen) wendet die Mutation aus Liefer-Punkt 1 an
      (`# files:` die Nutzlast, `# verify: test-bats`, `# expect:` der Name des neuen `bats`-Falls). Der Fall
      färbt **genau diesen Fall** rot (`make test-bats`, die Ausgabe wird gelesen: `not ok <n>` trägt den
      Namen aus `# expect:`, sonst meldet der Treiber *„falscher Grund"*). **Gegenprobe — grün heißt bindet:**
      bei entferntem oder auf gleiche Versionen geschwächtem neuen `bats`-Fall bleibt `make test-bats` unter
      derselben Mutation **grün**; färbt ein **anderer** Fall sie dann rot, deckt ein anderer Zweig die Stelle,
      und der neue Zahn ist unbewacht. Der Fall wird einzeln bewiesen — über den Treiber, soweit er einen
      Einzelfall-Lauf führt, sonst mit dem Anker von Hand im Scratch-Zustand; der Report nennt den Weg.
      **Rot, wenn:** der Anker die Stelle nicht mehr trifft (`sed` ohne Wirkung) — der Fall wird gegen den
      **heutigen** Quell-Bestand der Nutzlast gemessen, auch wenn `slice-tap-nachzug-sync-schreibt-die-formel-ins-tap`
      sie vorher verändert hat.
- [ ] **Liefer-Punkt 3 — der Text trägt nur, was gebunden ist:** in
      [`docs/user/releasing.md`](../../../user/releasing.md) Schritt 7 (*Grenze*) ersetzt der Satz über den
      fehlenden Zahn (`grep -n 'der Zahn fehlt' docs/user/releasing.md`) die Aussage durch die, die Fall und
      Mutations-Fall aus Liefer-Punkt 1 und 2 tragen — mit der Einschränkung aus Liefer-Punkt 1 und dem
      Verweis auf den Fall nach Kennung (nicht nach Zeilennummer); die Zahl neben dem Kommando
      `grep -c '^@test' test/tap-nachzug.bats` wird neu gemessen. Der Rest des Absatzes bleibt (§1). **Rot,
      wenn:** der Text *„der Vergleich liest keine Version"* ohne die Einschränkung sagt, oder wenn
      `grep -n 'der Zahn fehlt' docs/user/releasing.md` nach dem Slice noch trifft, obwohl beide Fälle
      stehen. **Deckung, benannt:** kein Test und kein Gate hält `releasing.md` gegen die Fälle, die sie
      nennt — die Klasse führt das Register (§8); Träger ist der Review dieses Slice.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: entfällt über Liefer-Punkt 3 hinaus — `harness/README.md`, Handbuch und Makefile-Kommentar
      berühren die Eigenschaft nicht — der Implementer liest die Zeile `make tap-check` in
      `harness/README.md` und den Kommentar des Ziels im Makefile gegen sie; nennt eine von beiden sie,
      wird sie dort nachgezogen und der Punkt steht in §7.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Register-Datei nicht.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert. Erwartet: die Fälle, die der Review dieses Slice findet, und die Frage, ob die Zusage-Klasse aus §8 (`doku-zusage-nennt-den-test-…`) mit diesem Slice ihren Ausgang trägt.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)


Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `test/tap-nachzug.bats` | update | Liefer-Punkt 1: ein Fall — ungleiche Bytes, größere Tap-Version, Exit 1, Meldung, Zeile `tap-check: Exit 1`; die Fixture-Funktion für die Formel besteht (`formel <version>`), der Fall baut Asset und Tap daraus |
| `test/mutations/<nächste freie Nummer>-tap-check-liest-versionen-bei-ungleichen-bytes.sh` <!-- d-check:ignore (Datei entsteht mit diesem Slice) --> | neu | Liefer-Punkt 2: die Mutation in `gleich()` der Nutzlast; Nummer, Name-Familie und Modus aus dem Bestand gemessen |
| `docs/user/releasing.md` | update | Liefer-Punkt 3: der Satz über den fehlenden Zahn in Schritt 7 (*Grenze*) |

- **Messung vor dem Anlegen ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)):**
  `ls test/mutations | sort -n | tail -3` (Nummer), `git ls-files -s 'test/mutations/*tap-check*' | awk '{print $1}' | sort | uniq -c`
  (Modus der Familie; im Gesamtbestand `git ls-files -s 'test/mutations/*.sh' | awk '{print $1}' | sort | uniq -c`
  gemischt), und das `sed`-Muster gegen `harness/tools/tap-nachzug-nutzlast.sh` **am Anlage-Ort**: es trifft
  im Zweig *cmp meldet Unterschied* von `gleich()` genau eine Zeile (`sed -n '<Muster>p' … | wc -l` → 1).
- **Reihenfolge:** der `bats`-Fall zuerst und auf unverändertem Code grün → der Mutations-Fall, Rot gelesen →
  die Gegenprobe → der Text. Der Fall geht dem Text voraus: erst wenn er rot gesehen ist, darf die Doku sagen,
  dass er bindet.
- **Kein Produkt-Code.** Ändert die Arbeit `harness/tools/`, ist sie zu groß (§4).
- **Der Absatz *Grenze* in Schritt 7 hat zwei Nachbarn:** `slice-tap-nachzug-sync-schreibt-die-formel-ins-tap`
  schreibt den Satz über `grep -ci version` und den Vorwärts-Schutz derselben Stelle um. Es gibt keine
  Reihenfolge-Pflicht; wer als zweiter läuft, misst den Absatz an seinem Start neu und nimmt den Stand des
  ersten als Ausgangslage.

## 4. Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Vor `open` → `next`** (Priorisierung, Entscheidung des Auftraggebers): der bewegende Lauf misst nach
[`AGENTS.md`](../../../../AGENTS.md) §3.11 und
[`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 4, ob ein
eingefrorenes Artefakt diese Datei als Pfad nennt — über beide Adress-Formen (Code-Span-Pfad und
Markdown-Link). Der Befund am Tag des Schnitts: kein Artefakt nennt sie
(`grep -rnI --exclude-dir=.git --exclude-dir=.harness -E 'slice-tap-check-liest-keine-version-ist-gebunden\.md|open/slice-tap-check-liest-keine-version-ist-gebunden|\]\(slice-tap-check-liest-keine-version-ist-gebunden' . | grep -v 'planning/in-progress/slice-tap-check-liest-keine-version-ist-gebunden.md' | wc -l`
→ **0**, gemessen 2026-09-25 und vor dem Move erneut: **0**); die Kennung steht allein in der Datei des Nachbar-Slice `slice-tap-nachzug-sync-schreibt-die-formel-ins-tap` (`open/`, änderbar) als Text, in keinem eingefrorenen Artefakt.

**Start** (`next` → `in-progress`): `Verantwortlich:` gesetzt, WIP-Limit frei. Keine Abhängigkeit: der Slice
braucht weder `sync` noch ein Ziel; die Nutzlast, gegen die er den Anker misst, besteht
(`harness/tools/tap-nachzug-nutzlast.sh`).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): der neue Fall wird auf unverändertem Code nur
  grün oder die Mutation nur rot, wenn `harness/tools/tap-nachzug-nutzlast.sh` oder das Skript sich ändert
  (etwa weil der Stub `curl` die Fixture für ungleiche Bytes nicht durchreicht) — die Änderung am Werkzeug ist
  ein anderer Vorgang und ein eigener Slice; in diesem bleibt die Test-Hälfte.
- `in-progress` → `open` (blockiert): `slice-tap-nachzug-sync-schreibt-die-formel-ins-tap` liegt in
  `in-progress/` und ändert `gleich()` oder den Zweig, an dem der Anker sitzt — dann wartet dieser Slice auf
  dessen Ende und misst den Anker danach neu (§3).

## 5. Closure-Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: (1) `make test-bats` ist grün, und die Ausgabe der Mutation aus Liefer-Punkt 2
nennt genau den neuen Fall als `not ok`; dieselbe Mutation bleibt bei geschwächtem oder entferntem Fall
grün (die Gegenprobe). (2) `grep -n 'der Zahn fehlt' docs/user/releasing.md` trifft nicht mehr, und die Aussage
in Schritt 7 nennt Fall und Einschränkung; `make gates` ist grün. Dazu der Lerneintrag in §7 in einer der drei
Formen. **Was hier nicht zugesagt ist:** dass der Vergleich in *jeder* Form keine Version liest — gebunden ist
eine Form (Liefer-Punkt 1), und der Text sagt es.

## 6. Risiken und offene Punkte


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

Kein Risiko trägt hier schon seinen Ausgang; er wird bei der Closure zugewiesen, die Kandidaten stehen dabei.

- **Der Anker der Mutation ist nach `slice-tap-nachzug-sync-schreibt-die-formel-ins-tap` verschoben** — der
  Slice für `sync` erweitert die Nutzlast an der Stelle, an der `gleich()` liegt; ein früher angelegter
  `sed`-Anker trifft dann die falsche oder keine Zeile. **Ausgang:** Kandidat *weiter offen* →
  [`BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`](../observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/observation.md)
  (die Regel steht als
  [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand));
  *eingetreten* wäre ein Folge-Slice mit Kennung, wenn der Anker schon bei der Anlage nicht trifft.
- **Der Fall bindet nur die eine gemessene Form** (größere Tap-Version, ungleiche Bytes). Eine andere Form der
  Versions-Lektüre (kleinere Tap-Version, gleiche Version bei sonst ungleichen Bytes) färbt ihn nicht.
  **Ausgang:** Kandidat *entfallen* — die Zusage in Text und Name ist auf die gebundene Form eingeschränkt
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6: *die Zusage auf das einschränken, was der Code hält*); *weiter offen*,
  wenn der Review eine zweite Form als zusagenswert nennt →
  [`BEO-ALL/doku-zusage-nennt-den-test-dessen-fall-nur-einen-ausschnitt-misst`](../observations/BEO-ALL/doku-zusage-nennt-den-test-dessen-fall-nur-einen-ausschnitt-misst/observation.md).
- **Die Mutation färbt mehrere Fälle**, und der Fall nennt nur einen (`# expect:` nimmt einen Namen). Der
  Treiber prüft, ob der genannte Name unter den roten steht. **Ausgang:** Kandidat *entfallen* — die
  Gegenprobe aus Liefer-Punkt 2 trennt den neuen Fall von den anderen; die Klasse führt
  [`BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere`](../observations/BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere/observation.md)
  (Zähler in §8), ein Beleg wird dort nur eingetragen, wenn sie hier eintritt.

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

Wird bei der Closure geschrieben — von der Rolle Planner in frischem Kontext (AGENTS.md §3.10), nach Review und Verifikation, in der Form der Regeln oben.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist allein `*` (gesamtes Repo) — ein Test, ein
Mutations-Fall und ein Satz der Nutzer-Doku zum Release-Vorgang. Die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md) führt `*` als eigene Zeile; sie erfüllt die
Schwelle ≥ 2 von 3 Achsen, keine Zerlegung ist nötig. `harness/tools/` ist nicht berührt (§1, Schicht-Abgrenzung).

**Vorgelagert — offene Beobachtungen sichten:** Register gelesen am 2026-09-25 auf dem lokalen Stand (fünf
Commits vor `origin/main`, nichts gepusht; das Register ist beim Lesen so alt wie der letzte Merge). Sub-Area
aller Einträge ist `*`. Die Zähler-Stände sind die Zahl der Dateien unter dem `evidence/` des Eintrags
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`, gemessen 2026-09-25, keine
Erwartungswerte). Gesucht nach Zahn, Mutation, Zusage, Doku-Zusage, Prozedur-Wiedergabe. **Treffer:**

- [`BEO-ALL/doku-zusage-nennt-den-test-dessen-fall-nur-einen-ausschnitt-misst`](../observations/BEO-ALL/doku-zusage-nennt-den-test-dessen-fall-nur-einen-ausschnitt-misst/observation.md)
  — **1×**, `offen`. Der Gegenstand dieses Slice ist seine Instanz (Befund M-1 der Kurzrunde); der Slice
  heilt die Instanz und nicht die Klasse. Ein zweiter Beleg entsteht nur, wenn der Review dieses Slice eine
  zweite Doku-Zusage findet, deren genannter Test nur einen Ausschnitt misst. Unter der Schwelle.
- [`BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall`](../observations/BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall/observation.md)
  — **2×**, `offen`. Nachbar: dort fehlt der Mutations-Fall für eine Zusage, die ein Fall trifft; hier trifft
  der Fall die Eigenschaft nicht und der Slice liefert beides. Erhöht wird der Zähler durch diesen Slice nicht.
- [`BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`](../observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/observation.md)
  — **5×**, verkörpert als
  [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand);
  die Regel bindet die Anlage dieses Slice (§2, Liefer-Punkt 2; §3, Messung).
- [`BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere`](../observations/BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere/observation.md)
  — **1×**, `offen`. Risiko 3 in §6; unter der Schwelle.
- [`BEO-ALL/prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle`](../observations/BEO-ALL/prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle/observation.md)
  — **2×**, `offen`. Der Slice ändert einen Satz derselben Prozedur-Zeile; wird der neue Satz vom Review
  wieder als weiter reichend als seine Quelle gelesen, ist das der dritte Beleg — der Eintrag hätte mit diesem
  Slice **3×** und brauchte einen Ausgang bei dessen Closure (Lese-Schritt, Baseline-Regelwerk
  `modul-06-roadmap.md`).
- Gesichtet, kein Treffer für diesen Gegenstand: `zusage-nennt-sensor-der-form-nicht-sieht` (Skript- und
  Funktionsköpfe; hier steht die Zusage in Prosa), `negation-mitten-im-bats-fall-ohne-wirkung` (der neue Fall
  schreibt keine Negation mitten im Fall; die Regel dazu steht im Eintrag).

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

Alle berührten Sub-Areas GF (`*` steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md) als Greenfield) — kein BF/Hybrid-Block.


