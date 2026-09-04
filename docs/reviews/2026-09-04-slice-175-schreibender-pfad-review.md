# Review — slice-175, schreibender Pfad von `archive-welle` und Ablösung des Shell-Helfers

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 8/10) — frischer Kontext, getrennt von Implementation, Architektur und Planung |
| **Review-Art** | Diff gegen Plan und Hard Rules. **Nicht** DoD-Abhakung und **keine** Gate-Lauf-Bestätigung (Verifier, Modul 11) |
| **Gegenstand** | `git diff a795e53..ef18c90` — drei Implementations-Commits `1e18b7e` (schreibender Pfad in `internal/archive` + `cmd/`), `f85e9a4` (Ablösung: Helfer, bats-Satz, sieben Mutations-Fälle, `Makefile`, `.d-check.yml`, `harness/README.md`), `ef18c90` (neun Kommentare + Kopf-Feld `Verantwortlich:`) |
| **Plan** | [`docs/plan/planning/done/slice-175-archive-welle-schreibender-pfad.md`](../plan/planning/done/slice-175-archive-welle-schreibender-pfad.md) |
| **Vorherige Findings am gleichen Modul** | [`2026-09-03-slice-173-vorschau-zweig-review.md`](2026-09-03-slice-173-vorschau-zweig-review.md) · [`2026-09-03-slice-173-vorschau-zweig-review-runde-2.md`](2026-09-03-slice-173-vorschau-zweig-review-runde-2.md) · [`2026-09-03-slice-170-impl-review.md`](2026-09-03-slice-170-impl-review.md) — dieselbe Operation, lesender Zweig bzw. Shell-Fassung. Deren tragende Klasse `BEO-025` (*Zusage nennt einen Geltungsbereich, den der Code darunter nicht hält; in ihrer schärfsten Form nennt sie einen Sensor, der die Form nicht sieht*) steht im [Register](../plan/planning/observations.md) offen |
| **Bindende ADRs** | [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) (**`Proposed`** — Architect-Verdikt, das der Port als Constraint liest; ihre drei Abnahme-Kriterien, Festlegung 2 und 3 und die fünf Folgepflichten sind hier Prüfmaßstab, weil der Plan sie als solchen nennt), [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (**`Accepted`** — Eigentum am Anweisungssatz), [ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md), [ADR-0003](../plan/adr/0003-go-native-binaries.md) |
| **Anforderungen** | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten); [`AGENTS.md`](../../AGENTS.md) §3.2, §3.3, §3.6, §3.7, §3.9; [`MR-009`](../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile), [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) |
| **Skill-Version** | `.harness/skills/reviewer.md` 1.6.0 |
| **Modell** | Claude Opus 5 (1M context) |
| **Kontext frisch** | ja — **kein Beleg aus dem Implementer-Bericht übernommen.** Jede Zahl und jedes Verdikt unten ist in dieser Sitzung selbst erhoben; das Kommando steht beim Befund |

**Was in diesem Lauf gefahren wurde — und warum mehr als sonst.** Lesende Messungen über dem
Arbeitsbaum (`grep`, `git grep`, `sed`), dazu drei **Sensor-Läufe** und drei **Mutations-Sonden**.
Die Sensor-Läufe sind `make docs-check` (*578 Datei(en), 0 Befund(e)*) und `make comment-claims`
(*55 Datei(en), 0 Befund(e)*) — beide Docker-only nach [`AGENTS.md`](../../AGENTS.md) §3.9, beide
zur **Feststellung eines Befundes**, nicht als Gate-Bestätigung (die bleibt Verifier-Rolle).

Die Mutations-Sonden liefen in einer **Kopie des Baums außerhalb des Repos**
(`tar --exclude=.git`, Scratch-Verzeichnis); der Arbeitsbaum dieses Repos wurde zu keinem Zeitpunkt
verändert (`git status --porcelain` vor und nach dem Lauf leer). Der Grund für die Sonden steht in
[`AGENTS.md`](../../AGENTS.md) §3.6: Wo ein Report behauptet *„das ist unbewacht"*, ist das eine
Aussage über eine Menge und braucht denselben Beleg wie eine Zahl. HIGH-1, MEDIUM-1 und MEDIUM-2
unten sind darum **gemessen grün unter der Mutation**, nicht aus dem Test-Bestand abgeleitet.

---

## Findings

### HIGH-1 — Dass `--vorschau` nichts schreibt, hängt an einer Zeile, die kein Test erreicht

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (Hard Rule — *„Ein Test, dessen Name eine
  Eigenschaft behauptet, muss die Eigenschaft messen"*) · [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md)
  §Konsequenzen (*„der Träger trägt ab dann ein Kommando, das den versionierten Baum eines fremden
  Repos umschreibt und darin löscht"*)
- **pfad:** `cmd/ai-harness-init/archive_welle.go:97-99` (die Zeile) ·
  `cmd/ai-harness-init/archive_welle_test.go:53-68` (der Test, der sie zu decken vorgibt)
- **befund:** `archiveWelleLauf` gibt bei stehender Sperre in Zeile 94-96 zurück; erst danach steht
  `if vorschau { return 0 }`. Der einzige Test, der den Zweig mit `vorschau=true` ruft
  (`TestArchiveWelleVorschauRuehrtKeineGitOperationAn`, Zeile 64), baut einen Baum, dessen leeres
  `done/` drei Sperren erzeugt (`ergebnisnotiz`, `kein-plan`, `kein-slice`) — der Aufruf endet in
  Zeile 95, Zeile 97 wird nie ausgeführt, und der Rückgabewert wird nicht einmal geprüft. Der
  Kommentar darüber sagt dagegen *„mit --vorschau endet der Zweig nach dem Bericht, **auch wenn
  keine Sperre steht**"* — genau der Fall, den der Test nicht herstellt. Gemessen in dieser
  Sitzung: mit gelöschten Zeilen 97-99 — `--vorschau` führt dann `archive.Anwenden` aus — bleibt
  `make test-go` grün, `cmd/ai-harness-init` und `internal/archive` beide `ok`. Ein
  `test/mutations/`-Fall über dieser Eigenschaft existiert nicht
  (`sed -n 's/^# expect: //p' test/mutations/2[3-4][0-9]-archive*.sh` nennt zehn Sensoren, keiner
  davon berührt den Vorschau-Zweig).
- **verifizierbar:** ja — `make test` bzw. `make test-go` nach Entfernen von
  `cmd/ai-harness-init/archive_welle.go:97-99`; heute grün, erwartet rot.
- **klasse:** Test misst die Vorbedingung statt die im Namen behauptete Eigenschaft
  (`BEO-025`-Klasse, Sensor-Variante)

### MEDIUM-1 — Der fail-closed-Ausgang „verletzte Stub-Form" ist zugesagt, seine Verdrahtung ist ungewächtert

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 · [`harness/README.md`](../../harness/README.md)
  Zeile 79 (*„eine **verletzte Stub-Form** bricht **zwischen** den zwei Commits ab und nennt den
  Rückweg"*)
- **pfad:** `internal/archive/anwenden.go:225` (`if err := FormOK(text); err != nil`) ·
  `internal/archive/stub_test.go:131-146`
- **befund:** `FormOK` wird an genau einer Stelle im Produktivpfad gerufen
  (`grep -rn "FormOK" internal/archive/ | grep -v stub.go` → eine Zeile). Alle drei Assertions über
  `FormOK` prüfen die Funktion isoliert; kein Test führt einen Lauf, in dem sie feuert. Gemessen in
  dieser Sitzung: mit gelöschten Zeilen 225-227 — die Operation schreibt einen formwidrigen Stub
  und meldet `ok` — bleibt `make test-go` grün. Der Mutations-Fall
  `test/mutations/239-archive-welle-go-stub-ueberschrift.sh` trifft die **Logik** von `FormOK`
  (`sed`-Muster verifiziert, ein Treffer), nicht ihre **Verdrahtung**. Damit steht die
  README-Zusage über den Ausgang ohne rot gesehenes Gegenbeispiel da.
- **verifizierbar:** ja — `make test-go` nach Entfernen von `internal/archive/anwenden.go:225-227`;
  heute grün, erwartet rot.
- **klasse:** Zahn prüft die Funktion, nicht die Stelle, an der der Aufrufer sie benutzt

### MEDIUM-2 — Der Vorlagen-Wächter quantifiziert über „jeden Platzhalter" und sieht acht von zehn

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 ·
  [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 3
- **pfad:** `test/archiv-stub-vorlagen.bats:25-27` (die Extraktion) und `:39` (der Test-Name)
- **befund:** `platzhalter()` extrahiert mit `grep -oE '\{"<[^"]+>"'`. Von den zehn Ersetzungen,
  die `sliceStub` und `welleStub` führen, trifft das Muster acht:
  `grep -oE '\{"<[^"]+>"' internal/archive/anwenden.go | sort -u | wc -l` → **8**, gegen
  `grep -oE '\{"[^"]+",' internal/archive/anwenden.go | sort -u | wc -l` → **9** plus die
  konkatenierte zehnte (`{"done/<welle-id>/" + archivName, …}`), die kein Muster trifft. Die zwei
  Unsichtbaren sind `<welle-id>-results.md` und `done/<welle-id>/archiv.zip`. Gemessen in dieser
  Sitzung: nach `sed -i 's|<welle-id>-results\.md|<welle-id>-ergebnisse.md|'` in
  `.harness/baseline/v5.18.0/templates/docs/plan/planning/archiv-stub-welle.template.md` bleiben
  alle vier bats-Fälle grün (`1..4`, Exit 0) — obwohl der Welle-Stub danach
  `**Ergebnisnotiz:** welle-NN-ergebnisse.md` ohne Link trüge, weil die `<welle-id>`-Ersetzung als
  letzte den Rest auffängt. Das ist der Zustand, den der Datei-Kopf ausdrücklich verhindern soll
  (*„Ohne diese Datei käme eine Form-Änderung der Baseline erst beim nächsten Archivierungslauf ans
  Licht — als Stub mit einem stehengebliebenen Platzhalter"*). Die im Kopf **benannte** Grenze ist
  eine andere (Richtung Vorlage → Code); diese Lücke liegt in der Richtung, die der Test zu decken
  behauptet.
- **verifizierbar:** ja — Platzhalter in einer der zwei vendored Vorlagen umbenennen, dann
  `docker run … $(BATS_IMAGE) test/archiv-stub-vorlagen.bats`; heute grün, erwartet rot.
- **klasse:** Extraktions-Regel enger als die Menge, über die der Test-Name quantifiziert

### MEDIUM-3 — Der Slice-Plan liest den Register-Zähler falsch, und die Schwellen-Aussage kippt damit

- **kategorie:** MEDIUM
- **quelle:** Baseline-Regelwerk `modul-05-planning-harness.md` §Zwei Schritte vor der
  Modus-Begründung (*„erreicht der Eintrag mit diesem Slice 3×, ist er keine Notiz mehr, sondern
  eine Lücke und braucht einen eigenen Folge-Slice"*) ·
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
- **pfad:** [`…/slice-175-archive-welle-schreibender-pfad.md`](../plan/planning/done/slice-175-archive-welle-schreibender-pfad.md)
  Zeile 160 und 168 (§6) sowie Zeile 220-222 (§8)
- **befund:** §8 und §6 führen `BEO-009` mit **8×** und `BEO-025` mit **1×**; das
  [Register](../plan/planning/observations.md) führt sie mit **9×** bzw. **2×**
  (`awk -F'|' '/BEO-0(09|25)/ {print $2, $5, $6}' docs/plan/planning/observations.md`). Beide Zahlen
  stehen ohne das Kommando, das sie liefert. Die Folge ist nicht kosmetisch: mit dem wahren Stand
  **2×** erreicht `BEO-025` durch diesen Slice die **dritte** Nennung, womit die Sichtungs-Regel
  einen eigenen Folge-Slice verlangt — der Plan schließt in Zeile 222 dagegen mit *„Keiner erreicht
  mit diesem Slice die Schwelle neu."* Dieser Report belegt die dritte Nennung mit vier Instanzen
  in einem Lauf (HIGH-1, MEDIUM-1, MEDIUM-2, LOW-1).
- **verifizierbar:** nein — kein Modul aus `modules:` der `.d-check.yml` hält eine Zahl im
  Slice-Plan gegen die Registerzeile, auf die sie sich beruft (`grep -n '^modules:' .d-check.yml`).
- **klasse:** Sichtungs-Schritt zitiert einen Zähler-Stand, den das Register nicht trägt

### MEDIUM-4 — Die `Stand`-Zelle von `BEO-026` behauptet den abgelösten Träger im Präsens, und ihr Mess-Kommando läuft ins Leere

- **kategorie:** MEDIUM
- **quelle:** Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register (`Stand` trägt
  Zustand und Beleg) · [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) ·
  [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) Folgepflicht 3 (*geänderte
  Ableitung, stehengebliebene Zusage*)
- **pfad:** [`docs/plan/planning/observations.md`](../plan/planning/observations.md) Zeile 74
  (`BEO-026`); dieselbe Klasse in Zeile 73 (`BEO-025`) und Zeile 77 (`BEO-029`)
- **befund:** Die Zelle sagt *„der Shell-Träger schreibt weiter `untrackte Datei(en)`
  (`grep -c 'untrackte Datei(en)' harness/tools/archive-welle.sh`), und seine Ablösung liegt bei
  slice-175"*. Beide Hälften hat dieser Diff falsifiziert: der Helfer ist in `f85e9a4` entfernt,
  und das zitierte Kommando endet mit `No such file or directory`, Exit 2 (in dieser Sitzung
  gefahren). Zeile 73 und 77 tragen dieselbe Form — Präsens-Aussagen über den gelöschten Pfad,
  eine davon mit Zeilennummern (`archive-welle.sh` Zeilen 644-648 / 577-588). Das Register ist ein
  **lebendes** Artefakt: die Zelle ist genau der Text, den der Sichtungs-Schritt des nächsten
  Slice-Plans liest. Die Änderung der Zelle ist nicht durch [`AGENTS.md`](../../AGENTS.md) §3.7
  erzwungen (deren Cutoff bindet die Zelle, die *geschrieben* wird) — der Diff hat sie aber
  unwahr gemacht.
- **verifizierbar:** nein — `codepaths.ignore-refs` nimmt den Pfad jetzt referenz-weit aus, damit
  läuft `make docs-check` über die Zelle grün (in dieser Sitzung: 578 Dateien, 0 Befunde).
- **klasse:** geänderte Ableitung, stehengebliebene Zusage in einem lebenden Register
  (`BEO-009`-Klasse)

### MEDIUM-5 — Der Anweisungssatz für Schritt 4 beschreibt weiter die Handarbeit, die dieser Lauf abgelöst hat

- **kategorie:** MEDIUM
- **quelle:** [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 2
  (*„ein Target, das die eine fährt, während die Doku die andere beschreibt, ist `LH-QA-01` eine
  Ebene tiefer"*) · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- **pfad:** `.claude/commands/close-welle.md:65-79` (Schritt 4)
- **befund:** Schritt 4 schickt den Planner zum **manuellen** Vorgang: *„an ihrer Stelle bleiben
  gekürzte Stubs — per `cp` aus `.harness/baseline/v5.18.0/templates/…/archiv-stub-slice.template.md`
  bzw. `…-welle.template.md`"*, und nennt als Start-Bedingung `slice-170` in `done/`. Weder
  `make archive-welle` noch das Unterkommando kommt in der Datei vor
  (`grep -c 'archive-welle' .claude/commands/close-welle.md` → **0**). Nach diesem Diff fährt
  `make archive-welle` den Träger; ein Planner, der dem Command folgt, archiviert daneben von
  Hand — ohne die Sperren, ohne das Zip, ohne die Zwei-Commit-Trennung und ohne den
  Verweis-Nachzug, also genau ohne das, was der Archivierungs-Commit bezeugen soll.
  **Die Nicht-Änderung durch die Implementation ist korrekt:**
  [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1
  weist `.claude/commands/close-welle.md` namentlich dem **Planner** zu. Der Befund ist damit eine
  Übergabe an diese Rolle, kein Einwand gegen den Diff — er steht hier, weil sonst niemand ihn
  trägt.
- **verifizierbar:** nein — kein Sensor hält einen Command-Text gegen das Target, das er beschreibt.
- **klasse:** Anweisungssatz beschreibt einen abgelösten Träger

### LOW-1 — Zwei Sätze über denselben Suchraum in derselben Datei, einer davon zu eng

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (*Zusage* / *Abgrenzung*)
- **pfad:** [`harness/README.md`](../../harness/README.md) Zeile 89 gegen Zeile 79
- **befund:** Zeile 79 (in `f85e9a4` neu geschrieben) sagt *„nimmt allein `.git` und
  `.harness/baseline/**` aus"*; Zeile 89 (in `ef18c90` angefasst) sagt im selben Abschnitt
  *„ausgenommen allein `.harness/baseline/**`"*. Der Code führt beide
  (`internal/archive/scan.go:39` → `[]string{".git", ".harness/baseline"}`, seit `slice-173`
  unverändert). Praktisch fallen die Mengen heute zusammen, weil der Eingang `git ls-files` ist und
  `.git` darin nie steht — aber `AusgenommenePfade` ist exportiert, und ein zweiter Aufrufer mit
  einem Verzeichnis-Lauf statt dem Index läse Zeile 89 als die vollständige Liste.
- **verifizierbar:** nein — kein Modul hält zwei Prosa-Sätze derselben Datei gegeneinander.
- **klasse:** zwei Fassungen derselben Aussage in einem Dokument

### LOW-2 — Der Tombstone-Kommentar macht aus einer Wachstums-Bedingung einen Auflösungs-Trigger

- **kategorie:** LOW
- **quelle:** [`MR-009`](../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile) ·
  [`AGENTS.md`](../../AGENTS.md) §3.7 (*Rang-Zeiger*)
- **pfad:** `.d-check.yml:141-142`
- **befund:** Der Kommentar sagt *„MR-009 nennt das Wachstum dieser Liste als seinen
  Aufloesungs-Trigger."* `MR-009` §Auflösungs-Trigger beginnt mit **`permanent`** und führt die
  Wachstums-Klausel als **Bedingung** daneben (*„`ignore-refs` wächst nur mit weiteren bewusst
  entfernten Artefakten"*). Wer den Kommentar als Rang-Zeiger liest, kann schließen, das soeben
  erfolgte Wachstum habe den Trigger ausgelöst — und einen als permanent deklarierten
  Adaptions-Eintrag zur Auflösung stellen. Der Eintrag selbst (`harness/tools/archive-welle.sh`)
  ist nach `MR-009` korrekt: bewusst entfernt, voller Pfad, kein Glob, mit Begründung daneben.
- **verifizierbar:** nein — `make docs-check` prüft den Link, nicht die Wiedergabe der Quelle.
- **klasse:** Rang-Zeiger gibt die zitierte Quelle enger/anders wieder als ihr Wortlaut

### INFO-1 — Die Zwei-Commit-Trennung hat einen scharfen Test, aber keinen Mutations-Fall

- **kategorie:** INFO
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.3, §3.6 (*„wer keinen Fall in `test/mutations/` hat,
  ist unbewacht"*)
- **pfad:** `internal/archive/anwenden.go:76-80` · `internal/archive/anwenden_test.go:177-212`
- **befund:** `TestAnwendenTrenntMoveVonInhalt` misst die Trennung wirklich — der `gitMitschreiber`
  hält je Commit einen Schnappschuss des beobachteten Dateiinhalts *und* der Zip-Existenz fest, und
  die erwartete Ruf-Folge `mv,mv,mv,commit,rm,add,commit` ist als Literal geprüft. Ein
  `test/mutations/`-Fall darüber existiert nicht; `make mutate` prüft damit die **Haltbarkeit**
  dieses Zahns nicht. Das ist kein Verstoß — die Regel benennt genau diesen Zustand —, es ist die
  Grenze, in der die stärkste Zusage dieses Slice heute steht.
- **verifizierbar:** ja (indirekt) — `sed -n 's/^# expect: //p' test/mutations/*.sh | sort | uniq -c`
  führt den Test nicht.
- **klasse:** —

### INFO-2 — `archive-welle` hängt seit diesem Diff an einer `.gitignore`-Zeile, die niemand nennt

- **kategorie:** INFO
- **quelle:** Maintainability
- **pfad:** `Makefile:312-315` (`archive-welle: host-bin`) · `internal/archive/clean.go:28-49`
- **befund:** Das Target bekam eine Prerequisite auf `host-bin`, und im selben Slice zählt
  `UnsauberGrund` untrackte Einträge als „nicht sauber". Beides zusammen trägt nur, weil der
  Ablageort des Trägers ignoriert ist — gemessen:
  `git check-ignore -v .harness/state/bin/ai-harness-init` → `.gitignore:5:.harness/state/`.
  Verengte jemand diese Zeile, bräche jeder `make archive-welle`-Lauf mit *„1 untrackte(r)
  Eintrag"* ab, ohne dass ein Gate den Zusammenhang zeigt. Der Makefile-Kommentar begründet die
  Prerequisite (Bau vor Benutzung), nennt die Kopplung an `.gitignore` aber nicht.
- **verifizierbar:** nein — kein Sensor hält eine Prerequisite gegen die Ignore-Regel, die sie
  voraussetzt.
- **klasse:** —

---

## Negativbefunde — geprüft, ohne Befund

- **Zwei-Commit-Trennung, echt statt behauptet** ([`AGENTS.md`](../../AGENTS.md) §3.3). `Anwenden`
  fährt alle `git mv` und **dann** `Commit`; `Commit` ruft `git commit -q -m` ohne `-a` und ohne
  Pfade, committet also den Index — und der trägt nach der Sauberkeits-Sperre ausschließlich die
  Renames. Der Inhalts-Schritt liegt vollständig hinter dem ersten `Commit`. Die
  `os.MkdirAll`-Anlage des Zielverzeichnisses vor dem ersten `mv` erzeugt ein leeres Verzeichnis,
  das git weder trackt noch in `--porcelain` meldet. Kein Befund.
- **Stub aus der Vorlage, nicht aus im Code formatiertem Text**
  ([ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 3).
  `AusVorlage` liest die Datei (`os.ReadFile`) und ersetzt Platzhalter; es gibt keine im Code
  formatierte zweite Fassung der Form (`grep -n 'ARCHIVIERT' internal/archive/*.go` trifft nur die
  Prüfungen in `FormOK`/`Kuerze` und die Prüftext-Vorlagen in `stub_test.go`). Fehlt die Vorlage,
  fällt der Lauf aus statt zu raten (`TestAusVorlageFaelltOhneVorlageAus`,
  `TestAnwendenOhneVorlageNenntDenRueckweg`). Der Prüftext-Marker `PRUEFBAUM-MARKER` steht in keiner
  echten Vorlage und in keinem Produktivcode — der Stub kann seine Form nur aus der gelesenen Datei
  haben. Der Verzicht auf ein wörtliches `cp` ist korrekt und in
  [`harness/README.md`](../../harness/README.md) nachgezogen (die frühere Formulierung *„per `cp`"*
  ist dort entfernt). Kein Befund.
- **Abnahme-Kriterium 1 (Hänger-Wächter schließt `docs/reviews/**` nicht aus)** — aus `slice-173`
  korrekt wiederverwendet: `AusgenommenePfade()` führt zwei Präfixe, `docs/reviews` ist keines;
  `sperren()` erzeugt die `haenger`-Sperre, und `archiveWelleLauf` gibt bei jeder Sperre **vor**
  `Anwenden` zurück — gehalten von `TestArchiveWelleSchreibendBrichtAnEinerSperreAb`, das für
  `vorschau=false` prüft, dass **keine** git-Operation lief. Mutations-Fall 233 vorhanden,
  `sed`-Muster trifft. Kein Befund.
- **Abnahme-Kriterium 2, lesende Hälfte (untrackte Dateien)** — `UnsauberGrund` zählt `?? `-Zeilen
  mit, trennt die zwei Klassen in der Meldung und spricht bewusst von *Eintrag*, weil eine
  porcelain-Zeile ein Verzeichnis sein kann. Mutations-Fall 232 (`expect:`
  `TestUnsauberGrundZaehltUntrackte`) vorhanden. Kein Befund.
- **Abnahme-Kriterium 2, schreibende Hälfte (explizites Staging)** — `ZuStagen` baut eine
  aufgezählte Menge; `TestZuStagenNenntNurArchivStubsUndNachgezogene` prüft die **vollständige**
  Ist-Liste gegen eine erwartete und legt eine untrackte `fremd.txt` daneben, die im
  `ls-files`-Attrappen-Eingang fehlt. Mutations-Fall 241 ersetzt die Liste durch `[]string{"."}`;
  `sed`-Muster trifft (verifiziert). Kein Befund.
- **Abnahme-Kriterium 3 (aufsteigender Verweis beim Folgelauf)** — `TestZweiterLaufZiehtDen`…
  fährt wirklich **zwei** Läufe (`welle-09`, dann `welle-10`), prüft erst, dass Lauf 1 die Form
  `](../slice-100-a.md)` selbst schreibt, und dann, dass Lauf 2 sie auf
  `](../welle-10/slice-100-a.md)` zieht **und** die berührte Datei stagt. Mutations-Fall 240 nimmt
  das Welle-Segment weg; `sed`-Muster trifft (verifiziert). Kein Befund.
- **Folgepflicht 2 — kein Mutations-Fall verschwindet still.** Alle sieben Fälle über dem Skript
  sind einzeln zugeordnet: 225→235, 226→236, 227→239, 228→234, 229→233, 230→232, 231→240; dazu
  237 (Routing) und 238 (Dateityp-Achse) aus `slice-173` und 241 neu. Bestand jetzt zehn
  (`grep -l 'archive' test/mutations/*.sh | wc -l`), jeder `# expect:`-Name existiert als
  Go-Testfunktion (einzeln aufgelöst). **Grenze:** die Zuordnung steht heute nur in der
  Commit-Message; §7 des Plans ist noch Vorlage — das ist Closure-Arbeit, kein Diff-Befund.
- **Folgepflicht 4 — der vierte Pin verlässt das Makefile mit seinem Aufrufer.**
  `grep -cE '^[A-Z_]+_IMAGE \?=' Makefile` → **3**; `git grep -n ARCHIVE_IMAGE` außerhalb der
  Zeitdokumente liefert nichts. Kein Befund.
- **Ablösung sauber, kein toter Code.** `harness/tools/archive-welle.sh` und
  `test/archive-welle.bats` sind entfernt; die einzigen lebenden Nennungen sind der Tombstone in
  `.d-check.yml` und der Plan selbst (MEDIUM-4 betrifft den Wahrheitsgehalt der Register-Zellen,
  nicht toten Code). `make archive-welle` fährt `$(HOST_BIN) archive-welle`. Kein Befund.
- **Tombstone nach `MR-009`-Muster.** Ein konkreter voller Pfad, kein Glob, mit benanntem Was und
  Warum daneben, für ein **bewusst entferntes** (nicht geplantes) Artefakt — genau die Abgrenzung,
  die `MR-009` §Kein Rückfall auf stilles Grün verlangt. `make docs-check` in dieser Sitzung: 578
  Dateien, 0 Befunde. Kein Befund (die Kommentar-Formulierung ist LOW-2).
- **Lint-Suppression-Verbot** ([`AGENTS.md`](../../AGENTS.md) §3.2). Der Diff führt kein `//nolint`,
  kein `# shellcheck disable` und kein `d-check:ignore` ein
  (`git diff 1e18b7e^..ef18c90 | grep -nE '^\+.*(nolint|shellcheck disable|d-check:ignore)'` leer).
  Kein Befund.
- **Docker-only** ([`AGENTS.md`](../../AGENTS.md) §3.9). Kein neuer Host-Aufruf; `git` bleibt in
  genau einer Datei (`cmd/ai-harness-init/archive_welle.go`), jetzt mit vier schreibenden Aufrufen
  hinter einer Schnittstelle und Kontext-Timeout. Das neue Target fährt den im Docker-Bild
  gebauten Träger. Kein Befund.
- **Kommentar-Behauptungen** ([`AGENTS.md`](../../AGENTS.md) §3.6/§3.7). `make comment-claims` in
  dieser Sitzung: 55 Dateien, 0 Befunde; zusätzlich jeder in `internal/archive/**` und
  `cmd/…/archive_welle.go` genannte `Test…`-Name einzeln gegen die Testdateien aufgelöst — keiner
  fehlt. Der dritte Commit `ef18c90` räumt neun Kommentare, die einen Vergleich mit dem
  abgelösten Helfer behaupteten; die Ersatzsätze sind Indikativ über den Zustand. Kein Befund.
- **`BEO-025`-Risiko aus §6 (die `titel_von`-Grenze)** ist im Port geschlossen statt geerbt:
  `TitelVon` benennt die Grenze im Kopf, und `TestTitelVonLaesstDenNummernRestStehen` prüft sie mit
  dem Fall `# Slice 190: T` → `190: T` — die Zusage reicht nicht weiter als der Code. Kein Befund.
- **`LH-QA-02`-Zusage des Zip.** `Zip` setzt keinen Zeitstempel; `zip.Writer.Create` ebenso wenig.
  `TestZipIstUeberZweiLaeufeByteGleich` vergleicht zwei Läufe byte-weise. Beide `Close`-Fehler
  werden ausgewertet, ein abgeschnittenes Archiv geht nicht als Erfolg durch. Kein Befund — das
  Risiko 1 aus §6 des Plans ist damit gemessen statt übernommen.
- **Rückweg nach einem Fehler zwischen den Commits.** `NachCommit1Fehler` nennt
  `git reset --hard HEAD~1 && git clean -fd -- <ziel>`; das trifft beide Klassen (die Stubs und die
  Nachzug-Änderungen sind zu dem Zeitpunkt getrackte Modifikationen, das Zip ist untrackt im
  Zielverzeichnis). Kein Befund.
- **Suchraum-Kopplung zwischen zählendem und schreibendem Zweig.** `fundIn` und `ersetzeIn` fragen
  dieselbe Funktion `rollen`; `TestNachziehenSchreibtGenauDortWoVerweisFundZaehlt` hält die zwei
  Ergebnislisten gegeneinander. Das war die HIGH-Klasse aus `slice-173` Runde 1 und ist hier nicht
  wieder aufgetreten. Kein Befund.

**Nicht geprüft, weil nicht Reviewer-Rolle:** die DoD-Abhakung, der Stand von `make gates`,
`make mutate` und `make full-smoke`, und die Frage, ob `ADR-0033` ihren Acceptance-Trigger erreicht
hat (dafür verlangt sie eine **Konsistenz**-Runde gegen ADR-0022/0003/0007 — ein anderer
Prüfgegenstand als dieser Diff).

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| **HIGH** | 1 | Test misst die Vorbedingung statt die im Namen behauptete Eigenschaft |
| **MEDIUM** | 5 | Zahn prüft die Funktion, nicht ihre Verdrahtung · Extraktions-Regel enger als die Quantifizierung im Test-Namen · Sichtungs-Schritt zitiert einen Zähler-Stand, den das Register nicht trägt · geänderte Ableitung, stehengebliebene Zusage im lebenden Register · Anweisungssatz beschreibt einen abgelösten Träger |
| **LOW** | 2 | zwei Fassungen derselben Aussage in einem Dokument · Rang-Zeiger gibt die zitierte Quelle anders wieder als ihr Wortlaut |
| **INFO** | 2 | — |

**Wiederkehrende Klasse für die Closure §7 — und sie hat die Schwelle erreicht.** HIGH-1, MEDIUM-1,
MEDIUM-2 und LOW-1 sind vier Instanzen von `BEO-025` (*eine Zusage nennt einen Geltungsbereich, den
der Code darunter nicht hält; in ihrer schärfsten Form nennt sie einen Sensor, der die Form nicht
sieht*). Das Register führt die Zeile bei **2×** mit den Belegen `slice-170` und `slice-173`; mit
diesem Slice ist es die **dritte** Nennung. Nach `modul-05-planning-harness.md` §Zwei Schritte und
`modul-06-roadmap.md` §Das Beobachtungs-Register ist der Eintrag damit keine Notiz mehr, sondern
eine Lücke: er gehört beim Lese-Schritt verkörpert (Regel · Sensor · benannte Spec-Lücke) oder in
einen eigenen Folge-Slice. **Ob** der Zähler-Schritt fällt, entscheidet die Closure und nicht dieser
Report — dass der Plan ihn in §8 auf Basis eines falschen Standes ausgeschlossen hat, ist MEDIUM-3.

Zweitklasse: MEDIUM-4 ist `BEO-009` (*geänderte Ableitung, stehengebliebene Zusage*), im Plan §6
als Risiko 2 vorab benannt und dort auf den Skriptkopf und `harness/README.md` eingegrenzt. In
beiden benannten Orten ist es behoben; getroffen hat es das Register, das die Eingrenzung nicht
nannte.

---

## Verdikt

**Blockierend.** Ein HIGH und fünf MEDIUM stehen; nach `.harness/skills/reviewer.md` §Ablage
blockieren beide Kategorien typischerweise. Für zwei der sechs wird die Abweichung hier begründet:

- **HIGH-1 blockiert ohne Abweichung.** Die Eigenschaft, die den lesenden vom schreibenden Zweig
  trennt, ist die einzige Sicherung davor, dass ein Blick auf eine Welle sie archiviert. Sie hängt
  an drei Zeilen, deren Entfernen gemessen grün bleibt, und der Test, der sie im Namen führt,
  erreicht sie nicht. Das ist der Fall, den [`AGENTS.md`](../../AGENTS.md) §3.6 als *„kann unter
  keiner Mutation rot werden"* beschreibt — eine Ebene unter dem halluzinierten Gate aus
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6).
- **MEDIUM-5 blockiert den Diff nicht.** Das Artefakt gehört nach
  [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1 dem
  **Planner**; die Implementation hat es korrekt nicht angefasst. Der Befund ist ein
  Übergabe-Artefakt an diese Rolle und blockiert stattdessen die Einlösung von
  [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 2 — *ein* Träger,
  *eine* Beschreibung.
- **MEDIUM-3 und MEDIUM-4 blockieren die Closure, nicht den Code.** Beide liegen in
  Planungs-Artefakten (Slice-Plan §6/§8, Beobachtungs-Register) und sind vor dem `git mv` nach
  `done/` fällig, nicht vor dem Merge des Codes.

**Was trägt.** Die tragenden Zusagen dieses Slice sind eingelöst und einzeln belegt: die
Zwei-Commit-Trennung ist real und scharf getestet, der Stub kommt nachweislich aus der Datei, alle
drei Abnahme-Kriterien aus [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md)
haben ihren Zahn mit passendem `sed`-Muster, alle sieben Mutations-Fälle des Shell-Wegs sind
einzeln zugeordnet, der vierte Bild-Pin ist mit seinem Aufrufer weg, und der Tombstone folgt
`MR-009`. Die Befunde liegen sämtlich an der Naht zwischen einer **Zusage** und dem **Sensor**, der
sie halten soll — nicht an der Operation selbst.

**Kein Rollen-Konflikt erkennbar.** Sollte die Implementation HIGH-1 mit Verweis auf eine
Plan-Aussage bestreiten, greift der Konflikt-Pfad aus Modul 8 §Konflikt-Pfad als Rollen-Sequenz
(Reviewer → Architect → Verdikt als Artefakt); ein Herabstufen, weil die Implementation
widerspricht, ist dort ausdrücklich der vierte, falsche Pfad.
