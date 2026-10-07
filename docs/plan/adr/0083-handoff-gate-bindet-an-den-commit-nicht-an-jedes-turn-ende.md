# ADR-0083: Das Handoff-Gate bindet an den Commit, nicht an jedes Turn-Ende — der strenge Modus bleibt per Schalter

**Status:** Proposed

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
„nur bei Commit".

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

**4. Repo ohne Commit.** Hat das Repo keinen HEAD (ein frisches Ziel fährt `make gates` vor dem
ersten Commit, `harness/tools/full-smoke.sh` Stufe des Ziel-Laufs), schreibt `record-gates.sh` den
festen Wert `kein-commit` und bleibt grün; der Hook ermittelt den aktuellen Wert auf dieselbe Weise
und vergleicht ihn wie eine SHA. Vor dem ersten Commit ist das Turn-Ende damit frei, der erste
Commit gilt als neuer HEAD.

**5. Fail-closed.** Ohne Stempel-Datei gilt der strenge Zweig — nach dem Update bis zum ersten
grünen Lauf, auf einem Klon mit Änderungen und ohne Lauf; akzeptiertes Negativ, der erste
`make gates` beendet es. **Jeder unerwartete Fehler im Hook endet mit Exit 2 (blockierend)**, nie
mit einem anderen Exit-Code, den Claude Code als Freigabe läse (Hooks-Referenz, im Repo nicht
gemessen).

**6. Schalter `STOP_GATE_STRENG` — allein die Umgebung des Hooks.** Wert genau `1` stellt das heutige
Verhalten her; jeder andere Wert und das Fehlen gelten als Default. Der Hook liest keine Datei und
führt kein `make` aus. Die Umgebung des Hooks ist die des Claude-Code-Prozesses: gesetzt wird der
Schalter in der Shell, die Claude Code startet, oder unter `env` in `.claude/settings.local.json`
(Settings-Referenz, im Repo nicht gemessen). **Nicht** in `.claude/settings.json` des Ziels — die
Datei ist konvergent emittiert, der nächste Lauf nähme ihn weg. **Grenze:** ein Wert wie `true` oder
`yes`, eine Zuweisung in `repo.mk`/`Makefile` und ein `make`-Aufrufparameter erreichen ihn nicht;
dann gilt der Default.

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
| F — Schalter zusätzlich als Zeile in `repo.mk`/`Makefile` lesen | Schalter versioniert im Repo | der Hook müsste make-Syntax nachbauen; jede nicht erkannte Form (`export`, `override`, Kommentar, Mehrfachzuweisung) fiele still auf die lockere Seite |
| **E — HEAD-Stempel als eigene Datei, Default Commit-Bindung, Schalter allein über die Umgebung** | bindet an den Commit; Nachweis-Format und Gate-Lauf unverändert; heutiges Verhalten per Variable | eine „fertig"-Meldung ohne neuen HEAD ist gate-frei; der Schalter ist nicht im Repo versioniert |

## Konsequenzen

- Positiv: Turn-Enden ohne neuen HEAD kosten keinen Gate-Lauf mehr; der Commit bleibt gebunden.
- Negativ: §Entscheidung 1 (Rückkehr auf die gestempelte SHA), 5 (erster Lauf nach dem Update) und
  7 (Meldung ohne Commit); ein `checkout` auf einen anderen Zweig zählt als neuer HEAD (strenge
  Seite).
- Folgepflicht (Planner, ein Slice): beide Hook- und `record-gates.sh`-Fassungen, Schalter,
  Selbstprüfungs-Stufe, bats, Mutationsfälle; die emittierten Command-Vorlagen, die das strenge
  Verhalten zusagen (`internal/emit/templates/commands/implement-slice.md`, `plan-welle.md`,
  `close-welle.md`, je der Stop-Hook-Satz), und der Stop-Hook-Satz in `CLAUDE.md`; Release
  `v0.5.0` (minor: verhaltensändernd im Ziel).
- Folgepflicht (Architect): der `MR` aus §Entscheidung 7.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| bats, über dem **echten** Hook und dem echten `record-gates.sh` in einem tmp-Repo (kein Nachbau, `AGENTS.md` §3.6) | Turn-Ende ohne neuen HEAD mit ungedeckter Änderung → `approve`; neuer HEAD ohne neuen grünen Lauf → `block`; neuer HEAD gedeckten Inhalts → `approve`; `STOP_GATE_STRENG=1` ohne neuen HEAD → `block`; `STOP_GATE_STRENG=true` → wie Default; fehlende Stempel-Datei bei ungedeckter Änderung → `block`; Repo ohne Commit: `record-gates.sh` grün, Stempel `kein-commit`, Hook `approve`; unlesbare Stempel-Datei → Exit 2; `stop_hook_active` → `approve` | `make test` |
| Selbstprüfung des Ziels, am emittierten Hook | Turn-Ende ohne Commit frei; Commit ohne Nachweis blockiert | `make selbstpruefung` (kein Gate), gefahren von `make full-smoke` |
| Mutationsfälle | (1) der SHA-Vergleich wird so verfälscht, dass ein neuer HEAD als gleich gilt → *neuer HEAD ohne neuen grünen Lauf* rot; (2) der Fehlerpfad endet mit Exit 0 statt 2 → *unlesbare Stempel-Datei* rot; (3) der Schalter wird ignoriert → *`STOP_GATE_STRENG=1`* rot | `make mutate` |

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

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0083` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
