# MR-074 — Zweiter git-eigener Hook: `pre-commit` gegen `--amend`-Indexmitnahme

- **Datum:** 2026-09-28
- **Wirksamkeits-Anlass:** slice-amend-haelt-den-index-pfadrein.
- **Geltungsbereich:** `.githooks/pre-commit` (neu), [`harness/tools/pre-commit-amend-guard.sh`](../tools/pre-commit-amend-guard.sh) (neu), [`test/pre-commit-amend-guard.bats`](../../test/pre-commit-amend-guard.bats), `test/mutations/497-pre-commit-amend-guard-blankoscheck.sh`, die `Makefile`-`shell-lint`-Dateiliste (Ergänzung um den neuen Hook) und [`harness/README.md`](../README.md) §Traceability/§Werkzeuge (Prosa-Dokumentation des zweiten Trägers). **Nicht** [`.githooks/commit-msg`](../../.githooks/commit-msg) und dessen Prüfung — die trägt weiterhin [`MR-002`](../conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) allein.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  und er setzt keine Abweichung: er protokolliert eine **Erweiterung** um einen weiteren git-nativen
  Hook derselben Klasse, die [`MR-002`](../conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)
  für `commit-msg` bereits einführt — Durchsetzungsschicht-Artefakt
  (Baseline-Regelwerk
  [`grundlagen-durchsetzungsschicht.md`](../../.harness/baseline/v6.17.0/regelwerk/grundlagen-durchsetzungsschicht.md#das-vollständige-artefakt-set)
  §Das vollständige Artefakt-Set), nur an einer anderen Stelle des Commit-Pfads (Index statt
  Message) und mit einer anderen Zusage. Wie bei [`MR-002`](../conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)
  ändert kein Teil dieses Eintrags eine Komponenten-/Sequenzsicht oder eine Technik-Festlegung —
  ein ADR war deshalb nicht nötig (Architect-Verdikt in
  [`done/slice-amend-haelt-den-index-pfadrein.md`](../../docs/plan/planning/done/slice-amend-haelt-den-index-pfadrein.md)
  §1).
- **Adaption:** Ein zweiter git-eigener Hook liegt neben `commit-msg`: `.githooks/pre-commit`. Er
  wirkt bei jedem `git commit` in diesem Klon, sobald `make hooks-install` gelaufen ist —
  unabhängig davon, welche Rolle den Commit auslöst, dieselbe Reichweiten-Eigenschaft, die
  `commit-msg` für die Traceability-Kennung trägt
  ([`harness/README.md`](../README.md) §Traceability). Seine Zusage ist eine andere: nicht die
  Commit-Message, sondern der **Index** vor `git commit --amend`. Reißt der Amend Pfade mit, die
  der amendierte Commit (HEAD) selbst nicht enthielt — weil zwischen dem letzten eigenen Commit und
  dem Amend ein paralleler Vorgang eigene Dateien gestaged hat —, bricht der Hook den Commit ab
  (Exit 1); der Fluchtpunkt `AMEND_EXPECTED_PATHS` lässt einen bewusst erweiterten Amend durch. Die
  Prüf-Logik liegt in [`harness/tools/pre-commit-amend-guard.sh`](../tools/pre-commit-amend-guard.sh)
  (`harness/tools/`, damit `shell-lint` sie deckt, dieselbe Platzierung wie
  `commit-msg-traceability.sh`); ihr Kopfkommentar trägt Zusage, Erkennungsmechanik und Grenze
  vollständig. Beide Hooks teilen sich Aktivierung (`make hooks-install` setzt `core.hooksPath` auf
  `.githooks` für beide zugleich) und Umgehung (`git commit --no-verify`).
- **Grenze.**
  - **Der Index ist kein Gegenstand des `commit-msg`-Hooks — dafür genau der Gegenstand dieses
    Hooks.** `git commit --amend` läuft durch beide Träger, aber nur `pre-commit` sieht den Index;
    `commit-msg` prüft die Nachricht, nicht die gestagten Pfade
    ([`harness/README.md`](../README.md) §Traceability, *„Der Index ist kein Gegenstand dieser
    Tabelle"*).
  - **Ein Muster, keine Garantie.** Der Träger erkennt genau ein Muster — Pfade im Index, die der
    amendierte Commit selbst nicht enthielt. Trifft `--amend` versehentlich den *falschen* Commit,
    weil HEAD zwischen dem letzten eigenen Commit und dem Amend durch einen fremden Commit
    weitergewandert ist, erkennt der Träger das nicht als eigenen Fall — er fängt ihn in der Praxis
    meist über dasselbe Pfad-Muster, ohne das zu garantieren
    (`harness/tools/pre-commit-amend-guard.sh` Kopfkommentar §GRENZE).
  - **`--amend` ist prozessseitig, nicht flag-seitig erkannt.** git reicht dem `pre-commit`-Hook
    keine Argumente; der Träger liest die Kommandozeile des aufrufenden `git`-Prozesses über
    `/proc/$PPID/cmdline`, ersatzweise `ps -o args=`. Ist keines lesbar, überspringt der Träger die
    Prüfung (fail-open) statt jeden Commit zu blockieren — benannte Grenze, keine Zusage; dieser
    Fall ist im gepinnten bats-Image nicht nachstellbar und darum nicht mit einem roten
    Gegenbeispiel belegt.
  - **Dieselbe Aktivierungs- und Umgehungs-Grenze wie beim `commit-msg`-Träger**
    ([`MR-002`](../conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)): Der Hook wirkt
    nur, wo `make hooks-install` gelaufen ist (lokale Konfiguration, reist nicht mit dem Klon), und
    wird von `git commit --no-verify` umgangen — kein neuer Preis, dieselbe bereits akzeptierte
    Grenze.
  - **Kein Gate und kein genereller Index-Wächter.** Geprüft wird ausschließlich der `--amend`-Fall,
    nicht jeder Commit — dieselbe Abgrenzung, mit der
    [`done/slice-amend-haelt-den-index-pfadrein.md`](../../docs/plan/planning/done/slice-amend-haelt-den-index-pfadrein.md)
    §1 einen generellen Index-Wächter ausdrücklich ausschließt.
- **Begründung:** Bewährte Mechanik — derselbe Trägertyp (git-nativer Hook statt Claude-Hook oder
  Rollen-Anweisungssatz), aus demselben Grund wie bei `commit-msg`: Reichweite über alle Rollen
  hinweg, weil er am Commit hängt, nicht am Anweisungssatz, den nur drei der sechs Rollen führen
  (Baseline-Regelwerk `modul-08-agentenrollen.md` §Welche Rolle braucht welche Artefaktklasse). Der
  Anlass ist das Beobachtungs-Register
  ([`BEO-ALL/amend-committet-fremde-index-eintraege-mit`](../../docs/plan/planning/observations/BEO-ALL/amend-committet-fremde-index-eintraege-mit/observation.md),
  3 Belege — Konsistenz-Review 2026-09-15,
  `slice-174-archivierung-emittieren`,
  `slice-d-check-pin-bringt-links-lookahead-und-referenz-definitionen`) und
  [`AGENTS.md`](../../AGENTS.md) §3.10 (Rollentrennung bei parallel laufenden Rollen im selben
  Klon) · seit slice-amend-haelt-den-index-pfadrein.
- **Auflösungs-Trigger:** permanent.
