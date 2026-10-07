# Review: slice-archiv-grenze-aus-der-commit-abstammung

**Rolle:** Reviewer (Modul 10, `.harness/skills/reviewer.md`) · **Datum:** 2026-10-07
**Gegenstand:** Commits `087f990d` und `3f068403` gegen den Slice-Plan, [ADR-0081](../plan/adr/0081-altbestand-grenze-aus-der-commit-abstammung.md)
(Festlegungen 1–5, Fitness), ADR-0041, ADR-0033, `v6.17.0` `modul-06-roadmap.md` §Wellen-Closure Schritt 4,
`AGENTS.md` §3.6/§3.7.

**Summary:** 0 HIGH · 0 MEDIUM · 1 LOW · 2 INFO. Kein blockierender Befund.

## Findings

### F-1 — LOW

- `quelle`: `AGENTS.md` §3.6 (emittierte Abdeckungs-Aussage), `LH-QA-02`
- `pfad`: `harness/tools/full-smoke.sh:1807` → `docs/user/e2e-abdeckung.md:23`
- `befund`: Die Deklaration der Stufe `archivierung_im_ziel` nennt neu `LH-QA-02`. Die Anforderung
  verlangt Pinning und „zwei Läufe mit gleichem Tag erzeugen identische Ausgabe"
  (`spec/lastenheft.md:572-573`); die Stufe misst davon nur, dass ein flacher Klon sperrt statt
  abweichend zu archivieren, und die Kurzbeschreibung nennt diese Grenze gegenüber `LH-QA-02` nicht.
  Die RTM liest die Datei als Abdeckungs-Quelle (`.d-check.yml:551-552`). Failure-Szenario: entfällt
  die Abdeckung durch die Stufen in Zeile 24/34, bleibt `LH-QA-02` über einer Stufe „E2E ok", die
  weder Pin noch Ausgabe-Identität misst.
- `verifizierbar`: nein (kein Sensor hält Kurzbeschreibung gegen Anforderung)
- `klasse`: Abdeckungs-Aussage nennt eine Anforderung ohne Teilmess-Grenze

### F-2 — INFO

- `quelle`: ADR-0081 Festlegung 4
- `pfad`: `docs/user/benutzerhandbuch.md:398`
- `befund`: Der Satz „In einem flachen Klon … bricht der Lauf mit der Sperre `flacher-klon` ab" steht
  ohne die Bedingung „liegt eine Ergebnisnotiz in `done/`"; `grenzSperren` sperrt nur bei
  `GrenzeAktiv` (`internal/archive/grenze.go`). Ein Leser in einem flachen Klon ohne Ergebnisnotiz
  erwartet die Sperre, der Lauf archiviert — ADR-konform, kein falsches Archiv, nur die Erwartung.
- `verifizierbar`: ja (`TestGrenzeOhneErgebnisnotizVerhaeltSichWieBisher`)
- `klasse`: Bedingung einer Sperre fehlt im Nutzertext

### F-3 — INFO (Hinweis des Implementers)

- `quelle`: Maintainability
- `pfad`: `internal/emit/templates/commands/close-welle.md:94`, `internal/emit/templates/enforce/archivierung.mk:17`
- `befund`: Die Usage in `cmd/ai-harness-init/archive_welle.go` nennt `[kein-schreib-pfad]` nicht
  (`grep -rn kein-schreib-pfad cmd` → leer); die beiden Template-Stellen tun es, beschreiben aber einen
  **älteren** Träger ohne Schreibpfad — die Sperre stand im Go-Code bis zu `b64b75b1`
  (`git log -S'"kein-schreib-pfad"' -- internal cmd`). Unverändert vom Diff; für ein Ziel mit älterem
  Pin wahr. Kein Befund dieses Diffs.
- `verifizierbar`: nein
- `klasse`: Text nennt Sperre eines älteren Trägers

## Kommandos und Ausgaben

- `make mutate MUTATE_CASES="542-archive-welle-go-grenze-vergleich-umgekehrt 543-close-welle-ohne-flacher-klon 544-close-welle-ohne-bleibt-liegen"`
  → `mutate: 3 ok, 0 Befund(e)`, EXIT 0.
- Gegenprobe 542: Mutation angewandt, `t.Skip` allein in `TestGrenzeAltbestandNimmtNurSlicesVorEinerGrenze`,
  `make test-go` → EXIT 2, rot bleiben `TestGrenzeWelleNimmtDieFruehesteClosure` und
  `TestGrenzeParalleleClosuresTeilenDenSlice`. Gemeinsame Stelle `vorfahr`; der benannte Test bindet
  allein den Altbestand-Zweig (`o == ""`) — struktureller Nebeneffekt, kein Befund. Der cmd-Echt-Test
  blieb unter der Mutation grün: er prüft S = G und ein S ohne Abstammung, nicht S < G; S < G real
  trägt `full-smoke` (e). Baum danach per `git checkout` zurückgesetzt.
- `make e2e-abdeckung` → EXIT 0, `git status --short` leer (byte-gleich).
- `make gates` → EXIT 0.

## Geprüft, ohne Befund

- (a) `grenze.go`: Altbestand S ≤ G über irgendeinen Grenz-Commit; Welle-Lauf schließt S aus, wenn ein
  anderes G mit S ≤ G echter Vorfahr von O ist (früheste Closure); parallele G teilen S, der erste Lauf
  archiviert ihn, danach liegt er nicht mehr flach — keine Doppelarchivierung; Notizen im selben Commit
  (g = o) gelten als parallel. Ohne eigenen Add-Commit der Notiz keine Umordnung, Sperre `add-commit`.
- (b) `gitAbstammung`: `log -1 --no-renames --diff-filter=A --format=%H -- <pfad>` und
  `rev-parse --is-shallow-repository` wörtlich wie ADR-0081; `rev-list G`-Mitgliedschaft ist bei voller
  Historie gleichbedeutend mit `merge-base --is-ancestor`. git-Fehler → Exit 1; nie committeter oder
  ungetrackter Pfad → kein Add-Commit → `add-commit` (zusätzlich `unsauber`). Flacher Klon ohne
  Ergebnisnotiz: keine Grenze nötig, Verhalten wie ADR-0041 — ADR-konform (F4 „nur wo ein Grenz-Commit
  gebraucht wird"); das tmp-Ziel von `full-smoke` hat volle Historie, der CI-Klon des Repos ist davon
  nicht berührt.
- (c) Reviews werden nach `grenzeAnwenden` eingesammelt; ein liegen bleibender Slice behält seinen
  Report. `Haenger` sucht weiter im ganzen Suchraum außer dem Verschwindenden — ein flach bleibender
  Slice mit Verweis auf einen archivierten Report sperrt weiter fail-closed.
- (d) Testnamen messen die Eigenschaft (Wellenlose/NachGrenze-Mengen als Ist-Bestand gegen Soll-Liste,
  Sperren-Kennungen, Vorschau-Zeile); 542–544 gebunden.
- (e) `full-smoke` (e)/(e1)/(e2): drei Commits linear, altbestand nimmt slice-997, slice-996 bleibt und
  wird gezählt, welle-1 nimmt slice-995 und lässt slice-996; realer `--depth 1`-Klon sperrt mit
  HEAD/`done/` unverändert — misst, was die Deklaration sagt (bis auf F-1). Gelesen, nicht gefahren.
- (f) `close-welle.md`, `archivierung.mk`, Usage: Grenze, Zeile „bleibt liegen", beide Sperren stimmen
  mit dem Code; `v6.17.0` Schritt 4 wortgleich zu `v6.16.0` (Zeilen 313/314), Re-Evaluierungs-Trigger 1
  nicht gefeuert. Kommentare im Diff (§3.7) beschreiben den Zustand.
