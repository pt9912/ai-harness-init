# Slice slice-vorlauf-waechter-geht-ins-ziel: Der Vorlauf-Wächter der zwei history-lesenden Targets geht ins Ziel

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
emittierte Durchsetzungs-Mechanik — ein Vorlauf-Wächter ist Gate-Mechanik),
[`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) (die
zwei Targets kommen aus dem tool-generierten `d-check.mk`),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Gate, das über leerem Prüfbereich grün meldet, behauptet mehr als es prüft),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (der Wächter läuft
mit `bash + git`),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
Setzung 3 (die Klasse *blind und grün*, an der der Anlass gemessen ist),
[`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
(die Default-Regel für emittierte Prüfbereiche).

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

**Ziel:** Ein gebootstrapptes Ziel bricht bei einer auflösbaren, aber **leeren** Commit-Range an seinen
zwei history-lesenden Targets ab — statt `0 Befund(e)`, Exit 0 zu melden und damit blind grün zu
sein.

### Der Anlass ist am Baum gemessen

Das Ziel bekommt `doc-commits` und `doc-immutable` aus dem tool-generierten `d-check.mk`. Beide
lesen Historie über `--range`. Im **Dogfood** laufen sie nie allein: der Vorlauf-Wächter steht als
eigenes Glied davor. Im **Ziel** fehlt beides — Ziel und Wächter:

```sh
grep -c 'history-range-guard' Makefile                       # 5 — Target, Konsumenten-Ketten, Kommentare
git grep -c 'history-range-guard' -- internal/ | wc -l       # 0 — kein Ziel kennt ihn
```

**Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — beide Zahlen wandern mit dem Baum. Das Werkzeug selbst ist
[`harness/tools/history-range-guard.sh`](../../../../harness/tools/history-range-guard.sh) und rein:
`bash + git`, kein Netz, kein Image. Es prüft **vor** dem teuren Modul-Lauf, dass die angeforderte
Range git-seitig auflösbar **und nicht leer** ist — genau die zwei Bedingungen, an denen das Modul
selbst nicht unterscheidet.

**Der Wächter deckt eine benannte Grenze, nicht alles.** Eine **unauflösbare** Basis bricht schon
ohne ihn mit Exit 2 ab (*object not found*); was er fängt, ist die auflösbare, aber im flachen Klon
**leere** Range. Diese Grenze bleibt im Ziel benannt und wird nicht überdehnt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Werkzeug-Lücke im Nachbar-Repo.** `doc-commits` ist am gepinnten Stand zusätzlich
  unbedienbar, solange `commits.id-patterns` eine nicht-leere Liste trägt; die Abhilfe liegt in
  einem anderen Baum und hat hier keine Adresse
  ([`BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse`](../observations/BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse/observation.md),
  1×). Dieser Slice umgeht sie, er schließt sie nicht — eine zweite Fassung der Anforderung hier wäre
  die Doppelführung, die das Register vermeidet.
- **Das Modul `vcs`/`commits` selbst.** Ob `d-check` eine leere Range selbst von der leeren Menge
  unterscheidet, ist eine Anforderung an das Nachbar-Repo. Der
  [slice-210](../open/slice-210-planning-modul-im-emittierten-doc-gate.md) entscheidet die Modul-**Liste** —
  eine andere Fläche.
- **Der Bestand.** Ziele, die vor dieser Emission entstanden, werden nicht nachgerüstet; gebunden ist
  die Vorlage, die geschrieben wird.
- **Die Verarbeitungs-Logik des Werkzeugs.** Der Slice **emittiert** eine Vorlage und bindet sie ein;
  was das Werkzeug sonst gegenüber einem Ziel tut — Skelett-Erzeugung, Init-Pfad — bleibt unberührt.
  Angemerkt ist damit **nicht** `internal/` als Ganzes: `internal/emit/` ist die Emissions-Schicht
  selbst, und §3 arbeitet dort. *Schicht-Abgrenzung.*

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

- [x] **Das Ziel führt den Wächter, gebunden an die zwei history-lesenden Targets** — er läuft
      **vor** dem Modul-Lauf, nicht danach. Der Beleg ist `make full-smoke` über einem
      gebootstrappten Ziel, nicht eine Zeile im Emit-Code.
- [x] **Der Fall aus [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
      Setzung 3 ist rot gesehen:** ein Klon der Tiefe 1 mit einer leeren Range meldet **nicht**
      `0 Befund(e)`/Exit 0, sondern bricht mit einer Meldung ab — dieselbe Sonde mit einer
      **aufgelösten, nicht leeren** Range (`HEAD~1..HEAD`) auf einem vollständigen Klon bleibt grün.
      Ausgabe und Exit-Code gelesen, nicht nur der Exit-Code.
- [x] **Keine neue Host-Abhängigkeit** und kein Image-Lauf vor dem Modul-Lauf: der Wächter läuft mit
      `bash + git` ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)),
      und der Fehlt-Fall sagt etwas, statt still zu bleiben.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: die Aufzählung der emittierten Werkzeuge, soweit dieser Slice sie wachsen lässt.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit). **Hier nicht geprüft und nicht fällig:** dieses Repo führt Wellen, und der Slice ist Mitglied von [welle-emittierte-werkzeuge](../welle-emittierte-werkzeuge.md) — den Lese-Schritt trägt ihre Closure.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/enforce/` | neu | die Vorlage des Wächters reist wie die Hooks mit — das Ziel bekommt ihn, statt ihn nachzubauen |
| `internal/emit/emit.go` bzw. ein Fragment im emittierten Fragment-Verzeichnis | update | das Fragment bindet den Wächter **vor** die zwei history-lesenden Targets; die Targets selbst kommen aus dem tool-generierten `d-check.mk` und werden nicht handkopiert ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)) |
| `Makefile` (`full-smoke`) | update | der Beleg aus DoD (1) |
| `test/…` | neu/update | Happy/Negative nach DoD (2): leere Range, volle Range, fehlende Tiefe |

**Der Wächter wird nicht neu erfunden.** `harness/tools/history-range-guard.sh` trägt die Logik und
trennt seine reine Entscheidung von der `git`-Abfrage — die Form, die das gepinnte bats-Image ohne
`git` testbar macht. Die Emission übernimmt sie; über die Ziel-Verdrahtung entscheidet der Plan,
nicht eine zweite Implementierung.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Der Slice ist priorisiert (`Verantwortlich:` gesetzt) und das
WIP-Limit frei. Keine Vorbedingung aus einer **anderen** Welle: der d-check-Pin, gegen den die zwei
Targets laufen, steht in `d-check.mk` und im Emit-Code und ist nicht Gegenstand dieses Slice.

**Reihenfolge innerhalb der Welle:** unabhängig von den drei übrigen Mitgliedern. Die Flächen sind
disjunkt — dieses Mitglied fasst das `doc-gate.mk`-Fragment und die `enforce`-Vorlagen an, kein
anderes Mitglied tut das.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn der Wächter sich nicht in die
  emittierte Fragment-Form bringen lässt, ohne die zwei Targets aus dem tool-generierten
  `d-check.mk` zu **ersetzen** — dann trägt der Zuschnitt nicht, und die Zerlegung ist eine andere.
- `in-progress` → `open` (blockiert — Carveout?): wenn ein Pin-Sprung meldet, dass `d-check` die
  leere Range selbst von der leeren Menge unterscheidet — dann hat der Slice keinen Gegenstand mehr.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; `make full-smoke` grün über **beiden** Zweigen aus DoD (2) (leere Range → Meldung,
volle Range → grün); `make gates` grün; Closure-Notiz mit Steering-Loop-Lerneintrag.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Wächter sitzt vor einem Image-Lauf, dessen Range der Aufrufer setzt.** Ein Vorgabe-Wert,
  den niemand setzt (etwa `HEAD..HEAD`), machte ihn dauerhaft rot und erzöge zum Überlesen —
  dieselbe Klasse, gegen die
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine
  Ebene tiefer steht. — **Ausgang: entfallen** — die Verdrahtung trägt **keinen** Vorgabe-Wert. Die
  Range setzt der Aufrufer, das Ziel steht darum außerhalb von `GATE_CHECKS`, und ohne Range fällt
  der Aufruf laut ab, statt in einen Wert hineinzulaufen, den niemand gepflegt hat:

  ```sh
  make history-range-guard                                        # ohne RANGE
  # harness/tools/history-range-guard.sh: Zeile 147: 1: Usage: history-range-guard.sh <base>..<head> | --staged | --decide <range> <count> | --decide-staged <0|1>
  # make: *** [Makefile:165: history-range-guard] Fehler 1
  # EXIT=2
  ```

- **Die Werkzeug-Lücke im Nachbar-Repo bleibt offen.** Der Wächter umgeht sie (er fängt vor dem
  Modul-Lauf ab), er schließt sie nicht; ihre Abhilfe liegt in einem anderen Baum. Erreicht die
  Beobachtung mit diesem Slice einen weiteren Beleg, ist sie keine Notiz mehr und braucht einen
  eigenen Folge-Slice. — **Ausgang: weiter offen** → Beobachtungs-Register,
  [`BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse`](../observations/BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse/observation.md).
  **Dieser Vorgang legt dort keinen Beleg an, und das ist gemessen, nicht angenommen:** er umgeht
  die Lücke, statt sie zu beobachten (§8), und `commits.id-patterns` ist unberührt. Der Zähler des
  Eintrags bleibt darum, wo er war — **kein Erwartungswert**
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2), die Zahl wandert mit dem Register; die Schwellen-Folgerung zieht der Lese-Schritt aus
  dem Lauf, nicht aus dieser Zeile
  ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
  Setzung 2):

  ```sh
  ls docs/plan/planning/observations/BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse/evidence/*.md | wc -l   # 1
  ```

- **Der Pin bewegt sich unter dem Slice weg.** Ein Sprung, der die Range-Behandlung im Modul ändert,
  entwertet die Verdrahtung, nicht ihre Absicht. — **Ausgang: entfallen** — kein Pin-Sprung in
  diesem Vorgang, und die eine Hälfte, die ein Sprung bewegen könnte, ist fail-closed gebunden: die
  zwei Ziel-Namen kommen aus dem tool-generierten `d-check.mk`, das Fragment prüft ihre
  Ziel-Definition **vor** der Vorbindung und bricht mit Exit 2 ab, wenn sie fehlt. Die andere Hälfte
  — ein Modul, das eine **leere** Range selbst von der leeren Menge unterscheidet — macht den
  Wächter überflüssig, nicht falsch; sie ist die Rückführung aus §4 und nicht eingetreten.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** **Die Form lag schon vor, und die Emission hat sie getragen statt sie
  nachzubauen.** Die Entscheidung des Wächters ist eine reine Funktion, getrennt von der
  `git`-Abfrage — dieselbe Trennung, die ihn im gepinnten bats-Bild ohne `git` testbar macht —, und
  das emittierte Skript übernimmt sie bis auf die Test-Einstiege unverändert. **Zweitens hat die
  fail-closed Probe getragen**, obwohl sie nicht im Plan stand: sie macht aus einem **stillen Grün**
  (Ziel-Zeile ohne Rezept) einen lauten Abbruch, und sie deckt genau die Fläche, auf die ein
  tool-generiertes Fragment baut.
- **Was ging anders als geplant:** **Vier Dinge, und drei davon hat der Lauf sichtbar gemacht.**
  (1) Der DoD-Punkt 2 war in seiner ersten Fassung **nicht erfüllbar**: er verlangte die grüne
  Hälfte über einer leeren Range, und die kann in keinem Klon grün werden — die ausführende Rolle
  ist auf die einzige tragende Range ausgewichen und hat den Plan-Text als Übergabe gelassen; der
  Planner hat ihn vor der Umsetzung gezogen. (2) §3 nannte das `Makefile` als Träger des Belegs;
  der Beleg liegt in `harness/tools/full-smoke.sh`, das sein Rezept ruft — die Wirkung war die
  geplante, die Adresse eine Ebene zu hoch. (3) Die fail-closed Entscheidung war als **Variable**
  gebaut und damit von der Kommandozeile überschreibbar; das fand erst die vierte Runde, und es ist
  an der Stelle geschlossen. (4) Die Vorbindung braucht eine **eigene** Prüfung der Ziel-Definition
  — weder §1 noch §2 nannten sie; sie ist der Grund, aus dem eine fehlende Ziel-Zeile nicht still
  wird.
- **Steering-Loop-Eintrag:** *Neuer Sensor* — das emittierte Doc-Gate-Fragment bindet
  `doc-immutable` und `doc-commits` an einen Vorlauf-Wächter, der über einer auflösbaren, aber
  **leeren** Commit-Range **vor** dem Modul-Lauf mit einer Meldung abbricht, und hält die
  Vorbindung selbst fail-closed an die Ziel-Definition des tool-generierten `d-check.mk`.
  **Kein `liegt in`-Feld:** mit diesem Vorgang ist **keine** Regel dieses Repos verkörpert worden —
  der Sensor ist Liefergegenstand der *emittierten* Ebene und keine Antwort auf einen
  3×-Schwellen-Übertritt. Der Eintrag ist gezählt, nicht verkörpert. **Was der Lese-Schritt der
  [welle-emittierte-werkzeuge](../welle-emittierte-werkzeuge.md)-Closure vorfindet**, sind zwei
  Einträge, die mit diesem Vorgang die Schwelle erreichen — sie stehen unter *Beobachtungs-Register*
  und warten dort auf ihren Ausgang.
- **Beobachtungs-Register (`../observations/`):** **Ein neues Verzeichnis, vier Belege an
  vorhandenen Einträgen.** Neu angelegt:
  [`BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`](../observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/observation.md)
  — dieselbe Entscheidungslogik liegt als Dogfood-Fassung und als Emissions-Vorlage vor, und kein
  Sensor vergleicht die zwei; eine einseitige Änderung ließe beide Suiten grün und die Zusage ihrer
  Gleichheit still falsch werden. Beleg `evidence/slice-vorlauf-waechter-geht-ins-ziel.md` in
  [`BEO-ALL/zusage-nennt-zwei-kanten-der-sensor-deckt-eine`](../observations/BEO-ALL/zusage-nennt-zwei-kanten-der-sensor-deckt-eine/observation.md)
  (die Zusage „der Wächter läuft **vor** dem Modul-Lauf" gilt beiden Zielen, der Smoke urteilt die
  Ordnung nur über eines, und die blinde Grün-Hälfte ist nur für eines gefahren),
  [`BEO-ALL/abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt`](../observations/BEO-ALL/abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt/observation.md)
  (der nicht erfüllbare DoD-Punkt 2),
  [`BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle`](../observations/BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle/observation.md)
  (Review-Befund-Kennungen als Namen und Ausgabe in neuen Skript-Zeilen; die Klausel im Konjunktiv
  über die verworfene Alternative) und
  [`BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`](../observations/BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht/observation.md)
  („zweimal gefahren" in der Sensor-Prosa, ohne Kommando daneben und seither gewachsen). **Kein
  Zähler wird gesetzt**, er folgt aus den Dateien — **keine Erwartungswerte**
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). **Die zwei Schwellen-Übertritte dieses Vorgangs sind gezählt, nicht zugewiesen** — den
  Ausgang weist der Lese-Schritt zu
  ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
  Setzung 2):

  ```sh
  for s in zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor zusage-nennt-zwei-kanten-der-sensor-deckt-eine \
           abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt \
           kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle \
           zahl-ohne-kommando-trifft-ihren-gegenstand-nicht; do
    printf '%-60s %s\n' "$s" "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)"
  done
  # zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor    1
  # zusage-nennt-zwei-kanten-der-sensor-deckt-eine               3
  # abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt   3
  # kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle 10
  # zahl-ohne-kommando-trifft-ihren-gegenstand-nicht             14
  ```

- **Folge-Slices:** **keiner aus diesem Vorgang geschnitten.** Die eine offen gebliebene Lücke —
  der Smoke prüft die **Ordnung** nur für eines der zwei Ziele, für das andere nur die Nennung —
  liegt als Beleg im Register; ob sie einen eigenen Schnitt bekommt, entscheidet der Lese-Schritt
  der Wellen-Closure, nicht diese Notiz. Die Werkzeug-Lücke im Nachbar-Repo bleibt ohne Adresse in
  diesem Baum (§1, §6).
- **Risiken aus §6:** drei Risiken, drei Ausgänge — **zweimal *entfallen***, **einmal *weiter
  offen***, jeder mit seiner Begründung in §6.
- **Drei Paarungen:** von der [welle-emittierte-werkzeuge](../welle-emittierte-werkzeuge.md)-Closure
  getragen (dieser Slice ist ihr Mitglied), **hier nicht geprüft**. Was sie vorfindet, ist gelegt:
  kein `liegt in`-Feld in §7 — nichts verkörpert, also keine Anker-Paarung; kein Folge-Slice
  genannt, also keine Folge-Slice-Paarung; und jede hier genannte Beobachtung existiert als
  Verzeichnis mit nicht leerem `evidence/`.

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

**Vorgelagert — offene Beobachtungen sichten:** das Register durchgegangen, zwei Treffer für diese
Fläche, jeder mit seinem Zähler-Stand (die Zahl der Dateien unter `evidence/`, abgelesen mit
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l` — kein gespeicherter Wert,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1):

- [`BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse`](../observations/BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse/observation.md)
  — **1×, offen.** Berührt: der Gegenstand ist eine Lücke im gepinnten Werkzeug, und dieses Target
  ist die Stelle, an der sie auftritt. Steht als Risiko in §6. Der Zähler bewegt sich nur, wenn
  dieser Slice die Klasse **beobachtet** statt sie zu umgehen — er umgeht sie.
- [`BEO-ALL/gate-modul-erreicht-den-vendored-baum-nicht`](../observations/BEO-ALL/gate-modul-erreicht-den-vendored-baum-nicht/observation.md)
  — **3×, geplant** ([slice-202](../open/slice-202-der-tote-inline-pfad-unter-harness-bekommt-seinen-pruefer.md)).
  Trägt seinen Ausgang bereits. Für diesen Slice heißt das: Baseline-Pfade stehen hier als
  **Markdown-Link** (dort prüft `links`), nicht als Inline-Code — die Verengung gilt auch hier.

Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.
