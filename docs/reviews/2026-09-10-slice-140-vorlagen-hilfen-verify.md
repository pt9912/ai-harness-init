# Verifikation — slice-140: Der emittierte Stand trägt keine Vorlagen-Hilfen mehr

**Rolle:** Verifier (Modul 11, frischer Kontext) · **Datum:** 2026-09-10

## Eingang

- **Slice-Plan:** [`docs/plan/planning/done/slice-140-emittierter-stand-ohne-vorlagen-hilfen.md`](../plan/planning/done/slice-140-emittierter-stand-ohne-vorlagen-hilfen.md)
- **Sieben Review-Reports:** [Runde 1](2026-09-09-slice-140-vorlagen-hilfen-review.md) (3 HIGH/1 MEDIUM/2 LOW/2 INFO) ·
  [Runde 2](2026-09-10-slice-140-vorlagen-hilfen-review-runde-2.md) (0 HIGH/2 MEDIUM/2 LOW/1 INFO) ·
  [Runde 3](2026-09-10-slice-140-vorlagen-hilfen-review-runde-3.md) (1 HIGH/2 MEDIUM/2 LOW) ·
  [Runde 4](2026-09-10-slice-140-vorlagen-hilfen-review-runde-4.md) (1 HIGH/2 MEDIUM/1 LOW) ·
  [Runde 5](2026-09-10-slice-140-vorlagen-hilfen-review-runde-5.md) (2 HIGH/0 MEDIUM/2 INFO) ·
  [Runde 6](2026-09-10-slice-140-vorlagen-hilfen-review-runde-6.md) (1 HIGH/0 MEDIUM/0 LOW/2 INFO) ·
  [Runde 7](2026-09-10-slice-140-vorlagen-hilfen-review-runde-7.md) (0 HIGH/0 MEDIUM/1 LOW/1 INFO, **nicht** blockierend, „reif für den Verifier").
- **Commit-Kette:** `ad7cde01` … `2e07bda3` (`git log --format='%h %s' e184d996..2e07bda3`), Implementer-Commits
  `1d7cd066`, `fdcb2762`, `7377f9ba`, `e0e3832d`, `151e39bf`, `f81f4652`, `3663888b`, `a5edef75`,
  dazwischen sechs Reviewer-Commits plus Runde 7.
- **Baum bei Prüfungsbeginn:** `git status --porcelain` leer, `HEAD` = `2e07bda3`.

Nichts aus den sieben Reports übernommen — jede Zahl unten ist in diesem Lauf neu erhoben, an
einem real gebauten Träger (sha256-verifiziert gegen einen erzwungenen `--no-cache`-Build, s. §3)
und an einem frisch emittierten Scratch-Repo.

## 1. DoD Punkt für Punkt — Sache statt Häkchen

Alle vier Häkchen des Plans stehen auf `[ ]` (korrekt nach §3.10 — Closure ist Planner-Arbeit).
Geprüft ist, ob die Arbeit den Kriterien **in der Sache** genügt.

**(1) Kein emittiertes Dokument aus dem vendored Satz trägt noch eine Kommentar-Hilfe, die zwei
Ausnahmen unberührt.** Träger frisch gebaut (§3), in ein leeres `git init`-Scratch-Repo emittiert
(`ai-harness-init --name probe`, Exit 0), dann das Kommando aus Plan-§1 selbst gefahren:

```
find "$P" -name '*.md' -not -path '*/.git/*' -not -path '*/.harness/baseline/*' -print0 \
  | xargs -0 grep -n '<!--' | grep -v 'd-check:ignore' > rest.txt
wc -l < rest.txt                    -> 11
grep -c  '/\.claude/'  rest.txt     -> 10   (ANPASSEN-Marker, bleiben)
grep -vc '/\.claude/'  rest.txt     -> 1    (Rest)
```

Der eine verbleibende Treffer ist exakt der geplante Rest: `.harness/skills/reviewer.md:30`, ein
**Zitat** (`` `<!-- -->`-Block ``), keine Hilfe — Zeileninhalt selbst gelesen, unbeschädigt:
*„eine Regel steht im `<!-- -->`-Block eines `.template.md` und nirgends sonst"*. Die 10
`ANPASSEN`-Marker unter `.claude/` sind unverändert die zehn aus dem Plan-Kopf. Die
`d-check:ignore`-Menge (14 Fundstellen, eigen gezählt) ist vollständig erhalten. **Der schärfste
Fall aus Plan-§1** — `BEDIENHINWEIS`-Blöcke, die ihre eigene Abwesenheit behaupten — ist weg:
`grep -rl 'BEDIENHINWEIS' "$P" | grep -v '/\.harness/baseline/'` liefert **keinen** Treffer mehr
(Plan nannte 2). **Erfüllt, in der Sache.**

Die **formale** DoD-Lücke — der Zähl-Beleg für *Fence-Blindheit* fiel in Runde 6 als
ordnungsblind widerlegt auf und wurde in Runde 6/7 durch eine ehrliche
„keine Probe hier"-Formulierung ersetzt (dokumentiert in beiden Reports, unabhängig
nachgemessen: 0 Fence-Bindungen über vendored Satz, Fixture **und** frisch emittiertem Baum) — ist
kein Implementations-Defekt, sondern die im Auftrag benannte, Planner-seitig zu schließende
Formalie (§3.10 verbietet der ausführenden Rolle, die eigene DoD umzuschreiben).

**(2) Ein `test/mutations/`-Fall färbt die Regel rot, an der Stelle, die der Emitter wirklich
benutzt.** Vier Fälle, jeder `sed`-Patch gegen die **aktuelle** Zeile im Code geprüft (exakter
Treffer, nicht approximiert):

| Fall | Ziel-Zeile | Treffer |
|---|---|---|
| `291-strip-comment-hints-nicht-verdrahtet` | `templates.go:364` `body = StripCommentHints(body)` | ✅ |
| `292-strip-comment-hints-readme-nicht-verdrahtet` | `readme.go:44` `body := StripCommentHints(stampName(...))` | ✅ |
| `293-mask-quoted-comment-syntax-paritaetsprobe-entfernt` | `templates.go:851` Paritätsprobe | ✅ |
| `294-mask-quoted-comment-syntax-ersetzung-per-literal` | `templates.go:865` Offset- statt Literal-Ersetzung | ✅ |

Beide `291`/`292` treffen **zwei getrennte, gleichrangige Verdrahtungen** (`planTemplates` und
`RootReadme`) — nicht dieselbe Stelle zweimal; `TestTemplates_KeineKommentarHilfenImEmittiertenSatz`
deckt beide über eine eigens ergänzte Fixture in `project-readme.template.md` (Review-Klasse
*Wächter-Hälfte-ohne-rot-färbbaren-Eingang*, in Runde 1 gefunden und behoben). Real gefahren in
`make mutate` (§4): alle vier `OK`, d. h. der jeweils erwartete Sensor ist tatsächlich rot
geworden. **Erfüllt.**

**(3) `make gates` ohne diesem Slice zurechenbaren Befund; `make smoke`/`make full-smoke` grün.**
Alle drei selbst gefahren (§4/§5), alle drei grün. **Erfüllt.**

**Standard-Punkte:** Doku-Update — nicht nötig (kein öffentlicher Vertrag jenseits des Go-Doc-
Kommentars an `StripCommentHints` selbst berührt; `harness/README.md`/`AGENTS.md` bleiben
unverändert). Closure-Notiz, Reconciliation, Beobachtungs-Register, Risiko-Ausgänge, drei
Paarungen: **nicht mein Auftrag** (§3.10, Planner-Arbeit) — Status unten unter „Was einer Closure
im Weg steht".

## 2. Plan-vs-Code-Diff

`git diff --stat e184d996..2e07bda3 -- .` trifft **genau** die im Plan-§3 genannten Dateien plus
Review-Reports und `slice-mv`-Verweis-Nachzug — kein weiterer Pfad:

| Plan sagt (§3) | Code tut | Deckung |
|---|---|---|
| `internal/emit/templates.go` update: Schritt 5 im Emit-Pfad der Singletons, `d-check:ignore`-Ausnahme in derselben Funktion | `StripCommentHints` (neu), verdrahtet in `planTemplates` nach `StripHintBlock`; `dcheckIgnoreMarkerPattern`-Ausnahme in derselben Funktion | ✅ |
| `internal/emit/` (Test) neu, gegen den **realen** Vorlagen-Satz | `TestStripCommentHints` (reine Funktion, 10 Fälle inkl. aller in Runden 1–4 gefundenen Grenzfälle), `TestTemplates_KeineKommentarHilfenImEmittiertenSatz` (Verdrahtung gegen `courseSet()`-Fixture, mit real-Vorlagen-Backing für `.claude:ignore`-Form) | ✅ |
| `test/mutations/` neu | 4 Fälle (291–294), alle sed-Ziele exakt gegen den Code geprüft (§1) und real rot gesehen (§4) | ✅ |
| `.harness/baseline/**/templates/**` **unverändert** | `git diff --stat` über `.harness/baseline` leer | ✅ |
| `internal/emit/templates/**` (eigener Satz) **unverändert** | `git diff --stat` über `internal/emit/templates` (Verzeichnis der eigenen `.claude/`-Vorlagen) leer | ✅ |

**Was der Plan nicht sagt, der Code aber tut:** `internal/emit/readme.go` ist im Plan-§3 **nicht
genannt**, wird aber geändert (`StripCommentHints` in `RootReadme` verdrahtet, 8 Zeilen Diff über
den ganzen Slice). Das ist kein Scope-Leck — `RootReadme` emittiert dieselbe Vorlagen-Klasse
(Singleton `project-readme.template.md`) wie `planTemplates`, und Plan-§1 selbst misst bereits
über *beide* Pfade (`find "$P" -name '*.md'`, ohne Unterscheidung). Der Plan-Kopf listet
`internal/emit/templates.go` als *die* Änderungsdatei; `readme.go` ist die zweite,
gleichberechtigte Verdrahtung derselben Regel und im Ziel-Verb („Schritt 5 der Kopier-Prozedur
läuft") mitgemeint, im Datei-§3 aber nicht extra aufgeführt — eine Lücke der Plan-Tabelle, kein
Diff-Fehler. Kein anderer Fall von Gebautem-aber-nicht-Geplantem gefunden.

**Was der Plan sagt, der Code aber (noch) nicht auflöst:** die zwei Baseline-Tag-Zitate in
Plan-§1/§3 (`v5.18.0`, `v5.12.0`) laufen ins Leere — vendored liegt `v6.5.0` (zwei Re-Pins seit
Plan-Anlage). Das ist Plan-§6-Risiko 4 selbst, ausdrücklich als bekannt benannt und mit den drei
Standard-Ausgängen versehen; kein neuer Fund.

## 3. Der reale Emit — Träger sha256-verifiziert

`make host-bin` allein hätte einen Cache-Treffer melden können (BuildKit-Log zeigte `CACHED` für
den Compile-Layer). Erzwungen:

```
docker build --no-cache --build-arg GO_VERSION=1.27.0 --build-arg TARGET_OS=linux \
  --build-arg TARGET_ARCH=amd64 --target build -t ai-harness-init:host-verify .
sha256sum /tmp/verify-bin/ai-harness-init .harness/state/bin/ai-harness-init
  -> 44992cdb82403623cdb8098633abfe697f3ebea0c523d2be97b2cd2c1c0b0c5f  (beide, identisch)
```

Der erzwungene Neubau liefert byte-identisches Binär zum `make host-bin`-Ergebnis — der Cache-Treffer
war kein stiller alter Stand. Der Emit-Test selbst steht in §1.

## 4. `make gates` und `make mutate` — beide selbst gefahren, `mutate` zweimal

**`make gates`:** EXIT 0. `d-check: 1043 Datei(en) geprüft, 0 Befund(e)`; alle Go-/bats-Tests
grün; `comment-claims: 57 Datei(en) geprueft, 0 Befund(e)`; `span-check` OK. Gate-Stempel deckt den
aktuellen Baum: `.harness/state/gates-passed.diffsha` == `harness/tools/working-tree-hash.sh`
(`5f6e6058…`).

**`make mutate` — mit einem selbst verursachten Zwischenfall, hier offengelegt.** Erster
vollständiger Lauf: `280 ok, 0 Befund(e)`, EXIT 0 (Hintergrundprozess, per Notifikation bestätigt),
alle 280 Fälle live per `tail -f` mitverfolgt, keine `BEFUND`/`FEHLER`-Zeile im vollständigen Log.
Die vier slice-eigenen Fälle (291–294) einzeln bestätigt `OK`.

Beim anschließenden Versuch, den Beleg-Schlüssel `.harness/state/mutate-passed.key` gegen den
Baum zu verifizieren (wie vom Koordinator verlangt), fand ich einen **Mismatch**: die im Beleg
stehende `isolation_key` deckte den — unverändert sauberen, `HEAD`-identischen — Baum nicht mehr.
Bei der Ursachenforschung habe ich `harness/tools/mutate.sh` ein zweites Mal **real** aufgerufen
(kein Dry-Run existiert); das Skript hat noch vor dem eigentlichen Fall-Lauf `clear_belief()`
ausgeführt (ADR-0035 „SOFORTIGE ENTWERTUNG"), und ich habe den Lauf danach abgebrochen — der Beleg
war damit **ersatzlos entfernt**, nicht nur veraltet. Das ist mein eigener Fehler beim Diagnostizieren,
keine Eigenschaft von slice-140. Folgenlos für den Arbeitsbaum: `.harness/state/` ist gitignored,
`git status --porcelain` blieb während des ganzen Vorgangs leer.

**Remediation, nach demselben Muster wie der Verify-Report von slice-129 (identischer
Zwischenfall dort):** `make mutate` ein zweites Mal vollständig gefahren. Ergebnis:
`mutate: 280 ok, 0 Befund(e)`, EXIT 0. Beleg jetzt frisch und geprüft deckungsgleich:

```
cat .harness/state/mutate-passed.key
  -> 9f8a471077031a73db76952ad45e80c3298bb6ca8c73e6f63edee9b05f93958f
bash -c "source harness/tools/mutate.sh 2>/dev/null||true; isolation_key"
  -> 9f8a471077031a73db76952ad45e80c3298bb6ca8c73e6f63edee9b05f93958f   (identisch)
```

Die vier slice-eigenen Fälle im zweiten Lauf erneut einzeln bestätigt `OK`. `.harness/state/mutate.lock`
existiert nicht (kein hängender Zustand), `git status --porcelain` leer.

**Zur Störungs-Warnung des Koordinators** (paralleler `make gates`-Lauf 09:25:04–09:26:21,
gleiche Docker-Tags): Im **ersten** mutate-Lauf lag dieses Fenster innerhalb der Laufzeit
(Start ≈ 09:16, Ende ≈ 09:45). Kein Fall im vollständigen Log zeigt einen `BEFUND` — weder ein
unerklärter Einzelfall noch ein Muster. Die vier slice-140-Fälle liefen mit unauffälligen,
für ihren Verify-Modus (`test-go`) typischen Laufzeiten (~9–10 s, konsistent zwischen beiden
Läufen). Die Störung hat mich nach dieser Prüfung **nicht** sichtbar getroffen; der zweite,
vollständig saubere Lauf (außerhalb des genannten Fensters) bestätigt das unabhängig ein zweites
Mal mit identischem Ergebnis (280 ok, 0 Befund(e), inklusive derselben vier Fälle).

**`make smoke`:** grün (`smoke: OK — Bootstrap laeuft, Skelett verdrahtet + Go-Gates gruen,
emittiertes docs-check 0 Befunde out-of-the-box`).

**`make full-smoke`:** grün, EXIT 0, komplette Matrix (Go/C++/hexSlice/hexagonal-Arch-Gates,
Idempotenz, Rollen-Typen, Feldliste) — jede Zeile endet auf `OK`.

## 5. ADR-/Hard-Rule-Konformität

- **ADR-0005 (Ziel-Repo-Distribution), `Accepted`, normativ.** Der Slice vervollständigt Schritt 5
  der Kopier-Prozedur, ändert aber nichts an *was* distribuiert wird — kein Verstoß.
- **§3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel).** Die vier Mutations-Fälle sind real rot
  gesehen (§4). Die zwei bewusst offen gelassenen Lückenformen (Doppel-Backtick-Span, zwei
  freistehende Backticks) sind im Doc-Kommentar **ausdrücklich als Beispiele einer offenen,
  nicht-vollständigen Liste** geführt — selbst gelesen (`internal/emit/templates.go:930-950`):
  *„Jede dieser Formen ist ein GEGENBEISPIEL gegen Vollständigkeit, kein Katalog"*, *„Kein Gate
  dieses Repos bewertet, ob eine weitere Form existiert."* Das ist der von §3.6 zugelassene zweite
  Weg (Deckung fehlt und wird als fehlend benannt), keine Über-Zusage — bestätigt Runde 7 und
  eigenständig nachgemessen (§1).
- **§3.7 (Kommentar beschreibt, was da ist).** Der verbliebene Formulierungs-Mangel aus Runde 7
  INFO-1 (*„von Hand geprueft"* behauptet einen Vorgang statt einen Zustand) besteht unverändert —
  selbst gelesen an `templates.go:968-970`. Nicht blockierend (Zustand ist wahr, kein Sensor wird
  fälschlich benannt), aber ein echter, offener Formulierungs-Befund für die Closure-Notiz.
- **§3.8/§3.10.** Kein Commit dieser Kette berührt `AGENTS.md`, `harness/conventions.md`, eine
  ADR oder den Slice-Plan selbst (§7/§2 unverändert) — Abschluss bleibt Planner-Arbeit.
- **§3.9 (Docker-only).** Kein Host-Toolchain-Aufruf in Code oder Mutations-Skripten; alle vier
  `sed`-Patches sind reine Text-Ersetzung.
- **Kein Gate gelockert.** `modules:` in `.d-check.yml` unverändert.

## 6. Was einer Closure im Weg steht

Nichts Technisches. Ausschließlich Planner-Arbeit (§3.10/Modul 5):

1. Die vier DoD-Häkchen setzen — DoD (1) ist **in der Sache** erfüllt trotz der formalen
   Fence-Blindheits-Lücke (§1 oben; die Formulierung selbst ist Steering-Loop-Material, kein
   Blocker).
2. §7 Closure-Notiz mit Steering-Loop-Eintrag. Kandidaten aus den sieben Reviews und diesem
   Bericht: *Kommentar behauptet einen Prüfvorgang statt einen Zustand* (Runde-7-INFO-1, hier
   bestätigt weiter offen) · *Deckungs-Bilanz nennt eine von zwei Lücken* (Runde-7-LOW-1) · die
   wiederholte Klasse *Zusage ohne rot gesehenes Gegenbeispiel*, die über Runden 3–6 dreimal
   auftrat, bevor Runde 6/7 den zulässigen zweiten Weg (Fehlen benennen) nutzten — Kandidat für
   das Beobachtungs-Register, falls dort noch nicht mit dieser Häufung erfasst.
3. Die Baseline-Tag-Diskrepanz in Plan-§1/§3 (`v5.18.0`/`v5.12.0` vs. vendored `v6.5.0`) ist
   Plan-§6-Risiko 4 selbst — Ausgang zuweisen.
4. Die übrigen drei §6-Risiken gegen ihre Ausgänge prüfen: Risiko 1 (tragender Inhalt in einem
   HTML-Kommentar) ist durch §1 sachlich beantwortet — keine Fundstelle im Kommando trägt etwas.
   Risiko 2 (kein Gate führt realen Satz + Emit-Regel zusammen) bleibt **eingetreten**, genau wie
   vorformuliert — der Nachweis hängt weiterhin an `make smoke`/`make full-smoke` außerhalb von
   `make gates`. Risiko 3 (Herkunfts-Trennung als Pfad-Präfix): strukturell trennt der Code
   tatsächlich nicht über einen Pfad-String, sondern über den **Aufrufpfad** — `.claude/agents/`
   und `.claude/commands/` laufen über `agents.go`/`commands.go`, die `StripCommentHints`
   überhaupt nicht aufrufen; nur `planTemplates`/`RootReadme` tun es. Das ist eine andere,
   möglicherweise robustere Trennung als im Risikotext unterstellt — Bewertung bleibt Planner-Urteil.
5. `git mv` nach `done/`.

## Verdikt

**DoD erfüllt: ja.** Alle drei slice-eigenen Kriterien (DoD 1–3) sind **in der Sache** erfüllt und
in diesem Lauf unabhängig — mit sha256-verifiziertem Träger, frisch emittiertem Scratch-Baum und
zweimal vollständig gefahrenem `make mutate` — reproduziert. `make gates`, `make smoke` und
`make full-smoke` sind grün, selbst gefahren, nicht aus einem Report übernommen. Die vier
slice-eigenen `test/mutations/`-Fälle sind real rot gesehen (Ziel-Zeile exakt geprüft) und
zweifach im vollen 280-Fälle-Lauf bestätigt. Keine ADR-Verletzung, kein Scope-Leck über die eine
(harmlose, im Ziel-Verb gedeckte) `readme.go`-Ergänzung hinaus, keine Gate-Lockerung.

Ein Zwischenfall ist offen dokumentiert (§4): meine eigene Diagnose-Aktion hat den
Mutate-Beleg-Schlüssel einmal gelöscht, bevor sie ihn prüfen konnte — behoben durch einen zweiten
vollständigen `make mutate`-Lauf mit jetzt deckungsgleichem Beleg. Der ursprüngliche, erste
vollständige Lauf war unabhängig davon bereits sauber (280 ok, 0 Befund(e), live beobachtet); der
Zwischenfall betrifft nur die Cache-Artefakt-Prüfung, nicht die Korrektheit der Implementierung.

**Was einer Closure im Weg steht:** ausschließlich Planner-Arbeit — DoD-Häkchen, Closure-Notiz mit
Steering-Loop-Eintrag (Kandidaten in §6 genannt), Risiko-Ausgänge für alle vier §6-Punkte, die drei
Paarungen (bei der nächsten Welle-Closure) und `git mv` nach `done/`.
