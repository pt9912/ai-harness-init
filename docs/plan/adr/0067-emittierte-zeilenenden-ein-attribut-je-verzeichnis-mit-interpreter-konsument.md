# ADR-0067: Die Zeilenenden der emittierten Dateien — ein Git-Attribut je Verzeichnis mit Interpreter-Konsument, die Klasse folgt dem Boden

**Status:** Proposed

**Datum:** 2026-09-25

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0007](0007-bootstrap-phasen.md) (**Accepted** — ihre Festlegung 3 führt die Idempotenz-Klassifikation je Datei; die Tabelle dort nennt keinen Pfad `.gitattributes`: für zwei Verzeichnisse trägt ihre Zeile die Klasse, für drei entscheidet ihre Zweifelsregel. **Kein `Supersedes`**, Begründung in §Konsequenzen),
[ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) (**Accepted** — dieselbe Frage für einen Pfad in einem Verzeichnis, das dem Adopter gehört; ihre Festlegung 2 gibt die Methode: die Klasse folgt dem Boden, nicht der Fassung; ihre Festlegung 4 lässt die `.claude/`-Zeilen ungewogen),
[`MR-055`](../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft) (eine Stellen-Messung trägt keine Folgerung über eine Eigenschaft — der Grund, warum Festlegung 3 `.claude/hooks/` nicht aus der Tabelle liest),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) (jede Zahl unten steht neben dem Kommando, das sie liefert),
[`MR-005`](../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption) (das emittierte Layout `tools/harness/` gegenüber dem des Dogfood),
[`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (die Boundary-Ak setzt die zwei Klassen in Kraft),
[`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (die Skripte der Durchsetzungsschicht sind die Konsumenten, deren Bytes hier gehalten werden),
[`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (Scope Windows; seine Grenze der Messmethode bleibt unverändert — Festlegung 5),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)

**Schärft:** [`ARC-003`](../../../spec/architecture.md#2-schichten-und-constraints) — die Idempotenz-Klassifikation je Datei, hier verbindlich gemacht für die emittierten `.gitattributes`-Dateien. Keine Spec-Aussage ändert sich; ihr Prüfbereich wächst um fünf Pfade.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR).

---

## Kontext

### Was bricht, und an welchen Dateien

Ein Klon eines gebootstrappten Ziels, den Git mit `core.autocrlf=true` auscheckt (die Voreinstellung von Git for Windows), bekommt jede Textdatei mit CRLF. Die Emission legt LF ab; die CR entstehen im Klon. Gemessen an einem frisch bootstrappten Ziel (`ai-harness-init --lang go`), einmal committet und zweimal geklont — die Kontrolle mit `-c core.autocrlf=false` **ausdrücklich gesetzt**, nicht vom Host geerbt:

```sh
git clone -q --no-hardlinks -c core.autocrlf=true  <ziel> kc
git clone -q --no-hardlinks -c core.autocrlf=false <ziel> kf
for p in .harness .claude/hooks .githooks harness/mk tools/harness; do
  echo "$p $(grep -rlI $'\r' --exclude-dir=.git kc/$p | wc -l) $(grep -rlI $'\r' --exclude-dir=.git kf/$p | wc -l)"; done
# .harness 58 0 · .claude/hooks 3 0 · .githooks 1 0 · harness/mk 11 0 · tools/harness 11 0   (autocrlf=true | false)
```

**Keine Erwartungswerte** ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2) — die Zahlen wandern mit dem Bestand; tragend ist, dass die Kontrolle in jedem der fünf Verzeichnisse null trägt und der autocrlf-Klon in jedem mindestens eine Datei.

Drei Konsumenten brechen dort **an den Bytes**, und zwei davon an einer Datei **ohne Endung**:

- **Ein Bash-Skript über seine Shebang-Zeile.** `.githooks/commit-msg` im autocrlf-Klon, `./.githooks/commit-msg /dev/null` → `/usr/bin/env: »bash\r“: Datei oder Verzeichnis nicht gefunden`, Exit 127. `bash tools/harness/baseline-verify.sh` (ohne Shebang aufgerufen) → `set: pipefail: Ungültiger Optionsname`.
- **Die Byte-Prüfung des vendored Baums.** Im autocrlf-Klon fällt jede der Dateien, die `SHA256SUMS` zählt, durch die Prüfsumme (`tr -d '\r' < SHA256SUMS | sha256sum -c`, dort `grep -vc ': OK$'` → 54, `grep -c ': OK$'` → 0); die Zeilenenden der Summen-Datei selbst sind dabei bereinigt, es misst also allein die CR in den 54 Dateien.
- **Eine Wortliste, die ein Skript einliest.** Der emittierte Command-Guard liest `tools/harness/blocked/<sprache>` per `cat` und zerlegt an Leerraum; ein CR bleibt am letzten Wort haften. Zwei Zustände, an echten Klonen gemessen:
  - **Der gewöhnliche autocrlf-Klon — der Guard trägt ebenfalls CRLF und fällt laut.** Der Aufruf aus `.claude/settings.json` (`bash .claude/hooks/pretooluse-command-guard.sh`, Eingabe `{"tool_name":"Bash","tool_input":{"command":"go build ./..."}}`) endet mit `set: pipefail: Ungültiger Optionsname` und Exit 2, mit `ls` als Befehl ebenso: **jeder** Aufruf, kein durchgelassener. Ob Claude Code diesen Exit 2 eines Hooks als blockierend liest, ist **nicht gemessen** (Hook-Konvention, kein Lauf dieses Repos).
  - **Der Mischzustand — Guard LF, `blocked/go` CRLF — ist der stille.** Ihn erzeugt eine Adopter-Wurzel mit einem Endungs-Glob (`printf '*.sh text eol=lf\n' > .gitattributes`, committet, Klon mit `-c core.autocrlf=true`; `grep -c $'\r'` → Guard 0, `blocked/go` ≥ 1): `staticcheck ./...` wird **durchgelassen** (`printf '{"tool_name":"Bash","tool_input":{"command":"staticcheck ./..."}}' | bash .claude/hooks/pretooluse-command-guard.sh | grep -c '"block"'` → 0), mit LF-Kontrolle → 1; `gofmt` blockt weiter. Ein Guard, der nicht mehr an seinem letzten Listenwort blockt, ist fail-open **ohne Fehlermeldung** — das Fehlerbild, gegen das der Guard gebaut ist.

Der Mischzustand ist der Grund, warum die Erfassung unten nach **Verzeichnis** schneidet und nicht nach Endung: `blocked/go` und `commit-msg` tragen keine, und ein Endungs-Glob — eines Adopters in der Wurzel oder des Werkzeugs selbst (Alternative E) — erzeugt ihn.

### Was der Mechanismus kann, gemessen

Git legt die Zeilenenden je Pfad über Attribute fest, und eine `.gitattributes` in einem Unterverzeichnis **überstimmt** die der Wurzel für ihr Verzeichnis. Gemessen an demselben Ziel, mit einer Adopter-Wurzel `* text eol=crlf` und je einer Zeile `* text=auto eol=lf` in den fünf Verzeichnissen:

```sh
git check-attr eol text -- .githooks/commit-msg tools/harness/blocked/go .harness/baseline/<tag>/SHA256SUMS harness/mk/go.mk Makefile
# .githooks/commit-msg: eol: lf · tools/harness/blocked/go: eol: lf · …/SHA256SUMS: eol: lf · harness/mk/go.mk: eol: lf · Makefile: eol: crlf
```

Im autocrlf-Klon trägt jedes der fünf Verzeichnisse danach null CR-Dateien, `bash tools/harness/baseline-verify.sh` endet mit `OK`, `.githooks/commit-msg` läuft über seine Shebang-Zeile, und das Ausführungsbit bleibt (`ls -l .githooks/commit-msg` → `-rwxrwxr-x`). Das **Makefile der Wurzel** bleibt mit CRLF: eine genestete Datei erreicht die Wurzel nicht.

### Die Tabelle der Klassen nennt den Pfad nicht

`.gitattributes` liegt an einem Namen, den `git` fixiert. Die konvergente Zeile der Tabelle in [ADR-0007](0007-bootstrap-phasen.md) Festlegung 3 nennt für vier der fünf Verzeichnisse Globs von Dateinamen — `harness/mk/*.mk`, `.claude/hooks/*.sh`, `tools/harness/*`, `.harness/skills/*` und `.harness/baseline/<tag>/` —, keinen Namen `.gitattributes`. Zwei Nachbar-Aussagen über die Verzeichnisse selbst stehen dort und in der Code-Aufzählung:

```sh
grep -c 'local.mk' docs/plan/adr/0007-bootstrap-phasen.md   # 2  (Adopter-local.mk in harness/mk/ unberührt)
grep -c '\.gitattributes' docs/plan/adr/0007-bootstrap-phasen.md   # 0
```

**Keine Erwartungswerte**; tragend ist die zweite Zahl. Was die Tabelle über die **Dateien** sagt, trägt nicht ohne Weiteres die **Verzeichnis-Klasse** einer Datei mit einem von `git` gewählten Namen, und für `.claude/` lässt [ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) Festlegung 4 die Zeilen ausdrücklich ungewogen ([`MR-055`](../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)). Die Frage ist damit ein **Urteil** ([`AGENTS.md`](../../../AGENTS.md) §3.6), dieselbe wie bei dem Commit-Träger: Kann an diesem Pfad ein legitimer Adopter-Zustand bestehen, in dem die Datei nicht die des Werkzeugs ist? Die Zweifelsregel der Tabelle ist eindeutig — *„im Zweifel gilt `skip-if-present`"*. Wo die Tabelle das Verzeichnis selbst als tool-eigene Infrastruktur führt, ist die Frage von ihr **beantwortet**; wo sie eine Adopter-Fläche nennt oder ungewogen bleibt, greift die Zweifelsregel. Festlegung 3 führt das je Pfad.

## Entscheidung

**Wir legen in jedem Verzeichnis, in dem das Werkzeug Dateien mit Interpreter- oder Byte-Konsument ablegt, eine `.gitattributes` mit der einen Zeile `* text=auto eol=lf` ab — und die Klasse der Datei folgt dem Boden: konvergent, wo das Werkzeug das Verzeichnis bestimmt; skip-if-present mit Meldung, wo der Adopter oder ein fremdes Werkzeug den Namensraum mitträgt.** Fünf Festlegungen.

**1. Die Menge folgt einem Kriterium, nicht einer Aufzählung.** Ein Verzeichnis unterhalb der Wurzel des Ziels gehört zur Menge, wenn das Werkzeug dort eine Datei ablegt, an deren Bytes ein Konsument **bricht** — ein Bash-Skript, ein awk-Programm, eine Wortliste, die ein Skript einliest, die Byte-Prüfung `SHA256SUMS` (jeweils gemessen, §Kontext) —, **oder** ein make-Fragment, dessen Rezepte Shell-Zeilen tragen. Das make-Fragment steht als **Vorsorge** in der Menge, nicht als gemessener Bruch: GNU Make 4.3 verträgt CR (Probe: `printf 'all:\r\n\t@echo hi\r\n' > crlf.mk; make -f crlf.mk | od -c` → `h i \n`; und an einem Ziel mit `sed -i 's/$/\r/' Makefile d-check.mk harness/mk/*.mk` läuft `make baseline-verify` → `OK`); ob ein anderes make CR verträgt, ist ungemessen. Heute sind das fünf Verzeichnisse:

| Verzeichnis | Konsument der Dateien dort |
|---|---|
| `tools/harness/` (samt `blocked/`) | bash-Skripte, ein awk-Programm, die Wortlisten des Guards |
| `harness/mk/` | make-Fragmente, deren Rezepte Shell-Zeilen tragen (Vorsorge, s. o.) | <!-- d-check:ignore (der Pfad entsteht erst im gebootstrappten Ziel) -->
| `.claude/hooks/` | die Hook-Skripte, die Claude Code über bash startet |
| `.githooks/` | der git-eigene Träger, den git über seine Shebang-Zeile startet |
| `.harness/` | die Byte-Prüfung des vendored Baums; der Ort des Vorbilds `.harness/.gitignore` |

**Nicht** in der Menge: `.claude/` selbst (`settings.json`, `agents/`, `commands/` — JSON und Markdown, deren Konsument kein Interpreter ist) und **die Wurzel des Ziels, obwohl sie make-Dateien trägt** (`Makefile`, `d-check.mk`, mit `--arch` `a-check.mk`). Die Wurzel ist eine **ausdrückliche Ausnahme vom Kriterium**, keine Folge davon: dort trägt keine der zwei Klassen (Festlegung 5, Alternative D), und ein Bruch ist nicht gemessen (GNU Make 4.3, s. o.). Was daraus als CR-tragender Rest im Klon bleibt, ist **nicht gemessen und nicht zugesagt**; eine Datei, die später in ein Verzeichnis unterhalb der Wurzel mit Interpreter-Konsument einzieht, fällt unter das Kriterium, nicht unter eine neue Entscheidung.

**2. Die Zeile ist `* text=auto eol=lf`, und sie gilt dem ganzen Verzeichnis.** Erfasst wird mit `*`, nicht mit Endungs-Globs: `blocked/<sprache>` und `commit-msg` tragen keine Endung, und der Mischzustand im Kontext zeigt an der ersten den stillen Ausfall; die genestete Zeile gewinnt gegen einen Endungs-Glob in der Adopter-Wurzel. `text=auto` lässt eine Datei, die Git als binär erkennt, unberührt — in den Verzeichnissen des frisch bootstrappten Ziels liegt kein getrackter Binärbestand (`git ls-files --eol | grep -c 'i/-text'` → 0), und der Träger unter `.harness/state/` ist gitignoriert; die Heuristik fängt den Fall, dass einer dazukommt. `eol=lf` legt das Auschecken jeder erkannten Textdatei fest, unabhängig von `core.autocrlf` **und** von einer Adopter-Wurzel (Kontext, zweite Messung).

**3. Die Klasse folgt dem Boden — und die Herkunft ist je Zeile benannt.** *Abgeleitet aus der Tabelle* heißt: ihre Zeile führt das Verzeichnis selbst als „reine tool-erzeugte Infrastruktur" (das Prinzip dort: konvergent ist die Ausnahme für tool-eigene Infrastruktur, die der Adopter nicht editieren soll). *Zweifelsregel* heißt: die Tabelle nennt eine Adopter-Fläche oder lässt die Zeile ungewogen, und im Zweifel gilt skip-if-present.

| Ziel-Datei | Klasse | Herkunft der Klasse |
|---|---|---|
| `.harness/.gitattributes` | **konvergent** | **abgeleitet aus der Tabelle** — die Unterbäume `.harness/baseline/<tag>/` und `.harness/skills/*` stehen dort als konvergente tool-Infrastruktur, und der Nachbar `.harness/.gitignore` (ebenfalls ein von `git` fixierter Name, im selben Verzeichnis) ist konvergent (Code-Aufzählung); eine Adopter-Fläche nennt die Tabelle in diesem Verzeichnis nicht |
| `tools/harness/.gitattributes` | **konvergent** | **abgeleitet aus der Tabelle** — `tools/harness/*` samt `blocked/` steht dort als konvergent, „reine tool-erzeugte Infrastruktur", und das Werkzeug bestimmt, was dort liegt ([`MR-005`](../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)). Ein Adopter, der dort eine eigene `.gitattributes` führt, verliert sie beim nächsten Lauf — ein Zustand, den die Tabelle nicht vorsieht und den **kein Lauf gemessen hat** (Trigger 2) |
| `harness/mk/.gitattributes` | **skip-if-present** | **Zweifelsregel** — die Tabelle nennt hier eine Adopter-Fläche (`local.mk` und die eigenen Fragment-`.mk`, die der `include`-Glob mitnimmt). `local.mk` ist dabei ein Name der Tabelle, kein Pfad, den ein Emitter kennt (`grep -rl 'local\.mk' internal cmd \| wc -l` → 0); im Code führt den Adopter-Ort `harness/mk/vorgaben.mk` (`SelbstpruefungVorgabeOrt` in `internal/emit/selbstpruefung.go`, „das kein Lauf dieses Werkzeugs schreibt"). Ein Adopter, der dort eine eigene `.gitattributes` führt, ist ein legitimer Zustand | <!-- d-check:ignore (der Pfad entsteht erst im gebootstrappten Ziel) -->
| `.claude/hooks/.gitattributes` | **skip-if-present** | **Zweifelsregel** — ein von Claude Code fixierter Pfad, an dem ein Adopter eigene Hooks führen kann; die Tabellenzeile `.claude/hooks/*.sh` wird **nicht** auf diese Datei gelesen ([ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) Festlegung 4, [`MR-055`](../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)) |
| `.githooks/.gitattributes` | **skip-if-present** | **Zweifelsregel** — das Verzeichnis ist das des Repos, der Gast-Boden aus [ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) Festlegung 2 |

**4. Skip-if-present heißt hier dasselbe wie in ADR-0054 Festlegung 3.** Der Pfad ist frei → die Datei wird geschrieben. Der Pfad ist belegt → die liegende Datei bleibt **unberührt** und der Lauf **sagt es**; die Meldung nennt, was dann gilt: steht die Zeile dort nicht, tragen die Dateien dieses Verzeichnisses im Klon mit `core.autocrlf=true` CRLF. Die Meldung fällt auch bei einem zweiten Lauf über der **eigenen** Datei des ersten Laufs (der Lauf unterscheidet nicht, wessen Datei liegt) — benannt, nicht verhindert; eine Byte-Gleichheits-Ausnahme wäre ein neuer Pfad im Writer für drei Zeilen Ausgabe, und die Festlegung 3 aus [ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) bleibt so unverändert.

**5. Die Wurzel des Ziels bekommt keinen Eintrag, und die Aussage reicht so weit wie ihre Messung.** Die Wurzel gehört dem Adopter; eine skip-if-present-Datei dort schützte ein Ziel mit eigener Wurzel-`.gitattributes` **gar nicht**, während die genesteten Dateien gegen eine Adopter-Wurzel gewinnen (Kontext, zweite Messung). Die Entscheidung sagt damit: *die Skripte, Fragmente und Prüfsummen, die das Werkzeug in diesen fünf Verzeichnissen ablegt, kommen in einem Klon mit `core.autocrlf=true` mit LF an — in den zwei konvergenten Verzeichnissen immer, in den drei skip-if-present-Verzeichnissen, solange der Pfad frei war.* Bei belegtem Pfad gilt, was die liegende Datei sagt (Sonde: eine belegte `.githooks/.gitattributes` ohne `eol=lf`, Klon mit `-c core.autocrlf=true` → `grep -c $'\r' .githooks/commit-msg` ≥ 1). Die Aussage sagt **nichts** über einen Windows-Lauf: gemessen wird, was der Smudge-Filter von Git unter Linux mit den Bytes tut. Die Grenze der Messmethode in [`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (die gehosteten Windows-Runner tragen keine Linux-Container) gilt unverändert, und **keine Aussage der Spec ändert sich** — die Spec trägt keine Zeile über die Zeilenenden ausgelieferter Dateien (`grep -rniE 'crlf|autocrlf|gitattributes' spec/ | wc -l` → 0; das Wort `Zeilenende` steht in der Spec einmal, in `SPEC-031`, und meint das Ende einer Kommandozeile), und diese Entscheidung fügt ihr keine hinzu.

## Verglichene Alternativen

Regeln dieser Sektion: **mindestens drei Optionen mit Pro/Contra** — „nichts tun" ist eine davon (Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR)).

| Option | Pro | Contra |
|---|---|---|
| A — **alle fünf konvergent** | eine Regel für alle; die Zusage steht ohne Vorbedingung; ein von Hand geänderte Datei heilt beim nächsten Lauf | der Lauf schreibt unbedingt und ersetzt in drei Verzeichnissen mit Adopter-Fläche eine Datei, deren Inhalt der Adopter geführt haben kann (eine abweichende Zeile für eine Datei seines Verzeichnisses); die Zweifelsregel ist überspielt, und [ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) Festlegung 4 verbietet, die `.claude/`-Zeile der Tabelle dafür zu lesen |
| **B — Boden-gemischt (gewählt)** | folgt der Methode der ADR-0054 Festlegung 2; die zwei Verzeichnisse, die das Werkzeug allein bestimmt, heilen (dort hängt die Byte-Prüfung des vendored Baums und der Guard dran); in den drei übrigen bleibt Adopter-Inhalt stehen und der Lauf sagt es | zwei Klassen für fünf gleiche Zeilen; in drei Verzeichnissen kommt eine Änderung der Zeile bei einem Ziel mit belegtem Pfad nicht an, und die Meldung erscheint auch über der eigenen Datei (Festlegung 4) |
| C — **alle fünf skip-if-present** | eine Regel; kein Adopter-Inhalt wird berührt; die Zweifelsregel wörtlich angewandt | in `.harness/` und `tools/harness/` — wo die Tabelle das Verzeichnis als reine tool-erzeugte Infrastruktur führt — heilte ein Lauf eine gelöschte oder geänderte Datei nicht mehr, und dort hängen `baseline-verify` und der Guard an den Bytes; die Klasse folgte der Regel statt dem Boden |
| D — **eine Datei in der Wurzel des Ziels** (skip-if-present, oder ein Marker-Block in der Wurzel des Adopters) | ein Ort; deckt auch `Makefile`, `d-check.mk`, `Dockerfile` und die Dokumente | skip-if-present schützt ein Ziel mit eigener Wurzel-Datei **gar nicht**; ein Marker-Block schreibt in eine Adopter-Datei — ein dritter Mechanismus neben den zwei Klassen, für eine Zeile, und die Wurzel-Dateien tragen unter GNU Make 4.3 keinen gemessenen Bruch (Festlegung 1), unter einem Windows-`make` und BuildKit keine Messung überhaupt |
| E — **Endungs-Globs** (`*.sh`, `*.mk`, `*.awk` plus benannte Dateien) | eng; berührt nur, was ein Interpreter liest | trifft `blocked/<sprache>`, `commit-msg` und die Prüfsummen-gehaltenen Dateien nicht, sobald der Glob sie nicht einzeln nennt — und erzeugt damit den Mischzustand aus dem Kontext (Skript LF, Wortliste CRLF), an dem der Guard `staticcheck` **ohne Meldung** durchlässt; jede neue endungslose Datei wäre ein Eintrag mehr, und keiner meldete das Vergessen |
| F — **nichts tun** | keine Änderung an Code, Text oder Vertrag | jedes Ziel, das ein Windows-Entwickler mit Voreinstellung klont, trägt CRLF in Skripten, die `bash` nicht lesen kann, und in einem vendored Baum, dessen Prüfsummen alle brechen; der Ausfall ist **laut**, nicht still — der Guard endet in jedem Aufruf mit Exit 2 (Kontext), der git-eigene Träger mit 127 —, das Ziel ist also unbenutzbar, ohne dass ein Wächter still aufhört zu blocken; ob Claude Code den Exit 2 als blockierend liest, ist ungemessen |

## Konsequenzen

- **Positiv:** Ein Klon mit `core.autocrlf=true` bekommt die Skripte, Fragmente, Hooks und den vendored Baum mit LF, soweit die Datei aus Festlegung 3 an ihrem Pfad liegt; `baseline-verify` und der git-eigene Träger laufen dort über ihre Shebang-Zeile bzw. gegen ihre Prüfsummen. Eine Adopter-Wurzel kann das für diese Dateien nicht aufheben (nächstes Verzeichnis gewinnt); bei belegtem skip-if-present-Pfad entscheidet die Datei des Adopters (Festlegung 5).
- **Positiv:** Die Klasse hat je Datei eine Adresse und eine benannte Herkunft. Die Zweifelsregel aus [ADR-0007](0007-bootstrap-phasen.md) Festlegung 3 ist in den drei skip-if-present-Pfaden **angewandt**; in den zwei konvergenten trägt die Tabelle das Verzeichnis als tool-eigen — die Regel ist dort beantwortet, nicht übergangen, und der Preis der Gegenwahl steht in Alternative C.
- **Negativ:** Die Wurzel-Dateien des Ziels und `.claude/settings.json`, `agents/`, `commands/` bleiben ohne Attribut; ob ein Windows-`make` oder BuildKit an CRLF bricht, ist ungemessen. Der Bestand daran ist Sache des Adopters.
- **Negativ:** In drei Verzeichnissen heilt der Lauf die Datei nicht; die Meldung erscheint dort bei jedem Lauf, auch über der eigenen Datei.
- **Negativ, benannt und nicht bewacht:** Ein bereits mit CRLF ausgechecktes Arbeitsverzeichnis behält seine CR bis zum nächsten Checkout; `git add --renormalize .` ist der Vorgang des Adopters, das Werkzeug fasst keinen fremden Arbeitsbaum an. **Ebenso eine Datei, die ein Adopter schon mit CRLF im Index führt:** sie bleibt trotz `text=auto eol=lf` CRLF (Sonde: CRLF-Datei ohne Attribut committet, danach `.githooks/.gitattributes` mit der Zeile → `git ls-files --eol` → `i/crlf w/crlf`, im Klon mit `-c core.autocrlf=true` CR ≥ 1); auch das ist Sache des Adopters (`git add --renormalize`).
- **Kein `Supersedes`.** [ADR-0007](0007-bootstrap-phasen.md) und [ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) werden nicht abgelöst und ihre Tabelle nicht fortgeschrieben: was sie nicht nennen, entscheidet ihre Zweifelsregel bzw. ihre Zeile für das Verzeichnis, und diese Datei wendet beides an — sie ist die spätere, nicht die abweichende. Was in [ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) über die `.claude/`-Zeilen der Tabelle steht, bleibt unangetastet.
- **Kein Change Request.** Keine `LH-*`-Aussage ändert sich; die Grenze der Messmethode von [`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) bleibt wörtlich, was sie ist. Die ADR liest [`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (Windows erstklassig) als Bezug ihrer Technik und fügt dem Vertrag nichts hinzu. **Herstellbar ist die Eigenschaft unter Linux, nicht unter Windows:** das Gegenbeispiel zu *„ein Klon mit `core.autocrlf=true` trägt in diesen Verzeichnissen kein CR"* baut die dritte Fitness-Zeile (Klon mit `-c core.autocrlf=true`, Kontrolle mit `=false`); nicht herstellbar auf den gehosteten Runnern ist die Aussage über einen **Windows**-Git. Ein Lastenheft-Satz über die Klon-Eigenschaft wäre damit als Linux-Aussage prüfbar — aber eine neue vertragliche Zusage, die [`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) nicht trägt (die Spec schweigt zum Gegenstand, Festlegung 5) und deren Windows-Lesart kein Lauf einlöst ([`AGENTS.md`](../../../AGENTS.md) §3.6). Diese Entscheidung braucht sie nicht als Voraussetzung; wer die Eigenschaft dennoch vertraglich binden will, trifft das als Auftraggeber im Change-Request-Weg ([`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)), nicht hier.
- **Folgepflicht 1 — der Vorgang, und er ist Implementer-Arbeit.** Die fünf Einträge mit ihrer Klasse in der Aufzählung, die die Klasse je Pfad trägt (die Klasse eines Pfades steht nur dort), die Vorlage, die Meldung nach Festlegung 4, die Inventur des Ziels über seinen eigenen Baum und die Sätze, die die emittierten Verzeichnisse aufzählen. Dazu der Messweg (Fitness Function unten). Schnitt, Priorisierung und Vorschau-Zeile sind **Planner-Arbeit**; der Vorgang liegt im Planning-Lifecycle.
- **Folgepflicht 2 — die Kopplung der Erfassung.** Die Zusage ist die Menge nach dem Kriterium aus Festlegung 1; der Test darf sie darum **nicht** aus derselben Verzeichnis-Liste ableiten, die die Emission liest (ein Test, der die Quelle gegen sich selbst hält, kann unter keiner Mutation rot werden).

## Fitness Function (falls maschinell prüfbar)

**Die Sensoren dieser Entscheidung sind zu bauen; bis der Vorgang aus Folgepflicht 1 sie liefert, ist die Zusage unbewacht** ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6): keine Zeile unten nennt ein Target, das heute für diesen Gegenstand existiert). Die Klassen-Kopplung je Pfad steht bereits (`TestEnforce_IdempotenzKlasseJePfad` in `internal/emit/enforce_test.go`) und trägt die neuen Pfade, sobald sie in der Aufzählung stehen.

| Tooling | Regel | Make-Target |
|---|---|---|
| `go test` | **Eigenschaft statt Verzeichnis-Liste:** für jede emittierte Datei **unterhalb der Wurzel des Ziels** mit Interpreter- oder Byte-Konsument (Shebang-Zeile, Endung `.sh`/`.awk`/`.mk`, Wortliste unter `blocked/`, Datei unter `.harness/`, Datei unter `.githooks/`) liegt in einem Vorfahr-Verzeichnis, das nicht die Wurzel ist, eine emittierte `.gitattributes` mit `eol=lf`; die Wurzel-Dateien (`Makefile`, `d-check.mk`, `a-check.mk`) sind die ausdrückliche Ausnahme aus Festlegung 1; rot gesehen durch Streichen eines Eintrags **und** durch die Zeile `eol=crlf` | `make test` |
| `go test` | **eine Klasse je Pfad:** die zwei konvergenten und die drei skip-if-present-Pfade tragen die Klasse aus Festlegung 3; die belegte Datei bleibt beim zweiten Lauf unberührt und der Lauf nennt sie, die freie wird geschrieben | `make test` |
| `make full-smoke` (**Stufe zu bauen**) | im echten Klon mit `-c core.autocrlf=true` trägt keine Datei der fünf Verzeichnisse ein CR, `.githooks/commit-msg` läuft über seine Shebang-Zeile, und die **Kontrolle** mit `-c core.autocrlf=false` (ausdrücklich gesetzt) trägt keine — die Stufe kann nicht aus falschem Grund rot sein; ohne die Emission trägt der autocrlf-Klon CR-Dateien und die Meldung nennt die Datei. Der Rest, den die fünf Verzeichnisse nicht decken, wird ausgegeben, nicht zugesagt | `make full-smoke` |
| `make mutate` (**Fall zu bauen**) | ein Eintrag der Aufzählung entfällt, oder die Zeile trägt `eol=crlf` → der Test der ersten Zeile färbt rot | `make mutate` |
| **kein Gate** — ob ein **Windows**-Git dieselbe Konfiguration liest (andere Konfigurationsebene für `core.autocrlf`, Symlink-Recht, Ausführungsbit), prüft kein Lauf, den die Runner tragen ([`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix), Grenze der Messmethode). Benannt, nicht bewacht | — | — |

## Re-Evaluierungs-Trigger

- **Wenn ein Runner Linux-Container unter Windows fährt** — die Grenze der Messmethode in [`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) löst sich —, dann ersetzt oder ergänzt ein echter Windows-Lauf die Stufe unter Linux, und die Aussage aus Festlegung 5 ist neu zu fassen.
- **Wenn gemessen ist, dass gebaute Ziele in `harness/mk/`, `.claude/hooks/` oder `.githooks/` keine eigene `.gitattributes` führen** (eine Stichprobe tatsächlich gebootstrappter Ziele), dann wiegt der Heilungs-Verlust schwerer als das Überschreib-Risiko, und die drei skip-if-present-Zeilen sind neu zu wägen. **Und wenn eine solche Stichprobe in `tools/harness/` oder `.harness/` eine eigene `.gitattributes` findet**, ersetzt die konvergente Klasse dort Adopter-Inhalt, und die zwei konvergenten Zeilen sind neu zu wägen. Bis dahin steht die Klasse auf dem Urteil aus §Kontext und nicht auf einer Zahl. <!-- d-check:ignore (der Pfad entsteht erst im gebootstrappten Ziel) -->
- **Wenn ein Windows-`make` oder BuildKit an CRLF in den Wurzel-Dateien nachweislich bricht**, dann ist die Wurzel-Frage aus Festlegung 5 keine Adopter-Sache mehr, und die Alternative D ist mit dieser Messung neu zu wägen.
- **Wenn die Emission ein Verzeichnis mit Interpreter-Konsument anlegt**, das Festlegung 1 nicht nennt, gilt das Kriterium; ein zweiter Eintrag in dieser Tabelle ist die Folge, keine neue Entscheidung.

**Träger der Trigger:** der erste hängt am Runner-Ereignis der Grenze in [`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix), der vierte an der ersten Fitness-Zeile. Für den **zweiten und den dritten gibt es keinen Wächter**: keine Stichprobe gebauter Ziele wird gezogen, keine Messung an einem Windows-`make` genommen. **Benannt, nicht geschlossen** — beide sind bis dahin eine Absichtserklärung, kein bewachter Trigger.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-25 | **Proposed** | Architect-Lauf zur Klasse und zur Erfassungsmenge der emittierten `.gitattributes`, ausgelöst vom Slice `slice-emittierte-dateien-behalten-lf-im-autocrlf-klon`. Die Messungen in §Kontext stehen neben ihren Kommandos |
| 2026-09-25 | Proposed überarbeitet | Review Runde 1 (Text): Guard-Fehlerbild an den gewöhnlichen Klon angepasst, Kriterium und Wurzel-Ausnahme in Deckung, Begründung ohne Change Request, Herkunft der zwei konvergenten Klassen, Träger der Trigger |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0067` (Baseline-Regelwerk `v6.8.0`, `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
