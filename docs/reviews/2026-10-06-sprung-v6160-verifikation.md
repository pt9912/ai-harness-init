# Verifikation: slice-sprung-auf-v6160-wird-vollzogen

**Rolle:** Verifier (Modul 8/11), frischer Kontext · **Datum:** 2026-10-06 · **Bezug:** `ADR-0078`,
`ADR-0079`, `MR-007`, `MR-033`, `MR-040` · **Gegenstand:** `b106f3e3..1844159a` gegen DoD und Plan
des Slice; Review `2026-10-06-sprung-v6160-review.md` vollständig gelesen, darum Stichproben.

- **DoD 1 (Träger) — bedingt.** Bestätigt: `make baseline-verify` → `v6.16.0 OK — 54 Dateien`;
  `make regelwerk-check` (Netz) → `2302 Datei(en) geprüft, 0 Befund(e)`, EXIT 0; `modul-13` und
  `modul-15` gegen `git -C <Kurs-Klon> show v6.16.0:lab/regelwerk/…` (nur gelesen) unterscheiden
  sich nur in der beim Packen umgeschriebenen `Quelle:`-Zeile; am Tausch-Commit ändern sich 14
  Vorlagen und, ohne die `Quelle:`-Zeile (`git diff -I 'Quelle:'`), 8 Regelwerk-Dateien. Das deckt
  sich mit dem Delta. Sechs Träger stehen auf `v6.16.0`. Der sha256 steht samt `curl … | sha256sum`
  im Tausch-Commit `f39b62d9`. Symlink-Kommando 1.3 → 0. Die drei `templates.go`-Stellen sind
  nachgezogen, und deren NUL-Byte-Aussage hält (`grep -rlP '\x00' …/v6.16.0/templates | wc -l` → 0).
  **Rot an der realen Quelle:** `DefaultTag` in `internal/fetch/baseline.go` auf `v6.13.0` →
  `make test-go` EXIT 2, `TestDefaultTag_MatchesBaseline`: *„fetch.DefaultTag "v6.13.0" != Makefile
  BASELINE_TAG "v6.16.0"“*, dazu `TestInventurMessTag_IstDerGefetchteStand`. Ein Byte in
  `regelwerk/modul-13-quality-gates.md` → `make baseline-verify` EXIT 2, *„weicht von SHA256SUMS
  ab“*. Beides zurückgesetzt, `git status` sauber. **Bedingt, weil:** Das Link-Kommando aus §1 liefert
  **3**, nicht die **0**, die 1.4 und Closure-Trigger 1 verlangen. Die drei Fundstellen sind
  ADR-0075 (1) und ADR-0076 (2); sie stehen nach `ADR-0079` (Accepted) als `ignore-refs`-Paare. Der
  Plan nennt `ADR-0079` aber nirgends. Das Abnahmekriterium hat sich verschoben, der Plan wurde nicht
  nachgezogen (§3.10: Übergabe an den Planner). Außerdem ist „Tausch- und Nachzugs-Commit in einem
  Push“ offen: nichts ist gepusht.
- **Verbleibende `v6.13.0`-Adressen (Pflicht 3) — bestätigt.** `git grep -n 'baseline/v6.13.0'`
  außerhalb der Zeitdokumente findet Folgendes, jeweils mit Begründung: ADR-0074 Z. 236 und ADR-0077
  Z. 28 (Inline, `Accepted`, eingefroren, §3.4); ADR-0075/0076 (Links, `ADR-0079`); ADR-0078 Z. 62
  (Vergleichs-Kommando der regierenden ADR); `docs/migrations/v6.13.0.md` (Bericht über diesen Tag);
  `docs/migrations/v6.16.0.md` Z. 18 (`git diff f39b62d9^ f39b62d9`, ref-gebunden); der eigene Plan
  (§1/§3 als Messung bzw. Entfernung). Ohne Begründung bleibt keine Fundstelle.
- **Zahlen (Pflicht 4) — bestätigt.** Die Kommandos aus `MR-056` nachgefahren: 125120 / 26745 /
  `27.2`. Das `MR-080`-grep → 1. `cat …/v6.16.0/regelwerk/*.md | wc -c` → 384237 (AGENTS.md §1).
  M-1 und M-2 des Reviews sind in `1844159a` behoben, beide Kommandos lesen `v6.16.0`.
- **DoD 2 (Freshness) und Pflicht 7 — bestätigt.** Das Übergabe-Artefakt trägt `MR-076` als
  *widerspricht*, Rückbau erst nach der Umstellung. Der Eintrag ist aktiv
  (`harness/conventions/MR-076-…`). Plan §1 nennt den Folge-Slice
  `slice-span-pflichtfeld-traegt-nicht-bekannt`, und der liegt in `open/`. Die vier übrigen
  Folge-Slices aus §1 liegen ebenfalls in `open/`.
- **DoD 3 (Vorlagen-Bericht, Pflicht 6) — bestätigt.** `grep -ci vorschlag` → 0. Die Ausgänge sind
  im Architect-Commit `1844159a` gesetzt (M-3 behoben), die Grenz-Frage ist als Lesart gesetzt
  („bedingte Regel, deren Bedingung nicht greift, zählt als *schon erfüllt*“). Die Instanz-Tabelle
  hat 15 Zeilen, nach `harness/migration.md` §4 abgegrenzt (25 − 9 wiederkehrende − 1 offene).
  Die Release-Bedingung aus ADR-0078 Festlegung 5 steht in Plan §4 und §6.
- **Gates (DoD 4):** `make full-smoke` → EXIT 0 (alle Stufen `OK`, im Ziel `baseline-verify: v6.16.0 OK`, keine Nennung von `v6.13.0` im Log) · `make gates` einmal am Ende, Ergebnis in der Commit-Message dieses Berichts. Offen für den Planner:
  1.4/Closure-Trigger 1 auf `ADR-0079` nachziehen; den Push von Tausch- und Nachzugs-Commits
  gemeinsam ausführen; I-1 aus dem Review. Laufzeit bis vor `make gates`: 12 min 8 s.
