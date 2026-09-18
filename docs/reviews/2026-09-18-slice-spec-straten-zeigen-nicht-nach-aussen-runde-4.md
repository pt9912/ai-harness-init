# Review-Report: `slice-spec-straten-zeigen-nicht-nach-aussen` — 2026-09-18, Runde 4

**Review-Art:** Code — geprüft wird **ein** Commit gegen seine eigene Commit-Message, gegen
`AGENTS.md` §3.6 und §3.7 und gegen die drei Findings meiner Runde 3. **Nicht** gegen die DoD: die
prüft der Verifier (Modul 11).

**Gegenstand:** `64517a2c` — die Antwort des Implementers auf R3-1, R3-2 und R3-3 des Reports
`627b47f6`. Runden 1–3 sind abgehandelt und **nicht** Gegenstand dieses Laufs. Der Gegenstand ist
eng: die **Behauptung** der Commit-Message zur Vereinigung und zur Isolation der zwei
Zusicherungen, die sie tragende Frage, ob der `else`-Umbau der Positions-Zusicherung ihre Zähne
nimmt, sowie der kleinere Mit-Gegenstand R3-3 (eine Zeile) und R3-2 (Meldungs-Fassung).

**Skill:** `.harness/skills/reviewer.md` v2.0.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** deepseek-v4.1-flash:cloud[1m] · **Datum:** 2026-09-18

> **Zitier-Form** *(Norm, kein Ausfüll-Hinweis)*. Dieser Report friert ein; was er zitiert,
> bewegt sich weiter. Deshalb **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine Baseline-Stelle
> als Tag + Pfad in Inline-Code (`v6.9.0` · `regelwerk/<datei>.md` §<Abschnitt>) statt als Link.
> Ortsfeste Ablagen stehen als Pfad (`AGENTS.md` §3.6). Die Reports der Runden 1–3 werden **nicht**
> nachgebessert; dieser tritt daneben. Die Findings dieses Laufs heißen `R4-*`.

**Eingangs-Kontext:**

- der Auftrag zu diesem Lauf (enger Gegenstand: allein `64517a2c`)
- der eigene Report der Runde 3 (`627b47f6`, R3-1 bis R3-3)
- die Commit-Message von `64517a2c` — sie trägt die Zusage, gegen die dieser Lauf misst
- `AGENTS.md` §3.6 · §3.7 · §3.9
- `MR-025` · `LH-FA-03` · `LH-QA-01`
- `v6.9.0` · `regelwerk/modul-11-verification.md` §Bewusstes Brechen für DoD-Testbehauptungen ·
  `v6.9.0` · `regelwerk/modul-13-quality-gates.md` §Fitness Function aus einem ADR-Satz
  (der Break-Test **und** der unveränderte Bestand, auf dem der Sensor schweigt)
- `harness/tools/mutate.sh` — seine Bedingungen 2, 3 und 4 (gegriffen · rot · rot am benannten
  Wächter) sind das Maß, an dem die Fälle hier gemessen werden

**Eigene Messungen.** Alle Läufe in einem Wegwerf-Klon des Repos unter `/tmp`, ausgecheckt auf
`64517a2c`, über `make test-go` — Docker-only (`AGENTS.md` §3.9), keine Host-Toolchain. Der
Arbeitsbaum dieses Repos wurde nicht angefasst; das Arbeitsverzeichnis des Klons war nach jedem
Messblock leer (`git status --porcelain` → keine Zeile). `make gates` über `64517a2c` ist vom
Auftraggeber belegt (EXIT 0) und hier **nicht** wiederholt. Der Mutations-Treiber hat **keinen**
Fall-Filter — je Lage wurde darum die Mutation direkt gefahren und ihre Rot-Form gelesen, dieselbe
Methode wie in Runde 3. Keine Zahl ist ein Erwartungswert (`MR-025` Setzung 2).

**Was ich zuerst prüfen musste: die Polarität der Gegenprobe.** Der Auftrag formuliert sie als
*„wenn `376` grün bleibt, ist die Zusicherung unbewacht"*. Das ist verkehrt herum, und die
Messung zeigt es: **ich** weite in dieser Probe das Muster (`"- {name: aussen,"` →
`"- {name: "`) — ich nehme den Zahn also selbst heraus. Grün danach heißt: der Fall hängt
**genau an diesem Zahn** (die Zusicherung trägt), nicht das Gegenteil. Rot danach hieße
umgekehrt, dass ein **anderer** Zweig den Fall fängt und der Fall die Zusicherung gar nicht
bindet. Ich habe deshalb beide Richtungen der Probe gefahren und lese sie in dieser Lesart; das
Ergebnis ist eindeutig und stützt die Commit-Message.

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| R4-1 | LOW | Die **Vorhandenseins**-Zusicherung ist von keinem gelisteten Fall **gebunden**: wehrt man ihre Klassen-Klausel ab (Bedingung immer falsch), bleibt der gelistete Fall `372` rot — nur über `emit_test.go:78`, also über die Positions-Prüfung; `make mutate` meldet `ok` und der verlorene Zahn bleibt unsichtbar. Ihre zweite Klausel (die Regel `{from: spec-straten, to: aussen, allow: false}`) hat überhaupt keinen gelisteten Fall: `372` und `376` sind die einzigen, die `aussen` nennen, und keiner davon ändert die Regel-Zeile. Gemessen ist, dass ein Mutant, der **nur** die Regel-Zeile entfernt, allein über `:73` rot färbt — die Zusicherung hat also echte Zähne, nur keinen Fall, der sie bindet. **Kein gelisteter Mutant entkommt** (alle vier gemessen rot, siehe Belege), die Aussage der Commit-Message ist damit nicht widerlegt; dies ist der symmetrische Rest zu R3-1 und **nicht** von `64517a2c` eingeführt. | `AGENTS.md` §3.6 (*„wer keinen Fall in `test/mutations/` hat, ist unbewacht"*) | `internal/emit/emit_test.go:71`–`:73` | ja — die Klassen-Klausel abwehren und `372` fahren: der Test fällt weiter über `:78` (in diesem Lauf gemessen) | neuer-waechter-ohne-mutations-fall |

**Warum LOW und nicht wie R3-1 MEDIUM.** Die zwei Lagen unterscheiden sich in drei gemessenen
Punkten, und nur der dritte trägt die Abstufung. Erstens hat die Vorhandenseins-Zusicherung einen
Fall, dessen Rot **ihre** Meldung ist (`372` → `:73`), während die Positions-Zusicherung vor R3-1
nur in einem Doppel-Rot (`:73` **und** `:76`) auftrat. Zweitens ist der Mutant, der sie binden
würde, gemessen und ungelistet — nicht inexistent. Drittens bleibt die Eigenschaft selbst hinter
dem Test doppelt gedeckt: der `matrix-aussen-Zahn` in `harness/tools/full-smoke.sh:882`–`:907`
verlangt, dass eine Referenz aus einem Spec-Stratum nach außen das `docs-check` im **Ziel** rot
färbt — ohne die Regel-Zeile täte er das nicht und der Zahn fiele. Der Verlust wäre damit einer an
der Unit-Ebene, keine offene Flanke im emittierten Vertrag. **Der Befund blockiert nicht.**

---

## Belege

### 1. Die tragende Frage — trägt jede der beiden Zusicherungen ihren Fall allein?

Fünf Läufe über `make test-go` im Klon, je Lage eine Zeile der Fall-Ausgabe (Form, die
`make mutate` als Rot liest: `--- FAIL: <Test>`), sonst nichts:

| Stand im Klon (`64517a2c`) | Exit | fallende Zusicherung(en) | anderer Test gefallen? |
|---|---|---|---|
| unverändert | `0` | — (kein `--- FAIL:` im Log) | nein |
| `372` (Klasse `aussen` entfernt) | `2` | `emit_test.go:73: die Klasse aussen oder ihre Regel aus spec-straten fehlt` | nein |
| `376` (`aussen` vor `adaptionsblock` gezogen) | `2` | `emit_test.go:78: aussen ist nicht die letzte Klasse in classes: (letzte ist "- {name: adaptionsblock, paths: [\"harness/conventions.md\", \"harness/conventions/**\"], token: 'MR-\\d{3}'}")` | nein |
| `375` (Welle-Pfad in die ADR-Zeile) | `2` | `emit_test.go:95: der Welle-Pfad wird in der emittierten Konfiguration genannt — …` | nein |
| Position-Muster auf `"- {name: "` geweitet, dann `376` | **`0`** | — (der Fall entkommt) | nein |
| Vorhandenseins-Klausel (Klassen-Zeile) abgewehrt, dann `372` | `2` | `emit_test.go:78` — **nicht** `:73` | nein |

Gelesen wurden die Logs mit
`grep -E 'emit_test\.go:[0-9]+:|redundant|\[build failed\]|--- FAIL:'` je Lauf;
`--- FAIL:` erschien in jedem roten Lauf **einmal** und nannte ausschließlich
`TestDCheckConfig_EntschiedeneModulListe`. Die Zuordnung der Zeilen zu den zwei Zweigen ist damit
belegt: `:73` gehört der Vorhandenseins-Prüfung (`64517a2c` Zeilen 71–73), `:78` der
Positions-Prüfung (Zeile 74–79). Der unveränderte Bestand schweigt — beide Zusicherungen sind
rot-gesehen **und** im Nicht-Verletzungsfall still (`v6.9.0` ·
`regelwerk/modul-13-quality-gates.md` §Fitness Function aus einem ADR-Satz, zweite Richtung).

**Die Vereinigung — die Behauptung der Commit-Message.** *„jede Mutation, die eine der beiden
bricht, färbt den Test rot."* Gemessen für drei disjunkte Verletzungs-Klassen: nur Vorhandensein
(`372` → `:73`), nur Ordnung (`376` → `:78`), nur die Regel-Zeile (eigener Lauf, unten → `:73`).
Ein Mutant, der **beide** bricht, kann nicht entkommen, weil beide Zweige `t.Errorf` rufen und der
`else` nur die zweite Meldung wegnimmt — das ist eine Folgerung aus der Struktur, **nicht**
gemessen. Die Behauptung hält.

### 2. Die Gegenprobe in beiden Richtungen, und was sie belegt

- **Positions-Bedingung** (`sed -i '74s/"- {name: aussen,"/"- {name: "/'` + `376`): Exit `0` —
  `376` entkommt. Der Fall hängt also **allein** an diesem Muster; mit intaktem Muster fällt er
  ausschließlich über `:78`. Damit ist die Zusicherung gebunden und der Umbau hat ihr **keine**
  Zähne genommen. Das ist die Antwort auf die tragende Frage dieses Laufs: **sie trägt.**
- **Vorhandenseins-Bedingung** (`sed -i '71s/.*/\tif false ||/'` + `372`): Exit `2`, gefallen
  über `:78`. Der Fall bleibt rot, obwohl die Klassen-Klausel der Prüfung weg ist — der `else`
  fängt den Mutanten. Genau das ist R4-1: die Vorhandenseins-Zusicherung ist nicht gebunden.
  Gedeckt wird sie der Meldung nach von `372`, den Zähnen nach von **keinem** gelisteten Fall.
- **Nur die Regel-Zeile entfernt** (kein gelisteter Fall, Sondierung dieses Laufs:
  `sed -i '/^    - {from: spec-straten, to: aussen, allow: false}$/d'` auf der Vorlage): Exit `2`,
  gefallen über `:73` **allein**. Die zweite Klausel hat also echte Zähne und ist der einzige
  Fänger dieses Mutanten — nur steht sie in keinem Fall:
  `grep -l 'to: aussen' test/mutations/*.sh` → **keine Datei** (kein Erwartungswert, der Bestand
  wandert); `grep -l 'name: aussen' test/mutations/*.sh` → `372`, `376`.
- **Ein verworfener Sondierungs-Lauf, benannt statt verschwiegen.** Ein erster Versuch, die
  Vorhandenseins-Bedingung *ganz* auszuschalten, war falsch gepolt (`if false ||` → `go vet:
  redundant or: false || false`, Abbruch als `[build failed]`; danach `!strings.Contains(yml,
  "SENTINEL-AUS")` — ein Zweig, der für **jede** Vorlage feuert). Beide Läufe sind damit **kein
  Beleg** für irgendetwas und wurden nicht in die Tabelle oben aufgenommen; die Aussage zu R4-1
  ruht auf den zwei Läufen darüber, die ein eindeutiges Ergebnis haben.

### 3. Der `else` selbst — was er verschluckt, und was nicht

Er verschluckt **Meldungen, keine Urteile**. Gemessen: `372` färbt heute nur `:73`; im Stand der
Runde 3 färbte derselbe Mutant `:73` **und** `:76`. Ein Zustand, in dem die Positions-Prüfung
etwas zu sagen hätte und gar nicht läuft, existiert: immer dann, wenn die Vorhandenseins-Prüfung
feuert. Ein Verlust an **Deckung** ist das nicht — jede der drei Verletzungs-Klassen bleibt rot
(Abschnitt 1) —, sondern einer an Diagnose: ein Mutant, der beide bricht, nennt jetzt eine Ursache.
Der neue Kommentar an `emit_test.go:75`–`:77` sagt genau das (*„Ordnung setzt Vorhandensein
voraus …"*) und adressiert den, der die Grenze **entfernt**; seine zweite Hälfte (*„eine zweite
Meldung derselben Ursache naehme dieser hier ihren eigenen Fall in `test/mutations/`"*) ist die
Grenz-Aussage, und sie ist durch die Messung der Runde 3 gedeckt. Kein Finding — geprüft, ohne
Befund (siehe Negativbefunde).

### 4. Mit-Gegenstand R3-3 — genau eine Zeile

`375` gegen den unveränderten Stand, gemessen über `diff` und `git diff --stat` im Klon:

```sh
git diff --stat          # internal/emit/templates/d-check.yml | 2 +-
                         # 1 file changed, 1 insertion(+), 1 deletion(-)
diff <vorher> <nachher>  # 13c13 — genau eine ersetzte Zeile
```

Die getroffene Zeile ist Zeile 13 (`- {regex: 'ADR-\d{4}', target: docs/plan/adr/, link-policy:
always}` → dieselbe Zeile mit angehängtem `exempt-paths`); die **auskommentierte**
Requirement-Beispielzeile mit demselben Anker bleibt unberührt — das war der Befund. Der
Kopfkommentar des Falls nennt jetzt *„an EINER anderen Position"* und *„jede Nennung des Pfades
faengt sie"*, und beides stimmt mit dem Muster und mit der Prüfung überein. **R3-3 aufgelöst.**
Zugleich belegt der Lauf die zwei Treiber-Bedingungen, die ein geändertes Muster treffen können:
die Mutation **greift** (Zeile 13 geändert) und sie färbt **am benannten Wächter** rot.

### 5. Mit-Gegenstand R3-2 — die Meldung sagt, was gemessen wird

Aus dem `375`-Lauf, wörtlich die neue Meldung:

```
emit_test.go:95: der Welle-Pfad wird in der emittierten Konfiguration genannt — auch eine
Nennung im Kommentar faengt diese Zusicherung, und als Ausnahme naehme er der Klasse welle
ihre Status-Deckung
```

Das `Contains` läuft über die ganze Datei einschließlich ihrer Kommentare. Der Satz nennt jetzt
(1) den **gemessenen** Zustand („wird genannt"), (2) ausdrücklich, dass eine Kommentar-Nennung
mitfällt, und (3) die Folge nur für den Ausnahme-Fall. Die frühere Behauptung *„an keiner Position
darf er die Status-Deckung … zuruecknehmen"* — die einem Kommentar eine Wirkung zuschrieb — ist
weg. Der Kopfkommentar von `375` trägt dieselbe Korrektur. **R3-2 aufgelöst.**

---

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Die zwei Zusicherungen, je Fall: unveränderter Bestand | geprüft, ohne Befund — `make test-go` über `64517a2c` Exit 0, kein `--- FAIL:` (Abschnitt 1) |
| `372` färbt **allein** `:73`; `376` färbt **allein** `:78`; kein anderer Go-Test fällt mit | geprüft, ohne Befund — je roter Lauf genau eine `--- FAIL:`-Zeile, immer `TestDCheckConfig_EntschiedeneModulListe`; die Assertion-Zeilen sind eindeutig einem Zweig zuzuordnen |
| Vereinigung der zwei Zweige („jede der beiden gebrochen → rot") | geprüft, ohne Befund — drei Verletzungs-Klassen gemessen rot; der Doppel-Bruch folgt aus der Struktur (beide Zweige rufen `t.Errorf`), ist als Folgerung gekennzeichnet, nicht als Messung ausgegeben |
| Positions-Bedingung: nimmt der `else` ihr die Zähne? | geprüft, ohne Befund — **nein**: mit intaktem Muster fällt `376` über `:78`, mit geweitetem Muster entkommt er. Die Zusicherung ist gebunden; die tragende Behauptung der Commit-Message hält |
| Der `else`-Zweig verschluckt eine Aussage, die noch etwas zu sagen hätte | geprüft, ohne Befund — er verschluckt die zweite Meldung, wenn die erste feuert; **keine** Verletzungs-Klasse wird dadurch grün (Abschnitt 3). Der Kommentar an `:75`–`:77` erklärt die Kopplung im Indikativ und adressiert den Änderenden (`AGENTS.md` §3.7) |
| Kopfkommentar `376` (*„First-Match heisst, dass eine nicht zuletzt stehende `**` jeder nachfolgenden Klasse ihre Dateien nimmt …"*) gegen `AGENTS.md` §3.7 | geprüft, ohne Befund — Kopplungs-Aussage über den Zustand, kein Lauf-Protokoll, keine Befund-Kennung, keine verworfene Alternative |
| Kopf-Form und Zähne des neuen Falls `376` | geprüft, ohne Befund — `# files:`/`# expect:` vorhanden, `100755`, die Mutation greift (Reihenfolge messbar geändert) und färbt den benannten Test aus dem benannten Grund (`make mutate` Bedingungen 2–4) |
| R3-3: geänderte Zeilenzahl von `375` | geprüft, ohne Befund — genau eine Zeile (`1 insertion(+), 1 deletion(-)`), die auskommentierte Beispielzeile bleibt stehen |
| R3-2: Meldung an `emit_test.go:95` gegen das, was das `Contains` misst | geprüft, ohne Befund — sie behauptet keine Wirkung einer Kommentar-Nennung mehr und nennt den gemessenen Zustand |
| Umfang von `64517a2c` gegen den Slice-Plan | geprüft, ohne Befund — drei Dateien (`emit_test.go`, die zwei Mutations-Fälle), keine Produkt-Code-Änderung außerhalb der Zusicherungen, keine Norm-Artefakte fremder Rollen, kein Markdown |
| Host-Toolchain im Diff | geprüft, ohne Befund — `sed`/`bash`, kein Paketmanager, keine Sprach-Toolchain (`AGENTS.md` §3.9) |
| Nachbar-Repo-Spuren (fremde Pfade, fremde Kennungen) | geprüft, ohne Befund — keine |

---

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 0 |

**Finding-Klassen dieses Laufs:** neuer-waechter-ohne-mutations-fall

**Zur Klassen-Häufung** (`v6.9.0` · `regelwerk/modul-10-review-harness.md` §Pflege, die der
Reviewer-Skill spiegelt): dieselbe Klasse trägt in diesem Slice jetzt **drei** Läufe — F-2 der
Runde 2, R3-1 der Runde 3, R4-1 hier. Der Skill verlangt bei dreimaligem Auftreten die Frage, ob
die **Kategorie** geschärft gehört; die Form, die die drei verbindet, ist präziser als „kein Fall":
*ein gelisteter Fall muss seine Zusicherung **binden** — nimmt man ihr den Zahn, muss er grün
werden; ein Fall, der auch ohne diese Zusicherung rot bliebe, deckt ihren Text und nicht ihre
Zähne.* Ob das eine geschärfte Skill-Zeile oder ein `AGENTS.md`-Zusatz wird, entscheidet nicht
dieser Report — er nennt die Klasse, die Zählung steht im Register bei der Closure §7.

## Verdikt

**Merge-blockierend: nein.** Die tragende Behauptung des Commits ist **gemessen** und hält:
`372` färbt allein `:73`, `376` allein `:78`, der unveränderte Bestand ist still, kein anderer Test
fällt mit, und der `else`-Umbau hat der Positions-Zusicherung **keine** Zähne genommen — mit
geweitetem Muster entkommt `376`, mit intaktem ist er der Fall, der sie bindet. Die Vereinigung ist
gegenüber dem Stand der Runde 3 unverändert: drei disjunkte Verletzungs-Klassen sind rot gesehen,
keine entkommt. R3-2 und R3-3 sind aufgelöst, beide gemessen (eine Zeile bzw. keine
Wirkungs-Behauptung mehr). Die vom Auftrag vorgegebene Lesart der Gegenprobe war in der Polarität
verkehrt — die Probe misst, ob der **Fall an seinem Zahn hängt**; ich habe sie so gelesen und die
Messung spricht für den Umbau.

**R4-1 (LOW) blockiert nicht.** Es ist der symmetrische Rest zu R3-1 an der *Vorhandenseins*-
Zusicherung: sie hat einen Fall, der ihre Meldung trägt, aber keinen, der ihre Zähne bindet, und
ihre Regel-Klausel steht in gar keinem Fall. Kein gelisteter Mutant entkommt; die Eigenschaft
bleibt hinter dem Test durch den `matrix-aussen-Zahn` des `full-smoke` gedeckt. Der Befund ist
**nicht** von `64517a2c` eingeführt und geht als Ermessen an den Implementer — er ist kein
Rückhalter für Verifikation und Closure.

**Frei für Verifikation und Closure.** Kein Implementer-Zug nötig, kein Planner-Zug; es liegt kein
Rollen-Konflikt vor und keine Entscheidung an, die den Architect bräuchte. Zwei Mitgaben in die
Closure: die **Finding-Klasse** dieses Laufs (dieselbe wie in den Runden 2 und 3, damit der Zähler
sie zusammenhält) und, bei der dritten Zählung, die Frage nach der geschärften Kategorie. Dieser
Report ist ein **Lauf-Beleg** und ersetzt keine Verifikation — DoD- und Spec-Konformität prüft der
Verifier separat (Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
