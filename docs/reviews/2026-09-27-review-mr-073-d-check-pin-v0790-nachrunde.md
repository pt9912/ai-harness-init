# Review-Report: MR-073 (d-check-Pin v0.79.0) — Nachrunde — 2026-09-27

**Review-Art:** Norm-Artefakt — gegen Plan + Konventionen (Modul 10 §Drei Review-Arten).

**Gegenstand:** Zweite Runde für den Slice
`slice-d-check-pin-bringt-links-lookahead-und-referenz-definitionen` — prüft die letzte offene
Closure-Voraussetzung (Closure-Trigger 2, §5 des Slice-Plans). Fünf Commits seit dem ersten Report,
davon drei im Gegenstand dieses Slice (chronologisch): `21afa8ba` (Implementer, volle
MR-063-Gegenmessung, behebt F-1), `21b45388` (Architect, MR-073 angelegt), `5fe0107d` (Architect,
Zeile 136 zweimal nachgebessert, amended, finaler Zustand). Zwei weitere Commits (`8d19b229`,
`12ef6e6b`) gehören einem unabhängigen Planner-Slice (`slice-mutate-form-match-epipe-verwirft-treffer`
in `next/`) und sind **nicht** Gegenstand dieser Runde — geprüft nur so weit, dass sie den
Ziel-Slice nicht berühren (Negativbefund unten).

**Vorheriger Report:**
[`2026-09-27-review-slice-d-check-pin-bringt-links-lookahead-und-referenz-definitionen.md`](2026-09-27-review-slice-d-check-pin-bringt-links-lookahead-und-referenz-definitionen.md)
(HIGH 0, MEDIUM 1 — F-1: unvollständige MR-063-Strenge-Bilanz, nur 5/9 Module). Diese Runde prüft,
ob F-1 geschlossen ist, und bewertet den seither neu entstandenen Adaptions-Eintrag MR-073
eigenständig.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.3.0
**Modell:** claude-sonnet-5 · **Datum:** 2026-09-27

**Eingangs-Kontext:**

- Vorheriger Review-Report (s. o.)
- Slice-Plan §2 (L2), §5 (Closure-Trigger), §6 (Übergabe an den Architect)
- `AGENTS.md` §3.5, §3.6, §3.7, §3.8
- `harness/conventions.md` samt MR-051, MR-053, MR-061, MR-063, MR-065, MR-066, MR-067, MR-068
- `harness/conventions/MR-068-…md` (Vorgänger-Muster, vollständig gelesen)
- `.harness/baseline/v6.9.0/templates/harness/conventions/MR-NNN-titel.template.md` (Pflichtfelder)
- `.d-check.yml` `ids:`/`matrix:`-Blöcke (Zeilen 319–367)
- `docs/plan/adr/0001-…md`, `docs/plan/adr/0003-…md`, `docs/plan/adr/0070-…md` (Status-Zeilen)
- lokaler Klon des Werkzeugs (`/Development/d-check`, nur lesend)

---

## Eigene Nachvollzüge (unabhängig vom Implementer-/Architect-Bericht)

1. **F-1-Behebung geprüft (`21afa8ba`).** Neun aktive Module laut `.d-check.yml` `modules:`-Zeile
   (`links, anchors, ids, matrix, codepaths, spans, planning, targets, structure`) — genau die Liste,
   die die Commit-Message nennt und gegen die sie ihre Sonden aufstellt. Methodik gelesen:
   `git archive HEAD` in eine Scratch-Kopie ohne Objektspeicher (Angabe nach MR-065 Setzung 1
   vorhanden), je Digest (`v0.77.0` aus `12f30003~1`, `v0.79.0` aus HEAD) das jeweils passende
   Fragment, Doppel-Digest-Vergleich in drei Stufen, `diff` der **vollen Befundzeilen** je Stufe
   (nicht nur Grund-Code-Zählung). Vier neue Sonden (matrix, spans, planning, targets) treffen
   plausible, benannte Grund-Codes; fünf waren bereits einzeln belegt (Implementer/Reviewer der
   ersten Runde). Ergebnis laut Commit: Stufe 3 (alle neun Sonden) `2074` Dateien, `88` Befunde,
   `diff` zwischen beiden Digests **leer**. Die Zahlen in der Commit-Message und in MR-073 (s. u.)
   stimmen überein (Summenprobe: 1+1+36+1+1+40+1+1+1+1+1+1+1+1 = 88). **F-1 ist damit inhaltlich
   geschlossen** — alle neun aktiven Module tragen eine Nicht-Null-Basis, byte-identisch über beide
   Digests; das war genau die Lücke, die F-1 benannte.
2. **Quell-Differenz selbst nachgefahren — und dabei eine Abweichung gefunden.** Sowohl die
   Implementer-Commit-Message (`21afa8ba`) als auch MR-073 selbst (Zeile 162–167) behaupten wörtlich:
   *„An den neun aktiven Modulen bewegt sich zwischen `v0.77.0` und `v0.79.0` nur `markdown.go` […]
   und `structure.go` […]; `file.go`/`file_test.go`/`run.go` gehören zum inaktiven Modul `file`,
   `pins.go`/`sources.go` sind keines unserer neun."* Selbst gefahren:
   `git -C /Development/d-check diff --numstat v0.77.0..v0.79.0 -- internal/hexagon/core/rules/`
   listet **elf** Dateien, darunter `anchors.go` (**3/0**) — eine Regeldatei des aktiven Moduls
   `anchors`, in der Aufzählung **nicht genannt**. Inhalt geprüft
   (`git -C /Development/d-check diff v0.77.0..v0.79.0 -- .../anchors.go`): ein neuer Skip
   `if ref.IsDefinition { continue }` mit Kommentar „anchors prueft Referenz-Definitionen nicht" —
   exakt die Ausnahme, die der Slice-Plan selbst in §1 schon benennt („`anchors` behandelt
   Definitionen nicht — neuer Out-of-Scope-Satz dort"), hier aber in der Quell-Differenz-Aussage der
   Strenge-Bilanz fehlt. Die übrigen acht Dateien der vollen `numstat`-Liste (`file.go`,
   `file_test.go`, `markdown.go`, `markdown_test.go`, `pins.go`, `reviews_test.go`, `run.go`,
   `sources.go`, `structure.go`, `structure_maxlines_test.go`) sind korrekt entweder dem inaktiven
   Modul `file` zugeordnet, außerhalb der neun (`pins.go`/`sources.go`, `reviews_test.go` — `reviews`
   ist kein aktives Modul dieses Repos), Test-Dateien der bereits genannten Änderungen, oder — bei
   `run.go` — eine reine, hinter `active["file"]` gated Verdrahtung des inaktiven Moduls. `anchors.go`
   ist die einzige Lücke in der Aufzählung.
   **Kein neuer Senkungs-Befund:** Die Änderung fügt eine **Ausnahme** hinzu (anchors überspringt
   Referenz-Definitionen), keine neue Prüfung — vor `v0.79.0` extrahierte `markdown.go`
   Referenz-Definitionen überhaupt nicht als Links, `anchors` prüfte sie also auch vorher mit 0 %
   Abdeckung. Die empirische Gegenmessung (Stufe 3, byte-identische Befundmenge inklusive der
   `anchor-missing`-Sonde) bleibt davon unberührt und ist die eigentliche Evidenz für „keine
   Senkung" — diese Zeile prüft sie unabhängig **nicht neu**, sie ist bereits in Punkt 1 bestätigt.
   Betroffen ist ausschließlich die **Quell-Differenz-Aussage** als zusätzliches, für sich
   behauptetes Argument („bewegt sich **nur**") — und diese Aussage ist an der behaupteten
   Vollständigkeit falsch. Siehe Finding F-2.
3. **Zeile-136-Lösung nachvollzogen.** `.d-check.yml` gelesen: `ids:` hat ein Muster
   `ADR-\d{4}` mit `link-policy: always` und `exempt-paths: [CHANGELOG.md, "docs/reviews/**"]` —
   `harness/conventions/` ist **nicht** ausgenommen, ein literales `ADR-0003`/`ADR-0001` in der neuen
   Datei löst also `id-unlinked` aus (bestätigt den ersten, verworfenen Fund). `matrix:` klassifiziert
   `harness/conventions/*.md` als `aussen` (First-Match: nicht `spec-straten`, nicht `adr`
   [Pfadmuster `docs/plan/adr/[0-9]*.md`], nicht `slice`) und trägt `status: {forbidden: [superseded,
   deprecated]}` ohne Pfad-Ausnahme für `harness/conventions/` — ein Live-Link von dort auf eine
   `Superseded`-ADR löst `matrix-inactive` aus. Status-Zeilen real gelesen: `docs/plan/adr/0001-…md`
   → `Superseded by ADR-0005`, `docs/plan/adr/0003-…md` → `Accepted`. Damit ist die im Commit
   `5fe0107d` beschriebene Kausalkette (Link-Form behebt `id-unlinked`, erzeugt aber real
   `matrix-inactive`; Beschreibungs-Form trifft keines von beiden) **an der Config selbst
   nachvollziehbar korrekt**. Die finale Zeile 136 trägt kein `ADR-\d{4}`-Muster mehr
   (`grep -n 'ADR-[0-9]' MR-073-…md` → nur die eine legitime `[ADR-0070](...)`-Verlinkung, Status
   `Accepted`, unproblematisch für `matrix`).
4. **Pflichtfelder der Ziel-Form geprüft.** Gegen
   `.harness/baseline/v6.9.0/templates/harness/conventions/MR-NNN-titel.template.md`: Pflicht sind
   Datum, Geltungsbereich, Ersetzt-Baseline-Regel, Adaption, Begründung, Auflösungs-Trigger — alle
   sechs in MR-073 vorhanden. `Löst auf`/`Ausgelöst durch Baseline-Stand` sind laut Vorlage nur bei
   Ablösung eines früheren Eintrags Pflicht; MR-073 trägt `Ausgelöst durch Baseline-Stand: keiner`
   ohne `Löst auf` — dieselbe (etablierte) Form wie in MR-061/MR-064/MR-066/MR-068, alle vier lösen
   ebenfalls keinen Eintrag ab und tragen dasselbe Muster. Konsistent.
5. **Form gegen Vorgänger-Muster MR-068 verglichen** (beide Dateien vollständig gelesen).
   Feldreihenfolge und -struktur decken sich (Datum → Wirksamkeits-Anlass → Geltungsbereich →
   Ausgelöst durch Baseline-Stand → Ersetzt-Baseline-Regel → [slice-spezifischer Absatz] → Adaption →
   Zweck/Werkzeug-Stand → Fragment → Strenge-Bilanz → Emitter-Pin gekoppelt → [Werkzeug-Grenzen] →
   Kein ADR nötig → Was der Sprung nicht setzt → Grenze → Begründung → Auflösungs-Trigger). Der
   zusätzliche Absatz „Drei Releases in einem Sprung — bewusste Abweichung" ist slice-spezifisch neu
   und an der von der Planung verlangten Stelle (§1 der Planung verlangt genau diese Benennung, §6
   verlangt sie im Eintrag) — vorhanden, mit Verweis auf die Auftraggeber-Anweisung vom 2026-09-27
   und der ausdrücklichen Klarstellung „kein neues Prinzip für künftige Sprünge".
6. **Referenz statt Duplikat — geprüft, aber anders befunden als die Auftragsfrage suggeriert.**
   MR-073 **verweist** auf Commit `21afa8ba` („Die Messung steht im Commit `21afa8ba` […], die Werte
   hier sind von dort übernommen") **und** führt zugleich die vollständige Sonde- und Stufen-Tabelle
   im Eintrag selbst. Das ist **keine** Abweichung vom Vorgänger: MR-068 tut exakt dasselbe — es
   verweist auf den Umsetzungs-Commit `cb3bc567` und reproduziert die volle Tabelle im Eintrag. Beide
   Formen zusammen (Referenz **und** Duplikat mit Quellenangabe) sind das etablierte Muster dieser
   Pin-Linie, nicht eine Abweichung davon; die Werte sind über eine unveränderliche Commit-Message
   datiert (MR-051 Setzung 1: die Message ist „der einzige Zusage-Träger […], den nach dem Push
   niemand mehr ändern kann") und damit weniger drift-anfällig als ein reiner Verweis ohne Zahlen.
   **Kein Befund.** (Auffällig, aber nicht normativ bindend: Der Implementer-Commit `21afa8ba`
   kündigt selbst an, die Bilanz werde „nicht kopiert, sondern […] zurückverwiesen" — genau das
   Gegenteil dessen, was dann geschah. Das ist eine unzutreffende Ankündigung in einer Commit-Message,
   aber keine Norm-Verletzung: Kein Plan-, ADR- oder Hard-Rule-Text verlangt reine Referenz ohne
   Zahlen, und die tatsächliche Form folgt korrekt dem Vorgänger-Muster.)
7. **Baseline-Zeile geprüft.** `harness/conventions.md` §Baseline enthält keine `d-check:`-Zeile
   (real gelesen) — MR-073 begründet das ausdrücklich mit MR-070 („der Zustand steht am Ort des
   Gegenstands"), zieht sie korrekt **nicht** nach. Konsistent mit dem Bestand.
8. **Commit-Zuschnitt (§3.8) geprüft.** `git show --stat 21b45388` → zwei Dateien
   (`harness/conventions.md`, die neue MR-073-Datei), beide Architect-Artefakte; `git show --stat
   5fe0107d` → eine Datei (dieselbe MR-073-Datei). Beide Messages beginnen mit „Rolle Architect:".
   `git show --stat 21afa8ba` → keine Datei (leerer Commit, `--allow-empty`), Message beginnt mit
   „Rolle Implementer:". Alle drei konform mit §3.8/§3.10 (Rollentrennung, Commit-Zuschnitt).
9. **Gates-Stempel gegengeprüft, nicht neu gebaut.** `cat .harness/state/gates-passed.diffsha` →
   `b84a1aab4dc9ea33226caae20e3cdcb9dfe4429eed29f4da723bd01ff9907831`; `bash
   harness/tools/working-tree-hash.sh` auf dem aktuellen Arbeitsbaum (HEAD `5fe0107d`) → derselbe
   Wert. `make gates` war also über genau diesem Endstand grün; nicht erneut gefahren (Auftrag).
10. **Fremde Commits außerhalb des Gegenstands geprüft.** `git show --stat 8d19b229` und `git show
    --stat 12ef6e6b` berühren ausschließlich `docs/plan/planning/next/slice-mutate-form-match-epipe-
    verwirft-treffer.md` — nicht den hier geprüften Slice, nicht `harness/conventions*`. Kein
    Überlapp.

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-2 | MEDIUM | Die „Quell-Differenz bestätigt den Schluss"-Aussage in Commit `21afa8ba` und wortgleich in `MR-073` Zeile 162–167 behauptet, zwischen `v0.77.0` und `v0.79.0` bewege sich an den neun aktiven Modulen „nur" `markdown.go` und `structure.go`. Real nachgefahren (`git diff --numstat v0.77.0..v0.79.0 -- internal/hexagon/core/rules/` am Werkzeug-Klon) bewegt sich zusätzlich `anchors.go` (+3/-0, eine Regeldatei des aktiven Moduls `anchors`) — nicht in der Aufzählung genannt. Inhaltlich harmlos (Ausnahme, keine neue Prüfung; die empirische Gegenmessung bleibt byte-identisch und unberührt), aber die Mengen-Aussage selbst ist falsch. | `AGENTS.md` §3.6/§3.7 (Zusage misst die tatsächliche Menge, kein Kommentar/Text ohne Deckung); Reviewer-Kultur „Menge erst messen" | `harness/conventions/MR-073-…md:162-167`; Commit `21afa8ba` (Message) | ja — `git -C /Development/d-check diff --numstat v0.77.0..v0.79.0 -- internal/hexagon/core/rules/` zeigt `anchors.go` in der Liste | Quell-Differenz-Aussage nennt eine Datei-Menge als abschließend, die ein Gegen-`diff` widerlegt |

Kein HIGH gefunden: keine ADR-/Hard-Rule-Verletzung, keine Gate-Lockerung ohne ADR (die zwei
`links`-Erweiterungen sind Verschärfungen, korrekt ohne ADR begründet), kein stilles Grün (die
empirische Strenge-Bilanz selbst — der eigentliche Beleg für „keine Senkung" — ist vollständig und
unberührt von F-2), kein halluzininiertes Gate, keine Referenz auf eine superseded ADR (die
Zeile-136-Lösung vermeidet genau das), keine Norm nur im Template-Kommentar, kein Kommentar ohne
Kommentar-Klasse, kein Zustandsfeld mit Chronik, kein Commit-Zuschnitt-Verstoß (§3.8).

**F-1 (vorherige Runde): geschlossen.** Alle neun aktiven Module tragen jetzt eine dedizierte,
nicht-triviale Sonde mit byte-identischem Befund über beide Digests; die Zahlen sind im Commit
`21afa8ba` nachprüfbar und in `MR-073` korrekt übernommen (Punkt 1/6 oben).

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Vollständigkeit der Strenge-Bilanz (9/9 Module) | geprüft, ohne Befund — F-1 geschlossen (s. o.) |
| Sonde je der vier neuen Module (matrix, spans, planning, targets) | geprüft (Grund-Code-Plausibilität, Summenprobe der Befund-Verteilung), ohne Befund |
| Quell-Differenz-Aussage | geprüft, **mit Befund** (F-2) |
| Zeile-136-Lösung gegen `.d-check.yml` `ids:`/`matrix:` | geprüft, ohne Befund — Kausalkette an der Config selbst nachvollzogen |
| Pflichtfelder der Ziel-Form | geprüft, ohne Befund — alle sechs Pflichtfelder vorhanden, `Löst auf`/`Ausgelöst durch` korrekt weggelassen |
| Formvergleich mit MR-068 | geprüft, ohne Befund — Struktur deckungsgleich |
| Referenz vs. Duplikat der Strenge-Bilanz | geprüft, ohne Befund — Duplikat-mit-Quellenangabe ist das etablierte Muster, keine Abweichung |
| §Baseline-Zeile `d-check:` | geprüft, ohne Befund — korrekt nicht nachgezogen (MR-070) |
| Commit-Zuschnitt §3.8 (`21b45388`, `5fe0107d`, `21afa8ba`) | geprüft, ohne Befund — nur Architect- bzw. Implementer-Artefakte, Rolle in jeder Message |
| Gates-Stempel gegen Arbeitsbaum-Hash | geprüft, ohne Befund — deckungsgleich, nicht neu gebaut (Auftrag) |
| Zwei fremde Commits (`8d19b229`, `12ef6e6b`) | geprüft, ohne Befund — unabhängiger Slice, kein Überlapp mit dem Gegenstand |
| Mutations-Deckung (`make mutate`) | nicht gefahren — kein neuer Wächter/Test in diesem Diff |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 0 |
| INFO | 0 |

**Finding-Klassen dieses Laufs:** Quell-Differenz-Aussage nennt eine Datei-Menge als abschließend,
die ein Gegen-`diff` widerlegt

## Verdikt

**F-1 gilt als geschlossen.** Die vollständige MR-063-Strenge-Bilanz (9 von 9 aktiven Modulen,
byte-identisch über beide Digests) liegt jetzt im Umsetzungs-Commit `21afa8ba` **und** im
Adaptions-Eintrag `MR-073` vor — der Kern der in der ersten Runde bemängelten Lücke ist behoben.

**MR-073 ist closure-tauglich, aber nicht ohne Nachbesserung von F-2.** Das neue MEDIUM-Finding
(F-2) betrifft eine falsche Mengen-Aussage in der unterstützenden „Quell-Differenz"-Erzählung, nicht
die primäre empirische Evidenz (Gegenmessungs-Tabelle) — die trägt den Schluss „keine Senkung"
bereits eigenständig und unberührt von F-2. Ob dieses Merge-blockierend ist, hängt an der
Repo-Kultur zu Mengen-Aussagen (`AGENTS.md` §3.6/§3.7, „Menge erst messen"): Eine als abschließend
formulierte Aufzählung, die ein einziges `diff`-Kommando widerlegt, ist genau die Klasse Befund, die
dieser Prozess sonst konsequent vor Closure nachfordert. Empfehlung: Zeile 162–167 in `MR-073`
(und, soweit lokal noch änderbar, die Formulierung im Nachtrag zu `21afa8ba`) um `anchors.go`
ergänzen und die Harmlosigkeit (Ausnahme statt neuer Prüfung, keine Wirkung auf die byte-identische
Gegenmessung) explizit benennen, bevor der Eintrag gepusht wird — der Eintrag bleibt ohnehin bis zum
Review lokal (`norm-eintrag-friert-vor-seinem-review-ein`, hiermit vorliegend).

**Übergabe:** Findings gehen an den Architect (Träger von `MR-073`) bzw. den Implementer (Träger von
`21afa8ba`) — beide Artefakte sind noch lokal und damit noch änderbar. Die Finding-Klasse geht in die
Slice-Closure §7 und von dort in den Zähler. Dieser Report ist ein Lauf-Beleg und ersetzt keine
Verifikation gegen DoD/Spec (Modul 11, Verifier-Aufgabe).
