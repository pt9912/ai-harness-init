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
  [slice-210](slice-210-planning-modul-im-emittierten-doc-gate.md) entscheidet die Modul-**Liste** —
  eine andere Fläche.
- **Der Bestand.** Ziele, die vor dieser Emission entstanden, werden nicht nachgerüstet; gebunden ist
  die Vorlage, die geschrieben wird.
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

- [ ] **Das Ziel führt den Wächter, gebunden an die zwei history-lesenden Targets** — er läuft
      **vor** dem Modul-Lauf, nicht danach. Der Beleg ist `make full-smoke` über einem
      gebootstrappten Ziel, nicht eine Zeile im Emit-Code.
- [ ] **Der Fall aus [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
      Setzung 3 ist rot gesehen:** ein Klon der Tiefe 1 mit einer leeren Range meldet **nicht**
      `0 Befund(e)`/Exit 0, sondern bricht mit einer Meldung ab; dieselbe Sonde auf einem
      vollständigen Klon bleibt grün. Ausgabe und Exit-Code gelesen, nicht nur der Exit-Code.
- [ ] **Keine neue Host-Abhängigkeit** und kein Image-Lauf vor dem Modul-Lauf: der Wächter läuft mit
      `bash + git` ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)),
      und der Fehlt-Fall sagt etwas, statt still zu bleiben.
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
  Ebene tiefer steht. — **Ausgang:** <eingetreten: CO-NNN / slice-<Kennung> | entfallen: Grund |
  weiter offen: → BEO im Register>
- **Die Werkzeug-Lücke im Nachbar-Repo bleibt offen.** Der Wächter umgeht sie (er fängt vor dem
  Modul-Lauf ab), er schließt sie nicht; ihre Abhilfe liegt in einem anderen Baum. Erreicht die
  Beobachtung mit diesem Slice einen weiteren Beleg, ist sie keine Notiz mehr und braucht einen
  eigenen Folge-Slice. — **Ausgang:** <eingetreten: CO-NNN / slice-<Kennung> | entfallen: Grund |
  weiter offen: → BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse im Register>
- **Der Pin bewegt sich unter dem Slice weg.** Ein Sprung, der die Range-Behandlung im Modul ändert,
  entwertet die Verdrahtung, nicht ihre Absicht. — **Ausgang:** <eingetreten: CO-NNN /
  slice-<Kennung> | entfallen: Grund | weiter offen: → BEO im Register>

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
  — **3×, geplant** ([slice-202](slice-202-der-tote-inline-pfad-unter-harness-bekommt-seinen-pruefer.md)).
  Trägt seinen Ausgang bereits. Für diesen Slice heißt das: Baseline-Pfade stehen hier als
  **Markdown-Link** (dort prüft `links`), nicht als Inline-Code — die Verengung gilt auch hier.

Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.
