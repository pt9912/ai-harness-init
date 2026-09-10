# Review-Report — slice-073: Welche Doc-Gate-Module ein frisch gebootstrapptes Ziel bekommt

**Rolle:** Reviewer · **Datum:** 2026-09-10 · **Runde:** 1

> Jede Zahl in diesem Report steht neben dem Kommando, das genau sie ausgibt
> ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).
> Keine ist ein Erwartungswert; alle wandern mit dem Baum. Die Sonden liefen gegen eine Kopie
> außerhalb des Repos, netzlos, Mount `:ro`, über dem in [`d-check.mk`](../../d-check.mk)
> gepinnten Digest.

## Eingangs-Kontext (die fünf Pflicht-Punkte, Modul 10, plus die Repo-Ergänzung)

- **Diff/Commit-Range:** `1b77eb93..7bc78f4a` — vier Commits (der reine Move `1b77eb93` ist die
  Basis und liegt außerhalb), 18 Dateien, 193 Insertions / 42 Deletions
  (`git diff --stat 1b77eb93..7bc78f4a`). Substanz sind vier Dateien:
  `internal/emit/templates/d-check.yml`, `harness/tools/full-smoke.sh`,
  `internal/emit/emit_test.go`, `test/mutations/295-emittierte-modulliste-verliert-matrix.sh`;
  die übrigen 14 sind `slice-mv`-Verweis-Nachzug und der Ruhe-Marker.
- **Slice-Plan (Repo-Ergänzung):**
  [`slice-073`](../plan/planning/in-progress/slice-073-emittierte-doc-gate-module.md).
- **Betroffene `LH-*`:**
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
  [`LH-FA-03`](../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).
- **Referenzierte ADRs, mit selbst gelesenem Status:**
  [ADR-0007](../plan/adr/0007-bootstrap-phasen.md) — `Accepted`, normativ
  (`grep -n '^\*\*Status:\*\*' docs/plan/adr/0007-*.md`). Die Commit-Messages nennen keine
  ADR-Kennung; zulässig, weil sie `LH-*`- und `MR-*`-Kennungen führen
  ([`AGENTS.md`](../../AGENTS.md) §5 verlangt *mindestens eine*).
- **Aktive `MR-*`:**
  [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids),
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed),
  [`MR-019`](../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence),
  [`MR-020`](../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf),
  [`MR-037`](../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst).
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3 — namentlich §3.3, §3.6, §3.7, §3.8, §3.10.
- **Vorherige Findings am gleichen Modul:** keine. `grep -rln 'slice-073' docs/reviews/` nennt
  sechs Dateien, in allen sechs ist die Kennung eine Beiläufigkeit
  (Prüfbereichs-Aufzählungen, das Homonym `token:`), kein Review dieses Gegenstands. Dies ist
  Runde 1.

## Vorbemerkung: eine Prämisse des Auftrags ist zu korrigieren

Der Auftrag formuliert *„`MR-017` — Fail-closed heißt: im Zweifel nicht emittieren"*. Der Eintrag
sagt das Gegenteil, und weil davon abhängt, wie die Befunde unten zu lesen sind, steht die
Korrektur vorn. [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
§Setzung, wörtlich:

```text
ein zu strenger Default wird beim ersten Lauf rot und kostet eine Glob-Zeile in einer
Datei, die dem Adopter gehört (die emittierten Configs sind skip-if-present, sie werden
nie überschrieben). Ein zu lascher Default lässt einen Bereich ungeprüft — und meldet
sich nie. Laut falsch schlägt leise falsch.
```

*Fail-closed* meint dort das **Gate**, das im Zweifel nicht durchlässt — also den **strengeren**
Default. Die Gegenkraft ist nicht Zurückhaltung, sondern
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein Gate
über leerem Prüfbereich). **Folge für diesen Review:** Dass drei Module mehr emittiert werden, ist
unter `MR-017` die richtige Richtung und wird unten *nicht* beanstandet. Beanstandet wird, dass
die Entscheidungsregel des Slice in derselben Änderung zweimal gegensätzlich ausgelegt wird.

## Findings

### HIGH-1 — Kriterium 1 der eigenen Entscheidungsregel wird in derselben Änderung in beide Richtungen ausgelegt

- **kategorie:** HIGH
- **quelle:** [`slice-073`](../plan/planning/in-progress/slice-073-emittierte-doc-gate-module.md) §1
  (Entscheidungsregel, Kriterium 1), [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
- **pfad:** `internal/emit/templates/d-check.yml:24-38`
- **befund:** Die emittierte `matrix`-Sektion führt vier Neuerungen, die der Dogfood **nicht**
  fährt — die Klasse `welle`, den `token:`-Modus auf `slice` und `welle`, und die Regeln
  `{from: adr, to: slice}` und `{from: adr, to: welle}`. Dieselbe Änderung hält die
  Richtungs-Prüfung *innerhalb* der Spec-Straten (`order:`/`direction: no-downward`) mit der
  Begründung zurück, der Dogfood führe das Feld nicht — obwohl sie aus **demselben
  auskommentierten Block derselben Baseline-Vorlage** stammt
  (`.harness/baseline/v6.5.0/templates/.d-check.yml`, Zeilen 24–25 gegen 28/31/35). Entweder
  bindet Kriterium 1 — dann fallen die vier Emissionen darunter —, oder es bindet nicht — dann
  trägt die Zurückhaltung keinen Grund. Der Diff wählt je Position die bequemere Lesart und
  benennt die Spannung nirgends.
- **verifizierbar:** ja — die emittierte `matrix`-Form auf den Dogfood angewandt ergibt **74**
  Befunde, **alle** aus den neu emittierten Regeln/Klassen, **null** aus den zwei Regeln, die der
  Dogfood schon fährt:

  ```sh
  DIGEST=$(grep -oE 'DCHECK_DIGEST \?= sha256:[0-9a-f]+' d-check.mk | cut -d' ' -f3)
  git archive HEAD | tar -x -C <kopie>
  # in <kopie>/.d-check.yml: token: auf slice, Klasse welle, die zwei Regeln adr->slice/adr->welle
  docker run --rm --network none -v <kopie>:/repo:ro "ghcr.io/pt9912/d-check@$DIGEST" > lauf.txt
  tail -1 lauf.txt                                                    # 1063 Datei(en), 74 Befund(e)
  awk -F'\t' 'NF>=3{print $3}' lauf.txt | sort | uniq -c              # 73 matrix-forbidden, 1 matrix-inactive
  grep matrix-forbidden lauf.txt \
    | grep -oE '(Token-)?Referenz [a-z-]+ → [a-z-]+' | sort | uniq -c # 51 adr→slice, 21+1 adr→welle
  ```

  Keine Erwartungswerte — die Zahlen wandern mit dem ADR-Bestand.
- **klasse:** Entscheidungskriterium in derselben Änderung in beide Richtungen ausgelegt

**Was dieser Befund *nicht* sagt.** Nicht, dass die vier Emissionen falsch wären — unter
`MR-017` sind sie die richtige Richtung, und im frischen Ziel messen sie 0 (Emissions-Seite
unbestritten). Auch nicht, dass der Dogfood vor dem Ziel grün sein müsste — dass die Dogfood-Seite
ein eigener Schnitt ist
([slice-072](../plan/planning/open/slice-072-adr-verweist-nicht-auf-lifecycle.md), liegt in
`open/`), steht so im Plan. Der Befund ist die **stumme Asymmetrie**: Wo die Ziel-Form die
Autorität ist, gilt sie für drei Positionen und für eine vierte nicht, und die Zahl 74 steht
nirgends im Diff.

### HIGH-2 — Der Auflösungs-Trigger der dritten Nicht-Emission ist bereits eingetreten und würde append-only eingefroren

- **kategorie:** HIGH
- **quelle:** [`slice-073`](../plan/planning/in-progress/slice-073-emittierte-doc-gate-module.md)
  DoD (3), [`MR-019`](../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence),
  [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `internal/emit/templates/d-check.yml:24` (die nicht emittierte Position) /
  `docs/plan/planning/in-progress/slice-073-emittierte-doc-gate-module.md:126`
- **befund:** DoD (3) nennt als Auflösungs-Trigger der dritten Nicht-Emission wörtlich *„der
  Dogfood führt selbst drei Straten und kann sie erproben"*. Beide Hälften sind **heute wahr**:
  `spec/` trägt drei Dateien und die Dogfood-Klasse `spec-straten` listet alle drei
  (`.d-check.yml:187`); `MR-019` ist aktiv. Die Plan-Begründung in §6 (*„der Dogfood führt zwei
  Straten und kann sie nicht erproben"*) stammt vom 2026-07-31 und ist überholt. Der Diff ersetzt
  den Trigger still durch einen anderen (*„der Dogfood führt kein `order:`/`direction:`-Feld"*) —
  das ist keine Aussage über das Ziel, sondern über eine Dogfood-Zeile, die niemand geschrieben
  hat. Wird der Eintrag mit dem Plan-Trigger geschrieben, entsteht ein Eintrag, dessen
  Auflösungs-Bedingung bei seiner Anlage schon gilt; Einträge dieses Blocks sind append-only
  ([`MR-020`](../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)),
  der Rumpf wird nachträglich nicht korrigiert.
- **verifizierbar:** ja — alle drei Kriterien aus §1 sind für diese Position erfüllbar, zwei davon
  direkt gemessen. Das Werkzeug **kann** es am gepinnten Digest, der Dogfood ist **grün**, und das
  Gegenbeispiel wird **rot**:

  ```sh
  # spec-straten-Klasse in Block-Form + order:/direction: no-downward, sonst unveraendert
  docker run --rm --network none -v <kopie>:/repo:ro "ghcr.io/pt9912/d-check@$DIGEST"
  #   -> 1063 Datei(en) geprüft, 0 Befund(e)            (Kriterium 2, Dogfood)
  # Abwaertslink Vertrag -> Technik/Sicht, ausserhalb exclude-sections eingeschmuggelt:
  #   spec/lastenheft.md:14  spezifikation.md  matrix-downward  Rang 0 → 1 ist nicht erlaubt
  #   spec/lastenheft.md:14  architecture.md   matrix-downward  Rang 0 → 2 ist nicht erlaubt
  ```

  Und für das **Ziel** ist Kriterium 2 trivial erfüllt: keine der drei emittierten Spec-Vorlagen
  trägt einen Quer-Link auf ein anderes Stratum —
  `grep -c '](.*\(lastenheft\|spezifikation\|architecture\)' .harness/baseline/v6.5.0/templates/spec/*.template.md`
  → je **0**.
- **klasse:** Auflösungs-Trigger bereits eingetreten, bevor der Eintrag geschrieben wird

**Warum das mehr ist als eine Formalie.** Die Position, die hier ausbleibt, ist die
Richtungs-Prüfung *innerhalb* der Spec-Straten — die Regel, die
[`MR-019`](../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)
in diesem Repo tragend macht und die die Baseline unter dem Grund-Code `matrix-downward` führt.
Ein Ziel bekommt damit ein `matrix`, das den Abwärtsverweis *zwischen* Spec und ADR/Slice sieht
und den *innerhalb* der Spec nicht. Und weil `.d-check.yml` *skip-if-present* ist
([ADR-0007](../plan/adr/0007-bootstrap-phasen.md)), bleibt die Lücke bei jedem Ziel offen, das
einmal gebootstrappt wurde.

### MEDIUM-1 — Das Übergabe-Artefakt für DoD (3) existiert im Repo nicht

- **kategorie:** MEDIUM
- **quelle:** Baseline-Regelwerk `modul-08-agentenrollen.md` §Die neun Übergaben und ihre
  Artefakte, [`AGENTS.md`](../../AGENTS.md) §3.8
- **pfad:** `docs/plan/planning/in-progress/slice-073-emittierte-doc-gate-module.md:121`
  (DoD (3), ungehakt) — kein Artefakt im Baum
- **befund:** Die Message von `bcf652b9` erklärt DoD (3) zur Architect-Arbeit und benennt *„der
  Report an den Reviewer trägt den Entwurf als Uebergabe-Artefakt"*. Ein solcher Entwurf liegt
  nicht im Repo: `grep -rn 'MR-054' --include='*.md' .` (ohne `.harness/baseline`) → **0**
  Treffer, `git status --porcelain` → leer, `ls harness/conventions/` endet bei `MR-053`. Die
  Übergabe hängt damit an einem Sitzungs-Kontext statt an einem Artefakt — genau der Fall, den
  Modul 8 als *„Kontext-Switch ohne Übergabe"* führt. Der Architect läuft nach Rollen-Definition
  in frischem Kontext und findet nichts zu lesen; der Verifier hat für DoD (3) kein Prüf-Artefakt.
- **verifizierbar:** ja — die drei Kommandos oben; kein Gate-Lauf deckt es (kein Modul der
  [`.d-check.yml`](../../.d-check.yml) liest Commits oder Rollen-Übergaben).
- **klasse:** Rollen-Übergabe ohne Artefakt im Repo

**Die Rollen-Grenze selbst ist korrekt gezogen** — siehe Negativbefund N-6. Beanstandet ist nicht,
*dass* der Implementer den Eintrag nicht schrieb, sondern dass das, was er stattdessen liefern
muss, nirgends liegt.

### MEDIUM-2 — Ein emittierter Kommentar nennt den Dogfood und einen dort nicht existierenden Mechanismus

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7,
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
- **pfad:** `internal/emit/templates/d-check.yml:35`
- **befund:** Die Zeile lautet *„Er ist im frischen Ziel der einzige Ausweg — anders als im
  Dogfood hat ein frisches Ziel keinen Bestand, den es vorschalten koennte."* Sie steht in einem
  Artefakt, das ein fremdes Repo bekommt, und vergleicht mit einem Repo, das der Adopter nicht
  kennt. Der Vergleich trifft zudem nicht zu: die Bestands-Vorschaltung existiert im Dogfood
  nicht — `grep -c 'Bestands-ADR\|vorgeschaltete' .d-check.yml` → **0**, und der Slice, der sie
  einführen soll, liegt in `open/`
  (`ls docs/plan/planning/*/slice-072*` → `docs/plan/planning/open/…`). Der Kommentar beschreibt
  damit eine Alternative, die es nirgends gibt — die Form, die §3.7 unter *„beschreibt abwesenden
  Text"* führt.
- **verifizierbar:** teilweise — das Wort ist im Emissions-Baum genau einmal messbar
  (`grep -rn 'Dogfood\|dogfood' internal/emit/templates/` → **1** Treffer, diese Zeile). Ein Gate
  fängt es **nicht**: der etablierte Wächter gegen repo-interne Referenzen in emittierten
  Artefakten (`harness/tools/full-smoke.sh:713`, `slice-033`/`LH-FA-08`) keilt auf
  `$tmprepo/.claude/commands/` und erreicht `internal/emit/templates/d-check.yml` nicht.
  `make comment-claims` erreicht die Datei ebenfalls nicht (`internal/emit/templates/` liegt
  dauerhaft außerhalb seiner vier Pfad-Muster).
- **klasse:** Emittiertes Artefakt nennt den Ursprungs-Repo-Mechanismus

**Nicht HIGH**, obwohl es der Gate-Pfad ist: Der Kommentar bricht kein Gate und belügt keinen
Sensor — die zwei Sätze davor tragen ihre Klassen (Abgrenzung, Grenze) korrekt, und der Marker,
den sie zusagen, hält (Negativbefund N-3). Es ist der Nachsatz, der falsch ist.

### LOW-1 — Der netzlose Wächter deckt die Modul-Streichung, nicht die zwei neuen Regeln

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `internal/emit/emit_test.go:44-46`, `test/mutations/295-emittierte-modulliste-verliert-matrix.sh`
- **befund:** `TestDCheckConfig_EntschiedeneModulListe` behauptet drei Dinge — die Modul-Liste,
  das auskommentierte Requirement-Muster und die Existenz der zwei neuen `matrix`-Regeln. Ein
  Mutations-Fall existiert nur für die **erste** (295 nimmt `matrix` aus `modules:`). Für die
  Zusage *„die beiden neuen matrix-Regeln (adr->slice, adr->welle) fehlen"* ist kein Fall unter
  `test/mutations/` angelegt; nach §3.6 ist sie damit gelistet-aber-unbewacht — *„wer keinen Fall
  in `test/mutations/` hat, ist unbewacht"*. Versagens-Szenario: Ein späterer Schnitt entfernt
  `{from: adr, to: welle, allow: false}` aus der Vorlage, und ob die `strings.Contains`-Zusage
  darauf anspringt, hat niemand rot gesehen.
- **verifizierbar:** ja — `ls test/mutations/*emittierte-modulliste* test/mutations/*matrix-regel*`
  nennt genau eine Datei.
- **klasse:** Zusage ohne Mutations-Fall

### INFO-1 — `MR-016` im Slice-Plan: kein toter Link, aber ein Argument auf abgeschafftem Kriterium

- **kategorie:** INFO
- **quelle:** [`MR-037`](../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst),
  [`MR-020`](../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf),
  [`AGENTS.md`](../../AGENTS.md) §3.10
- **pfad:** `docs/plan/planning/in-progress/slice-073-emittierte-doc-gate-module.md:9,14`
- **befund:** Der eingebrachte Nebenbefund ist **in beide Richtungen zu beantworten**. *Als Link*
  folgenlos: der Anker zieht per
  [`MR-020`](../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
  in die Tabelle *Aufgelöste Adaptionen* mit um, und der netzlose Voll-Lauf über dem Baum meldet
  `1063 Datei(en) geprüft, 0 Befund(e)` — kein `target-missing`, kein `anchor-missing`. *Als
  Argument* nicht folgenlos: Die Welle-Begründung des Plans stützt sich auf `MR-016` Frage 3
  (*reaktiv oder gewollt*), und `MR-037` schafft genau diese ab — *„die dritte Frage
  (reaktiv/gewollt) entfällt als eigenständiges Kriterium"*. Das **Ergebnis** hält: Fragen 1 und 2
  bleiben nach `MR-037` tragend (*„Bündel und ein eigenes Closure-Kriterium bleiben die tragenden
  Fragen"*), und der Plan beantwortet beide mit *Nein*. Es ist also **Planner-Nacharbeit, kein
  Sachfehler** — und sie ist bereits gebucht: §6 führt sie mit offenem Ausgang. Der Implementer
  durfte sie nicht selbst schließen (§3.10: die ausführende Rolle schreibt ihr eigenes
  Abnahmekriterium nicht um).
- **verifizierbar:** ja — der Voll-Lauf oben plus
  `grep -n 'entfällt als eigenständiges Kriterium' harness/conventions/MR-037-*.md`.
- **klasse:** Verweis auf abgelösten Eintrag trägt ein abgeschafftes Argument

### INFO-2 — Was die drei neuen Zähne im Regelbetrieb bewacht (Korrektur einer Auftrags-Prämisse)

- **kategorie:** INFO
- **quelle:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- **pfad:** `.github/workflows/ci.yml:73-77`, `Makefile:408`
- **befund:** Der Auftrag setzt voraus, `full-smoke` stehe *„außerhalb von `make gates` und
  außerhalb von CI"*. Die zweite Hälfte trifft nicht zu: `.github/workflows/ci.yml` führt einen
  eigenen Job `full-smoke` mit `run: make full-smoke`, pro Push/PR auf frischem Klon — die drei
  neuen Zähne laufen also im Regelbetrieb. Richtig ist die erste Hälfte: `make gates` hängt an
  `record-gates` und nennt `full-smoke` nicht, ein lokaler Gate-Lauf fährt die Zähne nicht. Im
  `gates`-Umfang bleibt allein `TestDCheckConfig_EntschiedeneModulListe` (die **Liste**, nicht das
  Verhalten) — und der Test-Docstring sagt das ausdrücklich (*„dieser Test bindet nur die LISTE,
  nicht das Verhalten (das braucht Docker und liegt in full-smoke)"*). Der Diff ist an dieser
  Stelle also **ehrlich**. Nebenbei sichtbar, außerhalb dieses Diffs: [`harness/README.md`](../../harness/README.md)
  §Sensors beschreibt CI als *„`make gates` + `make smoke` + `make mutate`"* und lässt den
  vierten Job aus.
- **verifizierbar:** ja — `grep -n 'full-smoke' .github/workflows/ci.yml`,
  `grep -nE '^gates:|^record-gates:' Makefile`.
- **klasse:** Deckungs-Aussage über einen Nicht-Gate-Sensor

## Negativbefunde (geprüft, ohne Befund)

- **N-1 — Die Kausalitäts-Gegenprobe läuft für alle drei Zähne, nicht für einen.** Die im Auftrag
  vermutete Lücke besteht nicht: `grep -n 'modul_zahn_alte_module_gruen' harness/tools/full-smoke.sh`
  → Definition bei `302`, Aufrufe bei `341` (matrix), `368` (ids), `390` (spans). Jeder Aufruf
  steht **vor** der Rücknahme der Verletzung, misst also den richtigen Zustand. Und die Funktion
  ist **fail-closed**: greift ihr `sed` nicht mehr (etwa nach einer Listen-Änderung), bleibt die
  volle Modul-Liste aktiv, die eingeschmuggelte Verletzung färbt rot, `rc` ist ungleich 0 und die
  Funktion meldet FEHLER — ein stilles Grün gibt es an dieser Stelle nicht.
- **N-2 — Die drei Zähne prüfen die benannte Befund-Art, nicht nur „rot".** Je Zahn zwei Sperren
  (Exit ungleich 0 **und** `grep -qE` auf `matrix-forbidden` / `id-unlinked` / `span-unclosed`);
  `grep -cE "grep -qE 'matrix-forbidden'|grep -qE 'id-unlinked'|grep -qE 'span-unclosed'"` → **3**.
  Das schließt „rot aus falschem Grund" aus, und die Meldung sagt genau das.
- **N-3 — Der Ausweg, den der emittierte Kommentar zusagt, hält am gepinnten Digest.** Eine
  Sonden-ADR mit `welle-99`/`slice-999` in einer Zeile und `welle-98`/`slice-998` in einer zweiten,
  die den Zeilen-Marker trägt: die erste Zeile liefert zwei `matrix-forbidden`, die zweite
  **null**. Der `token:`-Modus und die zwei neuen Regeln sind damit real wirksam, und der Marker
  nimmt genau seine Zeile aus. Die Meldung des Werkzeugs nennt den Ausweg selbst
  (*„Provenance via `<!-- d-check:status-provenance -->` deklarieren"*).
- **N-4 — `AGENTS.md` §3.7 an den neuen Kommentaren: die Selbstkorrektur ist vollständig.**
  Stichprobe über alle vier neu geschriebenen Kommentar-Blöcke (`d-check.yml` ×3, `full-smoke.sh`,
  `emit_test.go`, `mutations/295`): keiner nennt eine Slice-Nummer oder eine Befund-Kennung als
  Grund, alle stehen im Indikativ über den Ist-Zustand. Die verbleibenden vier `slice-073` in
  `full-smoke.sh` stehen in **Fehler-Meldungs-Strings**, nicht in Kommentaren — §3.7 keilt auf
  `^[[:space:]]*(#|//)`, und die Form ist dort der Bestand:
  `grep -nE 'slice-[0-9]{3}' harness/tools/full-smoke.sh | grep -vcE ':[[:space:]]*#'` → **113**
  solche Zeilen. Kein Finding.
- **N-5 — Hard Rule §3.3 (Move und Rewrite getrennt).** `git show --numstat --find-renames 1b77eb93`
  → `0	0	docs/plan/planning/{next => in-progress}/slice-073-….md`. Der Move ist byte-rein, der
  Verweis-Nachzug liegt im eigenen Commit `8102f97e`. Sauber.
- **N-6 — Rollen-Grenze zum Adaptions-Block ist korrekt gezogen.** [`AGENTS.md`](../../AGENTS.md)
  §3.8 bindet `harness/conventions.md` und `harness/conventions/` an den Architect. Der Diff fasst
  beide nicht an: `git diff --name-only 1b77eb93..7bc78f4a | grep -c '^harness/conventions'` →
  **0**. Die Entscheidung, DoD (3) nicht im Implementations-Kontext zu schreiben, ist die richtige
  — beanstandet ist allein das fehlende Übergabe-Artefakt (MEDIUM-1).
- **N-7 — Ruhe-Marker und `planning`-Invariante.** `in-progress/` trägt seit dem Move
  `slice-073-….md`; `9bced90f` entfernt „Nichts in Arbeit." aus der Roadmap. Das ist die von
  [`.d-check.yml`](../../.d-check.yml) §`planning` verlangte Richtung (`planning-drift` in **beide**
  Richtungen), und der Voll-Lauf über dem Baum bestätigt sie mit 0 Befunden.
- **N-8 — `exclude-sections` im emittierten `matrix` ist begründet, nicht abgeschrieben.** Die
  Baseline-Vorlage liefert die Klasse bewusst *ohne* den Schlüssel. Der Diff setzt ihn dennoch —
  zu Recht: die emittierte ADR-Vorlage endet mit `## Geschichte`
  (`grep -c '^## Geschichte' .harness/baseline/v6.5.0/templates/docs/plan/adr/NNNN-titel.template.md`
  → **1**), und ohne die Ausnahme färbte jede Fortschreibung eines Adopters rot. DoD (1) verlangt
  den Schlüssel ausdrücklich. Die zwei zusätzlichen Werte (`Historie`, `"7. Historie"`) sind
  Dogfood-Vokabular und im Ziel wirkungslos, aber nicht schädlich.
- **N-9 — Die Nicht-Emission von `codepaths` trägt.** Strukturell belegt statt geglaubt:
  `structureGitkeeps()` in `internal/emit/templates.go:430-445` legt `observations/` **nicht** an
  und begründet das im Kopfkommentar; drei emittierte Workflow-Commands nennen den Ort als
  Inline-Code (`grep -rn 'observations' internal/emit/templates/` → `plan-welle.md:46`,
  `implement-slice.md:153`, `close-welle.md:60`). Die Begründung ist damit eine andere als die des
  Plans von 2026-07-31 — genau die Nachmessung, die §3 verlangt. Sie hat eine Adresse:
  [slice-194](../plan/planning/next/slice-194-bootstrap-legt-den-register-ort-an.md).
- **N-10 — Die Nicht-Emission von `planning` trägt, und sie war im Plan angelegt.** Die
  Roadmap-Vorlage trägt den Ruhe-Marker für den leeren Zustand bewusst nicht, mit
  ausgeschriebener Begründung im Bedienhinweis (*„Ein Doku-Sensor matcht den Marker als Substring
  dieses Blocks, also matcht sich jeder Regel-, Hinweis- oder Beispieltext selbst"*). Ein frisches
  Ziel liefe damit sofort in `planning-drift`. Anders als im Auftrag beschrieben ist das **kein
  im Plan ungeführter Befund**: §6 nennt `planning` als den Kandidaten, den die §1-Tabelle nie
  geprüft hat, und verlangt die Nachmessung. Der Diff liefert sie; damit sind alle **7**
  Dogfood-Module (`grep -m1 '^modules:' .d-check.yml`) entweder emittiert oder mit Begründung
  ausgeschlossen — keine Leerstelle.
- **N-11 — Die Ausgangs-Klassifikation von `full-smoke` ist mitgezogen.** Die in
  [`harness/README.md`](../../harness/README.md) dokumentierte Gleichung über die
  `AUSGANG LEITUNG`/`AUSGANG BAUM`-Einordnung hält nach vier neuen Stufen weiterhin: **A**=37,
  **B**=5, **C**=6 → `A-B-C` = **26**, `einordnen`-Zeilen = 28 → `E-2` = **26**. Der Implementer
  hat die vier neuen `|| rc=$?`-Stellen korrekt eingeordnet.
- **N-12 — `test/mutations/295` hat Zähne.** Der Fall ersetzt die Modul-Liste durch
  `[links, anchors, ids, spans]`; der `expect:`-Test prüft
  `strings.Contains(yml, "modules: [links, anchors, ids, matrix, spans]")` und fällt damit
  zwingend. Die `# files:`-Zeile nennt die real mutierte Datei.
- **N-13 — Nicht geprüft (fremde Rolle):** die DoD-Abhakung, die Gate-Lauf-Bestätigung
  (`make gates`, `make mutate` 281/281, zwei `full-smoke`-Läufe) und der Beleg-Schlüssel. Das ist
  Verifikation (Modul 11), nicht Review — der Reviewer-Skill nimmt sie ausdrücklich aus. Die
  Grün-Behauptungen dieses Reports stützen sich ausschließlich auf eigene Sonden-Läufe, nicht auf
  die Berichte des Implementers.

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 2 | Entscheidungskriterium in derselben Änderung in beide Richtungen ausgelegt · Auflösungs-Trigger bereits eingetreten, bevor der Eintrag geschrieben wird |
| MEDIUM | 2 | Rollen-Übergabe ohne Artefakt im Repo · Emittiertes Artefakt nennt den Ursprungs-Repo-Mechanismus |
| LOW | 1 | Zusage ohne Mutations-Fall |
| INFO | 2 | Verweis auf abgelösten Eintrag trägt ein abgeschafftes Argument · Deckungs-Aussage über einen Nicht-Gate-Sensor |

**Wiederkehrende Klasse für den Steering-Loop-Zähler:** HIGH-1 und HIGH-2 sind zwei Seiten
derselben Beobachtung — *eine Entscheidungsregel wird je Position nach Bequemlichkeit ausgelegt,
und der Grund für die engere Auslegung ist eine Aussage über den eigenen Bestand statt über den
Prüfgegenstand*. Sie gehört bei der Slice-Closure ins Beobachtungs-Register
([`docs/plan/planning/observations/README.md`](../plan/planning/observations/README.md)).

## Verdikt

**Blockierend — ja.** Zwei HIGH und zwei MEDIUM.

HIGH-2 ist der teuerste, weil er in ein **append-only** Artefakt läuft: Wird der Eintrag mit dem
Plan-Trigger geschrieben, ist er bei seiner Anlage schon aufgelöst und wird nachträglich nicht
mehr korrigiert. Er gehört **vor** den Architect-Lauf, nicht danach. Da er zugleich das
Abnahmekriterium DoD (3) berührt, ist er nach [`AGENTS.md`](../../AGENTS.md) §3.10 ein
Übergabe-Artefakt an den **Planner** — die ausführende Rolle schreibt ihr eigenes
Abnahmekriterium nicht um, und der Reviewer entscheidet nicht, welcher Trigger an seine Stelle
tritt.

**Kein Rollen-Konflikt-Pfad ausgelöst.** Modul 8 verlangt die Konflikt-Sequenz ab *HIGH mit
Rollen-Widerspruch*. Ein Widerspruch liegt nicht vor: Der Implementer hat der Entscheidungsregel
nicht widersprochen, sondern sie zweimal verschieden gelesen, und die Trigger-Frage ist eine
Messung, keine Meinung. Sollte der Befund unter Verweis auf den Plan bestritten werden, ist der
Konflikt-Pfad zu eröffnen — herabgestuft wird er nicht.

Die Emissions-Seite selbst ist tragfähig: Die drei aktivierten Module sind an einem frischen Ziel
grün, ihre Gegenbeispiele sind rot gesehen, die Kausalitäts-Gegenprobe läuft für alle drei, die
Zähne prüfen die benannte Befund-Art, und der Ausweg, den der emittierte Kommentar zusagt, hält am
gepinnten Digest. Was fehlt, ist nicht die Arbeit — es ist die **Begründungs-Konsistenz** über die
vier Positionen und das Artefakt, an dem die nächste Rolle sie nachlesen kann.
