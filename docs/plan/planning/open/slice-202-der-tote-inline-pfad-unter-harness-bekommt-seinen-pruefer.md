# Slice slice-202: Der tote Inline-Pfad unter `.harness/` bekommt seinen Prüfer

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Slice ändert den Prüfbereich **eines** Gate-Moduls; sein Beleg ist ein
Gegenbeispiel-Paar und ein grüner Gate-Lauf, und beides steht in seiner eigenen DoD
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (der
tragende Vertrag: die benannte Grenze, die
[slice-201](../in-progress/slice-201-codepaths-erreicht-den-vendored-baum-nicht.md) in
[`harness/README.md`](../../../../harness/README.md) §Sensors gesetzt hat, ist die Adresse, die
dieser Slice einlöst),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (jede Klassifikation
einer Fundstelle steht neben dem Kommando, das sie ausgibt),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(Gate-**Anheben** ist ein Steering-Loop, kein ADR — [`AGENTS.md`](../../../../AGENTS.md) §3.5
bindet Senkungen, und jede Ausnahme aus Liefer-Punkt 2 ist eine),
[`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)
(die `codepaths`-Ventile und ihre Wachstums-Klausel),
[`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(eine Aussage über die Baseline nennt den Tag, gegen den sie gemessen ist — genau diese Form
erzeugt einen Teil des Bestands aus Liefer-Punkt 1),
[`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) (die Apparatur für die
**Link**-Form von drei einfrierenden Bäumen; dieser Slice baut ihr Gegenstück für die
**Inline**-Form),
[`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
(die Prüfbereichs-Frage einer emittierten Gate-Konfiguration ist eine andere Ebene und hier nicht
berührt)

**Berührte Spec-Stellen:** `—`. Der Prüfbereich eines Gate-Moduls ist in
[`spec/spezifikation.md`](../../../../spec/spezifikation.md) nicht festgelegt.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-08.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Ein toter Pfad unter `.harness/`, geschrieben als **Inline-Code** in einem **lebenden**
Artefakt, färbt `codepath-missing` — und jede Fundstelle, die trotzdem stumm bleiben soll, ist
eine einzeln benannte, einzeln gemessene Ausnahme statt einer pauschalen Wurzel-Auslassung.

**Der Ausgangsstand ist gemessen, nicht vermutet.**
[slice-201](../in-progress/slice-201-codepaths-erreicht-den-vendored-baum-nicht.md) hat die Ursache
belegt — `codepaths.roots` vergleicht Präfix-Zeichenketten, und `.harness` beginnt nicht mit
`harness` — und den Ausgang *benannte Grenze* gewählt, weil die naheliegende Reparatur über hundert
Befunde erzeugt, die keine Bugs sind. Der Bestand, den ein Prüfer vorfindet, steht neben dem
Kommando, das ihn ausgibt (Digest aus [`d-check.mk`](../../../../d-check.mk), netzlos, Kopie
außerhalb des Arbeitsbaums):

```sh
DIGEST=$(grep -oE 'DCHECK_DIGEST \?= sha256:[0-9a-f]+' d-check.mk | cut -d' ' -f3)
git clone --local --no-hardlinks . /tmp/probe-202
sed -i 's/roots: \[spec, docs, harness\]/roots: [spec, docs, harness, .harness]/' /tmp/probe-202/.d-check.yml
docker run --rm --network none -v /tmp/probe-202:/repo:ro "ghcr.io/pt9912/d-check@${DIGEST}" > /tmp/lauf202.txt
grep -c codepath-missing /tmp/lauf202.txt                                                   # 128
grep codepath-missing /tmp/lauf202.txt \
  | grep -v '^docs/plan/planning/done/' | grep -v '^docs/plan/adr/' | grep -v '/evidence/' \
  | grep -v '^harness/conventions/' | awk -F'\t' '$2 !~ /^\.harness\/(state|cache)/' \
  | grep -v 'does-not-exist-201' | grep -v '\$(BASELINE_TAG)' | awk -F'\t' '{print $1" -> "$2}'   # 12 Zeilen
```

**Keine Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — beide Zahlen wandern mit dem Bestand. Die zwölf Zeilen der zweiten Ausgabe liegen
sämtlich in **lebenden** Artefakten (laufende Roadmap, vier offene Slice-Pläne, drei flache
Welle-Pläne, eine Skill-Datei) und zerfallen in drei Formen, die **nicht** dasselbe verlangen:
ein Pfad in den vendored Baum unter einem **abgelösten** Tag ist als *Mess-Operand* richtig und
als *Adresse* tot; ein Pfad auf eine Datei, die das Werkzeug in jedes Zielrepo emittiert und die
dieses Repo selbst nicht führt, ist eine Dogfood-Lücke mit eigener Adresse; ein Pfad auf eine
Vorlage, die es nicht gibt, ist schlicht falsch. **Diese Unterscheidung ist die Arbeit**, nicht
das Aufnehmen einer vierten Wurzel.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Dogfood-Lücke selbst.** Dass dieses Repo die zweite Reviewer-Skill-Datei nicht führt,
  während das Werkzeug sie in jedes Zielrepo emittiert, ist ein eigener Vorgang mit eigener
  Adresse: die Kandidaten-Zeile *„Regeln ohne Feedback-Quadrant schließen — Rest-Achsen"* unter
  *Nächste Wellen* in [`roadmap.md`](../in-progress/roadmap.md), Achse (6, Skill-Hälfte). Dieser
  Slice macht den toten Pfad **sichtbar**; er legt die Datei nicht an. Ein Slice, der beides täte,
  entschiede über ein Rollen-Artefakt des Reviewers mit
  ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)).
- **Der Prüfbereich außerhalb von `.harness/`.** Dieselbe `roots`-Lücke trifft `internal/`, `cmd/`
  und `test/`; für die sagt [`.d-check.yml`](../../../../.d-check.yml) ausdrücklich *„folgen mit
  dem Go-Code (Phase 3)"*. Das ist eine **gestufte** Entscheidung mit eigenem Hochschalt-Trigger,
  kein Versehen — sie hier mitzunehmen hieße, eine Stufung ohne ihren Trigger aufzulösen.
- **Die Link-Form derselben Adresse.** Sie ist bereits entschieden und bewacht —
  [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) und
  [slice-197](../done/slice-197-eingefrorene-baseline-adresse-bekommt-ihr-ventil.md), und diese
  Kennung nimmt den Punkt an. Die zwei Vorgänge zeigen in verschiedene Richtungen: jener schaltet
  stumm, dieser deckt auf.
- **Die emittierte Fassung der Gate-Konfiguration.** Was ein **Zielrepo** an Prüfbereich bekommt,
  ist eine andere Ebene mit eigenem Beleg (`make full-smoke`, nicht `make gates`) und eigener
  Default-Regel
  ([`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)).
- **Kein Produkt-Code.** Der Slice ändert Gate-Konfiguration und Doku; `internal/` und `cmd/`
  bleiben unberührt. Die Selbstbindung ist beim Review in einem `git show --name-only` prüfbar.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als einer mit vier
erfundenen; die vier Klassen sind ein Suchraster, keine Ausfüll-Liste.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [ ] **Der Bestand ist Fundstelle für Fundstelle klassifiziert, nicht überschlagen.** Zu jeder
      Zeile der zweiten Ausgabe aus §1 steht genau eines: *Bug* (der Pfad wird nachgezogen) oder
      *benannte Klasse* mit ihrem Namen. Der Lauf-Bericht nennt die Ausgabe vollständig und die
      Zuordnung je Zeile. Wächst der Bestand gegenüber §1, ist **das** der Befund und die Zahl
      wird neu gemessen, statt die alte fortzuschreiben.
- [ ] **Jede Klasse trägt ihre eigene, gemessene Ausnahme — keine pauschale Wurzel-Auslassung.**
      Für jede in Liefer-Punkt 1 benannte Klasse steht eine Ausnahme, deren Bezugsmenge gemessen
      ist (wie viele Fundstellen sie stumm schaltet und welche). Eine Ausnahme, die den
      Prüfbereich senkt, ist eine Schwellen-Senkung und braucht ihre ADR
      ([`AGENTS.md`](../../../../AGENTS.md) §3.5); eine, die ihn hebt, ist ein Steering-Loop
      ([`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)).
      **Ein dritter Ausgang existiert nicht:** eine Klasse ohne eigene Ausnahme ist entweder ein
      Bug, der nachgezogen wird, oder eine Grenze, die in
      [`harness/README.md`](../../../../harness/README.md) §Sensors stehen bleibt — verschwiegen
      wird keine.
- [ ] **Das Gegenbeispiel ist rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6), in beiden
      Richtungen und mit gelesener Meldung: ein **erfundener** Pfad unter dem aktuellen
      Baseline-Tag in einem lebenden Artefakt färbt `codepath-missing`, und ein **auflösender**
      Pfad an derselben Stelle bleibt grün. Ohne die Gegenprobe könnte der Prüfer auch pauschal
      röten und wäre trotzdem rot zu sehen.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update für [`harness/README.md`](../../../../harness/README.md) §Sensors falls
      öffentlicher Vertrag berührt — die dort stehende benannte Grenze aus slice-201 ist auf den
      neuen Stand zu bringen oder zu streichen.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register fortgeschrieben, **falls dieser Slice einen Inventur-Fund auflöst** —
      Zeile mit Datum und auflösendem Artefakt nach *Aufgelöste Einträge* verschoben. Repos ohne
      Brownfield-Bootstrap haben die Datei nicht (`ls docs/plan/planning/reconciliation.md`); dann
      entfällt das Item. Der Pfad steht als **Kommando-Operand**, weil die vendored Vorlage ihn als
      blanken Inline-Code führt und `codepaths` ihn dann als fehlendes Ziel meldet — dasselbe Modul,
      dessen Reichweite dieser Slice zum Gegenstand hat.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`.d-check.yml`](../../../../.d-check.yml), `codepaths` | update | die vierte Wurzel plus die Ausnahmen je Klasse aus Liefer-Punkt 2 |
| die lebenden Artefakte mit **Bug**-Klassifikation | update | Liefer-Punkt 1; welche es sind, sagt die Messung, nicht diese Zeile |
| [`harness/README.md`](../../../../harness/README.md) §Sensors | update | die benannte Grenze aus slice-201 beschreibt danach eine andere Fläche |
| [`docs/plan/adr/`](../../adr/) | neu, **falls** eine Ausnahme eine Senkung ist | [`AGENTS.md`](../../../../AGENTS.md) §3.5 — kein PR-Kommentar |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **`make gates` ist grün** — beobachtbar am Lauf selbst. Ein
Slice, der die Fläche eines Gates ändert, braucht einen grünen Ausgangsstand: Auf rotem Baum ist
nicht unterscheidbar, ob die neue Fläche rot färbt oder die alte.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Klassifikation aus
  Liefer-Punkt 1 mehr als drei Klassen ergibt oder wenn eine davon eine eigene ADR-Abwägung
  verlangt, die nicht in dieselbe Review-Sitzung passt. Dann trennt der Schnitt die Klassen.
- `in-progress` → `open` (blockiert — Carveout?): wenn die vierte Wurzel eine Fläche aufdeckt, die
  aus einem **anderen** Grund rot ist als dem gesuchten — etwa der gitignorierte Laufzeit-Ort, den
  [`spec/architecture.md`](../../../../spec/architecture.md) als kanonische Adresse führt, obwohl
  er auf einem frischen Checkout nicht existiert. Dann ist der rote Status auf einen Trigger zu
  schalten, nicht durch eine breitere Ausnahme zu ersetzen.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. Die Klassifikation aus Liefer-Punkt 1 liegt vollständig vor — jede Zeile der Messung hat genau
   eine Zuordnung, und der Lauf-Bericht nennt beides.
2. Das Gegenbeispiel-Paar aus Liefer-Punkt 3 ist **rot** und **grün** gesehen, mit gelesener
   Meldung, und `make gates` ist grün.

**Lerneintrag** in einer der drei Formen (geschärfte Regel · neuer Sensor · benannte Spec-Lücke).
Die erwartete Form ist *neuer Sensor*; bleibt am Ende doch eine Klasse ohne Ausnahme und ohne
Nachzug, ist es eine **benannte** Lücke und der Text hat sie als Lücke zu sagen, nicht als
Deckung.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Bestand wächst schneller, als der Slice ihn klassifiziert.** Jede Aussage über die
  Baseline, die einen abgelösten Tag als Mess-Operand nennt, legt eine weitere Fundstelle an —
  und [`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  verlangt genau diese Form. Ein Prüfer, der sie als Bug meldet, kämpft gegen eine geltende Regel.
  — **Ausgang:** offen; die Closure setzt ihn.
- **Eine Ausnahme wird pauschal, weil die einzelne teuer ist.** Vier Klassen einzeln zu messen
  kostet vier Messungen; eine Wurzel-Auslassung kostet eine Zeile. Der billige Weg schaltet
  genau die Fundstellen stumm, für die der Prüfer gebaut wurde. — **Ausgang:** offen; die Closure
  setzt ihn.
- **Der gitignorierte Laufzeit-Ort ist keine der drei Klassen und lässt sich nicht wegdefinieren.**
  Er steht in zwei kanonischen Spec-Dokumenten als Adresse und existiert auf keinem frischen
  Checkout; eine Ausnahme dafür ist eine Aussage über die Spec, nicht über das Gate. —
  **Ausgang:** offen; die Closure setzt ihn.
- **Der Prüfer färbt rot, bevor der Bestand entschieden ist.** Die Reihenfolge — erst
  klassifizieren, dann anheben — steht in der Nummerierung der Liefer-Punkte und ist keine
  Empfehlung. — **Ausgang:** offen; die Closure setzt ihn.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<NNN>` (<slice-NNN>, <slice-MMM>, <slice-KKK> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-NNN.md` | `evidence/slice-NNN.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-NNN (<Titel>) — ist eine Datei in `open/`>
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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area, `*` (`ALL`). Die
Gate-Konfiguration adressiert das ganze Repo; `harness/tools/` (`TOOLS`) und `.codex/` (`CODEX`)
sind als Pfade nicht berührt. Der neue Prüfbereich ist keine neue Sub-Area — er ändert, worüber
ein Modul urteilt, nicht die Reife-Achse eines Bereichs.

**Vorgelagert — offene Beobachtungen sichten:** Das Register unter
[`../observations/`](../observations/) ist durchgegangen; die Zähler sind als Dateizahl unter
`evidence/` abgelesen
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, keine
Erwartungswerte). Diesen Vorgang betreffen:

| Eintrag | Zähler | Stand | Bezug zu diesem Slice |
|---|---|---|---|
| `gate-modul-erreicht-den-vendored-baum-nicht` | 2× | offen | **der Kern** — dieser Slice ist ihr Ausgang, und ihre `state.md` nennt ihn |
| `benannte-luecke-ohne-ausgang` | 1× | offen | die Grenze in [`harness/README.md`](../../../../harness/README.md) §Sensors, die dieser Slice einlöst oder neu fasst |
| `zusammenfassung-staerker-als-ihre-quelle` | 3× | offen | über der Schwelle: die Klassifikation aus Liefer-Punkt 1 ist genau die Stelle, an der eine Fundmenge zusammengefasst wird |
| `zahl-ohne-kommando-trifft-ihren-gegenstand-nicht` | 3× | offen | über der Schwelle: jede Zahl dieses Slice wandert mit dem Bestand |
| `ausnahmeliste-nur-auf-form-geprueft` | 2× | offen | `roots` ist eine Einschluss-Liste, und Liefer-Punkt 2 fügt Ausnahmen hinzu, die nie auf Berechtigung geprüft werden |

**Zwei der fünf Einträge stehen bei der Schwelle** und warten auf den Lese-Schritt
der nächsten Welle-Closure; dieser Slice erhöht sie nicht vorab. Alle Bezeichnungen sind
**zitiert**, nicht neu formuliert.

**Modus:** alle berührten Sub-Areas **GF** — der Begründungsblock entfällt damit nach der
Umfangs-Regel dieser Sektion.
