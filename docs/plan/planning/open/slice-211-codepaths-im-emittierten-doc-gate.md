# Slice slice-211: Das Modul `codepaths` im emittierten Doc-Gate wird entschieden

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Es gibt keine Closure-Bedingung, die von der DoD dieses Slice verschieden
wäre — ein Welle-Trigger wäre hier die Abschrift von DoD (2)
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Ebene: emittiert, nicht Dogfood.** Gegenstand ist die Doc-Gate-Startkonfiguration, die das
Werkzeug in ein fremdes Ziel schreibt. Die `.d-check.yml` **dieses** Repos ist nicht berührt; zwei
Verträge, zwei Gründe.

**Bezug:** [`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7)
(die emittierte Doc-Gate-Baseline),
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (der
emittierte Stand ist out-of-the-box gate-sicher),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein
Gate über falsch behauptetem Prüfbereich),
[`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
(die drei Kriterien und die Position `codepaths` in Setzung 3, deren Auflösungs-Trigger
eingetreten ist),
[`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
(die Default-Regel für emittierte Prüfbereiche),
[`ADR-0037`](../../adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md) (§Fitness Function nennt die
Deckung zwischen emittiertem Text und emittiertem Bestand als Lücke ohne Wächter),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel),
[`AGENTS.md`](../../../../AGENTS.md) §3.5 (eine Schwellen-Senkung braucht ein ADR — hier steht die
Gegenrichtung zur Wahl).

**Berührte Spec-Stellen:** — (kein Zielelement der Spec-Straten wird geändert; der Slice ändert die
Emissions-Vorlage des Doc-Gates und den Voll-E2E-Smoke).

**Verantwortlich:** —

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-09-11.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Für das Modul `codepaths` ist nach den drei Kriterien aus
[`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
Setzung 1 **entschieden und gemessen**, ob es in die emittierte Startkonfiguration geht — mit dem
fehlenden dritten Kriterium als Arbeit, nicht als Vorbehalt.

**Der Anlass ist ein eingetretener Auflösungs-Trigger, keine Vermutung.**
[`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
Setzung 3 hält `codepaths` mit dem Trigger *„die emittierte Prosa nennt keinen Ort mehr, den ein
frisches Ziel nicht trägt"* zurück. Der Ort wird emittiert
([slice-194](../done/slice-194-bootstrap-legt-den-register-ort-an.md)), und die Kopf-Marke des
Eintrags führt den Trigger als eingetreten. Was die drei Kriterien heute tragen, ist in drei
Kommandos abzulesen:

```sh
grep -m1 '^modules:' .d-check.yml                                          # Kriterium 1: der Dogfood faehrt es
sed -n 's/^modules: \[\(.*\)\]$/\1/p' internal/emit/templates/d-check.yml  # die emittierte Liste
grep -c -i codepath harness/tools/full-smoke.sh                            # Kriterium 3: 0 -- kein Gegenbeispiel im Ziel
```

**Keine Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — alle drei wandern mit dem Bestand. **Kriterium 1** ist erfüllt (dieses Repo fährt
`codepaths` in seinem eigenen Doku-Gate), **Kriterium 2** ist am frischen Ziel bereits grün
gemessen worden und wird in diesem Slice gegen den dann aktuellen Stand wiederholt, **Kriterium 3**
ist die offene Arbeit: Der Voll-E2E-Smoke führt für `codepaths` keinen Zahn, und ohne ihn ist grün
von *prüft nichts* nicht zu unterscheiden.

**Was die Entscheidung zusätzlich einlöst.** Der Registereintrag
[`BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger`](../observations/BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger/observation.md)
steht auf `geplant` und nennt als verbleibende Lücke wörtlich, dass *das Doku-Gate des Ziels
`codepaths` nicht fährt* — die Deckung zwischen emittiertem Text und emittiertem Bestand hat damit
keinen Wächter. Dieser Slice ist der benannte Träger dieser Lücke.

**Der Ausgang ist offen, und das ist die Zusage.** Fällt die Messung gegen Kriterium 2 rot aus,
bleibt `codepaths` als begründeter Kommentar-Block stehen — dann mit *gemessener* Begründung und
einem neuen Trigger statt des eingetretenen. Eine Aktivierung ist das Ziel der Messung, nicht ihr
vorweggenommenes Ergebnis.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Modul-Liste dieses Repos.** `codepaths` bleibt im Dogfood aktiv, wie es ist; dieser Slice
  entscheidet allein über die emittierte Startkonfiguration. *(Schicht-Abgrenzung — zwei Verträge,
  zwei Gründe.)*
- **Das Modul `planning` und das Requirement-Muster von `ids`.** Beide sind eigene Kandidaten mit
  eigenem Träger: `planning` hat seinen in
  [slice-210](slice-210-planning-modul-im-emittierten-doc-gate.md), das `ids`-Muster einen eigenen
  Auflösungs-Trigger in
  [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  Setzung 3, der nicht eingetreten ist. *(Ein Folge-Slice bzw. ein stehender Bestand übernimmt es.)*
- **Die Positionen innerhalb von `codepaths`.** Welche `roots:` die emittierte Konfiguration führt,
  wenn das Modul mitgeht, entscheidet die Ziel-Form der Startkonfiguration und nicht
  [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel),
  dessen Geltungsbereich die Modul-Zusammensetzung ist. Dieser Slice übernimmt die Wurzel-Liste,
  die der Kommentar-Block heute schon führt, und begründet keine zweite. *(Bestand bleibt bewusst
  stehen.)*
- **Der tote Inline-Pfad unter `.harness/baseline/` im Dogfood.** Dieselbe Modul-Familie, andere
  Ebene und eigener Träger:
  [slice-202](slice-202-der-tote-inline-pfad-unter-harness-bekommt-seinen-pruefer.md).
  *(Ein Folge-Slice übernimmt es.)*
- **Eine Migration für bereits gebootstrappte Ziele.** Die Anlage ist *skip-if-present*; ein
  gealtertes Ziel bekommt weder den Ort noch eine geänderte Gate-Konfiguration. Die Lücke ist als
  [`BEO-ALL/idempotente-anlage-erreicht-den-bestand-nicht`](../observations/BEO-ALL/idempotente-anlage-erreicht-den-bestand-nicht/observation.md)
  geführt und hat keinen Träger — einen zu erfinden wäre ein anderer Vorgang. *(Es wäre ein anderer
  Vorgang.)*

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) Kriterium 3 steht: `make full-smoke` trägt einen `codepaths`-Zahn im Ziel.** Eine
      erfundene Inline-Pfad-Nennung in einer emittierten Datei färbt `make docs-check` im
      gebootstrappten Ziel mit dem Grund-Code `codepath-missing` rot und wird danach
      zurückgenommen; der Zahn läuft über `modul_zahn_alte_module_gruen` gegen die **vorherige**
      Modul-Liste grün, sonst belegt er nicht, dass erst dieses Modul die Verletzung findet. Die
      rote Ausgabe wird gelesen und in §7 benannt.
- [ ] **(2) Gemessen: Kriterium 2 über dem frisch gebootstrappten Ziel**, netzlos, gegen den in
      [`d-check.mk`](../../../../d-check.mk) gepinnten Digest, in **beiden** Bootstrap-Formen
      (`--lang go` und sprachlos). Die Zahl steht neben ihrem Kommando; grün **oder** rot ist ein
      Ergebnis, nur eine fehlende Messung ist keines.
- [ ] **(3) Die Entscheidung steht in der emittierten Datei** — `codepaths` geht mit, oder es
      bleibt als begründeter Kommentar-Block mit einem Trigger, der **nicht** eingetreten ist
      ([`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
      Setzung 3, letzter Absatz). Beide Ausgänge ziehen
      `TestDCheckConfig_EntschiedeneModulListe` nach; eine Leerstelle ist keiner von beiden.
- [ ] `make gates` grün; `make full-smoke` grün (beide Bootstrap-Formen); `make mutate` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow ([`AGENTS.md`](../../../../AGENTS.md) §6), kein Self-Review (Modul 8).
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
| `harness/tools/full-smoke.sh` | update | der `codepaths`-Zahn aus DoD (1), gebaut nach dem Muster der drei vorhandenen Modul-Zähne samt Gegenprobe gegen die vorherige Modul-Liste |
| `internal/emit/templates/d-check.yml` | update | Ergebnis von DoD (3): Modul-Liste erweitert, oder der Kommentar-Block trägt den neuen, nicht eingetretenen Trigger |
| `internal/emit/emit_test.go` | update | `TestDCheckConfig_EntschiedeneModulListe` hält die entschiedene Liste; er wird nachgezogen, nicht aufgeweicht |
| `test/mutations/` | neu | der Zahn aus DoD (1) bekommt seinen kuratierten Fall — ein neuer Wächter ohne Mutations-Fall ist unbewacht ([`AGENTS.md`](../../../../AGENTS.md) §3.6) |
| die `.d-check.yml` **dieses** Repos | **unverändert** | Dogfood-Ebene, anderer Vertrag |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**`open` → `next`:** keine offene Vorfrage — die Kriterien stehen in
[`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
Setzung 1, und der Auflösungs-Trigger der Position ist eingetreten; `Verantwortlich:` wird dabei
gesetzt.

**Start** (`next` → `in-progress`): Implementer übernimmt, WIP-Limit frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): falls der Zahn aus DoD (1) sich nicht
  bauen lässt, ohne den Aufbau des Voll-E2E-Smokes selbst zu ändern — dann ist die Zahn-Arbeit ein
  eigener Liefer-Wert neben der Modul-Entscheidung.
- `in-progress` → `open` (blockiert — Carveout?): falls die Messung aus DoD (2) rot ausfällt und
  das Rot **aus emittierter Prosa** stammt, die dieser Slice nicht räumen kann. Nach oben heißt
  das, die Vorbedingung ist nicht vollständig geräumt; das gehört zurück in den Schnitt, statt
  Kriterium 2 auf *„weniger Befunde als vorher"* abzusenken.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **(a)** der Zahn aus DoD (1) ist einmal rot gesehen und läuft gegen
die vorherige Modul-Liste grün; **(b)** `make gates`, `make full-smoke` und `make mutate` sind
grün, und die Messung aus DoD (2) liegt mit ihrem Kommando vor.

Dazu: DoD vollständig; Review konform (Modul 10); Verifikation bestätigt (Modul 11); jedes Risiko
aus §6 mit Ausgang; Closure-Notiz mit Steering-Loop-Lerneintrag; `git mv` nach `done/` als eigener
Move-Commit. Den Abschluss schreibt der **Planner** in frischem Kontext, nicht der Lauf, der die
Arbeit gebaut hat ([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Ein aktiviertes Modul im Ziel ist eine Schwellen-Anhebung für jeden Adopter**, und sein Rot
  entsteht dann an Inline-Pfaden, die der Adopter selbst schreibt.
  [`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  hält das für die bessere Fehlrichtung, solange das Rot aus Adopter-Inhalt kommt; ob diese
  Zuordnung für `codepaths` trägt, entscheidet erst die Messung aus DoD (2).
  — **Ausgang:** <offen>
- **Kriterium 1 hat keinen Wächter.** Kein Ziel hält die emittierte Modul-Liste gegen die dieses
  Repos; der Träger ist der Rollen-Wechsel, wie
  [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  selbst feststellt. Dieser Slice misst Kriterium 1 an einem Kommando, nicht an einem Gate.
  — **Ausgang:** <offen>
- **Die Deckung zwischen emittiertem Text und emittiertem Bestand bleibt für alles unbewacht, was
  kein Inline-Pfad ist.** Auch ein mitgehendes `codepaths` prüft Pfade, nicht Aussagen; registriert
  als
  [`BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger`](../observations/BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger/observation.md).
  — **Ausgang:** <offen>
- **Nicht in diesem Slice:** die Modul-Liste dieses Repos, das Modul `planning`
  ([slice-210](slice-210-planning-modul-im-emittierten-doc-gate.md)), das Requirement-Muster von
  `ids`, die Positionen innerhalb von `codepaths`, und jeder Migrationspfad für bereits
  gebootstrappte Repos.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) —
[`internal/emit/`](../../../../internal/emit) und
[`harness/tools/`](../../../../harness/tools) liegen darunter. Die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
führt daneben `harness/tools/` als eigene Sub-Area (`TOOLS`, Greenfield) und `.codex/`; `.codex/`
ist **nicht** berührt, keine Datei aus §3 liegt dort.

**Vorgelagert — offene Beobachtungen sichten:** Die Ablage
[`observations/`](../observations/README.md) ist durchgegangen; je Slug die Zahl der
`evidence/`-Dateien und die erste Zeile seiner `state.md`:

```sh
for s in emittierte-vorlagen-klassifikation-ohne-traeger \
         idempotente-anlage-erreicht-den-bestand-nicht \
         gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse \
         neuer-waechter-ohne-mutations-fall; do
  d="docs/plan/planning/observations/BEO-ALL/$s"
  echo "$s $(ls "$d/evidence" | wc -l)x $(head -1 "$d/state.md")"
done
```

Keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Stände sind beim Übergang `open` → `next` neu abzulesen, nicht von hier zu
übernehmen. Die vier Einträge des Kommandos berühren diesen Slice, weitere Treffer: keine.

- [`emittierte-vorlagen-klassifikation-ohne-traeger`](../observations/BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger/observation.md)
  — **steht über der Schwelle, und dieser Slice ist der Träger seines Ausgangs.** Die `state.md`
  nennt das im Ziel nicht laufende `codepaths` als die verbleibende Wächter-Lücke; steht als
  Risiko in §6.
- [`idempotente-anlage-erreicht-den-bestand-nicht`](../observations/BEO-ALL/idempotente-anlage-erreicht-den-bestand-nicht/observation.md)
  — **getroffen**: eine geänderte Gate-Konfiguration erreicht ein gealtertes Ziel nicht; in §1
  ausdrücklich ausgeschlossen.
- [`gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse`](../observations/BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse/observation.md)
  — **getroffen, sobald die Messung aus DoD (2) rot ausfällt**: Dann steht wieder die Wahl
  zwischen Ausschreiben, Stummschalten und Umformulieren, und ein Kriterium dafür nennt keine
  Quelle.
- [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  — **berührt, in der günstigen Richtung**: DoD (1) legt einen neuen Wächter an, und §3 führt
  seinen kuratierten Fall als eigene Zeile.

**Alle berührten Sub-Areas GF.** Der Modus-Begründungsblock entfällt damit; `*` und `TOOLS` stehen
in der Modus-Deklaration als Greenfield, und dieser Slice führt keine neue Sub-Area ein.
