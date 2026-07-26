# Verifier-Report slice-051 — `artifact`/`release-artifacts` legen `DEST` an

Rolle: **Verifier (Modul 11)**, frischer Kontext, getrennt von Implementation und Review.
Prüfgegenstand ist **nicht** die Code-Qualität (das ist Modul 10), sondern die **DoD-Behauptung**
und die Plan-vs-Code-Übereinstimmung. Kanonische Rollen-Definition:
`.harness/baseline/v3.5.2/regelwerk/modul-11-verification.md` — *„Behauptung ohne Bestätigung ist
die häufigste Verifier-Lücke"*; eine DoD-Verletzung ist eine **Verifier-only-Klasse**.

**Datum:** 2026-07-26. **Slice:** `docs/plan/planning/in-progress/slice-051-artifact-dest-anlegen.md`.

**Range:** `14773e5..HEAD` (`1fe2496`). Slice-eigen: `c2349a0` (Plan) → `7277c43` (Move) →
`00bb7c3` (Impl) → `d3315f0` (Runde-1-Auflösung + Report) → `861631b` → `67388f7`
(Runde-2-Auflösung + Report). **Nicht** slice-eigen und **nicht** mitgeprüft: `1fe2496`, das
slice-052 schneidet.

**Mandat, abweichend von slice-048:** dieser Verifier durfte `make`-Targets **selbst fahren**
(inkl. `make mutate`, das gegen eine isolierte Kopie außerhalb des Repos arbeitet). Gegenprobe zur
Schaden-Präzedenz slice-044/047: `git status` war vor **und** nach allen Läufen leer, der
MR-003-Working-Tree-Hash ist unverändert (unten gemessen). Kein Produktivcode und keine Doku außer
dieser Datei wurden angefasst; nichts committet.

## Was ich selbst erhoben habe (statt Behauptungen nachzuerzählen)

- `make artifact DEST=<frisch, nicht existierend>` — real gefahren, zweimal (verschachtelter Pfad
  und der **wörtlich dokumentierte** Aufruf `DEST=./bin` im Repo selbst).
- `make release-artifacts DEST=<frisch, nicht existierend>` — **voller Sechs-Plattform-Bau** real
  gefahren. Der Beleg ist damit keine Ableitung, sondern eine Messung.
- **Gegenprobe am unreparierten Stand:** `git archive 7277c43` in eine Kopie außerhalb des Repos,
  dort derselbe Aufruf.
- `make gates` (Exit 0), `make mutate` (85 ok, 0 Befunde) — beide selbst gefahren, Logs erhalten.
- **Jede Mutation 86–89 einzeln** gegen je eine eigene Kopie, plus ein **Kontroll-Lauf ohne
  Mutation**, um zu sehen, welcher Wächter genau rot wird — die `make mutate`-Ausgabe allein
  beantwortet die Isolations-Frage nicht.
- **Eine Verstümmelung, die der Reviewer nur benannt hat** (N-1 Teilfall b), selbst gefahren.
- Messung des gepinnten bats-Images auf `make`/`docker`.
- Vollständig gelesen: `harness/tools/artifact-copy.sh`, `Makefile` (Ziel-Block),
  `test/release-matrix.bats`, `test/mutations/86…89`, `.github/workflows/release.yml` + `ci.yml`,
  `.gitignore`, `docs/user/benutzerhandbuch.md` §2/§11, `harness/tools/mutate.sh`,
  `harness/tools/smoke.sh` + `full-smoke.sh` (Köpfe), `AGENTS.md` §3.6/§4, beide Review-Reports.

---

## DoD Punkt für Punkt

| # | DoD-Punkt (§2) | Urteil | Mein Beleg |
|---|---|---|---|
| 1 | Nutzer-Befund behoben, Gegenprobe vor dem Fix Exit 2 | **BESTÄTIGT** | eigener Lauf Exit 0 + Binary da; Gegenprobe an `7277c43` reproduziert die Meldung **wörtlich**, make-Exit 2, nichts angelegt |
| 2 | Beide Targets, auch `release-artifacts` | **BESTÄTIGT** | voller Sechs-Plattform-Lauf nach nicht existierendem `DEST`: Exit 0, sechs Binaries |
| 3 | Logik als Skript, Recipes rufen nur — Grund: Testbarkeit | **BESTÄTIGT** | beide Recipes auf je einen `bash …/artifact-copy.sh`-Aufruf reduziert; bats-Image gemessen: **kein `make`, keine docker-CLI** |
| 4 | Verhaltens-Wächter in bats, lokal + CI ohne Daemon | **BESTÄTIGT** | sechs Wächter (96–101) im **eigenen** `make gates`-Lauf grün, 113 bats gesamt; `ci.yml:44` fährt `make gates` pro Push |
| 5 | Mutations-Fall, färbt seinen eigenen Wächter rot | **BESTÄTIGT** (übererfüllt) | `make mutate` 85 ok/0 Befunde; Einzel-Probe: 86→96, 87→99+100, 88→101, **89→nur 100** |
| 6 | CI-Workaround `mkdir -p dist` entfällt | **BESTÄTIGT** | `release.yml` ohne den Step; **kein** `mkdir` mehr in `.github/workflows/`; `dist` ist ungetrackt → jeder Release-Lauf fährt den Fall real |
| 7 | Handbuch-Hinweis deckt Parameter **und** Verzeichnis | **BESTÄTIGT** | §2-Hinweis nennt beides; §11 trägt 1.6/1.7 nach |
| 8 | `make gates` grün · `make mutate` grün | **BESTÄTIGT** | selbst gefahren: gates Exit 0 (d-check 197/0, 113 bats), mutate Exit 0 (85/0) |
| 9 | Closure-Notiz mit Steering-Loop-Eintrag | **NOCH NICHT FÄLLIG** | Slice liegt in `in-progress/`; §7 ist der Template-Rumpf. Erst beim `git mv` nach `done/` erfüllbar — **kein** Befund |

### 1. Der Nutzer-Befund ist behoben — **BESTÄTIGT**

**Fix-Seite, zwei unabhängige Läufe.**

- Frisches, **verschachteltes** Ziel (`…/verify-dest/bin`, beide Ebenen fehlten): `make artifact
  DEST=…` → **Exit 0**; `ls` zeigt `ai-harness-init` (6 373 538 B), `file` meldet
  „ELF 64-bit LSB executable, x86-64, statically linked, stripped". `mkdir -p` deckt also auch die
  mehrstufige Form, nicht nur die einstufige.
- **Der wörtlich dokumentierte Aufruf**, im Repo selbst gefahren (README und Handbuch Weg B nennen
  genau ihn): `bin/` existierte vorher nicht → `make artifact DEST=./bin` **Exit 0**,
  `./bin/ai-harness-init --help` läuft und meldet seine Usage. Danach `git status` **leer** und der
  MR-003-Working-Tree-Hash **byte-gleich** vorher/nachher
  (`369a8b64…e3b4`). Das ist zugleich der End-to-End-Beleg für die `.gitignore`-Auflösung (F-5).

**Gegenprobe-Seite.** `git archive 7277c43` (Stand **vor** `00bb7c3`) in eine Kopie außerhalb des
Repos; dort derselbe Aufruf mit fehlendem Zielverzeichnis:

```
invalid output path: directory "…/prefix-dest/bin" does not exist
make: *** [Makefile:64: artifact] Fehler 1
```

Prozess-Exit **2**, gemessen. Danach existiert das Zielverzeichnis **nicht** — es wird nichts
angelegt. Das deckt sich **wörtlich** mit §3 des Slice, inklusive der Zeilennummer `Makefile:64`.

Die von Review-Runde 1 (F-3) korrigierte Feinheit trägt und ist hier sichtbar: der **Rezept**-Status
ist 1 („Fehler 1"), der **Prozess**-Status von `make` ist 2. Die DoD-Formulierung („derselbe Aufruf
ist vor dem Fix Exit 2") meint den `make`-Aufruf und stimmt damit; der Skript-Kopf von
`artifact-copy.sh` erklärt die Differenz korrekt.

### 2. Beide Targets — **BESTÄTIGT**

Ich habe den vollen Sechs-Plattform-Bau **gefahren**, statt ihn zu argumentieren:
`make release-artifacts DEST=<frisch>/dist` (beide Pfad-Ebenen fehlten) → **Exit 0**,
`release-artifacts: OK — 6 Binaries in …`, und im Verzeichnis liegen
`ai-harness-init-{linux,darwin}-{amd64,arm64}` sowie `…-windows-{amd64,arm64}.exe`.

Dass der Defekt vorher **beide** Targets trug, ist ebenfalls gemessen und nicht übernommen: das
Rezept in `7277c43` prüft nur `test -n "$(DEST)"` und geht direkt in `docker create`/`docker cp` —
kein `mkdir` in der Schleife.

*Für den Fall, dass ein späterer Verifier den Sechs-Plattform-Bau nicht fahren will*, trägt auch die
strukturelle Kette: beide Recipes rufen **dasselbe** Skript mit derselben Argument-Form; das `mkdir
-p` steht **einmal** darin und ist nicht an eine Plattform-Bedingung geknüpft. Der bats-Wächter misst
dieses Skript direkt. Ein Sechs-Plattform-Bau fügt dieser Aussage nichts hinzu, was die
Schleifen-Iteration nicht schon hätte — er belegt zusätzlich nur, dass die **Verdrahtung** in der
Schleife stimmt. Genau das habe ich hier real gemessen.

### 3. Die Logik lebt als Skript, die Recipes rufen nur — **BESTÄTIGT**

`Makefile` nach dem Diff: `artifact` ist auf `@bash harness/tools/artifact-copy.sh
ai-harness-init:build "$(DEST)" ai-harness-init` reduziert, `release-artifacts` auf denselben
Aufruf mit Plattform-Tag und -Dateinamen. Die früheren Inline-Blöcke (`docker create` / `trap` /
`docker cp` / `docker rm`) sind vollständig verschwunden — je einmal pro Recipe, also die von
Runde 1 benannte Doppelung ist weg.

**Die Begründung ist gemessen, nicht angenommen.** Ich habe das gepinnte bats-Image
(`bats/bats@sha256:e8f18e0a…`) selbst befragt:

```
make: FEHLT      docker: FEHLT      bash: /usr/local/bin/bash      sed: /bin/sed      /tmp schreibbar: ja
```

Ein bats-Test **kann** dort also kein Recipe ausführen — die Extraktion ist die Bedingung der
Prüfbarkeit, nicht Ästhetik. Die Zusage des Slice und des Skript-Kopfes stimmt wörtlich.

*Nebenbeobachtung, kein Befund:* je Recipe bleibt eine Zeile Prüf-Logik inline
(`test -n "$(DEST)"`). Das ist der **Parameter**-Wächter, nicht die Kopier-Logik, die der DoD-Punkt
benennt; er ist vorbestehend und hat mit `release: DEST ist Pflicht (Exit 2 ohne)` seinen eigenen
Test. Kein Widerspruch zum DoD-Punkt.

### 4. Verhaltens-Wächter in bats — **BESTÄTIGT**

Aus **meinem eigenen** `make gates`-Lauf (nicht aus dem Report des Implementers):

```
ok 96  release: artifact-copy legt ein FEHLENDES Zielverzeichnis an
ok 97  release: artifact-copy schreibt auch in ein BESTEHENDES Zielverzeichnis
ok 98  release: artifact-copy verlangt alle drei Argumente (Exit 2)
ok 99  release: artifact-copy raeumt den Container auf
ok 100 release: artifact-copy raeumt auch auf, wenn das Kopieren SCHEITERT
ok 101 release: artifact-copy nimmt das uebergebene Image und den erwarteten Quellpfad
```

**Selbst gezählt:** `1..113` Tests gesamt (der Implementer nennt 113 nach 112 — stimmt). Sechs
Wächter für einen geforderten. Der Kette `make test` → `make gates` → CI pro Push bin ich
nachgegangen: `Makefile:48` fährt bats im gepinnten Image mit `--network none`, `gates:` (Zeile 217)
hat `test` als Prerequisite, `ci.yml:44` ruft `make gates` auf frischem Klon. Kein Daemon nötig —
der Lauf ist netzlos.

**Zum Risiko aus §6 („der Stub darf nicht zum Prüfgegenstand werden"):** der Stub bildet den realen
Fehlermodus ab (sein `cp` schreibt per `>` in den Zielpfad und fällt daher wie `docker cp`, wenn das
Verzeichnis fehlt), und die Assertions hängen an der beobachtbaren Wirkung (Verzeichnis da, Datei
nicht leer) bzw. am protokollierten Aufruf. Dass die Wächter nicht Selbstbestätigung sind, ist nicht
nur gelesen, sondern durch die Einzel-Proben unter Punkt 5 **gemessen**: jede Verstümmelung des
Skripts findet ihren Wächter.

### 5. Mutations-Fälle — **BESTÄTIGT**, über den DoD hinaus

`make mutate` selbst gefahren: **Exit 0**, `mutate: 85 ok, 0 Befund(e)`, isolierte Kopie unter
`/tmp/tmp.XsA2TMwucw/repo`, Host-Baum danach unverändert (`git status` leer). Die vier
slice-eigenen Zeilen:

```
mutate: ok  86-artifact-dest-mkdir           -> artifact-copy legt ein FEHLENDES Zielverzeichnis an rot
mutate: ok  87-artifact-cleanup-trap         -> artifact-copy raeumt den Container auf rot
mutate: ok  88-artifact-quellpfad            -> artifact-copy nimmt das uebergebene Image und den erwarteten Quellpfad rot
mutate: ok  89-artifact-cleanup-nur-erfolg   -> artifact-copy raeumt auch auf, wenn das Kopieren SCHEITERT rot
```

**Die Isolations-Frage beantwortet diese Ausgabe nicht** — sie sagt nur, dass der *erwartete*
Wächter fällt, nicht ob *nur* er fällt. Deshalb habe ich jede Mutation gegen eine **eigene Kopie**
angewandt und die vollständige `not ok`-Liste erhoben:

| Fall | Verstümmelung | rote Wächter (gemessen) |
|---|---|---|
| 86 | `mkdir -p` entfernt | **96**, dazu 99 und 101 (Kollateral: das Skript endet ≠ 0, beide prüfen `status -eq 0`) |
| 87 | `trap`-Zeile entfernt | **99 und 100** — beide Aufräum-Wächter |
| 88 | Quellpfad im Container verfälscht | **101**, sonst nichts |
| 89 | `trap` durch nachgestelltes `docker rm` ersetzt | **nur 100** |

Die Zusage des Implementers trifft damit **exakt** zu: 87 rötet beide, 89 **isoliert** den
Fehlerpfad-Wächter. Ohne 89 wäre Test 100 selbst unbewacht — die Begründung im Kopf von Fall 89
stimmt.

*Probe-Artefakt, benannt statt verschwiegen:* meine Kopien entstanden per `git archive` und tragen
kein `.git`, weshalb in **allen** Einzel-Proben zusätzlich `not ok 80 driver: die Kopie traegt den
Sensor-Bedarf inklusive .git` fällt. Ein **Kontroll-Lauf ohne jede Mutation** zeigt genau diesen
einen Fehlschlag — er ist Eigenschaft meiner Probe, nicht Wirkung einer Mutation. `make mutate`
selbst kopiert `.git` per `tar` mit und ist davon nicht betroffen (dort: 0 Befunde).

Die Nummer 86 als „nächste freie" stimmt: höchste vergebene war 85, heute sind es 85 Fälle bis
Nummer 89.

### 6. Der CI-Workaround ist weg — **BESTÄTIGT**

`- run: mkdir -p dist` ist aus `release.yml` entfernt; der `artifacts`-Job besteht aus Checkout →
`make release-artifacts DEST=dist` → `ls -l dist` → Upload. Ein `grep -rn "mkdir" .github/workflows/`
liefert **keinen** Treffer mehr — die Kompensation ist nicht an eine andere Stelle gewandert.

**Trägt die Behauptung „damit fährt jeder Release-Lauf den Fall real"?** Ja, und zwar aus drei
zusammen geprüften Gründen: `dist` ist **nicht** getrackt (`git ls-files dist` leer), der Job
checkt frisch aus (`actions/checkout` mit Default `clean: true`), und kein Step legt es vorher an.
Der erste Befehl, der `dist` berührt, ist das Target selbst. Der Workflow läuft auf Tag-Push und
per `workflow_dispatch` — der Fall ist also auch **vor** einem Tag anstoßbar.

*Nebenbeobachtung, kein DoD-Befund (siehe Abweichung A-3):* `/bin/` steht jetzt in `.gitignore`,
`dist/` nicht.

### 7. Der Handbuch-Hinweis — **BESTÄTIGT**

Vorher deckte er ausschließlich den fehlenden **Parameter**. Jetzt:

> **Hinweis:** Weg B baut den Stand, den Sie geklont haben […]. `make artifact DEST=./bin` verlangt
> die Angabe `DEST`. Ohne sie bricht der Befehl mit einer klaren Meldung ab. Den Zielordner müssen
> Sie **nicht** vorher anlegen — er wird erstellt, falls er fehlt.

Beide Fälle sind abgedeckt: **Parameter** („verlangt die Angabe `DEST`") und **Verzeichnis**
(„müssen Sie nicht vorher anlegen"). Die dritte, aus Runde 2 (N-3) stammende Klammer — dass Weg B
den geklonten Entwicklungsstand meint, nicht das im Kopf genannte `v0.1.0` — ist ebenfalls da. §11
trägt 1.6 (die Sach-Änderung mit Versions-Abgrenzung) und 1.7 (die Regel, wo Versions-Aussagen
hingehören) nach; die Handbuch-Version im Kopf steht auf 1.7. `README.md` nennt denselben Aufruf,
aber ohne den irreführenden Hinweis — dort gab es nichts zu korrigieren.

### 8. `make gates` grün — **BESTÄTIGT**

Selbst gefahren, **Exit 0**. Inhaltlich im Log: `baseline-verify` · d-check **197 Datei(en)
geprüft, 0 Befund(e)** · golangci-lint · Go-Build · **113 bats** ohne `not ok` · `go test ./...` in
allen fünf Paketen ok · shellcheck über `harness/tools/*.sh` **und** `test/mutations/*.sh` (deckt
also die neuen Dateien) · actionlint. `make mutate` ebenfalls Exit 0 (Punkt 5).

### 9. Closure-Notiz — **NOCH NICHT FÄLLIG**, explizit

Der Slice liegt in `in-progress/`; §7 trägt den unveränderten Template-Rumpf mit dem Kommentar
„Erst nach Abschluss füllen". Nach Modul 5 (Lifecycle als State Machine) und dem Closure-Trigger in
§5 ist die Notiz Teil des **Übergangs** nach `done/` und kann jetzt gar nicht erfüllt sein. Das ist
**kein** Befund und **keine** Teilerfüllung — der Punkt ist zum Prüfzeitpunkt nicht fällig. Er
bleibt offen bis zum Move-Commit.

---

## Sensor-Entscheidungen

**`make gates`, `make mutate`, `make artifact`, `make release-artifacts` — selbst gefahren.** Alle
vier oben belegt. Der Sechs-Plattform-Bau war nicht zwingend (siehe Punkt 2), aber billiger als die
Argumentation darüber; eine Messung schlägt eine Ableitung.

**`make smoke` — der Sensor ist gelaufen, die Begründung für sein Auslassen trägt nicht.**

Der Implementer hat `make smoke` ausgelassen mit dem Argument, es sei eine „echte Teilmenge von
`full-smoke`". **Diese Begründung ist durch die kanonischen Quellen des Repos widerlegt**, und zwar
zweimal wörtlich:

- `harness/tools/full-smoke.sh` (Kopf): „Abgrenzung zum Tier-2 `make smoke`: **jener** prüft die
  Bootstrap-SCHRITTE einzeln […]. **DIESER** fährt den ZUSAMMENGEFUEHRTEN `make -j gates` — die
  Sicht des echten Nutzers, **die `make smoke` bewusst NICHT nimmt**."
- `AGENTS.md` §4: dieselbe Aussage, aus der anderen Richtung — die Nutzer-Sicht, „die `make smoke`
  mit seinen getrennten Schritten bewusst nicht nimmt".

Die beiden Sensoren nehmen **verschiedene** Sichten; keiner enthält den anderen. Das ist genau die
Modul-11-Klasse: eine Behauptung, die niemand gegen die Quelle gehalten hat.

**Die Lücke ist im Ergebnis trotzdem geschlossen — von mir, nicht vom Implementer.** `make mutate`
fährt vor der ersten Mutation einen **Grün-Vorlauf je benutztem Sensor**; im Log meines Laufs steht

```
mutate: Gruen-Vorlauf make smoke (muss VOR der ersten Mutation gruen sein)
mutate: 85 Faelle …
```

Der Lauf ist über diesen Vorlauf **hinausgekommen**, und `mutate.sh` bricht bei rotem Vorlauf ab
(„make smoke ist schon ohne Mutation rot"). `make smoke` ist damit auf dem HEAD-Stand grün —
gemessen, gegen die isolierte Kopie. Zusätzlich fährt `ci.yml` `make smoke` als eigenen Job pro Push.

**Warum ich `make smoke` nicht noch einmal separat gefahren habe:** die Aussage lag nach dem
`mutate`-Lauf bereits vor, und der von diesem Slice geänderte Pfad ist in **beiden** Smokes
derselbe Schritt 1 — `make artifact DEST="$(mktemp -d)"`, also der Fall **bestehendes**
Verzeichnis. Genau den decken bats-Test 97 und mein realer `release-artifacts`-Lauf ab. Ein weiterer
Lauf hätte keine neue Information über diesen Slice erzeugt.

**`make full-smoke` — bewusst nicht gefahren, begründet.** Er berührt `artifact-copy.sh` ebenfalls
nur über Schritt 1 mit bestehendem `DEST`; sein übriger Umfang (Bootstrap-E2E, emittierte Gates)
liegt außerhalb dessen, was slice-051 anfasst. Der Implementer hat ihn gefahren, `ci.yml` fährt ihn
pro Push. Ein ~10-minütiger Lauf hätte hier keine DoD-Aussage getragen. Diese Entscheidung steht
hier, statt still zu bleiben — ein nicht gelaufener Sensor ist ein Befund, kein Formfehler.

**Zusätzlicher Sensor, den ich selbst gebaut habe.** Die Aufräum-Zusage („der Container wird immer
aufgeräumt") habe ich nicht nur über den Stub geprüft, sondern gegen den **echten** Daemon: nach
meinen sieben realen `artifact-copy.sh`-Aufrufen (1× `artifact`, 6× `release-artifacts`) meldet
`docker ps -a` **null** Container aus `ai-harness-init`-Images. Der `trap` räumt real auf, nicht
nur im Protokoll der Attrappe.

---

## Plan-vs-Code

**Geliefert wurde alles, was §3 plant** — die Tabelle Zeile für Zeile:

| Geplant | Geliefert | Beleg |
|---|---|---|
| `harness/tools/artifact-copy.sh` neu | ja | 41 Zeilen, `mkdir -p` + `docker create`/`cp`/`trap` |
| `Makefile` update | ja | beide Recipes auf einen Skript-Aufruf reduziert |
| `.github/workflows/release.yml` update | ja | `mkdir -p dist` entfernt |
| `test/release-matrix.bats` update | ja | sechs neue Wächter (96–101) |
| `test/mutations/86-artifact-dest-mkdir.sh` neu | ja | rötet 96 |
| `docs/user/benutzerhandbuch.md` update | ja | §2-Hinweis + §11-Einträge 1.6/1.7 |

**Nichts aus dem Plan fehlt.** Auch die geplante **Reihenfolge**-Zusage ist eingehalten worden,
soweit am Baum prüfbar: der Wächter ist gegen den unreparierten Stand rot — ich habe das unabhängig
von der Commit-Historie hergestellt (Mutation 86 → Test 96 rot; und die Gegenprobe an `7277c43`).
Der von Runde 1 als F-4 benannte Makel betrifft die **Formatierung** des Rot-Zitats in der
Commit-Message von `00bb7c3`, nicht die Sache; kein Artefakt im Baum trägt das Zitat weiter.

**Geändert, ohne im Plan zu stehen** — vier Posten, alle nachvollziehbar, keiner im Widerspruch:

1. `.gitignore` (`/bin/`) — Auflösung von Review-Befund F-5. Bewertung unten.
2. `test/mutations/87`, `88`, `89` — Auflösungen von F-1, INFO-1 und N-1. Additiv; sie erhöhen die
   Abdeckung des in diesem Slice entstandenen Skripts. Der DoD nennt nur 86; drei Fälle mehr sind
   keine Abweichung vom Plan, sondern dessen Ausbau durch die Review-Runden.
3. `docs/plan/planning/in-progress/roadmap.md` — Planungs-Buchführung (Slice-Zeile mit Trigger und
   Closure-Kriterium). Normale Mechanik.
4. Die beiden Review-Reports unter `docs/reviews/` — Prozess-Artefakte.

**`spec/lastenheft.md` ist über alle Slice-Commits unberührt:** `git diff 14773e5..HEAD --
spec/lastenheft.md` ist **leer**. Der Slice hat keine Anforderung angefasst — korrekt, denn er
behebt einen Defekt gegen eine bestehende Zusage (`LH-QA-04`), er verschiebt keine.

**Die `.gitignore`-Änderung — löst sie das Problem, und wie weit reicht sie?**

- *Sie löst es, gemessen:* der dokumentierte Aufruf `make artifact DEST=./bin` im Repo hinterlässt
  `bin/ai-harness-init`, und danach ist `git status` leer **und** der MR-003-Working-Tree-Hash
  byte-gleich zu vorher. Ohne den Eintrag machte die eigene Anleitung den Arbeitsbaum schmutzig und
  verschöbe den Stop-Hook-Hash — genau die von F-5 benannte Wirkung.
- *Ihre Reichweite ist eng und gewollt:* der führende Schrägstrich verankert am Repo-Wurzel.
  Gemessen: `git check-ignore -v bin/x` → Treffer `.gitignore:11`; `internal/bin/x` und `foo/bin/x`
  → **kein** Treffer. Es gibt heute weder eine getrackte Datei unter irgendeinem `bin/` noch
  überhaupt ein Verzeichnis dieses Namens im Baum — der Eintrag verdeckt also nichts Bestehendes.
- *Restreichweite, benannt:* legte jemand künftig ein **Quell**-Verzeichnis `bin/` an der Wurzel an,
  bliebe es still ungetrackt. Der Kommentar über dem Eintrag nennt Zweck und Herkunft, was diese
  Falle sichtbar hält. Vertretbar.

---

## Abweichungen

Keine davon ist eine DoD-Verletzung; alle sind unterhalb der DoD und wurden bei der Verifikation
sichtbar.

**A-1 — Die zweite Hälfte von N-1 ist offen, und ich habe sie rot gesucht und **grün** gefunden.**

Review-Runde 2 benennt in N-1 **zwei** Verstümmelungen, die grün blieben: (a) `trap` durch ein
nachgestelltes `docker rm` ersetzt und (b) **das Trap-Ziel auf eine fremde ID gelegt**
(`docker rm -f falsche-id`) — der erzeugte Container bliebe liegen. Aufgelöst wurde (a): neuer Test
100, neuer Fall 89, beides von mir bestätigt. Teilfall (b) ist in der Auflösung nicht erwähnt.

Selbst gemessen, gegen eine eigene Kopie mit
`trap 'docker rm -f falsche-id >/dev/null 2>&1' EXIT`: **kein einziger** `artifact-copy`-Wächter
fällt (nur das oben erklärte Probe-Artefakt 80). Die Assertion „der Container wird immer
aufgeräumt" — im Skript-Kopf **und** in `Makefile:61` — hat damit weiterhin eine Mutation, die grün
bleibt. Das ist die Klasse aus `AGENTS.md` §3.6.

Einordnung: **außerhalb der DoD** (kein DoD-Punkt fordert diesen Wächter), **LOW**, und die
überschießende Zusage stammt aus slice-029, nicht aus diesem Slice — das hat der Reviewer selbst so
eingeordnet. Sie ist aber **offen** und war es auch nach der Auflösung; ein Folge-Slice oder ein
Nachtrag (Wächter auf `rm -f cid-fake` pinnen, wie es Test 101 für den Quellpfad bereits tut) würde
sie mit zwei Zeilen schließen.

**A-2 — Die Begründung für den ausgelassenen `make smoke` ist sachlich falsch.**

Siehe Sensor-Entscheidungen. Das **Ergebnis** ist sauber (`make smoke` ist grün, von mir über den
`mutate`-Grün-Vorlauf gemessen), die **Behauptung** ist es nicht: `full-smoke.sh` und `AGENTS.md` §4
sagen beide wörtlich das Gegenteil einer Teilmengen-Beziehung. Für die Pre-completion-Checkliste
(Modul 9 Schritt 8) heißt das: hier wurde ein Sensor mit einer Begründung übersprungen, die man an
zwei Stellen im eigenen Repo in einer Minute hätte widerlegen können. Kein DoD-Punkt betroffen,
aber genau die Lücke, die Modul 11 fangen soll.

**A-3 — `/bin/` ist jetzt ignoriert, `dist/` nicht.**

Mit dem Wegfall von `mkdir -p dist` legt `make release-artifacts DEST=dist` das Verzeichnis selbst
an. Lokal gefahren hinterließe das ein **ungetracktes** `dist/` und verschöbe den
MR-003-Working-Tree-Hash — dieselbe Klasse wie F-5, ein Verzeichnis weiter. Reichweite ist gering:
`DEST=dist` steht nur in `release.yml` (dort auf einem Wegwerf-Runner), keine Nutzer-Doku schreibt
den Aufruf vor. Kein Befund gegen die DoD; ein Ein-Zeilen-Nachtrag, falls jemand das Target lokal
fährt.

**A-4 — Nachrichtlich, kein Befund:** beide Review-Reports reisen im **selben** Commit wie die von
ihnen ausgelösten Auflösungen (`d3315f0`, `67388f7`). Ein Leser kann „berichtet" und „aufgelöst"
nicht an der Commit-Grenze trennen. Das ist innerhalb dieses Slice konsistent gehandhabt und
entspricht dem hier üblichen Muster; ich notiere es nur, weil es die Rot-vor-Grün-Nachvollziehbarkeit
aus der Historie in die Commit-Messages verlagert (dieselbe Wurzel wie F-4).

**Mitreisend, aus dem Slice selbst (§6, kein Befund):** `v0.1.0` behält den Fehler; der Fix erscheint
erst in einem Folge-Release. Der Vorgang ist mit slice-052 bereits geschnitten (`1fe2496`, außerhalb
dieses Prüfumfangs).

---

## Gesamt-Urteil

**DoD BESTÄTIGT.**

Acht der neun DoD-Punkte sind **bestätigt** — jeder mit einem Beleg, den ich selbst erhoben habe,
nicht mit dem behaupteten. **Kein Punkt ist teilweise erfüllt, keiner widerlegt.** Der neunte
(Closure-Notiz) ist zum Prüfzeitpunkt **nicht fällig**: er entsteht per Definition beim Übergang nach
`done/`.

Der Kern der Sache hält der schärfsten Probe stand, die ich fahren konnte: der Nutzer-Aufruf ist
**wörtlich in seiner dokumentierten Form** grün, der unreparierte Stand ist **wörtlich in seiner
gemeldeten Form** rot, beide Targets sind real gefahren (inklusive des vollen Sechs-Plattform-Baus),
und jeder der vier Wächter fällt unter **seiner eigenen** Mutation — 89 sauber isoliert, wie
behauptet.

Die drei Abweichungen liegen unterhalb der DoD. A-1 ist die einzige mit Substanz: eine
§3.6-Zusage, deren zweite Verstümmelung weiterhin grün bleibt — vom Reviewer benannt, in der
Auflösung nicht adressiert. A-2 ist ein Beleg-Fehler ohne Ergebnis-Folge und gehört in den
Steering-Loop-Eintrag der Closure-Notiz: die Sensor-Abgrenzung `smoke` vs. `full-smoke` steht an zwei
Stellen im Repo und wurde trotzdem falsch behauptet.

**Der Closure-Trigger (§5) ist aus Verifier-Sicht erfüllt**, soweit er diese Rolle betrifft: DoD
vollständig (bis auf den nicht fälligen Punkt 9), Review konform in Runde 2, Verifikation bestätigt
die DoD, `make gates` und `make mutate` grün — von mir gefahren —, und der bats-Wächter ist gegen den
unreparierten Stand rot gesehen. Offen bleiben allein die beiden Schritte, die den Übergang selbst
ausmachen: `git mv` nach `done/` und die Closure-Notiz mit Steering-Loop-Eintrag.
