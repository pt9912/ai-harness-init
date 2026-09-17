# `make commit-msg-check` — prüft eine Commit-Message-Datei gegen Traceability-Kennung

## Vertrag

`make commit-msg-check MSG=<datei>` prüft eine Commit-Message-**Datei** (nicht die Historie)
gegen das `commits:`-Modul aus [`.d-check.yml`](../../.d-check.yml) via `--commit-msg` — wie
`slice-mv`/`archive-welle`/`vendor-baseline` **kein Gate und in keiner Prerequisite-Kette**: `MSG`
variiert pro Aufruf und ist damit kein hermetischer Prüfbereich
([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Geprüft
wird **nur die Anwesenheit** einer Kennung aus `commits.id-patterns` (`ADR-\d{4}`,
`LH-[A-Z]{2}-\d{2}`, `MR-\d{3}`, `slice-\d+`) — **nicht ihre Wahrheit**: eine Message, die
zusätzlich einen nicht auflösbaren Hash nennt, geht mit derselben Kennung ebenso durch.

Der **Träger** dieses Ziels ist der PreToolUse-Zusatz-Hook
[`.claude/hooks/pretooluse-commit-msg-guard.sh`](../../.claude/hooks/pretooluse-commit-msg-guard.sh),
zweiter Eintrag im `"Bash"`-Matcher neben `pretooluse-command-guard.sh`
([`.claude/settings.json`](../../.claude/settings.json)): er erkennt einen `git commit`-Aufruf,
der eine Message-Datei per `-F`, `--file` oder `--file=` übergibt — unquotiert, in einfachen oder
doppelten Anführungszeichen, sowie mit `-F` als letztem Zeichen eines kombinierten Kurz-Flags
(etwa `-qF`) —, und spiegelt sie (Repo-Konvention „Commit via Message-Datei") **vor** der
Ausführung nach `make commit-msg-check MSG=<datei>`; er blockt bei Exit ≠ 0 — der Commit steht
dann nicht. Die Prüf-Instanz ist über `PRETOOLUSE_COMMIT_MSG_CHECKER` austauschbar (Default: der
`make`-Aufruf oben) — einziger Grund ist Testbarkeit.

**Der zweite Träger derselben Regel** ist der git-eigene Hook
[`.githooks/commit-msg`](../../.githooks/commit-msg) — aktiviert per `make hooks-install`
(`git config core.hooksPath .githooks`). Er läuft **am Commit** statt am Agenten, setzt darum
kein Docker voraus (das Skript
[`harness/tools/commit-msg-traceability.sh`](../../harness/tools/commit-msg-traceability.sh) ist
bash + coreutils) und führt dieselbe Kennungs-Menge als eigene bash-Fassung — die zwei Fassungen
hält [`test/commit-msg-hook.bats`](../../test/commit-msg-hook.bats) gegen die Liste aus
`.d-check.yml`. Welche Commit-Klasse welcher der beiden erreicht, steht in
[`harness/README.md`](../README.md) §Traceability; dieses Ziel beschreibt nur den `make`-Weg.

## Grenze — was das Grün nicht abdeckt

- **Nicht die Wahrheit der Kennung**, nur ihre Anwesenheit (s. Vertrag) — derselbe Befund wie bei
  `doc-commits`.
- **`-F -` (stdin)** bleibt bewusst ausgenommen — keine zu prüfende Datei.
- **Kein Quotierungs-Kontext.** Der Matcher liest die Befehlszeile flach: trägt der `-m`-Text
  selbst eine `-F`/`--file`/`--file=`-Form gefolgt von einem existierenden Pfad, greift der Hook
  trotzdem und prüft diesen Pfad wie eine Message-Datei (derselbe Stolperdraht-Charakter wie beim
  Nachbar-Guard, kein Sandbox-Anspruch, [ADR-0004](../../docs/plan/adr/0004-durchsetzungs-emission.md)).
  Ein in Anführungszeichen gesetzter Pfad, der eine Shell-Variable enthält, bleibt dauerhaft
  unexpandiert — kein Rateversuch, keine Shell-Expansion. Fehlt die Message-Datei aus einem
  anderen Grund (etwa weil sie erst nach dem Hook-Lauf entsteht), greift der Hook ebenfalls nicht.
- **Nur wörtliches `git commit …` im Bash-Tool-Kommando.** Ein Commit, der **innerhalb** eines
  anderen Skripts oder Binaries läuft (etwa `harness/tools/slice-mv.sh`, aufgerufen über
  `make slice-mv`), erscheint dem Hook als `make slice-mv …` und wird nie geprüft, unabhängig von
  Flag-Form oder Kennung — ebenso `archive-welle`/`vendor-baseline`, die aus dem Go-Binär heraus
  committen. Dieselbe Grenze trifft den `-m`-Aufruf, solange sein Text keine `-F`/`--file`-Form
  trägt (der Matcher liest die Befehlszeile flach), und einen Commit außerhalb eines
  Claude-Code-Laufs. Diese Klassen deckt der zweite Träger, der git-eigene Hook; wo er selbst nicht
  greift, steht in [`harness/README.md`](../README.md) §Traceability.
- **Der Prüfbereich trägt seinen Cutoff, und er ist rein prospektiv.** Der PreToolUse-Hook prüft
  strukturell nur den **werdenden** Commit, nie die Historie — der Cutoff **ist** „ab dem ersten
  Aufruf dieses Hooks", nicht ein Datum in der Konfiguration. Ein Maßstab über die ganze Historie
  wäre an einem Bestand rot, den niemand mehr ändern kann
  ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **`doc-commits` (`d-check.mk`, `--range`) bleibt advisory und ungenutzt für diese Zusage** — ein
  Range-Lauf hängt am Objektspeicher des Klons, dieser Sensor nicht. Gemessen an `v0.76.1` und
  `v0.76.3` (jeder Digest mit dem Fragment seines Standes), mit der `commits`-Konfiguration dieses
  Repos:
  - **Ein Pack, dessen Name nicht mit `pack-` beginnt, ist kein Abbruchgrund mehr.** Der gepinnte
    d-check löst jedes Pack auf, dessen Datei ein gültiges Hash-Suffix und eine passende `.idx`
    trägt. Gemessen an einer Wegwerf-Kopie, deren Objekte vollständig in einem `loose-*.pack` mit
    passender `.idx` liegen (wie `git maintenance run --task=loose-objects` es anlegt;
    `ls .git/objects/pack/` nennt genau dieses eine Paar, keine Alternates, `count: 0`):
    `make doc-commits RANGE=c414119b..ebb76b3d` meldet unter `v0.76.3` 1 × `commit-untraceable`
    auf `7c1f228`, make-Exit 2, und `make adr-immutable RANGE=8ae647cc~1..8ae647cc` meldet dort
    `0 Befund(e)`, make-Exit 0. Unter `v0.76.1` brachen beide an derselben Kopie mit
    `Range-Basis "<hash>" nicht auflösbar: reference not found` ab, make-Exit 2.
  - **Ein wirklich fehlendes Objekt der Range bricht weiter ab.** Dieselbe Kopie ohne die `.idx`
    ihres Packs — das Pack wird damit auch für `git` selbst unlesbar
    (`git cat-file -t 8ae647cc` → `fatal: Not a valid object name`) —: `make doc-immutable
    RANGE=8ae647cc~1..8ae647cc` unter `v0.76.3` mit
    `Range-Basis "8ae647cc~1" nicht auflösbar: reference not found`, make-Exit 2.
  - **Der Klon liest seine Objekte über Alternates** (`git clone --shared <pfad>`: keine eigenen
    Packs, `.git/objects/info/alternates` nennt den Objektspeicher der Quelle, `git` liest Commit
    und Baum). Unter `v0.76.1` **und unter `v0.76.3`** brechen `make doc-commits
    RANGE=c414119b..ebb76b3d` und `make adr-immutable RANGE=8ae647cc~1..8ae647cc` ab, make-Exit 2,
    mit `Range-Basis "<hash>" nicht auflösbar: reference not found`. Derselbe Abbruch steht, wenn
    der Pfad aus `alternates` zusätzlich in den Container gemountet ist.
  - **Geprüft hat der Range-Lauf in den gemessenen Klonen ohne Alternates, deren Objekte in einem
    Pack mit passendem Index oder lose liegen:** umgepackt (`git repack -a -d`), aus
    `git clone --no-local file://<pfad>`, eine Kopie nur mit losen Objekten (Pack per
    `git unpack-objects` ausgepackt und entfernt) und — neu unter `v0.76.3` — eine Kopie mit
    einem `loose-*.pack`. Dass diese Formen für einen prüfenden Lauf genügen, ist nicht belegt;
    genannt sind die gemessenen.

  Welche Form vorliegt, ist ein Zustand des Klons und wechselt mit seiner Pack-Wartung und seiner
  Klon-Art; die Abbruch-Bedingung und ihre Grenze für alle history-lesenden Ziele führt
  [`MR-064`](../conventions.md#mr-064--d-check-pin-v0761-vcs-bricht-bei-unlesbarem-unterbaum-ab)
  §Grenze.

  Fehlerfrei **und** weiter prüfend bleibt in jedem Klon nur `--commit-msg` mit der realen,
  nicht-leeren Liste (dieser Sensor). Ob ein Range-Lauf über einem Klon in einer der geprüften
  Formen ein Gate wird, ist eine eigene Abwägung. Dass d-check Objekte in einem Pack mit anderem
  Namen und über Alternates nicht liest, ist eine Lücke im Werkzeug eines Nachbar-Repos desselben
  Nutzers — dort eine Anforderung, keine feste Werkzeug-Grenze.

## Ausgabe und Ausgänge

| Exit | Bedeutung |
|---|---|
| 0 | mindestens eine Kennung gefunden |
| 1 | keine Kennung gefunden (`commit-untraceable`) |
| 2 | Aufruf-Fehler, z. B. `commits.id-patterns` leer/fehlend |

## Sperren

Die zwei ersten prüft das Rezept im `Makefile`, bevor es das Bild startet.

- `commit-msg-check: MSG=<datei> fehlt` — `MSG` ist leer; Exit 2 → eine Message-Datei nennen.
- `commit-msg-check: MSG=… ist keine Datei` — der Pfad ist keine Datei; Exit 2 → den Pfad
  berichtigen.
- `d-check: error: …` — die `.d-check.yml` ist ungültig; der Lauf bricht vor der Prüfung ab,
  Exit 2 → die Konfiguration berichtigen.

## Bindung

Träger dieses Ziels: [`.claude/hooks/pretooluse-commit-msg-guard.sh`](../../.claude/hooks/pretooluse-commit-msg-guard.sh);
kein Gate-Versprechen, aber PreToolUse-Zusatz-Hook vor jedem `git commit -F`. Die zweite Hälfte
derselben Regel trägt der git-eigene Hook [`.githooks/commit-msg`](../../.githooks/commit-msg)
(aktiviert per `make hooks-install`) — beide Reichweiten stehen in
[`harness/README.md`](../README.md) §Traceability.
