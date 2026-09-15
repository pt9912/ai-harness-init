# Slice slice-lifecycle-move-geht-ins-ziel: Der Lifecycle-Move zieht seine Verweise im Ziel nach

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case.

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-emittierte-werkzeuge](welle-emittierte-werkzeuge.md). Die Welle trägt das
*Mehr* über dieser DoD: ihr Closure-Trigger fährt die neu emittierten Werkzeuge im gebootstrappten
Ziel einmal durch (`make full-smoke`) — einen Beleg, den kein Punkt dieser DoD führt
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Ebene: emittiert, nicht Dogfood.** Gegenstand ist die Command-Vorlage, die das Werkzeug in ein
fremdes Ziel schreibt. Der Anweisungssatz **dieses** Repos bleibt draußen und hat einen benannten
Ausgang ([slice-226](../done/slice-226-implementer-anweisungssatz-zieht-nach.md), §5 der Welle).

**Bezug:**
[`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) (die
emittierte Anleitung — sie schreibt den Lifecycle-Wechsel vor),
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (die
repo-spezifischen Stellen bleiben adaptierbare Marker),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein
Kommando behaupten, das im Ziel nicht läuft),
[ADR-0042](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 2 (die zwei
Pfad-Ausnahmen des Nachzugs sind Repo-Politik),
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (ein Anweisungssatz
gehört der Rolle, die ihn ausführt).

**Berührte Spec-Stellen:** `—`. Der Slice ändert eine Emissions-Vorlage; kein Zielelement der
Spec-Straten wird angefasst.

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-14.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Der emittierte `implement-slice.md` schreibt den Lifecycle-Wechsel an zwei Stellen als
**Handarbeit** vor — und lässt den **Verweis-Nachzug** entfallen, den der Dogfood automatisiert hat.
Das Ziel bekommt das Werkzeug und den Satz, der darauf zeigt.

### Der Anlass ist am Baum gemessen

Die emittierte Command-Vorlage nennt `git mv` viermal und kennt den Nachzug nicht; der Dogfood hat
beides getrennt:

```sh
grep -c 'git mv' internal/emit/templates/commands/implement-slice.md   # 4
git grep -c 'slice-mv' -- internal/emit internal/gen | wc -l           # 0
```

**Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — beide wandern mit dem Baum. Die zwei Stellen sind **Schritt 9** (der Eintritt nach
`in-progress/`) und **Schritt 24** (die Closure nach `done/`); jede verlangt einen *reinen* Move und
überlässt den Verweis-Nachzug dem Lauf. Genau dort bricht es in der Praxis: der Move macht Pfade
tot, und die Reparatur ist Handarbeit, die niemand anweist.

**Das Werkzeug existiert und ist fast generisch.** `harness/tools/slice-mv.sh` bewegt den Slice,
committet den reinen Move sofort als eigenen Commit und zieht danach **eingehende** und
**ausgehende** Verweise nach — jede Präfix-Form mit einer Regel statt einer Musterliste. Seine
einzigen Repo-Bindungen sind **zwei** Pathspec-Ausschlüsse (der unveränderte Fremdtext der vendored
Baseline und die `Accepted`-ADR), und beides ist Repo-Politik nach
[ADR-0042](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 2 — im Ziel also
adaptierbarer Marker, kein hart verdrahteter Wert
([`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Anweisungssatz dieses Repos.** Gegenstand ist die **emittierte** Vorlage; die lokale Fassung
  zieht über [slice-226](../done/slice-226-implementer-anweisungssatz-zieht-nach.md) nach (Dogfood, eigener
  Ausgang). Beide in einem Slice hieße, zwei Verträge mit einem Diff zu bedienen.
- **Die dritte Hälfte eines Ortswechsels.** Ein bewachtes **Zustandsfeld** nachzuziehen ist ein
  eigener Vorgang; er liegt bei
  [slice-ortswechsel-zieht-sein-zustandsfeld-nach](../open/slice-ortswechsel-zieht-sein-zustandsfeld-nach.md).
  Das Werkzeug deckt **Verweise**, nicht Zustandsfelder — die Grenze bleibt an beiden Stellen benannt.
- **Der Nachzug über die Ebene.** Dass die emittierte Vorlage der ausgeführten nachläuft, hält keine
  Quelle zusammen; die Klasse ist im Register gezählt und die Welle schließt sie nicht mit (Welle
  §5/§6).
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

- [x] **Der emittierte Anweisungssatz nennt für Schritt 9 und Schritt 24 das Werkzeug** statt des
      `git mv` von Hand, und die repo-spezifischen Stellen bleiben **adaptierbare** Marker
      ([`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)) — der
      Adopter darf sein Fragment anders nennen — und *was* daran frei ist, steht hier, weil der
      Satz sonst zwei Lesarten trägt: die **Datei** ist frei (der Aggregator bindet
      `harness/mk/*.mk` per Glob ein), der **Ziel-Name** darin ist es **nicht** — er kommt aus einem
      tool-eigenen Fragment, das jeder Bootstrap kanonisch neu schreibt.
- [x] **Das Ziel führt das Werkzeug, und es zieht Verweise in beiden Richtungen nach:** eingehende
      (jede Präfix-Form auf die bewegte Datei) und ausgehende (präfixlose Ziele innerhalb der
      bewegten Datei). Der Move bleibt ein **reiner** Commit, getrennt von der Inhaltsänderung; fiel
      keine Änderung an, bleibt es beim einen Commit. Beide Richtungen sind im Ziel belegt, nicht im
      Emit-Code behauptet.
- [x] **Fehlt eine Voraussetzung, sagt das Werkzeug das und committet nichts** — der unsaubere
      Arbeitsbaum ist der benannte Fall. Rot gesehen: den Fall herstellen, Kommando fahren, Ausgabe
      und Exit-Code lesen. Die zwei Pfad-Ausnahmen sind als Repo-Politik **markiert**, nicht
      versteckt.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: [`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md) führt
      **beide** Fassungen des Werkzeugs — die dieses Repos und die, die im Ziel liegt — und nennt die
      zweite samt ihrem Ort und ihrer Verdrahtung; die zwei Pfad-Ausnahmen stehen dort als Politik des
      jeweiligen Repos, **setzbar** auch im Ziel.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit). **Hier nicht geprüft und nicht fällig:** dieses Repo führt Wellen, und der Slice ist Mitglied von [welle-emittierte-werkzeuge](welle-emittierte-werkzeuge.md) — den Lese-Schritt trägt ihre Closure.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/commands/implement-slice.md` | update | die zwei Stellen (9, 24) nennen das Werkzeug statt der Handarbeit |
| `internal/emit/templates/enforce/` bzw. ein Fragment im emittierten Fragment-Verzeichnis | neu/update | das Ziel bekommt den Nachzug als Ziel und die Vorlage daneben |
| `Makefile` (`full-smoke`) | update | der Beleg aus DoD (2) |
| `test/…` | neu/update | die zwei Ersetzungsrichtungen und der unsaubere Baum — DoD (2)/(3) |

**Das Werkzeug wird übernommen, nicht neu gebaut.** `harness/tools/slice-mv.sh` trägt die Regel für
den eingehenden Nachzug (ein Vorkommen von `<von>/<datei>` an einer Wortgrenze, statt einer
Musterliste, die driftet) und trennt seine Ersetzungs-Funktionen von `main()`, damit ein Test sie
ohne `git`-Repo rufen kann. Die Emission übernimmt diese Form; die **Repo-Politik** darin — die zwei
Pfad-Ausnahmen — wird als Marker ausgewiesen.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Der Slice ist priorisiert (`Verantwortlich:` gesetzt) und das
WIP-Limit frei. **Keine harte Bindung an den Dogfood-Zwilling:**
[slice-226](../done/slice-226-implementer-anweisungssatz-zieht-nach.md) zieht den lokalen Anweisungssatz auf
eine **andere** Ziel-Fassung nach; die zwei Ebenen dürfen auseinanderlaufen, solange die Richtung
stimmt — erst die ausgeführte Fassung, dann die emittierte (Welle §5).

**Reihenfolge innerhalb der Welle:** unabhängig von den drei übrigen Mitgliedern; die vier Flächen
sind disjunkt.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn der eingehende **und** der ausgehende
  Nachzug zusammen nicht in einer Review-Sitzung prüfbar sind — dann ist der Schnitt an der
  Richtung zu schneiden, nicht die DoD länger zu machen.
- `in-progress` → `open` (blockiert — Carveout?): wenn der Nachzug im Ziel eine Repo-Entscheidung
  verlangt, die kein Marker trägt (etwa eine dritte Pfad-Ausnahme) — dann gehört erst die
  Entscheidung, dann der Slice.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; `make full-smoke` grün über einem gebootstrappten Ziel **und** die beiden
Nachzug-Richtungen dort belegt; `make gates` grün; Closure-Notiz mit Steering-Loop-Lerneintrag.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Nachzug ist im Ziel nicht entscheidbar, wo er auf fremde Texte trifft.** Das Werkzeug
  ersetzt in **jedem** Vorkommen an einer Wortgrenze; in einem Ziel, das dieselbe Slice-Kennung in
  einem Fremd-Text führt (vendored Baseline, eingefrorene ADR), wäre die Ersetzung falsch. Die zwei
  Pfad-Ausnahmen decken die zwei Fälle **dieses** Repos, nicht die des Ziels. — **Ausgang: entfallen**
  — die zwei Ausnahmen sind im Ziel **setzbar**, nicht versteckt: das Fragment führt die Variable mit
  einer Vorgabe und reicht sie als Umgebung an das Werkzeug durch, das Skript liest sie mit derselben
  Vorgabe beim Auslesen. Die Vorgabe ist aus dem mitemittierten Regelwerk abgeleitet und deckt genau
  die zwei Fremd-Text-Klassen, die es auch im Ziel gibt — vendored Baseline und die eingefrorene ADR;
  eine andere Politik ist ein **gesetzter Wert**, keine Unmöglichkeit. Am ausgelieferten Fragment
  gelesen:

  ```sh
  grep -n 'SLICE_MV_AUSGENOMMENE_PFADE' internal/emit/templates/enforce/slice-mv.mk
  #  27:SLICE_MV_AUSGENOMMENE_PFADE ?= :!.harness/baseline :!docs/plan/adr
  #  34:	@SLICE_MV_AUSGENOMMENE_PFADE='$(SLICE_MV_AUSGENOMMENE_PFADE)' bash "$(SLICE_MV)" "$(SLICE)" "$(TO)"
  ```
- **Der ausgehende Nachzug kollidiert mit dem Ziel-Ruheort.** Er trifft präfixlose Ziele *innerhalb*
  der bewegten Datei; trägt das Ziel eine andere Lifecycle-Tiefe, ist die Vorgabe falsch. Die
  Vorlage muss die Tiefe ableiten, nicht annehmen. — **Ausgang: entfallen** — der ausgehende Nachzug
  setzt keine Tiefe: er liest sein Von-Verzeichnis aus dem gefundenen Pfad und hängt **ein**
  `../<altes-verzeichnis>/` an. Dass die zwei Verzeichnisse Geschwister sind, ist keine Annahme über
  das Ziel, sondern Eigenschaft der emittierten Planungs-Ablage, in der die vier
  Lifecycle-Verzeichnisse flach nebeneinander liegen. Im gebootstrappten Ziel ist die Richtung
  gefahren: `make full-smoke` stellt dort das verbliebene Geschwister im Ausgangsverzeichnis her und
  liest das gezogene Ziel.
- **Die zwei Fassungen driften weiter ungeobachtet.** Kein Sensor hält den lokalen Anweisungssatz
  gegen die emittierte Vorlage; die zwei sind getrennte Artefakte, und dieses Mitglied schreibt die
  emittierte Fassung, nicht den Wächter. Die Lücke bleibt benannt (Welle §6) und ist der Grund, den
  Nachzug nicht still zu lassen. — **Ausgang: weiter offen** → Beobachtungs-Register,
  [`BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`](../observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/observation.md)
  — dieselbe Regel liegt als lauffähige Dogfood-Fassung und als Text der Emissions-Vorlage vor, und
  kein Sensor hält die zwei gegeneinander; das ist die Klasse dieses Falls, und sie trifft ihn enger
  als eine Zusage **neben** einer Ableitung. **Dieser Vorgang legt dort keinen Beleg an, und das ist
  gemessen, nicht angenommen:** er schreibt die emittierte Fassung und weist an ihr keine Drift gegen
  die lokale nach. Der Zähler des Eintrags bleibt darum, wo er war — **kein Erwartungswert**, die
  Zahl wandert mit dem Register:

  ```sh
  ls docs/plan/planning/observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/evidence/*.md | wc -l
  # 2
  ```

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** **Die Form lag schon vor, und die Emission hat sie getragen statt sie
  nachzubauen.** Die zwei Ersetzungs-Richtungen des Dogfood-Werkzeugs sind in die Emissions-Vorlage
  übernommen, und `test/slice-mv.bats` vergleicht die **Rümpfe** der drei Ersetzungs-Funktionen
  beider Fassungen weißraum-normalisiert — eine Form, die eine Musterliste nicht trägt: sie hält die
  *Regel* statt einer Formen-Aufzählung. **Zweitens hat der E2E getragen**, obwohl er im Plan nur als
  Beleg geführt war: [`make full-smoke`](../../../../harness/sensors/full-smoke.md) fährt die Kette
  Aggregator → Fragment → abgelegtes Skript → `git` in einem gebootstrappten Ziel, und dort erst ist
  [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) eingelöst statt behauptet.
  **Drittens die fail-closed-Kante:** eine fehlende Voraussetzung bricht ab, statt zu committen, und
  der E2E fährt diesen Zweig wirklich.
- **Was ging anders als geplant:** **Vier Dinge.** (1) Der Doku-Punkt nannte **keinen Träger**; er war
  der einzige Punkt, den die erste Verifikation als Verletzung gelesen hat, und ist auf
  [`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md) gezogen und dort erfüllt.
  (2) Sein Schlusssatz trug **zwei Lesarten** und war in der zweiten mit jeder Lieferung verletzt — er
  ist auf die Fassung gezogen, die nach dem Nachzug trägt. (3) §3 nennt `Makefile` als Träger des
  Belegs; der Beleg liegt in `harness/tools/full-smoke.sh`, das sein Rezept ruft — die Wirkung war die
  geplante, die Adresse eine Ebene zu hoch. (4) Der E2E brauchte einen **zweiten** Zweig: über einem
  Slice ganz ohne Verweis fällt der Nachzug-Commit aus, und genau das ist die Zusage der beiden
  Richtungen.
- **Steering-Loop-Eintrag:** *Neuer Sensor* — `test/slice-mv.bats` hält die drei
  Ersetzungs-Funktionen der zwei Fassungen (Dogfood-Werkzeug und Emissions-Vorlage)
  weißraum-normalisiert gegeneinander, und `test/mutations/346` gibt dem Fall seine Zähne: er fällt
  über einer **einseitig** entfernten Entscheidung, mit beiden Rümpfen in der Meldung. Das ist die
  Antwort auf [`BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`](../observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/observation.md)
  **für dieses Paar** — geschlossen an einer Stelle, nicht als Klasse. **Kein `liegt in`-Feld:** mit
  diesem Vorgang ist **keine** Regel dieses Repos verkörpert worden — der Sensor ist Liefergegenstand
  und keine Antwort auf einen 3×-Schwellen-Übertritt; der Eintrag ist gezählt, nicht verkörpert.
  **Die vier Grenzen, die dieser Vorgang benennt statt sie zu schließen** — keine davon ist eine
  DoD-Verletzung, alle vier gehen als Material in den Lese-Schritt:

  1. **Die Mutations-Deckungslücke.** Von den **sieben** Wächtern in `internal/emit/slicemv_test.go`
     sind **drei** über einen Fall in `test/mutations/` gedeckt und **vier** nicht; einer der vier
     trägt seine rote Richtung außerhalb des Mutations-Satzes (die fail-closed-Kante fällt im E2E,
     und dort ist sie rot gelesen), die drei übrigen haben ihre rote Richtung nicht vorgeführt.
     Beleg: [`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md).
  2. **Die Anker-Grenze der `schritteIn`-Hilfe.** Sie schlüsselt eine Anleitung über die **Nummer**
     des Schrittes auf und **überschreibt** einen Schlüssel, der ein zweites Mal in Spalte 0 auftritt;
     die Annahme *eindeutige Nummern* steht nirgends, und im heutigen Bestand greift die Verletzung
     nicht.
  3. **Die kanonische Neuschrift des Fragments hält kein Wächter** — die Aussage ist **wahr** und
     **unbewacht**; die Grenze steht jetzt benannt an der Stelle der Zusage, geschlossen ist sie
     nicht. Beleg:
     [`BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel`](../observations/BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel/observation.md).
  4. **Eine eingefrorene Commit-Message.** Die Message des Doku-Nachzugs sagt mehr, als gemessen ist
     („der E2E liest die Vorlage nicht" — er liest sie, nur nicht die **Nennung** des Aufrufs). Der
     Satz der Sensor-Prosa ist exakt, der Bericht daneben zu breit; die Message liegt in `git` und
     wird nicht repariert.

  Die Messungen dazu — jede Zahl steht neben dem Kommando, das sie liefert:

  ```sh
  for g in $(grep -oE '^func Test[A-Za-z_]+' internal/emit/slicemv_test.go | sed 's/func //'); do \
    printf '%s  %s\n' "$(grep -rl "expect: $g" test/mutations/ | wc -l)" "$g"; done
  #  1  TestSliceMvFragment_LiegtImZielUndHaengtNichtAnDerGatesKette
  #  1  TestSliceMvWerkzeug_LiegtAusfuehrbarUndTraegtBeideRichtungen
  #  0  TestSliceMvAusnahmen_SindAlsRepoPolitikMarkiert
  #  0  TestSliceMvFragment_ReichtDieAusnahmenAlsUmgebungDurch
  #  0  TestSliceMvFragment_TraegtDieFailClosedKante
  #  1  TestSliceMvAnleitung_NenntDasWerkzeugAnDenZweiStellen
  #  0  TestSliceMvWerkzeug_IstNichtDerDogfoodPfad
  grep -oE '^[0-9]+\. ' internal/emit/templates/commands/implement-slice.md | sort | uniq -d | wc -l   # 0 Dubletten
  grep -cE '^[0-9]+\. ' internal/emit/templates/commands/implement-slice.md                            # 25 Nummern
  ```
- **Beobachtungs-Register (`../observations/`):** **Ein neues Verzeichnis, zwei Belege an vorhandenen
  Einträgen.** Neu angelegt:
  [`BEO-ALL/lebendes-register-traegt-eine-ueberholte-fundliste`](../observations/BEO-ALL/lebendes-register-traegt-eine-ueberholte-fundliste/observation.md)
  — ein lebender Norm-Eintrag zählt namentlich die Stellen auf, an denen seine Form noch nicht greift,
  und das Kommando daneben liefert sie nicht mehr; die Klasse ist neu, ihre zwei Nachbarn sind enger
  (eine Zahl bzw. eine Aufzählung im **selben** Text). Beleg `evidence/slice-lifecycle-move-geht-ins-ziel.md`
  in [`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  (die vier Wächter ohne Fall) und in
  [`BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel`](../observations/BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel/observation.md)
  (die wahre, unbewachte Zusage). **Kein Zähler wird gesetzt**, er folgt aus den Dateien — die drei
  Zahlen mit ihrem Kommando:

  ```sh
  for s in neuer-waechter-ohne-mutations-fall zusage-ohne-herstellbares-gegenbeispiel \
           lebendes-register-traegt-eine-ueberholte-fundliste; do
    printf '%-52s %s\n' "$s" "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)"
  done
  # neuer-waechter-ohne-mutations-fall                        7
  # zusage-ohne-herstellbares-gegenbeispiel                   3
  # lebendes-register-traegt-eine-ueberholte-fundliste        1
  ```

  Der zweite Eintrag erreicht mit diesem Beleg die Schwelle; **den Ausgang weist der Lese-Schritt der
  Wellen-Closure zu**, nicht diese Notiz.
- **Folge-Slices:** **keiner aus diesem Vorgang geschnitten.** Die vier benannten Grenzen liegen als
  Belege im Register; ob eine davon einen eigenen Schnitt bekommt, entscheidet der Lese-Schritt der
  [welle-emittierte-werkzeuge](welle-emittierte-werkzeuge.md)-Closure.
- **Risiken aus §6:** drei Risiken, drei Ausgänge — **zweimal *entfallen***, **einmal *weiter
  offen***, jeder mit seiner Begründung in §6.
- **Drei Paarungen:** von der
  [welle-emittierte-werkzeuge](welle-emittierte-werkzeuge.md)-Closure getragen (dieser Slice ist
  ihr Mitglied), **hier nicht geprüft**. Was sie vorfindet, ist gelegt: kein `liegt in`-Feld in §7 —
  nichts verkörpert, also keine Anker-Paarung; kein Folge-Slice genannt, also keine
  Folge-Slice-Paarung; und jede hier genannte Beobachtung existiert als Verzeichnis mit nicht leerem
  `evidence/`.

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
`internal/emit/` liegt in keiner engeren Sub-Area der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area). Die
**emittierte** Ebene ist keine Sub-Area dieses Repos: sie ist ein anderer Vertrag, und die
Deklaration führt sie nicht.

**Vorgelagert — offene Beobachtungen sichten:** das Register durchgegangen. **Zwei Treffer**, beide
mit ihrem Zähler-Stand (die Zahl der Dateien unter `evidence/`, abgelesen mit
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l` — kein gespeicherter Wert):

- [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  — **24×, offen.** Berührt: dass der emittierte Satz der ausgeführten Fassung nachläuft, hält keine
  Quelle zusammen. Dieses Mitglied schreibt die **Vorlage**, nicht die Klammer; die Lücke steht als
  Risiko in §6 und als Out-of-Scope in Welle §6.
- [`BEO-ALL/verweise-brechen-beim-ortswechsel`](../observations/BEO-ALL/verweise-brechen-beim-ortswechsel/observation.md)
  — **6×, offen.** Berührt: der Gegenstand des Werkzeugs ist genau diese Klasse, und
  `make slice-mv` deckt sie im Dogfood seit `slice-144`. Für das Ziel heißt das: der Nachzug ist
  belegt, nicht behauptet — die zwei Richtungen sind im gebootstrappten Ziel zu fahren.

Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.
