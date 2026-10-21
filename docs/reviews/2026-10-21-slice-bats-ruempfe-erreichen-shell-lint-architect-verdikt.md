# Architect-Verdikt: slice-bats-ruempfe-erreichen-shell-lint

**Rolle:** Architect. **Datum:** 2026-10-21. **Gegenstand:** die Architect-Frage aus §1 von
`slice-bats-ruempfe-erreichen-shell-lint` (Bezug `CO-001`, `slice-113-co-001-ist-faellig`,
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`AGENTS.md`](../../AGENTS.md) §3.2, §3.5, §3.6, §3.9, `MR-049`). Zeitdokument, keine ADR.

**Ergebnis in einem Satz:** keine Senkung, keine ADR — der Prüfbereich wird geöffnet, nicht gelockert;
SC2154 wird durch einen Deklarations-Fuß des Extrakts erledigt, SC2016 durch eine **eine** Ausnahme am
bats-Aufruf mit ganzem Gegenstand; der Extrakt braucht keinen schreibbaren Mount.

**Was lokal lief** (macOS-Host, Docker; [`AGENTS.md`](../../AGENTS.md) §3.9 — Docker-Läufe in den
gepinnten Images, kein Host-Werkzeug; kein Normbeleg, nur Messung): `BATS_IMAGE` und `SHELLCHECK_IMAGE`
aus dem `Makefile`, Sonden unter dem gitignorierten Zustands-Bereich, danach gelöscht.

## Frage 1 — Senkung (§3.5) oder Config-Ausnahme (§3.2)?

**Config-Ausnahme, keine Senkung.** Wortlaut §3.5: *„Jede Schwellen-Senkung (Modul-Aktivierung,
Strenge) ist ein ADR … Eine befristete Ausnahme für einen Teil … ist keine Senkung, sondern ein
Carveout"*, und §3.6: *„Die Regel ist eine **Verschärfung** und braucht darum kein ADR (§3.5 gilt für
Senkungen …)"*. Gesenkt wird eine Schwelle, die vorher galt. Für die 50 `test/*.bats` galt vorher
**keine**: `CO-001` schließt sie ganz aus. Gemessen am gepinnten shellcheck (0.11.0), `shellcheck
--shell=bash --format=gcc` über den Extrakt aller 50 Dateien:

```
$ … | grep -c ': \(error\|warning\|note\):'      → 173   (Befunde in 39 Dateien; Vorlauf des Planners bestätigt)
  SC2016 60 · SC2154 58 · SC2164 36 · SC2094 4 · SC1003 4 · SC2030/2031/2012 je 2 · Rest je 1
```

Von 0 geprüft auf „173 minus Ausnahmen" ist Anhebung. Keine Zeile, die heute grün ist, wird danach
weniger geprüft: `harness/tools/*.sh`, `test/mutations/*.sh` und die übrigen Pfade bleiben im
unveränderten Aufruf (Frage 2). Die Senkungen in diesem Repo, die eine ADR trugen
(`ADR-0098` Festlegung 3, `ignore-refs`-Paar), nahmen jeweils eine **bestehende** Prüfung zurück; dieser
Fall nicht. `MR-001` (Doc-Gate-Schärfung) und `MR-017` (emittierte Prüfbereiche, fail-closed für
fremde Adopter) sind nicht einschlägig: beide regeln andere Gates bzw. die emittierte Ebene; der Slice
ist ausdrücklich Dogfood.

**Was §3.5 Absatz 2 trotzdem verlangt, und es ist keine ADR:** *„Eine Ausnahme nennt ihren ganzen
Gegenstand."* Die Begründung neben der Ausnahme nennt Regel, Baum und Wirkung. Der Wächter dafür
(`internal/ausnahmegrund`) liest nur `.d-check.yml`; für das Skript/den Aufruf trägt die Pflicht der
Implementer, der Reviewer prüft sie. **Sie gilt für beide Mittel unten**, auch für den Fuß, der in der
Wirkung eine Ausnahme ist (Frage 3).

**Vorgeschriebener Wortlaut des Gegenstands (Constraint für den Implementer):**

- **SC2016:** ausgenommen ist die Regel SC2016 *(`$` in Einzelquotes)* für den Extrakt **aller**
  `git ls-files 'test/*.bats'`. Begründung: im `@test`-Rumpf sind Einzelquotes mit `$` überwiegend
  gewollt — `bash -c '…$x…'`-Payloads, grep-Muster, Heredoc-Texte, Zusicherungen gegen wörtliche
  `$msgfile`. Gemessen: **60** Treffer in **16** Dateien (u. a. `tap-nachzug.bats`,
  `targets-modul-wiring.bats`). Genannte Grenze: ein *versehentlich* in Einzelquotes stehendes `$var`
  in einem bats-Rumpf wird nicht gemeldet.
- **SC2154** (Fuß, Frage 3): nur die drei Namen `status`, `output`, `lines`; der Fuß gilt in allen 50
  Extrakten. Genannte Grenze: eine Verwendung dieser Namen **ohne** vorangehendes `run` wird nicht
  gemeldet. `BATS_*` braucht nichts: shellcheck meldet Großbuchstaben-Variablen nicht
  (Vorkommen im Extrakt: `BATS_TEST_DIRNAME` 49, `BATS_TEST_TMPDIR` 35, `BATS_IMAGE` 2; SC2154 auf
  ihnen: 0).

## Frage 2 — auf den bats-Lauf begrenzen?

**Ja, und es geht ohne Konfigurationsdatei.** Das gepinnte shellcheck kennt beide Wege
(`--help` im `SHELLCHECK_IMAGE`):

```
-e CODE1,CODE2..    --exclude=CODE1,CODE2..    Exclude types of warnings
                    --norc                     Don't look for .shellcheckrc files
                    --rcfile=RCFILE            Prefer the specified configuration file over searching for one
```

Im Repo liegt **keine** `.shellcheckrc` (`ls .shellcheckrc` → nicht vorhanden); sie darf auch **nicht**
an der Wurzel angelegt werden: shellcheck sucht sie aufwärts, sie schaltete SC2016 für `harness/tools`
und `test/mutations` stumm. Gemessen: `--rcfile` mit `disable=SC2154` → 0 SC2154 auf `guard.bats`-Extrakt
gegenüber 1 ohne; `-e SC2016,SC2154` über alle 50 → 55 Befunde. **Empfehlung:** `--exclude=SC2016` am
**eigenen** shellcheck-Aufruf für den Extrakt (zweiter `docker run`), der bestehende Aufruf des Rezepts
bleibt unverändert und behält die volle Schwelle. Der Eintrag steht damit im Verkettungs-Skript samt
Gegenstands-Kommentar (Wortlaut oben) — ein zentraler Ort, kein Inline-Disable
([`AGENTS.md`](../../AGENTS.md) §3.2). `--rcfile` auf eine Datei **außerhalb** des Namens
`.shellcheckrc` wäre gleichwertig; die Flag-Form spart eine Datei.

## Frage 3 — Kopf statt Ausnahme?

**Trägt für SC2154, und ist ein Fuß, kein Kopf.** Ein vorangestelltes Statement verschöbe jede Zeile um
eins; die Rück-Zuordnung (unten) ist 1:1 und soll es bleiben. Angehängt wird eine Zeile **hinter** den
Extrakt (SC2154 ist flussunabhängig: eine Zuweisung irgendwo genügt):

```
status=0; output=; lines=(); : "$status" "$output" "${lines[@]}"
```

Ohne den `: …`-Teil entstehen **85** SC2034 (unbenutzte Zuweisung in Dateien ohne `run`); mit ihm nicht.
Messung (alle 50 Extrakte, gleiche Kommandos wie Frage 1):

| Lage | Befunde | SC2154 |
|---|---|---|
| Extrakt pur | 173 | 58 |
| Fuß ohne `:`-Verwendung | 199 | 0 (SC2034 +85) |
| Fuß mit `:`-Verwendung | **115** | **0** |

Die 115 sind exakt die 173 ohne die 58 SC2154: Zeile und Spalte der übrigen Befunde sind identisch
(Diff beider Ausgaben leer, bis auf SC2154). Der Fuß löscht keine Regel, er deklariert die Namen, die
das DSL bindet — die Aussage „bats setzt sie" ist wahr, nicht behauptet. **In der Wirkung ist er eine
Ausnahme** (die drei Namen sind für SC2154 blind) und trägt darum denselben Gegenstands-Kommentar wie
SC2016, aber keine ADR: Verschärfung, siehe Frage 1. Rot gesehen ist er messbar: ohne Fuß 58 SC2154 —
das ist der Zahn für den Mutations-Fall; der echte Gegenbeweis (ein absichtlicher Befund im Rumpf wird
rot) lief: ein angehängtes `cd /tmp` im Extrakt → SC2164 gemeldet.

## Frage 4 — MR-049 bei Zwischenablage?

**Nein, wenn die Zwischenablage host-seitig entsteht.** Gemessen: **ein** Container im `BATS_IMAGE`
mit `:ro`-Baum, `--network none`, `BATS_ROOT=/opt/bats BATS_LIBDIR=lib`, ruft
`/opt/bats/libexec/bats-core/bats-preprocess` je Datei, schreibt alles auf stdout (Trennzeile je Datei);
der **Host** teilt die Ausgabe in Dateien unter dem gitignorierten Zustands-Bereich (`git check-ignore`
bestätigt). Container-Stderr blieb leer, 10089 Zeilen, 50 Dateien, ein Start statt 100. Der
`shellcheck`-Container mountet weiter den ganzen Baum `:ro` (der Zustands-Bereich liegt darin).
`MR-049` hält *„Kein Mount ist schreibbar"* (Messung 1: `grep -vc ':ro'` → 0) und hat als
Auflösungs-Trigger *„sobald eine Prüfung … in den Baum schreiben **muss**"* — hier schreibt der Host,
nicht die Prüfung; der Trigger feuert nicht, `MR-049` bleibt unberührt. **Constraint:** der Implementer
führt keinen `-v …:rw`-Mount ein; täte er es, feuert der Trigger und das ist ein `MR` des Architects.
Ein Grenzfall bleibt: schreibt der Host nicht mit dem Nutzer, der den Baum besitzt, gilt das Muster von
`artifact-copy.sh` (Host legt an) — hier ohnehin der Fall.

## Zeilenzuordnung (Zusatz)

**Der Extrakt trägt die Originalzeile 1:1.** `bats-preprocess` ersetzt die `@test`-Zeile in place durch
`bats_test_function … ;test_…() {`; alle anderen Zeilen bleiben (Messung über alle 50 Dateien: von den
nicht-`@test`-Zeilen weichen **2** ab, beide durch ein fehlendes Schluss-Newline des Originals). Der
Extrakt endet mit einer Zusatzzeile, sie liegt hinter dem Original. Beispiel: Fundstelle
`comment-claims`-Extrakt `:27` ist im Original Zeile 27 (`[ "$status" -eq 0 ]`). **Zu tun bleibt nur der
Dateiname:** shellcheck nennt den Extrakt-Pfad; das Verkettungs-Skript bildet ihn auf `test/<name>.bats`
zurück (z. B. per Namensschema der Ablage). Die Grenze aus §6 des Slice (Rück-Zuordnung) entfällt
damit als Grenze, bleibt als Pflicht des Skripts: **Datei und Zeile des Originals in der Ausgabe**.

## Empfehlung — Mischform

1. **SC2154 per Fuß** (0 Rest-Befunde, Zeilen bleiben).
2. **SC2016 per `--exclude` am bats-Aufruf**, Gegenstand wörtlich wie oben.
3. **Verkettung V1 mit host-seitigem Schreiben** (ein Container, stdout, Host splittet) — Frage 4 fällt
   weg, `MR-049` bleibt; V2 (100 Starts) ist nicht nötig.
4. **Danach zu beheben, ohne Suppression:** 115 Befunde nach Fuß, davon 60 SC2016 durch Ausnahme
   erledigt → **55** zu beheben (SC2164 36, SC2094 4, SC1003 4, SC2030/2031 je 2, SC2012 2, SC2129,
   SC2034, SC2020, SC1087, SC1001 je 1). Die Zahlen sind keine Erwartungswerte
   ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2).
5. **Zähne (§3.6), vom Implementer rot zu sehen:** (a) Fuß entfernt → SC2154 > 0; (b) `--exclude`
   entfernt → SC2016 > 0; (c) die Begrenzung — ein Fall, der die Ausnahme in den **bestehenden**
   Aufruf zieht, ist nicht rot zu färben, wenn kein Rumpf von `harness/tools` ein `$` in Einzelquotes
   trägt; dann steht diese Grenze am Skript („Begrenzung hält allein die Trennung der Aufrufe"), statt
   behauptet zu werden. Ein Wächter für den Satz *„die Ausnahme gilt nur für bats"* existiert nicht.

## Ist eine ADR nötig?

**Nein.** Weder Senkung noch neue Norm; `AGENTS.md` und `harness/conventions.md` bleiben unberührt. Die
Entscheidung steht in diesem Zeitdokument; die Gegenstands-Kommentare trägt das Skript. Eine Frage an
den Auftraggeber entfällt. Akzeptiertes Negativ: shellcheck-Konfiguration ohne Wächter für den
Gegenstands-Satz — einmaliger, am Skript sichtbarer Blindfleck, der Reviewer liest den Kommentar gegen
die Flags; ein eigener Sensor trüge mehr Aufwand als der Fall (zwei Flags, ein Fuß).

## Was der Implementer danach beginnen darf

Sobald der Auftraggeber `slice-bats-ruempfe-erreichen-shell-lint` priorisiert und das WIP-Limit frei
ist (Start-Trigger §4 des Slice: das Verdikt liegt hiermit vor, eine ADR gibt es nicht): Verkettungs-
Skript nach V1 (host-seitig, `:ro`-Mounts), Fuß und `--exclude=SC2016` mit Gegenstands-Kommentar,
Dateinamen-Rückabbildung, Behebung der 55 Befunde, `.bats` aus der Pfad-Ausnahme zurücknehmen,
Mutations-Fälle (a) und (b). `slice-113` bleibt hinter diesem Slice.
