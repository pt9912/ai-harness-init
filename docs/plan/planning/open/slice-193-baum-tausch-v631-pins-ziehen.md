# Slice slice-193: Der vendored Baum steht auf `v6.3.1` — Pins gezogen, Verweise nachgezogen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Heute besteht kein Bündel, in das er gehörte: Der Sprung ist noch nicht als
Welle eröffnet, und eine Welle-Eröffnung ist ein eigener Planungs-Vorgang mit eigener Datei. Der
Slice ist einzeln lieferbar und hängt nicht daran — sein Wert (genau ein Tag im Baum, Pins und
lebende Adressen darauf) besteht auch, wenn kein Folge-Slice je läuft. Ob der Vorgang insgesamt
eine Welle braucht, entscheidet sich an der Frage aus Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht — ob eine Closure-Bedingung mehr beobachtet als die DoDs der
Mitglieder; sie ist in §6 als offener Punkt geführt und hier nicht beantwortet.

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Pin ist die
Reproduzierbarkeits-Klammer; dieser Slice bewegt ihn),
[`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) (das Werkzeug vendort
dasselbe Asset ins Ziel-Repo — `DefaultTag`/`DefaultBaselineSHA256` sind zwei der fünf Pin-Stellen
und wandern zwingend mit),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(der vendored Baum ist der Gegenstand — committet, netzlos, genau ein Tag),
[`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(eine datierte Mess-Aussage nennt den Tag, gegen den sie gemessen ist — sie wird beim Nachzug
gerade **nicht** gezogen),
[`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) (jeder Verweis in den Baum trägt
seinen Tag — die Pin-Hälfte des Tauschs),
[`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) (Festlegung 3 stellt das
Kriterium, nach dem die regierende Fassung dieses Sprungs bestimmt wird),
[`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (Festlegung 2
nennt Ort und Mindestumfang der Zielstand-Buchung, die dieser Slice auslöst),
[`ADR-0036`](../../adr/0036-ziel-fassung-regiert-den-sprung-v600.md) (regiert den **vorigen**
Sprung; ihr erster Re-Evaluierungs-Trigger ist der Grund, warum dieser Slice auf eine eigene
Entscheidung wartet — §4)

**Berührte Spec-Stellen:** `spec/spezifikation.md` §5 und §7 — **als Adresse, nicht als Aussage.**
Beide Abschnitte zitieren das Regelwerk über `.harness/baseline/v6.0.0/regelwerk/…`-Pfade; der
Tag-Wechsel zieht diese Adressen nach, ohne eine Festlegung des Technik-Stratums zu ändern. Eine
Kennung nennt der Slice nicht: Er berührt keine `SPEC-<NNN>`-Zeile inhaltlich. Der Verweis zeigt
**aufwärts** — die Spec nennt diesen Slice nie (Baseline-Regelwerk
`grundlagen-referenz-richtung.md` §Referenz-Richtung (SDP)).

**Verantwortlich:** `—` bis zur Priorisierung. **Die Zielstand-Buchung in
[`harness/conventions.md`](../../../../harness/conventions.md) §Baseline gehört nicht der
ausführenden Rolle** — die Datei ist Architect-Eigentum
([`AGENTS.md`](../../../../AGENTS.md) §3.8), und ihre Änderung wandert als eigener, die Rolle
nennender Commit in den Ablauf (§3, letzte Zeile).

**Autor:** Planner. **Datum:** 2026-09-06.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**`.harness/baseline/` führt `v6.3.1` als einzigen Baum, die fünf Pin-Stellen nennen denselben Tag
und den sha256 seines Release-Assets, und jede lebende Adresse mit Tag-Segment zeigt dorthin.**

### Der Delta-Katalog — gemessen auf der Achse, die wirklich vendored wird

Das Release-Asset heißt `lab-regelwerk.zip` (`grep -n 'lab-regelwerk' -A 1 .d-check.yml`), und der
Baum darin ist `regelwerk/` + `templates/` (`ls .harness/baseline/v6.0.0/`). Upstream entspricht
das **`lab/regelwerk` + `lab/templates`**, nicht `kurs/de`: Ein Diff über `kurs/de` misst die
Kurs-Fassung, aus der der Baum abgeleitet wird, und ordnet Änderungen anderen Tags zu. Gemessen am
lokalen Kurs-Klon `/Development/KI/ai-harness-course`, Stand `1fdce81`:

```sh
cd /Development/KI/ai-harness-course
git diff --stat v6.0.0..v6.3.1 -- lab/regelwerk lab/templates   # 13 Dateien, +286/-13
for p in v6.0.0..v6.1.0 v6.1.0..v6.2.0 v6.2.0..v6.3.0 v6.3.0..v6.3.1; do
  git diff --stat "$p" -- lab/regelwerk lab/templates; done
```

**Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Beträge sind an die genannten Tags gebunden und an keinen lebenden Baum. Was in
welchem Tag liegt, ist die Voraussetzung des Schnitts unten und deshalb je Tag aufgeschlüsselt:

Die Zellen nennen die Kurs-Dateien mit ihrem **Basisnamen**, relativ zu den zwei Operanden des
Kommandos oben — sie liegen im Kurs-Repo und nicht in diesem, und eine Repo-Adresse für sie zu
schreiben wäre eine, die hier ins Leere zeigt.

| Tag | Regelwerk | Templates | Was es normativ setzt |
|---|---|---|---|
| `v6.1.0` | `modul-07-carveouts` +3 · `modul-10-review-harness` +7 · `modul-13-quality-gates` +6 | `AGENTS.template.md` +7 · `README.template.md` (Einstiegs-Vorlage) +14 | Carveout-Auflösung setzt die Bindung-Spalte zurück · Review-**Deckung** ist mechanisierbar (d-check-Modul `reviews`) · ein feuernder Trigger macht die Entfernung der Hard-Rule-Zeile zum DoD-Punkt · Schritt 8 ist Rollenwechsel, kein Abschluss |
| `v6.2.0` | `modul-05-planning-harness` +3/-3 | `.d-check.yml` +8 · `slice.template.md` +5/-1 | die verpflichtende **Review-Zeile** in der DoD, der auskommentierte `reviews:`-Block mit `done-dir` als Aktivierungs-Schalter, und der Review-Report zählt nicht als Liefer-Punkt |
| `v6.3.0` | `grundlagen-begriffe` +1 · `grundlagen-harness-dateien` +81/-1 · `modul-13-quality-gates` +27 | `README.md` +1 · `README.template.md` (Einstiegs-Vorlage) +33 · **neu** `gate.template.md` +81 | die **Sensors-Regel**: ein Gate je Datei in einem neuen Sensor-Verzeichnis, benannt nach dem Target, ohne `done/`-Lifecycle; Zeitdokumente nennen das Target statt es zu verlinken; dazu *„Ein Gate ohne seine Grenze behauptet ebenfalls zu viel"* und *„Die dritte Lage: genannt, aber kein Gate"* |
| `v6.3.1` | `modul-13-quality-gates` +11/-6 | — | Nachschärfung derselben zwei Absätze |

**Der d-check-Pin-Sprung aus `v6.1.0` ist kein Posten dieses Slice — nachgemessen, nicht
geglaubt.** Er liegt in einem Commit, der `lab/regelwerk`/`lab/templates` **nicht** anfasst
(`git show --stat $(git log --format=%H v6.0.0..v6.1.0 --grep='chore(d-check)')` → `Makefile`,
`d-check.mk`, `lab/example/Makefile`, `lab/example/d-check.mk`), und liegt damit außerhalb des
Assets, das dieses Repo vendort. Die Achse ist zudem deckungsgleich: Kurs und Repo stehen beide auf
`v0.74.1` (`git show v6.3.1:d-check.mk | grep -n DCHECK_IMAGE` gegen
`grep -n DCHECK_IMAGE d-check.mk`) — dieses Repo hat den Sprung mit
[slice-187](../done/slice-187-d-check-pin-v0741.md) selbst vollzogen und pinnt zusätzlich per
Digest. **Der Tausch bringt hier nichts nach.**

### Was dieser Slice nicht tut

Er **entscheidet nichts über die regierende Fassung** — das ist eine Architect-Entscheidung und
sein Start-Trigger (§4). Er **wertet den Delta nicht aus**: welcher Adaptions-Eintrag von der neuen
Fassung eingeholt wird und welche Form-Pflicht dieses Repo trifft, ist der Adaptions-Durchgang, und
der ist ein eigener Slice (§6). Und er **stellt die Sensors-Sektion nicht um**: Die `v6.3.0`-Zeile
der Tabelle oben ist der umfangreichste Posten des Sprungs, sie legt ein neues Verzeichnis an und
berührt zwei lebende Norm-Artefakte — sie in denselben Schnitt zu nehmen hieße, einen vierten
Liefer-Punkt zu tragen und die Zwei-Schichten-Grenze zu reißen.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **Der Baum ist getauscht, und die fünf Pin-Stellen nennen denselben Tag.**
      `.harness/baseline/v6.3.1/{regelwerk,templates}` samt `SHA256SUMS` liegt committet,
      `.harness/baseline/v6.0.0/` ist entfernt, und `make baseline-verify` meldet `v6.3.1 OK`.
      Genau ein Tag liegt im Baum — die Zusage von
      [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
      ist eine Eindeutigkeits-, keine Vollständigkeits-Aussage und wird als solche belegt
      (`ls -d .harness/baseline/v*/ | wc -l` → 1).

      Die **fünf** Stellen sind `BASELINE_TAG`/`BASELINE_ZIP_SHA256` im `Makefile` (kanonisch), das
      `sources`-Paar `url`/`sha256` in [`.d-check.yml`](../../../../.d-check.yml) und
      `DefaultTag`/`DefaultBaselineSHA256` in `internal/fetch/baseline.go`; die vier
      nicht-kanonischen sind fail-closed an das Makefile-Paar gekoppelt und laufen in `make gates`
      (`test/sources-pin.bats`, `TestDefaultTag_MatchesBaseline`,
      `TestDefaultBaselineSHA256_MatchesMakefile`). `make regelwerk-check` (Netz, **nicht** in
      `make gates`) ist grün. Der sha256 wird am **Release-Asset gemessen**, nicht aus einer
      Erwartung übernommen; steht er nicht neben dem Kommando, das ihn liefert, ist der
      Liefer-Punkt offen.

      **Kein Gate deckt die Kopplung Baum↔Pin:** `baseline-verify` entdeckt das
      `<tag>`-Verzeichnis, statt `BASELINE_TAG` zu lesen, und `test/sources-pin.bats` koppelt die
      fünf nur untereinander — beide sind grün, während Baum und Pins verschiedene Tags tragen.
      Präzedenz und dieselbe benannte Lücke:
      [slice-182](../done/slice-182-baum-tausch-v600-pins-ziehen.md) DoD 1.
- [ ] **Kein lebender Verweis zeigt auf den alten Tag, und der Nachzug hat seine Bezugsmenge
      gemessen statt behauptet.** Ausgangslage am Stand dieses Plans, mit dem Kommando daneben
      (**kein Erwartungswert** — die Zahl wandert mit jedem Text, der den Tag nennt):

      ```sh
      P=( '*.md' '*.go' '*.sh' '*.yml' 'Makefile' )
      git grep -l '\.harness/baseline/v6\.0\.0' -- "${P[@]}" | wc -l                       # 82 Dateien
      git grep -c '\.harness/baseline/v6\.0\.0' -- "${P[@]}" | awk -F: '{s+=$NF} END{print s}'  # 233 Vorkommen
      git grep -l '\.harness/baseline/v6\.0\.0' -- "${P[@]}" \
        ':!docs/plan/planning/done' ':!docs/reviews' ':!harness/conventions/done' ':!docs/plan/adr' \
        | wc -l                                                                            # 64 lebende Dateien
      ```

      Die vier ausgenommenen Bestände sind eingefroren — `docs/plan/adr/` nach
      [`AGENTS.md`](../../../../AGENTS.md) §3.4, die drei übrigen als Zeitdokumente bzw. aufgelöste
      Einträge. **Nicht** gezogen werden außerdem zwei Klassen innerhalb der 64, und beide sind vor
      dem Nachzug einzeln auszuweisen: ein **Tree-Operand** (`<sha>:.harness/baseline/v6.0.0/…`),
      dessen Ersetzung aus einem laufenden Kommando eines machte, das `fatal` meldet, und eine
      **datierte Mess-Aussage** nach
      [`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist),
      die den Tag nennt, gegen den sie gemessen wurde. Die vier Symlinks unter `.claude/rules/`
      zeigen auf den neuen Baum (`readlink .claude/rules/*.md | grep -c 'baseline/v6\.0\.0'` → 4
      vor dem Lauf, 0 danach); ihre Zahl bleibt, was
      [`MR-035`](../../../../harness/conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)
      als geschlossene Menge führt.

      **Was `make docs-check` davon trägt:** keinen toten **Link** — nicht *keinen toten Pfad*. Ein
      `.harness/baseline/v6.0.0/…` in Inline-Code ohne Link-Klammer bleibt grün und ist als Pfad in
      den Arbeitsbaum trotzdem tot. Der Beleg ist darum das `git grep` oben, nicht das Gate.
- [ ] **Die Zielstand-Setzung ist verbucht — von der Rolle, der die Datei gehört.** §Baseline von
      [`harness/conventions.md`](../../../../harness/conventions.md) trägt für `v6.3.1` die Zeile
      in der Form aus
      [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2
      — Ziel-Tag, Datum des **Vollzugs**, der Slice mit dem Delta-Nachweis, sonst nichts —, und das
      Feld `Stand:` nennt `v6.3.1`. Die Datei ist Architect-Eigentum
      ([`AGENTS.md`](../../../../AGENTS.md) §3.8): Der ausführende Lauf schreibt sie **nicht**,
      sondern übergibt; die Änderung landet in einem eigenen, die Rolle nennenden Commit, der außer
      Architect-Artefakten nichts berührt. **Der Liefer-Punkt ist erst erfüllt, wenn dieser Commit
      liegt** — er ist Bedingung des Slice, nicht seine eigene Arbeit.
- [ ] `make gates` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register fortgeschrieben, **falls dieser Slice einen Inventur-Fund auflöst** —
      Zeile mit Datum und auflösendem Artefakt nach *Aufgelöste Einträge* verschoben. **Entfällt
      hier:** Repos ohne Brownfield-Bootstrap haben die Datei nicht, und dieses führt sie nicht
      (`ls docs/plan/planning/reconciliation.md` → nicht vorhanden).
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
| `.harness/baseline/v6.3.1/{regelwerk,templates}/` + `SHA256SUMS` | neu | der vendored Baum aus dem verifizierten Release-Asset |
| `.harness/baseline/v6.0.0/` | entfernt | genau ein Tag liegt im Baum ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) |
| `Makefile` (`BASELINE_TAG`, `BASELINE_ZIP_SHA256`) | update | kanonisches Pin-Paar |
| [`.d-check.yml`](../../../../.d-check.yml) (`sources`-`url`/`sha256`) | update | fail-closed an das Makefile-Paar gekoppelt (`test/sources-pin.bats`) |
| `internal/fetch/baseline.go` (`DefaultTag`, `DefaultBaselineSHA256`) | update | dasselbe Asset wandert ins Ziel-Repo ([`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)) |
| `.claude/rules/*.md` (die vier Baseline-Symlinks) | update | Symlink-Ziele tragen das Tag-Segment |
| lebende `*.md`/`*.go`/`*.sh`/`*.yml` mit `.harness/baseline/v6.0.0/`-Adresse | update | Adress-Nachzug; Bezugsmenge und die zwei Nicht-Zieh-Klassen in DoD 2 |
| [`harness/conventions.md`](../../../../harness/conventions.md) §Baseline (`Stand:`, Re-Baseline-Zeile) | update | **Architect-Commit**, nicht Teil des ausführenden Laufs ([`AGENTS.md`](../../../../AGENTS.md) §3.8) |

**Commit-Zuschnitt.** Der Lauf setzt mindestens drei Commits: (1) der Baum-Tausch samt Pins,
(2) der Adress-Nachzug — getrennt, weil er eine andere Prüfung braucht und der Tausch sonst in der
Rename-Detection untergeht ([`AGENTS.md`](../../../../AGENTS.md) §3.3), und (3) — **in einem
anderen Rollen-Kontext** — der Architect-Commit an §Baseline. Der dritte berührt außer
Architect-Artefakten nichts und nennt die Rolle in seiner Message.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`) — **drei Bedingungen, alle beobachtbar, alle erfüllt, bevor der
erste `git`-Befehl läuft:**

1. **Die Entscheidung über die regierende Fassung des Sprungs `v6.0.0` → `v6.3.1` liegt als
   angenommene ADR vor.** Sie ist ein **Übergabe-Artefakt des Architect**, nicht Arbeit dieses
   Slice, und ihr Fehlen ist der Grund, warum er noch nicht priorisiert ist.

   Warum sie fällig ist — nachgelesen, nicht angenommen:
   [`ADR-0036`](../../adr/0036-ziel-fassung-regiert-den-sprung-v600.md) trägt diesen Sprung
   **nicht**. Ihre Festlegung ist ausdrücklich auf `v5.18.0` → `v6.0.0` geschlossen (*„Diese
   Festlegung gilt **nur** für `v5.18.0` → `v6.0.0`"*), ihr Abschnitt §Was diese Festlegung nicht
   tut verwirft die allgemeine Regel *„es regiert stets die Ziel-Fassung"* erneut, und ihr **erster
   Re-Evaluierungs-Trigger** verlangt für den nächsten Sprung eine eigene Messung: *„Der nächste
   Sprung misst neu — beide Stufen, und das Delegat-Delta **netto**."* Dieselbe Bahn ist die von
   [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md), deren
   Festlegung 1 allein den Sprung davor band und deren Re-Evaluierungs-Trigger in
   [`ADR-0036`](../../adr/0036-ziel-fassung-regiert-den-sprung-v600.md) eingelöst wurde; das
   Kriterium selbst steht in
   [`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 und ist mit
   jedem Sprung neu anzuwenden. **Ob die Ziel-Fassung, die gepinnte oder eine dritte Antwort
   regiert, entscheidet dieser Plan nicht** — er stellt fest, dass keine bestehende Entscheidung
   den Fall deckt.

   Die zweistufige Messung (führt die gepinnte Fassung die Prozedur? · haben ihre Delegate ein
   **Netto**-Delta?) liegt beim entscheidenden Lauf — Präzedenz ist
   [`ADR-0036`](../../adr/0036-ziel-fassung-regiert-den-sprung-v600.md) §Kontext, die sie im
   ADR-Lauf selbst gegen die vendored Bäume nachfuhr. Der Delta-Katalog in §1 ist ihr **Material**,
   nicht ihr Ersatz: Er misst Dateien und Zeilen, nicht die Frage, welche Fassung regiert.
2. **[slice-125](../in-progress/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md) liegt in
   `done/`.** Er fasst [`.d-check.yml`](../../../../.d-check.yml) und
   [`harness/README.md`](../../../../harness/README.md) an — beide sind Gegenstand dieses Slice
   (Pin-Stelle bzw. Adress-Nachzug). Zwei Läufe darauf gleichzeitig erzeugen einen Konflikt in
   genau der Datei, deren Grün den Tausch belegen soll.
3. **Die Nacharbeit an
   [`ADR-0037`](../../adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md) ist gelandet.** Solange
   sie läuft, ist der ADR-Baum in Bewegung, und die Entscheidung aus Bedingung 1 entsteht in
   demselben Baum.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn der Adress-Nachzug mehr ist als eine
  mechanische Ersetzung mit zwei benannten Ausnahmen — etwa weil eine Zeilenspann-Bindung
  (`cite`-artig) auf den alten Baum zeigt und von Hand nachzurechnen ist. Dann trennt der Schnitt
  Tausch (Liefer-Punkt 1) und Nachzug (Liefer-Punkt 2) in zwei Slices.
- `in-progress` → `open` (blockiert — Carveout?): wenn ein Gate am neuen Baum rot wird und die
  Ursache in der Ziel-Fassung liegt statt in diesem Repo — der wahrscheinlichste Fall ist eine
  Form-Pflicht aus der `v6.3.0`-Zeile in §1, die ein bestehendes Artefakt bricht. Dann ist der rote
  Status auf einen Trigger zu schalten (Carveout, Baseline-Regelwerk `modul-07-carveouts.md`),
  nicht still zu übergehen.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. `make baseline-verify` meldet `v6.3.1 OK`, `ls -d .harness/baseline/v*/ | wc -l` gibt `1`, und
   `make gates` ist grün — mit gültigem Stempel über dem Baum, der die Closure trägt.
2. Der Adress-Lauf aus DoD 2 trifft außerhalb der vier eingefrorenen Bestände und der zwei
   benannten Nicht-Zieh-Klassen **null**, und die Ausnahmen sind einzeln aufgezählt statt als Zahl
   behauptet.

**Lerneintrag** in einer der drei Formen (geschärfte Regel · neuer Sensor · benannte Spec-Lücke).
Ein Kandidat steht schon fest und ist keine Erfindung der Closure: Die Kopplung **Baum ↔ Pin** hat
in diesem Repo bei jedem Sprung dieselbe Lücke (DoD 1, letzter Absatz) — ob sie eine geschärfte
Regel, einen Sensor oder eine benannte Lücke ergibt, entscheidet die Closure.

**Den Abschluss schreibt der Planner, nicht der Lauf, der den Baum getauscht hat**
([`AGENTS.md`](../../../../AGENTS.md) §3.10) — in eigenem Kontext und in einem Commit, der
ausschließlich Closure-Artefakte berührt.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Tag-Wechsel macht Adressen in eingefrorenen Artefakten tot, und die Entscheidung darüber
  gehört vor den Vollzug.** [`AGENTS.md`](../../../../AGENTS.md) §3.11 verlangt vor einem vom
  Prozess vorgeschriebenen Ortswechsel eine Messung über **beide** Adress-Formen — Code-Span und
  Markdown-Link —, ob ein eingefrorenes Artefakt das bewegte als Pfad nennt. Sie ist hier gefahren
  und trifft nicht null: **18** Dateien in den vier eingefrorenen Beständen nennen
  `.harness/baseline/v6.0.0/…` (3 ADRs, 12 Review-Reports, 3 `done/`-Slices, 0 aufgelöste
  MR-Einträge), **10** davon als Markdown-Link
  (`git grep -lE '\]\([^)]*\.harness/baseline/v6\.0\.0' -- docs/plan/adr docs/reviews
  docs/plan/planning/done harness/conventions/done | wc -l`; kein Erwartungswert). Ein
  ADR-Verweis ist nach §3.4 unantastbar, ein Review-Report ebenso — der Nachzug darf sie nicht
  ziehen, und ihr Ziel liegt nach dem Tausch nicht mehr im Baum. Das ist die Klasse
  `BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot`, deren Zähler bei **4** steht
  (`ls docs/plan/planning/observations/BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot/evidence/*.md | wc -l`)
  und deren Stand `verkörpert` ist — die verkörperte Regel deckt den **künftigen** Schreibfall, den
  Bestand deckt sie nicht. — **Ausgang:** offen; die Closure setzt ihn.
- **Die regierende Fassung ist bei Start noch nicht entschieden.** Dann greift der Start-Trigger
  nicht und der Slice bleibt liegen — das ist die gewollte Wirkung, nicht der Schaden. Der Schaden
  entstünde, wenn der Lauf ohne die Entscheidung tauscht und der spätere Adaptions-Durchgang
  gegen eine Pflichtgliederung misst, die niemand gewählt hat. — **Ausgang:** offen; die Closure
  setzt ihn.
- **Der Sprung läuft ohne eigenen Inventur-Slice, und die Klasse dafür steht bei 2×.**
  `BEO-ALL/re-baseline-ohne-inventur-slice` beschreibt genau diesen Fall — *„die Form-Pflichten der
  neuen Fassung kommen einzeln als Nachzügler zurück statt gebündelt in den Schnitt"* — und zählt
  `slice-148`, `slice-149`
  (`ls docs/plan/planning/observations/BEO-ALL/re-baseline-ohne-inventur-slice/evidence/*.md | wc -l`
  → 2). Hier trägt **dieser Plan** den Katalog (§1, je Tag und je Datei, auf der vendored Achse),
  und der Schnitt ist daraus geschnitten statt geschätzt. Tritt beim Vollzug eine Form-Pflicht auf,
  die der Katalog nicht führt, ist das der **dritte** Eintritt — und damit eine Lücke mit eigenem
  Folge-Slice, keine Notiz. — **Ausgang:** offen; die Closure setzt ihn.
- **Eine Form-Pflicht aus der `v6.3.0`-Zeile bricht ein bestehendes Artefakt beim Tausch.** Der
  wahrscheinlichste Kandidat ist die Sensors-Regel, die
  [`harness/README.md`](../../../../harness/README.md) betrifft — dieser Slice stellt sie nicht
  um, aber der neue Baum steht dann daneben. Bricht dabei ein Gate, ist der Weg der Carveout mit
  Auflösungs-Trigger, nicht das stille Rot. — **Ausgang:** offen; die Closure setzt ihn.
- **Die vendored `slice.template.md` erzeugt in einem Greenfield-Repo bei jedem kopierten Slice
  einen `codepath-missing`-Befund** — ihr Reconciliation-Item führt den Register-Pfad als
  Inline-Code, und `codepaths` prüft Inline-Code-Pfade auf Existenz, während dieses Repo die Datei
  nicht führt (`ls docs/plan/planning/reconciliation.md` → nicht vorhanden). **Der Tausch behebt es
  nicht:** `v6.3.1` fasst die Vorlage zwar an (+5/-1), die Reconciliation-Zeile aber nicht
  (`cd /Development/KI/ai-harness-course && git diff v6.0.0..v6.3.1 --
  lab/templates/docs/plan/planning/slice.template.md | grep -i reconcil` → leer). Der Bestand
  behilft sich, indem der Pfad als **Kommando-Operand** geschrieben wird, der seine eigene
  Abwesenheit belegt; dieser Plan tut es in §2. Ob daraus eine Regel wird, entscheidet nicht dieser
  Slice. — **Ausgang:** offen; die Closure setzt ihn.

### Offene Punkte — was dieser Schnitt bewusst nicht mitnimmt

Kein Risiko, sondern die Begründung der Grenze. Jeder Posten ist eigene Arbeit mit eigenem
Liefer-Wert; **eine Kennung trägt hier keiner**, weil ein genannter Folge-Slice als Datei im
Lifecycle existieren muss (Folge-Slice-Paarung) und das Anlegen dieser Dateien ein eigener
Planungs-Schritt ist.

| Posten | Warum nicht hier |
|---|---|
| **Adaptions-Durchgang** — jeder Eintrag unter [`harness/conventions/`](../../../../harness/conventions/) gegen die neue Fassung, mit den fünf Ausgängen des Freshness-Audits | Er urteilt über **Inhalte**, der Tausch bewegt **Bytes und Adressen**. Präzedenz des vorigen Sprungs: [slice-182](../done/slice-182-baum-tausch-v600-pins-ziehen.md) tauschte, [slice-185](../done/slice-185-adaptions-durchgang-gegen-v600.md) urteilte. Zusammengelegt wäre der Slice weder in einer Review-Sitzung prüfbar noch bei ≤ 3 Liefer-Punkten |
| **Die Sensors-Umstellung** — das Sensor-Verzeichnis unter `harness/` anlegen (je Gate eine nach dem Target benannte Datei), [`harness/README.md`](../../../../harness/README.md) §Sensors auf seine Tabelle zurückführen, die fehlende Sektion `## Safety and scope boundaries` nachtragen, [`AGENTS.md`](../../../../AGENTS.md) §4 nachziehen | Der umfangreichste Posten des Sprungs (§1, `v6.3.0`-Zeile), ein **neues Verzeichnis** und zwei lebende Norm-Artefakte, davon eines in Architect-Eigentum. Er ist zugleich der Träger, aus dem die zwei in §8 gesichteten Register-Einträge ihren Ausgang bekommen — die Migration liefert ihnen die Regel, die dem Repo bisher fehlte |
| **Die Review-Zusage bekommt ihren Wächter** — die `v6.2.0`-DoD-Zeile in Kraft setzen und das d-check-Modul `reviews` (`done-dir` als Aktivierungs-Schalter) in [`.d-check.yml`](../../../../.d-check.yml) aktivieren, dazu die emittierte Fassung unter `internal/emit/templates/` | **Die Übernahme ist entschieden** (Setzung des Auftraggebers) und dieser Slice trägt sie nicht: Er tauscht den Baum, aus dem die neue Vorlage kommt — die DoD-Zeile wirkt damit ab dem Tausch auf jeden **neu kopierten** Plan. Das **Aktivieren** des Moduls ist dagegen ein Gate-Anheben mit eigener Bezugsmenge (`docs/plan/planning/done/` gegen `docs/reviews/`) und braucht seinen eigenen roten Beleg ([`AGENTS.md`](../../../../AGENTS.md) §3.6) |
| **Die emittierte Ebene über den Pin hinaus** — der `reviews:`-Block der `.d-check.yml`-Vorlage, das Sensor-Verzeichnis im Ziel-Repo, `gate.template.md` | Die **Pin**-Hälfte gehört zwingend hierher: `DefaultTag`/`DefaultBaselineSHA256` in `internal/fetch/baseline.go` sind zwei der fünf gekoppelten Stellen, und wer sie stehen ließe, färbt `make gates` rot. Die **Inhalts**-Hälfte gehört nicht: Was ein emittiertes Repo an Struktur bekommt, ist eine eigene Entscheidung mit eigenem Prüfbereich, und `make full-smoke` ist ihr Beleg — nicht `make gates` |
| **Die Wellen-Frage** — braucht dieser Vorgang eine Welle? | Die Antwort hängt daran, ob eine Closure-Bedingung mehr beobachtet als die DoDs der Mitglieder (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht). Sie ist beantwortbar, sobald die Mitglieder feststehen — und die Eröffnung legt eine eigene Datei an, die dieser Lauf nicht schreibt |

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene Kennung **zitieren** statt neu
formulieren — sonst zählt das Register zwei Pfade getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** dieses Repo führt Wellen-Betrieb; sie prüft die nächste Welle-Closure —
  auch für einen Slice ohne Wellen-Zugehörigkeit.

## 8. Sub-Area-Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Umfang.** Der **Modus-Begründungsblock** unten ist Pflicht, sobald
mindestens eine berührte Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei
reinem GF genügt der Hinweis *"alle berührten Sub-Areas GF"*; bei reinem
Refactor ohne neue Sub-Area-Berührung entfällt er ganz. Die beiden
*Vorgelagert*-Blöcke entfallen nie.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area, `*` (`ALL`). Die
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md) führt daneben
`harness/tools/` (`TOOLS`) und `.codex/` (`CODEX`); beide sind **nicht** berührt — kein Skript und
keine Hook-Konfiguration unter diesen Pfaden trägt eine Baseline-Adresse
(`git grep -l '\.harness/baseline/v6\.0\.0' -- harness/tools .codex` → leer). Die einzige
Adress-Berührung außerhalb der Kern-Bäume liegt in `.claude/commands/close-welle.md` und in den
vier Symlinks unter `.claude/rules/`; beide gehören keiner deklarierten Sub-Area an und laufen
unter `ALL`. `ALL` erfüllt die Schwelle als deklarierte Sub-Area mit eigenem Kürzel; eine feinere
Aufteilung wäre hier Erfindung — der Gegenstand ist ein Baum, den das ganze Repo adressiert.

**Vorgelagert — offene Beobachtungen sichten:** Das Register unter
[`../observations/`](../observations/) ist durchgegangen; alle Einträge liegen unter `BEO-ALL` und
treffen die berührte Sub-Area damit formal. Aufgeführt sind die, die **diesen Vorgang** betreffen
— Zähler abgelesen als Dateizahl unter `evidence/`, nicht aus einem Feld
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`; keine
Erwartungswerte):

| Eintrag | Zähler | Stand | Bezug zu diesem Slice |
|---|---|---|---|
| `re-baseline-ohne-inventur-slice` | 2× | offen | **erreicht mit diesem Slice 3×, falls der Katalog in §1 nicht trägt** — als Risiko in §6 geführt |
| `vorgeschriebener-ortswechsel-macht-adresse-tot` | 4× | verkörpert | die 18 eingefrorenen Dateien mit `v6.0.0`-Adresse, §6 erstes Risiko |
| `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht` | 2× | offen | die Slices in `open/`, die gegen `v6.0.0`-Pflichten geschnitten sind, gelten nach dem Tausch gegen `v6.3.1` |
| `verweis-nachzug-bricht-tree-operand` | 1× | offen | die erste der zwei Nicht-Zieh-Klassen in DoD 2 |
| `baseline-sprungweite-treibt-kosten` | 1× | offen | vier Tags auf einmal; die Aufschlüsselung je Tag in §1 ist die Antwort darauf |
| `mess-zusage-trifft-das-eigene-zitat` | 1× | offen | die Kommando-Zeilen dieses Plans nennen Kurs-Tags als Operanden; sie dürfen beim Nachzug nicht gezogen werden ([`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)) |
| `einstiegs-datei-weicht-von-der-pflichtgliederung-ab` | 0× | offen | **gesichtet, hier nicht aufgelöst** — die fehlende Sektion `## Safety and scope boundaries`; die Migration bringt die Regel, die Umstellung ist eigene Arbeit (§6) |
| `benannte-luecke-ohne-ausgang` | 0× | offen | **gesichtet, hier nicht aufgelöst** — *„kein `sensors/done/`"* ist genau die Austrags-Regel, die `v6.3.1` mitbringt; ihr Ausgang entsteht mit der Sensors-Umstellung, gesetzt wird er von einer Closure, nicht von diesem Plan |

Die letzten beiden tragen heute **kein** `evidence/`-Verzeichnis — der Zähler ist damit null, und
das ist der abgelesene Stand, keine Auslassung
(`find docs/plan/planning/observations/BEO-ALL/benannte-luecke-ohne-ausgang -type f`). Ihre
Bezeichnungen sind hier **zitiert**, nicht neu formuliert, damit das Register sie nicht als zwei
Pfade zählt.

**Modus:** alle berührten Sub-Areas **GF** — der Begründungsblock entfällt damit nach der
Umfangs-Regel dieser Sektion. Der Modus ist keine Folge der Slice-Größe, sondern der Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md) §Modus-Deklaration pro Sub-Area, die
`*` als Greenfield führt.
