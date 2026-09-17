# Review-Report: slice-sprung-auf-v690-wird-vollzogen, Nachprüfung — 2026-09-17

**Review-Art:** Code. Nachprüfung der Nacharbeit gegen die Findings des ersten Laufs
(`docs/reviews/2026-09-16-slice-sprung-auf-v690-wird-vollzogen.md`). Neu gemeldet wird nur, was
die Nacharbeit selbst erzeugt hat.

**Gegenstand:** `git diff 7522c4c5..952aed15`, sechs Commits, zwölf Dateien.

**Skill:** `.harness/skills/reviewer.md` @ 2.0.0 · **Modell:** claude-opus-5 ·
**Datum:** 2026-09-17

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis; die `<Platzhalter>` darin sind Formbeispiele)*. Dieser
> Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link
> (`v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt>). Der vendored Baum trägt
> genau einen Tag; der Sprung löscht den alten, und ein Link darauf färbt beim
> nächsten Bump ein Artefakt rot, das niemand mehr anfassen darf. Ein `pfad`-Feld
> auf den **geprüften Gegenstand** ist davon nicht betroffen — es zitiert den
> Stand des Laufs und darf ihn festhalten (`v<X.Y.Z>` ·
> `regelwerk/grundlagen-harness-dateien.md` §harness/README.md als
> Einstiegspunkt — diese Zeile ist selbst ein Beispiel der Form).

**Eingangs-Kontext:**

- der erste Review-Report (F-1 bis F-12)
- [ADR-0056](../plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md),
  [ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 2
- `AGENTS.md` §3 (Hard Rules), dort §3.6 und §3.8; `harness/migration.md` §5
- **Setzung des Auftraggebers vom 2026-09-17** (Maßstab): Stoff darf innerhalb derselben Datei
  **wörtlich** in den Vorlagen-Abschnitt wandern, zu dem er gehört. Umformulieren ist dabei
  nicht erlaubt, ein Umzug in eine andere Datei auch nicht.
- `v6.9.0` · `templates/harness/sensors/gate.template.md`

---

## Findings

### Status der Findings aus dem ersten Lauf

| ID | Status | Beleg |
|---|---|---|
| F-1 | behoben | `5bf97553`: Der Glossar-Absatz ist **wortgleich** mit dem Stand `1aee7739` (`diff` der sieben Zeilen ist leer) und steht als Prosa unter `## Glossar (optional)`. Nach der Setzung vom 2026-09-17 ist der Umzug zulässig: dieselbe Datei, wörtlich, in den Abschnitt, zu dem der Begriff gehört. `full-smoke.md`: Der Stufen-Menge-Absatz ist in `42276db5` Zeile für Zeile gleich entfernt und wieder eingesetzt; die zwei LEITUNG/BAUM-Absätze sind nur neu eingehängt, und die Vorlage weist sie `Ausgabe` zu. Beides erlaubt die Setzung. |
| F-2 | behoben | `fcb88b9b`: Der Satz lautet jetzt nur „wird begründet aufgeteilt". Der Widerspruch zu `spec/spezifikation.md:449-453` ist weg. Der Rückbezug „Warum diese" löst weiter auf, denn die gewählte Regel steht in derselben Spec („ANTEILIG NACH TOOL-CALLS", etwa Z. 434). |
| F-3 | behoben | `267d380a`: `harness/migration.md` §5 a führt den Ausschluss der Vorlagen ohne Delta für diesen Sprung, mit Rückverweis in der Einleitung von Buchstabe a (Z. 201-202, Z. 242-249). Die Form des Berichts („nicht Gegenstand dieses Sprungs", Folge-Slice als Adresse) entspricht jetzt dem Wortlaut. Neuer Befund dazu: N-2. |
| F-4 | behoben | `3b84a873`, `952aed15`: `slice-mv.md` trennt Direktaufruf und `make` und nennt, dass der Move bei einem gescheiterten Commit schon ausgeführt ist. `history-range-guard.md` nennt für `make` Exit 2. Der Bericht nennt für `vendor-baseline` „0 oder 2". Fünf weitere Sensor-Dateien tragen denselben Satz. Die Messung aus dem ersten Lauf (`make history-range-guard` → 2, `make slice-mv` → 2) deckt die neuen Aussagen. |
| F-5 | nicht behoben, adressiert | Übergeben an den Matrix-Slice, der noch nicht angelegt ist; die Nacharbeit fügt keinen neuen Rückbezug ohne Ziel hinzu. |
| F-6 | behoben | `fcb88b9b`: §7 Historie trägt die Zeile `2026-09-17`, ohne ADR- oder Slice-Kennung (`v6.9.0` · `templates/spec/spezifikation.template.md` §7). Sie beschreibt beide Änderungen, auch die gestrichenen Beispiele. |
| F-7 | behoben | `42a2164e`: Der sortierte Zeilenvergleich alt gegen neu zeigt in beiden Dateien nur die neuen `###`-Zeilen und die Zeilen aus F-4. Der Stoff ist also wörtlich verteilt. Zuordnung je Absatz: In `slice-mv.md` tragen alle drei Teile (emittierter Vertrag · Grenze des Rumpf-Vergleichs · „Fehlt eine Voraussetzung, bewegt es nichts"). In `history-range-guard.md` tragen Vertrag und Grenze; unter Sperren trägt der Absatz zum Fragment, der Absatz zu `AdaptMK` nur mittelbar (N-4). Unter `Bindung` steht kein Stoff mehr. |
| F-8 | nicht behoben, nicht behebbar | Die Messages sind gepusht und unveränderlich; die Closure nimmt den Befund als Beobachtung. |
| F-9 | behoben | `3b84a873`: Die Sperre `vendor-baseline: keine Repo-Wurzel ueber …` passt zur Meldung im Code (`cmd/ai-harness-init/vendor_baseline.go:82` mit dem Fehlertext aus `archive_welle.go:262`); Exit 1 passt zu `vendor_baseline.go:59`. Der Bericht führt die Datei jetzt als *übernommen*. |
| F-10 | offen, beim Verifier | nicht Gegenstand der Nachprüfung |
| F-11 | unverändert (INFO) | keine Handlung verlangt |
| F-12 | unverändert (INFO) | keine Handlung verlangt |

### Neue Befunde aus der Nacharbeit

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| N-1 | LOW | Dieselbe Überschrift `### Im gebootstrappten Ziel` steht je Datei dreimal. Die Anker `im-gebootstrappten-ziel`, `-1` und `-2` hängen damit an der Reihenfolge. Die Setzung vom 2026-09-17 erlaubt gerade solche Umzüge innerhalb der Datei; ein künftiger Link auf `-2` zielte danach still auf einen anderen Unterabschnitt, und die Link-Prüfung bliebe grün. Heute verweist nichts auf diese Anker (`git grep -n 'im-gebootstrappten-ziel'` → leer). | Maintainability | `harness/sensors/slice-mv.md:13`, `:76`, `:115`; `harness/sensors/history-range-guard.md:18`, `:54`, `:90` | nein — der Anker bleibt formal gültig | Gleichlautende Überschriften machen den Anker von der Reihenfolge abhängig |
| N-2 | LOW | Die Einleitung von §5 nimmt „**den** sprung-bezogenen Absatz am Ende von Buchstabe a" aus, der ADR-0056 §Konsequenzen abbildet. Seit `267d380a` gibt es zwei sprung-bezogene Absätze. Am Ende steht jetzt der neue, der sich auf die Setzung des Auftraggebers stützt. Der Absatz, der ADR-0056 abbildet, ist nicht mehr der letzte und fällt damit aus der Ausnahme, wenn man sie nach der Lage liest. | Maintainability; ADR-0056 §Kopplung (§5 a projiziert die Entscheidung) | `harness/migration.md:192-193` gegen `:234`, `:242` | nein | Ausnahme nach Lage adressiert, Menge hat sich geändert |
| N-3 | LOW | Laut Befund-Satz des Berichts bekamen „vierzehn der fünfzehn Sensor-Dateien einen Abschnitt oder eine neue Ebene". `vendor-baseline.md` bekam weder das eine noch das andere, nur einen Eintrag unter `Sperren`. Die Überschriften sind unverändert `Vertrag · Grenze · Sperren · Bindung`, also trifft die Aussage auf dreizehn zu. Die Tabellenzeile „vierzehn Dateien übernommen" ist richtig. | `AGENTS.md` §3.6; `MR-025` | `docs/migrations/v6.9.0.md:174` | ja — `awk '/^## /' harness/sensors/vendor-baseline.md` vor und nach `3b84a873` | Zahl übernimmt das Prädikat einer Nachbarzahl |
| N-4 | INFO | Unter `## Sperren` / `### Im gebootstrappten Ziel` beschreibt der Absatz „Die Emission prüft die Voraussetzung der Bindung" einen Abbruch des **Bootstrap**-Laufs (`AdaptMK`), nicht des Wächter-Laufs. Die Vorlage nennt für `Sperren` die Abbrüche „des Laufs". Die Zuordnung trägt deshalb nur mittelbar; wörtlich ist der Absatz geblieben. | `v6.9.0` · `templates/harness/sensors/gate.template.md` §Sperren | `harness/sensors/history-range-guard.md:102` | nein | Abbruch eines anderen Laufs unter Sperren |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Commit-Zuschnitt je Rolle (`AGENTS.md` §3.8) | `5bf97553` und `267d380a` (Architect) berühren nur `harness/conventions.md` bzw. `harness/migration.md`. Die vier Implementer-Commits berühren nur Sensor-Dateien, die Spezifikation und den Bericht. Keine ADR und keine Closure ist berührt. Geprüft, ohne Befund |
| Wörtlichkeit der Umzüge (Setzung vom 2026-09-17) | `diff <(git show 7522c4c5:<f> \| sort) <(git show 952aed15:<f> \| sort)` für `slice-mv.md` und `history-range-guard.md`: Außer den neuen Überschriften unterscheiden sich nur die Zeilen aus F-4; keine Datei-übergreifende Verschiebung. Geprüft, ohne Befund |
| `##`-Gliederung der zwei Dateien | `Vertrag · Grenze · Ausgabe und Ausgänge · Sperren · Bindung`, in der Reihenfolge der Vorlage. Geprüft, ohne Befund |
| Exit-Sätze in `comment-claims.md`, `full-smoke.md`, `hook-overhead.md`, `mutate.md`, `span-report.md` | Jeder Satz unterscheidet Skript und `make`, und `make` meldet 2. Geprüft, ohne Befund |
| Bericht `docs/migrations/v6.9.0.md` (`952aed15`) | Die Zeilen je Datei nennen die neuen Commits. Die Zeile `smoke.md` begründet mit `make` → 2, die Zeile `vendor-baseline.md` mit 0 oder 2. Der Satz „Zwei Stellen sind durch die Lage bestimmt" ist ersetzt. Geprüft, ohne Befund außer N-3 |
| `spec/spezifikation.md` (`fcb88b9b`) | außerhalb der zwei Stellen unverändert; die Historie-Zeile ohne Kennung. Geprüft, ohne Befund |

## Summary

| Kategorie | Anzahl (neu) |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 3 |
| INFO | 1 |

**Status des ersten Laufs:** behoben 7 (F-1, F-2, F-3, F-4, F-6, F-7, F-9) · adressiert 1 (F-5) ·
nicht behebbar 1 (F-8) · beim Verifier 1 (F-10) · INFO ohne Handlung 2 (F-11, F-12).

**Finding-Klassen dieses Laufs:** Gleichlautende Überschriften machen den Anker von der Reihenfolge
abhängig · Ausnahme nach Lage adressiert, Menge hat sich geändert · Zahl übernimmt das Prädikat
einer Nachbarzahl

## Verdikt

**Bereit für Verifier und Closure.**

**Merge-blockierend:** nein. Alle vier MEDIUM des ersten Laufs sind behoben. Die Nacharbeit
erzeugt kein HIGH und kein MEDIUM.

**Übergabe:**

- N-1 und N-3 gehen an den Implementer.
- N-2 geht an den Architect.
- N-4 ist nur ein Hinweis.
- Keiner dieser Punkte verschiebt eine Abnahme.
- F-5 geht an den Matrix-Slice, F-8 an die Closure-Beobachtung, F-10 an den Verifier.
- Die Finding-Klassen gehen in die Slice-Closure §7.
