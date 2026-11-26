# Review-Report: slice-mutations-beleg-eingecheckt — 2026-11-25

**Review-Art:** Code — geprüft gegen den Slice-Plan und die Konventionen (Modul 10 §Drei Review-Arten).

**Gegenstand:** `slice-mutations-beleg-eingecheckt` · Diff-Range `f545a019..7f466d0c` (Sub-Züge `f545a019` — Architect · `79757bc2` · `7f466d0c` — Implementer; der Move `7425c326` ist reiner Lifecycle-Step)

**Skill:** `.harness/skills/reviewer.md` @ 2.3.0 ·
**Modell:** Claude Code (glm-5.3-flash, Subagent) · **Datum:** 2026-11-26

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- `slice-mutations-beleg-eingecheckt` (Slice-Plan, `docs/plan/planning/in-progress/`)
- ADR-0102 (Festlegungen 1–4, Re-Evaluierungs-Trigger) · ADR-0035 · ADR-0083 · ADR-0101 (Berichtigungs-Praxis für tote Adressen in Accepted-ADRs)
- `LH-QA-01` · `LH-QA-02` · `MR-051` · `MR-025` · `MR-053` · `MR-072` · `MR-090` · `MR-091`
- `AGENTS.md` §3 (Hard Rules; namentlich §3.4, §3.6, §3.7, §3.11)
- Baseline-Regelwerk `v7.0.0` · `regelwerk/modul-06-roadmap.md` §Das Beobachtungs-Register („Ein Vorgang zählt einmal")

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | ADR-0102 §Geschichte linkt den Slice-Plan über seinen Lifecycle-Pfad (`docs/plan/planning/in-progress/slice-mutations-beleg-eingecheckt.md`); der Zielort wandert bei der Closure per `git mv` nach `done/`, und `slice-mv` nimmt `docs/plan/adr` aus dem eingehenden Verweis-Nachzug aus (Pathspec-Ausnahme im Skript, neben `:!.harness/baseline`) — der Link bricht permanent in einer nach §3.4 eingefrorenen ADR. Die Adresse hätte bei der Kennung (`slice-mutations-beleg-eingecheckt`) zu stehen, wie die Zitier-Form der Report-Vorlage und §3.11 es für ein Artefakt verlangen, dessen Ort der Prozess bewegt; die Vorgänger-ADRs desselben Tages zitieren Bewegliches als Kommando-/Kennung-Zeile, nie als Markdown-Link in den Lifecycle. | [`AGENTS.md`](../../AGENTS.md) §3.11 | `docs/plan/adr/0102-mutations-ci-ergebnisse-tragen-als-eingecheckte-beleg-datei.md` · Verweis-Spalte der Accepted-Zeile (Geschichte-Tabelle, letzte Zeile der Datei) | ja — `make docs-check` über dem Stand ab der Closure (target-missing); bis dahin trägt kein Lauf es, weil der Link am Schreibmoment noch auflöst | Eingefrorenes Artefakt nennt ein wanderndes Artefakt als Pfad statt als Kennung |
| F-2 | MEDIUM | Plan §8 und der DoD-Punkt „Beobachtungs-Register" versprechen, der BEFUND-Beleg (Run 45647457778) „zählt die Klasse hoch" (§8: von 1 auf 2). Der Fund teilt seinen Vorgang (`slice-d-check-sprung-v0930`) mit der bereits vorhandenen, mit Merge unveränderlichen Evidence-Datei — unter „Ein Vorgang zählt einmal" zählt ein zweiter Fund im selben Vorgang nicht; der abgeleitete Zähler (Anzahl der Evidence-Dateien) bleibt, wo er vor der Beleg-Ernte stand. Der Versprechen-Weg „eine weitere Evidence-Datei" (Plan §3, Tabellen-Zeile) würde denselben Vorgang zweimal zählen und die 3×-Schwelle zum Phantomausgang heben; der Weg „Bestand editieren" bricht die Unveränderlichkeit der Evidence-Datei. | `v7.0.0` · `regelwerk/modul-06-roadmap.md` §Das Beobachtungs-Register (Zähler abgeleitet; „Zwei Funde im selben Vorgang … kein zweites Auftreten"; Evidence unveränderlich ab Merge) | `docs/plan/planning/in-progress/slice-mutations-beleg-eingecheckt.md` · §8 Punkt „Treffer … Zähler steht bei 1" und §3 Tabellen-Zeile `../observations/BEO-ALL/…` | ja — nach der Closure: `ls <Register>/evidence/` gegen die Vorgangs-Menge (`slice-d-check-sprung-v0930` darf nur eine Datei tragen) | Zweitfund im selben Vorgang als Zähler-Auftritt geplant |
| F-3 | LOW | Die Kopf-Zeilen der vier Beleg-Dateien tragen die Festlegung-2-Pflichten nur zum Teil: die zwei `befund-last`-Köpfe nennen Run-Id, aber keinen Attempt; die Messwert-Zahlen der Köpfe („82/82", „~90 Tage", „Zeilen 209-306", Wanduhr je Shard) tragen den von Festlegung 2 verlangten Erwartungswert-Vermerk (`MR-053`-Form) nirgends. | ADR-0102 Festlegung 2 | `docs/reviews/mutate/slice-c3-d-check-faecher-v7-0-0-3880063f-befund-last.txt` Z. 2 · `docs/reviews/mutate/slice-c7-adaptions-nachzuege-v7-0-0-3880063f-befund-last.txt` Z. 2 · `docs/reviews/mutate/slice-d-check-sprung-v0930-625cdef0-gruen.txt` Z. 6 | nein — kein Gate liest `docs/reviews/**` (exempt, s. Negativbefund zur Form-Zeile unten) | Kopf-Pflicht je Messwert-Zahl und Attempt unvollständig |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Commit-Zuschnitt je Rolle (§3.8) | geprüft, ohne Befund — `git show --stat` über die drei Sub-Züge; `f545a019` berührt allein ADR + ADR-Index (beide Architect-Artefakte), `79757bc2`/`7f466d0c` allein die vier Beleg-Dateien, `harness/sensors/mutate.md` und den Ruhe-Marker der Roadmap (derivativ von `in-progress/`, kein Architect-Gegenstand). ADR-0102 trägt `**Status:** Accepted` und folgt der Ziel-Form (Kontext, Entscheidung, Alternativen, Konsequenzen, Re-Evaluierungs-Trigger, Geschichte). |
| Namens-Form der Beleg-Dateien gegen ADR-0102 Festlegung 1 | geprüft, ohne Befund — `<slice-kennung>-<sha8>-<form>`: `625cdef0` als geprüfter Commit des Grün-/BEFUND-Paares stimmt mit den Zahl-Belegen der Slice-Closure über dem Pin-Sprung überein; `3880063f` als HEAD der Teil-Ernte-Läufe ist der Vorfahr beider Claim-Commits (`c7ad9c6d`, `0f4e3b0d`, beide per `git cat-file -e` auflösbar); Qualifikatoren `befund-infra`/`befund-last` wie der optionale Qualifikator der Festlegung. Die im Auftrag genannten falsch geplanten `28da4709`-Namen trägt keine der gelieferten Dateien — die Zeichenfolge steht im Bestand nur in `slice-gates-fastpfad-ueber-stempel` (Plan und Verifikations-Report), nicht in Plan, ADR oder Beleg-Datei dieses Slices; eine Korrektur-Notiz ist darum kein Gegenstand dieses Diffs und fehlt zu Recht. |
| Grün-Beleg gegen das Job-Log (Prüffeld 3) | geprüft, ohne Befund — `gh api repos/pt9912/ai-harness-init/actions/jobs/139305369935/logs` · Zeilen 209–306 · Zeitstempel-Spalte strippen · `diff` gegen den Dateikörper Z. 11–108 → byte-gleich (alle 98 Zeilen); je Datei zählen 82 `ok`-Zeilen, Kopf und Fallmenge-Zeile nennen 82 (Slice: 82), Wanduhr 1775 s und `Urteil: gruen` wie das Log. |
| BEFUND-Beleg-Dateien (Kopf- und Zähl-Konsistenz) | geprüft, ohne Befund — `befund-infra`: 71 `ok` + 11 `BEFUND (kein Ergebnis im Log)` im Zellkörper (das zwölfte Vorkommen steht in der Kopf-Zeile) = 82, Shards 0 und 5 tragen „Exit 2" wie der Kopf sagt; `befund-last` c3: 30 `ok` + 57 = 87, zehn Shards „Exit 2", 0 „Exit 0"; `befund-last` c7: 30 `ok` + 20 = 50, zehn Shards „Exit 2", 0 „Exit 0"; je Kopf nennen Ausgabe-Kanal, Lesekommando und Entnahme-Stand wie Festlegung 2 es verlangt (Abweichungen s. F-3). Die `Branch-File`-Lesekommandos sind nach der Konsum-/Räum-Reihenfolge bewusst historisch (Entnahme-Stand im Kopf) — die Bytes dieser drei Zellen sind nur am Entnahme-Stand geprüft, nicht nach der Räumung re-verifizierbar; genau diese Grenze benennt die Sensor-Doku (ergebnis-Job-Log von Run 45647457778, Job 139322200730, trägt die Fassung selbst nicht). |
| Form-Zeile in `harness/sensors/mutate.md` §CI-Branch (Prüffeld 4) | geprüft, ohne Befund — der Absatz nennt Ablageort, Namens-Form und Konsum-Reihenfolge (lesen → committen auf `main` → dann räumen), die Schreib-Rechte (`contents: write` allein am `ergebnis`-Job, auf `main` schreibt die CI nicht) und die Grenze „kein Wächter hält diese Ablage-Form" mit beiden Grep-Zeilen; `grep -n 'docs/reviews' .d-check.yml` zeigt `docs/reviews/**` in `exempt-paths`-Listen und nennt `docs/reviews/mutate` nirgends — die Zusage „kein Wächter" hält am Bestand. Der Nachzug-Commit `7f466d0c` zieht die `MR-051`-Link-Form nach (`../../harness/conventions/…`, Ziel existiert). |
| Branch-Räumung und Konsum-Reihenfolge (Prüffeld 6) | geprüft, ohne Befund — `git ls-remote origin 'refs/heads/mutate/*'` → leer; die Beleg-Dateien sind vor der Räumung committet (`79757bc2` trägt alle vier), die Reihenfolge steht im Sensor-Absatz und in der ADR als Festlegung 3. Kein Branch-Beleg blieb als zweite Quelle liegen. |
| Register-Aufgabe an die Closure (Prüffeld 5) | geprüft, mit Befund — die Aufgabe steht im Plan (§8, DoD, §3) und ist damit nicht still; ob sie in dieser Form ausgeführt werden darf, trägt F-2. Die Zähler-Angabe des Plans (§8: „steht bei 1") war beim Schnitt (`722e119b`, 16:26) gegen den gemergten Stand wahr; die Evidence-Datei der Closure `slice-baseline-vendorung-v7-0-0` (`9e48f1f6`, 18:07) hob ihn danach auf 2 — die Plan-Zählung ist damit überholt, was F-2 zusätzlich anfasst. |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 1 |
| LOW | 1 |
| INFO | 0 |

**Finding-Klassen dieses Laufs:** Eingefrorenes Artefakt nennt ein wanderndes Artefakt als Pfad statt als Kennung · Zweitfund im selben Vorgang als Zähler-Auftritt geplant · Kopf-Pflicht je Messwert-Zahl und Attempt unvollständig

## Verdikt

**Merge-blockierend:** ja — F-1 blockiert die Closure, nicht den Zustand des Beleg-Bestands: Der `git mv` des Slice nach `done/` darf erst nach der Bereinigung der ADR-0102-Geschichte-Zeile (Kennung statt Pfad), weil d-check `links` ab dem Move das tote Ziel meldet und die ADR im Kern eingefroren ist; die Berichtigungs-Praxis von ADR-0101 (Berichtigungs-Zeile in `## Geschichte`, außerhalb des vcs-Kerns) ist der Vorläufer für die Form. F-2 gehört in die Closure-Notiz (Zähler-Stand und Vorgangs-Zuordnung des BEFUND-Funds ausdrücklich entscheiden, bevor eine zweite Evidence-Datei angelegt wird); F-3 ist nebenher behebbar.

**Übergabe:** Findings gehen an den Implementer (Rückkante Review → Plan bei Plan-Defekt: F-2 ist ein Plan-Defekt); die **Finding-Klassen** gehen zusätzlich in die Slice-Closure §7 und von dort in den Zähler. Dieser Report selbst ist ein **Lauf-Beleg** — er wird über Läufe hinweg nicht wieder gelesen, und muss es nicht. Er ersetzt keine Verifikation — die DoD-/Spec-Konformität (namentlich die offenen DoD-Punkte: Closure-Notiz, Register, Risiko-Ausgänge) prüft der Verifier separat (Modul 11).
