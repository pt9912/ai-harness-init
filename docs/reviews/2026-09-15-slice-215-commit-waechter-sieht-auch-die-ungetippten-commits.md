# Review-Report: slice-215-commit-waechter-sieht-auch-die-ungetippten-commits — 2026-09-15

**Review-Art:** Code-Review gegen **Plan + ADRs + Hard Rules** (Modul 10 §Drei Review-Arten).
Gegenstand ist ein neuer Vor-Commit-Träger (`.githooks/commit-msg` + bash-Prüfer), seine
Verdrahtung, seine Doku-Reichweite und seine Zähne. **Kein DoD-Review** — DoD-/Spec-Konformität
prüft der Verifier (Modul 11, anderer Eingabe-Kontext).

**Gegenstand:** die drei Commits `7ee36939` · `2557901e` · `9ab67fa0` — 8 Dateien, +341/−12
(`git diff --stat 7ee36939^..9ab67fa0`): `.githooks/commit-msg` (neu) ·
`harness/tools/commit-msg-traceability.sh` (neu) · `test/commit-msg-hook.bats` (neu) ·
`test/mutations/340-commit-msg-traeger-ohne-kennungs-pruefung.sh` (neu) · `Makefile`
(`hooks-install`, `shell-lint`, `comment-claims`) · `.d-check.yml` · `harness/README.md`
§Traceability · `harness/sensors/commit-msg-check.md`.

**Kein Self-Review:** dieser Lauf hat an dem Gegenstand **nicht** geschrieben — weder an den drei
Commits noch an einer der acht Dateien noch an einer Vorlage daraus. Jede Zahl dieses Reports ist
in diesem Lauf gefahren; keine stammt aus einer Commit-Message oder einem Implementer-Bericht.

**Skill:** `.harness/skills/reviewer.md` @ `0565f274` (2.0.0) · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** deepseek-v4.1-flash:cloud[1m] · **Datum:** 2026-09-15

**Baum bei Review-Beginn:** `git status --porcelain` leer, HEAD `0ec30ca2`.
`core.hooksPath` in diesem Klon: **nicht gesetzt** (`git config --get core.hooksPath` → kein
Treffer, EXIT 1) — der geprüfte Träger ist hier **nicht aktiv**.

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis; die `<Platzhalter>` darin sind Formbeispiele)*. Dieser
> Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link
> (`v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt>). Der vendored Baum trägt
> genau einen Tag; der Sprung löscht den alten, und ein Link darauf färbt beim
> nächsten Bump ein Artefakt rot, das niemand mehr anfassen darf. Ein `pfad`-Feld
> auf den **geprüften Gegenstand** ist davon nicht betroffen — es zitiert den
> Stand des Laufs und darf ihn festhalten.
>
> Nach derselben Regel steht der geprüfte **Slice-Plan** hier als Kennung
> `slice-215-commit-waechter-sieht-auch-die-ungetippten-commits`, nicht als Pfad: sein Ort wandert
> bei der Closure.

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Slice-Plan `slice-215-commit-waechter-sieht-auch-die-ungetippten-commits` — §1 (Ziel und
  Abgrenzung), §2 DoD 1/2/3, §3 (Plan), §4 (Trigger), §5 (Closure-Trigger), §6 (Risiken), §8
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules; tragend hier §3.1, §3.5, §3.6, §3.7, §3.9) ·
  §2 (Source Precedence) · §5 (Traceability-Zusage)
- [`ADR-0004`](../../docs/plan/adr/0004-durchsetzungs-emission.md) (Stolperdraht-Charakter eines
  Guards) · [`ADR-0019`](../../docs/plan/adr/0019-agent-guard-prueft-die-aufrufform.md) ·
  [`ADR-0028`](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) ·
  [`MR-002`](../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) (Hook-Mechanik)
- [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) ·
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
- [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) ·
  [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung) ·
  [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) (Namens-Form der Slice-Kennung)
- Baseline `v6.8.0` · `regelwerk/modul-05-planning-harness.md` §Trigger je Lifecycle-Übergang ·
  `regelwerk/modul-08-agentenrollen.md` §Rollen-Regeln ·
  `regelwerk/modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill
- Vorherige Findings am selben Gegenstand: `2026-09-11-slice-126-commit-message-traegt-eine-kennung.md`
  und `…-runde-2.md` (1 HIGH · 5 MEDIUM · 1 LOW · 1 INFO; dort MEDIUM-1 = *„`git commit -m` ist als
  bewusst ausgenommen deklariert, wird aber geblockt"*)
- Beobachtungs-Register: `commit-message-ohne-traceability-kennung` (2×) ·
  `waechter-abdeckung-haengt-an-uninstruierter-konvention` (1×) ·
  `zusage-nennt-sensor-der-form-nicht-sieht` (14×) · `amend-committet-fremde-index-eintraege-mit` (2×)

---

## Vorbemerkung: der Start-Trigger §4 ist formal unerfüllt, und der Vollzug trägt trotzdem

§4 des Plans macht den Übergang `next` → `in-progress` davon abhängig, dass der **Architect** die
Träger-Wahl aus DoD (1) beantwortet hat — als ADR oder als Zeile in §3. Die Zeile steht in §3
unverändert auf **„offen"**; die Datei ist seit ihrer Beanspruchung von keinem Commit mehr berührt
(`git log --oneline -- <Slice-Datei>` → `1f5dc777` Move, `873f470e` Planner-Prosa), und im Register
der Entscheidungen führt keine ADR diesen Gegenstand
(`ls docs/plan/adr/*.md | wc -l` → 53 Dateien; `grep -rl 'hooksPath' docs/plan/adr/` → kein Treffer).

**Das ist ein Befund am Vollzug, aber nicht der schwerste dieses Laufs** — und er ist **kein**
Rollen-Konflikt: der Implementer behauptet die Architect-Antwort nicht, er verweist selbst darauf,
dass sie offen steht. Der Konflikt-Pfad aus Modul 8 greift darum nicht. Getragen wird der Vollzug
von §3 der Slice-Plan-**Vorlage**, die `core.hooksPath` + ein `make`-Ziel ausdrücklich als
mögliche Antwort führt (*„mit `core.hooksPath` statt `.git/hooks/`"*) — die *Form* der Antwort ist
also plan-gedeckt; die **Entscheidung** zwischen den Trägern ist es nicht. Was daran fehlt, steht
als F-1, weil es genau dort sichtbar wird: die unmade Entscheidung hat eine Folge, und sie ist in
keinem Artefakt des Diffs benannt.

---

## Eigene Messungen

Jedes Kommando ist in diesem Lauf gefahren; wo eine Zahl steht, steht das Kommando daneben, das
sie liefert, und **keine** ist ein Erwartungswert. Kopien lagen **außerhalb** des Repos
(`/tmp/…`), der Arbeitsbaum ist unverändert; `make hooks-install` wurde **nicht** in diesem Klon
gefahren, sondern nur in Kopien.

### 1. Das Grün/Rot-Paar des Trägers — reproduziert, wie im Commit-Bericht behauptet

```sh
cp -a <repo>/. <kopie> && cd <kopie> && make hooks-install
git commit --allow-empty -m 'Betreff ohne Kennung'
# commit-msg-traceability: keine Traceability-Kennung in der Commit-Message (AGENTS.md §5):
#             Betreff ohne Kennung                                      EXIT 1
git commit --allow-empty -m 'Bezug: ADR-0004 …'                          EXIT 0
git commit --allow-empty -m 'Merge branch main into feature'             EXIT 0
git commit --allow-empty --no-verify -m 'Betreff ohne Kennung'           EXIT 0
```

**Alle vier Beträge des README-Blocks treffen.** Dazu die Klasse, die der PreToolUse-Kanal
strukturell nicht sieht — Commit **innerhalb** eines Skripts, ohne `-F` in der Aufrufzeile:

```sh
bash inner.sh   # enthält: git commit -q --allow-empty -m "slice-mv: slice-mutations-…md  in-progress/ -> done/ (reiner Move)"
# commit-msg-traceability: … EXIT 1
```

### 2. F-1 — was die dokumentierte Aktivierung mit den Werkzeugen dieses Repos macht

```sh
cp -a <repo>/. <kopie2> && cd <kopie2> && make hooks-install
make slice-mv SLICE=slice-zaehler-label-nennt-seine-einheit TO=next
# commit-msg-traceability: keine Traceability-Kennung in der Commit-Message (AGENTS.md §5):
#             slice-mv: slice-zaehler-label-nennt-seine-einheit.md  open/ -> next/ (reiner Move)
# make: *** [Makefile:360: slice-mv] Fehler 1                              EXIT 1 (make)
git status --porcelain
# R  docs/plan/planning/open/slice-zaehler-label-nennt-seine-einheit.md -> docs/plan/planning/next/slice-zaehler-label-nennt-seine-einheit.md
```

**Der Move ist vollzogen, der Commit nicht** — `make slice-mv` bricht **nach** dem `git mv` ab und
läßt einen gestagten Rename ohne Commit stehen; ein zweiter Aufruf findet dann einen unsauberen
Arbeitsbaum vor. Dieselbe Messung für die zweite Werkzeug-Klasse, als Message-Form gefahren
(`harness/tools/slice-mv.sh:234` und `:268`, `internal/archive/anwenden.go:107` und `:175`,
`cmd/ai-harness-init/archive_welle.go:201-202` — alle drei committen mit `-m` **innerhalb** des
Werkzeugs):

```sh
git commit -q --allow-empty -m "archive-welle: welle-15  Archiv, Stubs und Verweis-Nachzug (Inhalt, getrennt vom Move — AGENTS.md §3.3)"
# commit-msg-traceability: … EXIT 1
git commit -q --allow-empty -m "slice-mv: slice-215-commit-waechter.md  next/ -> in-progress/ (reiner Move)"
# EXIT 0   — die Form mit Ziffern-Kennung kommt durch
```

**Der Auslöser ist die Kennungs-Form, nicht das Werkzeug.** Von den `slice-mv`-Commits dieses
Repos tragen die meisten eine Ziffern-Kennung, weil der Dateiname sie trägt:

```sh
RE='ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+'
git log --format='%s' | grep -c '^slice-mv:'                                    # 411
git log --format='%s' | grep '^slice-mv:' | grep -vcE "$RE"                     #  44
git log --format='%s' -300 | grep '^slice-mv:' | grep -vE "$RE" | head -2
# slice-mv: Verweise auf slice-vorlauf-waechter-geht-ins-ziel.md nach done/ nachgezogen …
```

Seit [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
(2026-09-13) vergibt dieses Repo **Namens**-Kennungen (`slice-vorlauf-waechter-geht-ins-ziel`), die
kein `slice-\d+` treffen. Die Einordnung des Implementers — *die Regelverletzung war schon da und
nur unsichtbar* — **trägt damit gemessen**: die zwei jüngsten kennungslosen `slice-mv`-Commits
sind genau die zwei jüngsten Namens-Form-Slices, und jeder künftige `make slice-mv` eines neuen
Slice erzeugt denselben Fall.

### 3. N-3 — der frische Klon, beide Hälften

```sh
git clone -q --no-hardlinks <repo> <klon> && cd <klon>
git config --get core.hooksPath                # kein Treffer, EXIT 0 (Option fehlt)
ls -l .githooks/commit-msg | awk '{print $1}'  # -rwxrwxr-x   (Index-Modus 100755)
git commit -q --allow-empty -m 'ohne kennung im frischen klon'   # EXIT 0 — Träger reist, Aktivierung nicht
make hooks-install
git commit -q --allow-empty -m 'ohne kennung im frischen klon'
# commit-msg-traceability: … EXIT 1
```

### 4. N-1 — der Zahn, einzeln gefahren (kein voller `make mutate`)

```sh
cp -a <repo>/. <kopie3> && cd <kopie3>
sed -i -E 's@^patterns=.*$@patterns=".*"@' harness/tools/commit-msg-traceability.sh   # genau der sed des Falls 340
docker run --rm --network none -v <kopie3>:/code:ro -w /code <BATS_IMAGE> test/commit-msg-hook.bats
# not ok 65 traeger: Message ohne Kennung wird abgelehnt
# not ok 69 traeger: ein Betreff 'Merge' ohne Leerzeichen wird abgelehnt
# not ok 71 traeger: Kennung nur in einer Kommentarzeile genuegt nicht
# not ok 75 kopplung: eine Kennung ausserhalb der Config-Liste wird abgelehnt      EXIT 2
```

Der `# expect:`-Name des Falls liegt in der Fehlschlag-Ausgabe, und `failure_form test-bats`
(`not ok [0-9]+`) trifft sie — der Treiber hätte `ok` gemeldet. Die unveränderte Kopie ist grün:
`1..11`, alle elf `ok`, EXIT 0.

### 5. F-2 — die Kopplung, in **beiden** Richtungen geprüft

```sh
# (a) Hook wird weiter als die Config — ein Muster, das in der Config nicht steht
sed -i "s@^patterns=.*@patterns='(ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+|TICKET-[0-9]+)'@" harness/tools/commit-msg-traceability.sh
docker run … <BATS_IMAGE> test/commit-msg-hook.bats     # 1..11, alle ok, EXIT 0

# (b) Config verliert ein Muster, das der Hook behält
sed -i "/^    - 'MR-\\\\d{3}'$/d" .d-check.yml
docker run … <BATS_IMAGE> test/commit-msg-hook.bats     # 1..11, alle ok, EXIT 0
```

### 6. F-3 — die `-m`-Zeile der Reichweiten-Tabelle, gegen den Guard selbst

```sh
H=.claude/hooks/pretooluse-commit-msg-guard.sh
printf '%s' '{"tool_input":{"command":"git commit -m \"Details siehe --file LICENSE\""}}' \
  | PRETOOLUSE_COMMIT_MSG_CHECKER=false bash "$H"
# {"decision":"block","reason":"Commit-Message-Datei LICENSE wurde ABGELEHNT (Pruef-Instanz Exit 1) …"}
printf '%s' '{"tool_input":{"command":"git commit -m \"Kurzer Betreff ohne Pfad\""}}' \
  | PRETOOLUSE_COMMIT_MSG_CHECKER=false bash "$H"          # keine Ausgabe — kein Match, kein Block
```

### 7. F-4 — die `--amend`-Klasse am Träger

```sh
git commit -q --allow-empty --no-verify -m 'Betreff ohne Kennung'   # ein kennungsloser Commit entsteht
git commit --allow-empty --amend --no-edit                          # git reicht die alte Message erneut durch
# commit-msg-traceability: keine Traceability-Kennung …            EXIT 1
```

### 8. Das Repo-Gate und der Prüfbereich der zwei Sensoren, die den Träger lesen

```sh
make gates                                                              # EXIT 0
#   baseline-verify: v6.8.0 OK — 54 Dateien (Integritaet + Vollstaendigkeit, netzlos)
#   d-check: 1428 Datei(en) geprüft, 0 Befund(e)
#   comment-claims: 61 Datei(en) geprueft, 0 Befund(e)
#   make test-bats: 1..293, alle ok, EXIT 0   (die elf neuen Fälle: ok 65…ok 75)
```

`.githooks/commit-msg` wird von `comment-claims` (`.githooks/*`) und von `shell-lint` (einzeln
genannt, weil git den nackten Hook-Namen verlangt) erreicht; beide Gate-Schritte sind in diesem
Lauf gefahren und grün.

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | `make hooks-install` — die **einzige** dokumentierte Aktivierung des Trägers — bricht die zwei Werkzeuge, die dieser Repo-Prozess bei jedem Lifecycle-Wechsel fährt: `make slice-mv` bricht **nach** dem `git mv` ab und läßt einen gestagten Rename ohne Commit stehen, `archive-welle` committet wie `slice-mv` mit einer `-m`-Form ohne Ziffern-Kennung (§Eigene Messungen 2). Die Reichweiten-Tabelle stellt dieselbe Klasse als *„erreicht"* dar, ohne daß eine Stelle die Folge nennt; die Träger-Wahl, aus der die Folge folgt, steht in §3 des Plans weiter auf **„offen"**. | [`AGENTS.md`](../../AGENTS.md) §3.6 · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) · `slice-215-…` §2 DoD (1) | [`harness/README.md`](../../harness/README.md):105 · [`.githooks/commit-msg`](../../.githooks/commit-msg):12 | ja — die zwei Kommandos in §2 der Messungen | `traeger-aktivierung-bricht-das-lifecycle-werkzeug-der-selben-regel` *(**neu***) |
| F-2 | MEDIUM | Die Kopplungs-Aussage hält nur **eine** Richtung: gemessen bleibt die ganze Datei grün, wenn der Prüfer um eine Kennung erweitert wird, die in `.d-check.yml` nicht steht, und ebenso, wenn die Config ein Muster verliert, das der Prüfer behält (§Eigene Messungen 5) — gehalten ist allein *jedes Config-Muster wird angenommen* plus **eine** fest verdrahtete Kennung außerhalb der Liste (`DC-0001`). Fünf lebende Stellen behaupten demgegenüber *„in beide Richtungen"* bzw. *„hält die zwei Fassungen"*. | [`AGENTS.md`](../../AGENTS.md) §3.6 · `slice-215-…` §6 Risiko 2 | [`harness/tools/commit-msg-traceability.sh`](../../harness/tools/commit-msg-traceability.sh):19 · [`test/commit-msg-hook.bats`](../../test/commit-msg-hook.bats):14-17 · [`.d-check.yml`](../../.d-check.yml):383 · [`harness/sensors/commit-msg-check.md`](../../harness/sensors/commit-msg-check.md):30 · [`Makefile`](../../Makefile):189 | ja — die zwei Läufe in §5 der Messungen | `kopplungs-zusage-weiter-als-der-sensor` (= Registerklasse *Zusage nennt Sensor, der Form nicht sieht*) |
| F-3 | LOW | Die Zeile *„`git commit … -m …` → nicht erreicht"* der neuen Reichweiten-Tabelle steht schärfer als der Kopf des Guards, den sie beschreibt: der sagt selbst, ein `-m`-Aufruf *„entkommt NICHT garantiert"*, und gemessen blockt der Guard, sobald der **Message-Text** eine `-F`/`--file`-Form vor einem existierenden Pfad trägt (§Eigene Messungen 6). Kein Mangel des Geprüften, sondern Doku-Drift gegen ein unverändertes Artefakt. | [`AGENTS.md`](../../AGENTS.md) §3.6 · [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) | [`harness/README.md`](../../harness/README.md):104 gegen [`.claude/hooks/pretooluse-commit-msg-guard.sh`](../../.claude/hooks/pretooluse-commit-msg-guard.sh):22-28 | ja — der Stub-Lauf in §6 der Messungen | `deklarierte-ausnahme-wird-von-der-erkennungs-regel-verletzt` (= Klasse aus `slice-126` Runde 2, MEDIUM-1 — hier auf der Doku-Seite) |
| F-4 | INFO | Die `--amend`-Klasse fehlt in der Tabelle, und der Träger feuert dort trotzdem: `git commit --amend --no-edit` auf einer kennungslosen Nachricht wird abgelehnt, obwohl in diesem Aufruf **niemand** eine Nachricht schreibt (§Eigene Messungen 7). Die Beobachtung des Registers (`amend-committet-fremde-index-eintraege-mit`) ist davon **nicht** betroffen — sie gilt dem Index, und die Zusage des Trägers gilt der Nachricht; die Zuordnung der Tabelle ist hier also richtig, die Feuer-Regel ist nur unbenannt. | Maintainability · [`ADR-0004`](../../docs/plan/adr/0004-durchsetzungs-emission.md) (Stolperdraht) | [`harness/README.md`](../../harness/README.md):101-108 | ja — der Lauf in §7 der Messungen | `träger-feuer-regel-fuer-eine-klasse-ohne-tabellenzeile` *(**neu***) |
| F-5 | INFO | **Für den Verifier, nicht für den Implementer:** DoD (2) verlangt den Träger *„verdrahtet"*; in diesem Klon ist er es **nicht** (`core.hooksPath` ungesetzt, ein kennungsloser `-m`-Commit geht hier durch, §Eigene Messungen 3). Ob eine Aktivierung per Handschritt + versionierter Datei die DoD erfüllt oder nur die *Möglichkeit* liefert, ist eine DoD-Frage und liegt bei Modul 11. Der README-Text benennt den Zustand ehrlich (Zeile 107 + der Absatz *„Wie der Träger auf einen frischen Klon kommt"*), die DoD-Abhakung ist damit entscheidbar — aber nicht von hier. | `slice-215-…` §2 DoD (2) | [`Makefile`](../../Makefile):207-210 · [`harness/README.md`](../../harness/README.md):107·110-114 | ja — die zwei Läufe in §3 der Messungen | `doD-punkt-verlangt-verdrahtung-die-das-opt-in-nicht-herstellt` *(**neu***) |

---

## Negativbefunde (geprüft, ohne Befund)

| Bereich | Ergebnis |
|---|---|
| **Der Zahn `test/mutations/340-…` trifft den benannten Wächter** | **geprüft, ohne Befund.** Der Fall mutiert `harness/tools/commit-msg-traceability.sh` — die Stelle, die der Aufrufer (`.githooks/commit-msg`) benutzt —, die bats-Stufe fährt den Aufruf **über den Hook** und nicht gegen das Skript direkt, `# verify: test-bats` ist ein Modus mit Fehlschlag-Form, und der `# expect:`-Name steht in der Ausgabe (`not ok 65 traeger: Message ohne Kennung wird abgelehnt`, §Eigene Messungen 4). Vier Fälle fallen, nicht einer — die Aussage *„4 rot"* der Commit-Message trifft. |
| **Die vier Belege des README-Blocks** | **geprüft, ohne Befund.** Alle vier reproduziert, mit denselben Exit-Codes (§Eigene Messungen 1). Die Vorbedingung *„`--allow-empty` hält den Versuch ohne Baum-Änderung"* und die Zählung *„der erste Aufruf erzeugt gar keinen Commit, die übrigen einen leeren"* treffen. |
| **Der frische Klon, in beiden Hälften ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit))** | **geprüft, ohne Befund.** Die Datei reist mit (Index-Modus `100755`, `git ls-files -s`), `core.hooksPath` reist nicht, `make hooks-install` ist der einzige Schritt dazwischen, und beide Zustände sind am Verhalten unterscheidbar (§Eigene Messungen 3). |
| **Der Hook von einem Unterverzeichnis aus** | **geprüft, ohne Befund.** `git` ändert vor dem Hook das Arbeitsverzeichnis auf die Wurzel; gemessen zusätzlich ein eigener Commit aus einem Unterverzeichnis — grün mit Kennung, rot ohne. Die `BASH_SOURCE`-Auflösung im Hook hält. |
| **Der Umgehungs- und Ausnahme-Katalog** | **geprüft, ohne Befund.** `--no-verify` umgeht (gemessen), `Merge `- und `Revert `-Betreff sind ausgenommen (gemessen, mit der Grenze `Merge` ohne Leerzeichen), fail-closed bei fehlender/nicht lesbarer Datei (Exit 2, bats `ok 72`/`ok 73`), Kommentarzeile zählt nicht (bats `ok 71`). |
| **Gate-Ausweitung oder Schwellen-Senkung ([`AGENTS.md`](../../AGENTS.md) §3.5)** | **geprüft, ohne Befund.** `git diff 7ee36939^..9ab67fa0 -- .d-check.yml \| grep -E '^[+-][^+-]' \| grep -vE '^[+-]#'` → **eine** Zeile (`- hooks-install` in `exempt-targets`); `modules:` unverändert (`… \| grep -cE '^[+-].*modules:'` → 0). Das eine neue `make`-Ziel ist im **Werkzeuge**-Abschnitt mit `kein Gate` geführt und steht in `exempt-targets` — beide Richtungen sind von `test/targets-modul-wiring.bats` gehalten (`ok 277`, `ok 278`). |
| **Halluziniertes Gate ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6))** | **geprüft, ohne Befund.** Jedes im Diff genannte `make`-Ziel existiert (`hooks-install`, `test-bats`, `shell-lint`, `comment-claims`); `make help` führt `hooks-install`. Kein Ziel behauptet eine Prüfung, die es nicht fährt. |
| **Fremde Pfade oder Kennungen im Baum** | **geprüft, ohne Befund.** `git diff … \| grep -nE '^\+' \| grep -E '/Development\|/home/\|/tmp/\|a-check\|d-check/harness'` → kein Treffer. Die Prosa über das Nachbar-Repo steht im Plan (§3) **ohne** Pfad auf jenes Checkout. |
| **`AGENTS.md` §3.7 — Kommentar-Klassen in den zwei neuen Skripten** | **geprüft, ohne Befund.** Zusage (Exit-Codes, Kommentarzeilen-Regel), Kopplung (`.d-check.yml`, bats), Abgrenzung (`kein Gate`, kein Docker), Rang-Zeiger (`AGENTS.md` §5, `LH-QA-03`) und Grenze (`ANWESENHEIT` statt Wahrheit, `core.commentChar`) stehen als Indikativ über den Ist-Zustand; keine verworfene Alternative, kein abwesender Text, keine Befund-Kennung, kein Lauf-Protokoll. `make comment-claims` → `61 Datei(en) geprueft, 0 Befund(e)`. |
| **`AGENTS.md` §3.9 (Docker-only)** | **geprüft, ohne Befund.** Der Träger läuft im Commit-Pfad ohne Docker (bash + coreutils), `make hooks-install` braucht `git` — die von §3.9 zugelassene Host-Abhängigkeit. Kein Host-Paketmanager, keine Host-Toolchain. |
| **Referenz auf eine superseded ADR** | **geprüft, ohne Befund.** §Bezug des Plans nennt `ADR-0004`, `ADR-0028`, `MR-002`, `LH-QA-01`, `LH-QA-03`; keine davon trägt ein `Supersedes`-Feld, und keine ist `Deprecated`/`Superseded by`. Die neue Doku verweist auf `AGENTS.md` §5 und `harness/README.md` §Traceability, nicht auf eine ADR. |
| **Zwei Wächter über demselben Gegenstand (§6 Risiko 3)** | **geprüft, ohne Befund — die doppelte Meldung tritt im Normalpfad nicht auf.** Der PreToolUse-Zusatz sitzt **vor** der Ausführung und blockt den Tool-Call; kommt er durch (andere Aufrufform, Werkzeug, Nicht-Agent-Kontext), ist er nicht geladen, und der Hook meldet allein. Beide Reichweiten stehen als Tabelle nebeneinander. Der Ausgang des Risikos ist Sache der Closure, nicht dieses Reports. |
| **Zahlen in den Artefakten des Diffs ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert), [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung))** | **geprüft, ohne Befund.** Die lebenden Artefakte des Diffs tragen keine mitwandernde Messzahl; die Aufzählungen („zwei Träger", „die beiden letzten Zeilen", `1..11`) sind Struktur-Aussagen desselben Artefakts. Die Commit-Message nennt `11 Faelle, 4 rot` — beides in diesem Lauf nachgemessen und richtig (§Eigene Messungen 4). |
| **Der Kopplungstest als Extrakor (`sed` über `.d-check.yml`)** | **geprüft, ohne Befund — heute.** Er liest den `commits:`-Block bis zur ersten Zeile ohne Einrückung/`#` und zieht daraus die einzeiligen `- '…'`-Einträge; `exempt-pattern: '…'` fällt durch das führende `-` aus dem Muster, und die `sources:`-Einträge tragen keine Anführungszeichen dieser Form. Beides nachgemessen (bats `ok 74`). Die Bindung an die Blockgrenze ist nicht deklariert — als F-2-nahe Grenze benannt, kein eigener Befund. |

---

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 1 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** `traeger-aktivierung-bricht-das-lifecycle-werkzeug-der-selben-regel` ·
`kopplungs-zusage-weiter-als-der-sensor` · `deklarierte-ausnahme-wird-von-der-erkennungs-regel-verletzt` ·
`träger-feuer-regel-fuer-eine-klasse-ohne-tabellenzeile` ·
`doD-punkt-verlangt-verdrahtung-die-das-opt-in-nicht-herstellt`

Die dritte ist die **Wiederkehr** einer Klasse aus `slice-126` Runde 2 (dort MEDIUM-1, auf der
Code-Seite); die zweite ist die Zuordnung zur Registerklasse `zusage-nennt-sensor-der-form-nicht-sieht`.
Die Zuordnung zu `BEO-<KUERZEL>/<slug>` und das Anlegen der Belege sind Sache der Slice-Closure,
nicht dieses Reports.

## Verdikt

**Merge-blockierend: ja** — zwei MEDIUM. F-1 und F-2 sind keine Formulierungsfragen: F-1 ist eine
**ungetroffene Entscheidung** (§3 `docs/plan/adr/` steht auf „offen", §4 bindet sie an den
Architect), die im gelieferten Zustand nur deshalb folgenlos bleibt, weil der Träger in diesem
Klon entwaffnet ist; F-2 ist die Mitigation eines **im Plan selbst benannten Risikos** (§6 Risiko 2),
von der gemessen nur die halbe Richtung hält.

**F-1 ist MEDIUM und nicht HIGH, mit Absicht:** keine der HIGH-Anker des Reviewer-Skills trifft —
kein behauptetes Gate ohne Deckung (`hooks-install` ist als *kein Gate* geführt), kein
stilles Grün (die Reichweite steht als Tabelle neben der Zusage), und das Gegenbeispiel zur
Zeile *„erreicht"* ist im Skript-Nachbau **rot gesehen**. Der Mangel ist die **Abdeckung** der
Aussage und die fehlende Zuordnung der Klasse zu einer Antwort — genau die MEDIUM-Liste.

**F-3 ist LOW und nicht MEDIUM:** die Autorität über das Verhalten des Guards ist sein eigener,
von diesem Diff **unveränderter** Kopf, und er trägt die Grenze ausdrücklich; die neue Tabelle
widerspricht ihm in einer Zelle. Das ist Drift gegen ein Artefakt, nicht gegen den Code — und die
Klasse ist im Bestand nicht eingetreten (`slice-126` Runde 2: Fundmenge 0).

**Zu den zwei Fragen, um die dieser Lauf geführt wurde.**

1. **Entwaffnen oder die Werkzeug-Formen ziehen.** Die Entwaffnung ist als *Handlung in diesem
   Klon* richtig — scharf gestellt reißt der Träger die Läufe der anderen Rollen (§Eigene
   Messungen 2), und die Weisung, `make hooks-install` hier nicht zu fahren, hat genau diesen
   Grund. Sie ist aber **keine Antwort auf die Träger-Frage**, und sie steht nirgends als
   Entscheidung: die Werkzeug-Formen sind der zweite Arm derselben Frage, und ob ihn dieser
   Slice zieht, entscheidet §3/§4 des Plans. Die Einordnung des Implementers, die Verletzung sei
   *„schon da und nur unsichtbar"*, trägt gemessen (§Eigene Messungen 2, 44 von 411 `slice-mv`-Commits
   ohne Kennung, die zwei jüngsten aus der Namens-Form) — sie ist nur nicht die ganze Antwort:
   mit [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
   wird der Fall für jeden neuen Slice der Regelfall.
2. **Der Start-Trigger §4.** Formal unerfüllt; der Vollzug trägt trotzdem, weil die *Form* der
   Antwort von der Slice-Vorlage gedeckt ist und der Implementer die Architect-Antwort nicht
   beansprucht. **Der Befund ist darum nicht der Übergang, sondern die Folge:** die unmade
   Entscheidung hinterläßt eine Aktivierung, deren erster Zug ein Werkzeug bricht (F-1), und
   §3 steht weiter auf „offen" — das gehört vor die Closure, nicht in ihren Text.

**Was der Reviewer geprüft und was er nicht geprüft hat.** Gezogen: die drei Commits vollständig;
Rot/Grün-Paare des Trägers (vier Klassen plus die Werkzeug-Klasse); der echte `make slice-mv` in
einer Wegwerf-Kopie; die Message-Form von `archive-welle`; der frische Klon in beiden Zuständen;
der Zahn einzeln gegen die mutierte Kopie; die Kopplung in beiden Richtungen; der Guard-Stub für
die `-m`-Klasse; `--amend`; `make gates` vollständig (EXIT 0, `docs-check` 1428/0, `comment-claims`
61/0, `test-bats` 293 grün). **Nicht gezogen:** kein voller `make mutate` (Weisung: Post-integration;
der Zahn wurde stattdessen einzeln gefahren), **kein** `make hooks-install` in diesem Klon
(Weisung — er würde die Läufe der anderen Rollen reißen), `make archive-welle` nicht als ganzer
Lauf (nur seine Message-Form, weil er eine geschlossene Welle und einen Baum-Eingriff voraussetzt),
`make smoke`/`make full-smoke` und die emittierte Ebene (im Plan §1 ausgeschlossen), sowie die
DoD-Abhakung — sie ist Verifier-Sache.

**Übergabe:** F-1 und F-2 gehen an den **Implementer**; F-1 zugleich als **Übergabe-Artefakt** an
den **Planner/Architect**, weil die Frage dahinter die Träger-Wahl aus §3/§4 ist und nicht im
Implementations-Kontext entschieden wird. F-3 ist eine Zelle Doku, F-4 eine benannte
Feuer-Regel ohne Entscheidungsbedarf, F-5 gehört dem **Verifier**. Die Finding-Klassen gehen
zusätzlich in die Slice-Closure §7 und von dort in den Zähler. DoD-/Spec-Konformität prüft der
Verifier separat (Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
