# ADR-0053: Die Kennungs-Zusage hat zwei Träger — einen am Commit und einen am Agenten, und beide bleiben

**Status:** Proposed

**Datum:** 2026-09-15

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`harness/README.md`](../../../harness/README.md#traceability) §Traceability und
[`AGENTS.md`](../../../AGENTS.md) §5 (die Zusage, deren Träger hier entschieden wird, an ihren zwei
Orten),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Wächter, dessen Reichweiten-Aussage weiter ist als sein Prüfbereich, behauptet mehr als er mißt),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Träger und seine
Aktivierung werden getrennt benannt, weil nur eine der zwei Hälften mit dem Klon reist),
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (der Commit-Pfad
verträgt kein Docker; `git` ist die zugelassene Host-Abhängigkeit),
[ADR-0004](0004-durchsetzungs-emission.md) (**Accepted** — der Stolperdraht-Charakter eines Guards
und die `bash`/`awk`-Bauart; gegen beide wird jede Träger-Wahl gehalten),
[ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) (**Accepted** — der Agenten-Kanal entscheidet
die **Aufrufform**; diese Entscheidung setzt an derselben Kanal-Grenze an und keiner ihrer
Re-Evaluierungs-Trigger ist gefeuert),
[`MR-002`](../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) (die
Hook- und Nachweis-Mechanik dieses Repos — sie entscheidet, **wo** ein Vor-Commit-Sensor hängen
darf),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert),
[`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(jede Baseline-Aussage nennt den Tag, gegen den sie gemessen ist),
[`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
(die Form der Kennung, die der Kandidat unten trägt, und die Ursache der zweiten Hälfte von
Festlegung 4)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie entscheidet, an welchem **Kanal** eine bestehende
Zusage durchgesetzt wird. Keine Anforderung und keine technische Festlegung ändert sich.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR). Die eine
Baseline-Aussage unten mißt gegen die regierende Fassung `v6.8.0`
([`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)).

---

## Kontext

### Der Gegenstand ist eine Zusage an den Commit, nicht an den Agenten

[`AGENTS.md`](../../../AGENTS.md) §5 verlangt, Requirement- und ADR-IDs in Commits zu
referenzieren; [`harness/README.md`](../../../harness/README.md#traceability) §Traceability sagt dasselbe in
der expliziten Form: *mindestens eine `LH-*`- oder `ADR-*`-ID*. **Durchgesetzt** wird eine
**Menge**, und sie ist die Konfiguration des Gegenstands — `commits.id-patterns` in
[`.d-check.yml`](../../../.d-check.yml), geführt von den zwei Trägern. Der Satz richtet sich an **jeden** Commit. Ein
Commit entsteht in diesem Repo aber auf zwei Wegen, und die unterscheiden sich nicht im Aufrufer, sondern im **Kanal**, auf dem der Aufruf sichtbar wird:

- **getippt** — ein Agent oder ein Mensch führt `git commit …` aus;
- **im Werkzeug** — `make slice-mv`, `make archive-welle` und der Verweis-Nachzug committen
  **innerhalb** von Skript bzw. Binär; auf der Kommandozeile erscheint `make slice-mv …`.

Der Kanal, an dem eine Zusage hängt, entscheidet ihre **Reichweite** — das ist der Gegenstand
dieser ADR und der Grund, warum sie eine Architektur-Entscheidung ist und keine Zeile im Plan.

### Was der PreToolUse-Kanal strukturell nicht sieht

Der Zusatz-Hook
[`.claude/hooks/pretooluse-commit-msg-guard.sh`](../../../.claude/hooks/pretooluse-commit-msg-guard.sh)
sitzt am Tool-Call-Kanal des Agenten. Er sieht eine **Befehlszeile**, und er sieht nur die, die
sein Matcher erkennt. Sein Kopf nennt seine Grenzen selbst, und die Reichweiten-Tabelle
des Einstiegs ordnet sie nach Commit-Klasse. Hier stehen sie als Aufzählung, weil diese Entscheidung an ihnen hängt:

- Ein Commit **aus einem Repo-Werkzeug** erreicht ihn nicht: auf der Kommandozeile steht
  `make slice-mv …`, nicht `git commit …`.
- Ein Commit **außerhalb eines Claude-Code-Laufs** erreicht ihn nicht: der Kanal existiert dort
  nicht.
- Die **`-m`-Form** ist nicht garantiert erreichbar: der Matcher verlangt eine `-F`/`--file`-Form.

Gemessen am Bestand, **keine Erwartungswerte** — alle vier Zahlen wandern mit jedem Commit:

```sh
git log --format='%s' | grep -c '^slice-mv:'                          # 411
git log --format='%s' | grep -c '^archive-welle'                      #   0
git config --get core.hooksPath                                       # kein Treffer, Exit 1
git ls-files -s .githooks/                                            # 100755 .githooks/commit-msg
```

Die `archive-welle`-Zeile des Blocks zählt **null** — die Klasse ist heute klein und
wächst mit der ersten geschlossenen Welle; sie ist die Klasse, die ein Träger am Commit
erreichen muß und die am Agenten strukturell unerreichbar bleibt.

### Der zweite Kanal und seine zwei Grenzen

Ein `git`-eigener `commit-msg`-Hook läuft **am Commit**, für jede Commit-Klasse, die `git` selbst
erzeugt — Werkzeug-Commits, `-m`-Formen, Commits ohne Agenten. Diese Entscheidung nimmt ihn als
Träger, mit den Grenzen, die `git` ihm setzt und die kein Aufbau dieses Repos verschiebt:

- **`core.hooksPath` ist lokale Konfiguration und reist nicht mit dem Klon.** Die **Datei** reist
  (`.githooks/commit-msg`, Index-Modus `100755` — oben gemessen), ihre **Aktivierung** tut es nicht;
  `make hooks-install` ist der eine Schritt dazwischen, und er braucht allein `git`
  ([`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- **`git commit --no-verify` umgeht ihn.** Ein Hook ist ein Stolperdraht
  ([ADR-0004](0004-durchsetzungs-emission.md)), keine Sandbox.

Dazu eine Bauart-Grenze, die aus dem Kanal folgt: der Hook liegt **außerhalb von `make`** und darf
darum kein Docker voraussetzen. Die Prüfung ist deshalb `bash` + coreutils
([`harness/tools/commit-msg-traceability.sh`](../../../harness/tools/commit-msg-traceability.sh)) —
und führt die Kennungs-Menge als **zweite Fassung** neben dem `commits:`-Block der
[`.d-check.yml`](../../../.d-check.yml). Zwei Fassungen derselben Liste sind eine Kopplung, und
eine Kopplungs-**Zusage** kann weiter sein als der Sensor, der sie hält; ihr Prüfbereich ist der
Gegenstand des Sensor-Dokuments ([`harness/sensors/commit-msg-check.md`](../../../harness/sensors/commit-msg-check.md))
und steht dort, nicht als zweite Fassung hier.

### Die Folge, die diese Entscheidung tragen muß

Ein Träger, der am Commit hängt, feuert auch dort, wo **dieses Repos eigene Werkzeuge** committen.
Gemessen an den vier Stellen, die ihre Message mit `-m` **innerhalb** des Werkzeugs bilden
([`harness/tools/slice-mv.sh`](../../../harness/tools/slice-mv.sh) zweimal,
`internal/archive/anwenden.go` zweimal):

```sh
grep -n 'git commit -q -m' harness/tools/slice-mv.sh                  # :234 (Move), :268 (Verweis-Nachzug)
grep -n 'g.Commit(' internal/archive/anwenden.go                      # :107 (Move), :175 (Inhalt)
```

`slice-mv` committet den reinen Move **nach** dem `git mv` (`:234`) und den Verweis-Nachzug
danach (`:268`). Trägt die Message keine Kennung, die die Menge trifft, bricht der zweite Commit ab
— und der Aufruf läßt einen **gestagten Rename ohne Commit** stehen. `make slice-mv` fährt **jede
Rolle bei jedem Lifecycle-Wechsel**
([`harness/README.md`](../../../harness/README.md#traceability) §Werkzeuge).

Der Auslöser ist die **Kennungs-Form**, nicht das Werkzeug: die Message trägt den Dateinamen. Der
Bestand zeigt beides, wieder gemessen und ohne Erwartungswert:

```sh
RE='ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+'
git log --format='%s' | grep '^slice-mv:' | grep -vcE "$RE"            # 44 von 411
```

Die 44 sind die Commits, deren Message keine Ziffern-Kennung trifft. Seit
[`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
vergibt dieses Repo **Namens**-Kennungen (`slice-<name>`), die `slice-[0-9]+` nicht trifft — der
Fall wird damit für **jeden neuen** Slice der Regelfall, und die [`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) §Grenze führt dieselbe Bindung
schon für die Erkennung im Werkzeug. `archive-welle` trägt überhaupt keine Kennung: seine Message
nennt `welle-<Kennung>`, und `welle-*` steht in der Menge nicht.

### Was daran entschieden wird und was nicht

Der auslösende Slice `slice-215-commit-waechter-sieht-auch-die-ungetippten-commits` führt in §3 die
Träger-Wahl und bindet ihre Beantwortung in §4 an den Architect — **als ADR oder als Zeile in §3**.
Diese ADR ist die schwerere der beiden Formen; die vier Festlegungen unten binden über diesen Slice
hinaus, und keine von ihnen ist eine Plan-Zelle.

Nicht Gegenstand dieser ADR: die Konvention „Commit via Message-Datei" in den Rollen-Anweisungssätzen
zu schreiben (fremdes Eigentum,
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)), die **Wahrheit** einer
genannten Kennung zu prüfen (Anwesenheit, nicht Wahrheit — die Grenze beider Träger), ein
Range-Lauf in CI, und die **emittierte Ebene**: was ein gebootstrapptes Zielrepo an
Commit-Wächtern bekommt, entscheidet der Slice, der die Tool-Ebene entscheidet.

### Annahmen, auf denen diese Entscheidung steht

Kippt eine, kippt die Festlegung, auf der sie steht; alle drei stehen unten als
Re-Evaluierungs-Trigger.

- **(a) `core.hooksPath` bleibt lokale Konfiguration.** Solange `git` einen Hook nicht aus dem Baum
  aktiviert, ist die Aktivierung ein Host-Schritt — und die eine Hälfte der Trägerschaft ist ein
  ausgewiesener Schritt, kein Automatismus.
- **(b) Der Commit-Pfad bleibt ohne Docker.** Ein Hook, der einen Daemon voraussetzt, bräche jeden
  Commit ohne laufenden Daemon; die `bash`+coreutils-Bauart ist deshalb keine Sparsamkeit, sondern
  eine Bedingung des Kanals.
- **(c) Die Kennungs-Menge bleibt in `.d-check.yml` geführt.** Der Hook spiegelt sie; fällt der
  `commits:`-Block als Führung weg, verliert die zweite Fassung ihren Bezugspunkt.

## Entscheidung

**Wir wählen Alternative C: beide Kanäle bleiben, jeder trägt die Klasse, die der andere nicht
erreicht.** Vier Festlegungen.

**1. Der Träger der Klasse *Commit aus einem Repo-Werkzeug* — und der Klasse *Commit außerhalb
eines Agenten-Laufs* — ist der git-eigene `commit-msg`-Hook.** Er liegt versioniert unter
`.githooks/commit-msg`, seine Prüfung unter `harness/tools/commit-msg-traceability.sh`, seine
Aktivierung ist `git config core.hooksPath .githooks` über `make hooks-install`. Der tragende Grund
ist die Kanal-Grenze aus §Kontext: diese zwei Klassen sind am **Commit** entscheidbar und am
**Agenten** strukturell nicht; ein Träger am Agenten kann sie nicht erreichen, gleichgültig wie
breit sein Matcher wird. Der Hook läuft `bash` + coreutils ohne Docker und ohne Netz; er trägt damit auch die `-m`-Form,
die der Matcher des Agenten-Kanals nicht garantiert erreicht.

**2. Der PreToolUse-Kanal bleibt, und die zwei sind nicht austauschbar.** Er trägt die Klasse
*getippter Aufruf in einem Claude-Code-Lauf* und er trägt sie **ohne Aktivierungsschritt** — er
reist mit dem Klon. Wer ihn gegen den git-Hook eintauscht, senkt die Deckung in jedem Klon, in dem
`make hooks-install` nicht gelaufen ist; wer den git-Hook gegen ihn eintauscht, läßt die drei
Klassen oben unerreicht. **Zwei Träger über einem Gegenstand sind hier keine Doppelung:** der
Agenten-Kanal liegt **vor** der Ausführung und der Commit-Kanal **an** ihr, im Normalpfad blockt
genau einer, und beide urteilen über denselben Satz.

**3. Der Träger ist ein Stolperdraht, und seine zwei Grenzen gehören zur Trägerschaft.** Die
Aktivierung reist nicht, und `--no-verify` umgeht ihn; ein Klon ohne `make hooks-install` ist
ungeprüft. Beides steht als Zeile in der Reichweiten-Tabelle
([`harness/README.md`](../../../harness/README.md#traceability) §Traceability), und diese Tabelle
ist die Deklaration des Trägers: **jede ihrer Zeilen ist eine Zusage über eine Commit-Klasse**, und
eine Zusage ohne Gegenbeispiel ist keine
([`AGENTS.md`](../../../AGENTS.md) §3.6). Ein Träger, der über seinen zwei Grenzen als Zaun
gelesen würde, wäre eine Zusage ohne Deckung
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

**4. Die Commit-Message-Formen der eigenen Werkzeuge sind der zweite Arm derselben Frage, und sie
sind ein eigener Träger.** Vier Stellen
([`harness/tools/slice-mv.sh`](../../../harness/tools/slice-mv.sh) `:234` und `:268`,
`internal/archive/anwenden.go` `:107` und `:175`) bilden ihre Message mit `-m` **innerhalb** des
Werkzeugs und ohne Kennung. Die Werkzeug-Klasse ist **genau die Klasse, für die Festlegung 1 den
Träger wählt** — ein Träger, auf dem die Werkzeuge des eigenen Prozesses fallen, trägt seine Klasse
nicht: er bricht `make slice-mv` **nach** dem `git mv` und hinterläßt einen gestagten Rename ohne
Commit, in einem Aufruf, den jede Rolle bei jedem Lifecycle-Wechsel fährt.

**Entschieden ist damit, *daß* die Werkzeug-Commits im Gegenstand der Zusage liegen; nicht, *welche
Form* jede der vier Messages trägt.** Die Form ist ein eigener Gegenstand — sie berührt die
Kennungs-Menge und die Namens-Form aus
[`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
und ist nicht dieselbe Frage wie der Kanal. Sie ist **kein Liefer-Punkt des auslösenden Slice**: dessen
DoD führt drei Punkte, der Kanal ist entschieden, und ein vierter Punkt gehört nach
`modul-05-planning-harness.md` §Ziel-Form: Slice zurück zum Schnitt.

Der Kandidat trägt eine Kennung: **`slice-werkzeug-commits-tragen-eine-kennung`**
([`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)).
Der Schnitt — ein Slice, seine Priorisierung, seine Zeile in der Vorschau — ist **Planner-Arbeit**
(Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle); dieser Lauf liefert
die Messung und die Kennung, nicht den Plan. Bis der Slice im Planning-Lifecycle liegt, löst die
Kennung hier auf. **Eine Ausnahme für die Werkzeug-Formen ist damit nicht ausgesprochen:** eine
Zeile, die `slice-mv:`-Messages von der Prüfung nimmt, wäre eine **Senkung** der Durchsetzung
([`AGENTS.md`](../../../AGENTS.md) §3.5) und höhlte die Klasse aus, für die dieser Träger gewählt
ist.

## Verglichene Alternativen

Regeln dieser Sektion: **mindestens drei Optionen mit Pro/Contra** — „nichts tun" ist eine davon
(Baseline-Regelwerk `v6.8.0`, `modul-04-adrs.md` §Ziel-Form: ADR (MADR)).

| Option | Pro | Contra |
|---|---|---|
| A — **nur der Agenten-Kanal** (der git-Hook unterbleibt) | kein Aktivierungsschritt, keine neue Datei, keine zweite Kennungs-Fassung; der Kanal reist | die drei Klassen oben bleiben strukturell unerreicht — die Werkzeug-Commits, die Commits ohne Agenten und die nicht erkannte `-m`-Form. Die Zusage aus §5 bleibt an einer Aufrufform hängen, statt am Commit; der Gegenstand des auslösenden Slice fällt damit weg |
| B — **nur der git-Hook** (der PreToolUse-Zusatz entfällt) | ein Träger, ein Ort, eine Config; kein zweiter Satz über denselben Gegenstand | er reist nicht: jeder Klon ohne `make hooks-install` ist **un**geprüft, und der Zusatz ist die einzige Hälfte, die ohne Schritt wirkt. Entfernen ist eine **Senkung** der Durchsetzung ([`AGENTS.md`](../../../AGENTS.md) §3.5) — dieselbe Prüfung, die diese ADR fährt, nur mit dem kleineren Ertrag; und `--no-verify` bliebe die einzige verbleibende Umgehung |
| **C — beide Kanäle, mit getrennten Reichweiten (gewählt)** | jede der drei Klassen hat einen Träger; jede Hälfte trägt, was die andere nicht kann; die Reichweiten stehen als Tabelle statt als Behauptung; die zwei Grenzen sind je benannt | zwei Orte, an denen dieselbe Kennungs-Menge steht — eine Kopplung, deren Zusage weiter sein kann als ihr Sensor; zwei Grenzen statt keiner; und die Werkzeug-Formen aus Festlegung 4 müssen nachziehen, sonst fällt der Träger auf der Klasse, für die er gewählt ist |
| D — **ein `make`-Wrapper** (die Werkzeuge prüfen ihre Message selbst, vor dem Commit) | der Fehler fällt **vor** dem `git mv`, kein gestagter Rename bleibt liegen | er hängt am **Aufrufer**, nicht am Commit: jede Aufrufform, die den Wrapper umgeht (git direkt, ein Skript, eine IDE), bleibt ungeprüft — dieselbe Klasse, die dieser Träger schließen soll. Und er kennt nur die Aufrufstellen, die ihn rufen: ein weiteres Werkzeug fällt still aus der Deckung |
| E — **ein Range-Gate nach dem Commit** (`commits`-Modul über die Historie) | nutzt die gepinnte Config als einzige Fassung, kein zweiter Prüfer | es urteilt **nach** dem Commit: der Commit steht, bevor irgendetwas rot wird — feedforward wird zu feedback, und die Umgehung ist eingebaut. Dazu gemessen: `--range` des Moduls ist am gepinnten d-check unbedienbar, sobald `commits.id-patterns` eine nicht-leere Liste trägt |

## Konsequenzen

- **Positiv:** Die Zusage aus
  [`AGENTS.md`](../../../AGENTS.md) §5 hat einen Träger für die Klasse, die der Agenten-Kanal
  strukturell nicht erreicht. Die zwei Klassen *Commit aus einem Werkzeug* und *Commit ohne Agenten*
  sind nicht mehr ungedeckt, und die `-m`-Form hängt nicht mehr an einem Matcher.
- **Positiv:** Die reisende Hälfte bleibt. Ein frischer Klon ist mit dem Agenten-Kanal gedeckt,
  bevor irgendein Schritt gelaufen ist — die Klasse *getippter Aufruf* hat damit einen Träger ohne
  Vorbedingung.
- **Positiv:** Die Reichweite steht als **Tabelle** mit je einer Zeile pro Commit-Klasse und nicht
  als Satz. Die zwei Grenzen (Aktivierung reist nicht · `--no-verify`) stehen in ihr.
- **Negativ, und das ist der Preis von Festlegung 1:** Der Träger ist **opt-in**. Ohne
  `make hooks-install` ist ein Klon ungeprüft, und das Werkzeug, das ihn aktiviert, ist kein Gate
  (es schreibt lokale Konfiguration). Diese Entscheidung behauptet **kein** Gate; sie behauptet
  einen Träger mit zwei benannten Grenzen.
- **Negativ:** Zwei Fassungen derselben Kennungs-Menge — der `commits:`-Block der
  [`.d-check.yml`](../../../.d-check.yml) und die Regex des Prüfers. Sie sind gekoppelt; wie weit
  die Kopplung gehalten ist, steht im Sensor-Dokument, und die Kopplung zu halten ist ein Gegenstand des auslösenden Slice und nicht dieser ADR.

- **Negativ, und offen bis zum Kandidaten:** Die Werkzeug-Formen aus Festlegung 4 tragen keine
  Kennung. **Bis der Kandidat gearbeitet ist, bricht die Aktivierung des Trägers `make slice-mv`
  nach dem `git mv`** — die Folge ist an den vier Stellen und an `make slice-mv` gemessen. Sie ist der
  Grund, warum die Aktivierung in einem Baum, den mehrere Rollen zugleich benutzen, ein
  abgestimmter Schritt ist und kein Nebenbei.
- **Folgepflicht 1 — der Kandidat `slice-werkzeug-commits-tragen-eine-kennung`, geschnitten vom
  Planner.** Die Bedingung ist eine **Eigenschaft**, keine Adresse: ein Slice, der die vier
  Message-Formen in den Gegenstand der Zusage zieht und die Form ihrer Kennung entscheidet.
  [`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
  §Grenze führt die Erkennungs-Seite derselben Bindung; ob beide im selben Schnitt liegen, entscheidet
  der Planner.
- **Folgepflicht 2 — die zwei Träger bleiben in den Rollen-Anweisungssätzen unbenannt.** Die
  Konvention „Commit via Message-Datei" schreiben zu lassen ist fremdes Eigentum
  ([ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)); mit dem git-Hook verliert
  sie an Gewicht — der Träger am Commit braucht sie nicht mehr —, aber sie fällt nicht weg, weil
  die reisende Hälfte sie weiter voraussetzt.
- **Übergabe an den Planner:** die Kennung aus Festlegung 4 samt der Messung in §Kontext. Die
  Antwort auf die Träger-Wahl des Slice steht mit dieser ADR und ist in dessen §3 einzutragen.

## Fitness Function (falls maschinell prüfbar)

Festlegungen 1 und 2 haben je einen Sensor; Festlegung 3 spricht eine **Grenze** aus und
Festlegung 4 eine **Zuordnung** — für beide gibt es keinen, und das steht hier so.

| Tooling | Regel | Make-Target |
|---|---|---|
| bats — `test/commit-msg-hook.bats` | **Festlegung 1:** der Träger lehnt eine Message ohne Kennung ab, läßt eine mit Kennung durch, führt die Merge-/Revert-Ausnahme und ist fail-closed ohne lesbare Message-Datei. Der Aufruf geht **über den Hook** und nicht gegen das Prüf-Skript direkt | `make test` (in `make gates`) |
| Mutation — `test/mutations/340-commit-msg-traeger-ohne-kennungs-pruefung.sh` | **Festlegung 1:** nimmt dem Prüf-Skript die Kennungs-Prüfung (`patterns` → `.*`); der bats-Fall oben muß dabei rot werden — der Zahn trifft die Stelle, die der Aufrufer benutzt | `make mutate` (kein Gate) |
| bats — `test/commit-msg-guard.bats` | **Festlegung 2:** der Agenten-Kanal bleibt verdrahtet — die Fälle fahren den Hook über eine Tool-Eingabe und prüfen Treffer, Nichttreffer und den Block | `make test` (in `make gates`) |
| bats — `test/commit-msg-hook.bats`, Fälle *kopplung:\** | **Festlegung 1, Kopplung:** die zwei Fassungen der Kennungs-Menge und der Betreff-Ausnahme werden gegeneinander gehalten. Welche Richtung dieser Fall deckt, steht im Sensor-Dokument ([`harness/sensors/commit-msg-check.md`](../../../harness/sensors/commit-msg-check.md)) — der Prüfbereich eines Sensors ist sein eigener Gegenstand und steht nicht als zweite Fassung hier | `make test` (in `make gates`) |
| — | **Festlegung 3:** die zwei Grenzen des Trägers sind **Prosa in der Reichweiten-Tabelle** und haben keinen Sensor; kein Modul der [`.d-check.yml`](../../../.d-check.yml) vergleicht eine Commit-Klasse mit einer Tabellenzeile. Träger ist der Lauf, der die Tabelle ändert | — |
| — | **Festlegung 4:** die vier Message-Formen sind **heute ungeprüft**; ein Sensor darauf wäre erst mit dem Kandidaten zu bauen. Der Zahn aus Festlegung 1 färbt die Klasse nicht rot, weil kein Werkzeug-Commit im Prüfbereich der bats-Stufe liegt | — |
**Was diese Tabelle nicht belegt.** Sie beschreibt, welche Sensoren die Festlegungen halten, und behauptet keinen Rot-Beleg: der gehört dem Lauf, der den Träger ändert, und das Rot muß die **behauptete** Ursache tragen, nicht irgendeine ([`AGENTS.md`](../../../AGENTS.md) §3.6). Festlegung 3 und Festlegung 4 haben keinen Sensor, und das steht hier ausgeschrieben statt durch eine Zeile ersetzt.

## Re-Evaluierungs-Trigger

1. **`core.hooksPath` wird zum Automatismus** — ein Bootstrap- oder Klon-Schritt, der den Träger
   ohne Handaufruf herstellt *(feedforward — fremde Mechanik, kein Sensor)*. Dann fällt Annahme (a),
   Festlegung 3 verliert ihre erste Grenze, und die Träger-Frage ist neu zu stellen: ist die
   reisende Hälfte dann noch nötig?
2. **Der Kandidat `slice-werkzeug-commits-tragen-eine-kennung` ist gearbeitet** *(feedback — er hat
   einen entscheidbaren Ausgang)*. Dann tragen die vier Werkzeug-Formen eine Kennung, die Folge aus
   §Kontext entfällt, und Festlegung 4 bekommt ihren Sensor statt ihres Kandidaten.
3. **Die Kennungs-Menge oder die Kennungs-Form bewegt sich** — ein Muster kommt hinzu oder fällt
   weg, [`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
   wird abgelöst, oder eine neue Kennungs-Klasse tritt in die Menge ein *(feedforward — die
   Deklaration steht im Adaptions-Block)*. Dann ist die zweite Fassung im Prüfer zu prüfen und die
   Reichweiten-Tabelle neu zu lesen; fällt Annahme (c), verliert der Träger seinen Bezugspunkt.
4. **Die emittierte Ebene bekommt einen Commit-Wächter** *(feedforward — eine Entscheidung des
   Slice, der die Tool-Ebene entscheidet)*. Dann gilt diese Grenze dort unverändert — sie ist eine
   Eigenschaft des Kanals, nicht dieses Aufbaus — und gehört dort **genannt**, nicht
   stillschweigend mitgeliefert ([ADR-0051](0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md)
   für dasselbe Muster auf einer anderen Achse).

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-15 | **Proposed** | Architect-Antwort auf die Träger-Wahl, die `slice-215-commit-waechter-sieht-auch-die-ungetippten-commits` in §3 führt und in §4 an den Architect bindet. Die Messungen in §Kontext stehen neben ihren Kommandos; der Reviewer-Konsistenz-Durchgang steht aus ([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)) |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0053` (Baseline-Regelwerk `v6.8.0`, `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
