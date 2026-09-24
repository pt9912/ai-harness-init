# Review-Report: ADR-0064 (Tap-Nachzug), Runde 2 — 2026-09-24

**Review-Art:** Design — Nachrunde eines Design-Reviews einer `Proposed`-ADR gegen ihre Bezüge
(`ADR-0058` Festlegung 4 und 3, `ADR-0059`, `ADR-0063`, `ADR-0003`, `ADR-0040`, `MR-014` Setzung 1,
`MR-069`), gegen den Baum und gegen die Hard Rules (Modul 10 §Drei Review-Arten). Das ist die
erneute Runde der prüfenden Rolle, die `ADR-0040` Festlegung 2 nach einem blockierenden Befund als
Beleg des Acceptance-Triggers verlangt. Runde 1: `docs/reviews/2026-09-24-adr-0064-tap-nachzug-runde-1.md`
(Commit `04a1e49a`), unangetastet.

**Gegenstand:** Commit `16b93a88` (Rolle Architect: ADR-0064 `Proposed` korrigiert; auf `origin/main`
— `git log origin/main..HEAD` nennt nur den unbeteiligten Implementer-Commit `58270927`) —
`docs/plan/adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md` und die
Zeile 0064 in `docs/plan/adr/README.md` (2 Dateien, +257/−129). Der Slice-Plan ist nur Plan-Bezug.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13)
**Modell:** Sonnet 5 · **Datum:** 2026-09-24

**Eingangs-Kontext:** ADR-0064 vollständig; Runde-1-Report; `ADR-0058` (Festlegungen 1–5), `ADR-0059`
(Festlegungen 1 und 2), `ADR-0040` (Festlegungen 1 und 2), `ADR-0063` (Status); `MR-014` (Setzung 1
samt Nachtrag), `MR-069`; `LH-QA-03`; `AGENTS.md` §3; `.github/workflows/release.yml`;
`harness/tools/traeger-fetch.sh`; `harness/tools/mutate.sh` (`failure_form`) und
`test/mutations/01-baseline-pin-kopplung.sh` (Fall-Form); ADR-Vorlage der Baseline `v6.9.0`.

**Eigene Sensor-Läufe (nur lesend; kein Schreibzugriff auf ein Repo, kein `make mutate`):**

- `grep -nE 'contents: (read|write)|GH_TOKEN|secrets\.' .github/workflows/release.yml` →
  `47: contents: read`, `133: contents: write`, `157: GH_TOKEN: ${{ github.token }}`; `grep -cE 'secrets\.'` → `0`.
  Die Zeilenangabe der ADR (47/133/157) stimmt.
- `grep -ciwE 'tap|homebrew' spec/lastenheft.md` → `0`.
- `gh api repos/pt9912/homebrew-ai-harness-init --jq '.default_branch,.private'` → `main`, `false`;
  `…/branches/main --jq .protected` → `false`; `…/releases/latest --jq .tag_name` → `v0.2.3`.
- Asset-Gegenprobe: `cmp v022.rb tap.rb` → *„verschieden: Byte 726, Zeile 11"*, Exit 1; `cmp v023.rb tap.rb` →
  Exit 0; `version "0.2.3"` steht in Zeile 11 des Tap-Kopfs, genau einmal am Zeilenanfang.
- Transport-Bild (Digest aus `harness/tools/traeger-fetch.sh`, `docker run --rm --pull=never`, lesend,
  ohne Netz): Sondierung der ADR bestätigt (`curl`, `base64 -w`, `cmp`, `sha256sum`, `sed`, `awk`, `od`
  vorhanden; `jq`, `bash`, `git`, `gh` fehlen). Zusätzlich: `curl 8.16.0`; `sh` ist BusyBox-`ash`;
  `printf`, `echo`, `trap`, `test` sind Builtins; `sha1sum`, `stat`, `mktemp` vorhanden; Nutzer
  `curl_user`, `umask 0022`; `/tmp` schreibbar. **`-H @Datei` funktioniert real:** gegen einen
  lokalen Listener im Container gefahren, kam der `Authorization: Bearer …`-Header aus einer per
  `umask 077` + `printf` angelegten Datei (Modus `600`) an; das Token stand in keiner Argumentliste.
- Anonymer Lese-Pfad: `curl -sI -H 'Accept: application/vnd.github.raw'` gegen die Contents-API des Tap
  → `cache-control: public, max-age=60, s-maxage=60`, `x-ratelimit-limit: 60`.
- Arithmetik im Bild-`sh` (für einen Kern-Vergleich „numerisch je Feld"): `$(( e + 0 ))` mit leerem `e` →
  `0`, rc 0; `$((08+1))` → *„arithmetic syntax error"*, rc 2; `$(( 99999999999999999999 + 0 ))` →
  `7766279631452241919`.
- `make` (GNU Make 4.3): `TAG='v1$(HOME)x' make` gibt `$TAG` unverändert an das Rezept; `make TAG='v1$(HOME)y'`
  gibt `v1/home/dby` an das Rezept — die Kommandozeilen-Variable wird beim Export **von make** expandiert.
- `grep -ln '^## Grenze' docs/plan/adr/*.md` → nur ADR-0064; `grep -rln 'curlimages/curl@sha256' .` →
  `harness/tools/traeger-fetch.sh`, `internal/emit/templates/enforce/traeger-fetch.sh`, `test/traeger-fetch.bats`
  und ein Verifikations-Bericht.
- `make gates` — siehe Ende des Reports.

---

## Runde-1-Befunde

| Befund | Stand | Fundstelle in der ADR und Beleg |
|---|---|---|
| F-1 (Bezug ADR-0059 falsch zugeschrieben) | **behoben** | Bezug nennt Festlegung 1 (`SHA256SUMS` reist als Asset) und Festlegung 2 wörtlich; beide stehen so in `0059` (`**1. `SHA256SUMS` reist als Release-Asset.**`, `**2. Das Binary trägt keinen Wert, der vom Bau-Ergebnis abhängt.**`); die Formel-als-Asset-Aussage führt jetzt den Release-Workflow als Quelle. Rest: N-4 |
| F-2 (YAML-Check „Secret gesetzt?") | **behoben** | Festlegung 1 (Job „ohne eigene Logik in der YAML, insbesondere ohne eigenen Nachweis"), Festlegung 3 Schritt b, Festlegung 4 letzter Punkt; Zahn: Fitness-Zeile „Fehlt-Nachweis" |
| F-3 (Vorwärts-Schutz gegen `releases/latest`) | **Substanz behoben, Zähne teilweise offen** | Festlegung 3 Schritt d: Kern numerisch je Feld gegen die `version`-Zeile am Tap-Kopf, kleiner → Exit 2 ohne Schreiben; Fälle `0.2.3`/`v0.1.2` und `0.2.9`/`v0.2.10`. Der Maßstab (Tap-Stand) ist der richtige und fail-closed **bei kleinerem Tag**. Die fail-closed-Enden — nicht lesbare `version`-Zeile, Gleichstand, Tag-Form ohne Breiten-/Nullregel — haben keinen Zahn: **N-1** |
| F-4 (Vorab-Regel nur in `sync`) | **behoben** | Ablauf-Tabelle Festlegung 1 (Schritt c in beiden Modi), Festlegung 3 Schritt c, Fitness-Zeile „Vorab-Tag … in beiden Modi, ohne Netz-Zugriff"; die Tag-Liste (`v1.0.0-RC`, `v1.0.0-rc.1+x`, `v1.0.0+build-1`) trägt die Metadatum-zuerst-Regel |
| F-5 (Vertrauensgrenze zu eng) | **behoben** | Festlegung 4 (Umgebungs-Secret an `v*`-Tags, Reichweite von *Contents: write* ausgeschrieben), Alternative G, §Grenze (*„Das Umgebungs-Secret schließt Läufe an Branch-Fassungen aus, nicht Läufe an einem Tag"*; die Umgebung selbst ist als ungelesene Einstellung benannt), Re-Evaluierungs-Trigger 5. Geprüft ohne neuen Befund, s. Negativbefunde |
| F-6 (Tag als untrusted Eingabe) | **behoben, ein Zahn ungenau** | Festlegung 1 (Step-`env`, kein `${{ }}` im `run:`, Formprüfung auf dem Host vor `docker`); Fitness-Zeile „Tag-Eingabe". Der Test-Tag ist kein gültiger Git-Ref und der Fall führt nicht über `make`: **N-2** |
| F-7 (Token als Argument) | **behoben** | Festlegung 4 (`-e TAP_TOKEN` ohne Wert; Header per Shell-Builtin in Datei Modus 0600, `curl -H @Datei`); `curl 8.16.0` im gepinnten Bild trägt `-H @Datei` (gemessen, Header kam an). Zahn: Fitness-Zeile „Token nie in einer Kommandozeile" mit `curl`-Stub |
| F-8 (Zusagen ohne Zahn) | **behoben bis auf die Enden des Vorwärts-Schutzes** | Fitness-Tabelle je Zusage mit Fall und Schwächung: Nachkontrolle, Optimistik, geschriebene Bytes, Pin, Fehlt-Nachweis, Job-Form je Zeile inkl. Step-`env`; sechs benannte `make mutate`-Zähne (Fall-Form erfüllbar, s. Schwerpunkt 3). Rest: N-1 |
| F-9 (Host/Bild-Aufteilung) | **behoben** | Festlegung 5: Host `bash` (Eingaben, Tag-Form, Pin, Schritt b, Vorab-Regel, `docker run`), Bild POSIX-`sh`-Nutzlast; Maßstab für ein eigenes Bild ist die `command -v`-Sonde. `bash` als Host-Voraussetzung ist durch `traeger-fetch.sh` (`#!/usr/bin/env bash`) und die `bash harness/tools/…`-Rezepte des `Makefile` gedeckt |
| F-10 (Zeilen 47/133/157) | **behoben** | Messung gegen `release.yml` nachgefahren, stimmt |
| F-11 (Vorfall-Bezeichnung) | **behoben** | „Gegenstück" des Vorfalls, umgekehrte Richtung, Vorfall hermetisch nachgestellt |
| F-12 (`exempt-targets`) | **behoben** | Folgepflicht 1 nennt den Eintrag in `targets.exempt-targets` (exakt) für beide Ziele |
| F-13 (`LH-QA-04`) | **behoben** | Eigener Absatz „Kein Bezug"; `grep -ciwE 'tap|homebrew' spec/lastenheft.md` → 0 nachgemessen; Folgepflicht 6 legt die Entscheidung an den Auftraggeber |
| F-14 (Ablauf zweimal) | **behoben** | Ablauf-Tabelle in Festlegung 1; Festlegung 3 folgt ihr; kein Widerspruch gefunden |
| F-15 (Lese-Anmeldung) | **behoben** | Festlegung 2: *„Das Lesen führt das Token mit, wenn es gesetzt ist"*. Rest zum anonymen Pfad: N-3 |
| F-16 (Slice-Anspielungen) | **behoben** | `grep -nEi 'slice\|planning/\|open/\|next/\|in-progress/\|done/'` über die ADR → keine Treffer |

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| N-1 | MEDIUM | Der Vorwärts-Schutz sagt Exit 2 bei nicht lesbarer `version`-Zeile zu (Festlegung 3 Schritt d, Grenze) und lässt Gleichstand weiterlaufen; die Fitness-Tabelle führt dafür keine Zeile, nur `0.2.3`/`v0.1.2` und `0.2.9`/`v0.2.10`. Die Lücke liegt an der einzigen Stelle, an der der Guard offen fällt, ohne dass ein Fall rot wird: liest die Extraktion die Zeile nicht (`sed` liefert leer), ist `$(( e + 0 ))` im Bild-`sh` `0` und rc 0 — das Tap gälte als `0.0.0`, **jeder** Tag ginge durch und das Tap würde überschrieben. Dazu benennt die Tag-Form keine Breiten- und Nullregel: `$((08+1))` bricht im Bild mit Syntaxfehler (rc 2, zufällig richtig), ein 20-stelliges Feld wird zu `7766279631452241919`. Die ADR-eigene Präambel der Fitness Function („Jede Zusage … steht mit dem Gegenbeispiel") ist an dieser Stelle nicht eingelöst. | AGENTS.md §3.6, ADR-0064 Festlegung 3 d | docs/plan/adr/0064-…:239-246, :452 | ja — Fall „Tap-Kopf ohne lesbare `version`-Zeile → 2, kein Schreibaufruf"; Fall „Tag-Kern = Tap-Kern läuft weiter"; Fall Feld mit führender Null | Zusage „nicht lesbar → Exit 2" ohne Zahn; Guard offen fallbar |
| N-2 | LOW | Zwei Ungenauigkeiten an der Tag-Übergabe. (a) Der Fall nennt `v1.0.0$(touch <marker>)`; ein Git-Ref-Name trägt kein Leerzeichen, der Tag ist so nicht anlegbar und trägt die Injektion nicht (`$`, `(`, `)`, `;`, Backtick sind erlaubt, Whitespace nicht). (b) Die Zusage *„das `make`-Rezept … übergibt ihn als Umgebungsvariable"* gilt für den CI-Weg (Step-`env` → `make`, gemessen: `$TAG` bleibt unverändert); beim dokumentierten Aufruf `make tap-check TAG=<tag>` expandiert **make selbst** die Kommandozeilen-Variable beim Export (`v1$(HOME)y` → `v1/home/dby`). Beides ist ohne Sicherheitsfolge (der Tippende ist der Auftraggeber, die Formprüfung fängt das Ergebnis), aber der Fall prüft die Übergabe nicht dort, wo die Zusage gemacht wird. | ADR-0064 Festlegung 1, Fitness-Zeile Tag-Eingabe | docs/plan/adr/0064-…:183-185, :454 | ja — Fall über `make` mit einem ref-gültigen Tag wie `v1.0.0$(id)` | Übergabe-Zusage ohne Zahn an der Übergabestelle |
| N-3 | LOW | Festlegung 2 begründet die Contents-API damit, dass kein zwischengespeicherter Pfad einen alten Stand als grünen zeigt. Der anonyme Lese-Pfad der API trägt `cache-control: public, max-age=60, s-maxage=60` (gemessen). Der `tap-check` der Prozedur (Festlegung 6) läuft unmittelbar nach dem Job und ohne Token, wo der Auftraggeber keines exportiert hat: er kann bis zu 60 s den Stand vor dem Schreiben lesen und meldet dann Exit 1 *„Formel-Unterschied"* für ein Tap, das gleich ist. Die Grenze nennt den Zeitpunkt des Aufrufs, nicht dieses Fenster. | LH-QA-02, ADR-0064 Festlegung 2 und 6 | docs/plan/adr/0064-…:208-212, :319-327 | ja — Kopfzeile der anonymen Antwort | Cache-Prämisse der Kontrolle für den anonymen Pfad nicht tragend |
| N-4 | LOW | Zwei Bezug-Paraphrasen tragen mehr als die Gegenseite. (a) Der Bezug nennt `MR-069` mit *„er bekommt kein Geheimnis"*; `MR-069` sagt das nicht (`grep -niE 'geheimnis\|secret\|token'` über den Eintrag → keine Treffer) — das ist die Setzung dieser ADR, gelesen wie ein Inhalt von `MR-069`. (b) Der Bezug schreibt `LH-QA-03` „git, docker, make" zu; das Lastenheft sagt für die Laufzeit des Tools *„git + docker"* (Anforderung, Zeilen zu `LH-QA-03`), das dritte Wort steht in `ADR-0058` Festlegung 4. Dieselbe Klasse wie F-1, kleiner. | MR-069, LH-QA-03 | docs/plan/adr/0064-…:9-14, :32-35 | ja — `grep` auf die beiden Quellen | Bezug schreibt der Gegenseite eine Aussage zu, die sie nicht führt |
| N-5 | LOW | Die ADR trägt `## Grenze` als eigene oberste Überschrift; die Vorlage kennt sieben `##`-Abschnitte ohne Grenze, und keine andere ADR führt eine solche Ebene (`grep -ln '^## Grenze' docs/plan/adr/*.md` → nur `0064`). Die Pflichtgliederung ist geschlossen; eigener Stoff steht als `###` unter dem passenden Abschnitt. Kein Gate prüft das. | Baseline `modul-04-adrs.md` §Ziel-Form: ADR | docs/plan/adr/0064-…:401 | ja — Überschriften-Vergleich mit der Vorlage | Pflichtgliederung um eine Ebene erweitert |
| N-6 | LOW | Die Nutzlast-Aufgabe „Blob-Stand aus diesen Bytes berechnet" (Festlegung 3 Schritt f) und die Datei mit Modus 0600 brauchen `sha1sum`, `stat`/`mktemp` bzw. `umask`; der *gemessene Bestand* in §Lage und im Maßstab von Festlegung 5 führt sie nicht (das Bild trägt sie: gemessen). Ohne sie im Bestand ist der Maßstab *„nur Programme des gemessenen Bestands"* für genau die Aufgaben nicht prüfbar, die den Schreib-Pfad tragen. Außerdem sagt die ADR nicht, woher das neue Skript den Bild-Digest nimmt; der Pin steht schon an zwei Stellen mit einem Kopplungstest (`traeger-fetch.sh`, emittierter Zwilling, `test/traeger-fetch.bats`) — eine dritte Kopie im Skript hat keinen. | ADR-0058 Festlegung 4, LH-QA-02 | docs/plan/adr/0064-…:113-121, :295-313 | ja — Sonde `command -v sha1sum`; `grep` auf den Digest | Prüfmaßstab und Pin-Quelle der Nutzlast nicht vollständig benannt |
| N-7 | INFO | Drei Randlagen ohne Aussage der ADR, an die Rolle Implementer: (a) *„das Tap bleibt unverändert, und die Meldung sagt das"* gilt für eine **ausdrückliche** Ablehnung; bei Zeitüberschreitung oder Verbindungsabbruch nach dem PUT ist der Ausgang unbekannt, und Exit 2 mit dieser Meldung wäre unwahr (der Wiederholungslauf ist konvergent, Festlegung 3). (b) Ein Tap ohne `Formula/ai-harness-init.rb` fällt unter *„Tap nicht lesbar"* (Exit 2) — der Erstbestand eines neuen Tap ist damit von Hand herzustellen; die Grenze nennt nur die nicht lesbare `version`-Zeile. (c) `-e TAP_TOKEN` hält das Token aus jeder Kommandozeile, nicht aus `docker inspect` und `/proc/<pid>/environ` für Nutzer mit Zugriff auf den Docker-Daemon; die Zusage sagt *„nie in einer Kommandozeile"* und trägt das. | ADR-0064 Festlegung 3, 4 | docs/plan/adr/0064-…:256-257, :283-285, :416-417 | nein | Randlage einer Fehlerklasse nicht benannt |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Vorwärts-Schutz gegen einen **kleineren** Tag | fail-closed: Kern numerisch je Feld gegen die `version`-Zeile, kleiner → Exit 2 ohne Schreiben; `v0.1.2` gegen `0.2.3` und `v0.2.10` gegen `0.2.9` sind die richtigen Gegenproben; der Maßstab (Tap-Stand statt `releases/latest`) trägt die Zusage. Build-Metadatum: Schritt c schneidet es zuerst ab; `v0.2.3-rc.1` gegen Tap `0.2.3` endet vor Schritt d mit Exit 0 (Vorab, benannt). Geprüft, ohne Befund an der Entscheidung (Zahn-Enden: N-1) |
| Umgebungs-Secret, Grenze der Benennung (F-5) | benannt sind: Schreibrecht im Repo genügt für ein `v*`-Tag; der Tag-Lauf führt das Workflow-Skript des Tag-Baums aus; Branch-Fassungen erreichen das Secret nicht; die Umgebung samt Regel ist Einstellung außerhalb des Baums ohne Leser (Grenze) und ihr Beleg ist der erste reale Lauf; Umfang und Dauer des Tokens sind begrenzt, das Ziel nicht; Re-Evaluierungs-Trigger 5 fängt einen nicht gewollten Tag-Lauf. Ein `workflow_dispatch` auf einem Tag-Ref erreicht das Secret nicht, weil der Job die `publish`-Bedingung (`github.event_name == 'push' && startsWith(github.ref, 'refs/tags/')`) trägt. Geprüft, ohne Befund |
| Job `tap` gegen `MR-014` Setzung 1 und `MR-069` | enthält Checkout, `permissions: contents: read`, einen `make`-Schritt; kein Inline-Check; `publish` bleibt ohne Checkout und ohne Secret; `MR-069` wird nicht berührt (der zweite Auflösungs-Trigger dort, ein zweiter Check *im* `publish`-Job, tritt nicht ein). Geprüft, ohne Befund |
| Kollision mit `ADR-0058` Festlegung 3/4 | Transport im digest-gepinnten Bild (dasselbe Bild wie `traeger-fetch`), Plattform-Erkennung entfällt (kein Binary), Netz nur an genau diesem Aufruf, keine Prerequisite-Kette, kein Gate (beide Ziele außerhalb von `gates` und `record-gates`, Zeile `kein Gate` in §Werkzeuge, Eintrag in `exempt-targets` als Folgepflicht). Kein Widerspruch. Geprüft, ohne Befund |
| Kollision mit `ADR-0059`, `ADR-0063`, `ADR-0003`, Festlegung 7 (*„kein `Supersedes`"*) | die Formel-Digests bleiben aus der `SHA256SUMS` des Schnitts; der Nachzug liest die fertige Formel; die Kontrolle vergleicht Bytes, keine Versions-Strings; `ADR-0063` steht auf `Proposed`, die ADR sagt das. Geprüft, ohne Befund |
| Host-Voraussetzung `bash` und `LH-QA-03` | gedeckt: `traeger-fetch.sh` läuft unter `bash`, das `Makefile` ruft `bash harness/tools/…`; die Nutzlast im Bild braucht kein `bash`; kein `gh`/`jq`/`curl`/`base64` auf dem Host. Geprüft, ohne Befund (Paraphrase: N-4) |
| `curl -H @Datei`, Datei-Modus, Aufräumen | im gepinnten Bild vorhanden und wirksam (gemessen); `trap` und `printf` sind Builtins des Bild-`sh`; im Container mit `--rm` entfällt die Datei mit dem Container, in einem hermetischen Lauf auf dem Host sorgt `trap … EXIT` für das Entfernen, und die Fitness-Zeile prüft „Datei fehlt nach dem Lauf". Geprüft, ohne Befund |
| Fitness-Zähne für `make mutate` (Schwerpunkt 3) | die sechs Zähne sind als Fälle formulierbar: `failure_form` führt die Stufe `test-bats` (`not ok [0-9]+`), die Fall-Form (`# files:`, `# expect:`, `sed`-Anker) trägt einen `bats`-Namen als rot färbenden Test; die `sed`-Anker sind nach `MR-071` gegen den dann vorhandenen Quell-Bestand zu messen. Benannt, nicht bewacht, solange das Skript nicht steht — die ADR sagt das nicht als Bewachung aus. Geprüft, ohne Befund |
| Zusage, die am ersten realen Lauf hängt | der Schreib-Pfad am realen Tap und die Umgebung samt Regel sind in der Grenze als nicht test-gedeckt benannt (*„der erste reale stabile Tag-Lauf … ist sein Beleg — benannt, nicht als bewiesen behauptet"*); das Vorab-Tag-Probe sagt ausdrücklich, dass es Gültigkeit und Schreibrecht nicht zeigt. Geprüft, ohne Befund |
| Rot-Beleg am realen Zustand | `v0.2.2`-Asset gegen den Tap-Kopf: Byte 726, Zeile 11 = `version`-Zeile, Exit 1; `v0.2.3`: Exit 0; das Tap steht weiter auf `0.2.3`. Nachgefahren, stimmt |
| Datierte Messungen der ADR | alle fünf am 2026-09-24 nachgemessen und stimmig: kein `secrets.` (0), Zeilen 47/133/157, Tap `main`/öffentlich/ungeschützt, `latest` = `v0.2.3`, `grep -ciwE 'tap\|homebrew' spec/lastenheft.md` → 0, Transport-Bild-Sonde |
| Ablage: Pflichtgliederung (bis auf N-5), Verglichene Alternativen A–G, Re-Evaluierungs-Trigger, Grenze, Accept-Zeile | vorhanden; die Accept-Zeile der Geschichte ist noch nicht geschrieben (Status `Proposed`), der Trigger nennt sie als Kennung, nicht als Pfad-Link (`ADR-0040` Festlegung 1). Geprüft, ohne Befund |
| Ablage: Adress-Regeln (`AGENTS.md` §3.11), Zustandsform (§3.7), Zahlen neben Kommando (`MR-025`) | keine Slice-Kennung; Pfade nur auf ortsfeste Ziele (`release.yml`, `homebrew-formula-fill.sh`, `docs/user/releasing.md`, das Verzeichnis `docs/reviews/`); keine „früher stand hier"-/„nach Review-Befund"-Erzählung (`grep -nEi 'früher\|nach review\|befund f-\|vormals\|zuvor'` → keine Treffer; die Geschichte-Zeile nennt Zustand und Anlass); jede gemessene Zahl steht neben ihrem Kommando; jede `LH-`/`ADR-`/`MR-`-Kennung trägt einen Anker-Link außer dem Klartext in Überschrift, Zitat und `Supersedes`-Satz. Geprüft, ohne Befund |
| ADR-Index-Zeile 0064 | Status `Proposed`, Titel und Bezug spiegeln die Fassung (Umgebungs-Secret, `v*`-Tags); die Korrektur berührt nur diese eine Zeile. Geprüft, ohne Befund |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 (N-1) |
| LOW | 5 (N-2 … N-6) |
| INFO | 1 (N-7) |

**Runde-1-Befunde:** 16 von 16 behoben; F-3 in der Substanz (der Vorwärts-Schutz am Tap-Stand ist
tragend und fail-closed gegen einen kleineren Tag), seine Zähne an den Enden offen (N-1). Kein Runde-1-Befund
ist neu aufgerissen. Neu aus der Korrektur: N-1 bis N-7, davon eines MEDIUM.

**Wiederkehrende Klassen für den Zähler (Slice-Closure §7):** *Zusage ohne benanntes rotes
Gegenbeispiel* (N-1; Runde 1: F-3, F-7, F-8), *Bezug schreibt der Gegenseite eine Aussage zu, die sie
nicht führt* (N-4; Runde 1: F-1, F-13) — beide Klassen treten in dieser ADR in der zweiten Runde
zum zweiten Mal auf, jetzt mit kleinerem Gewicht.

**Verdikt:** annahmefähig. Der Acceptance-Trigger (*„ohne blockierenden Befund an der Substanz der sieben
Festlegungen"*) ist **erfüllt**: kein HIGH, und kein Befund ändert oder widerlegt eine der sieben
Festlegungen; die Bezüge (`ADR-0058`, `ADR-0059`, `MR-014`, `MR-069`) tragen, `LH-QA-03` bleibt mit der
Aufteilung Host/Bild gewahrt. N-1 ist der einzige MEDIUM-Befund und liegt an der **Beleg-Seite** der
Festlegung 3 (eine Fitness-Zeile und eine Zeile Tag-Form-Wortlaut), nicht an ihrer Entscheidung; er
gehört vor die Accept-Zeile oder als bindende Fitness-Vorgabe in die Umsetzung, weil die ADR sich selbst
zusagt, dass jede Zusage ihr Gegenbeispiel trägt. N-2 bis N-6 sind Darstellung und hindern die Annahme
nicht (`ADR-0064` §Acceptance-Trigger). Die Annahme selbst bleibt Entscheidung des Auftraggebers.
