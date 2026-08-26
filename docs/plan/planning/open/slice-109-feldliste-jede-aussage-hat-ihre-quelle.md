# Slice slice-109: Jede Aussage der Feldliste hat ihre Quelle — die Frage je Feld steht einmal, und die Zutat über den Bestand wird zurückgeführt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Wartung am Wortlaut eines emittierten Artefakts, reaktiv). Die drei Fragen
aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, hier beantwortet: **(1) Bündel?** Nein — zwei Aussagen desselben Dokuments, eine Datei,
ein Schnitt; kein zweiter Slice wartet auf ihn. **(2) Gemeinsames Closure-Kriterium?** Nein — jedes
denkbare wäre die Abschrift seiner eigenen DoD. **(3) Auslöser reaktiv oder gewollt?** Reaktiv:
eine gemessene Doppelung und eine gemessen unrichtige Zutat (§1). Kein Fähigkeits-Sprung — der
Adopter bekommt dasselbe Dokument an derselben Stelle. **Auch nicht in
[welle-12](../welle-12-erfassungsschicht-emittieren.md):** deren Zeilen *„Redaktion"* und
*„Benannte Grenze"* sind mit
[slice-098](../done/slice-098-feldliste-ist-ausdruck-des-traegers.md) geliefert und bleiben
es — dieser Slice ändert den **Wortlaut** zweier Aussagen, nicht die Frage, ob das Kriterium
erfüllt ist. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: der emittierte Text — und deshalb kein Kosmetik-Schnitt.** Was hier steht, liegt im Repo
jedes Adopters, ist **konvergent** (ein Re-Lauf schreibt es neu) und wird von ihm nicht geheilt.
Eine unrichtige Tatsachenbehauptung darin ist keine Ungenauigkeit in unserem Baum, sondern eine in
seinem.

**Bezug:**
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (**Rang 1** —
§Redaktion trägt den dritten Grenz-Satz wörtlich: *„Ausdrücklich nicht zugesagt ist, dass
Pfadnamen unkritisch sind, und dass der Bestand geschützt ist — er ist gitignored, nicht
verschlüsselt und nicht zugriffsbeschränkt."* Die Zutat aus §1 steht dort **nicht**),
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) (**Accepted** — Festlegung 1 macht
[`spec/spezifikation.md`](../../../../spec/spezifikation.md) §5 zum **Rang-2**-Zielort derselben
Tatsache: was ein Feld bedeutet und welche Incident-Frage es beantwortet),
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (**Accepted** —
Festlegung 7: das Dokument wird **aus dem Träger erzeugt**; Festlegung 6 Stück 3 verlangt den
dritten Satz als *geschrieben*. Dieser Slice ändert an beiden nichts, er löst ein, was sie über
die Herkunft sagen),
[`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
(der Eintrag, der die Feldtabelle ins Technik-Stratum gezogen hat — und der für dessen vierte
Spalte selbst misst, dass sie **Feedforward** ist: kein Gate hält sie),
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) (die
Konstruktion, die für eine der Antworten auf Frage A schon einmal gewählt wurde: tool-generiert,
verbatim),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (eine Zusage ist erst fertig, wenn ihr Gegenbeispiel rot
gesehen wurde — die Regel, an der DoD (1) hängt),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das genau sie liefert),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(Verortung).

**Autor:** Planner. **Datum:** 2026-08-26.

---

## 1. Ziel

**Was die Feldliste im Zielrepo sagt, sagt genau eine Quelle in diesem Repo: die Frage je Feld
steht einmal statt zweimal, und kein Satz behauptet über den Bestand mehr, als der Träger tut.**

### (A) Die Frage je Feld steht zweimal, und die zwei Fassungen driften bereits

Die **Mengen** sind konstruktiv gehalten: `SchemaFields()` liest den `Span`-Typ, und ein Feld ohne
Eintrag bricht die Erzeugung ab — dafür gibt es zwei Wächter und zwei Fälle
([slice-098](../done/slice-098-feldliste-ist-ausdruck-des-traegers.md) DoD (1)). Der
**Wortlaut** ist an nichts gebunden. Zwei Bestände, zwei Kommandos:

- `grep -c '{Field: "' internal/span/fieldlist.go` → **32** Einträge im Träger.
- `sed -n '/^| Feld | Pflicht | Incident-Frage | Sensor |/,/^$/p' spec/spezifikation.md | grep -c '^| \`'`
  → **26** Datenzeilen in §5; sechs davon führen **zwei** Feld-Literale in der ersten Spalte
  (`… | grep '^| \`' | awk -F'|' '{n=gsub(/\`[a-z_0-9]+\`/,"&",$2); if(n>1) c++} END{print c}'`
  → **6**), zusammen also dieselben **32** Felder in **anderer** Gliederung.

Die Divergenz ist keine Vermutung, sondern an einer Zeile abzulesen:
`grep -n '{Field: "seq"' internal/span/fieldlist.go` → *„Fehlt eine **Zeile**? — je Strom vergeben
und steigend, damit eine Lücke **sichtbar wird**"*; `grep -n '^| \`seq\`' spec/spezifikation.md` →
*„**Fehlt ein Span?** — je Strom monoton steigend, damit der **Leser** eine Lücke sieht"*.
Dieselbe Tatsache, zwei Formulierungen, und
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) Festlegung 1 macht §5 zum
**Rang-2**-Zielort genau dieser Tatsache.

**Kein Sensor hält sie zusammen.** Keine Go-Stelle liest die §5-Tabelle dieses Repos:
`grep -rn 'spezifikation' --include='*.go' internal/ cmd/ | grep -vE '^\S+:[0-9]+:\s*(//|\*)'` →
**3** Treffer, alle über den **emittierten** Vorlagen- bzw. Zieldateinamen
(die Vorlage `spezifikation.template.md` und `spec/spezifikation.md` als Name in einer Ziel-Liste),
keiner über ihrem Inhalt. Und die Spalte, die §5 zusätzlich führt, ist selbst als Feedforward gemessen
([`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
§Sensor, und seine Grenze) — es gibt hier also nicht einen starken und einen schwachen Ort,
sondern zwei ungebundene.

### (B) Ein Satz behauptet über den Bestand mehr, als der Träger tut

Der dritte Grenz-Satz trägt eine **Zutat**, die seine Quelle nicht hat:
`grep -n 'Arbeitsverzeichnis lesen kann' --include='*.go' --include='*.sh' -r .` → **1** Treffer
([`internal/span/fieldlist.go`](../../../../internal/span/fieldlist.go), Zeile **132**) — *„wer
dieses Arbeitsverzeichnis lesen kann, liest ihn"*. Gemessen am Bestand, den derselbe Träger
schreibt:

- `stat -c '%a' .harness/state/spans` → **755** für das Verzeichnis;
- `stat -c '%a' .harness/state/spans/*.jsonl | sort | uniq -c` → **221**× **600**, ausnahmslos;
- und der Modus ist **gesetzt**, nicht geerbt: `grep -c '0o600' internal/span/emit.go` → **6**
  Stellen, darunter ein ausdrückliches `Chmod` nach dem Öffnen.

Wer das Arbeitsverzeichnis lesen kann, liest den Bestand also gerade **nicht**, wenn er nicht der
Eigentümer ist. Die Richtung des Fehlers ist die sichere — der Satz sagt **weniger** Schutz zu, als
besteht —, aber es ist eine nachprüfbare Tatsachenbehauptung in einem fremden Repo, und sie stimmt
nicht.

**Der einzige Treffer ist zugleich der Befund über die Bewachung:** die Zutat steht in **keinem**
Wächter. `TestFeldliste_GrenzeUeberDenBestand` hält fünf Textstücke (*„Über den Bestand ist nichts
zugesagt"*, `**gitignored**`, `**nicht verschlüsselt**`, `**nicht zugriffsbeschränkt**`,
`**Pfadnamen sind nicht als unkritisch zugesagt**`), und der Voll-E2E-Sensor prüft leerraum-
normalisiert nur den Satzkopf
(`sed -n '/for satz in/,/done/p' harness/tools/full-smoke.sh | grep -c '"Über den Bestand ist nichts zugesagt"'`
→ **1**). Die Zutat fällt also aus dem Dokument, ohne einen Sensor zu bewegen — genau die
Eigenschaft, die sie unrichtig werden ließ.

**Was ausdrücklich bleibt: die Nicht-Zusage selbst.** Sie steht wörtlich auf Rang 1; dieser Slice
führt die **Zutat** zurück, nicht den Satz.

### Die Frage vor dem Code: wer leitet von wem ab

Sie entscheidet den Schnitt, nicht den Stil, und gehört beantwortet, bevor die erste Zeile fällt:

| # | Frage | Warum sie den Schnitt entscheidet |
|---|---|---|
| A | **Wird §5 aus dem Träger erzeugt, oder hält ein Wächter die zwei Fassungen gegeneinander?** | *Erzeugt* (Vorbild [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)) schließt die Drift konstruktiv aus, verlangt aber, dass die **Gliederung** fällt: **26** Zeilen werden **32**, und die vierte Spalte — die Sensor-Bindung — bleibt Hand-Arbeit und muss die Erzeugung überleben. *Verglichen* lässt §5, wie es ist, und kostet einen Parser über einer Markdown-Tabelle, der bei unbekannter Zeilenform **fail-closed** fallen muss, sonst misst er über einer leeren Menge ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) |
| B | **Trägt der Träger die Fragen weiter, oder wandern sie ganz nach §5?** | Ein `go:embed` über einer Doku-Datei machte das Produkt-Binär von `spec/` abhängig — die stärkste Kopplung und die teuerste: der Träger wird ins Ziel **kopiert**, und was er einbettet, geht mit. Diese Antwort ist zulässig, aber sie ist eine Aussage über die Bauform des Trägers und gehört begründet, nicht nebenbei |

## 2. Definition of Done

Zwei slice-eigene Punkte (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6). Wo kein Kommando einen Punkt rot färbt, steht das
dabei, statt sich hinter einem anderen zu verstecken.

- [ ] **(1) Die Incident-Frage je Feld ist an eine Quelle gebunden — ein Eingriff in genau eine
      der zwei Fassungen färbt rot.** Ob die Bindung eine Erzeugung oder ein Vergleich ist,
      entscheidet Frage A aus §1, und die Antwort steht mit ihrer Begründung im Plan. Nach dem Lauf
      gilt für **jedes** der 32 Felder, dass seine Frage in beiden Fassungen dieselbe Aussage
      trägt — nicht nur für die Stichprobe aus §1.
      **Rot:** `make test` — dazu ein `test/mutations/`-Fall, der die Frage **eines** Feldes in
      **einer** Fassung ändert und das Rot erwartet. Heute existiert dieser Sensor nicht: keine
      Go-Stelle liest §5 (`grep -rn 'spezifikation' --include='*.go' internal/ cmd/ | grep -vE '^\S+:[0-9]+:\s*(//|\*)'`
      → **3**, alle über Dateinamen der emittierten Ebene).
- [ ] **(2) Kein Satz des Dokuments behauptet über den Bestand mehr, als der Träger tut — die
      Zutat fällt oder wird messbar. Beides ist zulässig, Schweigen nicht.**
      *Fällt sie*, färbt **kein** Kommando das rot, und das steht dann so da: der Satz sagt danach
      genau, was
      [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)
      §Redaktion sagt, und eine Nicht-Zusage hat keine Bruchstelle. *Wird sie messbar* — etwa als
      Aussage über den Modus, den der Träger setzt —, bekommt sie ihren Wächter gegen genau diesen
      Modus, plus einen `test/mutations/`-Fall, der ihn aufweitet.
      **Unverändert bleibt die Nicht-Zusage selbst**, vorher wie nachher:
      `b=<scratch>/bin/ai-harness-init; p=$(mktemp -d); (cd "$p" && "$b" --name probe >/dev/null); grep -c 'nicht zugriffsbeschränkt' "$p/harness/erfassung-feldliste.md"`
      → **1**.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Doku-Update, falls ein öffentlicher Vertrag berührt ist · Closure-Notiz mit
Steering-Loop-Lerneintrag. **Der Doku-Punkt ist hier nicht leer:** das emittierte Dokument **ist**
ein Adopter-Vertrag, und bei Antwort *erzeugt* auf Frage A ändert sich zusätzlich die Struktur von
[`spec/spezifikation.md`](../../../../spec/spezifikation.md) §5.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`internal/span/fieldlist.go`](../../../../internal/span/fieldlist.go) — `SchemaNotes()` | update | DoD (1): die Hand-Tabelle ist die eine Seite der Kopplung; welche Richtung sie bekommt, entscheidet Frage A |
| [`internal/span/fieldlist.go`](../../../../internal/span/fieldlist.go) — `limitStore` | update | DoD (2): die Zutat steht in dieser einen Konstante (§1, ein Treffer im ganzen Baum) |
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md) §5 | update, **soweit Frage A es verlangt** | [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) Festlegung 1 — der Rang-2-Zielort derselben Tatsache. Bei Antwort *erzeugt* fällt die Gruppierung (26 → 32 Zeilen), die **vierte Spalte bleibt Hand-Arbeit** und muss die Erzeugung überleben ([`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)) |
| [`internal/span/fieldlist_test.go`](../../../../internal/span/fieldlist_test.go), [`internal/emit/fieldlist_test.go`](../../../../internal/emit/fieldlist_test.go) | update | DoD (1) braucht einen neuen Wächter; DoD (2) berührt `TestFeldliste_GrenzeUeberDenBestand` **nur**, wenn die Zutat messbar wird — die fünf Textstücke, die er heute hält, enthalten sie nicht (§1) |
| `test/mutations/` — ein Fall für DoD (1), einer für DoD (2), soweit sie ein Rot haben <!-- d-check:ignore (geplante Dateien) --> | neu | [`AGENTS.md`](../../../../AGENTS.md) §3.6: wer keinen Fall hat, gilt als unbewacht. Nummern beim Anlegen neu auszählen (`ls -1 test/mutations/*.sh \| wc -l` → **165**, mitwandernd) |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | **unverändert** | er prüft leerraum-normalisiert nur die drei Satz**köpfe** (§1); die Zutat liegt außerhalb seines Vergleichs |
| [`spec/lastenheft.md`](../../../../spec/lastenheft.md) | **unverändert** | Rang 1 trägt den Satz wörtlich; keine interne Quelle ändert `LH-*` ([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)) |
| [`docs/plan/adr`](../../adr) | **unverändert** | beide Punkte **führen aus**, was [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) und [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) bereits sagen; eine *Accepted*-ADR wird gelesen, nicht ergänzt ([`AGENTS.md`](../../../../AGENTS.md) §3.4) |
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | **unverändert** | wellenlose Arbeit wird dort nicht geführt ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 2/3) |

**Die Ist-Messung gehört vor die Kopplung.** Wieviele der **32** Fragen sagen heute in beiden
Fassungen dasselbe, und wieviele nicht? Die Antwort entscheidet, ob DoD (1) ein Angleichen von zwei
Zeilen ist oder von dreißig — und ein Angleichen von dreißig ist ein anderer Schnitt (§4). Die
Stichprobe aus §1 zeigt **eine** Divergenz; das ist eine Untergrenze, kein Befund über die Menge.

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): nichts blockiert ihn außer dem WIP-Limit — und das ist
der Termin, den dieser Slice trägt.** Beide Fassungen liegen im Baum, die Messungen aus §1 gelten
über ihm, Frage A und B sind ohne Vorarbeit eines anderen Slice entscheidbar. Er wartet
insbesondere **nicht** auf die Closure von
[welle-12](../welle-12-erfassungsschicht-emittieren.md) und **nicht** auf
[slice-108](slice-108-feldlisten-waechter-tragen-ihren-fall.md): jener gibt bestehenden Wächtern
ihre Fälle, dieser ändert den Text, den sie halten. Laufen sie in beliebiger Reihenfolge, kostet
die zweite Runde einen Abgleich der berührten Fall-Köpfe — sie brechen einander nicht.

**Was dieser Slice ausdrücklich nicht ist: eine Nennung.** Beide Befunde sind in einer Review- und
einer Verifikations-Runde gemessen und benannt worden; ein Träger ohne Termin ist in diesem Repo
dreimal vergeben und nullmal eingelöst worden
([slice-101](slice-101-norm-postens-bekommen-einen-termin.md) §1, dort mit Kommando).

Die zwei Rückführungen, vorab benannt:

- **`in-progress` → `next` (zu groß):** wenn die Ist-Messung aus §3 zeigt, dass ein großer Teil
  der **32** Fragen inhaltlich auseinanderläuft. Dann sind es zwei Slices — einer, der die
  Kopplung baut, und einer, der die Fassungen angleicht; ein Lauf, der beides tut, entscheidet
  dreißig Formulierungen nebenbei.
- **`in-progress` → `open` (blockiert):** wenn Antwort *erzeugt* auf Frage A die vierte Spalte von
  §5 nicht tragen kann. Dann steht eine Entscheidung über die **Form** des Rang-2-Zielorts aus, und
  die gehört vor den Architect, statt an
  [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) vorbei gebaut zu werden.

## 5. Closure-Trigger

DoD (1) und (2) erfüllt mit gefahrenen Kommandos; Frage A und B mit ihrer Begründung im Plan
beantwortet; `make gates` grün; `make full-smoke` grün über beide Bootstrap-Varianten (das Dokument
ändert seine Bytes, und der Voll-E2E-Sensor liest es); `make mutate` grün einschließlich jedes
neuen Falls; Review konform (Modul 10); Verifikation bestätigt (Modul 11); `git mv` nach `done/`
als eigener Move-Commit; Closure-Notiz mit Steering-Loop-Eintrag in einer der drei Formen
(geschärfte Regel · neuer Sensor · benannte Spec-Lücke).

## 6. Risiken und offene Punkte

- **Eine Kopplung kann zirkulär werden, und dann misst sie nichts.** Wer §5 aus dem Träger erzeugt
  **und** den Wächter gegen die erzeugte Datei hält, vergleicht zwei Ausgaben derselben Funktion —
  dieselbe Bauart, die [slice-096](../done/slice-096-traeger-liegt-im-ziel.md) §7 schon einmal
  gemessen hat. Der Prüfpunkt: **an welchen zwei verschiedenen Artefakten** der Vergleich hängt.
- **Die vierte Spalte von §5 ist der teuerste Teil und der leiseste.** Sie bindet je Zeile einen
  Wächter, und kein Gate hält sie
  ([`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  misst das mit fünf Sonden). Eine Erzeugung, die sie überschreibt, löscht eine Bindung, die
  niemand vermisst — der teuerste Fehler dieses Schnitts.
- **Der Wortlaut zweier Fassungen anzugleichen heißt, einen davon zu wählen.** Die Fassung im
  Träger geht ins Repo des Adopters, die in §5 ist für uns. Wer sie zusammenzieht, schreibt
  entweder Adopter-Sprache in ein normatives Dokument oder Repo-Sprache in ein fremdes — das ist
  eine Leser-Entscheidung und gehört in die Antwort auf Frage A, nicht in den Diff.
- **DoD (2) hat einen Ausgang ohne Rot, und das ist keine Ausrede, sondern die Sache.** Eine
  gestrichene Behauptung hat keine Bruchstelle. Der Beleg dafür ist negativ und gehört so in die
  Closure-Notiz: welches Kommando **vorher** den alten Text lieferte und danach nichts.
- **Zwei Sätze des Dokuments beginnen mit derselben Wendung und sind zwei Verträge.**
  `b=$PWD/.harness/state/bin/ai-harness-init; p=$(mktemp -d); (cd "$p" && "$b" --name probe >/dev/null); grep -c 'erneuter Lauf' "$p/harness/erfassung-feldliste.md"`
  → **2**. Der erste ist die **Konvergenz-Zusage über das Dokument** (bewacht von
  `TestFeldliste_Konvergent` und `test/mutations/172`), der zweite sagt konditional etwas über die
  **Wiederablage des Trägers** (*„sobald ein erneuter Lauf des Werkzeugs das Programm wieder
  ablegt"*) und liegt im Vertrag von
  [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 1/5,
  also bei [slice-096](../done/slice-096-traeger-liegt-im-ziel.md). Wer an diesen Sätzen arbeitet,
  zieht sie **nicht** zusammen: der eine ist eine Zusage über eine Datei, der andere eine Bedingung
  über ein Programm.
- **`make gates` sieht den Gegenstand nur zum Teil.** Der Doku-Gate prüft Kennungen, Anker und
  Pfade; zwei Fassungen derselben Aussage sind grün, und eine unrichtige Tatsachenbehauptung in
  einem emittierten Text ebenfalls. Was hier grün wird, ist der neue Wächter aus DoD (1).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `internal/span/`, `spec/`
und `test/` gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
