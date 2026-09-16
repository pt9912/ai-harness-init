# Slice slice-planning-readme-beschreibt-die-eigenen-lifecycle-verzeichnisse: Zwei Sätze über `in-progress/`, die der Bestand nicht trägt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case.

**Welle:** ohne Welle. Es gibt keine Closure-Bedingung, die mehr beobachtet als die DoD unten: Der
Gegenstand sind zwei Abschnitte **einer** lebenden Datei, und ihr Beleg ist der `docs-check`-Lauf,
der ohnehin in jeder DoD steht (Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht). Nach
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
steht wellenlose Arbeit nicht in der Roadmap — auch nicht beim Abschluss.

**Ebene: Dogfood, nicht emittiert.** Gegenstand ist die Planning-README **dieses** Repos. Die
vendored Vorlage bleibt unberührt (§1) — sie ist committet vendored Fremdtext
([`AGENTS.md`](../../../../AGENTS.md) §3.7).

**Bezug:**
[ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) (Festlegung 1 — die Regel,
deren Nachzug diese zwei Sätze in die Datei brachte bzw. stehen ließ),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben ihrem Kommando),
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
(Kennungs-Form),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(keine Zusage über einen Prüfumfang, den kein Sensor hält).

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle; Gegenstand ist ein
Planungs-Artefakt).

**Verantwortlich:** `—` bis zur Priorisierung.

**Autor:** Planner. **Datum:** 2026-09-14.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** [`docs/plan/planning/README.md`](../README.md) sagt über die vier Lifecycle-Verzeichnisse
das, was dieses Repo führt und was das Regelwerk setzt — kein Satz, dessen nächstliegende Lesart
den eigenen Bestand ausschließt, und keine Zelle, die hinter der Semantik ihrer Ziel-Form
zurückbleibt.

### Zwei Befunde, eine Datei, eine gemeinsame Wurzel

Beide stammen aus dem Review von `slice-flache-welle-ist-eroeffnet-nicht-geplant`, Runde 2, und
beide sind **Instanz gegen Ziel-Form**: einmal hat der Nachzug einen Satz mitgebracht, den dieses
Repo nicht trägt, einmal ist ein älterer Absatz hinter seiner Ziel-Form zurückgeblieben. Kein
Modul des Doku-Gates hält eine Instanz gegen ihre Vorlage; `make docs-check` ist über beiden
Fassungen grün.

**Befund A — der aktive Durchlauf und die Roadmap.** §Slices vs. Wellen sagt: *„Der aktive
Durchlauf `open/` → `next/` → `in-progress/` nimmt ausschließlich **Slices** auf; `done/`
archiviert **zusätzlich** abgeschlossene **Nicht-Slice-Records**"*. Zwei Zeilen darüber verlinkt
derselbe Abschnitt `in-progress/roadmap.md` — Rang 5 der Source Precedence. **Die Ziel-Form selbst
adressiert diesen Pfad**, und zwar in mehreren ihrer Dateien, das Regelwerk daneben:

```sh
grep -rl 'in-progress/roadmap' .harness/baseline/v6.9.0/ | wc -l                                  # 7
git grep -l 'in-progress/roadmap\.md' \
  -- ':!.harness/baseline' ':!docs/plan/planning/done' ':!docs/reviews' | wc -l                    # 38
```

**Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — beide wandern mit dem Stand. Der Slice hat damit **eine Lesart zu wählen und
auszuschreiben**, nicht einen Bestand zu verschieben: entweder trägt *Durchlauf* die enge Lesart
*Passage* — dann sagt der Satz es —, oder der Satz nennt die stehende Ablage, die `in-progress/`
neben den Slices führt. Was der Slice **nicht** darf, ist den Satz stehen lassen: Wer ihn als
Konvention liest, verschiebt `roadmap.md` oder schreibt einen Start-Trigger ohne den
`^slice-`-Filter, den die Slice-Pläne dieses Repos heute führen.

**Befund B — die Bedeutungs-Tabelle.** §Lifecycle-Bedeutungen führt für `in-progress/`
*„Branch / PR existiert."*; Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State
Machine setzt seit der Neufassung das Gegenteil der Reihenfolge — der `git mv` landet **auf dem
Hauptzweig, vor der Arbeit**, der Branch entsteht danach. Die `next/`-Zelle verliert daneben den
Zeiger auf das Feld `Verantwortlich:`, das derselbe Abschnitt an den Übergang `open→next` bindet.
Die Zelle ist damit nicht nur knapper als ihre Ziel-Form, sie lehrt eine andere Reihenfolge.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Umzug von `docs/plan/planning/in-progress/roadmap.md`.** Der Pfad ist Rang 5 der Source
  Precedence, die Baseline adressiert ihn selbst (Messung oben), und 38 lebende Dateien zeigen
  darauf. Der Satz folgt dem Bestand, nicht umgekehrt. *Bestand bleibt bewusst stehen.*
- **Keine Änderung an der vendored Vorlage**
  `.harness/baseline/v6.9.0/templates/docs/plan/planning/README.template.md`. Der Baum ist
  committet vendored Fremdtext, den [`AGENTS.md`](../../../../AGENTS.md) §3.7 ausdrücklich
  ausnimmt; `make baseline-verify` hält ihn gegen `SHA256SUMS`. *Bestand bleibt bewusst stehen.*
- **Kein Adaptions-Eintrag `MR-<NNN>`.** Ob aus Befund A eine Abweichung von der Baseline folgt,
  ist eine Architektur-Frage, und den Adaptions-Block schreibt der **Architect**
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Kommt der Slice zu dem Ergebnis, dass hier eine
  Abweichung **besteht**, ist das ein Übergabe-Artefakt an den Architect und kein Schritt dieses
  Slice. *Es wäre ein anderer Vorgang.*
- **Keine Sektion `Regeln dieser Sektion` in den übrigen Abschnitten.** Die Ziel-Form führt sie in
  jeder, diese Datei in einer von fünf
  (`grep -c '^Regeln dieser Sektion' docs/plan/planning/README.md` → **1**,
  `grep -c '^## ' docs/plan/planning/README.md` → **5**, keine Erwartungswerte). Das ist eine
  **Gliederungs**-Frage über die ganze Datei und nicht die Aussage über die Lifecycle-Verzeichnisse.
  *Es wäre ein anderer Vorgang.*
- **Kein Produkt-Code und kein Sensor.** `internal/`, `cmd/`, `harness/tools/` und
  [`.d-check.yml`](../../../../.d-check.yml) bleiben unberührt. Ein Modul, das eine Instanz gegen
  ihre Vorlage hielte, wäre eine Gate-Aktivierung mit eigener Erprobung
  ([`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)).
  *Schicht-Abgrenzung.*

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
Gate-Läufe und die Closure-Pflichten darunter zählen nicht mit.

**Zwei Liefer-Punkte, einer je Befund:**

- [ ] **(1) §Slices vs. Wellen sagt über `in-progress/` nichts, was den eigenen Bestand
      ausschließt.** Die stehende Ablage, die dort neben den Slices liegt, ist entweder benannt
      oder der Satz ist auf die Passage-Lesart verengt; in beiden Fällen steht `roadmap.md` und
      der Satz nebeneinander, ohne dass einer den anderen widerlegt. Geprüft an der Datei, nicht
      am Wortmuster: `ls docs/plan/planning/in-progress/` führt weiterhin `roadmap.md`
      (kein Erwartungswert), und der Abschnitt widerspricht dem nicht.
- [ ] **(2) §Lifecycle-Bedeutungen trägt die Semantik ihrer Ziel-Form** — `v6.8.0` ·
      `templates/docs/plan/planning/README.template.md` §Lifecycle-Bedeutungen, die Zuordnung aus
      dem Instanz-Register [`harness/migration.md`](../../../../harness/migration.md): `in-progress/`
      heißt **beansprucht** (der `git mv` liegt auf dem Hauptzweig, **vor** der Arbeit; Branch/PR
      entsteht danach), und die `next/`-Zelle nennt das Feld `Verantwortlich:`. Die Zellen sind
      **ersetzt, nicht ergänzt** ([`AGENTS.md`](../../../../AGENTS.md) §3.7).
      **Grenze wie beim Vorgänger:** Was die Ziel-Form nennt und dieses Repo nicht führt, kommt
      nicht mit — der Byte-Import einer Vorlagen-Aussage ist genau der Fehler, der Befund A erzeugt
      hat.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: Liefer-Punkte (1) und (2) **sind** dieses Item — beide Träger sind
      Planungs-Doku.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — **hier nicht**: Dieses
      Repo fährt Wellen-Betrieb (`ls docs/plan/planning/welle-*.md | wc -l` → **3**, kein
      Erwartungswert), also prüft sie die nächste Welle-Closure, auch für diesen Slice ohne
      Wellen-Zugehörigkeit.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`docs/plan/planning/README.md`](../README.md) §Slices vs. Wellen, dritter Bullet | update | Befund A — Liefer-Punkt (1) |
| [`docs/plan/planning/README.md`](../README.md) §Lifecycle-Bedeutungen, Zeilen `next/` und `in-progress/` | update | Befund B, gegen `README.template.md` §Lifecycle-Bedeutungen — Liefer-Punkt (2) |

**Kein Test-Eintrag, und das ist kein Vergessen.** Der Prüfgegenstand ist Prosa in einer lebenden
Datei; ihr Wächter ist der Bestand, den sie beschreibt. Ein `*_test.go` oder `*.bats` daneben
hielte den Text gegen eine zweite Fassung seiner selbst.

**Und keine Gate-Zusage.** Kein Modul des Doku-Gates hält eine Instanz gegen ihre Vorlage oder
einen Prosa-Satz gegen den Verzeichnis-Bestand; `docs-check` bleibt über beiden Fassungen grün.
Träger ist der Lauf, nicht ein Sensor — die Klasse
[`BEO-ALL/gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang`](../observations/BEO-ALL/gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang/observation.md).

**Reihenfolge:** erst die zwei Mess-Kommandos aus §1 neu fahren und die Ziel-Form lesen, dann
ersetzen — **ersetzen, nicht danebenstellen** ([`AGENTS.md`](../../../../AGENTS.md) §3.7).

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **`in-progress/` trägt keinen Slice** (WIP frei). Beobachtbar
ohne Rückfrage, auf dem **Hauptzweig**:

```sh
ls docs/plan/planning/in-progress/ | grep -c '^slice-'   # 0  (Exit 1 bei 0)
```

**Der Trigger ist kein Ergebnis dieses Slice** — er spricht über den Bestand von `in-progress/`
vor der Arbeit.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): **Befund A lässt sich nicht durch einen
  Satz auflösen** — etwa weil die Wahl der Lesart eine Aussage über die Ablage-Ordnung des ganzen
  Planning-Baums verlangt. Dann ist die Ordnung der Gegenstand und der Satz ihre Folge, nicht
  umgekehrt.
- `in-progress` → `open` (blockiert — Carveout?): **Aus Befund A folgt eine Abweichung von der
  Baseline** (§1, dritter Ausschluss). Der Adaptions-Eintrag gehört dem Architect, und der Satz
  wartet auf ihn.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. **Beide Liefer-Punkte tragen**, und `make gates` meldet Exit 0: `roadmap.md` liegt unverändert
   in `in-progress/`, und kein Satz des Abschnitts schließt das aus; die zwei Zellen der
   Bedeutungs-Tabelle tragen die Semantik der Ziel-Form.
2. **Der Umsetzungs-Commit nennt je Träger die gelesene Ziel-Form** — welchen Abschnitt von
   `README.template.md` er gelesen hat und mit welchem Kommando, statt die Aussage frei zu
   formulieren.

**Lerneintrag:** die Form entscheidet die Closure und nicht dieser Plan. Das Feld `liegt in` steht
nur, wenn mit diesem Slice wirklich eine Regel aus der 3×-Schwelle verkörpert wurde
(Baseline-Regelwerk `grundlagen-traceability.md` §Herkunfts-Anker).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **(1) Die Korrektur von Befund A nimmt aus der Vorlage die nächste Aussage mit, die dieses Repo
  nicht führt.** Der Abschnitt ist über weite Strecken wortgleich mit der Ziel-Form; wer ihn
  anfasst, liest sie erneut — die gemessene Klasse
  [`BEO-ALL/vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt`](../observations/BEO-ALL/vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt/observation.md),
  die genau an diesem Abschnitt schon einmal zugeschlagen hat.
  **Gegenmittel im Plan:** Liefer-Punkt (2) trägt die Grenze ausdrücklich, und §3 verlangt je
  Träger die gelesene Ziel-Form statt einer freien Formulierung.
  — **Ausgang:** <eingetreten / entfallen / weiter offen — bei Closure zu setzen>
- **(2) Die gewählte Lesart von *Durchlauf* verengt sich still auf diese eine Datei.** Sagt der
  Abschnitt etwas anderes als die Slice-Pläne, die `in-progress/` mit `grep -c '^slice-'` messen,
  stehen zwei Fassungen derselben Ordnung nebeneinander.
  **Gegenmittel im Plan:** Liefer-Punkt (1) misst gegen den Verzeichnis-Bestand, nicht gegen ein
  Wortmuster.
  — **Ausgang:** <eingetreten / entfallen / weiter offen — bei Closure zu setzen>
- **(3) Befund B berührt die Semantik, auf der die Start-Trigger der Slice-Pläne aufsetzen.** Wer
  `in-progress/` neu beschreibt, beschreibt mit, was ein Start-Trigger beobachtet; eine unscharfe
  Zelle macht eine ganze Klasse von Triggern unscharf.
  **Gegenmittel im Plan:** Liefer-Punkt (2) bindet die Zelle an die Ziel-Form und an
  `modul-05-planning-harness.md` §Lifecycle als State Machine, nicht an eine eigene Formulierung.
  — **Ausgang:** <eingetreten / entfallen / weiter offen — bei Closure zu setzen>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes der drei mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <Repo **mit** Wellen-Betrieb — geprüft von der nächsten Welle-Closure, auch
  für diesen Slice ohne Wellen-Zugehörigkeit>

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area: `*` (gesamtes Repo,
Kürzel `ALL`), deklariert in [`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area. Die Schwelle ≥ 2 von 3 Achsen ist erfüllt: eigene Regeln
([`AGENTS.md`](../../../../AGENTS.md) §3.7,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)),
eigener Prüfbereich ([`make docs-check`](../../../../harness/sensors/docs-check.md)) und eigene
Fehlermodi (eine Anleitung, die den eigenen Bestand ausschließt). **`TOOLS` und `CODEX` sind
geprüft und nicht berührt:** Keine Aussage über `harness/tools/` oder `.codex/` ändert sich.

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist am gemergten Stand durchgegangen;
alle Verzeichnisse führen dieselbe Sub-Area `*`, die Sichtung ist damit vollständig. Die Stände
unten sind **datierte Messungen**
([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2, **keine Erwartungswerte**) und schließen die Fortschreibung durch die Closure von
`slice-flache-welle-ist-eroeffnet-nicht-geplant` bereits ein. **Drei Treffer** berühren diesen
Slice:

| Beobachtung (`BEO-ALL/<slug>`) | Zähler | Stand | wo sie diesen Slice trifft |
|---|---|---|---|
| `vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt` | 2× | offen | §1 Befund A und §6 Risiko 1 — dieser Slice **ist** ihr Ausgang für den Vorgänger |
| `instanz-und-ihre-ziel-form-fallen-auseinander` | 1× | offen | §1 Befund B — die Bedeutungs-Tabelle ist hinter ihrer Ziel-Form zurückgeblieben |
| `gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang` | 1× | offen | §3 — der Nachzug schreibt keine Gate-Zusage über seinen Prüfumfang hinaus |

```sh
for s in vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt \
         instanz-und-ihre-ziel-form-fallen-auseinander \
         gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang; do
  printf '%s %s\n' "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)" "$s"
done
```

**Keiner der drei erreicht mit diesem Slice 3×** — zwei stehen bei 1×, einer bei 2×; erst ein
weiterer Vorgang hebt den ersten über die Schwelle. **Ein eigener Folge-Slice entsteht aus der
Sichtung also nicht.**

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas sind Greenfield; der Block trägt
eine Sub-Area.

### Sub-Area: `*` (gesamtes Repo, Kürzel `ALL`)

- **Modus:** GF
- **Konventionen-Dichte:** hoch — die Ziel-Form steht in der vendored Vorlage, ihre Zuordnung im
  Instanz-Register [`harness/migration.md`](../../../../harness/migration.md), die Lifecycle-Semantik
  im Baseline-Regelwerk `modul-05-planning-harness.md`, und was ein lebendes Artefakt tragen darf,
  in [`AGENTS.md`](../../../../AGENTS.md) §3.7.
- **Phase-Reife:** Phase 4 für die Planungs-Doku — die Verzeichnis-Lage ist bewacht
  (`grep -m1 '^modules:' .d-check.yml | tr ',' '\n' | wc -l` → **8**, kein Erwartungswert), die
  Prosa über sie ist es nicht.
- **Evidenz-/Diskrepanz-Risiko:** **niedrig**. Beide Befunde sind vor dem Schnitt gemessen (§1),
  die Ziel-Form liegt vor, und der Gegenstand sind ein Bullet und zwei Tabellenzellen ohne
  Code-Kopplung.
- **Reconciliation-Aufwand:** keiner — GF, kein Inventur-Fund; die Datei `reconciliation.md`
  existiert in diesem Repo nicht (`ls docs/plan/planning/reconciliation.md` → Exit 2), und das
  zugehörige DoD-Item entfällt deshalb in §2. Graduation entfällt (n/a bei GF).
