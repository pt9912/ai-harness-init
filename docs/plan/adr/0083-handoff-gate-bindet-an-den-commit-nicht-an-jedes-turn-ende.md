# ADR-0083: Das Handoff-Gate bindet an den Commit, nicht an jedes Turn-Ende — der strenge Modus bleibt per Schalter

**Status:** Accepted

**Datum:** 2026-10-07

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:** [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`MR-002`](../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks),
[`MR-003`](../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung),
[`MR-032`](../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)

**Schärft:** — keine Spec-Stelle trägt das Stop-Verhalten
(`grep -n -i -E 'stop-hook|handoff-gate|stop-require' spec/spezifikation.md spec/architecture.md | wc -l`
→ **0**); die Anforderung steht in [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren).

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR); `AGENTS.md` §3.5 — die
Entscheidung lockert ein Gate, diese ADR ist ihr Träger.

---

## Kontext

**Ist, in beiden Fassungen gleich.** Der Stop-Hook (`.claude/hooks/stop-require-gates.sh` im
Dogfood, `internal/emit/templates/enforce/stop-require-gates.sh` emittiert) gibt frei bei
`stop_hook_active`; ohne Nachweis-Datei bei sauberem Baum; sonst nur, wenn der Inhalts-Hash des
Arbeitsbaums gleich `.harness/state/gates-passed.diffsha` ist. Damit blockiert **jedes** Turn-Ende
mit einer ungedeckten Änderung — auch Rückfrage und Zwischenstand. Die zwei Dateien unterscheiden
sich nur in Kommentaren (Umlaute transliteriert, Umbruch, MR-Verweis allein im Dogfood) und im Pfad
des Hash-Werkzeugs (`harness/tools/` hier, `tools/harness/` im Ziel):
`diff .claude/hooks/stop-require-gates.sh internal/emit/templates/enforce/stop-require-gates.sh`.

**Baseline.** `grundlagen-durchsetzungsschicht.md` (v6.17.0, Z. 30) setzt das Handoff-Gate *„bevor
der Agent ‚fertig' meldet"*; `modul-09-implementierung.md` Schritte 5/6 legen den Gate-Lauf vor den
Handoff. Das Turn-Ende ist strenger als beides.

**Anlass.** CR-1 eines Adopters (v0.4.0); Auftraggeber-Entscheidung 2026-10-07: umsetzen, Default
„nur bei Commit". CR-1 verlangt den strengen Modus als dauerhafte, mit dem Repo reisende
Einstellung und nennt dafür `repo.mk`.

**Variante Subagent-Erkennung — ohne Objekt.** Laut Claude-Code-Hooks-Referenz (Abschnitte
`Stop`/`SubagentStop`; im Repo nicht gemessen) trägt die Stop-Eingabe `session_id`,
`transcript_path`, `cwd`, `permission_mode`, `hook_event_name` und `stop_hook_active` — kein Feld,
das einen Subagenten oder ein „fertig" kennzeichnet; das Ende eines Subagenten feuert
`SubagentStop`, und das ist in keiner Fassung verdrahtet
(`grep -c SubagentStop .claude/settings.json internal/emit/templates/enforce/settings.json` → **0**,
**0**).

## Entscheidung

Wir wählen **Commit-Bindung als Default, das heutige Verhalten als Schalter**. Der Default gilt im
Ziel **und im Dogfood** (Auftraggeber-Setzung 2026-10-07).

**1. Default.** Der Hook blockiert nur, wenn **beides** gilt: die Commit-SHA von HEAD ≠ der beim
letzten grünen Lauf gestempelten SHA, **und** Inhalts-Hash ≠ Hash-Nachweis. Turn-Ende ohne neuen
HEAD seit dem letzten grünen Lauf: frei. Commit, dessen Inhalt der letzte grüne Lauf deckt: frei.
Neuer HEAD mit ungedecktem Inhalt: blockiert. `stop_hook_active` gibt wie heute beim zweiten Mal
frei. **Zugesagt ist „HEAD gleich geblieben", nicht „kein Commit":** wer auf einem Nebenzweig
committet und per `git switch -` oder `git reset --soft` auf die gestempelte SHA zurückgeht, kommt
frei durch.

**2. Ein roter Lauf gibt nie frei.** Er schreibt keinen Stempel: der Nachweis entsteht nur hinter
der Ordnungskante `record-gates: <checks>` (Wächter `test/gate-nachweis-kante.bats`); ein neuer HEAD
bleibt blockiert, bis ein grüner Lauf ihn deckt.

**3. Der HEAD-Stempel ist eine eigene Datei, keine Änderung des Gate-Laufs.** `record-gates.sh`
(beide Fassungen) schreibt nach dem Hash zusätzlich `.harness/state/gates-passed.head` — die
aufgelöste Commit-SHA, keinen symbolischen Ref. Checks, Kante, Hash-Funktion und Format von
`gates-passed.diffsha` bleiben unverändert — die Datei hat weitere Leser (`harness/tools/full-smoke.sh`,
`harness/tools/mutate.sh`), die ein Formatwechsel bräche. Das ist die Lesart des Nicht-Ziels der
CR: ein Zusatz neben dem Nachweis.

**4. Repo ohne Commit — eng erkannt.** `record-gates.sh` und Hook ermitteln den HEAD-Wert auf
dieselbe Weise: `git rev-parse --verify -q HEAD` gelingt → die SHA. Scheitert es, gilt das Repo
**nur dann** als commitlos, wenn zugleich `git symbolic-ref -q HEAD` einen Ref liefert (ungeborener
Zweig) **und** `git rev-list -n1 --all` leer mit Exit 0 endet (kein einziger Commit); dann ist der
Wert der feste Text `kein-commit`, `record-gates.sh` bleibt grün und der Hook vergleicht ihn wie
eine SHA. Jede andere Lage — HEAD zeigt auf einen kaputten oder fehlenden Ref in einem Repo mit
Commits, `rev-list` scheitert — ist ein Git-Fehler und fällt unter §5.
Darunter fällt auch ein frischer `git switch --orphan` in einem Repo mit Commits: `rev-list --all` ist nicht
leer, der Hook endet mit Exit 2 — die strenge Seite; akzeptiertes Negativ. Ein frisches Ziel fährt
`make gates` vor dem ersten Commit (`harness/tools/full-smoke.sh` Stufe des Ziel-Laufs); vor dem
ersten Commit ist das Turn-Ende damit frei, der erste Commit gilt als neuer HEAD.

**5. Fail-closed.** Ohne Stempel-Datei gilt der strenge Zweig — nach dem Update bis zum ersten
grünen Lauf, auf einem Klon mit Änderungen und ohne Lauf; akzeptiertes Negativ, der erste
`make gates` beendet es. **Jeder unerwartete Fehler im Hook endet mit Exit 2 (blockierend)**, nie
mit einem anderen Exit-Code, den Claude Code als Freigabe läse (Hooks-Referenz, im Repo nicht
gemessen); `record-gates.sh` endet bei einem Git-Fehler nach §4 rot und schreibt keinen Stempel.

**6. Schalter — versioniert als Datei, lokal per Umgebung.** Streng gilt, wenn **eine** der zwei
Quellen es sagt:

- **Repo-Einstellung:** die Datei `.harness/stop-gate-streng` existiert (Inhalt bedeutungslos),
  gelesen per `test -e` relativ zur Repo-Wurzel. Sie ist versioniert, reist mit dem Klon und gilt
  für jedes Team-Mitglied; der Modus ist am Repo ablesbar. Sie liegt außerhalb des ignorierten
  `.harness/state/` (`git check-ignore -v .harness/stop-gate-streng` → kein Treffer). Das Werkzeug
  **schreibt sie nie** und löscht sie nie — sie ist Repo-Eigentum, wie jede Datei, die der Lauf
  nicht emittiert.
- **Lokaler Zusatz:** die Umgebungsvariable `STOP_GATE_STRENG` mit Wert genau `1` (Shell, die
  Claude Code startet, oder `env` in `.claude/settings.local.json`, Settings-Referenz, im Repo nicht
  gemessen). Jeder andere Wert und das Fehlen sagen nichts; sie heben eine vorhandene Datei nicht auf.

**Abweichung von CR-1:** die Einstellung steht nicht in `repo.mk`. Kriterium „dauerhaft, mit dem
Repo reisend" erfüllt die Datei ebenso; eine Zeile in make-Syntax müsste der Hook nachbauen, und
jede nicht erkannte Form fiele still auf die lockere Seite (Alternative F). Eine Existenz-Prüfung
kennt keine Fehllesung. **Nicht** in `.claude/settings.json` des Ziels — die Datei ist konvergent
emittiert, der nächste Lauf nähme den Schalter weg. **Grenze:** ein Wert wie `true` oder `yes`, eine
Zuweisung in `repo.mk`/`Makefile` und ein `make`-Aufrufparameter erreichen den Schalter nicht.

**7. Folge-Eintrag zu [`MR-002`](../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)/[`MR-003`](../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung).**
Die Bindung des Handoff-Gates wandert vom Baseline-Punkt *„bevor der Agent ‚fertig' meldet"* auf den
Commit; nach `modul-13-quality-gates.md` §Guard-Härtung ist das ein neuer `MR`, der den Wächter
schärft bzw. lockert, mit mitgezogener Grenz-Zeile: *„eine ‚fertig'-Meldung ohne neuen HEAD geht ohne
Gate-Lauf durch; das Netz dort ist CI auf dem Push"*. Er setzt nach
[`MR-032`](../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
die Kopf-Marke an beide Einträge (Teil-Ablösung). Ihn schreibt der Architect in eigenem
Commit (`AGENTS.md` §3.8), wenn der Slice den Hook ändert.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun | kein Aufwand, strengste Lesart | blockiert Rückfrage und Zwischenstand; strenger als die Baseline; die CR bleibt offen |
| B — Subagent-Erkennung | trifft den Fall, den die CR nennt | die Stop-Eingabe trägt kein solches Feld (§Kontext); ohne Objekt |
| C — Zeitvergleich: Commit-Datum von HEAD gegen mtime des Nachweises | `record-gates.sh` bleibt unberührt | Uhrzeit ist keine Abstammung: `checkout`/`reset` auf einen älteren Commit liest sich als „kein Commit" |
| D — HEAD in `gates-passed.diffsha` mitschreiben | eine Datei | ändert das Format eines Nachweises mit drei Lesern |
| F — Schalter als Zeile in `repo.mk`/`Makefile` (Wortlaut der CR) | Schalter versioniert im Repo | der Hook müsste make-Syntax nachbauen; jede nicht erkannte Form (`export`, `override`, Kommentar, Mehrfachzuweisung) fiele still auf die lockere Seite |
| G — Schalter allein über die Umgebung | keine Datei, kein Lesen | reist nicht mit dem Repo (`.claude/settings.local.json` ist maschinen-lokal); im Team setzt ihn jeder einzeln, am Repo ist der Modus nicht ablesbar — verfehlt CR-1 |
| **E — HEAD-Stempel als eigene Datei, Default Commit-Bindung, Schalter als versionierte Datei `.harness/stop-gate-streng` plus Umgebung** | bindet an den Commit; Nachweis-Format und Gate-Lauf unverändert; strenger Modus reist mit dem Repo, ohne Parser | eine „fertig"-Meldung ohne neuen HEAD ist gate-frei; ein lokales Abschalten des versionierten Modus gibt es nicht |

## Konsequenzen

- Positiv: Turn-Enden ohne neuen HEAD kosten keinen Gate-Lauf mehr; der Commit bleibt gebunden; ein
  Team, das streng arbeiten will, setzt es einmal im Repo.
- Negativ: §Entscheidung 1 (Rückkehr auf die gestempelte SHA), 5 (erster Lauf nach dem Update) und
  7 (Meldung ohne Commit); ein `checkout` auf einen anderen Zweig zählt als neuer HEAD (strenge
  Seite); die Einstellung steht nicht am Ort, den CR-1 nennt (§6).
- Folgepflicht (Planner, ein Slice): beide Hook- und `record-gates.sh`-Fassungen, Schalter,
  Selbstprüfungs-Stufe, bats, Mutationsfälle; die emittierten Command-Vorlagen, die das strenge
  Verhalten zusagen (`internal/emit/templates/commands/implement-slice.md`, `plan-welle.md`,
  `close-welle.md`, je der Stop-Hook-Satz), und der Stop-Hook-Satz in `CLAUDE.md`; Release
  `v0.5.0` (minor: verhaltensändernd im Ziel).
- Folgepflicht (Architect): der `MR` aus §Entscheidung 7.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| bats, über dem **echten** Hook und dem echten `record-gates.sh` in einem tmp-Repo (kein Nachbau, `AGENTS.md` §3.6) | Turn-Ende ohne neuen HEAD mit ungedeckter Änderung → `approve`; neuer HEAD ohne neuen grünen Lauf → `block`; neuer HEAD gedeckten Inhalts → `approve`; Datei `.harness/stop-gate-streng` vorhanden, ohne neuen HEAD → `block`; `STOP_GATE_STRENG=1` ohne neuen HEAD → `block`; `STOP_GATE_STRENG=true` → wie Default; fehlende Stempel-Datei bei ungedeckter Änderung → `block`; Repo ohne Commit: `record-gates.sh` grün, Stempel `kein-commit`, Hook `approve`; Repo mit Commit, HEAD auf einen nicht existierenden Ref umgebogen → `record-gates.sh` rot ohne Stempel, Hook Exit 2; unlesbare Stempel-Datei → Exit 2; `stop_hook_active` → `approve` | `make test` |
| Selbstprüfung des Ziels, am emittierten Hook | Turn-Ende ohne Commit frei; Commit ohne Nachweis blockiert | `make selbstpruefung` (kein Gate), gefahren von `make full-smoke` |
| Mutationsfälle | (1) der SHA-Vergleich wird so verfälscht, dass ein neuer HEAD als gleich gilt → *neuer HEAD ohne neuen grünen Lauf* rot; (2) der Fehlerpfad endet mit Exit 0 statt 2 → *unlesbare Stempel-Datei* rot; (3) der Umgebungs-Schalter wird ignoriert → *`STOP_GATE_STRENG=1`* rot; (4) die Datei-Prüfung wird ignoriert → *Datei vorhanden* rot; (5) die Commitlos-Erkennung entfällt bis auf „rev-parse scheitert" → *HEAD auf nicht existierenden Ref* rot | `make mutate` |

## Re-Evaluierungs-Trigger

- Die Stop-Eingabe von Claude Code führt ein Feld, das Abschluss von Zwischenstand trennt —
  dann Variante B neu prüfen.
- Eine Beobachtung *„Handoff ohne Commit mit rotem Stand durchgelassen"* erreicht 3× im
  Beobachtungs-Register.
- Der Kurs ändert die Definition des Handoff-Gates.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-10-07 | Proposed | Auftraggeber-Entscheidung zu CR-1 eines Adopters (v0.4.0) |
| 2026-10-07 | **Accepted** | Review `2026-10-07-adr-0083-0084-review` mit Nachprüfung (Commit `968f7c6f`); deren N1/N2 nach Vorschlag des Reviewers behoben (Commit `ade73d27`), **nicht erneut nachgeprüft**; §4 vor der Annahme um den `--orphan`-Fall ergänzt; Annahme durch den Auftraggeber am 2026-10-07 ([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1) |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0083` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
