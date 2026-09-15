# Review-Report: slice-174-archivierung-emittieren — Runde 2 — 2026-09-15

**Review-Art:** Code-Review gegen **Plan + ADRs + Hard Rules** (Modul 10 §Drei Review-Arten).
Gegenstand ist der Nachzug auf die drei Befunde der ersten Runde: eine Marker-Umschrift in einer
Emissions-Vorlage, ein neuer Go-Mutationsfall, ein neuer E2E-Abschnitt, sechs Konjunktiv-Umschriften.
**Kein DoD-Review** — DoD-/Spec-Konformität prüft der Verifier (Modul 11, anderer Eingabe-Kontext).

**Gegenstand:** Commit `c18b9c74` (Rolle Implementer), 9 Dateien, +96/−32, über dem
Umsetzungs-Commit `3e535c3c`. Gelesen, aber **nicht** Gegenstand: `20a29cbd` (ADR-0051, `Proposed`),
`d0610fb5` (Erinnerungs-Slice), `b8456062` und `cf13765e` (Runde 1).

**Kein Self-Review:** dieser Lauf hat an keinem der geprüften Commits geschrieben. Kein Befund
dieses Reports ist aus der Commit-Message oder aus dem Implementer-Bericht übernommen — die dort
behaupteten Rot-Belege (Fall `339`, der neue E2E-Abschnitt `(c2)`, die Vorbedingung der
Nicht-Gate-Zusicherung) sind einzeln nachgefahren und ihre **Meldungen gelesen** (§1, §3, §4).

**Skill:** `.harness/skills/reviewer.md` @ `0565f274` (2.0.0) · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** deepseek-v4.1-flash:cloud[1m] · **Datum:** 2026-09-15

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

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- Slice-Plan `slice-174-archivierung-emittieren` (§1 Ziel und Abgrenzung, §2 DoD, §3 Plan, §4
  Trigger, §5 Closure-Trigger, §6 Risiken)
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules; tragend hier §3.6, §3.7, §3.9)
- [`ADR-0033`](../../docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md) (Festlegung 4 und 5,
  Folgepflicht 8) · [`ADR-0028`](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  (§Was hier NICHT entschieden ist, Folgepflicht 3) · [`ADR-0007`](../../docs/plan/adr/0007-bootstrap-phasen.md)
  (Idempotenz-Klassen-Tabelle) · [`ADR-0051`](../../docs/plan/adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md)
  (`Proposed`; Festlegung 1, §Konsequenzen Folgepflicht 3)
- [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) ·
  [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) §Adaptierbar ·
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- Vorherige Findings am **selben Modul** (emittierte Mechanik, E2E-Beleg, Anker aus der Prosa,
  Kommentar-Klassen): `2026-09-15-slice-174-archivierung-emittieren` (Runde 1, **derselbe
  Gegenstand**) · `2026-09-14-slice-vorlauf-waechter-geht-ins-ziel` · `2026-09-13-slice-073-emittierte-doc-gate-module-runde-5`
  — daraus die wiederkehrenden Klassen `test-anker-aus-der-prosa-erfuellbar` und
  `kommentar-im-konjunktiv-ueber-die-verworfene-alternative`

---

## Verdikt über die Befunde der Runde 1

Die Runde-1-Befunde werden **nicht** erneut gemeldet, sondern gegen den Nachzug gehalten. Ein Wort
je Befund steht im §Summary-Block; die zwei, die stehen bleiben, sind unten als F-1 und F-2
**neu** gefasst, weil der Nachzug an ihren Fundorten etwas verändert hat.

| Runde-1-Befund | Verdikt dieses Laufs |
|---|---|
| **F-1 HIGH** (Rollen-Konflikt, `close-welle.md`) | **behoben — auf dem Konflikt-Pfad entschieden, und die Entscheidung trägt die Änderung.** Das gewählte Verdikt ist das dritte des Konflikt-Pfads (*„Lockerung legitim, aber undokumentiert"*, `v6.8.0` · `regelwerk/modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz), und beide Hälften seines Übergabe-Artefakts existieren: [ADR-0051](../../docs/plan/adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md) (der Architect, `20a29cbd`) und der Erinnerungs-Slice (der Planner, `d0610fb5`). Der Satz der Vorlage bleibt damit **stehen**; die Rolle des schreibenden Laufs ist nicht mehr der Gegenstand, sondern die **Lücke**, die die ADR benennt. **Die eine Bedingung, die daran hängt, gehört in die Closure und nicht in ein Finding:** ADR-0051 steht auf `Proposed`, und ihre §Konsequenzen Folgepflicht 1 sagt *„der Slice schließt **nicht vor seiner Annahme**"* — die Annahme braucht eine Reviewer-Runde an der ADR (ihr §Acceptance-Trigger). Kein Gate liest diesen Zustand; §Verdikt nennt ihn darum als Closure-Bedingung. |
| **F-2 MEDIUM** (`ANPASSEN`-Marker lädt zum Umbenennen ein) | **nicht behoben** — die Einladung steht noch da, sie ist nur um eine Selbstwidersprechung ergänzt. Einzelheiten als **F-1** unten. |
| **F-3 LOW** (Konjunktiv über die verworfene Alternative) | **teilweise behoben** — die zwei genannten Fundorte sind weg (§2), **drei Fundorte derselben Form bleiben im selben Delta** (§5). Als **F-2** unten. |
| **F-4 INFO** (Negativ-Prüfung ohne Vorbedingung auf ihren Prüfbereich) | **behoben und gemessen** — die neue Vorbedingung fällt über einer leeren Kette (§4), und ihre drei Marker sind **Rezept-Zeilen**, die die reale Kette trägt (§4.2). |

---

## Eigene Messungen

Jedes Kommando dieses Abschnitts ist in diesem Lauf gefahren. Wo eine Zahl steht, steht das Kommando
daneben, das sie liefert; **keine Erwartungswerte**
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).

### 1. Mutation `339` selbst gefahren — rot mit der behaupteten Ursache, und die Meldung gelesen

```text
$ bash test/mutations/339-anleitung-nennt-ein-ziel-das-es-nicht-gibt.sh && git diff --stat
 internal/emit/templates/commands/close-welle.md | 2 +-
$ make test-go 2>&1 | grep -E 'FAIL|behauptet'
--- FAIL: TestEmittierteDokumente_NurInitInvarianteZiele (0.01s)
    emitteddocs_test.go:188: emittiertes Dokument .claude/commands/close-welle.md behauptet
      `make archiv-welle` — die Init-Phase schreibt nur [archive-welle baseline-verify doc-commits
      doc-immutable docs-check gates help history-range-guard record-gates span-clean span-report]
GOTEST_EXIT=2
$ git checkout -- internal/emit/templates/commands/close-welle.md && git status --porcelain   # leer
```

**Der Fall trifft die Verdrahtung, die der Aufrufer benutzt, und das ist hier nachgemessen, nicht
angenommen.** Er mutiert die **Quell**-Vorlage; der Wächter emittiert den Dokument-Satz über den
echten Emitter (`emitDokumentSatz` → `emit.Commands`) und liest die Ziel-Menge **dynamisch** aus den
Fragmenten (`emit.InitInvariantTargets` → `initFragments`), nicht aus einer gepflegten Liste — die
Fehlermeldung nennt die gelesene Menge, und in ihr steht `archive-welle`. Die vom Fallkopf
behauptete Form *„beide Seiten gelesen, keine gepflegte Liste"* ist damit an der Ausgabe belegt.
Nachgefahren ist auch, dass die Command-Emission **nicht** neutralisiert — `NeutralizeMakeClaims`
läuft allein in `Templates` und `RootReadme` (`grep -rn 'NeutralizeMakeClaims' --include=*.go
internal/`), so dass ein Anspruch der Anleitung den Wächter überhaupt erreichen kann.

### 2. Die zwei Fundorte des Runde-1-LOW sind inhaltlich weg

```text
$ sed -n '15,19p' internal/emit/archivierung.go
// selbst. Der Traeger liegt gitignored, ein frischer Klon hat ihn also nicht — und
// das Kommando, das ihm das sagt, liegt hier und nicht bei ihm.
$ sed -n '83,87p' internal/emit/archivierung_test.go
// Das Fragment ist die Stelle, an der ein Ziel liest, dass die Archivierung nicht
// eingetreten ist — und der Fall des frischen Klons ist der, fuer den der Satz
// dasteht.
```

Beide Sätze beschreiben jetzt den Zustand. **Keine Aussage ist dabei verlorengegangen:** die
Zusage „das Kommando liegt beim Fragment, nicht beim Träger" trägt weiter, und die
`t.Errorf`-Umschriften (in §2 mitgelesen) sind Aussage für Aussage deckungsgleich — die einzige gefallene
Klausel ist der Vergleich *„ein Gate über ihr wäre eines über leerem Prüfbereich"*
(`archivierung.mk`) bzw. sein Rest in einer Fehlermeldung; der Grund selbst steht in beiden
Fassungen. Die Klausel wird **nicht** als Befund gemeldet: die Aussage trägt.

### 3. Mutation `338` — der umgeschriebene Mechanismus gegen GNU make gehalten

Der Nachzug hat genau den Absatz umgeschrieben, der erklärt, warum der Fall **genau eine** Zeile
löscht (`test/mutations/338-archivierung-ohne-traeger-schweigt.sh:13-16`). Seine neue Fassung
behauptet zwei Dinge über die Datei; beide sind nachgemessen falsch:

```text
$ tail -1 internal/emit/templates/enforce/archivierung.mk | od -c | tail -2
0000100   i   e   d   e   r       a   b   .   "  \n
$ grep -n '\\$' internal/emit/templates/enforce/archivierung.mk
31:	echo "archive-welle: der Traeger liegt nicht ($(ARCHIV_CARRIER)) …"; \
$ cut -c1-40 <(sed -n '28,32p' internal/emit/templates/enforce/archivierung.mk)
	@for c in "$(ARCHIV_CARRIER)" "$(ARCHIV
		if [ -x "$$c" ]; then exec "$$c" archi
	done; \
	echo "archive-welle: der Traeger liegt 
	echo "archive-welle: ein erneuter Lauf 
```

(a) Die **letzte** Zeile trägt **keine** Fortsetzungsmarke; die Marke trägt die Zeile, die der Fall
löscht. (b) Die behauptete Folge — *„ohne sie endet die Rezept-Fortsetzung im Leeren (ein
make-Fehler …)"* — tritt nicht ein: über der kopierten Rezept-Form endet `make` mit **0**.

```text
$ printf 't:\n\t@for c in x; do \\\n\t\tif true; then echo "$$c"; fi; \\\n\tdone; \\\n' > /tmp/mkprobe/Makefile
$ make -C /tmp/mkprobe t; echo "EXIT=$?"
x
EXIT=0
```

Die Begründung, die sie stützen soll („genau eine Zeile fällt"), trägt also nicht: **auch zwei**
gelöschte Zeilen ließen das Rezept heil und färbten den Sensor aus dem **richtigen** Grund rot.
Der Fall selbst bleibt richtig — nur sein Kopf sagt über sich selbst etwas Falsches. Einzelheiten
als **F-3** unten.

### 4. Der neue E2E-Abschnitt `(c2)` und die neue Vorbedingung — am gebootstrappten Ziel gemessen

```text
$ make full-smoke > /tmp/fullsmoke-review2.log 2>&1; echo "FULLSMOKE_EXIT=$?"
FULLSMOKE_EXIT=0
$ grep -n 'unbekanntes Ziel\|FEHLER' /tmp/fullsmoke-review2.log
292:full-smoke: unbekanntes Ziel (golang): make archiv-welle endet laut und nennt den Namen — die
     Anleitung zeigt auf das Ziel, das das Fragment fuehrt:
293:full-smoke:   make[1]: *** Keine Regel, um „archiv-welle" zu erstellen.  Schluss.
$ grep -c 'full-smoke: FEHLER' /tmp/fullsmoke-review2.log   # 0 Treffer
```

**`(c2)` mißt die Stelle, die der Aufrufer benutzt**, und baut nichts nach: sie ruft `make` im
**gebootstrappten Ziel** mit einem Namen, den kein Fragment dieses Repos führt. Der Exit-Code der
Laufspitze (**0**) ist die tragende Zeile; die zwei Fehlschlag-Zweige von `(c2)` exitieren mit 1 und
liegen darum vor ihm. Beide Einordnungen sind gelesen: der Abbruch ist **laut** und **nennt den
Namen** — genau der Preis, den der Marker behauptet.

**4.2 Die drei Marker der Vorbedingung sind Rezept-Zeilen, und die reale Kette trägt sie.** Der
Commit nennt den Grund für die Form (ein Ziel-Name fiel im Ziel rot); gemessen ist er an den
Fragmenten, die das Ziel bekommt:

```text
$ grep -rn 'record-gates.sh\|baseline-verify.sh' internal/emit/templates/ internal/emit/*.go
internal/emit/templates/enforce/enforce.mk:8:	@bash tools/harness/record-gates.sh
internal/emit/baseline.go:37:		@bash tools/harness/baseline-verify.sh
$ grep -c 'docker run' d-check.mk    # dieselbe Rezept-Form, die der Ziel-Bootstrap generiert
14
```

Die drei Marker werden als **Teilketten** gesucht (`record-gates.sh`, nicht
`tools/harness/record-gates.sh`) und treffen damit die Zeilen, die `make -n gates` druckt. Die
Gegenrichtung ist am Zweig gelesen, nicht an einer leeren Kette behauptet: über einer leeren
`$kette` schlägt jeder der drei `grep -qF` fehl → `fehlt` ist nicht leer → `exit 1`, und die
Zusicherung dahinter wird gar nicht erreicht. **Die Vorbedingung fällt, sie bleibt nicht grün.**

**4.3 Die Abdeckungs-Gleichung des Einordners bleibt balanciert — an allen drei Ständen gemessen.**

```text
$ A=$(grep -cE '\|\| [a-z_0-9]+=\$\?$' F); B=$(… | grep -cE ' -n |span-clean|bash "\$wrapper"'); \
  C=$(… | grep -c 'tmpbin/ai-harness-init'); D=$(grep -cE '^[[:space:]]*einordnen "' F)
3e535c3c^: A=47 B=9 C=6  A-B-C=32   D=34  D-2=32
3e535c3c : A=51 B=10 C=6 A-B-C=35   D=37  D-2=35
c18b9c74 : A=52 B=10 C=6 A-B-C=36   D=38  D-2=36
```

Der Nachzug fügt **eine** Abschnitts-Zeile und **eine** Einordnung hinzu; beide Seiten wandern um
1, die Gleichung hält. Der Fall, der sie prüft, ist
`abdeckung: die Gleichung des Kriteriums haelt` (`make test-bats`, in `make gates`).

### 5. Der Konjunktiv-Bestand des Deltas, vollständig gezählt

```text
$ git diff 3e535c3c^..c18b9c74 -U0 … | grep '^+' | grep -nEi '\b(wuerde|waere|haette|braeche|laese|faende|naehme|stuende|koenne|muesste|liefe|bliebe|fiele|…)\b'
 d1:7:+// Glob einbindet — ein Ziel daneben liefe in keinem `make` des Adopters.
d1:62:+// aufgezaehlt: eine im Test gepflegte Kette bliebe gruen, sobald ein neues
d1:95:+	// Vorbedingung: die Huelle traegt wirklich die Gate-Kette. Ohne sie liefe der
$ git blame -L 5,7 -- internal/emit/archivierung.go
3e535c3c5 (pt9912 2026-09-15 6) // Glob einbindet — ein Ziel daneben liefe in keinem `make` des Adopters.
```

Drei Fundorte, alle aus dem Delta des Slice (nicht aus dem Bestand daneben), alle in den zwei
Dateien, die der Runde-1-Befund schon nannte. In `full-smoke.sh` und in `test/mutations/334, 336,
338` findet der Ausdruck **null** Treffer — die Umschrift dieser vier Dateien ist vollständig.
Einzelheiten als **F-2** unten.

### 6. Der neue Marker und die Verbotslisten des Commands-Wächters

```text
$ grep -c 'harness/tools/' internal/emit/templates/commands/*.md
close-welle.md:0 · plan-welle.md:0 · implement-slice.md:0
$ sed -n '91,95p' internal/emit/templates/commands/close-welle.md | grep -cE 'make mutate|make smoke|test/mutations|ai-harness-init|slice-[0-9]'   # 0
```

Der neue Marker nennt **keinen** internen Pfad und keine der verbotenen Formen; `make gates` läuft
über ihm grün (§7).

### 7. `make gates` — Exit-Code und tragende Zeile

```text
$ make gates > /tmp/gates-review2.log 2>&1; echo "GATES_EXIT=$?"
GATES_EXIT=0
$ grep -E 'd-check: [0-9]+ Datei|gates: ' /tmp/gates-review2.log
d-check: 1403 Datei(en) geprüft, 0 Befund(e)
$ tail -1 /tmp/gates-review2.log
span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert
```

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills**. Die Spalten sind gespiegelt, nicht neu
definiert; bei Abweichung gilt der Skill.

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Der `ANPASSEN`-Marker nennt als **Handlung** weiterhin eine Umbenennung des Ziels und gibt ihr ein Mittel mit (*„Wer das Ziel umbenennt, zieht das Fragment mit"*), das der Satz **davor** widerlegt: dasselbe Fragment ist werkzeug-eigen und wird von jedem Bootstrap kanonisch neu geschrieben ([`ADR-0007`](../../docs/plan/adr/0007-bootstrap-phasen.md) Idempotenz-Klasse; `internal/emit/enforce.go:207-222` schreibt die Menge bei **jedem** Lauf, ohne Zweig für einen vorhandenen Bestand). Ein Adopter, der der Marker-Handlung folgt (Ziel in Anleitung **und** Fragment umbenennen), hat nach dem nächsten Werkzeug-Lauf einen Anleitungsnamen, den `make` nicht kennt — genau der Ausfall, den der Marker im selben Satz ankündigt und der neue E2E-Abschnitt `(c2)` als laut belegt. Der Satz ließe sich auch als Handlung des **Werkzeug-Autors** lesen; der Marker steht aber als Ausfüll-Anweisung an den Adopter (*„nenne hier den deines Repos"*), und diese Lesart ist es, die ihn sich selbst widersprechen lässt. | [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) · [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) §Adaptierbar · [`ADR-0007`](../../docs/plan/adr/0007-bootstrap-phasen.md) · [`ADR-0033`](../../docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 4 und 5 | `internal/emit/templates/commands/close-welle.md:91-95` | nein — herstellbar nur über eine `full-smoke`-Variante (im Ziel umbenennen, `init` erneut fahren, Anleitung und Fragment gegeneinander lesen); kein Gate hält die zwei Namen zusammen | adaptions-marker-nennt-eine-stelle-die-emissions-klasse-nicht-haelt |
| F-2 | LOW | Die Konjunktiv-Umschrift hat die **gemessene Menge** nicht erreicht: drei Fundorte derselben Form bleiben im Delta des Slice, einer davon in derselben Datei wie der gemeldete — `archivierung.go:6` (*„ein Ziel daneben liefe in keinem `make` des Adopters"*, Konjunktiv über die verworfene Ablage), `archivierung_test.go:38` (*„eine im Test gepflegte Kette bliebe gruen, sobald ein neues Fragment eine Kante dazunimmt"*, Konjunktiv über die verworfene Umsetzung) und `archivierung_test.go:71` (*„Ohne sie liefe der Waechter ueber einem leeren Ergebnis"*). Alle drei sind als Zustand formulierbar, ohne die Aussage zu verlieren — dieselbe Klasse, die der Nachzug selbst mit dem Register-Namen *„Korrektur trifft den Fundort statt die gemessene Fundmenge"* führt und die er in `full-smoke.sh` und `test/mutations/334, 336, 338` vollständig gezogen hat (§5). | [`AGENTS.md`](../../AGENTS.md) §3.7 („Falsch: … Konjunktiv über die verworfene Alternative") | `internal/emit/archivierung.go:5-6` · `internal/emit/archivierung_test.go:37-38,71` | nein — `make comment-claims` prüft, ob ein genannter Sensor existiert, nicht worüber ein Kommentar spricht ([`AGENTS.md`](../../AGENTS.md) §3.7) | kommentar-im-konjunktiv-ueber-die-verworfene-alternative |
| F-3 | LOW | Der Absatz, der begründet, warum der Fall **genau eine** Zeile löscht, ist umgeschrieben und dabei in beiden Aussagen falsch geworden: die stehenbleibende Zeile trägt **keine** Fortsetzungsmarke (die trägt die gelöschte, `archivierung.mk:31`), und die behauptete Folge *„ohne sie endet die Rezept-Fortsetzung im Leeren (ein make-Fehler …)"* tritt nicht ein — ein Rezept, dessen letzte Zeile mit `\` endet, läuft mit Exit **0** durch (§3). Der Fall und sein Erwartungswert bleiben richtig; falsch ist die Begründung, die er über sich selbst gibt, und sie ist die Stelle, an der eine spätere Lockerung (zwei Zeilen statt einer) ihren Diagnose-Text verlöre. | [`AGENTS.md`](../../AGENTS.md) §3.7 (Ein Kommentar beschreibt, was da ist) | `test/mutations/338-archivierung-ohne-traeger-schweigt.sh:13-16` | ja, messbar — der Trockenlauf aus §3 trägt es; **kein** Gate führt diese Messung | kommentar-behauptet-einen-mechanismus-der-nicht-eintritt |
| F-4 | LOW | Der Kopf des E2E-Abschnitts wurde in diesem Commit von **VIER** auf **FUENF AUSSAGEN** gezogen und um `(c2)` erweitert; die Schlusszeile desselben Abschnitts (`harness/tools/full-smoke.sh:2021`, in diesem Commit **nicht** angefasst) zählt weiter vier auf: kein Gate `(c)` · die zwei Sperren `(a)` · der reale Lauf `(b)` · der Träger-lose Fall `(d)` — die neu hinzugekommene Zusicherung kommt in ihr nicht vor, obwohl sie die Text-Hälfte des F-2-Nachweises trägt. Wer die Wellen-Closure über der Schlussliste liest, liest einen Abschnitt mit vier Aussagen, der fünf führt. | Maintainability | `harness/tools/full-smoke.sh:1029-1042` gegen `harness/tools/full-smoke.sh:2021` | nein — kein Gate hält Prosa-Aufzählung und Ausgabe-Zeile zusammen | sensor-schlusszeile-zaehlt-weniger-aussagen-als-sein-kopf |
| F-5 | INFO | Der Nachzug schreibt erneut am Marker-Inhalt **desselben** Artefakts, das [`ADR-0051`](../../docs/plan/adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md) §Konsequenzen Folgepflicht 3 namentlich der **Planner**-Rolle zuspricht (*„der Implementer trägt an dieser Datei nichts mehr"*) — geschrieben am 2026-09-15, nach dem Architect-Verdikt `20a29cbd`. Die ADR steht auf `Proposed`; gebunden ist damit nichts, und der Plan führt die Datei in seiner §3-Tabelle weiter als `update` dieses Slice. Die Zuständigkeit ist daher **nicht** neu zu entscheiden — sie gehört als Zustand in die Closure: Folgepflicht 3 ist heute teils durch ein Implementer-Commit erledigt, und die Reviewer-Runde, die ADR-0051 annehmen soll (ihr §Acceptance-Trigger), liest einen Stand, der ihrer eigenen Aufteilung widerspricht. Kein Modul liest Rollen oder Commit-Zuschnitt ([`AGENTS.md`](../../AGENTS.md) §3.8, *Ein Wächter existiert nicht*). | [`ADR-0051`](../../docs/plan/adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md) Folgepflicht 3 · [`AGENTS.md`](../../AGENTS.md) §3.8 | `internal/emit/templates/commands/close-welle.md:91-95` | nein — kein Gate liest Commits oder Rollen | rollen-zuordnung-eines-nachzugs-gegen-eine-proposed-adr |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **Mutation `339` — trifft oder umgeht sie die Verdrahtung?** ([`AGENTS.md`](../../AGENTS.md) §3.6) | **geprüft, ohne Befund.** Sie mutiert die **Quell**-Vorlage, der Wächter emittiert über den echten Emitter und liest die Ziel-Menge aus den Fragmenten; die Meldung nennt die gelesene Menge und den behaupteten Namen (§1). Der Fall ist über den Treiber automatisch erfasst (Glob `"$cases_dir"/*.sh`, Aufruf `bash "$case_file"`), sein Modus `100644` ist damit irrelevant neben `100755`-Geschwistern — der Treiber führt beide. `# verify: test-go` und `# expect: TestEmittierteDokumente_NurInitInvarianteZiele` entsprechen dem Fehlschlag-Muster der Go-Stufe (`--- FAIL: <Name>`), das der Lauf zeigt. |
| **Der neue E2E-Abschnitt `(c2)` — die Lauf-Hälfte derselben Klasse** | **geprüft, ohne Befund.** Er mißt an der **realen** `make`-Ausgabe im gebootstrappten Ziel (§4), nicht an einem nachgebauten Aufruf, und er prüft die Richtung, die den Adopter trifft: unbekannter Name → Abbruch **und** Nennung; ein stiller Durchlauf wäre rot. Die zwei Zweige schließen beide Fehlschlag-Formen aus, und der Abschnitt läuft **vor** dem Aufbau des geschlossenen Bestands, kann ihn also nicht verfälschen — `make full-smoke` endet mit 0 und ohne FEHLER-Zeile. |
| **Die neue Vorbedingung der Nicht-Gate-Zusicherung (Runde-1-F-4)** | **geprüft, ohne Befund.** Drei Rezept-Zeilen-Marker, die die reale Kette trägt (§4.2); über leerer Kette fällt sie (§4). Die Reihenfolge stimmt (Vorbedingung **vor** der Negativ-Zusicherung), und die Marker sind **Teilketten**, decken also die Pfad-Präfixe der emittierten Rezepte mit ab. |
| **Die Abdeckungs-Gleichung des Einordners über dem Nachzug** | **geprüft, ohne Befund — balanciert an allen drei Ständen** (§4.3): `3e535c3c^` 32 == 32 · `3e535c3c` 35 == 35 · `c18b9c74` 36 == 36. Der Nachzug bewegt beide Seiten um **1**. Die im Auftrag genannte Quadrupel-Zahl (`A=47 B=9 C=6 D=34`) ist der Stand **vor** dem Slice, nicht der des Nachzugs; gemessen ist sie in §4.3 mit reproduziert. |
| **Aussagen-Verlust durch die Konjunktiv-Umschrift** | **geprüft, ohne Befund.** Alle elf umgeschriebenen Sätze (fünf in `full-smoke.sh`, je einer in `archivierung.go`, `archivierung_test.go` und `archivierung.mk`, je einer in `334`, `336`, `338`) tragen ihre Zusage in der Indikativ-Fassung weiter; keine ist schwächer als die Sache (§2). Zwei Klauseln sind gefallen und benannt: der Vergleich *„ein Gate über ihr wäre eines über leerem Prüfbereich"* steht in keiner Fassung mehr, und der Marker verliert den Satz *„der Satz über das fehlende Werkzeug darunter gilt unabhängig davon"* — der Satz darunter steht unverändert und trägt sich selbst. |
| **Der neue Marker gegen die Verbotslisten** ([`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)) | **geprüft, ohne Befund.** Kein `harness/tools/`, keines der Muster `make mutate`/`make smoke`/`test/mutations`/`ai-harness-init`/`slice-<Ziffern>` (§6); die Wortgleichheit der Feststellungs-Zeile für ein Repo **ohne** das Werkzeug ist unberührt, weil der Nachzug sie nicht anfasst. |
| **[`AGENTS.md`](../../AGENTS.md) §3.7 über allen zugefügten Zeilen des Nachzugs** | **geprüft, mit den Befunden F-2 und F-3 und sonst ohne Befund:** kein `Review-Befund`, kein Lauf-Protokoll, kein *„früher stand"*, kein abgebrochener Satz. Die elf `slice-<Ziffern>`-Treffer des Deltas sind Fixture-Dateinamen des Smoke-Bestands (`slice-999-archiv-smoke.md`, …), keine Herkunfts-Erzählung. |
| **Der Fragment-Zuschnitt und der Träger-Zweig** (unverändert seit Runde 1) | **geprüft, ohne Befund.** Der Nachzug berührt `enforce.go` nicht; `archivierungFile()` liegt weiter in `enforceFiles()` vor dem Ausgangs-Zweig, `Enforce` schreibt die Menge konvergent und prunt nie (§F-1 nutzt genau diese Eigenschaft als Beleg). |
| **DoD-Konformität, Plan-§3-Zeile, ADR-0051-Substanz** | **nicht geprüft — nicht Gegenstand dieses Laufs.** DoD/Spec prüft der Verifier; die von [`ADR-0051`](../../docs/plan/adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md) Folgepflicht 2 verlangte Korrektur der Plan-§3-Zeile steht aus (die Zeile führt die Vorlage weiter als `update` dieses Slice), ist aber Planner-Arbeit und ausdrücklich außerhalb dieses Auftrags; die ADR selbst ist von der Prüfung ausgenommen. |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 3 |
| INFO | 1 |

**Runde-1-Befunde, ein Wort je Befund:** F-1 **behoben** (Konflikt-Pfad entschieden; Bedingung für
die Closure benannt) · F-2 **nicht behoben** (als F-1 neu gefasst) · F-3 **teilweise behoben** (als
F-2 neu gefasst) · F-4 **behoben**.

**Finding-Klassen dieses Laufs:** adaptions-marker-nennt-eine-stelle-die-emissions-klasse-nicht-haelt ·
kommentar-im-konjunktiv-ueber-die-verworfene-alternative ·
kommentar-behauptet-einen-mechanismus-der-nicht-eintritt ·
sensor-schlusszeile-zaehlt-weniger-aussagen-als-sein-kopf ·
rollen-zuordnung-eines-nachzugs-gegen-eine-proposed-adr

## Verdikt

**Nicht merge-blockierend — aber der Slice ist noch nicht schließbar.** Kein HIGH: die Runde-1-HIGH ist
auf dem Konflikt-Pfad entschieden und die Änderung bleibt stehen; kein stilles Grün ist entstanden,
die zwei neuen Zusicherungen des Nachzugs sind gefahren und ihre Meldungen gelesen. Die vier
offenen Punkte sind Nacharbeit am Text, kein Rückbau: **F-1** ist der Rest desselben Befunds, den der
Nachzug halb erledigt hat, und er sitzt an derselben Stelle, an der er gemeldet wurde.

**Zwei Bedingungen hängen nicht an diesem Report und werden hier nur benannt**, weil kein Gate sie
liest:

1. **Closure-Vorbedingung.** [`ADR-0051`](../../docs/plan/adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md)
   steht auf `Proposed`, und ihre Folgepflicht 1 sagt, dass der auslösende Slice **nicht vor ihrer
   Annahme** schließt. Der Beleg ist eine Reviewer-Runde **an der ADR** (ihr §Acceptance-Trigger),
   nicht an diesem Diff und nicht die Nachmessung eines hier aufgelösten Befunds
   ([`ADR-0040`](../../docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2).
2. **Der Fundort von F-1 gehört nach [`ADR-0051`](../../docs/plan/adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md)
   Folgepflicht 3 in die Planner-Rolle** (F-5). Wer die Zusage dort nachzieht, sollte das wissen,
   bevor die Datei ein drittes Mal in einem Implementer-Commit landet.

**Übergabe:** Findings gehen an den Implementer (F-1 bis F-4); F-1 zusätzlich an den Planner
(er trägt den Text nach [`ADR-0051`](../../docs/plan/adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md)
Folgepflicht 3) und F-5 an Planner und Architect (Zustand der Folgepflicht, kein Finding zur
Rollen-Entscheidung). Die **Finding-Klassen** gehen in die Slice-Closure §7 und von dort in den
Zähler; `kommentar-im-konjunktiv-ueber-die-verworfene-alternative` steht damit zum zweiten Mal in
dieser Welle. Dieser Report selbst ist ein **Lauf-Beleg** — er wird über Läufe hinweg nicht wieder
gelesen und ersetzt keine Verifikation (Modul 11).
