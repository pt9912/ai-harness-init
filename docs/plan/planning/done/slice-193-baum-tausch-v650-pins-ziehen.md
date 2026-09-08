# Slice slice-193: Der vendored Baum steht auf `v6.5.0` — Pins gezogen, Verweise nachgezogen

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
Kriterium der regierenden Fassung; Festlegung 2 trennt Prozedur und Ist-Maßstab und trägt hier,
solange der Tausch aussteht),
[`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (Festlegung 2
nennt Ort und Drei-Teil-Form der Zielstand-Buchung, die dieser Slice auslöst),
[`ADR-0038`](../../adr/0038-ziel-fassung-regiert-den-sprung-v650.md) (die regierende Fassung
**dieses** Sprungs; `Proposed`, und ihre Annahme ist Start-Bedingung 1 in §4)

**Berührte Spec-Stellen:** `spec/spezifikation.md` §5 und §7 — **als Adresse, nicht als Aussage.**
Beide Abschnitte zitieren das Regelwerk über `.harness/baseline/v6.0.0/regelwerk/…`-Pfade; der
Tag-Wechsel zieht diese Adressen nach, ohne eine Festlegung des Technik-Stratums zu ändern. Eine
Kennung nennt der Slice nicht: Er berührt keine `SPEC-<NNN>`-Zeile inhaltlich. Der Verweis zeigt
**aufwärts** — die Spec nennt diesen Slice nie (Baseline-Regelwerk
`grundlagen-referenz-richtung.md` §Referenz-Richtung (SDP)).

**Verantwortlich:** Implementer (pt9912). **Die Zielstand-Buchung in
[`harness/conventions.md`](../../../../harness/conventions.md) §Baseline gehört nicht der
ausführenden Rolle** — die Datei ist Architect-Eigentum
([`AGENTS.md`](../../../../AGENTS.md) §3.8), und ihre Änderung wandert als eigener, die Rolle
nennender Commit in den Ablauf (§3, letzte Zeile).

**Autor:** Planner. **Datum:** 2026-09-07.

**Form dieses Plans:** die Ziel-Form der **gepinnten** Fassung `v6.0.0`
(`templates/docs/plan/planning/slice.template.md` — §1 *Ziel*, §8
*Sub-Area-Modus-Begründung*). Das ist keine Wahl dieses Plans, sondern
[`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 2: Prozedur und
Ist-Maßstab sind während des Wechsels zwei Fassungen, und bis der Baum getauscht ist, bleibt die
gepinnte für jede Konformitäts-Frage maßgeblich. Die Umbenennung beider Abschnitte in `v6.4.0`
steht darum in §1 als Delta-Posten und nicht in dieser Gliederung.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**`.harness/baseline/` führt `v6.5.0` als einzigen Baum, die fünf Pin-Stellen nennen denselben Tag
und den sha256 seines Release-Assets, und jede lebende Adresse mit Tag-Segment zeigt dorthin.**

Der Zielstand ist gesetzt, nicht abgeleitet: Der Auftraggeber hat ihn am 2026-09-07 auf `v6.5.0`
gezogen, verbucht in [`harness/conventions.md`](../../../../harness/conventions.md) §Baseline —
dem Ort, den [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
Festlegung 2 dafür vorgibt. Nach welcher Fassung der Sprung läuft, entscheidet
[`ADR-0038`](../../adr/0038-ziel-fassung-regiert-den-sprung-v650.md): die Ziel-Fassung `v6.5.0`.

### Der Delta-Katalog — gemessen auf der Achse, die wirklich vendored wird

Das Release-Asset heißt `lab-regelwerk.zip` (`grep -n 'lab-regelwerk' -A 1 .d-check.yml`), und der
Baum darin ist `regelwerk/` + `templates/` (`ls .harness/baseline/v6.0.0/`). Upstream entspricht
das **`lab/regelwerk` + `lab/templates`**, nicht `kurs/de`: Ein Diff über `kurs/de` misst die
Kurs-Fassung, aus der der Baum abgeleitet wird, und ordnet Änderungen anderen Tags zu. Die
Byte-Gleichheit dieser Achse ist in
[`ADR-0038`](../../adr/0038-ziel-fassung-regiert-den-sprung-v650.md) §Die Achse belegt und hier
nicht zweitgemessen. Gemessen am lokalen Kurs-Klon `/Development/KI/ai-harness-course`, Stand
`ac94c33` — eine **Host-Voraussetzung**, kein Artefakt dieses Repos:

```sh
K=/Development/KI/ai-harness-course
git -C "$K" diff --numstat v6.0.0 v6.5.0 -- lab/regelwerk lab/templates \
  | awk '{a+=$1;d+=$2;n++} END{printf "%d Dateien  +%d  -%d\n", n,a,d}'   # 32 Dateien  +624  -153
for p in v6.0.0..v6.1.0 v6.1.0..v6.2.0 v6.2.0..v6.3.0 \
         v6.3.0..v6.3.1 v6.3.1..v6.4.0 v6.4.0..v6.5.0; do
  git -C "$K" diff --numstat "$p" -- lab/regelwerk lab/templates; done
```

**Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Beträge sind an die genannten Tags gebunden und an keinen lebenden Baum. Was in
welchem Tag liegt, ist die Voraussetzung des Schnitts unten und deshalb je Tag aufgeschlüsselt.
Die Zellen nennen die Kurs-Dateien mit ihrem **Basisnamen**, relativ zu den zwei Operanden des
Kommandos oben — sie liegen im Kurs-Repo und nicht in diesem, und eine Repo-Adresse für sie zu
schreiben wäre eine, die hier ins Leere zeigt. **`regelwerk/README.md` ist in jedem Schritt mit
`+1/-1` dabei und in keiner Zeile genannt:** Das ist die Stand-Zeile des Baums
(`git -C "$K" show v6.5.0:lab/regelwerk/README.md | sed -n '3p'` → `**Stand:** Kurs-Welle 128 ·
2026-09-06.`), kein Regel-Delta.

| Tag | Regelwerk | Templates | Was es normativ setzt |
|---|---|---|---|
| `v6.1.0` | `modul-07-carveouts` +3 · `modul-10-review-harness` +7 · `modul-13-quality-gates` +6 | `AGENTS.template.md` +7 · `README.template.md` (Einstiegs-Vorlage) +14 | Die Carveout-Auflösung setzt die **Bindung**-Spalte in `harness/README.md` §Sensors zurück · Review-**Deckung** ist mechanisierbar (d-check-Modul `reviews`), die Kategorisierung bleibt inferential · ein feuernder Trigger macht die Entfernung der Hard-Rule-Zeile zum DoD-Punkt des auslösenden Slice · Schritt 8 des Minimal Agent Workflow ist Rollenwechsel, kein Abschluss |
| `v6.2.0` | `modul-05-planning-harness` +3/-3 | `.d-check.yml` +8 · `slice.template.md` +4/-1 | die verpflichtende **Review-Zeile** in der DoD, der auskommentierte `reviews:`-Block mit `done-dir` als Aktivierungs-Schalter, und der Review-Report zählt **nicht** als Liefer-Punkt |
| `v6.3.0` | `grundlagen-begriffe` +1 · `grundlagen-harness-dateien` +80/-1 · `modul-13-quality-gates` +27 | `README.md` +1 · `README.template.md` +33 · **neu** `gate.template.md` +81, erste Datei einer neuen Vorlagen-Ebene | die **Sensors-Regel**: ein Gate je Datei unter `harness/sensors/<target>.md`, sobald sein Vertrag mehr als einen Satz braucht; die Tabellenzeile bleibt und wird ihr Index, die **Target-Zelle wird zum Link**; kein `sensors/done/` — ein retiriertes Gate ist weg; Zeitdokumente schreiben `make <target>` als Token statt als Pfad |
| `v6.3.1` | `modul-13-quality-gates` +10/-7 | — | Nachschärfung derselben zwei Absätze |
| `v6.4.0` | `modul-05-planning-harness` +46/-1 · `modul-06-roadmap` +3/-1 · `modul-09-implementierung` +9 | `README.md` +10/-6 · `slice.template.md` +36/-10 | die **Out-of-Scope-Disziplin** im Slice-Plan: §1 heißt *Ziel und Abgrenzung*, je Ausschluss eine Begründung, **vier Klassen** als Suchraster (Folge-Slice mit Kennung, die die Sendung annimmt · bewusst stehender Bestand · anderer Vorgang · Schicht-Abgrenzung), keine Mindestzahl und kein Sensor darauf; §8 heißt *Sub-Area-Prüfungen und Modus-Begründung*, weil die zwei vorgelagerten Prüfungen unbedingt sind und nur der Begründungsblock bedingt |
| `v6.5.0` | 21 Dateien, davon mit Regel-Delta `grundlagen-harness-dateien` +52/-22 · `grundlagen-traceability` +41 | `archiv-stub-slice` +8 · `archiv-stub-welle` +8 · `welle-results` +8 · `review-report` +18/-2 | die **Zitier-Form** als stehender Norm-Block in vier einfrierenden Vorlagen (Kennung statt Adresse: `slice-NNN` statt Lifecycle-Pfad, `make <target>` statt Sensor-Datei-Link, eine Baseline-Stelle als `v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt> statt als Link) · die **RTM-Gegenrichtung** *Anforderung → Beleg*, erzeugt statt gepflegt, mit dem **Slice** als entlastender Spalte und der ADR ausdrücklich **nicht** als Quittung |

**Die `v6.4.0`- und `v6.5.0`-Zeilen tragen zwei Posten, die diesen Plan selbst betreffen**, und
beide sind hier Delta, nicht Gliederung: Die Umbenennung von §1 und §8 und die Zitier-Form gelten
ab dem Tausch für neu kopierte Artefakte — bis dahin ist die gepinnte Fassung der Ist-Maßstab
(Kopf, letztes Feld).

**Die Tabellenform ist in `v6.5.0` eine eigene Rauschklasse.** 17 der 25 im letzten
Release-Schritt berührten Dateien ändern **nur** die Markdown-Tabellenform;
[`ADR-0038`](../../adr/0038-ziel-fassung-regiert-den-sprung-v650.md) §Was das Messinstrument
diesmal mitzählt führt die Messung. Wer die Roh-Beträge der `v6.5.0`-Zeile als Regel-Delta liest,
überschätzt sie — deshalb nennt die Zelle die zwei Dateien mit Regel-Delta einzeln.

**Der d-check-Pin-Sprung aus `v6.1.0` ist kein Posten dieses Slice — nachgemessen, nicht
geglaubt.** Er liegt in einem Commit, der `lab/regelwerk`/`lab/templates` **nicht** anfasst
(`git -C "$K" show --stat $(git -C "$K" log --format=%H v6.0.0..v6.1.0 --grep='chore(d-check)')`
→ `Makefile`, `d-check.mk`, `lab/example/Makefile`, `lab/example/d-check.mk`), und liegt damit
außerhalb des Assets, das dieses Repo vendort. Die Achse ist zudem deckungsgleich: Kurs und Repo
stehen beide auf `v0.74.1` (`git -C "$K" show v6.5.0:d-check.mk | grep -n DCHECK_IMAGE` gegen
`grep -n DCHECK_IMAGE d-check.mk`) — dieses Repo hat den Sprung mit
[slice-187](../done/slice-187-d-check-pin-v0741.md) selbst vollzogen und pinnt zusätzlich per
Digest. **Der Tausch bringt hier nichts nach.**

### Warum das ein Slice bleibt — die Größen-Achsen sind gegen den Ziel-Tag invariant

Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Slice nennt drei Abbruch-Kriterien.
Alle drei sind hier gemessen, und keines hängt daran, **welcher** Tag das Ziel ist:

- **≤ 3 Liefer-Punkte.** Es bleiben die drei aus §2 — Baum samt Pins, Adress-Nachzug,
  Zielstand-Buchung. Was der weitere Sprung mitbringt, ist **Inhalt**; dieser Slice bewegt
  **Bytes und Adressen**. Die Zahl der Pin-Stellen ist 5, die der Bäume nach dem Lauf 1, die der
  Adress-Formen 2 (Link und Pfad) — jede davon ist eine Eigenschaft dieses Repos, nicht des
  Ziel-Tags.
- **Höchstens zwei Schichten.** Berührt sind der vendored Baum (Daten) und die Adress-Schicht
  (Pins, Markdown, Symlinks). Ein Delta über 32 statt über 13 Kurs-Dateien fügt keine dritte hinzu.
- **In einer Review-Sitzung prüfbar.** Der prüfbare Teil ist der Adress-Nachzug über die lebenden
  Dateien; seine Menge ist **64** und wandert mit dem Bestand, nicht mit dem Ziel-Tag (Kommando in
  §2, Liefer-Punkt 2).

**Geteilt wird deshalb nicht.** Was *wächst*, ist die Liste in §6 §Offene Punkte — und die zählt
nach derselben Sektion nicht in die Größe, weil sie beschreibt, was der Slice **nicht** liefert.

### Was dieser Slice nicht tut

Er **entscheidet nichts über die regierende Fassung** — das tut
[`ADR-0038`](../../adr/0038-ziel-fassung-regiert-den-sprung-v650.md), und ihre Annahme ist sein
Start-Trigger (§4). Er **wertet den Delta nicht aus**: welcher Adaptions-Eintrag von der neuen
Fassung eingeholt wird und welche Form-Pflicht dieses Repo trifft, ist der Adaptions-Durchgang, und
der ist ein eigener Slice (§6). Und er **setzt keine der sechs Form-Pflichten um**, die die Tabelle
oben führt — Sensors-Verzeichnis, Zitier-Form, RTM-Gegenrichtung, Out-of-Scope-Disziplin,
Review-Wächter, Carveout-Bindungsspalte. Jede davon urteilt über bestehende Artefakte; der Tausch
legt nur den Text daneben, an dem sie gemessen werden. §6 §Offene Punkte führt sie einzeln mit
Begründung.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **Der Baum ist getauscht, und die fünf Pin-Stellen nennen denselben Tag.**
      `.harness/baseline/v6.5.0/{regelwerk,templates}` samt `SHA256SUMS` liegt committet,
      `.harness/baseline/v6.0.0/` ist entfernt, und `make baseline-verify` meldet `v6.5.0 OK`.
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
      Liefer-Punkt offen. **Dieser Plan nennt ihn nicht** — ihn hier zu führen hieße, eine Zahl
      ohne ihr Kommando zu setzen
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).

      **Kein Gate deckt die Kopplung Baum↔Pin:** `baseline-verify` entdeckt das
      `<tag>`-Verzeichnis, statt `BASELINE_TAG` zu lesen, und `test/sources-pin.bats` koppelt die
      fünf nur untereinander — beide sind grün, während Baum und Pins verschiedene Tags tragen.
      Präzedenz und dieselbe benannte Lücke:
      [slice-182](../done/slice-182-baum-tausch-v600-pins-ziehen.md) DoD 1.
- [x] **Kein lebender Verweis zeigt auf den alten Tag, und der Nachzug hat seine Bezugsmenge
      gemessen statt behauptet.** Ausgangslage am Stand dieses Plans, mit dem Kommando daneben
      (**kein Erwartungswert** — die Zahl wandert mit jedem Text, der den Tag nennt):

      ```sh
      P=( '*.md' '*.go' '*.sh' '*.yml' 'Makefile' )
      git grep -l '\.harness/baseline/v6\.0\.0' -- "${P[@]}" | wc -l                       # 93 Dateien
      git grep -c '\.harness/baseline/v6\.0\.0' -- "${P[@]}" | awk -F: '{s+=$NF} END{print s}'  # 285 Vorkommen
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
- [x] **Die Zielstand-Buchung ist vollzogen — von der Rolle, der die Datei gehört.** §Baseline von
      [`harness/conventions.md`](../../../../harness/conventions.md) trägt für `v6.5.0` die Zeile
      in der Drei-Teil-Form aus
      [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2
      — Ziel-Tag, Datum des **Vollzugs**, der Slice mit dem Delta-Nachweis, sonst nichts —, und das
      Feld `Stand:` nennt `v6.5.0`. Diese Buchung ist die Architect-Folgepflicht, die
      [`ADR-0038`](../../adr/0038-ziel-fassung-regiert-den-sprung-v650.md) §Konsequenzen *fällig
      mit dem Baum-Tausch* stellt. Die Datei ist Architect-Eigentum
      ([`AGENTS.md`](../../../../AGENTS.md) §3.8): Der ausführende Lauf schreibt sie **nicht**,
      sondern übergibt; die Änderung landet in einem eigenen, die Rolle nennenden Commit, der außer
      Architect-Artefakten nichts berührt. **Der Liefer-Punkt ist erst erfüllt, wenn dieser Commit
      liegt** — er ist Bedingung des Slice, nicht seine eigene Arbeit.
- [ ] `make gates` grün. **Offen und vom Carveout gedeckt** — nicht stillschweigend übergangen:
      `make docs-check` meldet am Stichtag 2026-09-08 `948 Datei(en) geprüft, 36 Befund(e)`, EXIT 1;
      die neun übrigen Ziele der `record-gates`-Kette sind einzeln nachgefahren und grün
      (`make -k baseline-verify lint build test shell-lint ci-lint comment-claims host-bin span-check`
      → EXIT 0). Alle 36 tragen den Grund-Code `target-missing` und liegen in einfrierenden
      Artefakten, deren Reparatur [`AGENTS.md`](../../../../AGENTS.md) §3.4 und §3.11 sperren.
      **`CO-006`** schaltet diesen Status auf einen beobachtbaren Auflösungs-Trigger, wie
      Baseline-Regelwerk `modul-05-planning-harness.md` §Closure- und Lerneintrag-Regeln es für
      den Übergang nach `done/` bei rotem Gate verlangt; der Folge-Slice ist `slice-197`. Der
      Haken bleibt leer, weil die Zusage nicht eingelöst ist — gedeckt ist der Übergang, nicht
      die Zusage.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register fortgeschrieben, **falls dieser Slice einen Inventur-Fund auflöst** —
      Zeile mit Datum und auflösendem Artefakt nach *Aufgelöste Einträge* verschoben. **Entfällt
      hier:** Repos ohne Brownfield-Bootstrap haben die Datei nicht, und dieses führt sie nicht
      (`ls docs/plan/planning/reconciliation.md` → nicht vorhanden).
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit). **Der Träger ist benannt, und ein Befund für ihn liegt vor:** Die zweite Hälfte der Register-Paarung (c) ist rot, zwei von 70 Einträgen führen ein leeres `evidence/` (§7, letzter Punkt) — Vorbestand, nicht von diesem Slice erzeugt.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.harness/baseline/v6.5.0/{regelwerk,templates}/` + `SHA256SUMS` | neu | der vendored Baum aus dem verifizierten Release-Asset |
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

1. **[`ADR-0038`](../../adr/0038-ziel-fassung-regiert-den-sprung-v650.md) steht auf `Accepted`.**
   Sie entscheidet die regierende Fassung des Sprungs `v6.0.0` → `v6.5.0` und ist ein
   **Übergabe-Artefakt des Architect**, nicht Arbeit dieses Slice. Beobachtbar an
   `grep -m1 '^\*\*Status:\*\*' docs/plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md`.

   Solange sie `Proposed` trägt, ist sie ein Architect-Verdikt und bindet nicht
   ([`AGENTS.md`](../../../../AGENTS.md) §3.4 bindet ab `Accepted`) — ihr eigener
   Acceptance-Trigger verlangt eine Reviewer-Runde gegen
   [`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md),
   [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) und
   [`ADR-0036`](../../adr/0036-ziel-fassung-regiert-den-sprung-v600.md) mit Report ohne
   blockierenden Befund unter `docs/reviews/`. **Dass diese Bedingung heute unerfüllt ist, ist die
   gewollte Wirkung**: Der Slice bleibt liegen, bis die normative Quelle des Vorgangs steht.

   **Warum überhaupt eine eigene Entscheidung:**
   [`ADR-0036`](../../adr/0036-ziel-fassung-regiert-den-sprung-v600.md) trägt diesen Sprung nicht —
   ihre Festlegung ist ausdrücklich auf `v5.18.0` → `v6.0.0` geschlossen, und ihr erster
   Re-Evaluierungs-Trigger verlangt für den nächsten Sprung eine eigene zweistufige Messung samt
   Netto-Frage. Dieselbe Bahn ist die von
   [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md); das Kriterium
   selbst steht in [`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 3
   und ist mit jedem Sprung neu anzuwenden. Der Delta-Katalog in §1 ist **Material** dieser
   Messung, nicht ihr Ersatz: Er misst Dateien und Zeilen, nicht die Frage, welche Fassung regiert.
2. **[slice-125](../done/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md) liegt in
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
  Ursache in der Ziel-Fassung liegt statt in diesem Repo — die wahrscheinlichsten Fälle sind die
  Sensors-Regel aus `v6.3.0` und die Zitier-Form aus `v6.5.0`, die beide auf lebende Norm-Artefakte
  zielen. Dann ist der rote Status auf einen Trigger zu schalten (Carveout, Baseline-Regelwerk
  `modul-07-carveouts.md`), nicht still zu übergehen.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. `make baseline-verify` meldet `v6.5.0 OK`, `ls -d .harness/baseline/v*/ | wc -l` gibt `1`, und
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
  und trifft nicht null: **29** Dateien in den vier eingefrorenen Beständen nennen
  `.harness/baseline/v6.0.0/…`, **15** davon in Link-Form, und die Link-Form liegt in **zwei**
  Beständen, nicht mehr nur in einem:

  ```sh
  E=( docs/plan/adr docs/reviews docs/plan/planning/done harness/conventions/done )
  git grep -l  '\.harness/baseline/v6\.0\.0'          -- "${E[@]}" | wc -l   # 29
  git grep -lE '\]\([^)]*\.harness/baseline/v6\.0\.0' -- "${E[@]}" | wc -l   # 15
  git grep -lE '\]\([^)]*\.harness/baseline/v6\.0\.0' -- "${E[@]}" | cut -d/ -f1-3 | sort | uniq -c
  #   1 docs/plan/planning/done      (ein geschlossener Slice)
  #  14 docs/reviews
  ```

  Ein ADR-Verweis ist nach §3.4 unantastbar, ein Review-Report und ein geschlossener Slice ebenso
  — der Nachzug darf sie nicht ziehen, und ihr Ziel liegt nach dem Tausch nicht mehr im Baum. Das
  ist die Klasse `BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot`, deren Zähler bei **4**
  steht
  (`ls docs/plan/planning/observations/BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot/evidence/*.md | wc -l`)
  und deren Stand `verkörpert` ist — die verkörperte Regel deckt den **künftigen** Schreibfall, den
  Bestand deckt sie nicht. Die Ziel-Fassung bringt für den künftigen Fall einen zweiten Träger mit
  (die Zitier-Form in vier Vorlagen, §1 `v6.5.0`-Zeile); auf den Bestand wirkt auch der nicht.
  **Keine Erwartungswerte** — beide Zahlen wachsen mit jedem Review-Lauf, der in den Baum
  verlinkt. — **Ausgang: eingetreten.** Zwei Folge-Slices tragen die zwei Hälften: `slice-197`
  setzt für den **Bestand** das Ventil, das
  [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) beschlossen hat;
  `slice-198` schärft §3.11 für den **künftigen** Fall. Die Entscheidung fiel dabei nach dem
  Vollzug statt davor, und der Grund steht in §3.11 selbst: Sie nimmt ein Verzeichnis
  ausdrücklich als ortsfest aus, und `.harness/baseline/<tag>/` ist eines — genau die Stelle, die
  `slice-198` anfasst. Der Prüf-Teil der Regel hat gehalten (die Messung oben lief vor dem Lauf),
  der Entscheidungs-Teil nicht.
- **Nach vollständigem Nachzug bleibt das Doku-Gate rot: 35 Befunde aus eingefrorenen Artefakten,
  die das Modul `links` prüft.** Das ist die **Vorkommen-Achse** derselben Klasse
  `BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot`, nicht ein zweiter Fund: Das Risiko
  darüber zählt **Dateien** in den vier eingefrorenen Beständen, dieses zählt, was das Gate daraus
  **macht**. Doppelt gezählt wird dabei nichts — die Menge liegt innerhalb der Bezugsmenge aus
  DoD 2 und **außerhalb** von deren lebendem Teil, dessen Pathspec beide Bestände ausnimmt.

  **Gemessen und nicht gefolgert** — an einer Kopie außerhalb des Repos, weil `make docs-check` den
  Arbeitsbaum mountet: Baum nach `v6.5.0` umbenannt, jeder lebende Verweis gezogen, die vier
  eingefrorenen Bestände unangetastet, darüber der Pin aus `d-check.mk`:

  ```sh
  S=$(mktemp -d)                                             # ausserhalb des Repos
  tar --exclude=.git --exclude=.tmp -cf - . | (cd "$S" && tar -xf -)
  mv "$S/.harness/baseline/v6.0.0" "$S/.harness/baseline/v6.5.0"
  find "$S" -type f \( -name '*.md' -o -name '*.go' -o -name '*.sh' -o -name '*.yml' -o -name 'Makefile' \) \
    -not -path '*/docs/reviews/*'            -not -path '*/docs/plan/adr/*' \
    -not -path '*/docs/plan/planning/done/*' -not -path '*/harness/conventions/done/*' \
    -not -path '*/.harness/baseline/*' \
    -exec grep -lF '.harness/baseline/v6.0.0' {} + \
    | xargs -r sed -i 's|\.harness/baseline/v6\.0\.0|.harness/baseline/v6.5.0|g'
  D=$(sed -n 's/^DCHECK_DIGEST ?= //p' d-check.mk)
  docker run --rm --network none -v "$S:/repo:ro" "ghcr.io/pt9912/d-check@$D"
  ```

  → `d-check: 913 Datei(en) geprüft, 35 Befund(e)`, EXIT 1 — **32 in `docs/reviews/` (14 Dateien),
  3 in `docs/plan/planning/done/` (eine Datei), 0 in `docs/plan/adr/` und
  `harness/conventions/done/`**, je Link-Vorkommen ein Befund. Ohne den Nachzug sind es **157**,
  also dieselben 35 plus 122 lebende (dieselbe Kopie ohne den `find`-Schritt).

  **Der `done/`-Anteil ist neu gegenüber dem vorigen Sprung** und die Achse, an der dieses Risiko
  wächst: Ein geschlossener Slice friert wie ein Report ein, aber er entsteht in jeder Closure,
  nicht nur in jedem Review.

  **Warum das Gate sie sieht:** Die Bestände sind **nicht** vom Doku-Gate ausgenommen. Von den
  Modulen in [`.d-check.yml`](../../../../.d-check.yml) tragen nur `ids` und `codepaths` eine
  `exempt-paths`-Zeile für `docs/reviews`; `links` und `anchors` tragen keine, und eine
  referenz-weite Options-Sektion haben sie nicht
  (`grep -n '^modules:' .d-check.yml; grep -n 'exempt-paths' .d-check.yml`).

  **Was das für die DoD heißt, ausdrücklich:** Liefer-Punkt 2 bleibt erfüllbar — ein eingefrorener
  Report ist kein *lebender* Verweis, und die dortige Messung schließt ihn aus. Rot färbt er
  trotzdem; getroffen sind der DoD-Punkt `make gates` grün und Closure-Kriterium 1 in §5.

  **Drei Wege stehen offen, und keiner wird hier gewählt** — die Wahl gehört in den Lauf: ein
  eingefrorenes Artefakt ändern, was [`AGENTS.md`](../../../../AGENTS.md) §3.4 und §3.11 sperren ·
  ein Referenz-Ventil, das nach §3.5 seine eigene ADR braucht — heute führt die Config **4** Paare
  (`grep -c '^  - in: ' .d-check.yml`), dieser Fall bräuchte **15** `in:`-Einträge, und ein
  `scan.ignore`-Schnitt an ihrer Stelle nähme **299** Reports aus vier Modulen
  (`ls docs/reviews/*.md | wc -l`) · den Tausch anders schneiden.

  **Grenzen dieser Messung — was sie liefert und was sie nicht sieht.** Die 35 sind eine
  **Untergrenze**: Die Sonde zog pauschal, während der Lauf zwei Klassen stehen lässt (DoD 2), und
  sie misst nur den Prüfbereich — was `scan.ignore` ausnimmt, trägt eine tote Adresse unbemerkt.
  **14** eingefrorene Dateien nennen die Adresse **ohne** Link-Klammer: nach dem Tausch tot als
  Pfad, grün im Gate, weil `codepaths` für `docs/reviews` ausgenommen ist
  (`comm -23 <(git grep -l '\.harness/baseline/v6\.0\.0' -- "${E[@]}" | sort)
  <(git grep -lE '\]\([^)]*\.harness/baseline/v6\.0\.0' -- "${E[@]}" | sort) | wc -l`).
  **Keine Erwartungswerte** — jede Zahl dieses Eintrags ist an den Stand vom 2026-09-07 gebunden.
  Die Tag-Literale in den Kommandos oben sind eine datierte Mess-Aussage nach
  [`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  und gehören zur zweiten Nicht-Zieh-Klasse aus DoD 2. — **Ausgang: eingetreten**, und die Sonde
  war wie angekündigt eine Untergrenze: gemessen sind **36** statt 35, Stichtag 2026-09-08
  (`make docs-check` → `948 Datei(en) geprüft, 36 Befund(e)`; Verteilung **32 · 3 · 1** über
  `docs/reviews/**`, `docs/plan/planning/done/**` und eine `observation.md`, alle mit Grund-Code
  `target-missing`, alle mit Ziel in `.harness/baseline/**`). Träger ist **`CO-006`** — der
  Carveout, den `modul-05-planning-harness.md` §Closure- und Lerneintrag-Regeln für genau diese
  Lage verlangt: Er schaltet den roten Gate-Status auf einen beobachtbaren Auflösungs-Trigger, und
  sein Folge-Slice ist `slice-197`. Der dritte der drei Wege, die dieses Risiko offenließ — *den
  Tausch anders schneiden* —, ist damit nicht gewählt, und der erste bleibt gesperrt.
- **Die regierende Fassung ist bei Start noch nicht angenommen.** Dann greift Start-Bedingung 1
  nicht und der Slice bleibt liegen — das ist die gewollte Wirkung, nicht der Schaden. Der Schaden
  entstünde, wenn der Lauf ohne die Annahme tauscht und der spätere Adaptions-Durchgang gegen eine
  Pflichtgliederung misst, die keine angenommene Entscheidung deckt. — **Ausgang: entfallen.**
  [`ADR-0038`](../../adr/0038-ziel-fassung-regiert-den-sprung-v650.md) stand vor dem ersten
  `git`-Befehl auf `Accepted`
  (`grep -m1 '^\*\*Status:\*\*' docs/plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md`);
  Start-Bedingung 1 war erfüllt, der Schaden ist nicht eingetreten und kann für diesen Slice nicht
  mehr eintreten. **Der Fall ist damit nicht folgenlos, aber die Folge ist eine andere:** Der
  Statuswert war gesetzt, ohne dass der Beleg vorlag, den der eigene Acceptance-Trigger jener Datei
  verlangt. Das ist kein Eintritt *dieses* Risikos — es fragt nach dem Statuswert — und wird
  getrennt geführt: entschieden in
  [`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md), der
  ausstehende Beleg als `slice-199`, der Zähler in §7.
- **Der Sprung läuft ohne eigenen Inventur-Slice, und die Klasse dafür steht bei 2×.**
  `BEO-ALL/re-baseline-ohne-inventur-slice` beschreibt genau diesen Fall — *„die Form-Pflichten der
  neuen Fassung kommen einzeln als Nachzügler zurück statt gebündelt in den Schnitt"* — und zählt
  zwei Belege
  (`ls docs/plan/planning/observations/BEO-ALL/re-baseline-ohne-inventur-slice/evidence/*.md | wc -l`
  → 2). Hier trägt **dieser Plan** den Katalog (§1, je Tag und je Datei, auf der vendored Achse),
  und der Schnitt ist daraus geschnitten statt geschätzt. Tritt beim Vollzug eine Form-Pflicht auf,
  die der Katalog nicht führt, ist das der **dritte** Eintritt — und damit eine Lücke mit eigenem
  Folge-Slice, keine Notiz. **Sechs Releases auf einmal erhöhen genau dieses Risiko**, und die
  Klasse dafür heißt `BEO-ALL/baseline-sprungweite-treibt-kosten` (1×, offen). — **Ausgang:
  entfallen** — der Katalog hat getragen, und die Bedingung des dritten Eintritts ist nicht
  eingetreten. Gemessen: Keiner der 36 Gate-Befunde stammt aus einer Form-Pflicht, alle tragen den
  Grund-Code `target-missing` auf einer Adresse; die neun übrigen Ziele der `record-gates`-Kette
  sind grün; und der Review dieses Slice nennt die Emissions-Ebene ausdrücklich als geprüft ohne
  Befund. Es trat keine Form-Pflicht auf, die der Katalog in §1 nicht führt. Der Zähler von
  `BEO-ALL/re-baseline-ohne-inventur-slice` bleibt damit bei 2×, und die Klasse bleibt für den
  nächsten Sprung offen — gestrichen ist sie nicht, nur nicht durch diesen Slice erhöht.
- **Eine Form-Pflicht aus der `v6.3.0`- oder der `v6.5.0`-Zeile bricht ein bestehendes Artefakt
  beim Tausch.** Zwei Kandidaten sind benannt und gemessen: die **Sensors-Regel**, die
  [`harness/README.md`](../../../../harness/README.md) betrifft — die Sektion führt **80** Zeilen
  bei **13** Tabellenzeilen, und das Verzeichnis, das die Ziel-Fassung dafür vorsieht, fehlt
  (`awk '/^## Sensors/{p=1} /^## Traceability/{p=0} p' harness/README.md | wc -l`; dieselbe
  Pipeline mit `grep -c '^|'`; `ls -d harness/sensors 2>/dev/null | wc -l` → 0) —, und die
  **Zitier-Form**, die in vier einfrierenden Vorlagen als stehender Norm-Block liegt. Dieser Slice
  stellt keine von beiden um, aber der neue Baum steht dann daneben. Bricht dabei ein Gate, ist der
  Weg der Carveout mit Auflösungs-Trigger, nicht das stille Rot. — **Ausgang: entfallen** — keine
  der beiden Form-Pflichten hat ein bestehendes Artefakt gebrochen. Gemessen an derselben Stelle
  wie oben: alle 36 Gate-Befunde sind `target-missing` auf einer Adresse, keiner stammt aus der
  Sensors-Regel oder der Zitier-Form, und `ls -d harness/sensors 2>/dev/null | wc -l` → 0 färbt
  nichts rot, weil kein lebendes Dokument auf das fehlende Verzeichnis zeigt. Der Carveout dieser
  Closure trägt darum **nicht** diesen Fall — das rote Gate hat eine andere Ursache. Die zwei
  Form-Pflichten stehen unumgesetzt daneben; das ist ihr Posten in §Offene Punkte und kein
  gebrochenes Artefakt.
- **Der Bestand offener Slice-Pläne ist gegen die gepinnte Fassung geschnitten, und niemand hält
  ihn gegen den neuen Stand.** `open/` führt **57** Pläne
  (`ls docs/plan/planning/open/slice-*.md | wc -l`), jeder mit einer §1/§8-Gliederung und einer
  Zitier-Praxis nach `v6.0.0`. Das ist
  `BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht` (2×, offen); dieser Plan ist
  der eine, den der Sprung nachgezogen bekommt, und belegt damit zugleich, dass es für die übrigen
  keinen Schritt gibt. **Der Tausch ändert daran nichts** — er legt nur den Text daneben, gegen den
  sie künftig gelesen werden. — **Ausgang: weiter offen** → Beobachtungs-Register,
  `BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`. Der Beleg dieses Slice hebt den
  Zähler von 2× auf **3×** und damit über die Schwelle; welcher der drei Ausgänge er bekommt, setzt
  der Lese-Schritt (§7). Der Bestand ist beim Abschluss neu gemessen, Stichtag 2026-09-08:
  `ls docs/plan/planning/open/slice-*.md | wc -l` → **63**, davon
  `grep -l '^## 1\. Ziel und Abgrenzung' docs/plan/planning/open/slice-*.md | wc -l` → **5**.
- **Die vendored `slice.template.md` erzeugt in einem Greenfield-Repo bei jedem kopierten Slice
  einen `codepath-missing`-Befund** — ihr Reconciliation-Item führt den Register-Pfad als
  Inline-Code, und `codepaths` prüft Inline-Code-Pfade auf Existenz, während dieses Repo die Datei
  nicht führt (`ls docs/plan/planning/reconciliation.md` → nicht vorhanden). **Der Tausch behebt es
  nicht:** `v6.5.0` fasst die Vorlage in zwei Schritten an, die Reconciliation-Zeile aber nicht
  (`git -C "$K" diff v6.0.0 v6.5.0 -- lab/templates/docs/plan/planning/slice.template.md | grep -i
  reconcil` → leer). Der Bestand behilft sich, indem der Pfad als **Kommando-Operand** geschrieben
  wird, der seine eigene Abwesenheit belegt; dieser Plan tut es in §2. Ob daraus eine Regel wird,
  entscheidet nicht dieser Slice. — **Ausgang: weiter offen** → Beobachtungs-Register,
  `BEO-ALL/vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt` (mit diesem Slice
  angelegt, 1×). Der Fund gehört auf die **emittierte** Ebene, deren Beleg `make full-smoke` ist
  und nicht `make gates`; ein Folge-Slice wird hier bewusst nicht genannt, weil die Entscheidung —
  Vorlage beim Emittieren anpassen oder das emittierte Gate mit einem Ventil versehen — noch nicht
  gefallen ist und eine Kennung ohne sie ein Ausgang wäre, der formal steht und materiell leer ist.

### Offene Punkte — was dieser Schnitt bewusst nicht mitnimmt

Kein Risiko, sondern die Begründung der Grenze. Jeder Posten ist eigene Arbeit mit eigenem
Liefer-Wert. **Bis auf einen trägt keiner eine Kennung**, weil ein genannter Folge-Slice als Datei
im Lifecycle existieren muss (Folge-Slice-Paarung) und das Anlegen dieser Dateien ein eigener
Planungs-Schritt ist; die eine Ausnahme nennt einen **bestehenden** Nachbar-Slice, keinen
zugesagten. Die Liste ist der Umfang, den die Planung nach dem Tausch vor sich hat — sie zählt
nicht in die Größe dieses Slice (§1, letzter Block), aber sie ist das Material der Wellen-Frage in
ihrer letzten Zeile.

| Posten | Warum nicht hier |
|---|---|
| **Adaptions-Durchgang** — jeder Eintrag unter [`harness/conventions/`](../../../../harness/conventions/) gegen die neue Fassung, mit den fünf Ausgängen des Freshness-Audits | Er urteilt über **Inhalte**, der Tausch bewegt **Bytes und Adressen**. Präzedenz des vorigen Sprungs: [slice-182](../done/slice-182-baum-tausch-v600-pins-ziehen.md) tauschte, [slice-185](../done/slice-185-adaptions-durchgang-gegen-v600.md) urteilte. Zusammengelegt wäre der Slice weder in einer Review-Sitzung prüfbar noch bei ≤ 3 Liefer-Punkten |
| **Die Sensors-Umstellung** (`v6.3.0`/`v6.3.1`) — das Sensor-Verzeichnis unter `harness/` anlegen, je Gate mit mehr als einem Satz Vertrag eine nach dem Target benannte Datei, die Target-Zelle der Tabelle zum Link machen, [`harness/README.md`](../../../../harness/README.md) §Sensors auf seine Tabelle zurückführen, [`AGENTS.md`](../../../../AGENTS.md) §4 nachziehen | Der umfangreichste Posten des Sprungs und der **tragende Grund** von [`ADR-0038`](../../adr/0038-ziel-fassung-regiert-den-sprung-v650.md): ein **neues Verzeichnis**, eine neue Artefakt-Klasse mit eigener Ziel-Form (`gate.template.md` in der Vorlagen-Achse) und zwei lebende Norm-Artefakte, davon eines in Architect-Eigentum. Er ist zugleich der Träger, aus dem die zwei in §8 gesichteten Nullzähler-Einträge ihren Ausgang bekommen — die Ziel-Fassung liefert ihnen die Regel, die dem Repo bisher fehlt. **Eine Reihenfolge-Bedingung ist gemessen:** Solange das Verzeichnis fehlt, färbt jede Nennung seines Pfads als Inline-Code `docs-check` rot (Modul `codepaths`, Grund-Code `codepath-missing`) — der Slice legt es an, bevor ein lebendes Dokument darauf zeigt |
| **Die Zitier-Form in einfrierenden Artefakten** (`v6.5.0`) — den stehenden Norm-Block der vier Vorlagen in die repo-eigene Praxis übernehmen und gegen [`AGENTS.md`](../../../../AGENTS.md) §3.11 halten | Er urteilt über die **Schreib-Regel** künftiger Zeitdokumente, nicht über den Baum. Und er berührt eine Frage, die [`ADR-0038`](../../adr/0038-ziel-fassung-regiert-den-sprung-v650.md) §Was diese Festlegung nicht entscheidet ausdrücklich offen lässt und als eigene Architect-Folgepflicht führt — der Träger von §3.11 ¶1 für Rollen-Reports und das Verhältnis der `exempt-paths`-Ausnahme zum Nachzug durch `make slice-mv`. Eine Entscheidung, die dort fällt, ist nicht in einem Tausch-Slice zu treffen |
| **Die RTM-Gegenrichtung** (`v6.5.0`) — *Anforderung → Beleg* als erzeugter Auslesestand, mit der Setzung, welche Spalte entlastet | Neue Fähigkeit mit eigenem Liefer-Wert und eigener Bezugsmenge (`spec/lastenheft.md` gegen den Lifecycle). Die Baseline schlägt den **Slice** als entlastende Spalte vor und verlangt, eine andere Wahl zu deklarieren — das ist eine Setzung für den Adaptions-Block, kein Byte im Baum. Ein Nachbar-Slice führt die Frage bereits: slice-192 |
| **Die Out-of-Scope-Disziplin im Slice-Plan** (`v6.4.0`) — §1 auf *Ziel und Abgrenzung*, §8 auf *Sub-Area-Prüfungen und Modus-Begründung*, vier Ausschluss-Klassen mit Begründungspflicht | Sie gilt für **neu kopierte** Pläne ab dem Tausch und ändert am Baum nichts. Für den Bestand ist sie die Frage aus dem sechsten Risiko oben — 57 Pläne in `open/`, die niemand hält —, und die ist eine Planungs-Entscheidung, kein Nachzug |
| **Die Review-Zusage bekommt ihren Wächter** (`v6.1.0`/`v6.2.0`) — die DoD-Zeile in Kraft setzen und das d-check-Modul `reviews` (`done-dir` als Aktivierungs-Schalter) in [`.d-check.yml`](../../../../.d-check.yml) aktivieren, dazu die emittierte Fassung unter `internal/emit/templates/` | Der Tausch bringt die neue Vorlage, und die DoD-Zeile wirkt damit ab dem Tausch auf jeden **neu kopierten** Plan. Das **Aktivieren** des Moduls ist dagegen ein Gate-Anheben mit eigener Bezugsmenge (`docs/plan/planning/done/` gegen `docs/reviews/`) und braucht seinen eigenen roten Beleg ([`AGENTS.md`](../../../../AGENTS.md) §3.6) |
| **Die Carveout-Bindungsspalte** (`v6.1.0`) — die Auflösung eines Carveouts setzt die `Bindung`-Spalte in [`harness/README.md`](../../../../harness/README.md) §Sensors zurück | Eine Regel über den **Carveout-Lifecycle**, die erst beim nächsten Auflösungs-Vorgang greift. Sie hängt zudem an der Sensors-Umstellung darüber: Wo die Tabellenzeile hin wandert, wandert die Spalte mit |
| **Die emittierte Ebene über den Pin hinaus** — der `reviews:`-Block der `.d-check.yml`-Vorlage, das Sensor-Verzeichnis im Ziel-Repo, `gate.template.md` | Die **Pin**-Hälfte gehört zwingend hierher: `DefaultTag`/`DefaultBaselineSHA256` in `internal/fetch/baseline.go` sind zwei der fünf gekoppelten Stellen, und wer sie stehen ließe, färbt `make gates` rot. Die **Inhalts**-Hälfte gehört nicht: Was ein emittiertes Repo an Struktur bekommt, ist eine eigene Entscheidung mit eigenem Prüfbereich, und `make full-smoke` ist ihr Beleg — nicht `make gates` |
| **Die Wellen-Frage** — braucht dieser Vorgang eine Welle? | Die Antwort hängt daran, ob eine Closure-Bedingung mehr beobachtet als die DoDs der Mitglieder (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht). Sie ist beantwortbar, sobald die Mitglieder feststehen — und die Eröffnung legt eine eigene Datei an, die dieser Lauf nicht schreibt. **Die Liste oben ist ihr Material:** Acht Posten mit eigenem Liefer-Wert sind der Umfang, an dem sich entscheidet, ob ein Bündel vorliegt |

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene Kennung **zitieren** statt neu
formulieren — sonst zählt das Register zwei Pfade getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

**Rolle:** Planner · **Datum:** 2026-09-08.

- **Was hat funktioniert:** Der **Delta-Katalog auf der vendored Achse** (§1). Er misst
  `lab/regelwerk` + `lab/templates` statt `kurs/de` — also die Achse, die wirklich vendored wird —
  und schlüsselt je Tag auf. Aus ihm sind die fünf Folge-Slices geschnitten statt geschätzt, und er
  trägt den Ausgang des vierten Risikos: Beim Vollzug trat keine Form-Pflicht auf, die er nicht
  führt. Ebenso getragen hat die **Trennung Bytes/Adressen von Inhalt** — der Slice bewegt einen
  Baum und Adressen, und jede Form-Pflicht der neuen Fassung steht als eigener Posten in
  §Offene Punkte statt als stiller Zusatz im selben Lauf. Und die **vorab benannten
  Nicht-Zieh-Klassen** (DoD 2) haben die zwei Fälle abgefangen, in denen eine mechanische
  Ersetzung ein laufendes Kommando kaputtgemacht hätte.
- **Was ging anders als geplant:** Drei Dinge.

  **Erstens: der Baum kam aus der falschen Quelle.** Er wurde aus dem `git`-Baum des Kurs-Repos
  gelegt, während die fünf Pin-Stellen das Release-Asset beschreiben. Beide tragen denselben
  Regel-Text und nicht dieselben Bytes — das Release-Verfahren schreibt repo-relative Links in
  absolute, tag-gepinnte URLs um. **26** Dateien des Baums trugen dadurch Adressen auf ein
  Verzeichnis, das in keinem adoptierenden Repo existiert
  (`git grep -l '\.\./\.\./kurs/de/' 962c1722^ -- '.harness/baseline/v6.5.0' | wc -l`; heute 0 —
  die erste Zahl ist an einen Tree-Operanden gebunden und darum fest). Das Symptom ist behoben; die
  Ursache steht: Kein Sensor hält Asset gegen Baum, und der Vendoring-Vorgang hat keinen
  `make`-Träger.

  **Zweitens: das rote Gate stand ohne Träger.** Diagnose und Abhilfe waren vollständig, der
  Carveout fehlte — und der Plan führt das grüne Gate zugleich als Liefer-Punkt (§2) und als
  Closure-Kriterium (§5). Daraus entstand die Zirkularität, die diese Closure mit `CO-006` auflöst.

  **Drittens: die Fähigkeits-Grenze des gepinnten Werkzeugs war keine.** Die erste Fassung von
  [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) verwarf das
  Referenz-Ventil mit der Begründung, `ignore-refs` nehme keine Glob-Werte. Der gepinnte Stand
  nimmt sie, und der Schlüssel steht querschnittlich auf Top-Level — die Auskunft stand im Kopf
  des `ignore-refs`-Blocks der eigenen [`.d-check.yml`](../../../../.d-check.yml). Der Irrtum
  kostete eine verworfene Entscheidung und einen Change Request an ein Nachbar-Team.
- **Steering-Loop-Eintrag — benannte Spec-Lücke, gegen
  [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit):** *Der Pin ist die
  Reproduzierbarkeits-Klammer, und kein Sensor hält den vendored Baum gegen das Asset, dessen
  sha256 er nennt.* Die Kette ist zur Hälfte bewacht: **Pin → Asset** hält `make regelwerk-check`
  (Netz, nicht in `make gates`), **Asset → Baum** hält nichts — `regelwerk-check` hasht die
  Roh-Bytes des ZIP (`unpack: none`) und sieht den Baum nie, `make baseline-verify` misst gegen
  ein `SHA256SUMS`, das derselbe Vorgang erzeugt hat. Die Lücke ist in
  [`harness/conventions.md`](../../../../harness/conventions.md) §Adoptierte Konventions-Quellen
  benannt; **neu ist, dass sie sich realisiert hat** und dass ihre Reichweite über frühere Tags in
  diesem Repo nicht messbar ist. **Kein neuer Sensor wird hier behauptet** — `slice-200` baut den
  Träger, gebaut ist er nicht
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Beobachtungs-Register (`../observations/`):** **zwölf** Belege aus diesem Vorgang, je genau
  eine `slice-193.md` — ein Vorgang zählt einmal, auch wo ein Fund mehrfach auftrat. Sieben gehen
  in bestehende Einträge: `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch` (→ **3×**) ·
  `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht` (→ **3×**) ·
  `aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand` (→ 2×) ·
  `verweis-nachzug-schreibt-in-eingefrorenes-artefakt` (→ 2×) ·
  `vollstaendigkeits-zusage-misst-falsche-ebene` (→ 2×) ·
  `zahl-neben-nie-gefahrenem-kommando` (→ 4×) ·
  `fremdes-rollen-artefakt-im-implementations-kontext` (→ 6×). Fünf Einträge sind neu, je 1×:
  `vendored-baum-entsteht-aus-anderer-quelle-als-sein-pin` ·
  `gate-modul-erreicht-den-vendored-baum-nicht` ·
  `accept-uebergang-ohne-den-beleg-seines-triggers` ·
  `rotes-gate-mit-diagnose-ohne-angenommenen-traeger` ·
  `vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt`. Zähler sind Dateizahlen und
  stehen in keinem Feld (`ls .../evidence/*.md | wc -l`).

  **Zwei Einträge überschreiten mit diesem Slice die Schwelle** und stehen bis zum Lese-Schritt
  weiter auf `offen` — zulässig und vorübergehend nach `v6.5.0` ·
  `regelwerk/modul-06-roadmap.md` §Das Beobachtungs-Register. Den Lese-Schritt trägt in einem Repo
  mit Wellen-Betrieb die Welle-Closure, und dieses Repo führt zwei offene Wellen; die Übergabe
  steht hier, nicht der Ausgang.

  **Eine Zählung des Review-Reports ist nicht übernommen:** Er liest die drei Funde der Klasse
  `vollstaendigkeits-zusage-misst-falsche-ebene` als Übertritt der Schwelle. Drei Funde in **einem**
  Vorgang sind eine Gelegenheit und kein drittes Auftreten; der Zähler steht danach bei 2.
- **Folge-Slices:** `slice-197` (das Ventil aus
  [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md), zugleich Träger von
  `CO-006`) · `slice-198` (§3.11 nennt den vendored Baum) · `slice-199` (der Beleg, den
  [`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) für
  [`ADR-0038`](../../adr/0038-ziel-fassung-regiert-den-sprung-v650.md) verlangt) · `slice-200`
  (der `make`-Träger des eigenen Vendorings) · `slice-201` (der Prüfbereich für Inline-Pfade in den
  Baum — oder seine benannte Grenze). Alle fünf liegen als Datei in `open/`.
- **Carveout:** **`CO-006`** — der Tag-Tausch macht 36 Adressen in einfrierenden Artefakten tot.
  Betroffenes Gate `make docs-check`, Geltungsbereich die drei einfrierenden Bäume,
  Auflösungs-Trigger *`make docs-check` meldet `0 Befund(e)`, ohne dass ein Artefakt in einem der
  drei Bäume geändert wurde*, Folge-Slice `slice-197`. Er schaltet keinen Befund stumm: Es ist
  keine Ausnahme konfiguriert, der Gate meldet alle 36 und endet mit EXIT 1. Geduldet ist ein
  **lautes** Rot mit Trigger, nicht ein stilles.
- **Trigger-Audit:** `CO-001` — Trigger weiterhin **eingetreten**, Ausgang unverändert
  *verlängert mit Folge-Slice* (`slice-141` entscheidet vorher, `slice-113` führt aus); die
  `Letzte Prüfung:`-Zeile bleibt beim Stand des welle-10-Audits, weil das Carveout-Audit in einem
  Repo mit Wellen-Betrieb Schritt 2 der Welle-Closure ist und eine zweite Eintragung desselben
  Ergebnisses Chronik wäre. `CO-002` — permanent, in
  [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) übergeführt, keine
  Handlung. Bootstrap-aware Gates führt dieses Repo keine. ADR-Re-Evaluierungs-Trigger: der erste
  von [`ADR-0036`](../../adr/0036-ziel-fassung-regiert-den-sprung-v600.md) ist mit
  [`ADR-0038`](../../adr/0038-ziel-fassung-regiert-den-sprung-v650.md) bedient; der offene
  Acceptance-Beleg jener Datei ist `slice-199`.
- **Risiken aus §6:** alle sieben tragen genau einen Ausgang — **2× eingetreten** (Adressen in
  eingefrorenen Artefakten → `slice-197`/`slice-198`; rotes Doku-Gate → `CO-006`/`slice-197`),
  **3× entfallen mit Begründung** (regierende Fassung stand `Accepted`; der Katalog trug, keine
  Form-Pflicht außerhalb; keine Form-Pflicht hat ein Artefakt gebrochen), **2× weiter offen ins
  Register** (`folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`;
  `vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt`). Sieben, nicht acht: Die
  Tabelle in §Offene Punkte darunter führt neun Posten und weist sich selbst als *kein Risiko*
  aus — sie begründet die Grenze des Schnitts.
- **Drei Paarungen:** dieses Repo führt Wellen-Betrieb; sie prüft die nächste Welle-Closure —
  auch für einen Slice ohne Wellen-Zugehörigkeit. **Ein Befund für sie liegt vor und ist nicht von
  diesem Slice erzeugt:** Die zweite Hälfte der Register-Paarung (c) — *jede Registerzeile trägt
  mindestens einen Beleg* — ist rot. Zwei der Einträge führen ein leeres `evidence/`,
  `benannte-luecke-ohne-ausgang` und `einstiegs-datei-weicht-von-der-pflichtgliederung-ab`; beide
  sind in §8 als Nullzähler gesichtet und im Register als solche geführt.

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
[`../observations/`](../observations/) ist durchgegangen; es führt **65** Verzeichnisse
(`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`), alle unter `BEO-ALL`, die damit die
berührte Sub-Area formal treffen. Aufgeführt sind die, die **diesen Vorgang** betreffen — Zähler
abgelesen als Dateizahl unter `evidence/`, nicht aus einem Feld
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`; keine
Erwartungswerte):

| Eintrag | Zähler | Stand | Bezug zu diesem Slice |
|---|---|---|---|
| `vorgeschriebener-ortswechsel-macht-adresse-tot` | 4× | verkörpert | die 29 eingefrorenen Dateien mit `v6.0.0`-Adresse, §6 erstes und zweites Risiko |
| `re-baseline-ohne-inventur-slice` | 2× | offen | **erreicht mit diesem Slice 3×, falls der Katalog in §1 nicht trägt** — als Risiko in §6 geführt |
| `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht` | 2× | offen | die 57 Pläne in `open/`, gegen `v6.0.0`-Pflichten geschnitten; dieser Plan ist der nachgezogene, §6 sechstes Risiko |
| `byte-gleichheit-als-aussage-ueber-die-regel-gelesen` | 2× | offen | der Delta-Katalog in §1 nennt je Tag die Dateien mit Regel-Delta, nicht die Roh-Beträge — `v6.5.0` normalisiert die Tabellenform des ganzen Baums |
| `verweis-nachzug-schreibt-in-eingefrorenes-artefakt` | 1× | offen | der Nachzug darf die 15 eingefrorenen Link-Dateien nicht ziehen; ihre Ausnahme steht in DoD 2 |
| `verweis-nachzug-bricht-tree-operand` | 1× | offen | die erste der zwei Nicht-Zieh-Klassen in DoD 2 |
| `baseline-sprungweite-treibt-kosten` | 1× | offen | sechs Releases auf einmal; die Aufschlüsselung je Tag in §1 ist die Antwort darauf |
| `mess-zusage-trifft-das-eigene-zitat` | 1× | offen | die Kommando-Zeilen dieses Plans nennen Tags als Operanden; sie dürfen beim Nachzug nicht gezogen werden ([`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)) |
| `regel-delta-zaehlt-herkunfts-kommentar-mit` | 1× | offen | dieselbe Frage, andere Rauschklasse — für diesen Sprung trägt der Herkunfts-Kommentar null, die Tabellenform trägt ([`ADR-0038`](../../adr/0038-ziel-fassung-regiert-den-sprung-v650.md) §Was das Messinstrument diesmal mitzählt) |
| `einstiegs-datei-weicht-von-der-pflichtgliederung-ab` | 0× | offen | **gesichtet, hier nicht aufgelöst** — die fehlende Sektion `## Safety and scope boundaries` und die Sensors-Fläche; die Ziel-Fassung bringt die Regel, die Umstellung ist eigene Arbeit (§6) |
| `benannte-luecke-ohne-ausgang` | 0× | offen | **gesichtet, hier nicht aufgelöst** — *„kein `sensors/done/`"* ist genau die Austrags-Regel, die `v6.5.0` mitbringt; ihr Ausgang entsteht mit der Sensors-Umstellung, gesetzt wird er von einer Closure, nicht von diesem Plan |

Die letzten beiden tragen heute **kein** `evidence/`-Verzeichnis — der Zähler ist damit null, und
das ist der abgelesene Stand, keine Auslassung
(`find docs/plan/planning/observations/BEO-ALL/benannte-luecke-ohne-ausgang -type f`). Alle
Bezeichnungen sind **zitiert**, nicht neu formuliert, damit das Register sie nicht als zwei Pfade
zählt.

**Modus:** alle berührten Sub-Areas **GF** — der Begründungsblock entfällt damit nach der
Umfangs-Regel dieser Sektion. Der Modus ist keine Folge der Slice-Größe, sondern der Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md) §Modus-Deklaration pro Sub-Area, die
`*` als Greenfield führt.
