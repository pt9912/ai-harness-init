# Review-Report: ADR-0064 (Tap-Nachzug) — 2026-09-24

**Review-Art:** Design — Design-Review einer `Proposed`-ADR gegen ihre Bezüge (`ADR-0058` Festlegung 4,
`ADR-0059`, `ADR-0003`, `MR-014` Setzung 1, `MR-069`), gegen den Baum und gegen die Hard Rules
(Modul 10 §Drei Review-Arten). Das ist die Reviewer-Runde des Acceptance-Triggers der ADR.

**Gegenstand:** Commit `7507c51f` (Rolle Architect: ADR-0064 `Proposed` samt Index-Zeile, lokal, nicht
gepusht) — `docs/plan/adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md`
und die Zeile 0064 in `docs/plan/adr/README.md`. 2 Dateien, +382/−0. Der Slice-Plan zum Nachzug
(Planner-Artefakt) ist nur Plan-Bezug, nicht Prüfgegenstand.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13)
**Modell:** Sonnet 5 · **Datum:** 2026-09-24

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- ADR-0064 vollständig; `ADR-0058` (Festlegung 4), `ADR-0059`, `ADR-0063` (`Proposed`), `ADR-0003`,
  `ADR-0040`
- `MR-014` (Setzung 1 samt Nachtrag), `MR-069`, `MR-025`
- `LH-QA-02`, `LH-QA-03`, `LH-QA-04`
- `AGENTS.md` §3 (insbesondere §3.6, §3.7, §3.9, §3.11)
- `.github/workflows/release.yml`, `harness/tools/traeger-fetch.sh`, `docs/user/releasing.md`,
  `docs/user/benutzerhandbuch.md` (Weg C), `.d-check.yml` (`targets.exempt-targets`)
- Baseline `v6.9.0` · `templates/docs/plan/adr/NNNN-titel.template.md` (Pflichtgliederung)

**Eigene Sensor-Läufe dieses Laufs (nur lesend, nichts geschrieben):**

- `grep -cE 'secrets\.' .github/workflows/release.yml` → `0`; `grep -nE 'permissions|GH_TOKEN|contents:'`
  → `46:permissions:`, `47:contents: read`, `132:permissions:`, `133:contents: write`, `157:GH_TOKEN`
- `gh api repos/pt9912/homebrew-ai-harness-init --jq '.default_branch,.private'` → `main`, `false`;
  `…/branches/main --jq .protected` → `false`; `…/releases/latest --jq .tag_name` → `v0.2.3`
- Rot-Beleg der ADR nachgefahren (Assets und Tap-Kopf gelesen, kein Schreibzugriff):
  `cmp v022.rb tap.rb` → *„verschieden: Byte 726, Zeile 11"* (Exit 1; Zeile 11 des Assets ist
  `version "0.2.2"`); `cmp v023.rb tap.rb` → Exit 0
- Tap-Bestand: Contents-Wurzel = `Formula`, `README:md`; die letzten Commits nennen `0.2.3` und `0.2.2`
- Transport-Bild (`traeger-fetch.sh`, Digest-Pin, lokal vorhanden) sondiert:
  `curl`, `base64` (mit `-w`), `cmp`, `sha256sum`, `sed`, `awk`, `od` **vorhanden**; `jq`, `git`, `bash`
  **fehlen**; Benutzer `curl_user`
- `make gates` — siehe Ende des Reports

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Der Bezug und Festlegung 7 schreiben `ADR-0059` zu, *„die Formel reist als Release-Asset"* und *„die Formel ist das achte Asset"*. `grep -niE 'formel\|tap\|homebrew\|achte' docs/plan/adr/0059-*.md` liefert 0 Treffer; die ADR trägt nur die `SHA256SUMS` als Asset. Auch das Zitat *„kein Wert im Binary, der eine Funktion des Bau-Ergebnisses ist"* steht dort nicht wörtlich (Festlegung 2 lautet *„Das Binary trägt keinen Wert, der vom Bau-Ergebnis abhängt"*). Die Konsistenz-Prüfung, die der Trigger verlangt, ist gegen eine Aussage geführt, die die Gegenseite nicht trägt. | ADR-0059 | docs/plan/adr/0064-…:21-23, :237-245 | ja — `grep -c` auf die vier Wörter in `0059-*.md` | Bezug schreibt der Gegen-ADR eine Aussage zu, die sie nicht führt |
| F-2 | MEDIUM | Festlegung 4 schreibt als *ersten Schritt des Jobs* einen Nachweis vor, dass `TAP_TOKEN` gesetzt ist, mit eigener Meldung — das ist ein Check in der Workflow-YAML, in einem Job, der auscheckt. `MR-014` Setzung 1 (*„ein Check wird nie in der Workflow-YAML definiert"*) gilt für jeden auscheckenden Job; `MR-069` nimmt nur den Job ohne Checkout aus. Festlegung 1 sagt selbst *„ohne eigene Logik in der YAML"*, und Exit 2 (*„Anmeldung fehlt"*) deckt den Fall im Skript bereits ab. | MR-014, MR-069, ADR-0064 F1/F4 | docs/plan/adr/0064-…:140-143, :209-212 | nein — `actionlint` und `shell-lint` prüfen das nicht; nur `bats` über die Job-Form könnte es | Inline-Prüfung in auscheckendem Job widerspricht der eigenen Regelform |
| F-3 | MEDIUM | Der Vorwärts-Schutz (Festlegung 3 Schritt 2) hält den Tag gegen `releases/latest`. Das ist das nach Erstellung jüngste stabile Release, nicht die höchste SemVer-Fassung: ein später veröffentlichter stabiler Tag einer älteren Linie (Nachlieferung `v0.1.2` nach `v0.2.3`) wäre `latest`, und der Nachzug stellte das Tap auf die ältere Formel zurück — genau das, was die Festlegung ausschließen will. Der `bats`-Fall injiziert `latest` und kann diese Lage nicht zeigen. | ADR-0064 F3, AGENTS.md §3.6 | docs/plan/adr/0064-…:177-179, :335 | nein — ohne den Fall (zwei stabile Tags, älterer Nachlauf) rot zu sehen | Zusage „nur vorwärts" ohne das Gegenbeispiel, das sie bricht |
| F-4 | MEDIUM | Die Vorab-Regel steht nur im Modus `sync`; `check` kennt sie nicht. Festlegung 6 macht die Meldung des Schnitts von `make tap-check TAG=<tag>` mit Exit 0 abhängig — bei einem Vorab-Tag (`release.yml` führt ihn ausdrücklich als Probe der ganzen Kette) bleibt das Tap bewusst stehen, `check` endet damit auf Exit 1, und die Prozedur kann nicht grün werden. Der Vertrag 0/1/2 sagt für diese Lage nichts. | ADR-0064 F2/F3/F6 | docs/plan/adr/0064-…:160-169, :173-178, :225-232 | ja — ein Fall `check` mit Vorab-Tag | Exit-Vertrag deckt eine benannte Nicht-Gegenstands-Lage nicht |
| F-5 | MEDIUM | Die Vertrauensgrenze ist zu eng benannt. (a) *„nur in diesem Job"* ist bei einem Repository-Secret Konvention, keine Durchsetzung: jeder Workflow einer beliebigen Branch-Fassung mit Schreibrecht kann `secrets.TAP_TOKEN` lesen; das Umgebungs-Secret mit Tag-/Branch-Bindung wird weder erwogen noch verworfen. (b) *„öffnet das Schreiben einer Datei im Tap"* — `Contents: Read and write` öffnet jede Datei und jeden Ref des Tap, nicht eine. (c) Die Grenze nennt Tag-Push und Workflow-Änderung am Tag, nicht die Branch-Fassung. Der Schaden (Verteilweg von `brew`) ist benannt, seine Reichweite nicht vollständig. | ADR-0064 F4, §Grenze | docs/plan/adr/0064-…:190-208, :325-328 | nein — Repo-Einstellung außerhalb des Baums | Zugangs-Geheimnis: benannte Grenze unvollständig |
| F-6 | MEDIUM | Der Tag ist untrusted Eingabe, und die ADR nennt weder seine Übergabe noch eine Prüfung. Git-Ref-Namen erlauben `$`, `(`, `)`, `;`, Backtick; ein `run: make tap-nachzug TAG=${{ github.ref_name }}` liefe mit `TAP_TOKEN` im Step-`env` — der Skript-Injektion sind die Ausdrücke im Skript-Text ausgesetzt (die vorhandenen Steps übergeben den Tag als `${GITHUB_REF_NAME}` aus dem `env`). Im Skript geht der Tag in Schnittstellen-URL und Commit-Message; *„Aufruf falsch"* ist als Exit 2 benannt, eine Form-Prüfung des Tags nicht. | ADR-0064 F1/F4 | docs/plan/adr/0064-…:140-143, :166 | ja — ein Fall mit einem Tag wie `v1$(…)`; `actionlint` fängt Ausdrücke im `run`-Text nur teilweise | Untrusted Eingabe im Job mit Geheimnis ohne benannte Übergabe- und Formregel |
| F-7 | MEDIUM | Festlegung 4 sagt, das Token werde *„nie als Argument übergeben"*. Der Transport im Bild ist `curl`; ein Bearer-Header als `-H`-Argument steht in der Prozess-Kommandozeile im Container und — für andere Nutzer eines gemeinsamen Hosts sichtbar — in der Prozessliste des Hosts. Die ADR sagt nicht, wie das Token an `curl` kommt; der `bats`-Fall der Job-Form prüft es nicht. Ein Test, der die Nicht-Ausgabe (`set -x`, Log) prüft, steht nicht in der Fitness Function. | ADR-0064 F4 | docs/plan/adr/0064-…:205-208, :332-339 | ja — Fall, der das Skript mit gesetztem Token unter `sh -x`/mit `curl`-Stub fährt und die Argumentliste liest | Zusage „nie als Argument" ohne Zahn |
| F-8 | MEDIUM | Die Fitness Function trägt Zähne für Vergleich, Idempotenz, Vorwärts-Schutz, Vorab und Job-Form (mit benannter Schwächung), nicht aber für andere Zusagen der Festlegungen: die **Nachkontrolle** nach dem Schreiben (Schritt 5, Exit 1), den **optimistischen Konflikt** (*„lässt den Schreibvorgang scheitern, statt ihn zu überschreiben"*; Exit 2, Tap unverändert), **die geschriebenen Bytes gleich dem Asset** (Base64-Kodierung, End-Newline), die **Pin-Prüfung** (Exit 2 bei nicht gepinntem Bild) und den **Fehlt-Nachweis**. Die Job-Form bindet `TAP_TOKEN` an *„keinen Workflow-`env`"*, nicht aber an *Step-`env` statt Job-`env`*, `persist-credentials: false` und `permissions: contents: read` des Jobs — Zusagen aus Festlegung 4, die keine Mutation rot färbt. | AGENTS.md §3.6, ADR-0064 F3/F4/F5 | docs/plan/adr/0064-…:182-188, :203-204, :218-219, :332-339 | ja — `bats`-Fälle plus `make mutate`-Fälle | Zusage ohne benanntes rotes Gegenbeispiel |
| F-9 | MEDIUM | Festlegung 5 sagt *„Der Host braucht git, docker, make, sonst nichts"* und lässt offen, welche Schritte im Bild und welche im Host-Skript laufen; die Belegpflicht (*„die Wahl belegt der Implementierer"*) nennt keinen Maßstab. Gemessen: das Bild trägt `curl`, `base64 -w`, `cmp`, `sha256sum`, `sed`, `awk`, aber weder `jq` noch `bash` — Schnittstellen-Antworten (`sha`, `tag_name`) müssten mit `sed`/`awk` gelesen und die Nutzlast POSIX-`sh` sein; welche Werkzeuge außerhalb des Bilds auf dem Host zulässig sind (`gh`, `jq`, `base64`), sagt die ADR nicht. `LH-QA-03` bleibt so unentschieden. | LH-QA-03, AGENTS.md §3.9, ADR-0058 F4 | docs/plan/adr/0064-…:214-223 | ja — Sonde des Bilds; `make full-smoke`-artige Prüfung der Host-Abhängigkeiten | Docker-only-Anspruch ohne Aufteilung Host/Bild |
| F-10 | LOW | Die Messung nennt `:46 (contents: read), :132 (contents: write)`; das sind die `permissions:`-Zeilen (`46`, `132`), die Werte stehen auf `47` und `133`. Zeilennummern sind keine Erwartungswerte, die Zuordnung Zeile → Aussage ist aber um eins verschoben. | MR-025 | docs/plan/adr/0064-…:79 | ja — das Kommando der Messung | Messung: Zeilenzuordnung ungenau |
| F-11 | LOW | Der Rot-Beleg beschreibt *„Asset v0.2.2 gegen Tap-Kopf"* als *„der Vorfall-Zustand"*. Der Vorfall war das Umgekehrte (Tap älter als Asset). Die Byte-Klasse ist dieselbe, der Zustand ist es nicht; der Beleg trägt den Nachweis, dass `check` einen Unterschied als Exit 1 meldet, nicht den Vorfall. | AGENTS.md §3.6 | docs/plan/adr/0064-…:338 | nein | Beleg nennt sich Vorfall-Zustand, ist dessen Spiegel |
| F-12 | LOW | Folgepflicht 1 nennt zwei `README`-Zeilen, *„das `targets`-Modul hält beide Richtungen"*. `targets.exempt-targets` in `.d-check.yml` ist **exakt** (kein Glob) und führt die Werkzeuge; die zwei neuen Ziele sind dort einzutragen, sonst färbt das Doku-Gate im ersten Implementer-Lauf rot. Die Folgepflicht nennt den Eintrag nicht. | AGENTS.md §3.1 | docs/plan/adr/0064-…:275-278 | ja — `make docs-check` | Folgepflicht unvollständig gegenüber der Gate-Konfiguration |
| F-13 | LOW | `LH-QA-04` steht im Bezug als Träger (*„die Formel reist als achtes Asset"*). `grep -niE 'tap\|homebrew' spec/lastenheft.md` liefert außerhalb der Änderungshistorie keinen Treffer; die Matrix nennt Linux/macOS/Windows, das Tap trägt Windows nicht. Die Repo-Praxis (`release.yml`, `releasing.md`) führt denselben Bezug; er löst gegen den Vertrag nicht auf. | LH-QA-04 | docs/plan/adr/0064-…:10-12 | nein | Bezug löst gegen das Lastenheft nicht auf |
| F-14 | LOW | Festlegung 1 beschreibt `tap-nachzug` als *„führt `check`, schreibt bei Abweichung nach"*; Festlegung 3 stellt Vorab-Regel und Vorwärts-Schutz **vor** `check`. Die Reihenfolge im Text der beiden Festlegungen ist nicht dieselbe. | ADR-0064 F1/F3 | docs/plan/adr/0064-…:137-138, :171-185 | nein | Zwei Fassungen desselben Ablaufs im selben Text |
| F-15 | INFO | Die Job-Vorbedingung `TAP_TOKEN` steht außerhalb des Repos (Handlung des Auftraggebers, Ablaufdatum). Gelesene Anonym-Zugriffe der Kontrolle (`releases/latest`, Assets, Contents-API) laufen gegen das Rate-Limit ohne Anmeldung; auf einem gemeinsam genutzten Runner ist Exit 2 die richtige Klasse, aber die ADR sagt nicht, ob der Lese-Pfad im Job das Token mitführt. An die Rolle Implementer. | LH-QA-02 | docs/plan/adr/0064-…:135-137 | nein | Lese-Anmeldung ungeklärt |
| F-16 | INFO | Die ADR nennt *„den Job-Slice"* und *„den Slice der Prozedur"* (Zeilen 295, 322) und legt damit einen Schnitt nahe, den der Slice-Plan (ein Slice, drei Liefer-Punkte) nicht führt; die Folgepflichten 1–5 zusammen sind mehr als drei Liefer-Punkte. Größen- und Schnitt-Frage ist Planner-Arbeit. An die Rolle Planner. | Modul 5 §Ziel-Form: Slice | docs/plan/adr/0064-…:295, :322 | nein | ADR schneidet Slices, die der Planner schneidet |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Datierte Messungen (0 × `secrets.`, Tap öffentlich/ungeschützt/`main`, `releases/latest` = `v0.2.3`) | am 2026-09-24 nachgemessen, stimmen; Zeilenzuordnung siehe F-10 |
| Rot-Beleg `v0.2.2`-Asset gegen Tap-Kopf (Exit 1, Byte 726, Zeile 11 = `version`-Zeile) und `v0.2.3` byte-gleich | nachgefahren, stimmen; Vorfall-Bezeichnung siehe F-11 |
| Vorab-Regel gegen `release.yml` (`case "${tag%%+*}" in *-*)`, Metadatum zuerst abgeschnitten) | Beschreibung stimmt mit dem `publish`-Job überein, geprüft, ohne Befund |
| Job-Form: `needs: publish`, gleiche Bedingung wie `publish`, Checkout, `persist-credentials: false`, `permissions: contents: read` | konsistent mit `MR-069` (`publish` bleibt ohne Checkout und ohne Geheimnis), geprüft, ohne Befund; Fork-PR: `release.yml` triggert nur auf `push` von Tags und `workflow_dispatch`, ein Fork-Lauf erreicht kein Geheimnis — geprüft, ohne Befund |
| Idempotenz und Exit-Klassen 0/1/2 (Lesefehler nie 0/1) | Vertrag und Schwächungs-Formulierung tragen, geprüft, ohne Befund (Lücken siehe F-3, F-4, F-8) |
| Transport im digest-gepinnten Bild, Pin-Prüfung, Netz an genau diesem Aufruf, `docker run -e TAP_TOKEN` ohne Wert | dieselbe Bauart wie `traeger-fetch.sh`; Bild trägt `curl`/`base64`/`cmp`/`sha256sum` (Sonde) — Wiederverwendung ist plausibel, nicht widerlegt; Lücke siehe F-9 |
| Pflichtgliederung nach Vorlage (`Status`, `Datum`, `Autor`, `Bezug`, `Schärft`, `Regeln`, Kontext, Entscheidung, Verglichene Alternativen, Konsequenzen, Fitness Function, Re-Evaluierungs-Trigger, Geschichte) | vollständig, geprüft, ohne Befund |
| Verglichene Alternativen A–F, Re-Evaluierungs-Trigger, Grenze | vorhanden, je Option Pro/Contra; die Grenze benennt Installierbarkeit, Herkunft, Nicht-Test des Schreibpfads — geprüft, ohne Befund (Reichweite des Geheimnisses: F-5) |
| Adress-Regeln: keine Slice-Kennung, keine Pfad-Adresse auf wandernde Artefakte (`grep -nE 'slice-[a-z0-9]\|planning/\|open/\|next/\|in-progress/\|done/'` → 0), Accept-Zeile nennt den Beleg als Kennung | `AGENTS.md` §3.11 gehalten, geprüft, ohne Befund |
| `AGENTS.md` §3.7 (Zustandsform; Anlass steht im Kontext, Geschichte hat eine Zeile) und `MR-025` (Zahlen neben Kommando) | geprüft, ohne Befund außer F-10 |
| Widerspruch zu `ADR-0058`/`ADR-0063`, Festlegung 7 (*„kein `Supersedes`"*), `LH-QA-02`/`LH-QA-03` | kein Widerspruch: der Nachzug berührt Träger-Pin, `traeger-fetch` und Binary nicht (Attribution zu `ADR-0059`: F-1; Host-Abhängigkeiten: F-9) |
| Index-Zeile 0064 in `docs/plan/adr/README.md` | Status `Proposed`, Titel/Bezug spiegeln die ADR, Format wie Zeile 0063, geprüft, ohne Befund |
| Host-Abhängigkeit von `make tap-nachzug`/`tap-check`: `gh` | die ADR fordert `gh` nicht; die Messungen der ADR nutzen `gh` als Architect-Werkzeug, nicht als Werkzeug-Abhängigkeit — geprüft, ohne Befund |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 9 (F-1 … F-9) |
| LOW | 5 (F-10 … F-14) |
| INFO | 2 (F-15, F-16) |

**Wiederkehrende Klassen für den Zähler (Slice-Closure §7):** *Zusage ohne benanntes rotes
Gegenbeispiel* (F-3, F-7, F-8), *Bezug schreibt der Gegenseite eine Aussage zu, die sie nicht führt*
(F-1, F-13).

**Verdikt (Substanz der sieben Festlegungen):** kein HIGH, aber neun MEDIUM-Befunde an der Substanz
(F-1 bis F-9: Bezug, Regelform, Vorwärts-Schutz, Vorab-Lücke im Vertrag, Vertrauensgrenze, Tag als
Eingabe, Argument-Form des Tokens, fehlende Zähne, Host/Bild-Aufteilung). Der Acceptance-Trigger
(*„ohne blockierenden Befund an der Substanz"*) ist damit **nicht** erfüllt: **annahmefähig nach
Korrektur** im `Proposed`-Fenster und einer Nachrunde der prüfenden Rolle. F-10 bis F-14 sind
Darstellung und hindern die Annahme nicht. Die Annahme selbst bleibt Entscheidung des Auftraggebers.
