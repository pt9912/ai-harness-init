# Freshness-Durchgang des Adaptions-Blocks — slice-sprung-auf-v690-wird-vollzogen

**Rolle:** Architect (pt9912) · **Datum:** 2026-09-17 · **Gegenstand:** Liefer-Punkt 2 des Slice
`slice-sprung-auf-v690-wird-vollzogen` (Adaptions-Durchgang und Stichprobe gegen den Bestand) ·
**Adressat:** Planner, Closure §7.

Dieses Dokument ist das Übergabe-Artefakt des Durchgangs. Den Ausgang *widerspricht* trägt der
Commit `0b7bcd2e` (2026-09-16), alle übrigen Ausgänge stehen nur hier.

## 1. Kopf

- **Tag:** `v6.9.0`. Die Prozedur stellt diese Fassung (`ADR-0056`, einzige Festlegung):
  Baseline-Regelwerk `modul-02-harness-bootstrap.md` §Freshness-Audit der vendored Baseline
  (Schritt 2).
- **sha256 des Release-Assets:** `8a4e0aaf597a9c67404cb7a350a6fba992f0c98195e011e025c073660ee55cce`
  (`grep -nE '^BASELINE_ZIP_SHA256' Makefile`).
- **Delta-Basis:** `v6.8.0`, gelesen nach `ADR-0043` Festlegung 2: die letzte Zeile mit gefülltem
  Delta-Nachweis in §Baseline des Konventionsspeichers vor diesem Sprung.
- **Gelesen, im Volltext am Stand `v6.9.0`:** die vier Regelwerks-Dateien mit inhaltlichem Delta.
  Jede übrige Datei unterscheidet sich nur im Tag ihres Quell-Links:

  ```sh
  O=63e0964e^; A=.harness/baseline/v6.8.0/regelwerk; N=.harness/baseline/v6.9.0/regelwerk
  for f in $N/*.md; do b=${f##*/}
    n=$(diff <(git show "$O:$A/$b") "$f" | grep '^[<>]' | grep -v 'ai-harness-course/blob/v6\.[89]\.0' | wc -l)
    [ "$n" -gt 0 ] && echo "$b $n"; done
  # README.md 2 · modul-02-harness-bootstrap.md 24 · modul-05-planning-harness.md 101 · modul-06-roadmap.md 2
  ```

  `63e0964e` ist der Commit, der den Baum tauscht; sein Vorgänger trägt `v6.8.0`. Alle Zahlen in
  diesem Abschnitt vergleichen zwei feste Stände und sind fest.

- **Wo das Delta liegt:**

  ```sh
  for b in README.md modul-02-harness-bootstrap.md modul-05-planning-harness.md modul-06-roadmap.md; do
    echo "$b: $(diff <(git show "$O:$A/$b") "$N/$b" | grep -E '^[0-9]' | tr '\n' ' ')"; done
  # README.md: 3c3 20c20 100c100
  # modul-02-harness-bootstrap.md: 3c3 282,284c282,302
  # modul-05-planning-harness.md: 3c3 20a21,22 34c36,38 61,63c65,70 95c102 103a111,113 161a172,252
  # modul-06-roadmap.md: 3c3 66c66
  ```

  | Datei | Zeilen (`v6.9.0`) | Abschnitt |
  |---|---|---|
  | `README.md` | 3 · 20 · 100 | Stand-Zeile; zwei Kurs-Links auf den Tag |
  | `modul-02-harness-bootstrap.md` | 282–302 | `#### Freshness-Audit der vendored Baseline (Schritt 2)`, Punkt *„Der Review vergleicht auch die Form"*: `MR` tritt in die Append-only-Klasse; *Templates* benennt die Artefakt-Klasse; Sensor-Gate-Dateien sind ausgenommen |
  | `modul-05-planning-harness.md` | 21–22 · 36–38 · 65–70 | `### Lifecycle als State Machine`: die Kanten `open → done` und `next → done` |
  | `modul-05-planning-harness.md` | 102 · 111–113 | `### Trigger je Lifecycle-Übergang und WIP-Limit (Modul 5)`: sechs statt fünf Übergänge |
  | `modul-05-planning-harness.md` | 172–252 | neuer `#### Ein Slice, dessen Gegenstand ein anderer übernimmt`, in `### Closure- und Lerneintrag-Regeln (Modul 5)` |
  | `modul-06-roadmap.md` | 66 | `### Roadmap-Struktur: fünf Abschnitte (Modul 6)`, Punkt Historische Trigger-Verschiebungen: *„ein Slice in einem anderen aufgegangen"* |

  Jeder Abschnitt, den ein Eintrag unten als gelesen nennt und der in dieser Tabelle fehlt, ist
  zwischen beiden Ständen gleich.

- **Grundgesamtheit:** alle aktiven Einträge am Stand vor dem Ergebnis-Commit, nicht eine
  Vorsichtung. Zwanzig davon nennen eine der drei geänderten Modul-Dateien beim Namen:

  ```sh
  git ls-tree --name-only 0b7bcd2e^ harness/conventions/ | grep -c '/MR-[0-9]*-.*\.md$'   # 56
  git grep -lE 'modul-0[256]-' 0b7bcd2e^ -- 'harness/conventions/MR-*.md' | wc -l         # 20
  ```

- **Frage je Eintrag** (Wortlaut der Prozedur): *„Regelt die neue Fassung das, wofür diese
  Adaption angelegt wurde?"* Die Antwort ist genau einer der fünf Ausgänge. Die Vorgabe des
  Auftraggebers gilt delta-gebunden: Wo das Delta *widerspricht* ergibt, wird die neue Fassung
  übernommen (`ADR-0056` §Konsequenzen).

## 2. Ausgang je Eintrag

**Ergebnis: 1 × widerspricht, 55 × bleibt gültig.** *gegenstandslos*, *teilweise überholt* und
*Bezug ist entfallen* kommen nicht vor.

Die Spalte *Gelesen* ist bei den zwanzig Einträgen gefüllt, die eine geänderte Modul-Datei beim
Namen nennen. Bei den übrigen nennt der Beleg, warum ihr Gegenstand außerhalb des Deltas liegt;
*Datei ohne Delta* verweist auf das erste Kommando in §1.

Die gelesenen Zitate stehen an beiden Ständen genau einmal:

```sh
for q in 'ohne das ganze Regelwerk im Kontext zu halten' 'keine Blank-Kopie im Repo' \
         'Rückbau ist ein neuer Eintrag, kein Edit' 'Das alte Verzeichnis fällt' \
         'sondern ein Formfehler und wird zuerst repariert'; do
  echo "$(git show "$O:$A/modul-02-harness-bootstrap.md" | grep -c "$q") $(grep -c "$q" "$N/modul-02-harness-bootstrap.md")  $q"; done
# jeweils: 1 1
```

| Eintrag | Ausgang | Gelesen (Stand `v6.9.0`) | Beleg |
|---|---|---|---|
| `MR-000` | bleibt gültig | — | Adoptions-Erklärung; `grundlagen-harness-dateien.md` ohne Delta. Ihre Aussage prüft die Stichprobe (§4). |
| `MR-001` | bleibt gültig | — | Ersetzte Regel in `grundlagen-referenz-richtung.md`, Datei ohne Delta. |
| `MR-002` | bleibt gültig | — | Fork (Hooks, Gate-Nachweis); das Delta regelt keine Hooks. |
| `MR-003` | bleibt gültig | — | Fork (Härtung des Nachweises); das Delta regelt ihn nicht. |
| `MR-004` | bleibt gültig | `modul-02` `#### Detail-Tabelle (Schritte 5–8: Inhalts-Phase)`, **Anmerkung zur vendored Baseline (Schritt 2)** | Anmerkung liegt außerhalb der Zeilen 282–302; Zitat unverändert. |
| `MR-005` | bleibt gültig | — | Ersetzte Regel in `grundlagen-durchsetzungsschicht.md`, Datei ohne Delta. |
| `MR-006` | bleibt gültig | wie `MR-004` | Anmerkung unverändert; der Cache-Teil ist ohnehin durch `MR-007` abgelöst. |
| `MR-007` | bleibt gültig | `modul-02` `#### Freshness-Audit …`, Punkt *„Der Review vergleicht auch die Form"* | Setzung 4 ersetzt *„Das alte Verzeichnis fällt erst, wenn der Review durch ist"*; der Satz steht außerhalb der Zeilen 282–302 und ist unverändert. Abweichung ohne Delta, sie bleibt. |
| `MR-008` | bleibt gültig | `modul-02` `#### Detail-Tabelle (Schritte 5–8 …)`, **Anmerkung zum Instanziierungs-Zeitpunkt (Schritt 2)** | Anmerkung unverändert. Der Hunk betrifft den Form-Durchgang, nicht die Instanziierung. |
| `MR-009` | bleibt gültig | `modul-02` `#### Gate-Fragment d-check.mk (Schritt 2)` | Abschnitt ohne Delta; ersetzte Regel in `modul-14-docker-harness.md`, Datei ohne Delta. |
| `MR-010` | bleibt gültig | wie `MR-009` | Abschnitt ohne Delta. |
| `MR-011` | bleibt gültig | — | Fork (Werkzeug-Pin); das Delta regelt ihn nicht. |
| `MR-012` | bleibt gültig | `modul-02` `#### Freshness-Audit …`, Punkt *„Release-Liste prüfen, nicht das Asset"* | Punkt außerhalb der Zeilen 282–302. |
| `MR-013` | bleibt gültig | wie `MR-012` | Punkt außerhalb der Zeilen 282–302. |
| `MR-014` | bleibt gültig | — | Ersetzte Regel in `grundlagen-durchsetzungsschicht.md`, Datei ohne Delta. |
| `MR-015` | bleibt gültig | — | Change Request bei Personalunion; `modul-03-spec.md` ohne Delta; die Teil-Ablösung durch `MR-036` bleibt. |
| `MR-017` | bleibt gültig | — | Emittierte Ebene; das Delta regelt sie nicht. |
| `MR-019` | bleibt gültig | — | Ersetzte Regel in `grundlagen-referenz-richtung.md`, Datei ohne Delta. |
| `MR-020` | bleibt gültig | — | Ersetzte Regel in `grundlagen-harness-dateien.md` §Konventionsspeicher, Datei ohne Delta. Der Hunk nimmt `MR` in die Append-only-Klasse des Form-Durchgangs auf und stützt sich dafür auf den Punkt *„Rückbau ist ein neuer Eintrag, kein Edit"* (unverändert). Der Hunk regelt die Form bestehender Einträge bei einem neuen Stand, nicht den Rumpf bei vollständiger Aufhebung. |
| `MR-021` | bleibt gültig | — | Ersetzte Regel in `modul-15-observability.md`, Datei ohne Delta. |
| `MR-024` | bleibt gültig | wie `MR-009` | Abschnitt ohne Delta. |
| `MR-025` | bleibt gültig | — | Fork (Zahl neben Kommando); das Delta regelt ihn nicht. |
| `MR-026` | bleibt gültig | — | Fork (Hard-Rule-Nummer); AGENTS-Vorlage ohne Delta. |
| `MR-027` | bleibt gültig | wie `MR-009` | Abschnitt ohne Delta. |
| `MR-028` | bleibt gültig | — | Ersetzte Regel in `grundlagen-traceability.md`, Datei ohne Delta. Das Feld `Wirksamkeits-Anlass` ist ein Zusatz des Repos, kein von einem Baseline-Stand nachgetragenes Pflichtfeld. |
| `MR-029` | bleibt gültig | `modul-02` `#### Freshness-Audit …`, Punkt *„Der Review geht durch die Adaptions-Liste"* (Formcheck-Satz) | Punkt außerhalb der Zeilen 282–302; Zitat unverändert. |
| `MR-030` | bleibt gültig | — | Fork (Rollen-Name); `modul-08-agentenrollen.md` ohne Delta. |
| `MR-031` | bleibt gültig | — | `grundlagen-harness-dateien.md` ohne Delta. Die Zeile 66 von `modul-06` nennt einen weiteren Fall einer Umplanung im Drift-Log; die Trennung von Drift-Log und Closure-Log bleibt. |
| `MR-032` | bleibt gültig | — | Ersetzte Regel in §Konventionsspeicher, Datei ohne Delta. Die Kopf-Marke nennt einen Zustand und zieht keine Form nach. |
| `MR-033` | bleibt gültig | — | Fork (Tag zur Baseline-Aussage); das Delta regelt ihn nicht. |
| `MR-034` | bleibt gültig | — | Werkzeug-Aussage zum Referenz-Ventil; das Delta regelt sie nicht. |
| `MR-035` | bleibt gültig | `modul-02` **Anmerkung zur vendored Baseline (Schritt 2)**; `README.md` | Anmerkung unverändert; `README.md` ändert nur Stand und Kurs-Links. Den Auslöser des Tag-Wechsels prüft §3. |
| `MR-036` | bleibt gültig | — | Ersetzte Regel in `grundlagen-source-precedence.md`, Datei ohne Delta. |
| `MR-037` | bleibt gültig | `modul-06` `### Wann Arbeit eine Welle braucht (Modul 6)` | Abschnitt ohne Delta (Zeile 66 liegt in §Roadmap-Struktur). Der neue `modul-05`-Abschnitt sagt für wellenlose Arbeit dasselbe: *„Wellenlose Arbeit erscheint in der Roadmap nicht"*. |
| `MR-038` | bleibt gültig | `modul-02` `#### Freshness-Audit …`, Punkt *„Rückbau ist ein neuer Eintrag, kein Edit"* | Punkt außerhalb der Zeilen 282–302; Zitat unverändert. |
| `MR-039` | **widerspricht → übernommen** | — (ersetzte Regel in §Konventionsspeicher); geprüft gegen `modul-02` Zeilen 282–302 | Setzung 1 (ein neues Pflichtfeld wird nachgetragen) steht gegen *„Für wiederkehrende Templates (…, `MR`) … bestehende werden nicht rückwirkend umgeschrieben"*. Setzung 2 ist ihre Ausnahme und entfällt mit ihr; Setzung 3 bleibt. Umsetzung in §5. |
| `MR-040` | bleibt gültig | `modul-02` `#### Freshness-Audit …`, Punkt *„Der Review vergleicht auch die Form"* (Zeilen 282–302) | Der Hunk erweitert die Klassenliste und sagt weiter *„Neue Instanzen folgen der neuen Form"*. Er bindet die Form, nicht Aussagen in einer Instanz; auf dieser Unterscheidung steht der Eintrag. |
| `MR-041` | bleibt gültig | `modul-02` **Anmerkung zum Instanziierungs-Zeitpunkt (Schritt 2)** | Anmerkung unverändert; Zitat *„keine Blank-Kopie im Repo"* unverändert. |
| `MR-042` | bleibt gültig | — | Anlass einer Lastenheft-Änderung; `modul-03-spec.md` ohne Delta. |
| `MR-043` | bleibt gültig | — | Ersetzte Regel in `grundlagen-traceability.md`, Datei ohne Delta. Gegenstand sind die im Bestand nachgetragenen Felder, und die bleiben stehen (`MR-060` §Geltungsbereich). |
| `MR-044` | bleibt gültig | — | Ersetzte Regel in `modul-15-observability.md`, Datei ohne Delta. |
| `MR-045` | bleibt gültig | — | Ersetzte Regel in §Konventionsspeicher, Datei ohne Delta. |
| `MR-046` | bleibt gültig | — | Ersetzte Regel in §Konventionsspeicher, Datei ohne Delta. |
| `MR-047` | bleibt gültig | `modul-02` `#### Freshness-Audit …`, die fünf Ausgänge | Ausgänge außerhalb der Zeilen 282–302. |
| `MR-048` | bleibt gültig | — | Ersetzte Regel in `modul-14-docker-harness.md`, Datei ohne Delta. |
| `MR-049` | bleibt gültig | — | Ersetzte Regel in `modul-14-docker-harness.md`, Datei ohne Delta. |
| `MR-050` | bleibt gültig | — | Ersetzte Regel in `modul-14-docker-harness.md`, Datei ohne Delta. |
| `MR-051` | bleibt gültig | `modul-05` `#### Zwei Schritte vor der Modus-Begründung`; `modul-06` `### Das Beobachtungs-Register (Modul 6)` | Beide Abschnitte ohne Delta. |
| `MR-052` | bleibt gültig | wie `MR-009` | Abschnitt ohne Delta. |
| `MR-053` | bleibt gültig | `modul-02` `#### Freshness-Audit …`, die fünf Ausgänge | Der Eintrag nennt den Rumpf *„append-only eingefroren"*; der Hunk sagt dasselbe jetzt für `MR` aus. Das Delta bestätigt ihn und löst nichts ab. |
| `MR-054` | bleibt gültig | — | Emittierte Ebene; das Delta regelt sie nicht. |
| `MR-055` | bleibt gültig | — | Fork (Stellen-Messung); das Delta regelt ihn nicht. |
| `MR-056` | bleibt gültig | — | Fork; `grep -rl 'claude/rules' .harness/baseline/v6.9.0/ \| wc -l` → 0. Auslöser und Betrag: §3. |
| `MR-057` | bleibt gültig | — | Kennungs-Form; `grundlagen-source-precedence.md` ohne Delta. Der neue `modul-05`-Abschnitt behandelt die Kennung als Adresse, nicht ihre Form. |
| `MR-058` | bleibt gültig | — | Fork (Messzeitpunkt); das Delta regelt ihn nicht. |
| `MR-059` | bleibt gültig | — | Reichweite von `MR-057`; das Delta regelt sie nicht. |

## 3. `MR-035` und `MR-056`: Auslöser und Betrag

**Der Auslöser hat gefeuert.** Beide Einträge sagen im Feld `Auflösungs-Trigger` sinngemäß: Ein
Tag-Wechsel zieht die Zeiger nach oder entfernt sie; *„welches von beidem, ist ein neuer Eintrag
nach Setzung 2"*. Der Tausch `63e0964e` hat die Zeiger umgehängt
(`git log --format=%h -1 -- .claude/rules/modul-05-planning-harness.md` → `63e0964e`).

**Setzung 2 greift nicht, weil die Menge gleich bleibt.** Setzung 2 von `MR-035` lautet: *„ein
Eintrag mehr oder weniger ist ein neuer Eintrag dieses Blocks"*. Der Tausch hat die Zeiger
nachgezogen und keinen entfernt. Vorher und nachher sind es dieselben sieben Module:

```sh
for c in 63e0964e^ 63e0964e; do
  git ls-tree "$c" .claude/rules/ | awk '$1=="120000"{print $3}' \
    | while read -r s; do git cat-file -p "$s"; echo; done \
    | grep '\.harness/baseline/' | sed 's|.*/||' | sort | tr '\n' ' '; echo; done
# beide Zeilen: grundlagen-traceability.md modul-01-entwicklungszyklus.md modul-05-planning-harness.md
#               modul-06-roadmap.md modul-08-agentenrollen.md modul-11-verification.md modul-13-quality-gates.md
```

Nachziehen ist damit weder *mehr* noch *weniger*, und ein neuer Eintrag ist nicht fällig. Der
Auswahl-Maßstab (`MR-056` Setzung 1: *Lauf-Berührung*) bleibt ebenfalls unberührt. Die zwei
geänderten Module liegen auf der Achse *Ablauf* (Slice-Lifecycle, Drift-Log). Die Baseline kennt
den Mechanismus weiterhin nicht (`claude/rules` im Baum: 0 Treffer, §2).

**Der Betrag: was angenommen ist.** `MR-056` Setzung 4 sagt: *„Der Auftraggeber hat den Aufschlag
genannt bekommen und angenommen — genannt war er mit dem Betrag am Stand `v6.7.2`"*. Angenommen
ist damit der **Aufschlag**, also der Preis, `modul-11` und `modul-13` aufzunehmen, genannt mit
einem Betrag. Die Setzung nennt weder eine Schwelle noch einen Gesamt-Betrag. Die Beträge wandern
laut Auflösungs-Trigger mit dem Tag.

| Stand | sieben Zeiger gesamt | davon `modul-11` + `modul-13` | Aufschlag |
|---|---|---|---|
| `v6.7.2`, genannt und angenommen | 110410 | 23331 | 26,8 % |
| `v6.8.0` | 113031 | 25622 | 29,3 % |
| `v6.9.0` | 119270 | 25622 | 27,4 % |

Die Kommandos stehen in `MR-056` Setzung 4. Die Zeile `v6.7.2` ist der Wortlaut des Eintrags an
seinem Anlage-Commit (`git show ec966153:harness/conventions/MR-056-…`), die Zeile `v6.8.0` der
Wortlaut vor dem Adress-Nachzug `f599169f`. Der Zuwachs dieses Sprungs liegt nicht im Aufschlag,
sondern in zwei Modulen der Grundauswahl von `MR-035`:

```sh
for b in modul-05-planning-harness.md modul-06-roadmap.md; do
  echo "$b $(git show "$O:$A/$b" | wc -c) $(wc -c < "$N/$b")"; done
# modul-05-planning-harness.md 18684 24736    (+6052)
# modul-06-roadmap.md 34970 35157             (+187)
```

**Urteil: Die Annahme deckt den heutigen Betrag nicht eindeutig.**

1. Sie ist an den Aufschlag gebunden, und dessen Betrag steht nicht mehr auf dem genannten Wert:
   23331 → 25622 Zeichen, mit dem Sprung auf `v6.8.0`.
2. Der Zuwachs dieses Sprungs (113031 → 119270, +6239) liegt auf `modul-05` und `modul-06`.
   `MR-035` Setzung 1 misst deren Anteil nur (18,1 % am Stand `v5.12.0`); dass ein Betrag
   angenommen wurde, sagt dort keine Stelle.

**Das ist eine offene Frage an den Auftraggeber, keine Entscheidung dieses Durchgangs:** Deckt die
Annahme aus `MR-056` Setzung 4 einen Auto-Kontext von 119270 statt 110410 Zeichen?

## 4. Stichprobe gegen den Bestand (`MR-000`)

**Abschnitt:** Baseline-Regelwerk `v6.9.0` · `modul-07-carveouts.md` §Ziel-Form: Carveout.

- **Ohne Delta:** `diff <(git show "$O:$A/modul-07-carveouts.md" | sed -n '/^### Ziel-Form: Carveout/,/^### Werkzeug-Wahl/p') <(sed -n '/^### Ziel-Form: Carveout/,/^### Werkzeug-Wahl/p' "$N/modul-07-carveouts.md") | wc -l` → 0.
- **Rotation:** Die vorige Stichprobe prüfte `modul-14-docker-harness.md` §Multi-Stage-Build (`slice-084` §7).

| Regel | Steht im Bestand oder als deklarierte Abweichung? |
|---|---|
| Sechs Pflicht-Header-Felder (Status · Datum angelegt · Letzte Prüfung · betroffenes Gate · Geltungsbereich · Folge-Slice) | ja: alle sechs in `CO-001` bis `CO-006` |
| Auflösungs-Trigger als beobachtbare, messbare Bedingung | ja: `CO-001` führt seinen Trigger als Bestands-Frage, die ein anderer ohne Rückfrage beurteilt |
| **Die Gate-Konfiguration nennt die `CO-<NNN>` im Gate-Output** | **nein, zweimal:** `git grep -n 'CO-001' -- Makefile '*.mk' .d-check.yml` → leer, Exit 1; das `shell-lint`-Rezept verengt die Messung, ohne `CO-001` zu nennen. Keine deklarierte Abweichung: `grep -rl 'CO-001' harness/conventions/` → leer |
| Auflösung ist ein `git mv` nach `done/` | ja: vier aufgelöste Carveouts liegen im `done/`-Verzeichnis der Carveout-Ablage |
| Auflösung setzt die Bindung-Spalte in `harness/README.md` §Sensors zurück | ja: keine Zeile der Tabelle trägt eine `CO`-Kennung (Zusatzklassen-Messung im Konventionsspeicher: 0) |

**Ergebnis: 4 von 5 Regeln im Bestand, ein Fund.**

- **Adresse des Funds:** `slice-113`. Sein §1 führt den fehlenden Verweis `CO-001` im Kommentar
  des `shell-lint`-Rezepts ausdrücklich (`git grep -n 'CO-001' -- 'docs/plan/planning/**/slice-113-*.md'`).
- **Weg:** Ein einzelner Fund geht den Weg jeder Diskrepanz: Übernahme im nächsten Slice
  (Prozedur, Punkt *„Eine Stichprobe gegen den Bestand"*). Die Übernahme ist eine Änderung am
  `Makefile` und liegt nicht in diesem Durchgang.

**Urteil über `MR-000`: Die Aussage hält.** Nach der Prozedur treffen erst **mehrere** Funde die
Aussage *„keine inhaltlichen Adaptionen ggü. Baseline-Default"*. Ein einzelner trifft die einzelne
Regel und hat mit `slice-113` seine Adresse.

**Nebenbefund außerhalb des Abschnitts, nicht gezählt:** `modul-13-quality-gates.md` §Hard Rule
(Doku-Disziplin) verlangt für einen aktiven Carveout die `CO`-Kennung in der Bindung-Spalte. Die
`shell-lint`-Zeile trägt sie nicht. Der Nebenbefund hängt an demselben Carveout: Löst `slice-113`
`CO-001` auf, entfällt er.

## 5. Umgesetzt

- **`0b7bcd2e`:**
  - `MR-060` neu, per `cp` aus der vendored Vorlage. Ausgelöst durch Baseline-Stand `v6.9.0`;
    löst `MR-039` Setzung 1 und 2 auf; Setzung 3 bleibt.
  - `MR-039` bekommt die zweite Kopf-Marke; die vorhandene bleibt wörtlich stehen (`MR-032`
    Setzung 1).
  - Im Index des Konventionsspeichers kommt die Zeile für `MR-060` hinzu, und die zwei Sätze des
    Adaptions-Blocks zum Nachtragen zeigen auf `MR-060`.
- **Keine Werkzeug-Änderung:** Kein Sensor setzt `MR-039` Setzung 1 durch.
- **Die Buchung des Stands** ist nicht Teil dieses Durchgangs; sie steht in `31ba5903` und `44f5c034`.

**Offen für die Closure:**
- **(a)** die Frage an den Auftraggeber aus §3;
- **(b)** `slice-212` in `open/` nennt `MR-039` als erlaubte Form, einen Eintrag fortzuschreiben
  (Setzung 1). Das ist gegen `MR-060` veraltet;
- **(c)** das zweite Auftreten des rotierenden Prüf-Gegenstands ohne Ort, Register-Kennung
  `rotierender-pruef-gegenstand-ohne-ort`. Den Vorgänger dieser Stichprobe fand nur eine Suche
  im Rumpf von `slice-084`.
