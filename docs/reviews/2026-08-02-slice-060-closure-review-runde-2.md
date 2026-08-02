# Code-Review (Modul 10) — slice-060, Bestätigungsrunde über `b43ac6d` · `736b562` · `eefa39f`

## Kopf-Metadaten

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 10) — frischer Kontext |
| **Datum** | 2026-08-02 |
| **Prüfstand** | `main` @ `eefa39f`, Arbeitsbaum sauber, drei ungepushte Commits |
| **Prüfgegenstand** | `da1ffa9..HEAD` — `b43ac6d` (`docs/plan/planning/next/slice-076-…`) · `736b562` (Revert von `8864708`: `harness/conventions.md`, `docs/plan/planning/open/slice-074-…`) · `eefa39f` (`.claude/hooks/pretooluse-agent-guard.sh`) |
| **Schnitt** | eng — die zwei MEDIUM des Vorberichts und die Frage, ob beim Beheben Neues entstand. Die vier LOW und zwei INFO des Vorberichts sind **nicht** Gegenstand |
| **Slice-Plan** | `docs/plan/planning/in-progress/slice-060-rollen-achse.md` §5, §6 · `docs/plan/planning/next/slice-076-mr-018-umzug-technik-stratum.md` §1, §3 |
| **`LH-*`** | `LH-QA-03` (bash + awk im Guard-Pfad) · `LH-QA-01` (kein Gate über leerem Prüfbereich) |
| **ADRs** | `ADR-0014` (Accepted) · `ADR-0013` (Accepted) · `ADR-0011` (Accepted) · `ADR-0004` · `ADR-0003` |
| **Hard Rules** | `AGENTS.md` §3.1 · §3.2 · §3.3 · §3.4 · §3.5 · §3.6 · §5 |
| **Vorherige Findings am gleichen Modul** | `docs/reviews/2026-08-02-slice-060-closure-review.md` (MEDIUM-1/2 — die Blocker) · `docs/reviews/2026-08-01-slice-060-verify.md` · `docs/reviews/2026-07-31-slice-060-verify-fixes-review.md` |
| **Nicht Gegenstand** | die DoD-Abhakung (Verifikation, getrennter Kontext) |
| **Gefahrene Sensoren** | `make gates` voll (Exit 0, eigener Lauf) · Blob-Hash-Vergleich über die vier Stände von `MR-018` und slice-074 · jeder der sieben Fälle 117–122/139 auf eine isolierte Kopie angewandt und die geänderte Zeile abgelesen · die zwei im Kopf genannten Dauer-Fälle über die Payload gefahren, die der jeweilige bats-Fall benutzt · `comment-claims.sh` gegen fünf **entkoppelte** Varianten plus zwei Abrisse der realen Datei · Auszählung der `settings.json`-Berührungen über den in `MR-018` deklarierten Umfang |
| **Nicht gefahren** | `make mutate` als Vollauf (Nutzer-Ausschluss) · `make smoke`/`make full-smoke` |

---

## MEDIUM-1 — **erledigt**

**Gegenstand:** der Eingriff in den Rumpf eines akzeptierten Adaptions-Eintrags.

**Beleg (eigene Messung).** Der Revert ist byte-genau, nicht nur inhaltsgleich — die Blob-Hashes
sind identisch:

```
== harness/conventions.md
  8864708^: c4da8e08f770ac28a4280848c46693e94d06c1a2
  8864708 : 418e9265722dcf06d68cd442e2b16dbd67497684
  736b562 : c4da8e08f770ac28a4280848c46693e94d06c1a2
  HEAD    : c4da8e08f770ac28a4280848c46693e94d06c1a2
== docs/plan/planning/open/slice-074-agent-vor-aufruf-protokoll.md
  8864708^: 63e77bda7c5a9d95994f66c3527c67da7f3e18ed
  736b562 : 63e77bda7c5a9d95994f66c3527c67da7f3e18ed
  HEAD    : 63e77bda7c5a9d95994f66c3527c67da7f3e18ed
```

`git diff 8864708^ 736b562 -- harness/conventions.md docs/plan/planning/open/slice-074-…` gibt
keine Zeile aus. Damit fällt auch LOW-4 des Vorberichts (die doppeldeutige Zelle in slice-074)
mit weg — nicht behoben, sondern nie entstanden.

**Sind die zwei Sachmängel verlorengegangen? Nein.** `slice-076` §1 führt sie als (c) und (d)
unter der Überschrift *„Vier Mängel im heutigen Text"*, jeder mit seiner Art im Kopf des Postens;
§3 Schritt 5 nimmt (c) auf und schließt (d) namentlich aus. Ein Umsetzer von `slice-076` findet
beide ohne den Review-Bericht.

**Trägt die Unterscheidung (c) Korrektur / (d) Zielort-Frage?** Ja, und (c) ist
granularitäts-unabhängig falsch — das habe ich nachgemessen, nicht übernommen. Über den in
`MR-018` **selbst deklarierten** Umfang (`test/**`, `Makefile`, `harness/tools/*.sh`, Go-Tests):

| # | Prüfstelle | Datei | Art |
|---|---|---|---|
| 1 | `for rel in … .claude/settings.json …` (`:75-82`) | `harness/tools/smoke.sh` | Vorhandensein |
| 2 | `grep -q "PreToolUse"` (`:85-88`) | `harness/tools/smoke.sh` | Verdrahtung |
| 3 | `TestEnforce_EmitsAllMechanicFiles` | `internal/emit/enforce_test.go` | Vorhandensein |
| 4 | `TestEnforce_SettingsWiresBothHooks` | `internal/emit/enforce_test.go` | Verdrahtung |
| 5 | `32-enforce-settings-wires-guard.sh` | `test/mutations/` | Dauer-Sensor zu 4 |

`harness/conventions.md:1236-1240` sagt *„**eine** Prüfung ihres bloßen Vorhandenseins"* und nennt
dafür nur `TestEnforce_EmitsAllMechanicFiles`. Nummer 1 ist eine zweite, in derselben Datei, deren
anderen Block der Satz als Artefakt mitzählt. Das ist unabhängig davon falsch, ob man vier oder
fünf zählt — genau die Vermischung, die `slice-076` (c) benennt.

**Trägt (d)s Zielort die Sache schon?** Ja. `slice-074` §1 Punkt 3 nennt die zwei Lesarten
(*„Ob der Hook lief und seine Entscheidung folgenlos blieb, oder ob er gar nicht feuerte"*) und
den Auflösungs-Trigger im Satz danach (*„Zeile vorhanden → der Hook lief … Keine Zeile → der Hook
feuerte nicht"*). Die Aussage von (d), der Plan trage den Trigger bereits, hält. Was **nicht**
hält, ist ein Satz im Bezugs-Block desselben Plans — siehe LOW-2.

**Der Preis ist erledigt-mit-Rest.** Er ist benannt, aber nur in der Commit-Message von
`736b562`. Siehe LOW-1.

---

## MEDIUM-2 — **erledigt**

**Gegenstand:** *„Zähne haben"* bezeichnete im Guard-Kopf und im Plan verschiedene Mengen.

**Beleg (eigene Messung, über den Inhalt der Fälle).** Jeder Fall auf eine isolierte Kopie
angewandt, die geänderte Zeile abgelesen:

```
== 117  ALT :94: [ -f "$agents_dir/$stype.md" ] || exit 0
        NEU :94: : # MUTIERT
== 118  ALT :94: [ -f "$agents_dir/$stype.md" ] || exit 0
        NEU :94: case "$stype" in planner|architect|…) ;; *) exit 0 ;; esac
== 119  ALT :99: [ "$rib" = "false" ] && exit 0
        NEU :99: if [ "$rib" = "false" ] || [ "$rib" = "ABSENT" ]; then exit 0; fi
== 139  ALT :89: [ "$stype" = "ABSENT" ] && { emit_deny "…subagent_type (fail-closed)…"; exit 0; }
        NEU :89: [ "$stype" = "ABSENT" ] && exit 0
== 120/121/122   guard geaendert? NEIN   extraktor geaendert? JA
```

Zeile 94 ist die Rollen-Frage, kein `emit_deny`-Zweig — **117 und 118 treffen keinen
fail-closed-Zweig**. Die Angabe der Aufgabenstellung ist damit bestätigt. Gegenprobe über alle
vier Guard-Fälle: die Zeilen `:67` (awk), `:69` (Extraktor) und `:76` (Parse-Zweifel) bleiben in
jedem der vier Fälle unverändert. **Drei der fünf Zweige haben keinen Dauer-Fall.** Bestätigt.

Die zwei im Kopf genannten Dauer-Fälle habe ich zusätzlich über ihre Wirkung gefahren, mit
derselben Payload, die der jeweilige bats-Fall benutzt:

```
KONTROLLE (unmutiert)
  ohne Typ            : …"permissionDecisionReason": "Agent-Guard: Aufruf ohne lesbaren subagent_type (fail-closed)…"
  Rolle ohne Schalter : …"permissionDecisionReason": "Rollen-Agent 'reviewer' muss im VORDERGRUND starten…"
NACH Fall 139
  ohne Typ            : (leere Ausgabe)   -> bats "Agent-Aufruf ohne Subagent-Typ -> DENY" faellt
NACH Fall 119
  Rolle ohne Schalter : (leere Ausgabe)   -> bats "Rolle ohne Schalter -> DENY" faellt
```

Und der Parse-Zweifel hat den bats-Fall, den der Kopf ihm zuschreibt — direkt gefahren:

```
$ printf '%s' 'nicht mal JSON' | ./.claude/hooks/pretooluse-agent-guard.sh
…"permissionDecisionReason": "Agent-Guard: Aufruf nicht eindeutig lesbar (Parse-Zweifel, fail-closed)…"
$ printf '%s' 'nicht mal JSON' | awk -f harness/tools/extract-agent-call.awk ; echo rc=$?
rc=3
```

**Extensionaler Abgleich Kopf ↔ Plan §6.**

| Zweig | Kopf `:13-16` (nach `eefa39f`) | Plan `:287-289` |
|---|---|---|
| awk (`:67`) | UNBEWACHT | unbewacht, kein Fall in `test/` |
| Extraktor (`:69`) | UNBEWACHT | unbewacht, kein Fall in `test/` |
| Parse-Zweifel (`:76`) | nur `test/agent-guard.bats` | bats-Fall, kein Dauer-Sensor |
| fehlender Typ (`:89`) | `test/mutations/139` | Zähne |
| fehlender Schalter (`:101`) | `test/mutations/119` | Zähne |

Dieselbe Extension, Zweig für Zweig. Der Kopf trägt das Wort *„Zähne"* nicht mehr und damit auch
keine Zahl, die zwei Artefakte verschieden auffüllen können. Der Befund ist aufgelöst.

**Warum `comment-claims` schweigt — verifiziert, mit entkoppelten Varianten.** Die drei Kandidaten
(Verneinungs-Ausnahme, Schreibungsabhängigkeit von `CLAIM`, `block_sensor`) waren in allen
bisherigen Läufen gleichzeitig aktiv. Vier Blöcke ohne jede Sensor-Nennung trennen sie:

```
v1  "… sind unbewacht, nicht unbewachbar."   rc=0  0 Befund(e)
v2  "… sind unbewacht."                      rc=1  1 Befund  (Zeile 2)
v3  "… sind UNBEWACHT, nicht unbewachbar."   rc=0  0 Befund(e)
v4  "… sind UNBEWACHT."                      rc=0  0 Befund(e)   <- entscheidend
v5  wie v1 + "Sensor: test/agent-guard.bats" rc=0  0 Befund(e)
```

`v4` ist der Beleg: **ohne** Verneinung und **ohne** Sensor bleibt die versale Fassung stumm —
`CLAIM` ist schreibungsabhängig, `UNBEWACHT` trifft es nicht, `unbewachbar` auch nicht. `v2` zeigt
die Gegenrichtung: kleingeschrieben und ohne Verneinung feuert der Gate. Am realen Kopf-Block
(Zeilen 1–35, das Blockende liegt bei `:36 set -euo pipefail`) gibt es genau **einen**
`CLAIM`-Treffer:

```
:21: # nicht gegen das Verzeichnis veralten, das er bewacht. Sensor: test/agent-guard.bats,
```

und drei `SENSOR`-Treffer (`:15`, `:16`, `:21`). Nimmt man **nur dem Kopf-Block** jede
Sensor-Nennung, fällt der Gate mit Exit 1 auf genau diese Zeile:

```
rc=1
comment-claims: Behauptung ohne Sensor-Nennung (AGENTS.md §3.6):
  …/blockonly.sh:21  nicht gegen das Verzeichnis veralten, das er bewacht. Sensor: XXX,
```

Die Angabe in der Message von `eefa39f` ist damit bestätigt. Zur Aufgabenstellung siehe
§*Angaben der Vorlage* — die dortige Zuschreibung *„die Verneinungs-Ausnahme greife … widerlegt"*
trifft nicht, was mein Vorbericht gemessen hat.

---

## Findings

### LOW-1 — Der bewusst getragene Preis steht in keinem Artefakt des Pflicht-Lesepfads

- **kategorie:** LOW
- **quelle:** `AGENTS.md` §5 (Artefakt beschreibt die Sache) · [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
- **pfad:** `harness/conventions.md:1236-1243`
- **befund:** Dass die Aussage *„eine Prüfung ihres bloßen Vorhandenseins"* über den eigenen
  deklarierten Umfang gemessen falsch ist und bis zum Umzug stehen bleibt, sagt allein die
  Commit-Message von `736b562` (*„Bis dahin steht im Pflicht-Lesepfad eine gemessen falsche
  Zahl"*). Gemessen: `grep 'slice-07[0-9]'` über den Eintrags-Block `835…1658` ergibt **0**
  Treffer — `MR-018` zeigt weder auf `slice-076` noch auf `slice-074`; die Slice-Nennungen des
  Blocks sind 059, 060, 066, 068. `harness/conventions.md` steht in `CLAUDE.md` als Punkt 3 der
  Vor-jeder-Änderung-Leseliste. **Failure-Szenario:** wer die Stelle liest, entnimmt ihr, es gebe
  über den genannten Umfang genau eine Existenzprüfung der `settings.json`, und baut darauf — es
  sind zwei, und am Ort des Lesens steht nichts, das die Angabe einschränkt oder auf ihren
  Korrekturort zeigt.
- **verifizierbar:** nein — kein Gate liest Sätze in Markdown; am Artefakt nachprüfbar über den
  Block-Grep und `harness/tools/smoke.sh:75-82`.

### LOW-2 — Der Träger, auf den `slice-076` (d) sich stützt, widerspricht sich an genau dieser Stelle

- **kategorie:** LOW
- **quelle:** Maintainability · `AGENTS.md` §3.6
- **pfad:** `docs/plan/planning/open/slice-074-agent-vor-aufruf-protokoll.md:14` gegen `:188-193`
- **befund:** Der Bezugs-Block sagt *„Prüfschritt 3 (c) benennt die Sonde, **die dieser Slice
  fährt**"* und zitiert sie wörtlich; §3 lehnt dieselbe Sonde ausdrücklich ab: *„Geprüft und
  ABGELEHNT … **die Schlüsselnamen von `tool_input` als Menge**: … der Rest beantwortete keine
  benannte Frage."* `slice-076` (d) erklärt den Posten am Eintrag für *ersatzlos* mit der
  Begründung, `slice-074` trage ihn bereits — das trifft den **Auflösungs-Trigger** (§1 Punkt 3,
  gemessen, siehe oben), nicht die Sonde. Herkunft gemessen: der Satz stammt aus `94c0c72`, dem
  Schnitt-Commit von `slice-074`, also **vor** diesem Bereich; `8864708` hatte ihn beiläufig auf
  die tragfähige Fassung gebracht, und der byte-genaue Revert `736b562` musste ihn mit
  zurücknehmen, weil er ein Zitat aus `MR-018` trägt. **Failure-Szenario:** der Umsetzer von
  `slice-076` streicht den Posten unter Verweis auf `slice-074`; wer dort nachsieht, findet im
  Bezugs-Block die Zusage, die Sonde werde gefahren, und in §3 ihre Ablehnung — der Status der
  benannten, nicht gefahrenen Messung steht danach in keinem Artefakt widerspruchsfrei.
- **verifizierbar:** nein — Prosa in einem `open/`-Plan, außerhalb jedes Gates.

### LOW-3 — Die zwei neuen Pfad-Nennungen im Guard-Kopf validiert kein Sensor

- **kategorie:** LOW
- **quelle:** Maintainability · `AGENTS.md` §4 (`comment-claims`-Prüfbereich) · `LH-QA-01`
- **pfad:** `.claude/hooks/pretooluse-agent-guard.sh:15-16`
- **befund:** `eefa39f` trägt `test/mutations/139` und `test/mutations/119` in den Kopf. Beide
  Bestandteile der Prüfung fehlen: `comment-claims.sh` prüft die **Existenz** nur für Namen der
  Form `Test[A-Z]…` (`:99-109`) — ein erfundener Mutations-Pfad setzt `block_sensor` und passiert
  den Gate, gemessen:

  ```
  # Zweig X ist bewacht (test/mutations/999).
  -> rc=0  comment-claims: 1 Datei(en) geprueft, 0 Befund(e)
  existiert test/mutations/999-*.sh? 0
  ```

  Und `codepaths.roots` in `.d-check.yml:50` sind `[spec, docs, harness]`; `.claude/` liegt
  außerhalb, die Pfade werden also auch dort nicht aufgelöst. **Failure-Szenario:** ein
  Mutations-Fall wird umnummeriert — im Bereich 117–139 dieses Slice über zehn Commits verteilt
  geschehen —, und der Kopf nennt danach eine Nummer, die einen anderen oder gar keinen Zweig
  bewacht, während `make gates` grün bleibt.
- **verifizierbar:** ja, in der Gegenrichtung — der Probelauf oben zeigt, dass kein Gate feuert.

### LOW-4 — Der neue Kopf-Satz koordiniert zwei Paare; *„bei JEDEM Aufruf"* liest sich nur noch über das zweite

- **kategorie:** LOW
- **quelle:** Maintainability (Doku-Drift)
- **pfad:** `.claude/hooks/pretooluse-agent-guard.sh:13-16`
- **befund:** Die alte Fassung war eine flache Viererliste (*„fehlendes awk, fehlender Extraktor,
  Parse-Zweifel und fehlender Typ bei JEDEM Aufruf"*) — der Zusatz band alle vier. Die neue
  Fassung setzt ein zweites *„und"*: *„fehlendes awk **und** fehlender Extraktor (…),
  Parse-Zweifel (…) **und** fehlender Typ (…) **bei JEDEM Aufruf**"*. Damit ist die Lesart
  verfügbar, der Zusatz gelte nur dem zweiten Paar. Der Code sagt anderes: `:66` und `:68` liegen
  vor jeder Verzweigung, sie feuern bei jedem Eingang. **Failure-Szenario:** wer die Zweig-Liste
  des Kopfes als Inventar benutzt, führt awk und Extraktor als bedingte Zweige und sucht ihre
  Bedingung — es gibt keine.
- **verifizierbar:** nein — Prosa; ablesbar an `.claude/hooks/pretooluse-agent-guard.sh:66-69`
  gegen `:94`.

### INFO-1 — *„34-Zeilen-Block"* in der Message von `eefa39f` ist um eine Zeile zu klein

- **kategorie:** INFO
- **quelle:** `AGENTS.md` §3.6 (die Commit-Message ist eine Zusage)
- **pfad:** Commit-Message `eefa39f`
- **befund:** `comment-claims.sh:57` erkennt eine Kommentar-Zeile über `^[ \t]*#` — die
  Shebang-Zeile `#!/usr/bin/env bash` fällt darunter. Der Block, den der Gate bildet, geht von
  Zeile **1** bis Zeile **35** und ist 35 Zeilen lang; das Blockende ist gemessen `:36
  set -euo pipefail`. Die Aussage der Message ist in der Sache richtig (genau eine Behauptung,
  gedeckt), nur die Zahl nicht. Dieselbe Zahl steht bereits im Vorbericht vom selben Tag; sie ist
  dort ebenso ungemessen übernommen.
- **verifizierbar:** nein — kein Gate liest Commit-Messages.

### INFO-2 — Plan §6 benutzt *„unbewacht"* enger als `AGENTS.md` §3.6, sagt aber die Tatsache dazu

- **kategorie:** INFO
- **quelle:** `AGENTS.md` §3.6
- **pfad:** `docs/plan/planning/in-progress/slice-060-rollen-achse.md:287-289`
- **befund:** §3.6 setzt *„gelistet heißt: wer keinen Fall in `test/mutations/` hat, ist
  unbewacht"* — danach sind **drei** Zweige unbewacht (awk, Extraktor, Parse-Zweifel, gemessen
  oben). Der Plan nennt **zwei** so und begründet das mit einem selbst deklarierten, weiteren
  Kriterium (*„kein Fall in `test/` erreicht sie"*), unter dem der Parse-Zweifel wegen seines
  bats-Falls herausfällt. Der Satz nennt die tragende Tatsache im selben Atemzug (*„hat einen
  bats-Fall, aber keinen Dauer-Sensor"*), die Extension ist am Ort des Lesens also rekonstruierbar
  — das ist der Unterschied zu MEDIUM-2, wo sie es nicht war. Der Plan ist in diesem Bereich nicht
  angefasst worden (0 Dateien unter `in-progress/`); der Posten wird mit dem `git mv` eingefroren.
- **verifizierbar:** nein — Prosa im Plan.

---

## Negativbefunde (geprüft, ohne Befund)

1. **Der Revert ist vollständig und nicht mehr als nötig.** Beide von `8864708` berührten Dateien
   stehen auf ihren Blob-Hashes von `8864708^`; kein dritter Pfad ist mitgelaufen. Kein Befund.
2. **`b43ac6d`s Größen-Angaben stimmen exakt.** Gemessen: 410 Z / 30.344 B → 422 Z / 31.560 B,
   also +12 Z / +1.216 B; `--numstat` 43+/31−. Alle vier Zahlen der Message sind reproduziert.
   Kein Befund.
3. **Keine Entstehungs-Erzählung in den hinzugefügten Zeilen.** `git show b43ac6d | grep '^+'`
   gegen `bis <Datum>|frühere Fassung|Vorgänger|Befund|Runde|bisher|zuvor|stand hier` → **0**
   Treffer. Die Treffer der Gesamtdatei (`:124-127`, `:225`) sind Messungen *über* die
   Entstehungs-Erzählung in `MR-018`, also Gegenstand, nicht Selbstbeschreibung. Kein Befund.
4. **Kein Absatz, wo ein ersetzter Satz gereicht hätte.** Vier der sechs Hunks sind Ersetzungen
   und schrumpfen (Bezugs-Block −1, ADR-Index −2, §6 −1) oder halten die Länge; die Art-Angabe
   wanderte bei (a) und (b) aus einem Nachsatz in den Kopf des Postens, ohne Zuwachs. Der Zuwachs
   liegt in (c) +6 und (d) +8 — neuer Gegenstand, den es im Dokument nicht gab — sowie Schritt 2
   +2 und Schritt 5 +1. Die drei Gegenfinanzierungen der Message sind im Diff einzeln
   nachweisbar. Kein Befund.
5. **`eefa39f` hält Passage und Datei auf Maß.** Absatz `:11-16` sechs Zeilen vorher wie nachher,
   Datei 102 Zeilen vorher wie nachher, `--numstat` 3+/3−. Kein Befund.
6. **Das Ziel jedes Guard-Falls ist über den Inhalt bestimmt, nicht über den Namen.** Genau vier
   Fälle führen `# files: .claude/hooks/pretooluse-agent-guard.sh` (117, 118, 119, 139), drei
   führen den Extraktor (120–122); die Zuordnung des Kopfes deckt sich mit der gemessenen
   Zielzeile. Kein Befund.
7. **Die zwei genannten Dauer-Fälle tragen ihren Zweig wirklich.** Beide nehmen der jeweiligen
   Payload die Deny-Antwort (Ausgabe 0 Byte); der zugehörige bats-Fall fiele. Kein Befund.
8. **`AGENTS.md` §3.1.** Kein neuer Gate-Name, kein neues Target; `Makefile` und `harness/mk/`
   im Bereich unberührt (0 Zeilen). Kein Befund.
9. **`AGENTS.md` §3.2.** Kein `//nolint`, kein `# shellcheck disable` unter den hinzugefügten
   Zeilen; `shell-lint` im eigenen `make gates`-Lauf grün. Kein Befund.
10. **`AGENTS.md` §3.3.** Kein Rename im Bereich (`--name-status -M` → viermal `M`). Kein Befund.
11. **`AGENTS.md` §3.4.** `docs/plan/adr/` im Bereich unberührt (0 Dateien). `ADR-0013` und
    `ADR-0014` sind seit ihrer Annahme unangetastet. Kein Befund.
12. **`AGENTS.md` §3.5.** Keine Schwellen-Senkung. `736b562` stellt einen Stand wieder her,
    `eefa39f` **verengt** eine Zusage (aus einer Sammelzahl werden fünf einzelne Zuordnungen),
    `b43ac6d` erweitert ein Inventar. Kein Befund.
13. **`LH-QA-03` / `ADR-0004`.** Der Guard bleibt reines bash + awk; `eefa39f` ändert nur Kommentar.
    Kein Befund.
14. **`slice-060`s Plan ist im Bereich nicht berührt** (0 Dateien unter `in-progress/`). Die vier
    LOW und zwei INFO des Vorberichts sind damit unverändert offen — auftragsgemäß nicht
    Gegenstand. Kein Befund.
15. **`make gates` grün, eigener Lauf auf `eefa39f`.** Exit 0. Kein Befund.

---

## `make gates`, eigener Lauf

```
baseline-verify: v3.5.2 OK — 42 Dateien (Integritaet + Vollstaendigkeit, netzlos)
d-check: 280 Datei(en) geprüft, 0 Befund(e)
1..150
comment-claims: 38 Datei(en) geprueft, 0 Befund(e)
span-check: Emitter vorhanden, ein Span geschrieben, Ablageort git-ignoriert
EXIT=0
```

Keine `not ok`-Zeile im Lauf. Die Zahlen decken sich mit der Ausgangslage der Aufgabenstellung.

---

## Kategorie-Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 4 |
| INFO | 2 |
| **Summe** | **6** |

**Wiederkehrende Klasse.** Der Vorbericht protokollierte den Wechsel *„von der Zusage in ihre
Begründung"*. Er tritt hier nicht mehr auf: die drei Begründungen dieser Runde — Revert statt
Regel, Sensor-Nennung statt Zahl, Schreibungsabhängigkeit statt Verneinung — halten alle drei
gegen die entkoppelte Messung. An ihre Stelle tritt eine schwächere: **die Begründung steht in der
Commit-Message und nicht am Artefakt** (LOW-1) und **ein Träger wird benannt, ohne dass er
widerspruchsfrei ist** (LOW-2). Beide sind Ablage-Fragen, keine Mess-Fragen. Das gehört in die
Closure-Notiz.

---

## Verdikt

**KONFORM.**

Beide MEDIUM des Vorberichts sind erledigt, jedes mit eigenem Beleg: MEDIUM-1 durch einen
byte-genauen Revert bei erhaltenem Sachmangel-Inventar in `slice-076`, MEDIUM-2 durch eine
Zuordnung, die ich über den Inhalt der Mutations-Fälle nachgemessen habe und die sich extensional
mit Plan §6 deckt. Kein HIGH, kein MEDIUM; die vier LOW und zwei INFO blockieren nach der
Kategorien-Semantik des Reviewer-Skills nicht.

**Ist `slice-060` closure-reif? Aus Review-Sicht: ja.** Der Closure-Trigger §5 verlangt an dieser
Achse *„Review konform (Modul 10) mit **ausgestelltem** Verdikt"* — das liegt hiermit vor. Die
übrigen Bedingungen des Triggers liegen nicht auf meiner Achse und sind hier nur als Tatsache
festgehalten, nicht als Verdikt: die sechs DoD-Kästchen stehen auf `- [ ]` (gemessen: 6 × `- [ ]`,
0 × `- [x]`), `§7 Closure-Notiz` trägt den Platzhalter-Kommentar, `make mutate` als CI-Vollauf und
die Verifikation nach Modul 11 sind getrennte Kontexte.

**Was mit dem `git mv` eingefroren wird und nicht behoben ist:** die vier LOW und zwei INFO des
Vorberichts (nicht in Auftrag) sowie INFO-2 dieses Berichts. LOW-1 bis LOW-4 dieses Berichts
liegen außerhalb von `slice-060`s Artefakten (`harness/conventions.md`, `slice-074`, der
Guard-Kopf) und werden vom `git mv` nicht eingefroren.

---

## Angaben der Vorlage — geprüft, mit zwei Korrekturen

Ausdrücklich gemeldet statt still übergangen:

1. **Falsch:** *„`b43ac6d` … (+17/−5 nach eigener Rechnung)"*. Die eigene Rechnung des Commits
   lautet `43+/31−` bei netto +12 Zeilen; `+17/−5` steht weder in der Message noch im `numstat`.
   Die Angabe *„12 Zeilen / 1.216 Byte"* ist dagegen exakt.
2. **Zu stark:** *„drei Begründungen … alle drei widerlegt … zuletzt auch die aus deinem eigenen
   Vorbericht (die Verneinungs-Ausnahme greife)"*. Gemessen (`v1`, oben) **greift** die
   Verneinungs-Ausnahme für die kleingeschriebene Fassung: ohne jede Sensor-Nennung meldet sie
   0 Befunde. Widerlegt ist nicht die Aussage, sondern ihre **Isolation**: in jeder damals
   gefahrenen Variante stand die Sensor-Nennung auf derselben Zeile, die drei Ursachen waren nicht
   getrennt. Die operative Ursache für den Text, wie er dasteht, ist die Schreibungsabhängigkeit
   (`v4`) — das bestätigt die Aufgabenstellung; die Zuschreibung „widerlegt" trifft meinen
   Vorbericht in der Sache nicht.
3. **Bestätigt:** 117 und 118 treffen `:94` und keinen fail-closed-Zweig · drei der fünf Zweige
   haben keinen Dauer-Fall · `eefa39f` hält 6 auf 6 · `736b562` ist ein reiner Revert · die
   Ausgangslage `make gates` Exit 0 mit d-check 280/0, comment-claims 38/0 und 150 bats.
4. **Werkzeug-Konflikt, gemeldet statt umgangen:** die Betriebs-Notiz meiner Umgebung untersagt
   das Anlegen von Report-Dateien, während `.harness/skills/reviewer.md` §Ablage und dieser
   Auftrag genau diese Datei verlangen — und `da1ffa9` zeigt, dass Review-Berichte in diesem Repo
   als eigener Commit landen. Aufgelöst zugunsten des repo-gepflegten Skills; die Befunde gehen
   zusätzlich vollständig als Text an den Aufrufer.
