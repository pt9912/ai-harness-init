# Slice slice-spec-straten-zeigen-nicht-nach-aussen: Die Spec-Straten zeigen nicht nach außen, und das Doku-Gate hält das im Dogfood und im Ziel

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Der Test aus Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine
Welle braucht fällt negativ aus: `make gates` und `make full-smoke` stehen in §2, und keine
Closure-Bedingung beobachtet mehr als diese DoD.

**Bezug:**
[`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7)
(die Doc-Gate-Startkonfiguration geht ins Ziel),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`MR-001`](../../../../harness/conventions.md#mr-001) (Schärfung des `matrix`-Moduls),
[`MR-054`](../../../../harness/conventions.md#mr-054) (Kriterien für das emittierte Doc-Gate),
[`MR-017`](../../../../harness/conventions.md#mr-017) (emittierte Prüfbereiche fail-closed).

**Berührte Spec-Stellen:** `spezifikation.md §5` · `architecture.md §5`: Dort liegen die
Fundstellen der Sonde (§1). Je Datei trägt die Änderung ihren eigenen Träger (DoD 1).

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-09-17.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Die drei Spec-Straten haben keine Referenz nach außen, weder als Link noch als bloße
`MR-`- oder `ADR-`-Kennung. `make docs-check` hält das im Dogfood, und das emittierte Doku-Gate
trägt dieselbe Regel, ohne dass ein frisch gebootstrapptes Ziel rot startet. `MR`- und
ADR-Einträge dürfen weiter auf die Spec zeigen. Auftrag des Auftraggebers vom 2026-09-16; der
Slice übernimmt dabei den Review-Befund F-5 zu `slice-sprung-auf-v690-wird-vollzogen`: Nach dem
Entfernen der Links verweisen Sätze der Spezifikation noch auf „das Modul", ohne dass ein Bezug
dasteht.

### Die Sonde

Gefahren an einer Wegwerf-Kopie des Arbeitsbaums am Stand `c6d2f731`, mit d-check `v0.74.1` als
Messstand. Der gepinnte Stand ist ein anderer —
`grep -nE '^DCHECK_(IMAGE|DIGEST)' d-check.mk` nennt ihn, und die Umsetzung misst an ihm neu;
jede Zahl dieses Abschnitts hängt am Messstand. Die Änderung am `matrix:`-Block von
[`.d-check.yml`](../../../../.d-check.yml) umfasst drei Zeilen:

```yaml
    - {name: aussen, paths: ["**"]}                      # letzte Klasse, First-Match
    - {from: spec-straten, to: aussen, allow: false}     # neue Regel
  exempt-paths: ["docs/plan/adr/README.md", "docs/plan/planning/done/**"]
```

**Warum `exempt-paths`:** Die Status-Prüfung trifft jede klassifizierte Quelle, unabhängig von
den Regeln (d-check `DC-FA-MTX-001.a`). Ohne die Zeile meldeten der ADR-Index und eine
Welle-Datei unter `done/` in der Sonde vom 2026-09-16 `matrix-inactive`.

### Drei Schärfungen am selben Block — gemessen an diesem Baum

Die Klasse `aussen: ["**"]` ist die **letzte** und fängt alles, was keine frühere Klasse fängt.
Damit wird zweierlei tragend, was es vorher nicht war: die **Genauigkeit** der früheren Klassen
(wer zu weit greift, nimmt der letzten ihre Dateien) und die **Fläche** der Status-Prüfung (ab
jetzt ist jede Datei des Repos eine klassifizierte Quelle). Die drei Punkte unten folgen daraus
und gehören in Liefer-Punkt 1 und 3, nicht in einen vierten.

**1 — Die Klasse `slice` greift über den Lifecycle hinaus.** Sie steht auf
`docs/plan/planning/**/slice-*.md`; `**` überquert `/`-Grenzen:

```sh
find docs/plan/planning -name 'slice-*.md' | wc -l                                            # 681
find docs/plan/planning/{open,next,in-progress,done} -maxdepth 1 -name 'slice-*.md' | wc -l   # 281
find docs/plan/planning/done -mindepth 2 -maxdepth 2 -name 'slice-*.md' | wc -l               #   0
find docs/plan/planning -name 'slice-*.md' | grep -c '/observations/'                         # 400
```

**Keine Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025)) — alle vier
wandern mit dem Baum. 400 der 681 Treffer liegen in
`observations/<slug>/evidence/slice-<Kennung>.md`: Beleg-Dateien, deren Name die Kennung ihres
Vorgangs **ist** ([`ADR-0034`](../../../../docs/plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)),
keine Slice-Pläne. Die enge Fassung nennt die vier Lifecycle-Verzeichnisse ausdrücklich und eine
Ebene darunter für archivierte Stubs (`done/<welle-id>/slice-*.md`) — heute die leere Menge, s.
die dritte Zeile oben, und darum eine Zusage nach vorn statt eines Befunds.

**Sie hängt an einer Eigenschaft des Werkzeugs, die die Umsetzung misst:** dass `*` **keine**
`/`-Grenze überquert, `**` aber schon. Trifft das am gepinnten Stand nicht zu, trägt die enge
Fassung nicht, und das ist der Befund — nicht das Motiv, sie wegzulassen.

**2 — Eine bloße Kennung im Fließtext fängt kein Link-Sensor.** Das Kennungs-Muster je Klasse
(`token:`) ist am gepinnten Stand verfügbar und in der emittierten Hälfte in Gebrauch:

```sh
grep -c 'token:' internal/emit/templates/d-check.yml   # 2
grep -c 'token:' .d-check.yml                          # 0
```

Im Bestand der drei Straten steht heute **keine** solche Kennung:

```sh
grep -nE '(MR-[0-9]{3}|ADR-[0-9]{4})' spec/lastenheft.md spec/spezifikation.md spec/architecture.md \
  | grep -vcE '\]\('                                   # 0
```

Der Sensor zielt deshalb nicht auf den Bestand, sondern auf den Zustand **nach** Liefer-Punkt 1:
Wer die Referenz entfernt und die Kennung als Text stehen lässt, erfüllt die Zeile „die Aussage
bleibt, die Referenz fällt" dem Buchstaben nach, und eine Regel über Links sieht das Ergebnis
nicht. Das ist die Lücke, die Liefer-Punkt 3 entscheidet.

**3 — Der Grund einer Ausnahme steht an der Ausnahme.** Mit `aussen: ["**"]` wird auch
`docs/reviews/*.md` klassifizierte Quelle. Ein Review-Report nennt den zum Laufzeitpunkt aktiven
Stand dauerhaft — seine Einfrierung ist **zeitlich, nicht status-basiert**:

```sh
SUP=$(grep -l '^\*\*Status:\*\* \(Superseded\|Deprecated\)' docs/plan/adr/[0-9]*.md | sed 's|.*/||;s|\.md$||')
for a in $SUP; do grep -rl "$a" docs/reviews/; done | sort -u | wc -l   # 5
ls docs/reviews/*.md | wc -l                                           # 481
```

5 von 481 Reports nennen heute eine ADR, die inzwischen `Superseded` ist; **keine
Erwartungswerte**, und die linke Zahl kann nur steigen, weil Supersession einseitig ist. Die
Ausnahme trägt ihre Begründung als Kommentar an ihrer Zeile, nicht in einem Absatz daneben.

**Ergebnis:** `d-check: 1522 Datei(en) geprüft, 13 Befund(e)`, alle `matrix-forbidden`
(`grep -c matrix-forbidden <ausgabe>`), 12 in `spec/spezifikation.md` und 1 in
`spec/architecture.md`, kein `matrix-inactive`. Die Fundstellen liefert
`grep matrix-forbidden <ausgabe> | cut -f1,2`. Nach Ziel geordnet:

| Ziel der Referenz | Fundstellen |
|---|---|
| Adaptions-Block (`harness/conventions.md`, zwei `MR`-Anker) | 2 — je 1 in `spezifikation.md` und `architecture.md` |
| Carveout `CO-002` | 5 |
| `docs/user/claude-hooks-referenz.md` | 3 |
| `docs/reviews/**` | 2 |
| `AGENTS.md` | 1 |

**Gegenprobe:** Mit einem angehängten Link aus `spec/architecture.md` auf den ADR-Index steigt
die Zahl auf 14, und die neue Zeile lautet
`Referenz spec-straten → aussen ist nicht erlaubt`. Die Ausnahme in `exempt-paths` macht den
Index also nicht zu einem erlaubten Ziel. Die zwölf Links in den vendored Baum, die die Sonde
vom 2026-09-16 noch zählte, hat der Sprung-Slice schon entfernt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Historie des Lastenhefts im Dogfood bleibt ausgenommen** (`exclude-sections`). *Bestand
  bleibt bewusst stehen:* Das Lastenheft ändert sich nur per Change Request des Auftraggebers.
  Das emittierte Template nimmt `Historie` nicht aus; was daraus im Ziel folgt, misst DoD 2.
- **Der Abschnitt über die erklärten Abweichungen vom Observability-Modul in
  `spec/spezifikation.md` wird nicht in den Adaptions-Block verlegt.** *Anderer Vorgang einer
  anderen Rolle:* Den Adaptions-Block schreibt der Architect
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Dieser Slice entfernt dort nur die Referenzen;
  ob der Abschnitt umzieht, entscheidet der Architect vor dem Start (§4).
- **Keine Gliederungs-Änderung an `spec/spezifikation.md`.** *Ein Folge-Slice übernimmt sie:*
  `slice-gliederung-der-instanzen-ohne-vorlagen-delta` (Überschneidung an derselben Datei, §6).
- **Keine Festlegung, welche Rolle die Spec-Straten schreibt.** *Ein Folge-Slice übernimmt sie:*
  `slice-151-spec-straten-haben-eine-schreibende-rolle` (§6, Risiko 4).
- **Die Gegenrichtung bleibt offen:** Verweise aus `MR`- und ADR-Einträgen auf die Spec bleiben
  erlaubt. *Anderer Vorgang*, so beauftragt.
- **Kein Referenz-Ventil (`ignore-refs`) für eine Fundstelle.** *Anderer Vorgang:* Jedes Paar
  ist eine Senkung mit eigener ADR ([`AGENTS.md`](../../../../AGENTS.md) §3.5 und §3.11).
- **Keine Verbots-Regel, deren Quelle ein Planungs-Artefakt ist.** Auf der **Dogfood**-Ebene fügt
  der Slice **eine** Regel hinzu, auf der **Emissions**-Ebene **zwei** — `spec-straten → aussen`
  und `spec-straten → adaptionsblock`, den zweiten Weg gibt DoD 3 frei. Tragend ist nicht ihre
  Zahl, sondern ihre **Quelle**: jede nennt `spec-straten`; `slice`, `welle` und die Beleg-Dateien
  des Registers bleiben Quellen ohne Regel. *Schicht-Abgrenzung:* Die Achse dieses Slice ist die
  **Spec**, nicht der Planungs-Baum. Eine Regel wie *„ein Slice nennt keinen Review-Report"*
  läge auf der anderen Achse und träfe hier den Normalfall statt des Fehlers — gemessen:

  ```sh
  grep -rlE 'reviews/[0-9]{4}-[0-9]{2}-[0-9]{2}-[^ )`]*\.md' docs/plan/planning --include='slice-*.md' \
    | grep -vc '/observations/'   # 73
  grep -rlE 'reviews/[0-9]{4}-[0-9]{2}-[0-9]{2}-[^ )`]*\.md' docs/plan/planning --include='welle-*.md' | wc -l   # 4
  ```

  **Keine Erwartungswerte.** Gezählt ist die **Fläche**, nicht das Urteil: Ob ein solcher Verweis
  das Selbst-Zitat des eigenen Reports ist, entscheidet der Dateiname nicht — er trägt Datum,
  Kennung und Rollen-Suffix in Formen, die sich nicht durchgängig auf den Plan-Namen abbilden
  lassen. Eine Zahl für „davon Selbst-Zitat" stünde hier als Muster, das kein Kriterium ist
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Die Klassen-Enge aus §1, Schärfung 1 ist von
  diesem Ausschluss unberührt: Sie ist **Abgrenzung** — welche Datei welcher Klasse gehört —,
  kein Verbot.

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

**Zwei Ebenen, und sie fallen nicht zusammen.** Liefer-Punkt 1 ist **Dogfood** — die
Konfiguration dieses Repos und sein Spec-Bestand; er wirkt hier und nirgends sonst.
Liefer-Punkt 2 ist **Produkt-Arbeit** — was das Werkzeug in ein fremdes Repo schreibt
([`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7)); dort
bindet zusätzlich [`MR-054`](../../../../harness/conventions.md#mr-054) und die fail-closed-Regel
[`MR-017`](../../../../harness/conventions.md#mr-017), und sein Bestand ist nicht dieser Baum,
sondern ein frisch gebootstrapptes Ziel. Liefer-Punkt 3 hat auf **beiden** Ebenen eine Hälfte und
sagt je Ebene, welche. Eine Messung an der einen Ebene ist keine Aussage über die andere
(Register `emittierter-stand-laeuft-dem-dogfood-voraus`, §8).

- [x] **1 — Im Dogfood steht die Regel, der Block ist genau, und der Bestand hält beides.**
      - Der `matrix:`-Block in [`.d-check.yml`](../../../../.d-check.yml) trägt die drei Zeilen
        aus §1.
      - Die Klasse `slice` steht auf ausdrücklichen Pfaden statt auf `**` (§1, Schärfung 1). Dass
        `*` keine `/`-Grenze überquert, ist am gepinnten Stand **gemessen**, nicht angenommen;
        die Differenz `681 → 281` ist nach der Änderung mit demselben Kommando nachgewiesen.
      - `exempt-paths` nimmt `docs/reviews/*.md` auf und trägt seine Begründung als Kommentar an
        der Zeile (§1, Schärfung 3).
      - Jede Fundstelle der Sonde ist aufgelöst: Die Aussage bleibt, die Referenz fällt
        (Setzung des Auftraggebers vom 2026-09-16). Das gilt auch für die zwei `MR`-Nennungen in
        §5 und die Rückbezüge ohne Ziel aus F-5.
      - `make docs-check` meldet `0 Befund(e)`.
      - Je Spec-Stratum trägt die Änderung ihren eigenen Träger: `spezifikation.md` eine Zeile
        in §7 Historie, `architecture.md` den Frische-Marker `**Letzte Änderung:**` im Kopf auf
        dem Datum der Änderung. Die Architektur-Sicht führt **keine** Historie — die Ziel-Form
        des Sicht-Stratums nennt dort allein dieses Feld
        ([`modul-03-spec.md`](../../../../.harness/baseline/v6.9.0/regelwerk/modul-03-spec.md#ziel-form-architektur-sicht)
        §Ziel-Form: Architektur-Sicht).
      - **Rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6): Ein Link aus einem
        Spec-Stratum auf den ADR-Index färbt `matrix-forbidden`, und die Meldung nennt die neue
        Regel. Das Kommando steht im Umsetzungs-Commit.
- [x] **2 — Die emittierte Regel geht ins Ziel, und das Ziel startet grün.** Produkt-Ebene:
      geprüft wird am gebootstrappten Ziel, nicht an diesem Baum.
      - `internal/emit/templates/d-check.yml` trägt Klasse und Regel; der Kopfkommentar des
        `matrix`-Blocks nennt die neue Position.
      - Die Klassen `slice` und `welle` des Templates stehen beide auf `**`
        (`grep -c '\*\*/\(slice\|welle\)-\*\.md' internal/emit/templates/d-check.yml` → `2`, die
        Zeilen nennt `grep -n`). Ob die enge Fassung aus Schärfung 1 mitreist, ist **entschieden
        und begründet**: Das Ziel bekommt denselben Planning-Lifecycle, aber seinen
        Register-Bestand baut es selbst auf — eine Zusage über seine Dateizahl wäre hier nicht
        messbar ([`MR-055`](../../../../harness/conventions.md#mr-055)). Die Entscheidung steht
        als Kommentar im Template, nicht nur im Commit.
      - `make full-smoke` ist grün, das Ziel startet also grün.
      - Eine Referenz aus einem Spec-Stratum des Ziels auf eine Datei außerhalb färbt das
        emittierte Gate rot, rot gesehen, im E2E oder als Fall in `make test`.
      - Ob die Historie im Ziel ausgenommen wird, ist gemessen und nicht angenommen.
- [x] **3 — Für bloße Kennungen ist entschieden, wer sie fängt, und die Entscheidung ist
      belegt.** Möglich sind zwei Wege:
      - `token`-Klassen für `MR-` und `ADR-` (d-check `DC-FA-MTX-003`). Der Mechanismus ist am
        gepinnten Stand verfügbar und in der emittierten Hälfte in Gebrauch (§1, Schärfung 2).
        Für `ADR-` trägt ihn die vorhandene Klasse `adr`. Für `MR-` gibt es heute **keine
        Klasse**: Die Einträge liegen unter `harness/conventions/`, und `aussen: ["**"]` kann kein
        Muster tragen, das nur sie meint — dieser Weg verlangt also eine eigene Klasse für den
        Adaptions-Block, vor `aussen` einsortiert.
      - oder der Nachweis, dass `ids` mit `link-policy: always` die bloße Kennung in einem
        Spec-Stratum schon fängt. So begründet das emittierte Template heute, warum dort kein
        `ADR`-Token steht.

      Auf beiden Ebenen gilt dasselbe, und je Ebene eigens: Eine bloße `MR-`-Kennung in einem
      Spec-Stratum ist **rot gesehen** — im Dogfood gegen diesen Baum, in der Emission gegen ein
      Ziel. Der Bestand liefert das Gegenbeispiel nicht (§1, Schärfung 2: heute `0`); es wird
      hergestellt.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md)
      nennt beim Modul `matrix` die neue Klasse und ihre Grenze.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

**Dogfood-Ebene** — wirkt in diesem Repo:

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`.d-check.yml`](../../../../.d-check.yml) (`matrix:`) | update | Klasse `aussen`, Regel, `exempt-paths` samt Begründung an der Zeile, enge Pfad-Liste für `slice` (DoD 1) |
| `spec/spezifikation.md` §5, §7 | update | zwölf Fundstellen, Rückbezüge aus F-5, Historie-Zeile |
| `spec/architecture.md` §5, Kopf | update | eine Fundstelle, Frische-Marker `**Letzte Änderung:**` (DoD 1) |
| `test/mutations/` | neu, falls der neue Wächter ein Test ist | Register `neuer-waechter-ohne-mutations-fall` (§8) |
| [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) | update | Modul `matrix`: neue Klasse, die enge Pfad-Liste und ihre Grenze |

**Produkt-Ebene** — wirkt in einem fremden Repo, Bestand ist dort und nicht hier:

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/d-check.yml` | update | Klasse, Regel, Kopfkommentar; Entscheidung zur Pfad-Enge von `slice`/`welle` als Kommentar (DoD 2) |
| Test der emittierten Konfiguration (die Datei nennt der Implementer) | update | [`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7): Regel vorhanden, Gegenbeispiel rot |
| `harness/tools/full-smoke.sh` | update, falls das Gegenbeispiel im E2E läuft | [`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7): der Beleg wird am Ziel genommen, nicht an diesem Baum |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Das WIP-Limit ist frei, und ein Architect-Verdikt liegt als
Artefakt vor. Es beantwortet drei Fragen:

- **(a)** Bindet [`MR-054`](../../../../harness/conventions.md#mr-054) auch eine
  **Regel**-Änderung in einem Modul, das im emittierten Gate schon aktiv ist, oder nur die
  Aufnahme eines Moduls?
- **(b)** Ist `exempt-paths` eine Senkung nach [`AGENTS.md`](../../../../AGENTS.md) §3.5? Die
  drei Pfade — ADR-Index, `done/**`, `docs/reviews/*.md` — sind heute keiner Klasse zugeordnet,
  die Ausnahme nimmt ihnen also nichts, was sie heute tragen. Die Frage gilt für alle drei
  zugleich; die Zahlen dazu stehen in §1, Schärfung 3.
- **(c)** Bleibt der Abweichungs-Abschnitt in der Spezifikation, oder wandert er in den
  Adaptions-Block?

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Mehr als die Hälfte der Fundstellen
  lässt sich nicht durch bloßes Entfernen der Referenz auflösen, weil die Aussage ohne ihre
  Quelle umformuliert werden muss. Dann werden Dogfood (DoD 1) und Emission (DoD 2 und 3)
  getrennt geschnitten.
- `in-progress` → `open` (blockiert — Carveout?): Eine von zwei Bedingungen genügt.
  - `make full-smoke` wird mit der emittierten Regel rot, weil eine vendored Spec-Vorlage im
    Ziel eine Referenz nach außen trägt, die das Ziel nicht ändern darf. Die Entscheidung liegt
    dann beim Architect.
  - Oder der gepinnte d-check kann die Regel nicht ausdrücken. Das ist dann eine Anforderung an
    das Nachbar-Repo, keine Grenze.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. Mit aktiver Regel meldet `make docs-check` `0 Befund(e)`, und die Gegenprobe aus DoD 1 ist rot
   gesehen.
2. Mit der emittierten Regel ist `make full-smoke` grün, und das Gegenbeispiel aus DoD 2 ist rot
   gesehen.

Dazu kommt ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

1. **Eine Aussage trägt ohne ihre Quelle nicht.** Wer nur die Referenz entfernt, lässt einen
   Rückbezug ohne Ziel stehen (F-5), und wer umformuliert, kann die Aussage verschieben.
   *Absehbar:* entfallen, wenn je Fundstelle die Aussage ohne Quelle geprüft ist; sonst
   eingetreten, mit Beleg in `umschrift-eines-zitats-aendert-die-aussage`. — **Ausgang:**
   **entfallen.** Die Gegenprobe aus DoD 1 ist gefahren: alle Fundstellen der Sonde sind aufgelöst,
   die Rückbezugs-Formen ohne Ziel (`wie dort`, `siehe dort`, `ebenda`) treffen in beiden Straten
   keine Zeile mehr, und jede Aussage, die ihre einzige Quelle im Verweis hatte, ist auf das
   zurückgeschnitten, was sie ohne sie hält. Kein Beleg in
   `umschrift-eines-zitats-aendert-die-aussage` — die Beobachtung ist nicht eingetreten.
2. **Das emittierte Gate startet rot.** Nimmt das Template `Historie` nicht aus und trägt eine
   Spec-Vorlage dort eine Referenz nach außen, ist ein frisches Ziel rot. *Absehbar:* entfallen,
   wenn `make full-smoke` grün ist; sonst eingetreten, Rückführung nach `open`. — **Ausgang:**
   **entfallen.** `make full-smoke` ist grün; Beleg ist der CI-Lauf über den gepushten Stamm
   (`eea3a34c`): die Jobs `gates`, `smoke` und `full-smoke` grün, die zwei neuen Zähne im
   `full-smoke`-Log belegt. Die Rückführung nach `open` ist damit nicht gezogen.
3. **Zwei Slices greifen an dieselbe Datei:** Dieser und
   `slice-gliederung-der-instanzen-ohne-vorlagen-delta` ändern `spec/spezifikation.md`. Das ist
   hier genannt, nicht aufgelöst. *Absehbar:* entfallen, wenn beide nacheinander laufen. —
   **Ausgang: entfallen.** Der Nachbar liegt in `open/` und hat `in-progress/` nie betreten; die
   zwei Vorgänge haben sich nicht überlappt, und `spec/spezifikation.md` trägt allein die
   Änderungen dieses Slice. Der Nachbar bleibt die Adresse für die Gliederungs-Änderung.
4. **Für die Spec-Straten benennt keine Quelle die schreibende Rolle.** Die Setzung vom
   2026-09-16 ließ die Verweise den Implementer im Sprung-Slice nachziehen; ob sie auch hier
   gilt, sagt sie nicht. `slice-151-spec-straten-haben-eine-schreibende-rolle` ist die Adresse.
   *Absehbar:* entfallen, wenn `slice-151` vorher schließt oder der Auftraggeber setzt; sonst
   eingetreten, mit Beleg in `eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`.
   — **Ausgang: eingetreten.** `slice-151-spec-straten-haben-eine-schreibende-rolle` liegt in
   `open/` (Kopf `Verantwortlich: — bis zur Priorisierung`), und eine Setzung des Auftraggebers für
   diese zwei Straten steht nicht im Baum. Geschrieben sind sie trotzdem: der laufende Vorgang hat
   die Frage durch Tun beantwortet. Beleg in
   `eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet` — sein Zähler erreicht damit
   3×, und der fünfte Re-Evaluierungs-Trigger von
   [`ADR-0048`](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) ist eingetreten
   (Trigger-Audit in §7).
5. **`exempt-paths` wird als Senkung gelesen, ohne ihr Gate-Verhalten zu messen.** *Absehbar:*
   entfallen durch Start-Frage (b) und die Gegenprobe aus §1; sonst eingetreten, mit Beleg in
   `senkungs-pruefung-misst-die-menge-statt-des-gate-verhaltens`. — **Ausgang: entfallen.** Die
   Start-Frage (b) ist als Architect-Verdikt beantwortet, und sie beantwortet sie über das
   Gate-Verhalten statt über die Menge: für den ADR-Index und die Review-Reports *keine Senkung*,
   für die weite `done/**`-Fassung *Senkung* — und die ist darum **nicht** geliefert. Die
   Gegenprobe aus §1 misst zusätzlich, dass die Ausnahme aus der Status-Prüfung nimmt und nicht aus
   den Regeln. Beleg in `senkungs-pruefung-misst-die-menge-statt-des-gate-verhaltens`.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

- **Was hat funktioniert:** Die zwei Ebenen sind getrennt geliefert und getrennt gemessen — Dogfood
  am eigenen Baum, Emission am gebootstrappten Ziel über den `full-smoke`-Lauf —, und keine Aussage
  reicht weiter als ihr Sensor. Die Vorab-Sonde aus §1 hat den Schnitt getragen: die Fundstellen
  waren gezählt, bevor die erste geändert wurde, und der Umfang ist nicht gewachsen. Die drei
  Start-Fragen lagen vor der ersten Zeile Code als Architect-Verdikt vor; die dritte hat den
  Abweichungs-Abschnitt an seinem Ort gehalten, statt einen Umzug in den Adaptions-Block
  anzunehmen, und die zweite hat die weite `done/**`-Fassung der Ausnahme rechtzeitig verworfen.

- **Was ging anders als geplant:** Zwei Punkte, beide benannt statt stillschweigend absorbiert.
  Erstens ist die Dogfood-Ausnahme für die Review-Reports als `docs/reviews/**` geliefert, während
  §1 und DoD 1 `docs/reviews/*.md` nennen. Auf diesem Baum sind die zwei Formen deckungsgleich — es
  gibt kein Unterverzeichnis —, die Lieferung erfüllt den Punkt also, ohne ihm etwas hinzuzufügen.
  Der Plan-Wortlaut wird **nicht** nachgezogen: die weitere Form zur Deckung zu bringen hieße, eine
  Ausnahme nachträglich zu weiten, und eine geweitete Ausnahme ist eine Senkung nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5 — kein Plan-Text-Zug. Das Gate-Verhalten der Ausnahme
  ist dabei gemessen: sie nimmt aus der **Status**-Prüfung, nicht aus den Regeln
  ([`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) nennt die Grenze
  beim Modul `matrix`). Zweitens hat der **Trigger-Audit** einen fälligen ADR-Trigger ergeben:
  Risiko 4 ist eingetreten, sein Beleg hebt den Zähler von
  `eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet` auf 3×, und damit ist der
  fünfte Re-Evaluierungs-Trigger von
  [`ADR-0048`](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) eingetreten. Er
  verlangt, die Frage als allgemeine Regel zu entscheiden statt ein weiteres Mal je
  Artefaktklasse — das ist eine ADR-Frage und damit Architect-Arbeit, kein Closure-Schritt.
  Adresse: eine Folge-ADR zum Eigentum an Text-Artefakten, für die keine Quelle eine schreibende
  Rolle nennt.

- **Steering-Loop-Eintrag — benannte Spec-Lücke:** *Eine Prosa-Rückverweisung ohne Link und ohne
  Kennung bleibt in jedem Stratum grün.* Die neue Decken-Regel fängt zwei Formen — den Link über
  die Regel `spec-straten → aussen`, die bloße Kennung über `token:` bzw. `ids`. Ein Satz wie *„wie
  in der Nutzer-Doku beschrieben"* trägt weder noch; er ist die Form, die dieser Vorgang
  handwerklich geschlossen hat (die Rückbezüge sind umgeschrieben, nicht nur entlinkt), mechanisch
  aber nicht. Ein Sensor darauf existiert nicht, und das Lastenheft führt keine Anforderung, die
  ihn verlangt; das Baseline-Regelwerk nennt den Fall (`v6.9.0` ·
  `regelwerk/modul-11-verification.md` §Fitness Function ohne Standard-Tool). **Weitergereicht,
  nicht hier gelöst:** Ein Slice, der den Sensor baut, existiert nicht und wird hier nicht
  angelegt — sein Gegenstand ist eine Anforderungs- und Sensor-Entscheidung außerhalb dieses
  Vorgangs.

- **Beobachtungs-Register (`../observations/`):** Drei Belege angelegt, alle unter `BEO-ALL`:
  `evidence/slice-spec-straten-zeigen-nicht-nach-aussen.md` in
  `neuer-waechter-ohne-mutations-fall` (die Finding-Klasse dieses Vorgangs, in seinen drei
  Review-Läufen unter demselben Namen geführt), in
  `eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet` (Risiko 4) und in
  `senkungs-pruefung-misst-die-menge-statt-des-gate-verhaltens` (Risiko 5). Kein Zähler wird
  gesetzt, er folgt aus den Dateien —
  `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l` gibt für die drei
  **10 · 3 · 2**. Am Eintrag `spec-aenderung-ohne-historie-zeile` ist der Geltungsbereich in
  `state.md` verengt; ein Beleg entsteht dort nicht, weil die Beobachtung in diesem Vorgang nicht
  aufgetreten ist.

- **Folge-Slices:** `slice-151-spec-straten-haben-eine-schreibende-rolle` (die Adresse für die
  schreibende Rolle der Spec-Straten, Risiko 4) und
  `slice-gliederung-der-instanzen-ohne-vorlagen-delta` (die Gliederungs-Änderung an
  `spec/spezifikation.md`) — beide sind Dateien in `open/`. **Kein neuer Folge-Slice entsteht aus
  diesem Vorgang.** Die wiederkehrende Finding-Klasse `neuer-waechter-ohne-mutations-fall` hat eine
  geschärfte Kategorie ergeben — *ein gelisteter Fall muss seine Zusicherung binden; nimmt man ihr
  den Zahn, muss er grün werden* —, und ihr Zielort gehört nicht hierher: `AGENTS.md` §3.6 schreibt
  der Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8), eine Zeile in
  `.harness/skills/reviewer.md` die Rolle, die sie ausführt. Das ist Norm-Arbeit und wird hier
  benannt, nicht ausgeführt.

- **Risiken aus §6:** **1 entfallen · 2 entfallen · 3 entfallen · 4 eingetreten · 5 entfallen.**
  Begründung und Beleg stehen an jedem Risiko; die vier entfallenen tragen keinen Register-Beleg,
  der eingetretene (4) und der Befund zu 5 je einen.

- **Drei Paarungen** (nach dem `git mv` gefahren): **Anker** — kein Eintrag dieses Vorgangs
  deklariert einen Zielort; der Lerneintrag ist eine benannte Spec-Lücke und damit ohne Feld
  verkörpert, also kein Gegenstand der Paarung. **Folge-Slice** — beide genannten Kennungen liegen als Dateien
  im Planning-Lifecycle (`open/`). **Register** — jeder genannte Eintrag existiert als Verzeichnis,
  und jeder in diesem Vorgang entstandene Beleg steht in einem solchen. **Rot, und darum benannt:**
  Zwei Einträge tragen kein nicht-leeres `evidence/` —
  `einstiegs-datei-weicht-von-der-pflichtgliederung-ab` (Verzeichnis fehlt) und
  `planungs-bestand-waechst-schneller-als-er-abgebaut-wird` (Verzeichnis leer). Beide liegen
  **vor** diesem Vorgang und sind von ihm nicht verursacht; der erste nennt seinen Zustand selbst
  (*„Ohne Beleg, in der Form, die die Ablage verlangt"*), und für beide ist
  `slice-beleglose-register-eintraege-bekommen-eine-lesart` die Adresse — eine Datei in `open/`.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area, `*` (gesamtes Repo). Der
Slice ändert `spec/`, `.d-check.yml`, `internal/emit/` und `harness/sensors/`, und keine engere
deklarierte Sub-Area umschließt das. `harness/tools/` (`TOOLS`) ist nur berührt, wenn das
Gegenbeispiel im E2E läuft. `.codex/` (`CODEX`) ist nicht berührt.

**Vorgelagert — offene Beobachtungen sichten:** Alle Einträge führen die Sub-Area `*`, gesichtet
ist deshalb nach Gegenstand. Den Zähler je Treffer liefert
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, den Stand die erste Zeile
der `state.md`; keine der Zahlen ist ein Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| `neuer-waechter-ohne-mutations-fall` | 8 | verkörpert | die neue Regel ist ein Wächter (§3, `test/mutations/`) |
| `zusage-ohne-herstellbares-gegenbeispiel` | 3 | verkörpert | DoD 1 bis 3 verlangen je ein rot gesehenes Gegenbeispiel |
| `slice-plan-umfang-waechst-ueber-umsetzung-hinaus` | 3 | geplant, `slice-plan-umfang-bleibt-beim-gegenstand` | dieser Plan |
| `umschrift-eines-zitats-aendert-die-aussage` | 1 | offen | §6, Risiko 1 |
| `spec-aenderung-ohne-historie-zeile` | 1 | offen | DoD 1 verlangt je Spec-Stratum seinen Träger |
| `eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet` | 1 | offen | §6, Risiko 4 |
| `senkungs-pruefung-misst-die-menge-statt-des-gate-verhaltens` | 1 | offen | §6, Risiko 5 |
| `gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang` | 1 | offen | DoD-Update in `harness/sensors/docs-check.md` nennt die Grenze der Regel |
| `emittierter-stand-laeuft-dem-dogfood-voraus` | 1 | offen | DoD 1 und 2 ziehen beide Ebenen zugleich |

**Kein Eintrag erreicht mit diesem Slice absehbar 3×.** Die drei Einträge mit mindestens drei
Belegen tragen `verkörpert` oder `geplant`, und die genannte Kennung liegt als Datei in `open/`.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
