# Slice slice-210: Das Modul `planning` im emittierten Doc-Gate wird entschieden

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Es gibt keine Closure-Bedingung, die von der DoD dieses Slice verschieden
wäre — ein Welle-Trigger wäre hier die Abschrift von DoD (2)
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:** [`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7)
(die emittierte Doc-Gate-Baseline),
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (der
emittierte Stand ist out-of-the-box gate-sicher — die Schranke, an der jedes Kandidaten-Modul
gemessen wird),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein
Gate über leerem Prüfbereich — hier die offene Frage, ob der Prüfbereich im Ziel überhaupt trägt),
[`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
(die drei Kriterien, nach denen ein Modul ins emittierte Doc-Gate geht — dieser Slice wendet sie
auf einen benannten, unentschiedenen Kandidaten an),
[`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
(die Default-Regel für emittierte Prüfbereiche),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel).

**Berührte Spec-Stellen:** — (kein Zielelement der Spec-Straten wird geändert; der Slice ändert die
Emissions-Vorlage des Doc-Gates).

**Verantwortlich:** —

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-09-10.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Für das Modul `planning` ist nach den drei Kriterien aus
[`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
**entschieden und gemessen**, ob es in die emittierte Startkonfiguration geht — statt weiter
weder emittiert noch als Nicht-Emission begründet zu sein.

**Der Anlass ist eine benannte Lücke, keine Vermutung.**
[`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
hält fest, dass die
Kandidaten-Menge mit der Modul-Liste dieses Repos wächst und dass *„ein Modul ohne diese Messung
**nicht entschieden** — nicht abgelehnt"* ist. Die Differenz ist mit zwei Kommandos sichtbar:

```sh
grep -m1 '^modules:' .d-check.yml                                          # die Module dieses Repos
sed -n 's/^modules: \[\(.*\)\]$/\1/p' internal/emit/templates/d-check.yml  # die emittierten
```

**Keine Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — beide Listen wachsen. `planning` erfüllt **Kriterium 1** (der Dogfood fährt es selbst)
und ist damit Kandidat; Kriterium 2 und 3 sind für es nie gefahren worden.

**Der Prüfbereich im Ziel ist nicht leer — das ist gemessen und schließt
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) als
Kurzschluss-Antwort aus.** Ein gebootstrapptes Ziel bekommt die Roadmap an genau dem Ort, den das
Modul liest:

```sh
grep -n 'docs/plan/planning/in-progress/roadmap.md' internal/emit/templates.go
```

**Eine strukturelle Anzeige liegt vor, und sie ist nicht die Messung.** Die Vorlage, aus der diese
Roadmap entsteht, trägt die Überschrift, auf die das Modul bindet, aber **kein**
Ruhe-Marker-Literal:

```sh
T=.harness/baseline/v6.7.2/templates/docs/plan/planning/roadmap.template.md
grep -nE '^## Offene Wellen' "$T"     # die Ueberschrift steht
grep -c 'Nichts in Arbeit' "$T"       # 0 -- der Marker steht nicht
```

Ein frisches Ziel hat ein `in-progress/`, das keinen `slice-*.md` trägt; die Invariante des Moduls
verlangt dann genau diesen Marker. Das legt nahe, dass `planning` out-of-the-box **rot startet** und
damit an Kriterium 2 scheitert — **nahelegen ist aber kein Beleg**, und welcher Grund-Code fällt,
sagt erst ein Lauf gegen ein frisch gebootstrapptes Ziel. Genau den schuldet DoD (1).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Modul-Liste dieses Repos.** `planning` bleibt im Dogfood aktiv, wie es ist; dieser Slice
  entscheidet die **Ziel**-Seite. *(Schicht-Abgrenzung: der emittierte Baum ist ein anderer Vertrag
  als das eigene Gate — dieselbe Trennung, die
  [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  in seinem Geltungsbereich zieht.)*
- **Die zwei bereits entschiedenen Nicht-Emissionen** — `codepaths` und das Requirement-Muster von
  `ids`. Sie stehen mit eigenem Auflösungs-Trigger in
  [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  Setzung 3, und ihre Begründung wird nicht zweimal aufgeschrieben. *(Bestand bleibt bewusst
  stehen.)*
- **Die `waves`- und `closure`-Fähigkeiten desselben Moduls.** Dieser Slice entscheidet über die
  Modul-Aktivierung und ihre Marker-Hälfte; `waves` ist auch im Dogfood aus (die dokumentierte
  Abweichung dieses Repos), `closure` setzt einen `done/`-Bestand voraus, den ein frisches Ziel
  nicht hat. *(Es wäre ein anderer Vorgang.)*
- **Ein Migrationspfad für bereits gebootstrappte Repos.** `.d-check.yml` ist *skip-if-present*
  ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md)); die Reichweiten-Grenze steht in
  [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  Setzung 5 und gilt für dieses Modul wie für jedes andere. *(Bestand bleibt bewusst stehen.)*

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) Kriterium 2 und 3 sind für `planning` am frisch gebootstrappten Ziel gemessen.** Je ein
  netzloser d-check-Lauf gegen den in [`d-check.mk`](../../../../d-check.mk) gepinnten Digest, gegen
  ein mit dem Träger aus `make host-bin` frisch gebootstrapptes Ziel außerhalb des Repos, Mount
  `:ro`: **out-of-the-box** (Kriterium 2 — wie viele Befunde, welcher Grund-Code) und **mit
  Gegenbeispiel** (Kriterium 3 — die Marker-Invariante in beide Richtungen: fehlender Marker bei
  leerem `in-progress/`, stehengebliebener Marker bei beanspruchtem Slice). Dazu die
  Kausalitäts-Gegenprobe: dasselbe Gegenbeispiel bleibt ohne das Modul grün. Die Zahlen stehen je
  neben dem Kommando, das sie liefert.
- [ ] **(2) Das Ergebnis ist verkörpert — in genau einer der zwei Formen.** *Entweder* `planning`
  geht in `internal/emit/templates/d-check.yml`: die Modul-Liste wächst, der netzlose Wächter
  `TestDCheckConfig_EntschiedeneModulListe` bindet sie, ein Fall in `test/mutations/` färbt rot, und
  `harness/tools/full-smoke.sh` trägt den Zahn nach der dort etablierten Form — **einschließlich
  dessen, was das Grün überhaupt erst möglich macht** (die Marker-Zeile in der emittierten Roadmap,
  falls die Messung sie verlangt). *Oder* es bleibt aus: dann steht es als **dritte** Nicht-Emission
  mit eigenem Auflösungs-Trigger im Adaptions-Block — **Architect-Arbeit**
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8), eigener Commit, und dieser Plan ist das
  Übergabe-Artefakt dafür. Ein drittes Ergebnis („weiter unentschieden") ist keines.
- [ ] **(3) `make gates` grün; `make full-smoke` grün — beide Bootstrap-Formen; Review durchgeführt,
  Report unter `docs/reviews/`** (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
  Minimal Agent Workflow ([`AGENTS.md`](../../../../AGENTS.md) §6), kein Self-Review (Modul 8).
  Closure-Notiz mit Steering-Loop-Lerneintrag; Beobachtungs-Register fortgeschrieben; jedes Risiko
  aus §6 mit Ausgang.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/d-check.yml` | update (nur im Emissions-Zweig) | die Modul-Liste und der `planning`-Block |
| `internal/emit/templates.go` bzw. die Roadmap-Emission | update (nur im Emissions-Zweig, nur falls die Messung es verlangt) | ohne Ruhe-Marker im emittierten Stand startet das Modul rot — Kriterium 2 |
| `internal/emit/emit_test.go` | update (nur im Emissions-Zweig) | der netzlose Wächter bindet die entschiedene Liste, sonst ist sie unbewacht |
| `test/mutations/<NNN>-…sh` | neu (nur im Emissions-Zweig) | ohne Zahn wäre der Wächter gelistet-aber-unbewacht |
| `harness/tools/full-smoke.sh` | update (nur im Emissions-Zweig) | der Zahn im Ziel, nach der dort etablierten Form |
| [`harness/conventions.md`](../../../../harness/conventions.md) + [`harness/conventions/`](../../../../harness/conventions/) | update (nur im Nicht-Emissions-Zweig) | die dritte Nicht-Emission — **Architect-Arbeit** ([`AGENTS.md`](../../../../AGENTS.md) §3.8), eigener Commit |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): WIP-Limit frei, Implementer übernimmt. Keine Abhängigkeit von
einem anderen Slice — die Entscheidungsregel steht, der Kandidat ist benannt.

**Rückführungen — vorab benannt:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Messung aus DoD (1) zeigt, dass
  das Grün im Ziel eine Änderung an der **vendored** Roadmap-Vorlage verlangt statt an der
  Emission — dann sind es zwei Vorgänge (Emissions-Form und Baseline-Delta), nicht einer.
- `in-progress` → `open` (blockiert — Carveout?): wenn sich zeigt, dass die Marker-Invariante im
  Ziel gar nicht stabil herstellbar ist, weil der Zustand von `in-progress/` beim Adopter wandert —
  dann ist erst zu klären, ob das Modul im Ziel überhaupt eine tragbare Zusage abgibt.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD (1)–(3) abgehakt; `make gates` und `make full-smoke` grün; im Emissions-Zweig zusätzlich
`make mutate` ohne Befund für den neuen Fall; Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Nicht-Emissions-Zweig ist der bequemere und darum der verdächtigere.** „Bleibt aus" kostet
  eine Kommentar-Zeile, der Emissions-Zweig kostet einen Zahn und womöglich eine Änderung an der
  Roadmap-Emission. DoD (1) verlangt die Messung für **beide** Kriterien, damit die Bequemlichkeit
  nicht als Begründung durchgeht. — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen:
  Grund | weiter offen: → Beobachtungs-Register>
- **Die Marker-Invariante ist im Ziel eine Zusage über einen wandernden Zustand.** Sie hält den
  Ruhe-Marker gegen `in-progress/`; beim Adopter bewegt sich dieses Verzeichnis mit jedem
  Lifecycle-Übergang. Ein emittiertes Modul, das bei jedem `slice-mv` eine Roadmap-Zeile
  nachzuziehen verlangt, verschiebt Arbeit zum Adopter, die dieses Repo selbst als
  [`BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
  zählt. — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: →
  Beobachtungs-Register>
- **Die Kandidaten-Menge wächst weiter.** Dieser Slice entscheidet **einen** Kandidaten; wächst die
  Modul-Liste dieses Repos erneut, entsteht dieselbe Lücke für das nächste Modul, und
  [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  nennt dafür keinen Wächter — Kriterium 1 ist eine Zulassungs-Bedingung, kein Gleichheits-Sensor.
  — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: →
  Beobachtungs-Register>

## 7. Closure-Notiz

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien**, vier und nicht mehr.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `*` (gesamtes Repo) und — nur im
Emissions-Zweig — `harness/tools/` aus der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area): der
Zahn in `harness/tools/full-smoke.sh` ist eine Berührung der Harness-Mechanik und erreicht mit
Pfad- und Aussagen-Achse die Schwelle ≥ 2 von 3. `.codex/` wird nicht berührt.

**Vorgelagert — offene Beobachtungen sichten:** Das Register
([`observations/`](../observations/)) ist durchgegangen. **Zwei Einträge treffen diesen Slice als
Sub-Area-Risiko**, beide unter der Schwelle für diesen Gegenstand und darum als Risiko in §6
geführt statt als eigener Folge-Slice:
[`BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
(**9×**, offen — genau die Invariante, die dieses Modul im Ziel durchsetzen würde; der Eintrag
zählt sie im Dogfood, dieser Slice erwöge sie zu exportieren) und
[`BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus`](../observations/BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus/observation.md)
(1×, offen — die Divergenz-Richtung, hier ausnahmsweise umgekehrt: der Dogfood läuft voraus).
Daneben ohne Treffer:
[`BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
(11×, geplant) betrifft die Ebenen-Verwechslung zwischen Dogfood- und Ziel-Gate und ist hier
**Anlass des Schnitts**, nicht Risiko: dieser Slice trennt die zwei Ebenen ausdrücklich. Die
Zähler-Stände sind am Tag des Schnitts abgelesen
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`) und keine
Erwartungswerte.

**Modus-Begründungsblock:** Alle berührten Sub-Areas GF — Emitter und Harness-Mechanik sind
Greenfield-Bestand, Doc führt und Code folgt; ein Begründungsblock pro Sub-Area entfällt damit
(Baseline-Regelwerk `modul-05-planning-harness.md` §Zwei Schritte vor der Modus-Begründung).
