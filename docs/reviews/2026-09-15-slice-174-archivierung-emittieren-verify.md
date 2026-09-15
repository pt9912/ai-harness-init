# Verifikation `slice-174-archivierung-emittieren` — zwei Liefer-Punkte tragen, der zweite nur mit Widerspruch

**Rolle:** Verifier · **Datum:** 2026-09-15 · **Geprüfter Stand:** `db309c8c` (Umsetzung `3e535c3c`,
Review-Nachzug `c18b9c74`, Runde-2-Nachzug `db309c8c`; am selben Gegenstand zwei Planner-Commits:
`b8456062` Anlass-Block, `efce6042` ANPASSEN-Marker) · **Prüfgegenstand:** §2 Definition of Done
gegen den tatsächlichen Stand, dazu §1, §3, §5, §6, §8 des Plans — **nicht** der Plan gegen sich
selbst (das war der Reviewer) · **Reviews:** `2026-09-15-slice-174-archivierung-emittieren` (Runde 1:
1 HIGH · 1 MEDIUM · 1 LOW · 1 INFO, blockierend) und dieselbe Kennung `-runde-2` (0 HIGH · 1 MEDIUM
· 3 LOW · 1 INFO).

**An diesem Gegenstand nicht geschrieben (Negativ-Aussage).** Dieser Lauf hat an keinem der drei
Umsetzungs-Commits, an keiner der zwei Review-Runden und an keiner Datei des Slice etwas verfasst —
kein Kommentar, kein Testfall, kein Fragment, kein Plan-Satz, kein Review-Befund. Er hat gelesen und
Sensoren gefahren.

**Offengelegt — was dieser Lauf am Baum getan hat.** Zwei Mutations-Fälle (`335`, `338`) sind über
`harness/tools/mutate.sh` **in einer `/tmp`-Kopie** des Baums gefahren worden; die Kopie trug nur
diese zwei Fall-Dateien. Fall `335` ist zusätzlich dort einzeln über `make test-go` gefahren, sein
Fragment danach aus der Sicherung zurückgeholt (`git status --porcelain` in der Kopie: leer). Am
**Repo** ist keine Mutation angewandt worden; `make gates` lief in einem Wegwerf-Worktree auf
`db309c8c` und zusätzlich über dem Hauptbaum; `make full-smoke` im Hauptbaum. Der Hauptbaum trug zum
Messzeitpunkt eine **fremde, laufende** Änderung (zuerst `docs/plan/adr/0051-…`, später `slice-215-…`
und das zweite Wellen-Mitglied) — sie ist in keiner Zusicherung dieses Berichts enthalten und in
keiner Messung Gegenstand.

**Ausgenommener Gegenstand — nicht geprüft, mit Grund.** Die Annahme von
[`ADR-0051`](../../docs/plan/adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md)
(eigene Reviewer-Runde, Architect-Entscheidung; während dieses Laufs in `ff6daa84` vollzogen) und
die **Closure** (§7, Beobachtungs-Register, §6-Ausgänge, `git mv`, DoD-Häkchen — Planner-Arbeit nach [`AGENTS.md`](../../AGENTS.md) §3.10).

**Zitier-Form:** Kennung statt Adresse für alles, was der Prozess bewegt; ortsfeste Code-Pfade als
Inline-Code. Der geprüfte Gegenstand wird über seinen **Stand** festgehalten, nicht über seinen
Lifecycle-Pfad.

---

## Ergebnis in einer Tabelle

| §2 DoD-Punkt | Verdikt |
|---|---|
| **Liefer-Punkt 1** — „Ein frisch gebootstrapptes Ziel erreicht `archive-welle`“, Beleg `make full-smoke` und nur er | **erfüllt** (§2.1) |
| **Liefer-Punkt 2** — „Der emittierte `close-welle.md` zeigt auf den Träger … der Adopter darf das Target anders nennen“ | **nicht erfüllt** — zwei von drei Teilsätzen tragen, der dritte ist durch die Lieferung widerlegt (§2.2) |
| **Liefer-Punkt 3** — „Fehlt der Träger im Ziel, sagt das Kommando das und färbt nichts rot“ | **erfüllt** (§2.3) |
| `make gates` grün | **erfüllt** (§2.4) |
| Doku-Update: die Aufzählung emittierter Artefakte in `harness/README.md` und `README.md` | **nicht fällig** — beide Dateien führen keine solche Aufzählung (§2.5) |
| Closure-Notiz mit Steering-Loop-Lerneintrag | **nicht fällig** — Planner (`AGENTS.md` §3.10) |
| Beobachtungs-Register (`../observations/`) fortgeschrieben | **nicht fällig** — Planner |
| Jedes Risiko aus §6 trägt einen Ausgang | **nicht fällig** — Planner; §6-5 ist am Baum bereits eingetreten (§3.2) |
| Die drei Paarungen sind getragen | **nicht fällig** — im Wellen-Repo die Welle-Closure (Modul 6) |

**DoD-Verletzung: genau eine.** Liefer-Punkt 2, dritter Teilsatz (*„der Adopter darf das Target
anders nennen“*) — Fundort `slice-174` §2 gegen `internal/emit/templates/commands/close-welle.md:91-95`.
Sie ist **kein Artefakt-Defekt**, sondern ein Abnahmekriterium, das die Lieferung nicht mehr deckt;
aufzulösen hat sie allein der Planner (§2.6, §5).

**Befunde eigener Klasse (Verifier, keine DoD-Verletzung): drei** — §5: zwei Zahlen des Anlass-Blocks
(V-1), eine überholte Grenz-Zeile in der Sensor-Prosa (V-2), und der Umfang des E2E-Belegs (V-3,
INFO).

---

## 1. Ist der Sensor gelaufen?

Alle Docker-Läufe über `make` ([`AGENTS.md`](../../AGENTS.md) §3.9), keine Host-Toolchain. Der
Lauf, der die DoD trägt, ist **`make full-smoke`** — er ist im Hauptbaum gefahren, **EXIT 0**:

```sh
make full-smoke            # EXIT 0, 0 Zeilen `full-smoke: FEHLER`
```

Die entscheidenden Zeilen des neuen Abschnitts, wörtlich aus dem Lauf:

```text
full-smoke: unbekanntes Ziel (golang): make archiv-welle endet laut und nennt den Namen — die Anleitung zeigt auf das Ziel, das das Fragment fuehrt:
  make[1]: *** Keine Regel, um „archiv-welle“ zu erstellen.  Schluss.
full-smoke: Sperren erreichen den Aufruf (golang): make archive-welle endet ueber zwei Ausloesern nicht erfolgreich, nennt beide und schreibt nichts:
  [haenger]
  [untergrenze]
archive-welle --vorschau: welle-smoke
  Mitglieder (Welle-Feld nennt welle-smoke): 1 · wellenlos (seit der letzten Closure): 0
  Review-Reports (ohne Stub): 1 · Verweise: 0 Datei(en) betroffen
  Sperren: keine — der schreibende Lauf liefe.
archive-welle ok: welle-smoke
  Commit 1 (reiner Move): 1 Slice(s) + Welle-Plan nach docs/plan/planning/done/welle-smoke/
  Commit 2 (Inhalt): archiv.zip (883 Bytes), 2 Stub(s), 1 Review-Report(s) entfernt
full-smoke: Archivierung im Ziel (golang): make archive-welle archiviert real — welle-smoke/archiv.zip mit welle-smoke.md und slice-999-archiv-smoke.md als Stubs, der Review-Report des Slice ist fort.
full-smoke: ohne Traeger (golang): make archive-welle meldet den fehlenden Traeger, endet mit 0 und schreibt nichts.
full-smoke: OK — ARCHIVIERUNG IM ZIEL (ADR-0033 Festlegung 4 und 5): …
```

`make gates` ist über demselben Stand in einem **Wegwerf-Worktree** gefahren (der Hauptbaum trug
fremde, laufende Arbeit), ebenfalls **EXIT 0** (§2.4). Der Mutations-Treiber ist für zwei der neuen
Fälle gefahren (§4).

**Nicht gefahren, mit Grund:** der volle `make mutate`. Er gehört auf die Post-Integration-Stufe
(`v6.8.0` · `regelwerk/grundlagen-klassifikation.md` §Klassifikation); für diesen Slice sind zwei
der neuen Fälle **einzeln** gefahren und ihre Ausgaben gelesen. Was das offen lässt, steht in §6.

---

## 2. Deckt der Sensor die Zusage?

### 2.1 Liefer-Punkt 1 — die Erreichbarkeit ist am Ziel **gemessen**, nicht genannt — **erfüllt**

Der E2E ist nicht der einzige Beleg dieses Laufs, weil die Frage *„archiviert das Kommando im Ziel
wirklich, und nicht nur sein Name?“* zwei Dinge trennt: der E2E prüft die **Wirkung** (Archiv, Stubs,
Report fort), der Träger committet. Beides ist getrennt gemessen.

**(a) `make full-smoke` im gebootstrappten Ziel** — Exit 0, der Abschnitt läuft über beide Zweige
(`(a)+(b)` für diesen Punkt, `(d)` für Liefer-Punkt 3) und prüft `archiv.zip`, **beide** Stubs, das
Fortsein des Review-Reports und den Erfolgs-Exit. Die Zeile darüber nennt die zwei Commits; sie ist
die Ausgabe des Trägers, **nicht** seine Zusicherung.

**(b) Eigenmessung in einem `/tmp`-Ziel** — dasselbe Fragment, derselbe Träger, ein selbstgebauter
Bestand (Wellen-Plan, Ergebnisnotiz, ein Mitglied, ein Review-Report; dazu die zwei Auslöser für die
Sperren). Gelesen wurde `git log` **und** `git status` — die zwei Dinge, die der E2E nicht liest:

```text
$ make archive-welle WELLE=welle-smoke          # mit den zwei Ausloesern
archive-welle --vorschau: welle-smoke
  Sperren: 2 — der schreibende Lauf braeche ab.
    [untergrenze] 1 wellenlose(r) Slice(s) liegen flach …
    [haenger] ein Review-Report soll verschwinden, auf den noch verwiesen wird
      docs/reviews/bleibt.md -> docs/reviews/slice-999-review.md
make: *** [harness/mk/archivierung.mk:28: archive-welle] Fehler 3
MAKE-RC=2
geschrieben? NEIN

$ .harness/state/bin/ai-harness-init archive-welle welle-smoke   # der Traeger DIREKT
    [untergrenze] …  [haenger] …
TRAEGER-RC=3                       ← der Exit, den `make` nicht durchlaesst

$ make archive-welle WELLE=welle-smoke          # nach Entfernen der zwei Ausloeser
archive-welle ok: welle-smoke
  Commit 1 (reiner Move): 1 Slice(s) + Welle-Plan nach docs/plan/planning/done/welle-smoke/
  Commit 2 (Inhalt): archiv.zip (900 Bytes), 2 Stub(s), 1 Review-Report(s) entfernt
MAKE-RC=0
archiv.zip: JA (900 Bytes) · Stubs: welle-smoke.md, slice-999-archiv-smoke.md
Review-Report des Slice noch flach? NEIN
porcelain nach dem Lauf: []         ← der Traeger hat committet, nicht nur bewegt

$ git log --oneline HEAD~2..HEAD
6f1c2de archive-welle: welle-smoke  Archiv, Stubs und Verweis-Nachzug (Inhalt, getrennt vom Move — AGENTS.md §3.3)
a1afcb4 archive-welle: welle-smoke  Zeitdokumente nach docs/plan/planning/done/welle-smoke/ (reiner Move)
```

**Die Sperren-Vererbung ist damit bestätigt, samt der benannten Grenze** des Umsetzers
(*„`make` gibt für ein fehlgeschlagenes Rezept 2, der Träger-Exit 3 ist darüber nicht lesbar“*): der
direkte Aufruf endet mit **3**, derselbe Aufruf über `make` mit **2** und der Zeile `Fehler 3`. Das
Fragment trägt **keine eigene Sperr-Logik** — es führt `exec "$c" archive-welle "$(WELLE)"`, die
Sperren kommen aus dem Binär; die zwei Marken stehen in der Ausgabe, und geschrieben wurde nichts.

**Die zwei Zweige desselben DoD-Punkts** sind damit an einem realen Ziel gefahren: Erreichbarkeit
(§1: „kein Make-Ziel im Ziel“) über `(b)`, Nicht-Gate über `(c)`, und der laut abbrechende fremde
Name über `(c2)`.

### 2.2 Liefer-Punkt 2 — der Zeiger steht, der ehrliche Ausgang steht, der dritte Teilsatz ist widerlegt — **nicht erfüllt**

Der Punkt hat drei Teilsätze. **Zwei tragen**, einer ist durch die Lieferung widerlegt.

**Trägt (1): der Zeiger.** `internal/emit/templates/commands/close-welle.md` Schritt 4 nennt das
Ziel und den Weg zum Träger:

```text
Liegt der Träger im Repo, führt `make archive-welle WELLE=<welle-id>` ihn; fehlt er,
sagt das Kommando das selbst.
```

**Trägt (2): der ehrliche Ausgang steht daneben, wortgleich zum Vorstand.**

```sh
git show 3e535c3c^:internal/emit/templates/commands/close-welle.md | grep -c 'Hat dein Repo das Werkzeug nicht, ist die Bedingung nicht eingetreten'   # 1
grep -c 'Hat dein Repo das Werkzeug nicht, ist die Bedingung nicht eingetreten' internal/emit/templates/commands/close-welle.md                        # 1
```

**Trägt (3) nicht: der Marker.** Der Punkt schreibt fort: *„Die repo-spezifische Stelle bleibt ein
**adaptierbarer** Marker ([`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3))
— der Adopter darf das Target anders nennen.“* Das Ziel benennt als repo-spezifische Stelle **den
Weg zum Träger** und den Ziel-Namen ausdrücklich als **nicht** adaptierbar:

```text
<!-- ANPASSEN: der Weg zum Träger ist die repo-spezifische Stelle; nenne hier den deines Repos.
     Der Ziel-NAME `archive-welle` ist es nicht. Er kommt aus einem tool-eigenen Fragment, das
     jeder Bootstrap kanonisch neu schreibt — ein umbenanntes Ziel hält darum nicht, und diese
     Anleitung bleibt auf einem Namen stehen, den `make` nach dem nächsten Lauf nicht mehr kennt.
     Der Aufruf endet dann laut statt still; er endet nicht erfolgreich. -->
```

Der Marker selbst ist **da** und **adaptierbar** (Go-Wächter `TestCommands_AdaptationMarker` läuft
grün in `make gates`) — die Widerlegung trifft die *Konkretisierung* des Punktes: der Adopter darf
das Target **nicht** anders nennen, und das ist keine Nachlässigkeit der Lieferung, sondern
[`ADR-0007`](../../docs/plan/adr/0007-bootstrap-phasen.md)s konvergente Klasse, die
[`ADR-0033`](../../docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 4 für
genau dieses Fragment wiederholt. Der Punkt ist damit **wie geschrieben nicht wahr abhakbar**: das
gelieferte Artefakt erfüllt ihn, indem es ihm widerspricht. Aufgelöst hat die Spannung der Planner in
`efce6042` **am Artefakt** (der Marker lud zuvor zum Umbenennen ein und widersprach sich selbst —
Runde-2-F-1, MEDIUM); der DoD-Text ist unangetastet geblieben, und ihn zu ändern ist nach
[`AGENTS.md`](../../AGENTS.md) §3.10 **nicht** Sache des Implementers, des Reviewers oder dieses
Laufs. Einzelheiten und die Klasse: §5.

### 2.3 Liefer-Punkt 3 — der fehlende Träger sagt es, ohne Rot — **erfüllt**, und rot gesehen

Der geforderte Rot-Beleg ist an **genau diesem Fall** gefahren, in beiden Fassungen: über den E2E
(Zweig `(d)`: `mv "$carrier" "$carrier.beiseite"`, dann `make archive-welle`, Exit-Code und Ausgabe
gelesen) und als Mutations-Fall `338`, der die Meldung entfernt und den E2E rot färbt (§4). Eigene
Messung am `/tmp`-Ziel, ohne und mit der Mutation:

```text
$ make archive-welle WELLE=welle-zweit          # Traeger beiseite gelegt, unmutiert
archive-welle: der Traeger liegt nicht (.harness/state/bin/ai-harness-init) — dieses Repo archiviert seine Wellen nicht.
archive-welle: ein erneuter Lauf des Werkzeugs legt ihn wieder ab.
RC=0

$ sed -i '/^	echo "archive-welle: der Traeger liegt nicht/d' harness/mk/archivierung.mk
$ make archive-welle WELLE=welle-zweit          # mit der Mutation von Fall 338
archive-welle: ein erneuter Lauf des Werkzeugs legt ihn wieder ab.
RC=0
Satz FEHLT -> der E2E-Lauf geht auf seinen FEHLER-Zweig (rot), Exit 0 bleibt
```

Damit ist auch die **umgeschriebene Begründung** von `338` gedeckt (§4): die gelöschte Zeile ist die
vorletzte des Rezepts, die Fortsetzungsmarke trägt das `done; \` darüber weiter, das Rezept bleibt
heil, der Aufruf endet mit **0** — rot wird der Sensor am **fehlenden Satz**, nicht an einem
`make`-Fehler. Der Punkt ist erfüllt.

### 2.4 `make gates` grün — **erfüllt**

```sh
make gates        # EXIT 0 (Wegwerf-Worktree auf dem Stand db309c8c)
# baseline-verify: v6.8.0 OK — 54 Dateien (Integritaet + Vollstaendigkeit, netzlos)
# d-check: 1405 Datei(en) geprüft, 0 Befund(e)
# 1..281                                    ← bats
# comment-claims: 59 Datei(en) geprueft, 0 Befund(e)
# span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert
# acht Go-Pakete `ok` (cmd + sieben internal), kein `FAIL`
#
# Derselbe Lauf über dem Hauptbaum (mit diesem Bericht) ist ebenfalls EXIT 0:
# d-check: 1406 Datei(en) geprüft, 0 Befund(e) — die Zahl liegt um diesen Bericht höher.
```

**Eine fremde Messung desselben Gegenstands ist damit erklärt, nicht übernommen:** die
ADR-0051-Konsistenzrunde hat über einem **Arbeitsbaum um 04:1x** `EXIT 2` gesehen
(`TestArchivierungFragment_ZielAmTraegerUndNichtInDerGatesKette`, Fragment hängt `archive-welle` an
`GATE_CHECKS`). Dieser Rote ist die Signatur einer **angewandten Mutation** (`337` schreibt genau
diese Zeile) auf einem Baum, den ein anderer Lauf gerade bewegte; über dem committeten Stand
`db309c8c` ist derselbe Wächter grün, hier nachgemessen. Der Befund gehört damit zur Klasse
*„ein Lauf über einem bewegten Baum misst den Zeitpunkt“* und **nicht** zu diesem Slice.

**Dieselbe Lage war während dieses Laufs kurzzeitig zu sehen, mit demselben Ausgang.** Zwischenzeitlich trug der Hauptbaum
die **nicht committete** Arbeit einer anderen Rolle an `slice-215-commit-waechter-sieht-auch-die-ungetippten-commits`
und am zweiten Wellen-Mitglied `slice-kennungs-waechter-geht-ins-ziel`. `make gates` über **diesem**
Baum endete mit **EXIT 2** und genau einer Befund-Zeile:

```text
d-check: 1406 Datei(en) geprüft, 1 Befund(e)
docs/plan/planning/done/slice-215-commit-waechter-sieht-auch-die-ungetippten-commits.md:163  ADR-0062  id-unlinked  Kennung ohne Link auf ihre Definition
```

Die Kennung stand **nicht** am committeten Stand (`git show HEAD:<datei> | grep -c 'ADR-0062'` → 0)
und in keiner Datei dieses Slice (`git diff --name-only 36ba3d5e..db309c8c | grep -c 'slice-215'` →
0) — der Befund gehörte der laufenden Arbeit dort. Er ist mit ihr wieder verschwunden, und der Lauf
über dem Hauptbaum am Ende dieses Berichts ist **EXIT 0** (mit demselben Ergebnis). Was von der
Beobachtung bleibt: ein `make gates` über einem Baum, an dem gerade geschrieben wird, misst den
Zeitpunkt — für den DoD-Punkt zählt der Lauf über dem Stand, und beide sind grün.

### 2.5 Doku-Update: die zwei genannten Dateien führen keine solche Aufzählung — **nicht fällig**

Der Punkt ist bedingt („soweit sie durch diesen Slice wächst“). Der Bedingungsteil ist gemessen
falsch:

```sh
git grep -n 'harness/mk/\|commands/\|erfassung.mk\|archivierung.mk' -- README.md harness/README.md
# keine Ausgabe — beide Dateien nennen keinen emittierten Zielpfad einzeln
git log --oneline -S 'harness/mk' -- README.md harness/README.md
# 03505a8d (2026-07-23) nahm den letzten beiläufigen `harness/mk/<modul>.mk`-Hinweis aus README.md heraus
```

`harness/README.md` ist der Gate-Index dieses Repos (Sensors + Werkzeuge) und `README.md` die
Nutzer-Übersicht — eine Aufzählung **emittierter Artefakte** führt keine der beiden. Der Punkt hat
damit keinen Gegenstand; er ist nicht verletzt, sondern nicht fällig. Der *nahe* Ort, an dem der
Nachbar-Slice denselben Satz liest (die Sensor-Prosa), ist aus einem anderen Grund überholt — V-2 in
§5.

### 2.6 Die noch nicht fälligen Punkte

Vier der neun Punkte hängen nicht an Arbeit, sondern an der **Rolle**: Closure-Notiz, Register,
Risiko-Ausgänge und die drei Paarungen sind Closure-Schritte und laufen beim Planner
([`AGENTS.md`](../../AGENTS.md) §3.10, Baseline-Regelwerk `modul-08-agentenrollen.md` §Die neun
Übergaben). Sie sind **nicht fällig** — und keiner davon ist „erfüllt“ zu nennen, solange er nicht
gefahren ist: die Belege dafür (Closure-Notiz §7, Register-Eintrag, Ausgang je Risiko) liegen im
Ergebnis-Report-Format des Abschlusses und sind hier nicht vorwegzunehmen.

**Zwei dieser Punkte hängen zusätzlich an einer Bedingung außerhalb dieses Slice:** nach
[`ADR-0051`](../../docs/plan/adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md)
Folgepflicht 1 schließt der auslösende Slice **nicht vor der Annahme der ADR**. Der Zustand ist
nicht mein Gegenstand; er steht hier als **Closure-Vorbedingung**, weil kein Gate
ihn liest. **Beim Schreiben dieses Berichts vollzogen:** die Annahme ist in `ff6daa84` (Rolle Architect)
 erfolgt — die Vorbedingung aus Folgepflicht 1 ist damit eingelöst; die Messungen dieses Berichts
 bleiben die über `db309c8c`.

---

## 3. Sagt der Plan, was der Artefakt tut?

Beide Richtungen, gegen die §3-Tabelle und §1/§5 des Plans.

### 3.1 Gebaut und geplant

| §3-Zeile | Artefakt im Stand | Verdikt |
|---|---|---|
| `internal/emit/templates/commands/close-welle.md` — update (Schritt 4) | Zeiger + Marker, Schritt 4 | deckungsgleich |
| `internal/emit/` — update („nur falls Festlegung (d) einen eigenen Emissions-Schritt verlangt“) | `internal/emit/archivierung.go`, `…/templates/enforce/archivierung.mk`, `internal/emit/enforce.go` (+5) | deckungsgleich; die Bedingung ist mit Festlegung 4 **eingetreten**, nicht offen |

### 3.2 Gebaut, aber nicht in §3 — und warum das trägt

`internal/emit/archivierung_test.go` (drei Wächter), `test/unterkommando-kopplung.bats` (dritter
Aufrufer), sechs Fälle `test/mutations/334`–`339`, `harness/tools/full-smoke.sh` (der E2E-Abschnitt).
Fünf davon sind die **Pflichtseite** von [`AGENTS.md`](../../AGENTS.md) §3.6 (zu jeder Zusage der
rot färbende Fall) und der Kopplungs-Sensor der Namensachse — sie stehen in keiner Plan-Zeile, weil
§3 eine Änderungs-Tabelle und keine Beleg-Tabelle ist. **Eine Zeile ist ungenau, nicht falsch:**

| Plan sagt | Stand ist | Bewertung |
|---|---|---|
| `Makefile` (`full-smoke`) — update | `Makefile` **unverändert**; geändert ist `harness/tools/full-smoke.sh` (+252), das der Target-Rezept aufruft | der *Gegenstand* stimmt, der *Träger* der Änderung liegt eine Ebene tiefer. Die Zeile nennt das Ziel, nicht die Datei — kein Nachzug nötig, aber die nächste Planung sollte die Datei nennen, die sie meint |

### 3.3 §1-Abgrenzung — am Diff geprüft, eingehalten

```sh
git diff --stat 36ba3d5e..db309c8c
git diff --name-only 36ba3d5e..db309c8c | grep -E 'internal/archive|\.github|mutate'   # keine Ausgabe
git diff --name-only 36ba3d5e..db309c8c | grep -E 'slice-lifecycle-move-geht-ins-ziel|slice-kennungs-waechter-geht-ins-ziel'   # keine Ausgabe
```

- **`internal/archive/` ist unberührt** — der Träger bleibt, wie er war; die Sperren sind *geerbt*
  (§2.1), nicht nachgebaut. Das ist die tragende Zusage des Slice, und sie hält.
- **Keine Änderung an `.github/workflows/`** (also auch nicht an `ci.yml`/`mutate.yml`) — andere
  Rolle, und die Diff-Liste nennt keine Datei daraus.
- **Kein Zug an den zwei übrigen Wellen-Mitgliedern** (`slice-lifecycle-move-geht-ins-ziel`,
  `slice-kennungs-waechter-geht-ins-ziel`) — beide liegen unberührt in `open/`.
- Die übrigen Namen des Diffs außerhalb der Umsetzung (`docs/plan/adr/…`, `docs/plan/planning/done/…`,
  `roadmap.md`, `welle-emittierte-werkzeuge.md`, Erinnerungs-Slice) stammen aus den Commits der
  Rollen Planner/Architect/Reviewer, nicht aus den drei Umsetzungs-Commits.

### 3.4 Geplant, aber anders als im Wortlaut — die Zahlen des Plans

**V-1.** Der Anlass-Block in §2 Liefer-Punkt 1 ist in `b8456062` (Planner) auf den Stand gezogen
worden und war in diesem Moment richtig. Zwei spätere Commits haben **beide** Zahlen bewegt, und der
Block ist nicht nachgezogen:

```sh
grep -l 'archive' test/mutations/*.sh | wc -l        # Block sagt 33 — der Stand gibt 34
grep -c 'archive' harness/tools/full-smoke.sh        # Block sagt 21 — der Stand gibt 23
# je Stand, zum Nachvollziehen:
git show 3e535c3c:harness/tools/full-smoke.sh | grep -c 'archive'     # 21
git show c18b9c74:harness/tools/full-smoke.sh | grep -c 'archive'     # 23   (+2 durch F-4, Runde 2)
git grep -l 'archive' 3e535c3c -- 'test/mutations/*.sh' | wc -l       # 33
git grep -l 'archive' c18b9c74 -- 'test/mutations/*.sh' | wc -l       # 34   (+1: Fall 339)
```

Beide Zahlen tragen ihr Kommando im selben Block und sind als *keine Erwartungswerte* deklariert
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — sie sind damit **keine DoD-Verletzung**, aber sie zeigen nicht mehr, was das Kommando
darüber ausgibt. Die Rolle, die diesen Text schreibt, ist der Planner (§3.10); er fasst ihn bei der
Closure ohnehin an.

**V-1b.** §1 nennt als Messstelle den Tag `v5.18.0`:

```sh
ls .harness/baseline/                                                     # v6.8.0 — nur ein Tag, wie die Setzung es will
ls .harness/baseline/v5.18.0/templates/docs/plan/planning/archiv-stub-*.template.md   # kein Treffer
ls .harness/baseline/v6.8.0/templates/docs/plan/planning/archiv-stub-*.template.md | wc -l   # 2
```

Das Kommando läuft ins Leere; die **Aussage** (die zwei Stub-Vorlagen liegen über den vendored Baum
im Ziel) bleibt unter dem adoptierten Stand wahr. §6 Risiko 5 hat genau das vorweggenommen und
nennt als einen der drei Ausgänge *„entfallen: die Adresse ist nachgezogen und die Zählung neu
gefahren“* — die Adresse ist **nicht** nachgezogen, also steht der Ausgang beim Planner, nicht hier.

---

## 4. Modul 11 §Bewusstes Brechen — zwei neue Fälle einzeln, mit gelesener Ausgabe

Der Treiber ist über einer `/tmp`-Kopie des Standes gefahren, die nur die zwei Fall-Dateien führte
(`MUTATE_JOBS=1`, damit der Fall-Bericht lesbar bleibt); `335` ist zusätzlich einzeln über
`make test-go` mit gelesener Begründung gefahren.

```text
mutate: Gruen-Vorlauf make test-go (muss VOR der ersten Mutation gruen sein)
mutate: ok      335-archivierungs-fragment-ohne-preis      -> TestArchivierungFragment_TraegtPreisUndMeldung rot
mutate: ok      338-archivierung-ohne-traeger-schweigt     -> ohne Traeger sagt make archive-welle nicht rot
mutate: Vollstaendigkeit — 2 von 2 Fall-Dateien mit Ergebnis, jede Fall-ID genau einmal gezogen.
mutate: 2 ok, 0 Befund(e)
```

**Fall `335` — trägt die Meldung die behauptete Ursache?** Ja, und sie nennt die fehlende Zeile im
Klartext:

```text
--- FAIL: TestArchivierungFragment_TraegtPreisUndMeldung (0.00s)
    archivierung_test.go:154: harness/mk/archivierung.mk nennt den Preis des Aufrufs nicht — es fehlt: "nur auf ausdruecklichen Aufruf"
```

Die Mutation löscht genau die Zeile, deren Satz der Wächter verlangt; das Rot kommt aus dem
**richtigen** Grund und nicht aus einem Nachbar-Satz, den derselbe `strings.Contains`-Block sonst
trägt (die übrigen vier Preis-Sätze bleiben stehen).

**Fall `338` — deckt die umgeschriebene Begründung, was der Fall wirklich färbt?** Ja. Die Runde-2
hatte an der **alten** Begründung zwei Sätze als falsch gemeldet (stehenbleibende Zeile trage die
Fortsetzungsmarke; ohne sie ende die Rezept-Fortsetzung im Leeren). Die neue Begründung ist am
Mechanismus nachgemessen (§2.3): die gelöschte Zeile ist die **vorletzte**, die Marke trägt das
`done; \` darüber, das Rezept bleibt heil, **Exit 0** — rot wird der Sensor am fehlenden Satz. Damit
beschreibt der Fallkopf das, was passiert, und nicht mehr das, was er zuvor angenommen hatte. Sein
`# expect:` ist der Satz der **E2E-Fehlermeldung**, nicht ein Testname: das ist bei `# verify:
full-smoke` die zulässige Anker-Form, weil der Treiber den Text der Fehlschlag-Zeile liest
(`failure_form` → `full-smoke: FEHLER`) und der Satz nur dort steht, wenn der Lauf rot ist.

**Was an `338` nicht gemessen ist — als Grenze, nicht als Mangel:** seine `# expect:`-Zeile bindet
den Fall an den Wortlaut der E2E-Fehlermeldung; eine Umschrift derselben Meldung färbt den Fall
rot-aus-fremdem-Grund und meldet damit einen Befund, der keiner ist. Das ist derselbe Anker-Typ,
den der Treiber für jeden `full-smoke`-Fall nutzt — kein Befund dieses Slice, aber die Stelle, an
der ein Nachzug zuerst anstößt.

---

## 5. Befunde (Verifier-Klasse — eine DoD-Verletzung, drei eigene Befunde)

### 5.1 DoD-Verletzung — Liefer-Punkt 2, dritter Teilsatz

`slice-174` §2 verlangt, dass die repo-spezifische Stelle als **adaptierbarer Marker** bleibt und
*„der Adopter darf das Target anders nennen“*. Der Stand sagt an
`internal/emit/templates/commands/close-welle.md:91-95` das Gegenteil (**„Der Ziel-NAME
`archive-welle` ist es nicht“**), und zwar zu Recht: das Fragment ist tool-eigen und konvergent
([`ADR-0007`](../../docs/plan/adr/0007-bootstrap-phasen.md),
[`ADR-0033`](../../docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 4). Der
Punkt ist wie geschrieben nicht wahr abhakbar; das gelieferte Artefakt erfüllt ihn, indem es ihm
widerspricht.

**Das ist keine Review-Kategorie und kein Artefakt-Defekt** — es ist die DoD-Klasse, die nur die
Verifikation fängt (Modul 11), und die Klasse steht im Register unter
`abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt` (Stand **offen**, drei Belege). Der
Fall ist dort ein **vierter**; ich trage ihn nicht ein (Planner-Arbeit), sondern übergebe ihn.
**Ausgang:** der Planner zieht den dritten Teilsatz bei der Closure nach — entweder streicht er ihn
(die zwei tragenden Hälften bleiben) oder er schreibt ihn auf die Stelle um, die der Marker
wirklich adaptierbar lässt (den Weg zum Träger). Ein Artefakt-Nachzug ist **nicht** die Antwort: der
Ziel-Name *kann* nicht adopter-eigen sein, solange das Fragment konvergent ist.

### 5.2 V-2 — die Sensor-Prosa zählt zwei Aufrufer, der Sensor führt drei

`harness/sensors/archive-welle.md` §Grenze Punkt 2 sagt: *„**Zwei Aufrufer liegen im Prüfbereich**
— `Makefile` und `.claude/settings.json`“*. Mit diesem Slice führt `test/unterkommando-kopplung.bats`
**drei** Quellen des Namens — die dritte ist genau die, die der Slice hinzugefügt hat:

```sh
grep -n 'Aufrufer' harness/sensors/archive-welle.md              # 49: 2. **Zwei Aufrufer liegen im Prüfbereich** — `Makefile` und `.claude/settings.json`, dessen Hooks
grep -n 'Makefile\|settings.json\|archivierung.mk' test/unterkommando-kopplung.bats | head -3
# 8:   `Makefile`              — das Ziel `archive-welle`, der Bedien-Einstieg.
# 9:   `.claude/settings.json` — die Hooks dieses Repos. …
# 12:  `internal/emit/templates/enforce/archivierung.mk` — das emittierte Fragment,
grep -c '^@test' test/unterkommando-kopplung.bats                  # 3 — je eine Quelle
```

Die Zahl steht in der **Grenz-Liste** eines Sensors, den dieser Slice erweitert hat, und ist nicht
mitgezogen. Kein Gate hält sie (dieselbe Lücke, die §3.7 für sich selbst feststellt). Offen und
benannt bleibt die Gegenlesart: `test/unterkommando-kopplung.bats` sagt in Zeile 3 selbst weiter
*„Zwei Aufrufer nennen solche Namen“* und meint damit **Aufrufer dieses Repos** — die dritte Quelle
ist die emittierte Ebene und liegt in einem fremden Repo. Die Sensor-Prosa spricht dagegen vom
**Prüfbereich**, und dort sind es seit diesem Slice drei. **Kein Gate liest das; die Entscheidung
gehört dem, der die Sensor-Landschaft schneidet** — hier gemeldet als Drift, nicht als Verstoß. Die
Klasse ist im Register benachbart (`zusage-neben-geaenderter-ableitung-bleibt-stehen`, offen).

### 5.3 V-3 (INFO) — was der E2E-Beleg für Liefer-Punkt 1 nicht liest

Der E2E prüft die **Wirkung** im Arbeitsbaum (Archiv, beide Stubs, Review-Report fort), nicht die
zwei **Commits**, die der Träger selbst anlegt. Der Satz *„Commit 1 … Commit 2 …“* in der Ausgabe
ist die Meldung des Trägers, und die Zusicherungen des Abschnitts hängen nicht an ihm; sie sind
deshalb auch dann grün, wenn die zwei Commits ausblieben und nur die Dateien wanderten. Dass der
Stand die Zwei-Commit-Trennung wirklich trägt, ist **von mir** in einem eigenen Ziel nachgemessen
(`git log` + leeres `git status`, §2.1) — nicht vom E2E. Für den DoD-Punkt ist das ohne Belang (sein
Gegenstand ist die **Erreichbarkeit**; die Commits trägt die DoD des Archivierungs-Werkzeugs), und
die Sperre *„unsauberer Arbeitsbaum“* ist der Grund, warum der Abschnitt vorher `git status
--porcelain` leer verlangt. Es steht hier, weil ein Leser der Zeile sonst eine Zusicherung mitliest,
die es nicht gibt ([`AGENTS.md`](../../AGENTS.md) §3.6, eine Ebene tiefer).

Ebenso ungemessen im Zweig `(d)`: die Schlusszeile des Abschnitts sagt *„endet mit 0 **und schreibt
nichts**“*; geprüft sind dort `Exit 0`, der Satz über den fehlenden Träger und das Ausbleiben der
`archive-welle ok:`-Zeile. Der Zweig `(a)` prüft dieselbe Hälfte für seinen Fall (`done/welle`
existiert danach nicht). Der Satz ist wahr — ohne Träger führt das Rezept nichts aus —, aber die
Zusicherung darüber fehlt an dieser Stelle.

---

## 6. Was ich nicht geprüft habe, und die Rest-Unsicherheit

1. **Der volle `make mutate`** ist nicht gefahren (§1). Von den sechs neuen Fällen sind **zwei**
   einzeln gefahren; `334`, `336`, `337`, `339` sind in diesem Lauf **nicht** gefahren worden —
   die Runden 1 und 2 haben `334` und `337` (Runde 1) sowie `339` (Runde 2) selbst gefahren;
   ich habe keinen der vier wiederholt. Für die vier gilt die Zusage dieses Berichts **nicht**.
2. **`make gates` ist über dem Worktree gefahren, nicht über dem Hauptbaum** — Grund und Mess-Stand
   stehen im Kopf. Der Hauptbaum trug eine fremde, laufende Änderung; sie in eine Gate-Aussage
   hineinzunehmen hieße, den Zeitpunkt zu messen. Zwischenzeitlich war er fremd rot (§2.4); beim
   Abschluss ist er grün (`EXIT 0`, dieselben Zeilen wie §2.4) — beide Belege stehen in diesem Bericht.
3. **Die Annahme von [`ADR-0051`](../../docs/plan/adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md)
   und die Closure** sind ausgenommen (Kopf). Der Slice ist damit **nicht schließbar**, und der eine
   Grund, der bleibt, ist die eine DoD-Verletzung (§5.1); die ADR-Bedingung (Folgepflicht 1) hat sich
   während dieses Laufs mit `ff6daa84` erledigt.
4. **Zwei Adressen des Plans zeigen ins Leere bzw. auf einen anderen Träger** (§3.4): die zwei
   Zahlen des Anlass-Blocks und der `v5.18.0`-Pfad in §1. Beides ist aufgeschrieben und dem Planner
   übergeben, nichts davon ist still.
5. **Die Gegenlesart zu V-2** ist nicht entschieden — ob die Sensor-Prosa zwei **repo-interne**
   Aufrufer meint (dann bleibt sie richtig) oder ihren **Prüfbereich** (dann führt sie drei). Ich
   habe den Wortlaut beider Stellen zitiert, statt eine Lesart zu setzen.
6. **Der Marker-Vollzug ist an der Text-Hälfte gemessen** (der emittierte Satz des Commands), die
   Lauf-Hälfte derselben Klasse über `(c2)` im E2E. Dass ein Adopter, der das Ziel in der Anleitung
   umbenennt, im Ziel **laut** abbricht, hat der E2E an einem fremden Namen gemessen; ein
   vollständiges Durchspielen der Umbenennung (Anleitung ändern, `init` erneut fahren) ist **nicht**
   gefahren — der Review hat dieselbe Grenze benannt (Runde 1/2, F-1: *„herstellbar nur über eine
   `full-smoke`-Variante“*).

---

## Verdikt

**Liefer-Punkte 1 und 3 tragen — gefahren, nicht übernommen.** Die Erreichbarkeit ist an einem
frisch gebootstrappten Ziel und zusätzlich in einem eigenen `/tmp`-Ziel gemessen, samt der
Sperren-Vererbung aus dem Binär (direkt `3`, über `make` `2` mit `Fehler 3`, nichts geschrieben) und
den zwei Commits, die der E2E nicht liest. `make gates` ist über dem benannten Stand grün, und der
fremd gesehene rote Lauf derselben Wächter ist als Messung über einem bewegten Baum eingeordnet.

**Liefer-Punkt 2 ist nicht erfüllt.** Der Zeiger steht, der ehrliche Ausgang steht daneben — der
dritte Teilsatz ist durch die Lieferung widerlegt und durch eine `Accepted`-ADR-Klasse
unerfüllbar. Das ist die eine **DoD-Verletzung** dieses Laufs, sie ist kein Artefakt-Defekt, und sie
gehört nach [`AGENTS.md`](../../AGENTS.md) §3.10 in die Hand des **Planners**, nicht in einen
Nachzug der Arbeit. Solange sie steht, ist der Punkt „DoD vollständig“ des §5-Closure-Triggers
**nicht erfüllt**, und die Closure ist zusätzlich an die Annahme von
[`ADR-0051`](../../docs/plan/adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md)
gebunden — zwei Gründe, die nicht zusammenfallen. **Der zweite ist mit `ff6daa84` entfallen**,
der erste steht: DoD-Punkt 2 wartet auf den Planner.

**§5-Closure-Trigger, einzeln:** *DoD vollständig* — **nein** (§5.1); *`make full-smoke` grün über
beiden Zweigen* — **ja**, EXIT 0 über `(a)/(b)` und `(d)`; *`make gates` grün* — **ja**, EXIT 0;
*Closure-Notiz mit Steering-Loop-Lerneintrag* — **nicht gefahren** (Planner).

Die drei Befunde eigener Klasse (§5.2, §5.3) sind kein Rückbau: zwei gehören als Adressen und eine
als Grenze in die Closure-Notiz bzw. an den, der die Sensor-Landschaft schneidet. Dieser Report ist
ein **Lauf-Beleg** — er wird über Läufe hinweg nicht wieder gelesen und ersetzt keine Closure
(Modul 11).
