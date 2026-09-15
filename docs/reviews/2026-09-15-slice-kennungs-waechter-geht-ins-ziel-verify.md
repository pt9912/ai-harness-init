# Verifikation `slice-kennungs-waechter-geht-ins-ziel` — der Träger trägt, ein DoD-Satz trägt zwei Lesarten

**Rolle:** Verifier · **Datum:** 2026-09-15 · **Geprüfter Stand:** `af9f9705` —
`git rev-parse HEAD` → `af9f97056843671a63a5bb82982485fc035dbe50`; `git status --porcelain` → keine
Zeile, vor und nach jeder Messung.

**Prüfgegenstand:** §2 **Definition of Done gegen den tatsächlichen Stand**, dazu §1, §3, §5, §6,
§8 des Slice-Plans — **nicht** der Plan gegen sich selbst (das war der Reviewer). Auf die Umsetzung
`446cc05d` sind **vier** weitere Läufe gefolgt: der Planner-Zug `d9a429d4` (§1, §4), die zwei
Implementer-Nachzüge `a1059000`/`0b6a9f06` (F-1, F-3, F-4-Kopplung) und der Architect-Lauf
`af9f9705` ([`ADR-0054`](../../docs/plan/adr/0054-emittierter-commit-traeger-skip-if-present.md),
`Proposed`). Geprüft ist der **vereinigte** Stand aller vier.

**Vorgeschichte, nicht neu gemessen.** Die zwei Review-Reports zu diesem Gegenstand (Runde 1:
1 HIGH · 3 MEDIUM · 1 LOW · 1 INFO, blockierend F-1 bis F-4; Runde 2: F-1/F-3/F-5/F-6 erledigt, F-4 offen allein wegen der
fehlenden **Adresse**) sind Zeitdokumente. Ihre Rot-Belege zitiere ich als solche und fahre sie
nicht nach; die Zähne dieses Slice habe ich an **einer** Stelle selbst nachgemessen, die dort
nicht steht (§3.6, `V-6`).

**An diesem Gegenstand nicht geschrieben (Negativ-Aussage).** Dieser Lauf hat an **keiner** Datei
des Gegenstands etwas verfasst: kein Satz, kein Kommentar, kein Testfall, keine Mutation, kein
DoD-Häkchen, kein Risiko-Ausgang, kein Register-Beleg, kein Review-Befund. Er hat gelesen, Sensoren
gefahren und Sonden in `/tmp`-Kopien gelegt. Die zwei Review-Reports und
[`ADR-0054`](../../docs/plan/adr/0054-emittierter-commit-traeger-skip-if-present.md) sind
**Eingang**, nicht Gegenstand dieses Laufs.

**Offengelegt — was dieser Lauf am Baum getan hat.** Am Repo ist **keine** Datei geändert worden;
alle Läufe mit Wirkung lagen in `/tmp`:

- `/tmp/verify-target` (`git clone` von `af9f9705`): die **emittierte** Fassung in das Ziel-Layout
  gelegt (`.githooks/commit-msg`, `tools/harness/commit-msg-traceability.sh`), `core.hooksPath`
  gesetzt, vier Commit-Versuche — der Rot-Beleg aus DoD (2), von mir selbst gelesen (§2.1).
- `/tmp/verify-mut` (Klon, `HOOKS_DIR ?= .githooks` → `.git/hooks`): `make test-go`, `make test-bats`
  (§3.6, `V-6`).
- `/tmp/verify-copy` (`git archive HEAD`), angelegt und nicht gebraucht.

Im Repo selbst liefen `make gates` (EXIT 0) und `make full-smoke` (EXIT 0). Nach allen Läufen:
`git status --porcelain` ohne Zeile.

**Ausgenommener Gegenstand — nicht geprüft, mit Grund.** Die **Closure** (§7, Beobachtungs-Register,
die drei §6-Ausgänge, `git mv` — Planner-Arbeit nach [`AGENTS.md`](../../AGENTS.md) §3.10), die
Wellen-Closure, die zwei benachbarten offenen Wellen, `harness/conventions/**` und
`docs/plan/adr/**` (Architect-Eigentum). Die fünf unteren DoD-Zeilen sind damit **nicht fällig**,
nicht unerfüllt.

**Zitier-Form:** Kennung statt Adresse für alles, was der Prozess bewegt — der Slice, seine vier
Läufe, die Geschwister. Ortsfeste Code-Pfade stehen als Inline-Code.

---

## Ergebnis in einer Tabelle

| §2 DoD-Punkt | Verdikt |
|---|---|
| **Liefer-Punkt 1** — das Ziel hat einen Träger an einer benannten Stelle, und der Anweisungssatz trägt die Konvention mit, an der er hängt | **erfüllt** (§2.1) |
| **Liefer-Punkt 2** — der Fall ist rot gesehen: ohne Kennung fällt die Message, mit Kennung nicht; Ausgabe und Exit-Code gelesen | **erfüllt** (§2.2) |
| **Liefer-Punkt 3** — Reichweite und Abhängigkeit stehen neben der Zusage | **erfüllt** in der einen, **nicht erfüllt** in der anderen Lesart des Satzes — die Entscheidung gehört dem Planner (§2.3) |
| `make gates` grün | **erfüllt** — EXIT 0 über `af9f9705` (§1.1) |
| Review durchgeführt, Report unter `docs/reviews/` liegt vor | **erfüllt** — zwei `Rolle Reviewer`-Läufe, Runde 2 ohne blockierenden Befund außer der Adress-Frage |
| **Doku-Update: die Prosa nennt die Fassung, die im Ziel liegt — Ort und Verdrahtung** | **erfüllt** (§2.4); die Aussage über die Idempotenz-Klasse ist ein Befund eigener Klasse (`V-1`) |
| Closure-Notiz mit Steering-Loop-Lerneintrag | **nicht fällig** — Planner ([`AGENTS.md`](../../AGENTS.md) §3.10) |
| Beobachtungs-Register fortgeschrieben | **nicht fällig** — Planner; §8 trägt dazu einen bewegten Zähler (`V-4`) |
| Jedes Risiko aus §6 trägt einen Ausgang | **nicht fällig** — Planner; drei Ausgangs-Platzhalter stehen unverändert |
| Die drei Paarungen sind getragen | **nicht fällig** — im Wellen-Repo die Welle-Closure |

**Verbleibende DoD-Verletzungen: keine, unter der Lesart, über die ich Liefer-Punkt 3 entscheide.**
Der Slice kann mit diesem Stand in die Closure — **eine** Frage ist vorher zu beantworten, und sie
gehört dem Planner: ob Liefer-Punkt 3 seinen Parenthetik-Einschub als Aufzählung führt (`V-3`).

**Befunde eigener Klasse (Verifier, keine DoD-Verletzung): fünf**, `V-1` bis `V-5` — §5.

---

## 1. Ist der Sensor gelaufen?

Drei Sensoren tragen die Zusagen der DoD: `make full-smoke` (Punkte 1 und 2 berufen sich auf ihn),
`make gates` (Gate-Punkt) und die zwei Mutationen, die ich für die Zuordnung aus §3.6 gefahren habe.
Alle sind gelaufen.

### 1.1 `make gates` — **EXIT 0**

```sh
make gates        # EXIT 0
#  baseline-verify: v6.8.0 OK — 54 Dateien (Integritaet + Vollstaendigkeit, netzlos)
#  d-check: 1448 Datei(en) geprüft, 0 Befund(e)
#  0 Zeilen `not ok` in der bats-Stufe
#  comment-claims: 63 Datei(en) geprueft, 0 Befund(e)
```

**Keine Erwartungswerte** ([`MR-025`](../../harness/conventions.md) Setzung 2) — die zwei Dateizahlen
wandern mit dem Baum; tragend sind die Nullen und das `OK`. Die Dateizahl des Doku-Gates liegt über
den in den Commit-Messages genannten (1445/1446), weil seither der zweite Review-Report und die zwei
ADR-Dateien dazugekommen sind.

### 1.2 `make full-smoke` — **EXIT 0**, und der Commit-Abschnitt ist gefahren

```sh
make full-smoke   # EXIT 0
#  full-smoke: Traeger im Ziel (golang): make hooks-install setzt core.hooksPath; ein Commit OHNE
#    Kennung faellt mit der Meldung der Pruefung und entsteht nicht, einer MIT Kennung geht durch,
#    und --no-verify umgeht den Traeger:
#  full-smoke:   commit-msg-traceability: keine Traceability-Kennung in der Commit-Message:
#  full-smoke: OK — COMMIT-KENNUNG IM ZIEL: .githooks/commit-msg liegt ausfuehrbar im Ziel und
#    reist mit dem Klon, seine Aktivierung nicht — make hooks-install setzt core.hooksPath und ist
#    kein Gate ...
```

Der Lauf ist der **Wellen-Closure-Trigger** *und* der Beleg, auf den sich die DoD beruft; dass er
über einem gebootstrappten Ziel läuft, ist damit beides zugleich erledigt. Die `--lang-go`-Variante
ist die einzige, die der Abschnitt fährt — das ist im Abschnitt selbst als Grenze notiert und durch
`TestCommitMsgTraeger_LiegtImZielUndRuftDiePruefungDortAuf` (Emit ohne Sprache) abgedeckt.

### 1.3 Was ich deshalb **nicht** gefahren habe

`make mutate` — Post-integration und nächtlich, wie der Auftrag es vorgibt. Stattdessen zwei
einzelne Mutationen in Klonen (§3.6), weil `make mutate` über seinen Beleg-Vorlauf
([`ADR-0035`](../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md))
nur den **gelisteten** Satz fährt und genau die Frage „was ist gelistet" der Gegenstand war.

---

## 2. Deckt der Sensor die Zusage?

### 2.1 Liefer-Punkt 1 — **erfüllt**

Der Punkt verlangt einen Träger an einer **benannten** Stelle, dazu die Konvention im
Anweisungssatz; sein Beleg ist ausdrücklich `make full-smoke` über einem gebootstrappten Ziel, nicht
eine Zeile im Emit-Code. Ich lese die vier Angaben am Artefakt nach, statt sie zu übernehmen:

| Gefordert | Steht in | Träger |
|---|---|---|
| der Träger an einem benannten Ort, ausführbar, an den Zielpfaden | `.githooks/commit-msg` ruft `../tools/harness/commit-msg-traceability.sh` über sein eigenes Verzeichnis; beide aus `enforceFiles()` | `make test-go` (`TestCommitMsgTraeger_LiegtImZielUndRuftDiePruefungDortAuf`, Zielorte **aufgelöst** statt zeichengleich), `make full-smoke` (liegt, x-Bit, realer Commit) |
| die Aktivierung als eigener Schritt | `harness/mk/hooks-install.mk` definiert `make hooks-install`, setzt `core.hooksPath`, ist **kein** Gate | `make test-go` (`TestHooksInstallFragment_IstKeinGateUndNenntDenTraeger`, gegen `regelnIn`/`gatesHuelle`), `make full-smoke` (`make -n gates` + die drei Commit-Versuche) |
| die Konvention im Anweisungssatz | `.claude/commands/implement-slice.md` nennt Hook, `make hooks-install` und die zwei Grenzen | `make test-go` (`TestCommitMsgAnweisung_NenntTraegerUndAktivierung`, über `emit.CommandFile`) |
| die Verdrahtung im Ziel | `include harness/mk/*.mk` im emittierten Aggregator (`internal/emit/makefile.go:27`) | `make test-go` (`makefile_test.go` hält die Zeile), `make full-smoke` |

Die **Konvention** ist hier nicht die `-F`-Aufrufform, sondern die **Aktivierung**: der git-eigene
Hook liest die Datei, die `git` ihm übergibt, gleichgültig welcher Aufruf sie erzeugt hat. Der
Anweisungssatz nennt genau sie. Dass die **Dogfood**-Fassung derselben Vorlage sie nicht trägt, ist
als F-6 entschieden und von §1 (Abgrenzung) gedeckt. Beleg für den Punkt ist der gefahrene
`make full-smoke` (§1.2).

### 2.2 Liefer-Punkt 2 — **erfüllt**, in eigener Messung

Der Punkt verlangt, dass die Message **ohne** Kennung im Ziel fällt und eine **mit** Kennung nicht,
mit **gelesener Ausgabe und Exit-Code**. Der E2E-Abschnitt fährt das und protokolliert es (§1.2);
**zusätzlich** habe ich die Kette in `/tmp/verify-target` in der emittierten Form selbst gebaut —
Klon von `af9f9705`, die zwei emittierten Vorlagen an ihren Zielpfaden, `git config core.hooksPath
.githooks` — und die Exit-Codes selbst gelesen:

```sh
git commit --allow-empty -m 'Smoke ohne Kennung'
# -> commit-msg-traceability: keine Traceability-Kennung in der Commit-Message:
#                Smoke ohne Kennung
#                Erwartet wird eine Kennung aus der Menge in der Zeile `patterns=` dieser Pruefung.
# EXIT_ROT=1 · HEAD danach unverändert (der Commit ist nicht entstanden)
git commit --allow-empty -m 'Bezug: ADR-0004'          # EXIT_GRUEN=0
git commit --allow-empty --no-verify -m 'Smoke ohne Kennung (Umgehung)'   # EXIT_UMGEHUNG=0
```

Damit ist die Zusage nicht nur über den E2E belegt, sondern **einmal von einer zweiten Messung**:
derselbe Träger, dieselbe Prüfung, derselbe Grund, derselbe Nicht-Entstehen des Commits. Die
Fehlermeldung nennt ihren Grund selbst — keine Meldung, die auf einen anderen Fall passt.

### 2.3 Liefer-Punkt 3 — **erfüllt** in der einen, **nicht erfüllt** in der anderen Lesart

Der Punkt lautet: „was der Träger **nicht** erreicht (**die zweite Hälfte des Constraints, die
Commits innerhalb von Werkzeugen**), ist benannt; der Träger braucht nichts über `bash + git` bzw.
das gepinnte Gate-Bild hinaus". Die zwei Teile stehen unterschiedlich da:

| Teil | Ergebnis |
|---|---|
| die zweite Hälfte des Constraints (Doku-Update bei berührtem öffentlichem Vertrag) | **benannt** — im Fragment („von einem Commit-Waechter nicht mechanisch pruefbar"), in der README, und im E2E per `grep -F` auf genau diesen Satz |
| die Abhängigkeit (`bash + git`, kein Docker/Netz/Gate-Bild) | **benannt** — Fragment („weder Docker noch Netz noch ein Gate-Bild"), Hook-Kopf („bash und coreutils, kein Docker, kein Netz"), README; der E2E prüft `weder Docker` mit |
| „die Commits innerhalb von Werkzeugen" als Grenze | **nicht benannt — und sie trifft den Träger nicht.** Gemessen: der emittierte Träger **weist einen Commit in der Form von `make slice-mv` ab**: `git commit -m 'slice-mv: slice-kennungs-waechter-geht-ins-ziel  open/ -> next/ (reiner Move)'` → `EXIT_WERKZEUG=1`, dieselbe Meldung (§2.2) |

**Zwei Lesarten, und ich entscheide über die erste:**

- Als **Beispiel-Aufzählung** gelesen („was der Träger nicht erreicht, *etwa* diese zwei Dinge") ist
  alles benannt, was wirklich nicht erreicht wird — der Punkt ist **erfüllt**.
- Als **Checkliste** gelesen ist die dritte Zeile nicht abhakbar: sie behauptet eine Grenze, die es
  nicht gibt, und kein Satz der Lieferung dürfte sie wahrheitsgemäß nennen.

Ich entscheide den Punkt über die erste Lesart und melde den Wortlaut als Befund eigener Klasse
(`V-3`); den Satz zu ziehen ist Planner-Arbeit, und die ausführende Rolle schreibt ihr
Abnahmekriterium nicht um ([`AGENTS.md`](../../AGENTS.md) §3.10). **Was an der Messung hängen
bleibt und unabhängig von der Lesart gilt:** der Träger erreicht die Werkzeug-Commits des Ziels
**und bricht sie ab**, sobald er aktiviert ist — der E2E-Abschnitt belegt das gegen sich selbst,
indem er sich ans **Lauf-Ende** legt („nach (b) prueft der Traeger JEDEN weiteren Commit dieses
Klons"). Die README trägt die Aussage eine Tabelle höher für den Dogfood („44 von 411", Adresse
`slice-werkzeug-commits-tragen-eine-kennung`); die **neue** Prosa und der Grenzblock des Fragments
nennen sie nicht (`V-3`).

### 2.4 Der Doku-Punkt — **erfüllt**

Verlangt sind **Ort** und **Verdrahtung** der Fassung, die im Ziel liegt. Die neue Prosa in
`harness/README.md` §Traceability nennt: den Träger `.githooks/commit-msg`, die Prüfung
`tools/harness/commit-msg-traceability.sh`, das Aktivierungs-Fragment `harness/mk/hooks-install.mk`
mit dem Ziel `make hooks-install`, den Aggregator-`include harness/mk/*.mk` und den Anweisungssatz
der Ziel-Fassung. Die Adress-Wahl (README statt `harness/sensors/commit-msg-check.md`) trägt: der
Sensor der Prüfung ist `make commit-msg-check`, ein Ziel, das das gebootstrappte Repo nach eigener
Aussage **nicht** bekommt. Die Zeile, die den E2E als Beleg nennt, ist korrekt — ich habe ihn
gefahren (§1.2).

**Eine Aussage derselben Prosa ist davon getrennt zu bewerten** und ist keine DoD-Verletzung, weil
§2 keinen Idempotenz-Punkt führt: „beide schreibt der Bootstrap kanonisch neu" — `V-1`.

### 2.5 §3.7 — beschreibt die Lieferung die Stelle oder ihren Vorgang?

**Kein Verstoß in den neuen Quellen.** `internal/emit/commitmsg.go`, die drei Vorlagen und die
Kopfkommentare von `test/commit-msg-emission.bats` und `internal/emit/commitmsg_test.go` tragen
**keine** Befund-Kennung, **keine** Slice-Nummer und **kein** Lauf-Protokoll:

```sh
grep -nE '(#|//).*(Review-Befund|Befund |slice-[0-9]|hier und heute|frueher)' \
  internal/emit/commitmsg.go internal/emit/templates/enforce/commit-msg-*.sh \
  internal/emit/templates/enforce/hooks-install.mk                        # keine Zeile
```

Die fünf Kommentar-Klassen (Zusage · Kopplung · Abgrenzung · Rang-Zeiger · Grenze) sind erkennbar
besetzt; die Mutationsfälle nennen ihre Herkunft in der zulässigen Form (`test/mutations/*.sh` ist
kein lebendes Artefakt im Sinne der Regel). Die eine Zahl mit Messwert-Charakter in der
Testdatei (`'slice-126'`) ist ein Beispiel-String des Grün-Falls, kein Messwert.

---

## 3. §3.6 — rot gesehen?

Der Slice legt **18 neue Wächter** an: 7 Go-Tests (`internal/emit/commitmsg_test.go`), 10 bats-Fälle
(`test/commit-msg-emission.bats`) und **eine** E2E-Sektion (`kennungs_traeger_im_ziel` in
`harness/tools/full-smoke.sh`). Gelistet sind **10** Mutationsfälle (`test/mutations/347`–`356`).

```sh
grep -c '^func Test' internal/emit/commitmsg_test.go            # 7
grep -c '^@test' test/commit-msg-emission.bats                  # 10
ls test/mutations/34[7-9]-*.sh test/mutations/35[0-6]-*.sh | wc -l   # 10
```

| Neuer Wächter | Mutationsfall |
|---|---|
| `TestCommitMsgTraeger_LiegtImZielUndRuftDiePruefungDortAuf` | `348` |
| `TestCommitMsgTraeger_ZielTraegtNurDenGitKanal` | `354` |
| `TestCommitMsgTraeger_NenntSeineZweiGrenzen` | `353` |
| `TestHooksInstallFragment_IstKeinGateUndNenntDenTraeger` | `349` |
| `TestHooksInstallFragment_TraegtDieReichweite` | `352` |
| `TestCommitMsgPruefung_IstDieEinzigeFassungDerMenge` | `351` |
| `TestCommitMsgAnweisung_NenntTraegerUndAktivierung` | `350` |
| bats *rot: eine Message ohne Kennung …* | `347` |
| bats *rot: der Grund nennt den Ort der Menge …* | `355` |
| bats *kopplung: die Klassen-Aufzählung im Kopf …* | `356` |
| bats *kopplung: die zwei bash-Fassungen der Kennungs-Menge …* | `340`/`341`/`342` (vorbestehend) |
| bats *kopplung: die Betreff-Ausnahme der zwei Fassungen ist dieselbe* | **keiner** |
| bats *rot: eine Kennung in einer Kommentarzeile zählt nicht* | **keiner** |
| bats *fail-closed: fehlende Datei und fehlender Aufruf enden mit Exit 2* | **keiner** |
| bats *grün: jede der vier Kennungs-Klassen …* | **keiner** (Richtung grün) |
| bats *grün: die Kennung darf im Rumpf stehen* | **keiner** (Richtung grün) |
| bats *grün: die Merge-/Revert-Ausnahme greift auf den Betreff* | **keiner** (Richtung grün) |
| E2E-Sektion `kennungs_traeger_im_ziel` (6 Zusagen, darunter die zwei Commit-Versuche) | **keiner** |

**Die Zuordnung ist für die tragenden Wächter dicht** — die sieben Go-Wächter und die drei
bats-Wächter, die eine Zusage dieses Slice tragen, haben je einen Fall, und der Review hat jeden
einzeln rot gelesen (Runde 1 §3). **Was offen bleibt, ist mit Kommando benannt:**

```sh
grep -rl 'exempt=' test/mutations/ | wc -l                          # 0
grep -l '^# expect:.*Betreff-Ausnahme' test/mutations/*.sh | wc -l   # 0
grep -l '^# files:.*full-smoke.sh' test/mutations/*.sh               # nur 190 (anderer Gegenstand)
```

**Von den 18 neuen Wächtern stehen 7 ohne Fall da.** Zwei davon tragen eine Zusage und sind deshalb
Befund, nicht Formalie — `V-6`.

---

## 4. §3.1 / `LH-QA-01` — behauptet der Slice ein Gate oder ein Ziel, das es nicht gibt?

**Nein, und ich habe die drei Ziele nachgesehen statt sie zu glauben:**

```sh
grep -n '^hooks-install:' Makefile                      # 207 (Dogfood)
grep -n '^full-smoke:' Makefile                         # 117
git grep -n 'harness/mk/\*\.mk' -- internal/            # makefile.go:27 (Ziel-Aggregator)
```

- `make hooks-install` existiert **beidseitig**: im Dogfood als Rezept (`Makefile:207`) und im Ziel
  als Fragment, das der Aggregator über `include harness/mk/*.mk` zieht. Es steht in **keiner**
  `gates`-Kette — der E2E prüft das mit `make -n gates`, `TestHooksInstallFragment_IstKeinGate…`
  mit der transitiven Hülle; der Dogfood-Zielkommentar sagt es selbst („NICHT in gates").
- `make full-smoke` existiert und ist in `harness/README.md` §Werkzeuge mit `kein Gate` geführt; die
  neue Prosa fügt **keine** Zeile in §Sensors hinzu. Das Doku-Gate-Modul `targets` läuft in
  `make gates` grün (§1.1) — es hätte eine `make X`-Zeile ohne Rezept gefärbt.
- Der Träger selbst ist kein Gate und keine halluzinierte Prüfung: er ist ein git-Hook, und die
  neue Prosa sagt an jeder Stelle, dass seine Aktivierung **nicht** mit dem Klon reist.

**Ein Ziel, das es nicht gibt, steht an einer Stelle dennoch — und sie ist als Grenze markiert:**
der E2E-Abschnitt ist als Werkzeug (kein Gate) gebunden, sein Beleg ist der gefahrene Lauf, nicht
sein Eintrag in `make gates` (§1.2). Das ist die deklarierte Betriebsform dieses Repos für
`full-smoke`, nicht ein neuer Befund.

---

## 5. Die Abweichung gegen `ADR-0054` — trägt die Lieferung, und wo steht die Grenze?

[`ADR-0054`](../../docs/plan/adr/0054-emittierter-commit-traeger-skip-if-present.md) (`Proposed`)
entscheidet in Festlegung 1: `.githooks/commit-msg` wird **skip-if-present** abgelegt; die zwei
übrigen Träger-Dateien bleiben konvergent. Die Lieferung sagt über denselben Pfad **das Gegenteil**,
an drei Stellen:

```sh
grep -n 'kanonisch neu' harness/README.md                                # "beide schreibt der Bootstrap kanonisch neu"
grep -n 'kanonisch neu' internal/emit/templates/enforce/hooks-install.mk  # "ist tool-eigen und wird bei jedem Bootstrap kanonisch neu geschrieben"
grep -n 'UNBEDINGT' internal/emit/commitmsg.go                            # "UNBEDINGT wie die uebrigen Fragmente"
grep -c 'skip-if-present' harness/README.md internal/emit/commitmsg.go \
  internal/emit/templates/enforce/hooks-install.mk \
  internal/emit/templates/commands/implement-slice.md                    # je 0
```

**Drei Feststellungen, in dieser Reihenfolge:**

1. **Es ist keine DoD-Verletzung.** §2 führt keinen Idempotenz-Punkt, und keine Zeile der Lieferung
   behauptet etwas über eine künftige Klasse — jede beschreibt, was **ist** (§3.7). Die Aussagen
   sind heute wahr und haben einen Wächter: `TestEnforce_Convergent` hält die konvergente Klasse
   über der ganzen Menge, Fall `49` färbt ihn rot.
2. **Die Abweichung ist adressiert, aber außerhalb der Lieferung.** `ADR-0054` Folgepflicht 1 nennt
   genau die Sätze, die gezogen werden müssen — „die Aufzählung, die ihn führt, und jeder Nachbar,
   der über *jede emittierte Datei wird konvergent geschrieben* fährt … der Kopf und die
   Fehlermeldung des Aktivierungs-Fragments … und der Commit-Absatz des emittierten
   Anweisungssatzes" — und benennt den Folge-Vorgang `slice-commit-traeger-wird-skip-if-present`.
   Die ADR schreibt in §Fitness Function selbst, dass der Ganz-Mengen-Test bis dahin **gegen ihre
   erste Zeile** läuft. Die Abweichung ist damit **entschieden und terminiert**, nicht stillgelegt.
3. **Was fehlt, ist die Grenze am Ort der Aussage.** Ein Leser der Lieferung — der Adopter liest
   `.githooks/commit-msg`, `harness/mk/hooks-install.mk` und die Command-Vorlage **in seinem Repo** —
   findet dort keinen Hinweis auf die Alternative; die Adresse liegt allein in einer `Proposed`-ADR,
   und der Folge-Slice ist noch nicht im Planning-Lifecycle angelegt
   (`ls docs/plan/planning/open/ docs/plan/planning/next/ | grep -c 'skip-if-present'` → 0). Die ADR
   erklärt diesen Zwischenstand für zulässig („bis der Vorgang im Planning-Lifecycle liegt, löst die
   Kennung hier auf"). **Kein Wächter** liest die Kommentar-Aussage gegen die ADR — dieselbe Lage,
   die `ADR-0054` §Fitness Function für ihre Meldung feststellt.

**Verdikt zu diesem Gegenstand: die Lieferung trägt, mit Adresse — und sie behauptet bis zum
Folge-Vorgang das Gegenteil der entschiedenen Klasse.** Das ist die zulässige Form, weil `ADR-0054`
die Sätze namentlich in einen benannten Vorgang übergeben hat; es als Befund festzuhalten ist
Pflicht, weil ohne die ADR kein Satz der Lieferung auf sie zeigt (`V-1`).

---

## 6. Sagt der Plan, was der Code tut?

In **beide** Richtungen geprüft, gegen `8c1b87b8..0b6a9f06` plus die zwei Nachbar-Läufe:

```sh
git diff --name-only 8c1b87b8 0b6a9f06 | wc -l                       # 23
git diff --name-only 8c1b87b8 0b6a9f06 -- internal/ | grep -vc '^internal/emit/'   # 0
git diff --name-only 8c1b87b8 0b6a9f06 -- Makefile | wc -l            # 0
```

**Gebaut, wie §3 es nennt:** die drei Vorlagen samt `internal/emit/commitmsg.go` und dem Eintrag in
`enforceFiles()`, die Command-Vorlage, `test/…` (bats + zehn Mutationsfälle). **Die gezogene §1-Grenze
hält:** alle acht Dateien unter `internal/` liegen unter `internal/emit/`, keine im Laufzeitpfad
(`cmd/`, `internal/gen`, `internal/wire`) — die Nachmessung des Reviewers bestätigt sich.

**Zwei Abweichungen, keine davon eine DoD-Verletzung:**

- **Geplant, nicht gebaut:** §3 nennt `Makefile` (`full-smoke`) als geändertes Artefakt — geändert
  wurde `harness/tools/full-smoke.sh` (+158 Zeilen), das Rezept (`Makefile:117-118`) ist unberührt.
  Dasselbe Ziel, andere Datei. Rein nachrichtlich.
- **Gebaut, nicht in §3:** `harness/README.md` (dort vom Doku-Punkt verlangt, nur nicht in der
  Datei-Tabelle geführt) und `internal/emit/enforce_test.go` (die Ausweitung von
  `TestEnforce_Convergent` auf die ganze Menge, aus Review-Befund F-4).

§8 nennt „alle berührten Sub-Areas GF"; die zwei vorgelagerten Prüfungen stehen dort, und die
Sub-Area-Wahl deckt den Vollzug (`*`, kein engeres Segment). **Eine Zahl in §8 ist bewegt** — `V-4`.

---

## 7. Befunde eigener Klasse (Verifier — **keine** DoD-Verletzung)

### V-1 (INFO) — die Idempotenz-Aussage der Lieferung ist die Gegenrichtung von `ADR-0054`

`harness/README.md`, `internal/emit/templates/enforce/hooks-install.mk` (Kommentar **und** die
Fehlermeldung des Rezepts, „den Traeger, den der Bootstrap schreibt") und `internal/emit/commitmsg.go`
sagen für `.githooks/commit-msg` konvergent zu, was `ADR-0054` Festlegung 1 als skip-if-present
entscheidet. Alle drei Sätze beschreiben den heutigen Stand und haben einen Wächter
(`TestEnforce_Convergent`, Fall `49`). Die Grenze steht **nicht** in der Lieferung, nicht in §6 und
nicht in §5 des Reports — ihre Adresse ist die ADR samt ihrem benannten Folge-Vorgang (§5).
**Addressee:** der Folge-Vorgang, den `ADR-0054` Folgepflicht 1 benennt; bis er im Planning-Lifecycle
liegt, ist die Aussage der Lieferung die einzige, die ein Adopter liest.

### V-2 (INFO) — der Folge-Vorgang zu `ADR-0054` ist allein in der ADR adressiert

`slice-commit-traeger-wird-skip-if-present` löst **nur** über die ADR auf — kein Slice in `open/`
oder `next/` trägt ihn, und §6 dieses Slice führt kein Risiko dazu. Die ADR erklärt den Zustand für
zulässig; für die Closure ist es eine Frage des Planner-Schnitts, nicht dieses Laufs. Benannt, damit
die Closure nicht den Eindruck erweckt, F-4 sei *adressiert* gleich *angelegt*.

### V-3 (INFO) — der DoD-Satz nennt eine Grenze, die der Träger nicht hat

§2 Liefer-Punkt 3 führt „die Commits innerhalb von Werkzeugen" unter dem, was der Träger **nicht**
erreicht. Gemessen: der emittierte Träger **erreicht** sie und bricht sie ab
(`EXIT_WERKZEUG=1`, §2.3); der E2E-Abschnitt belegt das gegen sich selbst, indem er sich ans
Lauf-Ende legt. Die zwei Lesarten des Satzes und meine Entscheidung stehen in §2.3. **Addressee:**
der Planner (Wortlaut des Abnahmekriteriums, [`AGENTS.md`](../../AGENTS.md) §3.10). Die Aussage
selbst steht in der README-Tabelle für den Dogfood („44 von 411"); die **neue** Prosa und der
Grenzblock des Fragments nennen sie nicht — dort steht nur die Grenze der zweiten
Constraint-Hälfte.

### V-4 (INFO) — §8 trägt einen bewegten Zähler und einen Satz, der nicht mehr gilt

§8 nennt für `BEO-ALL/waechter-abdeckung-haengt-an-uninstruierter-konvention` „**1×, offen**" und
sagt „Im Ziel gilt dieselbe Abhängigkeit". Beides gegen den Stand gemessen:

```sh
ls docs/plan/planning/observations/BEO-ALL/waechter-abdeckung-haengt-an-uninstruierter-konvention/evidence/*.md | wc -l   # 2
ls docs/plan/planning/observations/BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse/evidence/*.md | wc -l           # 1
```

Der zweite Beleg (`slice-215-…`) kam mit dessen Closure am 2026-09-15 dazu (Commit `7ba37f8b`), also
**nach** dem Schreiben des Plans (Datum 2026-09-14). Der Satz „im Ziel gilt dieselbe Abhängigkeit"
ist unabhängig davon falsch: der Träger des Ziels ist der git-eigene Hook, und der hängt — nach
[`ADR-0053`](../../docs/plan/adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md)
Festlegung 2 und dem Beleg `slice-215-…` — **nicht** an der uninstruierten Konvention; mein Nachbau
hat ihn ohne jeden Anweisungssatz feuern sehen (§2.2). **Derselbe Satz steht in §6 Risiko 2**
(„im Ziel gilt sie unverändert"). Beide §8-Formen sind regelkonform (die Zahl steht neben ihrem
Kommando, kein Erwartungswert); bewegt ist der Wert. **Addressee:** Planner — §8 ist der
Sichtungs-Schritt der Planung. Für die Schwelle relevant: der Eintrag steht bei **2×**, dieser
Slice zählt nach eigener Aussage nicht als Auftreten (der Gegenstand ist die emittierte Ebene).

### V-5 (INFO) — die DoD-Punkte 1 und 2 berufen sich auf einen Sensor, der **nicht** in `make gates` läuft

`make full-smoke` ist als „kein Gate" gebunden (README §Werkzeuge) und läuft in **keinem** lokalen
Gate-Lauf; der Beleg der zwei Liefer-Punkte hängt damit an CI bzw. am Wellen-Closure-Trigger. Das
ist die Betriebsform dieses Repos und keine Verletzung — die DoD hat den Träger richtig gewählt
(kein Go-Test fährt `git`), und ich habe ihn gefahren. Benannt, weil ein Leser der DoD „Beleg" als
„Gate" lesen könnte.

### V-6 (INFO) — sieben neue Wächter stehen ohne Mutationsfall da, zwei davon mit Zusage

Siehe §3. **Der belegte Fall:** die Kopplungs-Gruppe der `exempt=`-Zeile ist **unbewacht im
gelisteten Set** und hat trotzdem Zähne — in `/tmp/verify-mut2` die Dogfood-Zeile einseitig geändert:

```sh
sed -i "s@^exempt='^(Merge |Revert )'\$@exempt='^(Merge |Revert |WIP )'@" harness/tools/commit-msg-traceability.sh
make test-bats
# EXIT 2 · not ok 56 kopplung: die Betreff-Ausnahme der zwei Fassungen ist dieselbe
#          not ok 85 kopplung: Traeger und Config tragen dieselbe Betreff-Ausnahme
```

**Und der zweite, gewichtigere:** die E2E-Sektion ist der einzige Wächter der Verdrahtungs-Zusage
(„`core.hooksPath` auf `.githooks`") — kein gelisteter Fall nennt sie:

```sh
# /tmp/verify-mut: HOOKS_DIR ?= .githooks  ->  .git/hooks
make test-go      # EXIT 0
make test-bats    # EXIT 0 · 0 Zeilen `not ok`
```

Beide Zusagen sind damit **wahr und im gelisteten Set unbewacht**: `make mutate` würde den Verlust
dieser Zähne nicht melden. Nach §3.6 ist das zu benennen — nicht jede der sieben braucht einen Fall
(die drei Grün-Richtungen tragen keine Zusage), aber die zwei genannten tragen eine.

---

## Was dieser Lauf nicht prüfen konnte

- **`make mutate`** — Post-integration und nächtlich, wie der Auftrag es vorgibt. Gefahren sind zwei
  Einzelfälle in Klonen (§3.6); der Anteil der 18 neuen Wächter, den das gelistete Set abdeckt, ist
  gezählt (11 von 18), nicht durch einen Gesamtlauf bestätigt.
- **Die 10 gelisteten Fälle sind nicht neu gefahren.** Runde 1 und 2 haben sie einzeln rot gelesen
  und die Ausgaben zitiert; eine zweite Fahrt derselben Fälle wäre eine zweite Messung derselben
  Sache. Was ich **selbst** gelesen habe, steht in §2.2.
- **`make full-smoke` in seinen zwei anderen Bootstrap-Varianten** — der Commit-Abschnitt fährt nur
  `--lang-go`, und das steht dort als Grenze.
- **Die Kontext-Trennung der drei Rollen-Läufe** (Modul 8) — kein Sensor dieses Repos liest sie.
- **Die Closure** — §7, Register, die drei §6-Ausgänge, `git mv`: Planner. Die drei
  Ausgangs-Platzhalter des §6 stehen unverändert im Plan.
- **`harness/conventions/**`, `docs/plan/adr/**` und die Wellen-Closure** (samt den zwei benachbarten
  offenen Wellen): Auftrags-Grenze. `ADR-0054` ist als Eingang gelesen, nicht geprüft — der
  Accept-Übergang ist eine eigene Frage mit eigenem Beleg
  ([`ADR-0040`](../../docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)).

---

## Verdikt

**Die DoD trägt.** Liefer-Punkt 1 und 2 sind erfüllt, und beide über **gefahrene** Sensoren:
`make full-smoke` **EXIT 0** mit dem Commit-Abschnitt (§1.2) und — zusätzlich — der emittierte
Träger in eigener Messung in der Zielform, mit selbst gelesenen Exit-Codes: ohne Kennung `1` mit der
Meldung der Prüfung und **ohne entstandenen Commit**, mit Kennung `0`, `--no-verify` `0` (§2.2).
`make gates` ist **EXIT 0** (§1.1). Der Doku-Punkt nennt Ort und Verdrahtung und ist erfüllt (§2.4).
Der Review liegt in zwei Runden vor.

**Liefer-Punkt 3 trägt zwei Lesarten, und ich entscheide über die, die ihn erfüllbar hält** (§2.3):
alles, was der Träger wirklich nicht erreicht, ist benannt — der Satz trägt als Beispiel-Aufzählung.
Als **Checkliste** gelesen ist er nicht abhakbar, weil die dritte Zeile eine Grenze behauptet, die
der Träger nicht hat: **gemessen** weist der emittierte Carrier einen Commit in der Form von
`make slice-mv` mit Exit 1 ab. Den Wortlaut zieht der Planner (`V-3`).

**Die Abweichung gegen `ADR-0054` ist keine DoD-Verletzung — §2 führt keinen Idempotenz-Punkt —,
und sie ist über die ADR adressiert**, die die zu ziehenden Sätze namentlich und den Folge-Vorgang
`slice-commit-traeger-wird-skip-if-present` benennt. Die Lieferung behauptet bis dahin an drei
Stellen das Gegenteil der entschiedenen Klasse, ohne auf sie zu zeigen; das ist die zulässige Form
und bleibt als `V-1`/`V-2` stehen.

**§3.1/`LH-QA-01`: kein halluziniertes Gate und kein halluziniertes Ziel.** `make hooks-install` und
`make full-smoke` existieren beidseitig, der Ziel-Aggregator zieht das Fragment per Glob, und keiner
der zwei hängt an einer `gates`-Kette (§4).

**§3.6: 11 der 18 neuen Wächter haben einen gelisteten Fall, 7 keinen** — zwei davon tragen eine
Zusage und stehen mit ihrer Zahl und ihrem Kommando als `V-6`. Die E2E-Sektion ist der einzige
Wächter der Verdrahtungs-Zusage; die einseitige Änderung an `HOOKS_DIR` lässt `make test-go` und
`make test-bats` **beide bei EXIT 0** und würde von `make mutate` nicht gemeldet.

**Verbleibende DoD-Verletzungen: keine.** Offen sind drei Planner-Fragen — der Wortlaut von
Liefer-Punkt 3 (`V-3`), der bewegte Zähler und der Satz in §8/§6 (`V-4`), und der Schnitt des
Folge-Vorgangs zu `ADR-0054` (`V-2`) —, dazu die fünf nicht fälligen Closure-Pflichten.
Der Slice ist **nicht** merge-blockierend aus Sicht dieser Rolle.

Dieser Report ist ein **Lauf-Beleg** — er wird über Läufe hinweg nicht wieder gelesen und ersetzt
keine Closure (Modul 11).
