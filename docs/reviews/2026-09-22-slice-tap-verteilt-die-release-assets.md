# Review-Report: slice-tap-verteilt-die-release-assets — 2026-09-22

**Review-Art:** Code — Code-Review gegen Plan + Konventionen (Modul 10 §Drei
Review-Arten).

**Gegenstand:** Commit `38870fbd` (Rolle Implementer: Tap-Verteilung —
Formel als Release-Asset, Handbuch-Weg 3, LH-QA-04, ADR-0059) — drei
Dateien: `.github/workflows/release.yml`, `harness/tools/homebrew-formula.rb.tmpl`
(neu), `docs/user/benutzerhandbuch.md`.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13)
**Modell:** claude-sonnet-5 · **Datum:** 2026-09-22

**Eingangs-Kontext:**

- `docs/plan/planning/in-progress/slice-tap-verteilt-die-release-assets.md`
  (vollständig gelesen: §1 Ziel/Abgrenzung, §2 DoD, §6 Risiken)
- `LH-QA-04` (Plattform-Matrix)
- `ADR-0059` (SHA256SUMS reisen als Release-Asset, der Emit-Pin trägt nur den Tag)
- `AGENTS.md` §3 (Hard Rules), insbesondere §3.6 und §3.7

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Der neue Fail-Closed-Guard (Abbruch vor dem Schreiben, wenn ein Plattform-Digest in `SHA256SUMS` fehlt) ist eine im Kommentar behauptete Zusage; weder das DoD (Liefer-Punkt 1) noch die Commit-Message benennen für **diesen** Guard einen rot gesehenen Beleg — die dort genannten zwei Roten Gegenproben (HTTP-404 gegen v0.2.1, `docs-check`-Pfadfehler) prüfen andere Fehlerbilder. Kein Bats-Test und kein `shell-lint`-Lauf deckt die inline `run:`-Logik (`grep -rn homebrew test/` → 0 Treffer). Ich habe den Guard selbst reproduziert (SHA256SUMS ohne `linux-arm64`-Zeile → Exit 1, keine `dist/ai-harness-init.rb` geschrieben) — die Zusage hält, ist aber im Diff/DoD nicht als rot-gesehen dokumentiert. | `AGENTS.md` §3.6 | `.github/workflows/release.yml:67-84` | ja — lokal reproduziert (siehe Befund); ein `test/release-matrix.bats`-Fall würde es dauerhaft sichern | Fail-closed-Zusage im Workflow-Kommentar ohne dokumentierten Rot-Beleg |
| F-2 | INFO | Bei einem `workflow_dispatch`-Lauf (kein Tag-Push) ist `GITHUB_REF_NAME` der Branch-Name (z. B. `main`), wodurch `version`/`tag` in der erzeugten `dist/ai-harness-init.rb` einen nicht-numerischen Wert trägt. Folgenlos für die Veröffentlichung (der `publish`-Job läuft nur bei `push`+Tag), sichtbar nur im internen Build-Artefakt `release-binaries`. | Maintainability | `.github/workflows/release.yml:70-71` | ja — Ableitung aus dem `if`-Guard des `publish`-Jobs, kein Dispatch-Lauf nötig | Formel im Dispatch-Build trägt irreführende Platzhalter-Werte |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Umfangs-Treue §1 (kein Tap-Repo-Inhalt, keine Secrets/PAT/Cross-Repo-Push) | geprüft, ohne Befund — `git show 38870fbd \| grep -i secret\|token\|PAT\|push\|homebrew-ai-harness-init` liefert keinen Treffer außer einem unbeteiligten Wort in der Commit-Message |
| Reihenfolge/Sequenzierung des neuen Workflow-Schritts (nach `release-artifacts`, vor `upload-artifact`) | geprüft, ohne Befund — `make release-artifacts` erzeugt `dist/SHA256SUMS` vor dem neuen Schritt; `upload-artifact` nimmt `path: dist/` komplett mit |
| Vier-Plattformen-Lesart (kein Windows) | geprüft, ohne Befund — `for plat in darwin-amd64 darwin-arm64 linux-amd64 linux-arm64` |
| Sechs Platzhalter vollständig ersetzt | geprüft, ohne Befund — `grep -oE '__[A-Z0-9_]+__' harness/tools/homebrew-formula.rb.tmpl` liefert genau die sechs vom `sed`-Aufruf abgedeckten Namen |
| Homebrew-DSL (`on_macos`/`on_linux`/`on_arm`/`on_intel`) | geprüft, ohne Befund — reales, aktuelles Homebrew-API, kein `if OS.mac?`-Altmuster |
| Lizenz-Angabe `license "MIT"` gegen `LICENSE` | geprüft, ohne Befund — `LICENSE` im Repo ist MIT |
| Handbuch Weg C — Ehrlichkeit („brew install“ funktioniert noch nicht) | geprüft, ohne Befund — Text nutzt Konjunktiv/Futur („bekämen“) und benennt explizit, dass das Tap-Repository fehlt |
| Handbuch Weg C / Kommentare — AGENTS.md §3.7 Chronik-Check | geprüft, ohne Befund — kein „früher“/„vorher“/Protokoll-Erzählung; neue Kommentare tragen Zusage/Kopplung/Rang-Zeiger/Grenze, keine verworfene Alternative als Historie |
| Rote Gegenprobe „falscher Pfad im Handbuch → `docs-check` rot“ | geprüft, ohne Befund — selbst nachvollzogen: Pfad verfälscht → 2 `codepath-missing`-Befunde, Original wiederhergestellt → 0 Befunde |
| Rote Gegenprobe „HTTP 404 gegen `v0.2.1`“ | nicht selbst nachvollziehbar (netzlos) — Methodik plausibel: die Formel existiert erst ab diesem Slice, ein Abzug gegen den bereits veröffentlichten `v0.2.1` kann sie nicht finden |
| `make ci-lint` (actionlint) auf den neuen Workflow-Schritt | geprüft, ohne Befund — Exit 0 |
| `make comment-claims` | geprüft, ohne Befund — 72 Dateien, 0 Befunde |
| §1-Abgrenzung (kein zweiter Fetch-Weg, kein Re-Publish `v0.2.1`) | geprüft, ohne Befund — Diff berührt `ADR-0058`-Fetch-Pfad und den bereits veröffentlichten Release nicht |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 0 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** Fail-closed-Zusage im Workflow-Kommentar ohne
dokumentierten Rot-Beleg · Formel im Dispatch-Build trägt irreführende
Platzhalter-Werte

## Verdikt

**Merge-blockierend:** nein — keine HIGH-Findings. F-1 ist vor der
Slice-Closure zu klären (MEDIUM), da AGENTS.md §3.6 für DoD- und
Kommentar-Zusagen einen Rot-Beleg verlangt und der bestehende Beleg-Satz den
Fail-Closed-Pfad nicht abdeckt; die Zusage selbst hält (von mir reproduziert).

**Übergabe:** Findings gehen an den Implementer. Die Finding-Klassen gehen
zusätzlich in die Slice-Closure §7 und von dort in den Zähler. Dieser Report
ist ein Lauf-Beleg und ersetzt keine Verifikation gegen DoD/Spec (Modul 11).
