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

Der **Träger** ist ausschließlich der PreToolUse-Zusatz-Hook
[`.claude/hooks/pretooluse-commit-msg-guard.sh`](../../.claude/hooks/pretooluse-commit-msg-guard.sh),
zweiter Eintrag im `"Bash"`-Matcher neben `pretooluse-command-guard.sh`
([`.claude/settings.json`](../../.claude/settings.json)): er erkennt einen `git commit`-Aufruf,
der eine Message-Datei per `-F`, `--file` oder `--file=` übergibt — unquotiert, in einfachen oder
doppelten Anführungszeichen, sowie mit `-F` als letztem Zeichen eines kombinierten Kurz-Flags
(etwa `-qF`) —, und spiegelt sie (Repo-Konvention „Commit via Message-Datei") **vor** der
Ausführung nach `make commit-msg-check MSG=<datei>`; er blockt bei Exit ≠ 0 — der Commit steht
dann nicht. Die Prüf-Instanz ist über `PRETOOLUSE_COMMIT_MSG_CHECKER` austauschbar (Default: der
`make`-Aufruf oben) — einziger Grund ist Testbarkeit.

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
  committen. Ob dieser Rest über einen `git`-eigenen `commit-msg`-Hook geschlossen wird (ein
  anderer Träger, mit eigener Bootstrap-Entscheidung), ist hier **nicht** entschieden.
- **Der Prüfbereich trägt seinen Cutoff, und er ist rein prospektiv.** Der PreToolUse-Hook prüft
  strukturell nur den **werdenden** Commit, nie die Historie — der Cutoff **ist** „ab dem ersten
  Aufruf dieses Hooks", nicht ein Datum in der Konfiguration. Ein Maßstab über die ganze Historie
  wäre an einem Bestand rot, den niemand mehr ändern kann
  ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **`doc-commits` (`d-check.mk`, `--range`) bleibt advisory und ungenutzt für diese Zusage** — nicht
  aus Vorsicht, sondern gemessen defekt: Der gepinnte `v0.74.1` bricht `--range`-Läufe des
  `commits`-Moduls mit `Range-Basis-Vorfahren nicht lesbar: object not found` ab, sobald
  `commits.id-patterns` irgendeine nicht-leere Liste trägt; verschwindet mit einer leeren oder ganz
  weggelassenen Liste — dann prüft der Range-Lauf aber auch nichts mehr (dasselbe stille Grün wie
  im Sensor [`history-range-guard`](history-range-guard.md)). Fehlerfrei **und** weiter prüfend
  bleibt nur `--commit-msg` mit der realen, nicht-leeren Liste (dieser Sensor). Ein Range-Lauf in
  CI bräuchte entweder einen Tool-Fix oder den vollständigen Verzicht auf eine explizite
  `id-patterns`-Liste — beides eine eigene Abwägung; `d-check` ist ein Nachbar-Repo desselben
  Nutzers, eine hier gemessene Modul-Lücke ist dort eine Anforderung, keine feste Werkzeug-Grenze.

## Ausgabe und Ausgänge

| Exit | Bedeutung |
|---|---|
| 0 | mindestens eine Kennung gefunden |
| 1 | keine Kennung gefunden (`commit-untraceable`) |
| 2 | Aufruf-Fehler, z. B. `commits.id-patterns` leer/fehlend |

## Bindung

Träger: [`.claude/hooks/pretooluse-commit-msg-guard.sh`](../../.claude/hooks/pretooluse-commit-msg-guard.sh);
kein Gate-Versprechen, aber PreToolUse-Zusatz-Hook vor jedem `git commit -F`.
