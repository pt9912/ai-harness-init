# Review-Report: slice-d-check-pin-zieht-den-vcs-patch-nach — 2026-09-17

**Review-Art:** Code. Geprüft wird der Diff gegen Plan, Adaptions-Block und Hard Rules.

**Gegenstand:** `git diff e4c6cb0b..8aac6d30`, drei Commits:

| Commit | Rolle | Stand beim Review | Inhalt |
|---|---|---|---|
| `ebb76b3d` | Implementer | gepusht | Pin und Digest, `emit.go`, `--disable`-Namensprüfung im `Makefile`, Kopf von `d-check.mk`, Kommentar am `commits`-Block, zwei Sensor-Dateien |
| `49995a05` | Architect | lokal | `MR-064`, Kopf-Marke an `MR-061`, Index-Zeile und Zeile `d-check:` in §Baseline |
| `8aac6d30` | Implementer | lokal | `MR-064` im Kopf von `d-check.mk`; Aussagen zum Pack-Präfix als Bedingung |

**Skill:** `.harness/skills/reviewer.md` 2.0.0 · **Modell:** `claude-opus-5[1m]` · **Datum:** 2026-09-17

**Eingangs-Kontext:**

- Slice-Plan `slice-d-check-pin-zieht-den-vcs-patch-nach` (§1 bis §6, Übergabe an den Architect)
- `MR-010`, `MR-027`, `MR-032`, `MR-046`, `MR-053`, `MR-055`, `MR-061`, `MR-063`, `MR-064`
- `ADR-0042`, Re-Evaluierungs-Trigger 2
- `LH-QA-01`, `LH-QA-02`
- `AGENTS.md` §3.1, §3.5, §3.6, §3.7, §3.8, §3.9
- nur lesend: der Klon des Werkzeugs (Tags `v0.76.0`, `v0.76.1`) und der uncommittete eingehende
  CR zum Pack-Präfix dort. Er ist nicht Gegenstand und wird nur als Beleg zitiert.

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Die Sensor-Datei zum Vorlauf-Wächter sagt weiter, `doc-commits` sei im Dogfood *„unbedienbar, unabhängig von der Range"*, weil jeder `--range`-Lauf unter der nicht-leeren `id-patterns`-Liste abbreche. Diese Einordnung löst `MR-064` ab, und `commit-msg-check.md` ist entsprechend korrigiert. Gemessen im jetzt umgepackten Klon (nur `pack-*`): `make doc-commits RANGE=c414119b..ebb76b3d` prüft und meldet 1 × `commit-untraceable` (`7c1f228`). Das Zählkommando aus §1 des Plans trifft die Stelle nicht, denn sie nennt keinen Versions-String. | `AGENTS.md` §3.6; `MR-064` (Löst auf) | `harness/sensors/history-range-guard.md` §Grenze, dritter Punkt | ja — `make doc-commits RANGE=c414119b..ebb76b3d` in einem Klon mit `pack-*`-Packs | Korrektur trifft den Fundort statt die gemessene Fundmenge |
| F-2 | MEDIUM | Die §Grenze von `MR-064` sagt *„Ein frischer Klon trägt solche Packs nicht"*. Der Auflösungs-Trigger bietet den *„frischen Klon"* darum als Alternative zur Angabe der Pack-Namen an. Gemessen gilt das nur für `git clone --no-local`: Ein `git clone <pfad>` (Voreinstellung) und `--no-hardlinks` übernehmen `loose-*.pack` unverändert. Dasselbe sagt `commit-msg-check.md` aus demselben Slice für `--no-hardlinks`. Der erste Punkt der §Grenze sagt außerdem, der Abbruch trete ein, *„sobald die Range ein Objekt braucht"*. Der dritte Punkt schließt unlesbare Blobs dagegen ausdrücklich aus. | `MR-055`; `MR-053` | `MR-064` §Grenze, erster und dritter Punkt; §Auflösungs-Trigger, letzter Satz | ja — Wegwerf-Repo, `git maintenance run --task=loose-objects`, dann drei Klon-Formen und jeweils `ls .git/objects/pack/` | Stellen-Messung als Eigenschaft ausgegeben |
| F-3 | MEDIUM | `MR-064` stellt fest, dass die geteilte Infrastruktur Zeilen verliert (git-Adapter −70, VCS-Port −27). Welches aktive Modul den git-Adapter liest, hat der Eintrag nicht gelesen, und den Schluss überträgt er der Gegenmessung. Diese läuft nach `MR-063` Setzung 2 über einer `git archive`-Kopie ohne `.git` und fährt deshalb keinen Pfad über den VCS-Port. Der Schluss *„keine Senkung"* ist trotzdem richtig. Am Quellstand `v0.76.1` (nur lesend) greifen nur `vcs`, `commits` und `tracked` auf den Port zu (`rules/run.go:34`, `rules/commits.go:23`, `rules/tracked.go:23`, `rules/vcs.go:30`), und keines davon steht in `modules:`. Getragen wird der Schluss also von dieser Quell-Lesung, die der Eintrag nicht führt, und nicht von der genannten Gegenmessung. | `AGENTS.md` §3.5; `MR-063` Setzung 2 | `MR-064` §Strenge-Bilanz, Absatz nach der Dateiliste | ja — Quell-Lesung am Klon; die Gegenmessung kann es nicht bestätigen | Beleg fährt den behaupteten Pfad nicht |
| F-4 | LOW | Der Kommentar am `commits`-Block und `commit-msg-check.md` fassen die Bedingung als *„Packs unter anderem Präfix als `pack-`"*. Für *„Bedingung und ihre Grenze"* verweisen beide auf `MR-064` §Grenze. Dort heißt dieselbe Bedingung *„unkanonisch benannte Packs"* bzw. `loose-*.pack`, und dort endet auch der Auflösungs-Trigger. Gemessen ist nur das Präfix `loose-`. Laut dem eingehenden CR im Werkzeug-Repo ist die Präfix-Regel nicht im Quelltext nachgelesen. Zwei Fassungen derselben Bedingung stehen damit an zwei Orten, und eine davon ist weiter gefasst als gemessen. | `MR-055`; `MR-053` | `.d-check.yml` (Kommentar am `commits`-Block); `harness/sensors/commit-msg-check.md` §Grenze, Punkt zu `doc-commits` | nein | Bedingung weiter gefasst als gemessen |
| F-5 | LOW | Im Absatz, den der Slice neu gefasst hat, steht weiter *„(Beleg und Traeger-Entscheidung in harness/README.md)"*. `harness/README.md` nennt `doc-commits` nicht; `grep -n 'doc-commits' harness/README.md` gibt nichts aus. Der Zeiger stand schon vorher dort. | `AGENTS.md` §3.7 | `.d-check.yml` (Kommentar am `commits`-Block, letzter Satz vor `KOPPLUNG`) | ja — der `grep` | Zeiger im berührten Absatz löst nicht auf |
| F-6 | INFO | Für die Verifikation (DoD 2 *„liefert `v0.76.1` Exit 2"*): `MR-064` und die Commit-Message führen nur make-Exits. Im Fall *Spitze* ist make-Exit 2 unter beiden Digests gleich, einmal wegen der Befunde, einmal wegen des Abbruchs. Den Werkzeug-Exit habe ich direkt gemessen: `v0.76.0` 1 (48 × `core-drift-vcs`), `v0.76.1` 2 (Abbruch). Im Fall *Basis* ist er 0 bzw. 2. Die Unterscheidung trägt dort also der Werkzeug-Exit, nicht der make-Exit. | Modul 11 (Verifier) | `MR-064` §abbrechender Fall, Tabelle | ja | — |
| F-7 | INFO | Die Größe von `MR-064` (20 003 Bytes, `wc -c`) habe ich auf Dopplungen geprüft. Das Urteil: Es gibt keine zweite Fassung, die driftet. Der `doc-commits`-Absatz ist eine eigene datierte Messung (Kopf `ebb76b3d`, `v0.76.1`). `commit-msg-check.md` führt eine andere (Kopf `e4c6cb0b`, beide Digests) und schreibt sich beim nächsten Sprung fort, während der Eintrag einfriert. Die Code-Liste der Gegenmessung ist ein Vergleich mit `MR-063` und keine Abschrift. Ob gekürzt wird, entscheidet der Architect. Der Satz *„Diese Messung unter beiden Digests steht … in commit-msg-check.md"* bezieht sich nur auf den Lauf mit leerer Liste; der Absatz davor misst an einem anderen Kopf. | Maintainability | `MR-064`, Absatz zum `--range`-Abbruch von `commits` | nein | — |
| F-8 | INFO | Die zwei Namensprüfungen im `Makefile` schneiden mit `--disable [a-z]+`. Ein Modulname mit Bindestrich oder Ziffer würde auf beiden Seiten gleich gekürzt. Heute gibt es keinen solchen Namen im Fragment. Der Kommentar sagt *„je abweichendem Namen eine Zeile"*; `diff` gibt zusätzlich Hunk-Kopf und Trenner aus. Wirksam sind die Prüfungen trotzdem (siehe Negativbefunde). | Maintainability | `Makefile`, Kommentare an `commit-msg-check` und `regelwerk-check` | ja | — |

## Eigene Messungen

Alle Läufe fanden netzlos statt, bis auf die Registry-Abfrage. Kopien lagen im Scratchpad. Keine
Zahl ist ein Erwartungswert.

- **Digest.** `docker image inspect --format '{{json .RepoDigests}}' ghcr.io/pt9912/d-check:v0.76.1`
  → `sha256:1470ecdc…33b3`. `docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.76.1` →
  `Digest: sha256:1470ecdcaa686a5ef4513dee9b0ae522586f54b87d568b06fc6b5b2741b633b3`. Das Label
  `org.opencontainers.image.version` des Bildes unter diesem Digest lautet `0.76.1`. Der alte
  Digest gehört laut RepoDigests zu `v0.76.0`.
- **Quell-Differenz** am Werkzeug-Klon, nur lesend: `diff --numstat v0.76.0..v0.76.1 -- internal/`
  nennt sieben Dateien, dieselben wie in `MR-064`. Über den acht aktiven Regeldateien gibt es
  0 Zeilen, und `ls-tree v0.76.1` führt alle 8.
- **Gegenmessung, Stufe 2**, als Stichprobe nach `MR-063` Setzung 2: `git archive e4c6cb0b`, je
  Digest das Fragment seines Standes, Marker nur in regulären Dateien entwertet. Symlinks unter
  `.claude/rules`: 10 von 10 (`ls-tree`: 10), 0 reguläre. Ergebnis unter beiden Digests: 57
  (20 `codepath-missing`, 37 `id-unlinked`), make-Fehlerzeile `d-check.mk:88` bzw. `:87`. Der
  `diff` der vollen Befundzeilen ist leer. Die Stufen 1 und 3 habe ich nicht nachgefahren.
- **`vcs`-Abbruchfall.** Aufbau: `git archive e4c6cb0b`, `git init`, A (alles), B (Kind von A,
  entfernt `docs/plan/adr`), C (Kind von A, eine Zeile am Ende von ADR-0042 im Abschnitt
  *Geschichte*), nur lose Objekte. Gefahren wurde das `doc-immutable`-Rezept je Fragment, direkt
  über `docker run`.

  | Fall | `v0.76.0` | `v0.76.1` |
  |---|---|---|
  | intakt `A..B` | Werkzeug-Exit 1, 48 × `core-drift-vcs` | Werkzeug-Exit 1, 48 × `core-drift-vcs` |
  | intakt `A..C` | Exit 0, `0 Befund(e)` | Exit 0, `0 Befund(e)` |
  | Baum `C:docs/plan/adr` entfernt, `A..C` | Exit 1, 48 × `core-drift-vcs` | Exit 2, `Range-Spitze … nicht lesbarer Unterbaum "docs/plan/adr": object not found` |
  | zusätzlich Baum `A:docs/plan/adr` entfernt, `A..B` | Exit 0, `0 Befund(e)` (make-Exit 0) | Exit 2, `Range-Basis … nicht lesbarer Unterbaum "docs/plan/adr": object not found` |

  Das bestätigt die Tabelle in `MR-064`.
- **Klon ohne `loose-*.pack`.** `ls .git/objects/pack/` zählt 0 × `loose-`.
  `make adr-immutable RANGE=8ae647cc~1..8ae647cc` → `0 Befund(e)`, make-Exit 0 (`v0.76.1`).
  `make doc-commits RANGE=c414119b..ebb76b3d` → 1 × `commit-untraceable` (`7c1f228`), make-Exit 2.
- **Pack-Namen je Klon-Form** (Wegwerf-Repo nach `git maintenance run --task=loose-objects`):
  `git clone <pfad>` → `loose-*`, `--no-hardlinks` → `loose-*`, `--no-local` → `pack-*`.
- **Namensprüfung der `--disable`-Listen**, an Kopien von `Makefile`, `d-check.mk` und
  `.d-check.yml`. Beide Kommandos, wörtlich aus dem Kommentar gezogen, geben nichts aus (Exit 0).
  Rot mit gelesener Ausgabe (Exit 1):
  - `regelwerk-check`: `targets`→`vcs` gibt `< targets` / `> vcs`; `spans`→`span` gibt
    `< spans` / `> span`; ein weiteres Modul in `modules:` gibt `< structure`.
  - `commit-msg-check`: `--disable mentions` entfernt gibt `< --disable mentions`; `vcs`→`vc` gibt
    beide Seiten; ein weiteres `--disable` im Fragment gibt `< --disable newmod`.

  **Vorfall:** Ein Mutationsschritt lief wegen eines fehlgeschlagenen `mkdir` im Arbeitsbaum
  statt in der Kopie. Ich habe `.d-check.yml` per `git checkout --` wiederhergestellt und die
  Hilfsdatei gelöscht, bevor irgendein Gate lief; `git status --short` war danach leer. Die
  Ausgaben oben stammen aus der Wiederholung in der Kopie bzw. von der wiederhergestellten Datei.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Pin-Kopplung `d-check.mk` ↔ `internal/emit/emit.go` (Tag und Digest) | geprüft, ohne Befund |
| Digest gegen Registry, lokales Bild und Versions-Label | geprüft, ohne Befund |
| Strenge-Bilanz an den acht aktiven Regeldateien (Quell-Differenz) | geprüft, ohne Befund (zum Träger des Schlusses über die Infrastruktur: F-3) |
| Gegenmessung Stufe 2, beide Digests je mit ihrem Fragment, Symlinks erhalten | geprüft, ohne Befund |
| `vcs`-Abbruchfall, Basis und Spitze | geprüft, ohne Befund; Werkzeug-Exit ergänzt (F-6) |
| `ADR-0042` Trigger 2 (*nicht eingetreten*) | geprüft, ohne Befund: Der Port dient `vcs`/`commits`/`tracked`, und keines davon hält eine Adress-Form |
| Kopf-Marke an `MR-061`: Form nach `MR-032` Setzung 1 und 3, Rumpf unverändert (Diff: nur zwei Kopfzeilen), Datei bleibt nach `MR-046` liegen | geprüft, ohne Befund |
| Umfang der Kopf-Marke: genau die zwei Aussagen, die am Objektspeicher hängen (`MR-061` Zeilen 121–124 und 180–184). Der Lauf mit `unbekanntes Modul "mentions"` hängt an der Konfiguration, nicht am Objektspeicher | geprüft, ohne Befund |
| Datierung nach `MR-053`: jede Werkzeug-Aussage in `MR-064`, `commit-msg-check.md` und `docs-check.md` nennt Tag bzw. Digest und Kopf | geprüft, ohne Befund |
| Index-Zeile `MR-064` (Anfänge von Geltungsbereich und Ersetzt-Baseline-Regel stimmen mit der Datei überein) und Zeile `d-check:` in §Baseline | geprüft, ohne Befund |
| Namensprüfung der `--disable`-Listen: Kommando im Kommentar hält, Tausch, Umbenennung und Zuwachs werden rot | geprüft, ohne Befund (Randnotiz F-8) |
| Kommentare (§3.7) in `d-check.mk`, `Makefile` und `.d-check.yml`: kein Lauf-Protokoll, Verweise in der Form *„(Messung und Stand: MR-…)"*. Der Zeiger im Kopf von `d-check.mk` auf `MR-027` löst auf: Tabelle und Sonde stehen dort | geprüft, ohne Befund (Ausnahme F-5) |
| Commit-Zuschnitt (§3.8): `49995a05` berührt nur `harness/conventions.md` und `harness/conventions/`, `ebb76b3d` und `8aac6d30` kein Norm-Artefakt; die Rolle steht jeweils in der Message | geprüft, ohne Befund |
| Sensor-Dateien: Gliederung von `commit-msg-check.md` unverändert (Vertrag · Grenze · Ausgabe und Ausgänge · Sperren · Bindung); die geänderten Exit-Aussagen heißen durchgehend *make-Exit* | geprüft, ohne Befund |
| `docs-check.md`, Stilllegungs-Tabelle, neuer Messstand | nur gelesen, nicht nachgemessen: Die Angabe nennt Digest und Aufbau |
| Fixture `raw-print-mk.txt`, fünf Anker | nur gelesen (Angabe in Commit und `MR-064`), nicht nachgezählt |
| Gate-Lockerung ohne ADR (§3.5), halluziniertes Gate (§3.1), Host-Toolchain (§3.9) | geprüft, ohne Befund: kein Modul und kein Target verändert, alle Läufe über `make`/`docker`, `git` |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 3 |
| LOW | 2 |
| INFO | 3 |

**Finding-Klassen dieses Laufs:** Korrektur trifft den Fundort statt die gemessene Fundmenge ·
Stellen-Messung als Eigenschaft ausgegeben · Beleg fährt den behaupteten Pfad nicht · Bedingung
weiter gefasst als gemessen · Zeiger im berührten Absatz löst nicht auf

## Verdikt

**Nacharbeit vor dem Push, kein HIGH.** Pin, Digest, Kopplung, Gegenmessung und der
`vcs`-Abbruchfall halten. Die Bilanz *„keine Senkung"* hält ebenfalls, am Quellstand gelesen.

**Merge-blockierend:** ja, für die drei MEDIUM:

- **F-2 und F-3 treffen `MR-064`.** Der Eintrag ist noch lokal, und Risiko 3 des Plans tritt
  damit ein. Die Entscheidung über die Korrektur liegt beim Architect (`AGENTS.md` §3.8).
- **F-1 trifft eine Sensor-Datei.** Das ist Implementer-Arbeit im Rahmen von DoD 3.

F-4 und F-5 sind vor der Closure zu klären oder mit Begründung stehen zu lassen.

**Übergabe:** Die Findings gehen an den Implementer (F-1, F-4, F-5) und über den Planner an den
Architect (F-2, F-3, F-4 soweit `MR-064`). Die Finding-Klassen gehen in §7 der Slice-Closure. Für
den Verifier ist F-6 bestimmt. Dieser Report ersetzt keine Verifikation.
