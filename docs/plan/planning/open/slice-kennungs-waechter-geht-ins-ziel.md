# Slice slice-kennungs-waechter-geht-ins-ziel: Der Traceability-Constraint bekommt im Ziel einen Träger

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case.

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-emittierte-werkzeuge](../welle-emittierte-werkzeuge.md). Die Welle trägt das
*Mehr* über dieser DoD: ihr Closure-Trigger fährt die neu emittierten Werkzeuge im gebootstrappten
Ziel einmal durch (`make full-smoke`) — einen Beleg, den kein Punkt dieser DoD führt
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:**
[`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (die
emittierte Durchsetzungsschicht — Command-Guard und `settings.json`),
[`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) (der
Anweisungssatz trägt die Konvention, auf der ein Vor-Commit-Sensor hängt),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Wächter, dessen Reichweite nicht neben seiner Zusage steht, behauptet mehr als er misst),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (kein neuer
Host-Bedarf),
[ADR-0004](../../adr/0004-durchsetzungs-emission.md) (der Stolperdraht-Charakter eines Guards),
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (wer den
Anweisungssatz schreiben darf).

**Berührte Spec-Stellen:** `—`. Der Slice ändert die Emissions-Vorlage; kein Zielelement der
Spec-Straten wird angefasst.

**Verantwortlich:** — (bis zur Priorisierung).

**Autor:** Planner. **Datum:** 2026-09-14.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Der **Traceability-Constraint**, den das mitgelieferte Regelwerk dem Ziel vorschreibt, hat
dort einen Träger — oder das Ziel sagt an derselben Stelle, welchen Teil es nicht trägt.

### Der Anlass ist am Baum gemessen

Das Regelwerk verlangt, dass keine relevante Änderung ohne Bezug zu einer Kennung stattfindet; sein
Träger ist ein Commit-Wächter. Dieses Repo führt ihn — das Ziel nicht:

```sh
ls .claude/hooks/ | wc -l                                      # 4 — die drei emittierten plus der lokale
git grep -c 'commit-msg' -- internal/ | wc -l                  # 0 — das Ziel kennt ihn nicht
grep -c '\.sh", "\.claude/hooks/' internal/emit/enforce.go      # 3 — so viele Hooks gehen hinaus
```

**Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — alle drei wandern mit dem Baum. Der lokale Träger hat zwei Hälften: den
PreToolUse-Hook und ein Kommando, das dieselbe Prüfung ohne Agenten fährt — beide bleiben hier. Auch
die Modul-Liste der emittierten Gate-Konfiguration führt den Constraint nicht: sie liest
`modules: [links, anchors, ids, matrix, spans]`.

**Der Träger ist die Entscheidung, nicht ein Artefakt.** Ein Wächter kann am **Agenten** hängen (wie
hier) oder am **Commit**; die zwei erreichen verschiedene Mengen. Eine Commit-Message ohne Kennung
ist die eine Hälfte des Constraints — die andere, ein Doku-Update bei berührtem öffentlichem
Vertrag, ist von keinem der zwei Kanäle erreichbar. Was das Ziel nicht trägt, steht darum **neben**
dem, was es trägt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Träger-Wahl des Dogfoods für sich.** [slice-215](../done/slice-215-commit-waechter-sieht-auch-die-ungetippten-commits.md)
  entscheidet, wo der Wächter **dieses** Repos hängt, wenn der Aufruf nicht als Kommando erscheint;
  die emittierte Fassung erbt diese Entscheidung, statt sie vorwegzunehmen (§5 der Welle).
- **Der `commits`-Modulblock als solcher.** Sein Zustand am gepinnten Stand ist ein Befund des
  Nachbar-Werkzeugs und steht im Register
  ([`BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse`](../observations/BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse/observation.md));
  dieser Slice entscheidet den **Träger**, nicht das Modul.
- **Die zweite Hälfte des Constraints — das Doku-Update.** Sie ist von einem Commit-Gate nicht
  mechanisch prüfbar; sie wird **benannt**, nicht gebaut. Sie zu bauen wäre ein anderer Vorgang.
- **Der Produkt-Code.** Diese Eröffnung schneidet; `internal/` wird von ihr nicht angefasst.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Was hier steht, ist die Grenze, an der ein wachsender Slice sich
messen lässt: Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den
Plan **geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [ ] **Das Ziel hat einen Träger an einer benannten Stelle, und der Anweisungssatz trägt die
      Konvention mit, an der er hängt** — oder die Lücke ist an derselben Stelle als Satz benannt.
      Der Beleg ist `make full-smoke` über einem gebootstrappten Ziel, nicht eine Zeile im Emit-Code.
- [ ] **Der Fall ist rot gesehen:** eine Commit-Message **ohne** Kennung fällt im Ziel, eine **mit**
      Kennung nicht; Ausgabe und Exit-Code gelesen. Ist der Träger nicht gebaut, ist der Rot-Beleg
      die gelesene Ausgabe des benannten Satzes.
- [ ] **Reichweite und Abhängigkeit stehen neben der Zusage:** was der Träger **nicht** erreicht
      (die zweite Hälfte des Constraints, die Commits innerhalb von Werkzeugen), ist benannt; der
      Träger braucht nichts über `bash + git` bzw. das gepinnte Gate-Bild hinaus
      ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: die Aufzählung der emittierten Werkzeuge, soweit dieser Slice sie wachsen lässt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
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
| `internal/emit/templates/enforce/` + `internal/emit/enforce.go` | neu/update | die Vorlage des Trägers und seine Verdrahtung in der emittierten `settings.json` |
| `internal/emit/templates/commands/` | update | der Anweisungssatz trägt die Konvention („Commit via Message-Datei"), an der der Träger hängt |
| `Makefile` (`full-smoke`) | update | der Beleg aus DoD (1)/(2) |
| `test/…` | neu/update | Happy/Negative nach DoD (2) und die Reichweiten-Zeile aus DoD (3) |

**Der Träger wird nicht neu erfunden.** Dieses Repo führt beide Hälften — den PreToolUse-Hook und
das Kommando, das dieselbe Prüfung ohne Agenten fährt. Die Emission übernimmt die Form, die
[slice-215](../done/slice-215-commit-waechter-sieht-auch-die-ungetippten-commits.md) für den **Dogfood**
entscheidet; bis dahin steht hier der heutige Kanal, und der Slice ist nicht fertig, solange die
Reichweiten-Zeile aus DoD (3) fehlt. **Fällt dort die Wahl auf den `git`-eigenen Hook, ist die Form
im Ziel dieselbe wie im Klon — und ihre Grenze wandert mit:** `core.hooksPath` ist lokale
Konfiguration, die kein Bootstrap setzt; der emittierte Wächter ist damit **optional**, und was er
nicht erreicht, sagt die Reichweiten-Zeile.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Der Slice ist priorisiert (`Verantwortlich:` gesetzt) und das
WIP-Limit frei. **Keine harte Bindung an [slice-215](../done/slice-215-commit-waechter-sieht-auch-die-ungetippten-commits.md):**
er entscheidet den Dogfood-Träger; dieser Slice kann mit dem heutigen Kanal beginnen und zieht nach,
wenn dort entschieden ist — die Richtung „erst die ausgeführte Fassung, dann die emittierte" (Welle
§5) ist eine Ordnung, keine Sperre.

**Reihenfolge innerhalb der Welle:** unabhängig von den drei übrigen Mitgliedern; die Flächen sind
disjunkt — dieses Mitglied fasst die Hooks und die `settings.json` an, kein anderes tut das.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Träger-Entscheidung und die
  Angleichung der **drei** emittierten Command-Vorlagen zusammen nicht in einer Review-Sitzung
  prüfbar sind — dann ist an der Kanal-Hälfte zu schneiden.
- `in-progress` → `open` (blockiert — Carveout?): wenn sich zeigt, dass kein Kanal den
  Constraint im Ziel tragen kann, ohne den Durchsetzungsvertrag der emittierten
  `settings.json` zu ändern — dann gehört erst diese Entscheidung.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; `make full-smoke` grün über einem gebootstrappten Ziel; der Rot-Fall aus DoD (2) im
Closure-Eintrag zitiert; `make gates` grün; Closure-Notiz mit Steering-Loop-Lerneintrag.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der emittierte Wächter erbt eine Entscheidung, die noch nicht gefallen ist.**
  [slice-215](../done/slice-215-commit-waechter-sieht-auch-die-ungetippten-commits.md) bewegt den Träger des
  Dogfoods; eine emittierte Form, die davor geschrieben wird, ist mit seinem Ergebnis zu
  vergleichen und gegebenenfalls nachzuziehen. — **Ausgang:** <eingetreten: CO-NNN /
  slice-<Kennung> | entfallen: Grund | weiter offen: → BEO im Register>
- **Ein Wächter am Agenten sieht die Commits nicht, die Werkzeuge selbst setzen.** Das ist die
  gemessene Reichweiten-Grenze, die der Dogfood-Slice führt; im Ziel gilt sie unverändert, und die
  DoD (3) verlangt, sie **neben** die Zusage zu schreiben. — **Ausgang:** <eingetreten: CO-NNN /
  slice-<Kennung> | entfallen: Grund | weiter offen: → BEO-ALL/waechter-abdeckung-haengt-an-uninstruierter-konvention im Register>
- **Die Konvention, an der der Wächter hängt, wird nicht von allen Anweisungssätzen getragen.** Der
  Hook greift nur bei einer Message-**Datei**; ein Anweisungssatz, der den Commit anders beschreibt,
  fällt durch. — **Ausgang:** <eingetreten: CO-NNN / slice-<Kennung> | entfallen: Grund | weiter
  offen: → BEO im Register>

## 7. Closure-Notiz

<!-- BEDIENHINWEIS — keine Norm; faellt beim Kopieren weg (README.md
§Verwendung, Schritt 5) und darf deshalb nichts Tragendes halten. Reihenfolge:
diese Sektion vor dem `git mv` nach done/ fuellen — einzige Ausnahme ist das
letzte DoD-Item in §2 (die Paarungen suchen in `done/`, also nach dem `git mv`).
Im Repo ohne Wellen-Betrieb braucht die Closure dadurch drei Commits: Inhalt,
`git mv`, Haekchen — das folgt aus der Hard Rule, es widerspricht ihr nicht. -->

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
  Auslöser: `BEO-<NNN>` (<slice-kennung-a>, <slice-kennung-b>, <slice-kennung-c> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-<Kennung>.md` | `evidence/slice-<Kennung>.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-<Kennung> (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <von der Welle-Closure getragen — Anker · Folge-Slice · Register>

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) —
die Hook-Vorlagen und `internal/emit/` liegen in keiner engeren Sub-Area der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area). Die
**emittierte** Ebene ist keine Sub-Area dieses Repos: sie ist ein anderer Vertrag.

**Vorgelagert — offene Beobachtungen sichten:** das Register durchgegangen, zwei Treffer für diese
Fläche, jeder mit seinem Zähler-Stand (die Zahl der Dateien unter `evidence/`, abgelesen mit
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l` — kein gespeicherter Wert):

- [`BEO-ALL/waechter-abdeckung-haengt-an-uninstruierter-konvention`](../observations/BEO-ALL/waechter-abdeckung-haengt-an-uninstruierter-konvention/observation.md)
  — **1×, offen.** Berührt: der Wächter greift nur bei einer Message-Datei, und vier von sechs
  Agenten-Briefings nennen die Konvention nicht. Im Ziel gilt dieselbe Abhängigkeit; sie steht als
  Risiko in §6 und als Out-of-Scope-Punkt in §1.
- [`BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse`](../observations/BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse/observation.md)
  — **1×, offen.** Berührt: der `commits`-Modulblock ist am gepinnten Stand unbedienbar, und dieser
  Slice wählt Träger, die nicht auf ihm beruhen müssen. Der Zähler bewegt sich nur, wenn der Slice
  die Klasse **beobachtet** statt sie zu umgehen.

Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.
