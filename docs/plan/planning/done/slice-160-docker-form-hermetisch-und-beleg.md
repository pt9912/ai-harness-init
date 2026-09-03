# Slice slice-160: Die Docker-Form gegen die Ziel-Fassung — hermetischer Prüflauf und die Trennung Gate/Beleg

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-14](welle-14-re-baseline.md).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren),
[`ADR-0003`](../../adr/0003-go-native-binaries.md).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** Architect (pt9912) — der Liefergegenstand ist der Ausgang je Befund, und alle
drei Ausgänge dieses Laufs sind Einträge im Konventionsspeicher, einem Architect-Artefakt
([`AGENTS.md`](../../../../AGENTS.md) §3.8). Präzedenzfall
[slice-146](../open/slice-146-modul-14-multi-stage-build-abweichungen-deklarieren.md) trägt
dieselbe Besetzung. Das Feld weicht damit von der Default-Besetzung ab, die Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine nennt (*„den Rolleninhaber der
Implementer-Rolle"*).

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Für die vier neuen Docker-Aussagen der Ziel-Fassung steht der Ist-Zustand dieses Repos gemessen
da, und jede Abweichung trägt einen Ausgang — Konformität, `MR-<NNN>` oder Carveout.**

Die vier: *Zwei Formen des Reproduzierbarkeits-Ankers* (Archiv vs. Rezept — eine notierte
Image-Kennung hält fest, **welches** Image einen Lauf gemacht hat, und ist kein
Wiederholungs-Schlüssel) ·
*Besitz der Belege eines containerisierten Gates* (root-Besitz über einem beschreibbaren Mount) ·
*Der Prüflauf ist hermetisch — kein Mount* (Quellen per `COPY`, Rückweg über `stdout`; bei
Gate-Stage-als-Gate zwei Griffe: `--no-cache-filter` und **kein** `-q`) · und Modul 13
*Gate und Beleg — zwei Rollen derselben Prüfung* (`|| true` an den Beleg-Lauf, nie an den
Gate-Lauf; die sammelnde Stage erbt von der Quell-Stage, nicht von der Gate-Stage).

**Beide Ebenen sind Gegenstand** — der Dogfood (`Makefile`, `Dockerfile`) und die emittierte
(`internal/emit/templates/enforce/`). Was hier gilt und was das Werkzeug ausliefert, sind
verschiedene Verträge und werden getrennt beantwortet.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **Ist-Messung Mount und Besitz:** je Docker-Aufruf in `Makefile` und `d-check.mk` steht,
      ob er mountet, ob der Mount schreibbar ist und wem die Belege danach gehören — der Testfall,
      den die Quelle selbst nennt (`ls -l` auf das Build-Verzeichnis nach dem ersten Gate-Lauf).
      Dazu die Einordnung des Reproduzierbarkeits-Ankers: Archiv-Form oder Rezept-Form.
      → §9 Messung A und B.
- [x] **Ist-Messung Gate und Beleg:** wo ein Beleg-Lauf am Gate-Target oder an der Gate-Stage
      hängt, und wo ein `|| true` sitzt. Erbt eine sammelnde Stage von einer Gate-Stage, ist das
      der Befund. → §9 Messung D.
- [x] **Je Befund ein Ausgang** — Konformität (nichts zu tun, belegt), `MR-<NNN>` (benannte
      Abweichung, Architect) oder Carveout mit Auflösungs-Trigger. Getrennt für Dogfood und
      emittierte Ebene; keine Pauschale über beide. → §9, Spalte *Ausgang*:
      [`MR-048`](../../../../harness/conventions.md#mr-048),
      [`MR-049`](../../../../harness/conventions.md#mr-049),
      [`MR-050`](../../../../harness/conventions.md#mr-050); kein Carveout, weil kein Gate rot ist.
- [x] `make gates` grün.
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt. — **Keines fällig:** die drei Ausgänge
      liegen im Konventionsspeicher, und die Gate-Liste in
      [`AGENTS.md`](../../../../AGENTS.md) §4 wie in [`harness/README.md`](../../../../harness/README.md)
      ändert sich nicht (kein Target kommt, geht oder wechselt seine Zusage).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations.md`) fortgeschrieben — neue `BEO-<NNN>` oder Zähler +1 mit Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| dieser Plan, §9 | update | trägt die zwei Ist-Messungen und die Ausgänge |
| `Makefile`, `Dockerfile` | **keine** | kein Befund bekam den Ausgang *Konformität herstellen*; die drei Abweichungen sind deklariert, die Reparatur hängt an ihren Auflösungs-Triggern |
| `internal/emit/templates/enforce/` | **keine** | dieselbe Frage auf der emittierten Ebene, gemessen in §9; die Skelette liegen in [`internal/gen/`](../../../../internal/gen/), und ihr Ausgang ist ebenfalls deklariert statt umgesetzt |
| `harness/conventions.md` | update | die Antwort ist dreimal ein `MR-<NNN>` — Architect, eigener Commit |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [slice-156](../done/slice-156-baum-tauschen-pins-ziehen.md) liegt in
`done/` — erst dann ist `v5.18.0` der Ist-Maßstab, und ein Befund dagegen ist einer
([`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 2).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn ein Ausgang *Konformität
  herstellen* den Build-Weg umbaut — der Umbau ist dann ein eigener Slice, die Messung bleibt
  hier.
- `in-progress` → `open` (blockiert — Carveout?): wenn ein Befund nur durch eine Senkung einer
  bestehenden Schwelle grün würde ([`AGENTS.md`](../../../../AGENTS.md) §3.5).

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; kein Befund der zwei Messungen steht ohne Ausgang; Closure-Notiz mit
Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Messung wird zur Zusage, ohne rot gesehen worden zu sein** — *„der Prüflauf ist
  hermetisch"* ist eine Zusage nach [`AGENTS.md`](../../../../AGENTS.md) §3.6 und braucht das
  Gegenbeispiel, nicht die Lektüre des Makefiles. — **Ausgang:** **entfallen** → beide Zusagen
  dieses Laufs sind an einem Gegenbeispiel rot gesehen, nicht gelesen (§9, Messung B Punkt 3 und
  Messung C Punkt 2): der Schreibversuch im `:ro`-Mount scheitert und schreibt ohne `:ro`
  `root:root`; der Syntaxfehler im Arbeitsbaum färbt `make build` rot, mit gelesener Ursache.
  Die dritte Zusage — *der Baum bleibt unverändert* — trägt `git status -s` nach dem roten Lauf.
- **Der Umbau kostet mehr als die Abweichung** — die Rezept-Form verlangt, dass beim Build
  nichts installiert wird und jede Eingabe digest-gepinnt ist; ob dieses Repo das hält, ist
  gemessen zu beantworten und nicht anzunehmen. — **Ausgang:** **entfallen** → gemessen statt
  angenommen (§9, Messung A): beide Bedingungen halten im Dogfood, ein Umbau steht dort nicht an.
  Auf der emittierten Ebene halten sie nicht, und dort ist der Umbau nicht *teurer* als die
  Abweichung, sondern **durch eine höherrangige Quelle ausgeschlossen** —
  [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) lässt Tag *oder*
  Digest zu ([`MR-048`](../../../../harness/conventions.md#mr-048)).

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

**Closure-Kriterien (beobachtet, nicht behauptet):**

1. **DoD vollständig.**
   `grep -c '^- \[ \]' docs/plan/planning/*/slice-160-docker-form-hermetisch-und-beleg.md` → **0**
   offene Punkte (der Glob trägt den Aufruf über den `git mv` hinweg).
2. **`make gates` grün** nach dem Commit dieser Closure-Notiz — der Stop-Hook-Stempel deckt den
   Arbeitsbaum.

- **Was hat funktioniert:** Die Reihenfolge *messen, dann urteilen*. Drei der vier Anforderungen
  hätten sich aus dem Makefile heraus plausibel beantworten lassen, und zwei davon falsch: Der
  `:ro`-Mount *sieht* wie Konformität aus (er ist eine deklarierte Abweichung mit bezahltem
  Preis), und `make build` *sieht* wie ein Gate aus (sein Urteil kam beim Wiederholungslauf aus
  dem Cache). Beide Male hat erst das Gegenbeispiel entschieden. Getragen hat auch die zweite
  Frage aus der Ausgangs-Trias — *oder als deklarierte Abweichung?*: Für die Anker-Form lag der
  Kurzschluss nahe (*„[`ADR-0003`](../../adr/0003-go-native-binaries.md) streicht das OCI-Image,
  also erledigt"*) und wurde verworfen — die ADR entscheidet den **Vertriebskanal**, nicht die
  Frage, woran ein Lauf wiederholbar ist. Genau diese Falle führt
  [`BEO-008`](../observations.md), und §8 hat sie vor der Messung benannt.
- **Was ging anders als geplant:** Zweierlei. (1) Die höherrangige Quelle drehte ein Verdikt um.
  Für die emittierten Skelette sah die Baseline-Regel (*„per Digest, nicht per Tag"*) nach einer
  glatten Abweichung aus; [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
  (Rang 1) verlangt aber *„auf **Tag/Digest** gepinnt"* und lässt beides zu. Der Eintrag
  dokumentiert damit keine Nachlässigkeit, sondern eine Precedence-Entscheidung — und trägt einen
  Auflösungs-Trigger, der an einem Change Request hängt, nicht an einem Commit. (2) Der Ausgang
  *Konformität herstellen*, den §3 offenließ, wurde für **keinen** Befund gewählt: alle drei
  Abweichungen sind deklariert. `Makefile` und `Dockerfile` bleiben unberührt, und der Lauf
  berührt außer diesem Plan und dem Register nur Architect-Artefakte.
- **Steering-Loop-Eintrag: eine benannte Lücke, gezählt statt verkörpert.** Ein Folge-Slice, der
  über einen Baseline-Sprung hinweg in `open/` wartet, hält eine Pflicht, die sich unter ihm
  bewegt haben kann — und kein Schritt hält den Bestand offener Slice-Pläne gegen den neuen Stand
  ([`BEO-023`](../observations.md), 1×). Mit diesem Slice ist nichts verkörpert: der Eintrag steht
  bei 1×, der Lese-Schritt greift bei 3×.
- **Beobachtungs-Register (`../observations.md`):** eine neue Kennung —
  [`BEO-023`](../observations.md) (Sub-Area `*`, 1×, Beleg `slice-160`). Kein bestehender Eintrag
  wurde erhöht, und die drei Kandidaten sind geprüft: [`BEO-008`](../observations.md) bleibt bei
  1× — dieser Lauf ist die **Anwendung** der Lehre, kein zweites Auftreten des Kurzschlusses;
  [`BEO-009`](../observations.md) bleibt bei 5×, weil dieser Lauf keine Ableitung ändert und
  darum keine Zusage stehen lassen kann; [`BEO-013`](../observations.md) bleibt bei 1×, weil seine
  Bezugsmenge die Adaptions-Einträge sind, nicht die offenen Slice-Pläne.
- **Folge-Slices:** keiner geschnitten — das ist Planner-Arbeit. **Ein offener Punkt zur
  Übergabe:** die Fracht von
  [slice-146](../open/slice-146-modul-14-multi-stage-build-abweichungen-deklarieren.md) hat sich
  mit dem Sprung bewegt. Seine DoD (2) fragt nach dem Ausgang der Image-Hash-Regel; der neue
  Abschnitt §Zwei Formen des Reproduzierbarkeits-Ankers beantwortet die Vorfrage bereits teilweise
  (*„harness/image-hash.txt hält dann fest, welches Image einen Lauf gemacht hat; ein
  Wiederholungs-Schlüssel ist es nicht"*,
  `grep -c 'ein Wiederholungs-Schlüssel ist es nicht' .harness/baseline/v5.18.0/regelwerk/modul-14-docker-harness.md`
  → **1**). Ein Re-Cut jenes Plans gegen `v5.18.0` gehört vor seine Übernahme; dieser Lauf greift
  ihm nicht vor.
- **Risiken aus §6:** zwei benannt
  (`awk '/^## 6\. Risiken/,/^## 7\. Closure-Notiz/' docs/plan/planning/*/slice-160-docker-form-hermetisch-und-beleg.md | grep -c '^- \*\*'`
  → **2**), beide mit genau einem Ausgang — beide *entfallen*, je an einer Messung in §9
  aufgelöst.
- **Drei Paarungen:** hier **nicht** geprüft. Dieses Repo führt Wellen-Betrieb, und dieser Slice
  ist Mitglied von [welle-14](welle-14-re-baseline.md); Modul 6 §Wellen-Closure-Prozedur legt
  die Paarungen (Anker · Folge-Slice · Register) auf Closure-Schritt 3c — **nach** dem `git mv`
  der Welle-Datei, weil sie die dort erst entstehenden Einträge prüfen —, und Modul 8
  §Rollen-Sequenz für eine Welle weist denselben Schritt dem Planner-Kontext der Welle-Closure zu.
  Die hier fällige Hälfte ist, die Prüfung dorthin zu übergeben, statt sie zu doppeln.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `*` (gesamtes Repo, Build- und Gate-Weg) und
`harness/tools/` — beide führt die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area),
beide als Greenfield.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-009` (ein Fix ändert die Ableitung und lässt
die Zusage stehen) trifft das erste Risiko in §6 unmittelbar. Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.

## 9. Audit — die vier Docker-Aussagen von `v5.18.0` (Übergabe-Artefakt des Durchgangs)

**Alle vier Abschnitte sind neu**, gemessen als Tree-Operand gegen den Stand vor dem Tausch
([`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
Ausgang 2; `db83415` ist der Commit, der den `v5.12.0`-Baum entfernte). Je Abschnitt derselbe
`grep -c '^### <titel>'` auf beide Stände:

| Abschnitt | `v5.12.0` | `v5.18.0` |
|---|---|---|
| `modul-14` §Zwei Formen des Reproduzierbarkeits-Ankers | 0 | 1 |
| `modul-14` §Besitz der Belege eines containerisierten Gates | 0 | 1 |
| `modul-14` §Der Prüflauf ist hermetisch — kein Mount | 0 | 1 |
| `modul-13` §Gate und Beleg — zwei Rollen derselben Prüfung | 0 | 1 |

```sh
git show db83415^:.harness/baseline/v5.12.0/regelwerk/modul-14-docker-harness.md \
  | grep -c '^### Zwei Formen des Reproduzierbarkeits-Ankers'      # 0
grep -c '^### Zwei Formen des Reproduzierbarkeits-Ankers' \
  .harness/baseline/v5.18.0/regelwerk/modul-14-docker-harness.md   # 1
```

**Keine Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — jede Zahl unten wandert mit dem Baum.

### Messung A — Reproduzierbarkeits-Anker: Archiv-Form oder Rezept-Form?

| Bedingung der Rezept-Zeile | Dogfood | emittierte Ebene |
|---|---|---|
| jede Eingabe digest-gepinnt | **ja** — `grep -c '@sha256:' Dockerfile` → **2**, `grep -cE '^[A-Z_]+ \?= .*@sha256:' Makefile` → **3**, `grep -cE '^DCHECK_DIGEST \?= sha256:' d-check.mk` → **1** | **nein** — die Skelette pinnen per Tag (`grep -nE '^FROM ' internal/gen/golang.go internal/gen/cpp.go`: `golang:${GO_VERSION}`, `golangci/golangci-lint:${GOLANGCI_LINT_VERSION}`, `ubuntu:${CXX_VERSION}`; `grep -c '@sha256:' internal/gen/cpp.go` → **0**) |
| beim Build wird nichts installiert | **ja** — `grep -c '^require' go.mod` → **0**, `ls go.sum` → nicht vorhanden, und `git grep -hoE '^\s+"[a-z0-9.-]+\.[a-z]{2,}/[^"]+"' -- '*.go' \| sort -u` liefert nur `github.com/pt9912/ai-harness-init/…`; `go mod download` lädt damit nichts | **nein** — das C++-Skelett installiert (`apt-get install … build-essential cmake clang-tidy` in der `toolchain`-Stufe), das Go-Skelett zieht die `require`-Zeilen des Adopters |
| Archiv-Form (Image wird aufbewahrt) | **nein** — `grep -rc 'docker push' Makefile d-check.mk .github/workflows/` gibt keine Nicht-Null-Zeile | **nein** — dieselbe Messung, kein Push-Pfad im Skelett |

**Einordnung.** Dogfood = **Rezept-Form**, beide Bedingungen gehalten. Emittierte Ebene =
**keine von beiden**. Ein Image-Hash-Beleg existiert auf keiner der zwei Ebenen
(`grep -n 'metadata-file\|iidfile' Makefile d-check.mk harness/tools/*.sh` → kein Treffer;
`git ls-files | grep -ci 'image-hash'` → **0**) — das ist die Fracht von
[slice-146](../open/slice-146-modul-14-multi-stage-build-abweichungen-deklarieren.md) und
ausdrücklich **nicht** die dieses Laufs.

**Ausgang:** [`MR-048`](../../../../harness/conventions.md#mr-048) — die Rezept-Form ist benannt
(Dogfood, Konformität), die Tag-Form der Skelette ist als Abweichung deklariert und durch
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Rang 1, *„Tag/Digest"*)
gedeckt.

### Messung B — Mount, Schreibbarkeit und Besitz je Docker-Aufruf

Alle Rezept-Zeilen aus `Makefile` und `d-check.mk`, nach Weg getrennt:

| Weg | Ziele | Mount | schreibbar |
|---|---|---|---|
| `docker build --target` (Quellen per `COPY`) | `test-go`, `lint`, `build`, `compile`, `host-bin`, `release-artifacts` | keiner | — |
| `docker run -v … :ro` (eigenes Rezept) | `test-bats`, `shell-lint`, `ci-lint` | ja | **nein** |
| `docker run -v … :ro` (tool-generiertes Fragment) | `docs-check` + zehn `doc-*` in `d-check.mk`, `regelwerk-check` | ja | **nein** |
| `docker create` / `docker cp` (Extraktion) | `artifact`, `release-artifacts`, `host-bin` über [`harness/tools/artifact-copy.sh`](../../../../harness/tools/artifact-copy.sh) | keiner | — |

1. **Kein Mount ist schreibbar:**
   `grep -oE '\-v "?\$\(CURDIR\)"?[:/][^ ]*' Makefile d-check.mk | wc -l` → **15**, davon
   `… | grep -vc ':ro'` → **0**.
2. **Testfall der Quelle** (`ls -l` auf den Beleg-Bereich nach dem Gate-Lauf):
   `ls -l .harness/state/bin/` → `-rwxr-xr-x 1 db db … ai-harness-init`; `ls -la .harness/state/`
   führt Stempel, Spans und Bin sämtlich unter dem aufrufenden Nutzer. **Kein `root:root`.**
   Mechanik: der schreibende Prozess ist der Host — `mkdir -p` und `docker cp` in
   [`artifact-copy.sh`](../../../../harness/tools/artifact-copy.sh), `bash` in
   [`record-gates.sh`](../../../../harness/tools/record-gates.sh).
3. **Rot gesehen, nicht gelesen** — derselbe Aufruf wie `make test-bats`, nur schreibend:

   ```sh
   docker run --rm --network none -v "$(pwd)":/code:ro -w /code --entrypoint sh \
     bats/bats@sha256:e8f1…4e33 -c 'id -u; touch /code/PROBE'
   # uid=0
   # touch: /code/PROBE: Read-only file system   → Exit 1, Baum unverändert
   ```

   **Gegenprobe ohne `:ro`** (die Form, die der Abschnitt als Schaden beschreibt): derselbe
   Aufruf schreibt, und `ls -l` zeigt `-rw-r--r-- 1 root root 0 … PROBE`. Die Sonde ist wieder
   entfernt.

**Ausgang:** Besitz-Frage **konform** — der `:ro`-Preis ist bezahlt und die Belege gehören dem
Aufrufer. Die Mount-Form der drei eigenen Rezepte ist die Abweichung, siehe Messung C.

### Messung C — hermetischer Prüflauf und die zwei Griffe

| Aussage | Befund |
|---|---|
| Quellen per `COPY`, kein Mount | **teilweise**: der `docker build`-Weg trägt sie; drei eigene Rezepte (`test-bats`, `shell-lint`, `ci-lint`) mounten `:ro` |
| tool-generiertes Fragment mountet `:ro` | **freigestellt** — [slice-157](../done/slice-157-adaptions-durchgang-v5180.md) hat den neuen Absatz *§Und das Fragment mountet* gegen [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) entschieden: keine Nachforderung, solange nur gelesen wird |
| Griff 1 — `--no-cache-filter` an Gate-Stage-als-Gate | **teilweise**: `grep -cE '^\t+docker build --no-cache-filter' Makefile` → **3** (`test-go`, `lint`, `release-artifacts`); es fehlen `build` und `host-bin`, beide in `record-gates` |
| Griff 2 — **kein** `-q` | **konform**: `grep -cE 'docker build[^#]* (-q\|--quiet)( \|$)' Makefile d-check.mk` → **0** in beiden |

1. **Der Griff-1-Befund ist gemessen, nicht vermutet.** Unveränderter Wiederholungslauf von
   `make build`: `#13 [build 2/2] RUN … go build …` → `CACHED`, **7** gecachte Schichten. Die
   urteilende Schicht lief nicht. Zum Vergleich `make lint` (mit Griff): die fünf Schritte der
   `lint`-Stage laufen frisch.
2. **Und die Gegenrichtung ist rot gesehen.** Ein Syntaxfehler in `internal/gen/gen.go` — nur im
   Arbeitsbaum, nicht committet — färbt `make build` rot mit gelesener Ursache:
   `internal/gen/gen.go:230:29: syntax error: unexpected name ist at end of statement`, Exit
   **2**. Der Cache-Schlüssel von `#9 [build 1/2] COPY . .` deckt also den Prüfgegenstand, und
   die Meldung erreicht den Leser, weil kein `-q` gesetzt ist. `git status -s` nach dem Lauf ist
   leer — der Prüflauf hat den Baum nicht angefasst.

**Ausgang:** [`MR-049`](../../../../harness/conventions.md#mr-049) für die Mount-Hälfte (drei
eigene Rezepte, Preis bezahlt, Auflösungs-Trigger *sobald eine dieser Prüfungen schreiben muss*)
· [`MR-050`](../../../../harness/conventions.md#mr-050) für Griff 1 (Auflösungs-Trigger *sobald
die `build`-Stufe eine Eingabe zieht, die nicht im Build-Kontext liegt*) · Griff 2 **konform**.
Kein Carveout: kein Gate ist deswegen rot.

### Messung D — Gate und Beleg (Modul 13)

| Prüfung | Befund |
|---|---|
| `\|\| true` am Gate-Lauf | **keines**: `grep -c '\|\| true' Makefile d-check.mk` → **0** in beiden |
| `\|\| true` in den Helfern | **21** Vorkommen in `harness/tools/*.sh` (`grep -h '\|\| true' harness/tools/*.sh \| wc -l`), keines an einem Urteil — sie stehen an `grep`-Filtern, `read`, `diff` im Diagnose-Zweig, `chmod` und an Guard-Sonden, deren Nonzero-Exit **der gemessene Wert** ist |
| sammelnde Stage erbt von einer Gate-Stage | **nein**: `grep -nE '^FROM ' Dockerfile` → `deps` → `warm` → `test`, `deps` → `compile`, `deps` → `build`, golangci-Base → `lint`. Die Extraktions-Quelle `build` erbt von `deps` — der Quell-Stage, genau die Form *„`export` erbt von `repo`"* |
| Beleg-Lauf hängt am Gate-Target | **nein**: `hook-overhead` und `span-check` tragen ausdrücklich **keine** Prerequisite; `doc-doctor`/`doc-trace`/`doc-repair` stehen frei; `span-report: host-bin` läuft über die Quell-Stage `build`, **nicht** über `test` oder `lint` — ein rotes Gate macht den Bericht nicht unbaubar |
| emittierte Ebene | dieselbe Form: die Skelett-Gates sind reine `docker build --target`-Ziele ohne Beleg-Stage und ohne `\|\| true` (`grep -c '\|\| true' internal/gen/golang.go internal/gen/cpp.go` → **0** in beiden) |

**Eine Stelle sieht wie ein Verstoß aus und ist keiner.** `record-gates` hängt ausdrücklich an
allen Checks. Das ist kein Beleg im Sinne von Modul 13, sondern das **Urteils-Protokoll** des
Gates: Der Stempel behauptet *„die Checks waren grün"*, und über einem roten Check darf er nicht
entstehen. Die Regel schützt die **Diagnose**, nicht den Nachweis — und die Diagnose steht in den
vier Zielen der Zeile darüber, die alle ohne Prerequisite laufen.

**Ausgang:** **konform**, kein Eintrag fällig — beide Ebenen.
