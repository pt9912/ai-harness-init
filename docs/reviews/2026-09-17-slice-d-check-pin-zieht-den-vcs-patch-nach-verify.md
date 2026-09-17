# Verifikation `slice-d-check-pin-zieht-den-vcs-patch-nach`: DoD 1 bis 3 erfüllt, vor der Closure eine Nacharbeit und eine Architect-Entscheidung

**Rolle:** Verifier · **Datum:** 2026-09-17 · **Geprüfter Stand:** `78cf6680` (= `HEAD` vor diesem
Bericht). Geprüft ist die Kette `e4c6cb0b..78cf6680`
(`git log --oneline e4c6cb0b..78cf6680 | wc -l` → `10`).
**Verifikations-Art:** DoD- und ADR-Konformität gegen den tatsächlichen Baum
(`v6.9.0` · `regelwerk/modul-11-verification.md`). Das ist kein Review.

**Eingang:**

- der Slice-Plan `slice-d-check-pin-zieht-den-vcs-patch-nach` §1 bis §8, Stand im Pfad
  `in-progress/`;
- die Umsetzung: Implementer-Commits `ebb76b3d`, `8aac6d30`, `4db3fcfb`, `1ba2e474`;
  Architect-Commits `49995a05`, `af7a7e9c`, `e72dd3a2`, `78cf6680` (`MR-064`, Kopf-Marke an
  `MR-061`, Index und §Baseline);
- beide Review-Reports vom 2026-09-17: Runde 1 mit 3 MEDIUM und 2 LOW, Runde 2 „bereit“ mit N-1
  (LOW). Ihre Messungen sind gelesen und **nicht** wiederholt: Registry-Digest, `numstat` am
  d-check-Klon über den acht aktiven Regeldateien, Quell-Lesung zum VCS-Port, Gegenmessung
  Stufe 2 (57/57), `vcs`-Abbruchfall mit Werkzeug-Exit, Rot der Namensprüfung, `xyz-*`-Stichprobe;
- `ADR-0042` §Re-Evaluierungs-Trigger 2;
- Fremdquelle, nur lesend: der lokale Klon des d-check-Repos.

---

## 1. Ergebnis je DoD-Punkt

| DoD-Punkt | Status | Beleg |
|---|---|---|
| **1** — Pin an beiden Stellen, Digest belegt, Fragment re-adaptiert, `--disable` nach Namen, Kopf, Rot | **erfüllt** | `d-check.mk:73-74` und `internal/emit/emit.go:32-33` tragen `v0.76.1` und `sha256:1470ecdc…33b3`. Das lokale Bild: `RepoDigests` hat denselben Wert, das Label `org.opencontainers.image.version` lautet `0.76.1`. Die Registry hat Runde 1 belegt, die drei Kommandos stehen in `ebb76b3d`. Das Fragment ist gegen eine frische `--print-mk`-Ausgabe geprüft (§2.2): 76 Zeilen, 8 Adaptions-Hunks, 13/13 Targets, jeder der fünf Anker genau einmal in der Ausgabe und in der Fixture. Die Fixture bleibt deshalb zu Recht unverändert, und ohne neues Target braucht der Gate-Index keinen Eintrag. Beide Namensprüfungen geben auf dem Stand nichts aus (Exit 0). Ihr Rot hat Runde 1 und 2 gesehen. Der Kopf nennt `v0.76.1` und für die Marker-Tabelle einen Messstand (Zeiger auf `MR-027`). Das Rot der Kopplung ist in diesem Lauf selbst gesehen (§2.1). |
| **2** — Strenge-Bilanz `v0.76.0..v0.76.1` nach `MR-063`, `vcs`-Abbruchfall, `ADR-0042` Trigger 2 | **erfüllt** | Die Quell-Differenz über `internal/`, die Gegenmessung in drei Stufen (0/0, 57/57, 74/74), der lesbare und der abbrechende Fall sowie die Antwort auf Trigger 2 („nicht eingetreten“) stehen in `ebb76b3d` und `MR-064`. Die Regeldateien und Stufe 2 hat Runde 1 nachgefahren, die Quell-Lesung zum Port Runde 2. Ergänzt habe ich §2.3: Außerhalb von `internal/` bewegt sich im Werkzeug kein Code, auch kein `go.mod`. Ergebnis: **keine Senkung**, §4 greift nicht. Der lesbare Fall `make adr-immutable RANGE=8ae647cc~1..8ae647cc` meldet im heutigen Arbeitsklon (nur `pack-*`) unter `v0.76.1` `0 Befund(e)`, make-Exit 0 (§2.4). Den abbrechenden Fall habe ich nicht nachgefahren; zur Exit-Frage siehe V-4. |
| **3** — Werkzeug-Aussagen mit `v0.76.0` als Messstand gemessen oder datiert | **erfüllt** | Das Zählkommando aus §1 findet keine Zeile, die `v0.76.0` als geltenden Stand ausgibt. Die Treffer verteilen sich so: `d-check.mk:18` nennt die Version, ab der die Bedingung verfügbar ist, und keinen Messstand; `harness/sensors/commit-msg-check.md:61` datiert beide Digests; der Plan selbst; zwei Register-Belege, die ab Merge unveränderlich sind; ein offener Plan (nach §1 Bestand); die Index-Zeile von `MR-061`. `docs-check.md` nennt `v0.76.1` mit Digest. Die Aussagen zum `--range`-Abbruch sind in `ebb76b3d` und `4db3fcfb` nachgemessen. Ihr **Gegenstück** ist zu weit gefasst: V-1. |
| `make gates` grün | **erfüllt** | §7 |
| Review durchgeführt, Report liegt vor | **erfüllt** | zwei Reports vom 2026-09-17 unter `docs/reviews/`, beide aus einem Reviewer-Kontext |
| Doku-Update über Liefer-Punkt 3 hinaus keines | **erfüllt** | Es ist kein Target hinzugekommen (13/13), und `git diff --stat e4c6cb0b..78cf6680` nennt `harness/README.md` nicht. |
| Closure-Notiz, Register, Risiko-Ausgänge, Paarungen | **offen, Planner** | Closure-Pflichten (`AGENTS.md` §3.10); §7 des Plans steht auf „offen bis zur Closure“. |
| Reconciliation-Register | entfällt | wie im Plan begründet |

## 2. Eigene Messungen

Alle Läufe über `docker`, `make` und `git`, netzlos. Die Kopien liegen im Scratchpad außerhalb des
Repos; jedes Verzeichnis ist per `mktemp -d` angelegt und vor der ersten Mutation auf seinen Pfad
geprüft. `git status --short` im Arbeitsbaum war nach jedem Lauf leer. Keine Zahl ist ein
Erwartungswert.

### 2.1 Bewusstes Brechen der Pin-Kopplung

Vier Kopien per `git archive HEAD`. In jeder steht `d-check.mk` unverändert auf `v0.76.1`; die
Abweichung von `internal/emit/emit.go` gegenüber `HEAD` ist je Kopie per `diff` kontrolliert. Je
Kopie gefahren: `make test-go`.

| Kopie | Mutation an `emit.go` | make-Exit | rot |
|---|---|---|---|
| Kontrolle | keine | 0 | — |
| beide | Datei aus `e4c6cb0b` (Tag und Digest `v0.76.0`) | 2 | `TestDefaultDigest_MatchesCanonical` (`emit_test.go:73`, `… != kanonische Pin-Quelle … (Drift)`) **und** `TestDefaultImage_MatchesCanonical` (`emit_test.go:82`, `… != kanonische Quelle … (Tag-Drift)`) |
| nur Tag | `DefaultImage` auf `v0.76.0` | 2 | nur `TestDefaultImage_MatchesCanonical`, `(Tag-Drift)` |
| nur Digest | `DefaultDigest` auf `sha256:f0b55fde…` | 2 | nur `TestDefaultDigest_MatchesCanonical`, `(Drift)` |

Ein anderes Paket schlägt nicht an. Jede Meldung nennt den alten Wert gegen den kanonischen aus
`d-check.mk`, also die behauptete Ursache. Dass jeder Test allein fällt, zeigt: Jeder misst seine
eigene Hälfte der Kopplung, und keiner trägt die des anderen mit.

### 2.2 Fragment und Anker

- `docker run --rm --network none ghcr.io/pt9912/d-check@sha256:1470ecdc…33b3 --print-mk` ergibt
  76 Zeilen.
- Der `diff` gegen `d-check.mk` ergibt mit `grep -c '^[0-9]'` genau 8 Hunks.
- `grep -cE '^docs?-[a-z-]+:'` ergibt 13 über der Ausgabe und 13 über `d-check.mk`.
- Die fünf Anker aus `MR-063` sind `DCHECK_IMAGE ?=`, `.PHONY: doc-check`, `doc-check:`,
  `'^doc-[a-z-]+:` (je `grep -cF`) und die leere `DCHECK_DIGEST ?=`-Zeile
  (`grep -cE '^DCHECK_DIGEST \?=[[:space:]]*$'`). Jeder ergibt je 1 über der Ausgabe und über
  `internal/emit/testdata/raw-print-mk.txt`.

### 2.3 Quell-Differenz außerhalb von `internal/`

`git -C <Klon> diff --stat v0.76.0..v0.76.1 -- . ':!internal'` nennt 15 Dateien. Alle sind
Dokumentation, Planung oder die eigene Konfiguration des Werkzeugs; kein Code, kein `go.mod`,
kein `go.sum`. Die Quell-Differenz über `internal/`, auf die `MR-064` die Bilanz stützt, deckt
damit jeden Code-Pfad des Sprungs.
`git -C <Klon> tag -l 'v0.7[6-9]*' 'v0.8*'` nennt `v0.76.0`, `v0.76.1` und das ältere `v0.8.0`.
Ein neuerer Release existiert nicht.

### 2.4 Die Bedingung am Objektspeicher: „frei“ und das Gegenstück

Hier liegt die einzige Änderung, die kein Review gelesen hat (`78cf6680`, nach Runde 2).

- **`git repack -a -d` fasst `loose-*` zusammen.** Wegwerf-Repo mit drei Commits, danach
  `git maintenance run --task=loose-objects`: `ls .git/objects/pack/` nennt je eine `loose-*`-Datei
  (`.idx`, `.pack`, `.rev`). Nach `git repack -a -d` sind es je eine `pack-*`-Datei. Die Aussage
  aus `78cf6680` hält.
- **Der Arbeitsklon heute.** `ls .git/objects/pack/` nennt nur `pack-*`, `.git/objects/info/`
  enthält keine `alternates`-Datei.
  - `make adr-immutable RANGE=8ae647cc~1..8ae647cc`: `0 Befund(e)`, make-Exit 0.
  - `make doc-commits RANGE=c414119b..ebb76b3d`: 1 × `commit-untraceable` auf `7c1f228`,
    make-Exit 2.

  Beides deckt sich mit Runde 1.
- **Gegenbeispiel: `git clone --shared` des Arbeitsklons.** `ls -A .git/objects/pack/ | wc -l`
  ergibt `0`. `cat .git/objects/info/alternates` nennt den Objektspeicher des Arbeitsklons, dessen
  Packs alle mit `pack-` beginnen. git liest den Baum:
  `git cat-file -t '8ae647cc~1:.claude/hooks'` → `tree`, und `history-range-guard` löst die Range
  auf.
  - `make adr-immutable RANGE=8ae647cc~1..8ae647cc` endet mit make-Exit 2:
    `d-check: error: Range-Basis "8ae647cc~1" nicht auflösbar: reference not found`.
  - `make doc-commits RANGE=c414119b..ebb76b3d` endet mit make-Exit 2:
    `d-check: error: Range-Basis "c414119b" nicht auflösbar: reference not found`.

  **Gemessen ist eine Stelle:** eine Klon-Form, zwei Ziele, `v0.76.1`. Offen bleibt, ob das
  Werkzeug Alternates nicht liest oder ob der Container den Pfad der Alternates nicht sieht, weil
  das Rezept nur das Arbeitsverzeichnis einhängt. Unter `v0.76.0` ist der Klon nicht gemessen.

## 3. Plan-vs-Code-Diff

**Über den Plan hinaus gebaut** (§3 nennt es nicht):

- `Makefile`: die `KOPPLUNG`-Zeile samt Namensprüfung am Rezept `commit-msg-check`. §3 nennt nur
  den Kommentar an `regelwerk-check`. DoD 1 verlangt aber beide Listen nach Namen; gedeckt ist das
  also von der DoD, nicht von der Tabelle.
- `harness/sensors/history-range-guard.md` und `harness/sensors/doc-tracked.md`, aus Review F-1.
  Beide tragen dieselbe Klasse wie DoD 3 (Aussagen zum `--range`-Abbruch), die das Zählkommando
  aus §1 nicht trifft, weil sie keinen Versions-String nennen.
- Die Architect-Artefakte: `MR-064`, die Kopf-Marke an `MR-061`, die Index-Zeile und die Zeile
  `d-check:` in §Baseline. §6 übergibt nur „einen Adaptions-Eintrag“; Kopf-Marke und §Baseline
  führt `MR-064` in seinem Geltungsbereich. Der Titel wechselte von „unlesbarem Objekt“ zu
  „unlesbarem Unterbaum“, der Dateiname nicht (Runde 2, N-2).
- **Inhaltlich über den Plan hinaus:** Der Plan erwartete, die Aussagen zum `--range`-Abbruch am
  neuen Stand *nachzumessen*. Gemessen wurde eine **andere Ursache**: Der Abbruch hängt nicht an
  der Konfiguration allein, sondern am Objektspeicher. Das hat die Einordnung an fünf Stellen
  umgeschrieben (`.d-check.yml`, drei Sensor-Dateien, `MR-064`). Eine Rückführung nach §4 löst das
  nicht aus: Es gibt weder Senkung noch Handgriff.
- `d-check.mk`, Marker-Absatz: Der doppelte Messstand (`v0.74.1` im Text, dazu `MR-027`) wird zu
  einem Zeiger auf `MR-027`. Das ist in DoD 1 gedeckt.

**Geplant, aber nicht gebaut, jeweils zu Recht:**

- `internal/emit/testdata/raw-print-mk.txt`: Kein Anker fehlt (§2.2).
- `harness/README.md` / `.d-check.yml`-Targets: Es kommt kein Target hinzu.

**Aus der Liste „Was bei uns rot werden kann“ eingetreten:** `make adr-immutable` brach im
damaligen Arbeitsklon mit `loose-*`-Packs unter `v0.76.1` ab (`ebb76b3d`). Seit dem Umpacken läuft
es durch (§2.4).

## 4. Befunde und Übergaben

| ID | Kategorie | Befund | Pfad | Adressat |
|---|---|---|---|---|
| V-1 | MEDIUM | **Das Gegenstück der Bedingung ist als hinreichend formuliert und nicht hinreichend.** Drei lebende Stellen sagen, sinngemäß gleich: *„Liegen alle in Packs, deren Name mit `pack-` beginnt, läuft derselbe Range-Lauf durch und prüft.“* Im `--shared`-Klon (§2.4) liegen alle Objekte in einem Pack mit diesem Präfix, nur in einem fremden Objektspeicher, und `doc-commits` bricht trotzdem ab. Dazu gibt es einen zweiten, nicht gemessenen Rand: Lose Objekte fallen unter keine der zwei Formulierungen. Runde 1 hat eine Kopie nur mit losen Objekten gelesen gesehen. `commit-msg-check.md` spricht trotzdem von „den zwei Fällen“. Die Klasse ist dieselbe wie bei F-2 und N-1: *Stellen-Messung als Eigenschaft ausgegeben*. | `.d-check.yml:378-379`; `harness/sensors/commit-msg-check.md:76-80` und der Absatz „Welcher der zwei Fälle …“; `harness/sensors/history-range-guard.md:42-43` | **Implementer:** das Gegenstück auf das Gemessene einschränken (Objekte im eigenen Objektspeicher des Klons, keine Alternates) oder das Gegenbeispiel benennen. |
| V-2 | MEDIUM | **Der Diagnose-Schritt, den `MR-064` vorschreibt, sieht die Form nicht, die den Abbruch trägt.** §Grenze definiert „frei“ über `ls .git/objects/pack/`. Der Auflösungs-Trigger verlangt dieselbe Angabe für jeden history-lesenden Bilanz-Lauf. Der `--shared`-Klon ist nach diesem Wortlaut frei (0 Packs), und beide Ziele brechen ab (§2.4). Der Satz über „frei“ ist wörtlich wahr, der Schluss, für den er dasteht, nicht. Unter `v0.76.1` ist der Abbruch laut, kein stilles Grün, und keines der Ziele ist ein Gate. Der Absatz stammt aus `78cf6680` nach Runde 2 und ist ohne Review gepusht; der Eintrag ist damit eingefroren. Die Klasse passt zu `zusage-nennt-sensor-der-form-nicht-sieht`. | `harness/conventions/MR-064-d-check-pin-v0761-vcs-bricht-bei-unlesbarem-objekt-ab.md:266-270` und `:315-316` | **Architect** (`AGENTS.md` §3.8): Folge-Eintrag mit Kopf-Marke nach `MR-032`, oder Stehenlassen mit Begründung. |
| V-3 | INFO | Die `Accepted`-ADR `ADR-0053` führt in Alternative E weiter als gemessen: *„`--range` des Moduls ist am gepinnten d-check unbedienbar, sobald `commits.id-patterns` eine nicht-leere Liste trägt“*. Das ist die Einordnung, die `MR-064` ablöst. Das Zählkommando aus §1 und die Suche zu F-1 schlossen `docs/plan/adr` aus. Die Entscheidung der ADR hängt nicht daran; ihr Hauptargument ist, dass ein Range-Gate erst nach dem Commit urteilt. Die ADR ist unveränderlich (§3.4). | `docs/plan/adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md:263` | **Architect:** zur Kenntnis. Ein Folge-Artefakt ist nur nötig, wenn ein Leser die Zeile als geltend liest. |
| V-4 | INFO | Zu F-6: Die Tabelle in `MR-064` führt nur make-Exits. Im Fall *Spitze* ist der make-Exit unter beiden Digests 2 und unterscheidet deshalb nichts. Unterschieden wird der Fall durch die Meldung, die `MR-064` nennt, und durch den **Werkzeug-Exit** 1 → 2 (im Fall *Basis* 0 → 2). Den Werkzeug-Exit hat Runde 1 direkt gemessen, unter beiden Digests und mit gleichem Aufbau; die Tabelle deckt sich damit. Nachgefahren habe ich ihn nicht: Kein Befund dieses Laufs stellt diese Messung in Frage. DoD 2 („liefert `v0.76.1` Exit 2“) ist damit belegt, aber nur im Review-Report, einem Zeitdokument. | `MR-064`, Tabelle zum abbrechenden Fall | **Planner:** §7 zitiert für den abbrechenden Fall die Werkzeug-Exits aus Runde 1, nicht die make-Exits. |

## 5. Risiken aus §6: Belege für die Closure

Die Ausgänge setzt der Planner. Hier stehen nur die Belege.

1. **Abbruchfall nicht herstellbar:** Der Fall ist hergestellt (Basis und Spitze an der
   Wegwerf-Kopie, `MR-064`) und in Runde 1 mit Werkzeug-Exit nachgefahren. Das spricht für
   *entfallen*.
2. **Weiterer Release vor dem Start:** §2.3 nennt keinen Tag nach `v0.76.1`. Der Pack-Präfix-CR
   im Werkzeug ist nicht released. Das spricht für *entfallen*.
3. **Eintrag friert vor seinem Review ein:** Runde 1 und 2 haben `MR-064` vor dem Push gelesen.
   Die N-1-Korrektur (`78cf6680`) ging ohne Review in den Push, und V-2 trifft genau diesen
   Absatz. Ein Defekt darin braucht jetzt einen weiteren Eintrag, falls der Architect korrigiert.
   Das spricht für *eingetreten*, zumindest für diesen Teil; Kandidat für einen Beleg unter
   `norm-eintrag-friert-vor-seinem-review-ein`.

## 6. Offengelegt

- **Nicht nachgefahren:** Gegenmessung Stufe 1 und 3, der abbrechende Fall selbst, die
  Registry-Abfrage, die Stilllegungs-Tabelle in `docs-check.md` und der Transportklon mit
  umbenannten Packs. Das Rot der Namensprüfung hat Runde 1 und 2 gesehen. Keines davon ist
  sicherheitskritisch im Sinn von Modul 11. Die Bilanz „keine Senkung“ trägt die Quell-Differenz
  (Runde 1 plus §2.3) zusammen mit der Quell-Lesung (Runde 2) auch ohne Stufe 3.
- **V-1 und V-2 beruhen auf einer Klon-Form.** Andere Formen, bei denen `.git` nicht das
  Objektverzeichnis trägt (etwa ein `git worktree`), sind nicht gemessen, und über sie sagt dieser
  Bericht nichts.
- Ein Docker-Tag `ai-harness-init:test` ist durch die Mutationsläufe überschrieben worden. Der
  Gate-Lauf in §7 baut die Stage neu (`--no-cache-filter test`).

## 7. Gate-Lauf

`make docs-check` und danach `make gates` laufen über dem Baum, der diesen Bericht enthält. Ihre
Exit-Codes stehen in der Commit-Message dieses Berichts.

## 8. Verdikt

**DoD-Liefer-Punkte 1 bis 3 erfüllt, nicht closure-bereit.** Pin, Kopplung, Fragment,
Namensprüfung, Kopf, Strenge-Bilanz, `vcs`-Abbruchfall und die Datierung der Werkzeug-Aussagen
halten; das Rot der Kopplung ist gesehen und hat die behauptete Ursache. Die Bedingung steht an
allen Stellen gleich. **Ihr Gegenstück und die Aussage über „frei“ halten nicht als hinreichende
Bedingung** (§2.4).

**Vor der Closure fehlt:**

| Nr. | Was | Adressat |
|---|---|---|
| 1 | V-1: Gegenstück in `.d-check.yml`, `commit-msg-check.md` und `history-range-guard.md` auf das Gemessene einschränken oder das Gegenbeispiel nennen; danach `make gates` | Implementer |
| 2 | V-2: Entscheidung zu `MR-064` §Grenze und Auflösungs-Trigger (Folge-Eintrag mit Kopf-Marke oder Stehenlassen mit Begründung); V-3 zur Kenntnis | Architect, über den Planner |
| 3 | Closure: §7 mit Lerneintrag; Risiko-Ausgänge nach §5 dieses Berichts; für den abbrechenden Fall die Werkzeug-Exits aus Runde 1 (V-4); Register-Belege für die Klassen aus Runde 1, Runde 2 und diesem Bericht (`stellen-messung-als-eigenschaft-ausgegeben` zählt für diesen Vorgang einmal, dazu `zusage-nennt-sensor-der-form-nicht-sieht` und `norm-eintrag-friert-vor-seinem-review-ein`); die drei Paarungen; DoD-Häkchen; `make slice-mv` nach `done/` | Planner |
