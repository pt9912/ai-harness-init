# Nachprüfung `slice-stilllegungs-kanten-sind-gemessen` — F-1 bis F-5: 4 behoben · 1 teilweise; neu: 1 MEDIUM

**Rolle:** Reviewer · **Datum:** 2026-09-17 · **Geprüfter Stand:** `git diff 0edeeaab..d6bd222c`
(`3aae5fef` Implementer, `d6bd222c` Planner; 5 Dateien) · **Review-Art:** Nachprüfung der Findings
aus `docs/reviews/2026-09-17-slice-stilllegungs-kanten-sind-gemessen.md` gegen die Nacharbeit.
Neue Befunde stehen hier nur, wenn die Nacharbeit sie erzeugt hat · **Nicht Gegenstand:** die
DoD-Abhakung, F-6 (geht an die Closure) und F-7 (geht an den Verifier).

**Skill:** `.harness/skills/reviewer.md` @ `2.0.0` (`1b643a87`) · **Modell:** `claude-opus-5[1m]`

**Eingangs-Kontext:**
- Der Report des ersten Laufs (oben).
- Slice-Plan `slice-stilllegungs-kanten-sind-gemessen` §1 und §3.
- Die Folge-Slices `slice-mv-kanten-nach-done-sind-bewacht` (§1, §4) und
  `slice-mv-zieht-praefixlose-geschwister-verweise-nach` (geänderte DoD 1 und Closure-Trigger 1).
- `ADR-0056`, `LH-QA-01`, `AGENTS.md` §3.3, §3.7, §3.10 und §3.11.

---

## Status je Finding

| ID | Status | Beleg |
|---|---|---|
| F-1 | **behoben** | `harness/sensors/slice-mv.md`: „Die dritte Grenze wird an beiden Kanten wirksam", dazu eine eigene Spalte „präfixlos von Geschwistern" für beide Zeilen und der Satz, dass der Rest am Geber hängt, nicht an der Kante. `harness/sensors/docs-check.md` nennt beide Kanten. Deckt sich mit der Nachmessung des ersten Laufs (`slice-103-…`, 3 × `target-missing` nach `next → done`, ein Befund je Verweis). |
| F-2 | **behoben** | §1 des gemessenen Slice führt den Wächter als Ausschluss der Klasse *Folge-Slice*, mit Kennung. §3 verweist darauf. Die Adresse nimmt an: Das Ziel von `slice-mv-kanten-nach-done-sind-bewacht` ist genau der Wächter beider Kanten, im Dogfood und im Ziel, und keiner seiner Ausschlüsse nimmt ihn zurück. Den Ausschluss setzt der Planner, also die Rolle, der die Umfangsgrenze gehört. Ob die Begründung trägt: siehe N-1. |
| F-3 | **behoben** | Die Messung nennt den Stand `004335cc` samt Kommando. `git log -1 --format=%h -- harness/tools/slice-mv.sh` liefert `004335cc`, am Stand `d6bd222c` wie am Arbeitsstand. |
| F-4 | **behoben** | Das Rezept setzt `user.name` und `user.email` lokal in der Kopie und sagt, warum. |
| F-5 | **teilweise** | Die Adresse ist jetzt benannt: der eingehende CR vom 2026-09-17 mit Titel und d-check-Commit `d8e30b7d`. Die Datei `2026-09-17-cr-eingehend-ai-harness-init-stilllegungs-form.md` liegt im d-check-Klon. **Der Commit liegt aber nicht auf dem Remote:** `git -C <d-check> log --oneline origin/main..main` nennt `d8e30b7d`, und `git branch -r --contains d8e30b7d` bleibt leer. Außerhalb dieses einen Klons löst die Adresse darum nicht auf. |

## Neue Findings (durch die Nacharbeit entstanden)

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| N-1 | MEDIUM | Die Begründung, warum der Wächter nicht vor der Gruppierung stehen muss, hängt an einer Bedingung: Der Lauf, der die Kanten nimmt, prüft je Wechsel Exit-Code, reinen Rename und `make docs-check`. Dazu kommt die Reihenfolge „Werkzeug geändert und neu gemessen, bevor die Gruppierung die Kanten nimmt". Beides steht nur in den zwei Folge-Slices und im gemessenen Slice. Einen Plan der Gruppierung, der beides trägt, gibt es nicht; `grep -rn 'je Wechsel'` über `docs/plan`, `harness` und `AGENTS.md` trifft nur diese Stellen. Fährt der Gruppierungs-Lauf die Rename-Prüfung nicht, bleibt ein unreiner Move-Commit unentdeckt: Kein Modul des Doku-Gates liest Commits (`AGENTS.md` §3.10), und `make gates` färbt ihn nicht. | `AGENTS.md` §3.3 · `LH-QA-01` | `slice-mv-kanten-nach-done-sind-bewacht` §1 („Die Bedingung dafür"); dasselbe in `slice-stilllegungs-kanten-sind-gemessen` §1 und in `slice-mv-zieht-praefixlose-geschwister-verweise-nach` DoD 1 | nein: kein Modul liest Plan-Bedingungen oder Commits | Bedingung ohne Träger im Lauf, den sie bindet |

**Trägt die Begründung zu F-2?** Unter ihrer Bedingung ja. Die Versagensformen der Kanten laut
Tabelle werden je Wechsel sofort beobachtbar:
- ein Exit ungleich 0 am Exit-Code;
- ein unreiner Move an `git show --numstat`;
- ein fehlender Nachzug an `make docs-check` (`target-missing`, bei Code-Spans das Modul
  `codepaths` über `spec`, `docs` und `harness`).

Ein Wächter gegen Regression über die Zeit ist für einen einmaligen, beobachteten Lauf
entbehrlich. Die Bedingung selbst hat aber noch keinen Träger im Lauf, den sie bindet (N-1).
Darum ist die Begründung **nur bedingt tragend**.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| `AGENTS.md` §3.11 | geprüft, ohne Befund: neue Verweise auf Slices stehen bei ihrer Kennung. Die neuen Links zeigen auf ortsfeste Ziele (Sensor-Dateien, `spec/`, `docs/plan/adr/`) |
| `AGENTS.md` §3.10 | geprüft, ohne Befund: die geänderte Umfangsgrenze (§1) und die geänderte DoD des Geschwister-Slice stehen im Planner-Commit, nicht im ausführenden |
| `AGENTS.md` §3.7 | geprüft, ohne Befund im Geltungsbereich. „Gesetzt vom Planner nach Review-Befund F-2" steht in Slice-Plänen, die §3.7 nicht erfasst |
| Pflichtgliederung und Exit-Aussagen der Sensor-Dateien | geprüft, ohne Befund: die Nacharbeit ändert keine `##`-Überschrift; die Exit-Aussage in `docs-check.md` trennt weiterhin d-check und `make` |
| `MR-025`, `MR-033` | geprüft, ohne Befund: der neue Stand trägt sein Kommando, das Datum des CR steht neben dem Commit, `v6.9.0` bleibt genannt |
| Folge-Slice `slice-mv-kanten-nach-done-sind-bewacht` §4 | geprüft, ohne Befund: der Start hängt an `slice-mv-zieht-praefixlose-geschwister-verweise-nach` in `done/`, passend zum ersten Ausschluss in §1 |

## Verdikt

**Bereit für Verifier und Closure, mit zwei Übergaben an den Planner.**
- **F-5:** Kriterium 2 des Closure-Triggers („eine Adresse, die auflöst") ist erst erfüllt, wenn
  `d8e30b7d` auf dem Remote des d-check-Repos liegt. Die Closure prüft das.
- **N-1:** Die Bedingung aus der Begründung zu F-2 braucht einen Träger im Gruppierungs-Lauf,
  bevor dieser die Kanten nimmt. Gegen die DoD des gemessenen Slice steht sie nicht.
