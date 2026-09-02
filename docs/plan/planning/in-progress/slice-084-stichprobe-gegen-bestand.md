# Slice slice-084: Stichprobe gegen den Bestand, nicht gegen das Delta

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-10](../welle-10-re-baseline.md).

**Bezug:** [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) — die Aussage
*„keine inhaltlichen Adaptionen ggü. Baseline-Default"* ist genau die, über die diese Stichprobe
etwas herausfindet.

**Verantwortlich:** Planner (pt9912) — der gesicherte Liefergegenstand aus §3 ist die Closure-Notiz
dieses Slice selbst (§7, eine lebende Plan-Datei); die beiden `nur bei Fund`-Zeilen für einen
einzelnen Fund — Folge-Slice in `docs/plan/planning/open/` oder Carveout in `docs/plan/carveouts/`
(DoD (3)) — sind ebenfalls lebende Plan-Dateien, und Carveouts identifiziert nach
Baseline-Regelwerk `modul-07-carveouts.md` §Rollen (Modul 8) der Planner. Präzedenzfall
[slice-131](../open/slice-131-praesens-aussage-gegen-den-gepinnten-stand.md) trägt dieselbe
Artefaktklasse (*„die berührte Menge sind lebende Plan- und Welle-Dateien"*). Die dritte, ebenfalls
`nur bei Fund` geführte Zeile — `harness/conventions.md`, Adaptions-Block-Eintrag bei einer
deklarierten Abweichung — bleibt wie dort eine **Übergabe** an den Architect
([`AGENTS.md`](../../../../AGENTS.md) §3.8) und wechselt den Halter nicht. Das Feld weicht damit
von der Default-Besetzung ab, die Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als
State Machine nennt (*„den Rolleninhaber der Implementer-Rolle"*).

**Autor:** Planner. **Datum:** 2026-08-09.

---

## 1. Ziel

Ein Abschnitt der Baseline, der **kein Delta** hatte, ist gegen die ausgefüllten Artefakte
geprüft. Sein Gegenstand ist der **Bestand**, nicht die Änderung — deshalb läuft er unabhängig
vom Ergebnis der Tag-Frage und hätte auch bei aktuellem Pin zu laufen.

**Warum das eine eigene Eigenschaft der Prozedur ist:** Eine Baseline-Regel, die **nie** ins
ausgefüllte Artefakt übernommen wurde und sich seither **nie** geändert hat, erzeugt keinen
Template-Diff und hat keinen Eintrag, den der Adaptions-Durchgang abschreiten könnte. Sie ist
unsichtbar, *weil* sie alt und stabil ist.

**Der Präzedenzfall ist dieses Repo.** Modul 15 lag seit `554cade` (2026-07-17) vendored im Baum,
taucht in vier Commits auf — allesamt Re-Vendor — und war nie inhaltlich behandelt; das wurde der
Trigger von [welle-09](../welle-09-modul-15-konformitaet.md). Die Ursache ist mechanisch: die
Adoptions-Prüfung sieht bei jeder Re-Baseline nur das Delta, nie den Bestand.

**Auflösung eines Plan-Mangels (entschieden vor der Messung).** DoD (3) und die §3-Tabelle
spannten gegeneinander: DoD (3) routet jeden Fund über einen Folge-Slice oder Carveout, die
§3-Tabelle führte `harness/conventions.md` zugleich als in **diesem** Slice geänderte Datei
(„update, nur bei Fund"). Beides zugleich geht nicht, und das Kopf-Feld **Verantwortlich** hat die
Antwort bereits vorweggenommen: die dritte, ebenfalls `nur bei Fund` geführte Zeile bleibt eine
**Übergabe an den Architect** und wechselt den Halter nicht. **DoD (3) gilt; die §3-Tabelle ist
entsprechend korrigiert** (unten): `harness/conventions.md` wird in diesem Slice **nicht**
editiert — das Artefakt gehört dem Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Ein Fund
geht ausschließlich als Folge-Slice in `docs/plan/planning/open/` oder als Carveout aus diesem Lauf
hervor; die Direktänderung entsteht, wenn überhaupt, im Folge-Lauf. Träfe die Entscheidung
stattdessen „in diesem Slice", griffe die Rückführung `in-progress → open` — wie gerade bei
[slice-131](../open/slice-131-praesens-aussage-gegen-den-gepinnten-stand.md) —, weil ein
Planner-Kontext dieses Artefakt nicht direkt schreiben darf.

## 2. Definition of Done

- [x] Ein Abschnitt **ohne Delta** ist gewählt und die Wahl belegt — die Komplementärmenge zu
      `git diff <alt> <neu> -- .harness/baseline/`. Umfang: **genau ein** Abschnitt, keine
      Vollinventur.
- [x] Je Regel dieses Abschnitts ist beantwortet: *Steht sie im ausgefüllten Artefakt — oder als
      deklarierte Abweichung?* Zweimal nein heißt: nie übernommen.
- [x] Der Ausgang ist verbucht: **ein** Fund geht den Weg jeder Diskrepanz (Übernahme im nächsten
      Slice oder Carveout mit Auflösungs-Trigger, **nie** als Direktänderung in diesem Slice —
      Auflösung siehe Ende §1); **mehrere** Funde treffen nicht die einzelne Regel, sondern die
      [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)-Aussage — sie ist
      dann falsch und wird korrigiert, ebenfalls über den Folge-Slice, nicht in diesem.
- [x] `make gates` grün.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| dieser Slice, §9 (neu) und §7 | update | der geprüfte Abschnitt und sein Ergebnis — die Rotation braucht ein Gedächtnis |
| [`harness/conventions.md`](../../../../harness/conventions.md) | **keine — Architect-Artefakt** | ein Fund routet über die Zeile darunter, nie als Direktänderung in diesem Slice ([`AGENTS.md`](../../../../AGENTS.md) §3.8) |
| `docs/plan/carveouts/` bzw. `docs/plan/planning/open/` | neu, **nur bei Fund** | Carveout mit Auflösungs-Trigger oder Folge-Slice — trägt die `harness/conventions.md`-Änderung im Folge-Lauf |

## 4. Trigger

[slice-081](../done/slice-081-baum-tauschen-pin-ziehen.md) liegt in `done/`. **Nicht** abhängig vom
Adaptions-Durchgang: sein Gegenstand ist die Änderung, dieser hier prüft den Bestand.

Rückführungen: `in-progress` → `next`, wenn der gewählte Abschnitt mehrere Artefakte gleichzeitig
trifft und die Prüfung zur Inventur wird. `in-progress` → `open`, wenn ein Fund eine Entscheidung
verlangt, die über diesen Slice hinausreicht.

## 5. Closure-Trigger

DoD vollständig, Closure-Notiz geschrieben — inklusive der Angabe, **welcher** Abschnitt geprüft
wurde.

## 6. Risiken und offene Punkte

- **Die Versuchung ist die Vollinventur.** Ein Abschnitt pro Audit, rotierend; die Prozedur nennt
  den Grund selbst — sonst verliert die Welle ihr Closure-Kriterium. — **Ausgang:** **entfallen**
  → der Durchgang blieb bei genau einem Abschnitt: §9 prüft
  `### Multi-Stage-Build: die operativen Disziplinen (Modul 14)` und dessen Regeln, keine zweite
  Sektion und kein zweites Modul
  (`grep -cE '^\|.*\| (ja|\*\*nein\*\*) \|' docs/plan/planning/*/slice-084-stichprobe-gegen-bestand.md`
  → **4** Regel-Zeilen; der Glob trägt den Aufruf über den `git mv` hinweg, und die Zahl ist die
  des geprüften Abschnitts, kein Erwartungswert —
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Die Rückführung `in-progress` → `next` aus §4 wurde damit nicht ausgelöst.
- **Die Rotation hat kein Gedächtnis außer der Closure-Notiz.** Welcher Abschnitt zuletzt geprüft
  wurde, steht danach in §7 dieses Slice und in `welle-10-results.md`; ein Sensor, der die Rotation
  führt, existiert nicht. Das ist eine benannte Lücke, keine Zusage. — **Ausgang:** **weiter offen**
  → Beobachtungs-Register, [`BEO-012`](../observations.md) (Sub-Area `*`, 1×, Beleg `slice-084`).
  Kein Folge-Slice: der Eintrag steht bei 1×, der Lese-Schritt greift bei 3×. Von den zwei Trägern,
  die dieser Punkt nannte, existiert beim Übergang nur der erste — die Results-Notiz entsteht erst
  bei der Welle-Closure (`ls docs/plan/planning/done/welle-10-results.md` → nicht vorhanden).
- **Eine BF-Markierung ist hier nicht die Antwort.** Sie regelt Doc ↔ Code und trifft die Achse
  nicht, um die es geht (Baseline ↔ ausgefülltes Artefakt). — **Ausgang:** **entfallen** → die
  Abgrenzung hielt über den ganzen Durchgang: Der Fund ist eine fehlende **Deklaration** — kein
  Eintrag des Adaptions-Blocks nimmt die zwei Regeln aus (§9, Spalte *Beleg*) —, kein
  Doc-↔-Code-Reifegrad. Er lief über den in DoD (3) vorgesehenen Weg, §8 führt alle berührten
  Sub-Areas GF, und eine BF-Markierung wurde an keiner Stelle erwogen.
- **Mehrere Funde sind der interessante Fall.** Dann ist nicht eine Regel offen, sondern eine
  Aussage über das ganze Repo falsch — und die Korrektur ist größer als dieser Slice. Sie wird
  benannt und geschnitten, nicht hier erledigt. — **Ausgang:** **eingetreten** → zwei der vier
  Regeln sind zweimal nein (§9); getroffen ist damit die
  [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)-Blankett-Klausel, nicht
  die einzelne Regel. Folge-Slice
  [slice-146](../open/slice-146-modul-14-multi-stage-build-abweichungen-deklarieren.md) trägt die
  Korrektur als Architect-Übergabe und liegt als Datei in `open/`. Kein Carveout: kein Gate ist
  deswegen rot (§9, *Route*).

## 7. Closure-Notiz (nach `done/`)

**Geprüfter Abschnitt (Closure-Trigger §5).**
`### Multi-Stage-Build: die operativen Disziplinen (Modul 14)` aus `modul-14-docker-harness.md`,
zwischen `v3.5.2` und `v5.12.0` wortgleich. Wahl, Beleg der Delta-Freiheit und die Antwort je Regel
stehen in §9 dieses Plans und werden hier nicht gedoppelt; der Ausgang nach DoD (3) ist der Fall
*mehrere Funde* — zwei von vier Regeln zweimal nein.

**Closure-Kriterien (beobachtet, nicht behauptet):**

1. **DoD vollständig.**
   `grep -c '^- \[ \]' docs/plan/planning/*/slice-084-stichprobe-gegen-bestand.md` → **0** offene
   Punkte (der Glob trägt den Aufruf über den `git mv` hinweg).
2. **`make gates` grün** nach dem Commit dieser Closure-Notiz — der Stop-Hook-Stempel deckt den
   Arbeitsbaum.

- **Was hat funktioniert:** Der Schnitt fand, wonach er geschnitten war. §1 sagte zu, dass eine nie
  übernommene und seither stabile Baseline-Regel weder einen Template-Diff noch einen Eintrag im
  Adaptions-Durchgang erzeugt; genau zwei solche Regeln lagen im **ersten** geprüften Abschnitt.
  Kein Gate ist ihretwegen rot (§9, *Route*), und der Delta-Weg sieht sie nicht — die gewählte
  Unter-Sektion ist zwischen beiden Tags wortgleich (§9, `diff` über beide `git show`-Ausgaben →
  leer). Getragen hat den Fund die **zweite** Frage aus DoD (2) — *oder als deklarierte
  Abweichung?*: Sie verhindert den Kurzschluss, ein vorhandener ADR-Text zum Thema (hier
  [`ADR-0003`](../../adr/0003-go-native-binaries.md), OCI-Images) sei schon die Erfüllung. Genau
  diese Falle führt [`BEO-008`](../observations.md), und §8 hat sie **vor** der Messung benannt,
  nicht danach.
- **Was ging anders als geplant:** Zwei Dinge. (1) Der Plan trug einen Mangel, der vor der Messung
  aufzulösen war: DoD (3) und die §3-Tabelle spannten gegeneinander — die eine routet jeden Fund
  über einen Folge-Slice, die andere führte
  [`harness/conventions.md`](../../../../harness/conventions.md) zugleich als in *diesem* Slice
  geänderte Datei. Entschieden zugunsten von DoD (3), die §3-Tabelle ist entsprechend korrigiert
  (§1, Ende); die Rückführung `in-progress` → `open`, die bei umgekehrter Entscheidung fällig
  gewesen wäre, entfiel damit. (2) Die DoD dieses Plans stammt aus der Vorlage **vor** der
  Re-Baseline und führt vier Closure-Pflichten nicht als eigene Zeilen
  (`grep -c '^- \[ \]' .harness/baseline/v5.12.0/templates/docs/plan/planning/slice.template.md`
  → **9** Zeilen gegen
  `awk '/^## 2\. Definition/,/^## 3\./' docs/plan/planning/*/slice-084-stichprobe-gegen-bestand.md | grep -cE '^- \[[ x]\]'`
  → **5**; beide Zahlen wandern mit ihrer Datei und sind keine Erwartungswerte,
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Getragen sind die vier hier trotzdem — Beobachtungs-Register, Risiko-Ausgänge,
  Reconciliation-Register (dieses Repo hat keinen Brownfield-Bootstrap,
  `ls docs/plan/planning/reconciliation.md` → nicht vorhanden) und die drei Paarungen hängen nach
  Modul 5 und 6 am **Übergang** nach `done/`, nicht an einer DoD-Zeile. Nachgezogen wird die
  DoD-Form nicht: sie ist der Vertrag, gegen den dieser Slice geschnitten und geprüft wurde.
- **Steering-Loop-Eintrag: eine benannte Lücke, gezählt statt verkörpert.** Ein rotierender
  Prüf-Gegenstand — welcher Baseline-Abschnitt zuletzt gegen den ausgefüllten Bestand geprüft wurde
  — hat keinen stehenden Ort und keinen Sensor ([`BEO-012`](../observations.md), 1×). Mit diesem
  Slice ist nichts verkörpert: der Eintrag steht bei 1×, der Lese-Schritt greift bei 3×. Die zweite
  Lehre des Durchgangs — dass die Blankett-Klausel von
  [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) für einen Abschnitt falsch
  sein kann, ohne dass ein Gate rot wird — ist keine Regel dieses Slice, sondern die Fracht von
  [slice-146](../open/slice-146-modul-14-multi-stage-build-abweichungen-deklarieren.md): sie ändert
  ein Architect-Artefakt ([`AGENTS.md`](../../../../AGENTS.md) §3.8).
- **Beobachtungs-Register (`../observations.md`):** eine neue Kennung —
  [`BEO-012`](../observations.md) (Sub-Area `*`, 1×, Beleg `slice-084`). Kein bestehender Eintrag
  wurde erhöht, und die beiden Kandidaten sind in §8 vor der Messung geprüft:
  [`BEO-008`](../observations.md) bleibt bei 1× — dieser Lauf ist die **Anwendung** der Lehre, kein
  zweites Auftreten des Kurzschlusses; [`BEO-003`](../observations.md) bleibt bei 2×, weil der
  auslösende Lauf kein Slice-Closure-Lauf war und damit keinen formgebundenen Beleg hat.
- **Folge-Slices:**
  [slice-146](../open/slice-146-modul-14-multi-stage-build-abweichungen-deklarieren.md) — *Modul 14
  „Multi-Stage-Build": zwei Regeln bekommen ihren Ausgang*, liegt als Datei in `open/`. Kein
  weiterer: Der zweite Risiko-Ausgang nahm die Register-Route, statt einen Slice zu erzeugen — genau
  die Route, die [`BEO-001`](../observations.md) verkörpert hat.
- **Risiken aus §6:** vier benannt
  (`awk '/^## 6\. Risiken/,/^## 7\. Closure-Notiz/' docs/plan/planning/*/slice-084-stichprobe-gegen-bestand.md | grep -c '^- \*\*'`
  → **4**), vier mit genau einem Ausgang — einer *eingetreten* (Folge-Slice `slice-146`), einer
  *weiter offen* ins Register (`BEO-012`), zwei *entfallen* (keine Vollinventur · BF-Markierung an
  keiner Stelle erwogen).
- **Drei Paarungen:** hier **nicht** geprüft. Dieses Repo führt Wellen-Betrieb, und dieser Slice ist
  Mitglied von [welle-10](../welle-10-re-baseline.md); Modul 6 §Wellen-Closure-Prozedur legt die
  Paarungen (Anker · Folge-Slice · Register) auf Closure-Schritt 3c — **nach** dem `git mv` der
  Welle-Datei, weil sie die dort erst entstehenden Einträge prüfen —, und Modul 8 §Rollen-Sequenz
  für eine Welle weist denselben Schritt dem Planner-Kontext der Welle-Closure zu. Die hier fällige
  Hälfte ist, die Prüfung dorthin zu übergeben, statt sie zu doppeln.

## 8. Sub-Area-Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `*` (gesamtes Repo — deckt den geprüften
`Dockerfile`-Abschnitt) und `docs/plan/` (dieser Plan, der Folge-Slice). Beide sind bereits in der
Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
geführt — keine zu grobe, neu auszudifferenzierende Sub-Area.

**Vorgelagert — offene Beobachtungen sichten:**

- **`BEO-008`** (1×, `*`, Beleg slice-082) — *„Achse 1 … ist nicht mit ‚die Baseline behandelt
  jetzt dasselbe Thema' beantwortet"*. Dieselbe Arbeitsart wie dieser Durchgang: §9 prüft je Regel
  des gewählten Abschnitts, ob das Artefakt die **konkrete Pflicht** erfüllt — nicht, ob irgendwo
  im Repo ein verwandtes Thema auftaucht. Bei der Runtime-Stage-Regel lag der Kurzschluss nahe
  (*„[`ADR-0003`](../../adr/0003-go-native-binaries.md) bespricht OCI-Images, also erledigt"*) und
  wurde verworfen: die ADR entscheidet die
  Architektur, nimmt die Regel aber an keiner Stelle ausdrücklich im Adaptions-Block-Sinn aus (§9).
  Der Zähler bleibt bei 1× — dieser Lauf ist die Anwendung der Lehre, kein zweites Auftreten des
  Fehlers; die Prüfpflicht selbst wandert als DoD-Punkt in
  [slice-146](../open/slice-146-modul-14-multi-stage-build-abweichungen-deklarieren.md) weiter.
- **`BEO-003`** (2× im Register: slice-137, slice-144) — nach dem Move `slice-144: open → next`
  dieser Sitzung und dem folgenden Link-Abgleich-Commit (`91e1fe0`) läge ein drittes Auftreten vor,
  das nach Modul 6 die 3×-Schwelle (Lücke statt Notiz) erreichte. **Nicht der Gegenstand dieses
  Slice, aber hier benannt, weil der Sichtungs-Schritt der Ort dafür ist:** Der Zähler wird von
  diesem Slice **nicht** erhöht — die Belege des Registers sind formgebunden (Slice-Kennung, Datei
  in `done/`), und der auslösende Lauf war kein Slice-Closure-Lauf, sondern ein einzelner Commit
  zwischen zwei Lifecycle-Übergängen. Es gibt keine Slice-Datei, die als Beleg zitiert werden
  könnte. „Ein Nicht-Closure-Lauf hat keine Route ins Register" ist damit selbst ein Befund und
  keiner, den dieser Durchgang durch Fortschreiben verdeckt — er bleibt eine benannte Lücke für
  eine künftige Planungs-Sitzung, statt hier einen Beleg zu erfinden, den die Registerregeln nicht
  zulassen.

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `harness/` und
`docs/plan/` gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).

## 9. Audit — Modul 14 §Multi-Stage-Build: die operativen Disziplinen (Übergabe-Artefakt des Durchgangs)

**Gewählter Abschnitt und Beleg der Delta-Freiheit.** `### Multi-Stage-Build: die operativen
Disziplinen (Modul 14)` in `modul-14-docker-harness.md`. Kein regelwerk-Datei ist zwischen `v3.5.2`
und `v5.12.0` auf **Datei**-Ebene delta-frei (gemessen am lokalen Kurs-Klon
`/Development/KI/ai-harness-course`, weil `.harness/baseline/` in diesem Repo nur den Ziel-Stand
führt): `for f in $(git -C /Development/KI/ai-harness-course ls-tree -r --name-only v3.5.2 --
lab/regelwerk); do git -C /Development/KI/ai-harness-course diff --quiet v3.5.2 v5.12.0 -- "$f" &&
echo "$f"; done` → kein Treffer (nur `lab/templates/Makefile` ist datei-delta-frei, kein Regelwerk).
„Abschnitt" ist deshalb wie bei [slice-082](../done/slice-082-adaptions-durchgang.md) (Modul 15,
Block-Ebene) eine **Unter-Sektion**: die gewählte ist wortgleich in beiden Tags —
`diff <(git -C /Development/KI/ai-harness-course show v3.5.2:lab/regelwerk/modul-14-docker-harness.md | awk '/^### Multi-Stage-Build/{f=1} f{print} /^### Reproduzierbarkeits-Regeln/{exit}') <(git -C /Development/KI/ai-harness-course show v5.12.0:lab/regelwerk/modul-14-docker-harness.md | awk '/^### Multi-Stage-Build/{f=1} f{print} /^### Reproduzierbarkeits-Regeln/{exit}')`
→ leer.

**Geprüft ist das ausgefüllte Artefakt `Dockerfile`, Regel für Regel:**

| Regel | Im Artefakt? | Beleg |
|---|---|---|
| Base-Image per Digest pinnen, nicht per Tag | ja | `grep -c '@sha256:' Dockerfile` → **2** (`golang`, `golangci-lint`); Update-Disziplin über `make freshness-go`/`make freshness-golangci` (read-only Melder) |
| Lock-File vor dem Code; Installer-Version gepinnt; `--frozen`-Äquivalent | ja | `COPY go.mod`/`COPY go.su[m]` steht in jeder Stage **vor** `COPY . .`; `GOFLAGS="-mod=readonly …"` verweigert das Auflösen neuer Versionen beim Build (Go-Äquivalent zu `--frozen`); die Installer-Version ist die digest-gepinnte `golang`-Base selbst |
| Stages trennen: `deps` → `build` → `runtime` (Distroless/nonroot, keine Build-Toolchain im Ergebnis) | **nein** | `grep -c '^FROM' Dockerfile` → **6** (`deps`, `warm`, `test`, `compile`, `lint`, `build`), keiner davon `distroless`/`scratch` oder vergleichbar minimal; **kein** Runtime-Image existiert. Kein Adaptions-Eintrag nimmt die Regel aus: `grep -n -i 'runtime\|distroless\|nonroot\|non-root\|modul-14\|multi-stage' harness/conventions.md` → kein Treffer |
| Image-Hash im Build-Output festhalten (`--metadata-file` → einer Datei „harness/image-hash.txt", referenziert in `harness/README.md`) | **nein** | `find . -iname 'image-hash*' -not -path './.harness/*'` → kein Treffer; `grep -n 'metadata-file\|iidfile' Makefile` → kein Treffer; `grep -c -i 'image-hash\|image_hash' harness/README.md harness/conventions.md` → **0** an beiden Stellen. Ebenfalls keine Ausnahme im Adaptions-Block |

**Ausgang (DoD 3): mehrere Funde.** Zwei von vier Regeln sind **zweimal nein** — weder im Artefakt
umgesetzt noch im Adaptions-Block ausgenommen, also **nie übernommen** (DoD 2). Nach DoD (3) heißt
das: nicht die einzelne Regel ist der Fund, sondern die
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)-Blankett-Klausel selbst
ist für diesen Abschnitt falsch — sie behauptet implizit Konformität (*„wo kein Eintrag sie
ausnimmt, gilt die Klausel fort"*), die hier für zwei Regeln nicht vorliegt.

**Route (§1-Auflösung).** Kein Gate ist deswegen rot — es fehlt eine Deklaration, kein
Carveout-Fall. Folge-Slice
[slice-146](../open/slice-146-modul-14-multi-stage-build-abweichungen-deklarieren.md) trägt die
Architect-Übergabe. Was die zwei Regeln dort werden — Adoption (Mechanismus ergänzen) oder
deklarierte Abweichung mit Begründung — entscheidet der Architect-Lauf; für die Runtime-Stage-Regel
liegt die Begründung nahe ([`ADR-0003`](../../adr/0003-go-native-binaries.md): kein OCI-Image als
Vertriebsmittel), muss aber gegen den genauen Wortlaut der Regel geprüft werden, nicht nur gegen
das Vorhandensein einer ADR zum Thema (§8, `BEO-008`); für die Image-Hash-Regel ist offen, ob sie
zur Reproduzierbarkeits-Zusage ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit))
noch etwas beiträgt, das der bestehende Gate-Stempel (`working-tree-hash.sh`) nicht schon trägt.
