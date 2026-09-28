# Review-Report: slice-amend-haelt-den-index-pfadrein — 2026-09-28

**Review-Art:** Code — gegen Plan (`docs/plan/planning/in-progress/slice-amend-haelt-den-index-pfadrein.md`)
+ Architect-Verdikt (Plan §1) + Hard Rules. **Nicht** gegen DoD/Spec (Verifier-Sache, Modul 11).

**Gegenstand:** Commit `6c59c934` "Rolle Implementer: slice-amend-haelt-den-index-pfadrein --
Traeger .githooks/pre-commit haelt --amend gegen fremde Index-Eintraege ab". Betrachteter
Diff-Bereich für den inhaltlichen Delta des Slice-Plans: `75f03e82..6c59c934` (Move-Commits
`f1b74dbb`/`75f03e82` sind reine `git mv`, tragen keinen Inhalt).

**Skill:** `.harness/skills/reviewer.md` v2.3.0 (2026-09-27) · **Modell:** claude-sonnet-5 ·
**Datum:** 2026-09-28.

**Eingangs-Kontext:**

- `docs/plan/planning/in-progress/slice-amend-haelt-den-index-pfadrein.md` (inkl. §1
  Architect-Verdikt: Träger `.githooks/pre-commit`, schreibende Rolle Implementer, kein ADR-Bedarf,
  MR-Eintrag folgt als Architect-Folgeschritt)
- `AGENTS.md` §3.6, §3.7, §3.8, §3.10
- Baseline-Regelwerk `modul-08-agentenrollen.md` (Rollen-Trennung), `modul-13-quality-gates.md`
  §Guard-Härtung, `grundlagen-harness-dateien.md` §Was ein Kommentar trägt
- `ADR-0028` (Anweisungssatz gehört der ausführenden Rolle — vom Architect-Verdikt selbst geprüft
  und für nicht einschlägig befunden)
- `harness/README.md` §Traceability (bestehende `commit-msg`-Trägerform als Präzedenzfall)

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | `make hooks-install` prüft/setzt das Ausführ-Bit nur für `.githooks/commit-msg` (`test -x .githooks/commit-msg \|\| chmod +x .githooks/commit-msg`), nicht für den neu hinzugekommenen `.githooks/pre-commit`. Der Kommentar direkt über dem Target nennt genau diese Probe als Schutz gegen einen Klon, der das Ausführ-Recht einer Hook-Datei verliert ("git verwirft einen nicht ausfuehrbaren Hook still"). Verliert `.githooks/pre-commit` in einem Klon sein x-Bit, überspringt git ihn kommentarlos, `make hooks-install` meldet trotzdem Erfolg, und der Amend-Guard ist lautlos inaktiv — genau das Szenario, gegen das dieser Slice antritt (paralleler Vorgang + `--amend`), bleibt dann ungeschützt. | `LH-QA-02` (Reproduzierbarkeit) | `Makefile:284-287` | ja — Klon mit `chmod -x .githooks/pre-commit`, `make hooks-install`, dann `--amend`-Szenario nachstellen | Aktivierendes Kommando prüft das Exec-Bit nur für den ursprünglichen Hook, nicht für den neu hinzugekommenen Nachbarn |
| F-2 | MEDIUM | Der Plan (§3) sagt für neue Werkzeuge eine Doku-Aktualisierung "analog der bestehenden commit-msg-Tabelle" zu. Umgesetzt wurde ein Prosa-Absatz am Ende von §Traceability; die tatsächlich analoge Stelle — die `make hooks-install`-Zeile in der Werkzeuge-Tabelle (`harness/README.md:88`) sowie der Makefile-Zielkommentar und die Laufzeit-`printf`-Meldung (`Makefile:284,287`) — wurden nicht angefasst und beschreiben den Befehl weiterhin ausschließlich als Aktivierung des `commit-msg`-Trägers, obwohl dieselbe `core.hooksPath`-Umstellung jetzt auch den Amend-Guard aktiviert. | Plan §3 (Doku-Pflicht-Zeile) | `harness/README.md:88`, `Makefile:284`, `Makefile:287` | ja — Lesevergleich Zeile gegen tatsächliches Verhalten von `core.hooksPath` | Werkzeug-Beschreibung bleibt bei Erweiterung auf den ursprünglichen Einzelzweck fixiert |
| F-3 | LOW | Der Mutations-Fall `497-pre-commit-amend-guard-blankoscheck.sh` nennt im `# expect:`-Kopf genau einen Test. Gegenprobe (genannten Test aus der bats-Kopie entfernt, Mutation weiter angewandt, volle Suite gefahren): Ein zweiter, bereits vorhandener Test ("decide: AMEND_EXPECTED_PATHS mit einem fremden, nicht betroffenen Pfad haelt trotzdem an (kein Blankoscheck)") färbt ebenfalls rot und bindet die Mutation allein — beide Tests prüfen dieselbe unvollständige-Bestätigung-Eigenschaft am selben `if [ -z "$missing" ]`-Zweig, kein struktureller Nebeneffekt einer gemeinsamen Erfolgs-Ausgabe-Senke. Der Fall-Kopf behauptet keine Exklusivität, daher kein HIGH/kein zwingendes MEDIUM. | Reviewer-Skill §Klassifikation, LOW/INFO-Eskalation "Mutations-Fall nennt einen Test, die Mutation färbt mehrere" | `test/mutations/497-pre-commit-amend-guard-blankoscheck.sh`, `test/pre-commit-amend-guard.bats:84-88` | ja — Gegenprobe wie oben, real gefahren (dieser Report) | Mutations-Fall nennt einen Test, die Mutation färbt mehrere |
| F-4 | LOW | Der Kommentar über `shell-lint` erklärt die Einzel-Nennung von `.githooks/commit-msg` ("traegt keine .sh-Endung … wird darum einzeln genannt statt ueber einen Glob"), wurde aber nicht erweitert, als `.githooks/pre-commit` aus demselben Grund ebenfalls einzeln in dieselbe Zeile aufgenommen wurde — der Kommentar liest sich weiterhin, als beträfe die Begründung nur eine Datei. | Maintainability (Doku-Drift) | `Makefile:203-205` | ja — Lesevergleich | Kommentar zur Einzel-Nennung nicht nachgezogen bei zweitem gleichartigen Fall |
| F-5 | LOW | Die DoD-Zeile "`make gates` grün" zitiert Working-Tree-Hash `0a22d05ba9…`; der tatsächlich zuletzt aufgezeichnete und mit dem finalen Commit übereinstimmende Stand ist `a4498ea475…` (`.harness/state/gates-passed.diffsha`, deckungsgleich mit dem aktuellen Arbeitsbaum). Ursache ist der Selbstbezugs-Effekt (das Eintragen des Hashs in dieselbe Datei ändert den Hash) — vom Implementer im Auftrag selbst als kosmetischer Rest benannt. Der zugrunde liegende Beleg (Gate lief grün am final committeten Stand) ist real und unabhängig nachvollziehbar; nur die im Fließtext zitierte Zahl ist veraltet. | Maintainability | `docs/plan/planning/in-progress/slice-amend-haelt-den-index-pfadrein.md:134` | ja — `.harness/state/gates-passed.diffsha` gegen `bash harness/tools/working-tree-hash.sh` | Gate-Hash in derselben Datei referenziert sich selbst (Selbstbezugs-Effekt) |
| F-6 | INFO | Der neue Link `[harness/tools/pre-commit-amend-guard.sh](../harness/tools/pre-commit-amend-guard.sh)` in `harness/README.md` löst korrekt auf (Basisverzeichnis `harness/`, `..` kompensiert), verwendet aber eine unüblich lange Form gegenüber der im selben Verzeichnis sonst üblichen kürzeren `tools/…`-Form. Rein stilistisch, kein Doc-Gate-Befund. | Maintainability | `harness/README.md:204` | ja — `make docs-check` (bereits grün) | Unübliche, aber funktionierende relative Link-Form |
| F-7 | INFO | Der Kopfkommentar von `harness/tools/pre-commit-amend-guard.sh` führt sechs benannte Abschnitte (ZUSAGE/ERKENNUNG/ENTSCHEIDUNG/GRENZE/ABGRENZUNG/BELEG) gegenüber den fünf Klassen aus `AGENTS.md` §3.7. Der Baseline-Regel nach ist eine sechste Klasse zulässig ("wer eine sechste Klasse findet … erweitert sie"); BELEG liest sich inhaltlich aber als ausführliche Illustration der bereits vorhandenen ZUSAGE-Klasse ("mit dem Sensor, der es sähe") und nicht als eigenständig neue Frage-Kategorie. Kein Verstoß, nur ein Hinweis für eine mögliche Straffung. | AGENTS.md §3.7 | `harness/tools/pre-commit-amend-guard.sh:1-70` | nein — Urteilsfrage, kein Sensor | Sechster Kommentar-Abschnitt liest sich als Illustration einer bestehenden Klasse |
| F-8 | INFO | Der git-fassende Pfad (PPID-Kommandozeile lesen, `git diff-tree`/`git diff --cached`, Verdrahtung nach `decide()`) hat keinen automatisierten Regressionstest — nur die reinen Funktionen `has_amend_flag()`/`decide()` sind über bats gedeckt, weil das gepinnte bats-Image kein `git` führt. Dieselbe, bereits akzeptierte Grenze wie bei `history-range-guard.sh`; im Skript-Kopf selbst offen benannt, nicht verschwiegen. | Maintainability | `harness/tools/pre-commit-amend-guard.sh` (voller Lauf, ab `read_ppid_cmdline`) | nein — bekannte, dokumentierte Testlücke | Git-fassender Pfad ohne automatisierten Regressionstest (dokumentierte Grenze) |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Architect-Verdikt (Plan §1) eingehalten | geprüft, ohne Befund — kein ADR angelegt, kein Adaptions-Block-Eintrag vom Implementer geschrieben; die Verdikt-Prosa selbst stammt aus einem Commit vor dem Implementer-Commit (`git diff 75f03e82..6c59c934` zeigt an §1 nur DoD-Häkchen/Plan-Tabellen-Zeilen als Delta, kein Text-Eingriff in den Verdikt-Abschnitt) |
| Erkennung von `--amend` (Kopfkommentar §ERKENNUNG) | geprüft, ohne Befund — Indikativ über gemessenes `commit_source`-Verhalten von `prepare-commit-msg`, keine Konjunktiv-Chronik einer verworfenen Alternative; passt zur Abgrenzung-Klasse aus `AGENTS.md` §3.7 |
| Plattform-Grenze (kein `/proc`) | geprüft, ohne Befund — als GRENZE benannt ("Ohne lesbares `/proc/$PPID/cmdline` und ohne funktionierendes `ps -o args=` … ueberspringt der Traeger die Pruefung"); funktional statt namentlich (kein "macOS") formuliert, was die Aussage nicht an eine einzelne Plattform bindet — nicht verschwiegen |
| `AMEND_EXPECTED_PATHS`-Fluchtpunkt kein Blankoscheck | geprüft, ohne Befund — `comm -23` gegen die zerlegte erwartete Liste verlangt, dass **jeder** fremde Pfad einzeln genannt ist; manuell nachvollzogen und über reales E2E-Repo bestätigt (siehe unten) |
| AGENTS.md §3.6, Fixture vs. reale Quelle | geprüft, ohne Befund — `decide()`/`has_amend_flag()` sind reine Funktionen, die bats über denselben CLI-Einstieg (`--decide`/`--decide-amend`) aufruft, den der volle Lauf am Ende selbst nutzt; kein Nachbau der Verdrahtung (dieselbe Trennung wie bei `history-range-guard.sh`) |
| AGENTS.md §3.7, Kommentar-Klassen | geprüft, ohne Befund — Kopfkommentare tragen Zusage/Kopplung/Abgrenzung/Grenze (s. F-7 für einen nicht blockierenden Hinweis), keine Befund-IDs, keine Prozess-Chronik, kein abgebrochener Satz |
| `harness/README.md` §Traceability, neuer Absatz | geprüft, ohne Befund im Sinne halluzinierter Aussagen — Reichweite (`make hooks-install`, `--no-verify`) korrekt aus dem bestehenden `commit-msg`-Absatz übernommen; Vollständigkeits-Lücke separat als F-2 geführt |
| `.githooks/pre-commit` in `Makefile`s shell-lint-Liste | geprüft, ohne Befund — Datei aufgenommen, `shellcheck` (gepinntes Image `koalaman/shellcheck@sha256:bb596a0d…`) real gefahren gegen beide neuen Dateien: Exit 0, keine Meldung |
| bats-Suite `test/pre-commit-amend-guard.bats` | geprüft, ohne Befund — real im gepinnten Image (`bats/bats@sha256:e8f18e0a…`) gefahren: 10/10 grün, unabhängig reproduziert |
| Reales E2E-Verhalten (frisches Repo) | geprüft, ohne Befund — eigenständig nachgestellt (eigener Commit, paralleler Fremd-Stage, `--amend` ohne/mit `AMEND_EXPECTED_PATHS`): Exit 1 mit Träger-Meldung bzw. Exit 0 mit Bestätigungs-Meldung, deckungsgleich mit dem im Kopfkommentar dokumentierten BELEG |
| Rollen-Trennung / Übergabe-Artefakt (Modul 8) | geprüft, ohne Befund — Architect-Verdikt liegt als Plan-Artefakt vor dem Implementer-Commit vor, Implementer weicht nicht davon ab |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 3 |
| INFO | 3 |

**Finding-Klassen dieses Laufs:** Aktivierendes Kommando prüft Exec-Bit nur für ursprünglichen Hook
· Werkzeug-Beschreibung bleibt bei Erweiterung auf ursprünglichen Einzelzweck fixiert ·
Mutations-Fall nennt einen Test, die Mutation färbt mehrere · Kommentar zur Einzel-Nennung nicht
nachgezogen bei zweitem gleichartigen Fall · Gate-Hash in derselben Datei referenziert sich selbst
(Selbstbezugs-Effekt)

## Verdikt

**Merge-blockierend:** nein. Kein HIGH. Beide MEDIUM-Befunde (F-1, F-2) sind Vollständigkeits-/
Robustheits-Lücken in einer Nachbar-Doku bzw. einem Nachbar-Guard, nicht Verstöße gegen die
zentrale Zusage dieses Slice (der Amend-Guard selbst arbeitet korrekt, real geprüft). Sie
verändern nicht das Ergebnis der eigentlichen Kern-Prüfung (F-3 bis F-8 sind LOW/INFO), sollten
aber vor oder kurz nach Closure behoben werden, da F-1 im schlimmsten Fall den gesamten Zweck des
Slice lautlos unterläuft (Guard bleibt inaktiv, ohne dass irgendetwas das meldet).

**Kein HIGH mit Rollen-Widerspruch** — der Modul-8-Konflikt-Pfad ist nicht einschlägig; alle
Findings entstehen im normalen Implementer-Diff, nicht aus einem Widerspruch zwischen Rollen-
Verdikten.

**Übergabe:** Findings gehen an den Implementer (Rückkante). Die Finding-Klassen gehen in die
Slice-Closure §7 und von dort in den Zähler des Beobachtungs-Registers. Dieser Report ist
Lauf-Beleg und wird über Läufe hinweg nicht erneut gelesen. Ersetzt keine Verifikation — DoD-/
Spec-Konformität prüft der Verifier separat (Modul 11).
