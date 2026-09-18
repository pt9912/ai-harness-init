# Review-Report: `slice-das-ziel-sagt-was-sein-vendored-baum-ist` — 2026-09-18, Runde 2

**Review-Art:** Code — geprüft gegen Slice-Plan, aktive ADRs und die Hard Rules
(`v6.9.0` · `regelwerk/modul-10-review-harness.md` §Drei Review-Arten). **Keine**
DoD-Abhakung: die prüft der Verifier.

**Gegenstand:** `git diff 872170f4..0b891130` — die drei Commits `d47c7c57`, `3b7d7baa`,
`0b891130`, gegen die acht Findings aus Runde 1 (`docs/reviews/`, Report vom 2026-09-18).

**Skill:** `.harness/skills/reviewer.md` @ 2.0.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5 · **Datum:** 2026-09-18

**Eingangs-Kontext:** der Slice-Plan (§1, §4, §6) · `ADR-0022` (Accepted, Festlegung 5 und 7)
· `ADR-0054` (Accepted) · `LH-FA-09`, `LH-QA-01`, `LH-QA-02`, `LH-QA-03` · `MR-025`, `MR-033`,
`MR-053` · `AGENTS.md` §3.2, §3.6, §3.7, §3.8 · der Report aus Runde 1.

---

## 1. Stand der Findings aus Runde 1

| ID | Runde 1 | Stand | Beleg dieses Laufs |
|---|---|---|---|
| F-1 | HIGH | **erledigt** | Leerzeile bei `:140`, der neue Kommentar `:141-158` über `baum_aussagen_im_ziel()` `:159`, der Rollen-Typen-Block `:218-237` wieder unmittelbar über `rollen_typen_im_ziel()` `:238`. Jeder der zwei Blöcke beschreibt jetzt die Stelle, an der er liegt. |
| F-2 | HIGH | **erledigt** | Der Satz nennt **ein** Doku-Gate und die Stelle, die den Ausschluss trägt: *„vom Doku-Gate ausgenommen — `scan.ignore` in `.d-check.yml` nennt ihn."* Das emittierte `.d-check.yml` führt `ignore: [… ".harness/**"]`; die Aussage stimmt am Stand des Adopters. Siehe R2-2 für eine Rest-Beobachtung an der Gegenstelle. |
| F-3 | MEDIUM | **erledigt** | Die Zelle trennt das Unbedingte (`harness/mk/erfassung.mk` mit `span-report`/`span-clean`) von der Bedingung und benennt die vier Artefakte, die nur im Gelingens-Zweig entstehen. Im Code belegt: `internal/emit/enforce.go:301` (`if !captured { return nil }`) deckt `captureFiles()` **und** `FieldList(targetDir)` `:319`; `ADR-0022` Zeile 729 sagt dasselbe (*„Die Feldliste entsteht mit dem Träger … und teilt darum seinen Zweig"*). Die Zitierung von Festlegung 7 trägt. |
| F-4 | MEDIUM | **erledigt** | Der Zeiger nennt die Release-Übersicht des Repos, aus dem das Asset stammt, und sagt ausdrücklich, dass die Asset-URL selbst es nicht ist. Die Asset-URL steht im emittierten Abschnitt unverändert (bare URL, von `NeutralizePlaceholderLinks` nicht berührt) — die Ableitung ist damit am Dokument vollziehbar, und die falsche Behauptung ist weg. |
| F-5 | MEDIUM | **erledigt, Rest als R2-1 und INFO** | siehe §2. |
| F-6 | MEDIUM | **erledigt** | `test/mutations/367`, `# verify: full-smoke`; der Operand trifft `harness/tools/full-smoke.sh:1784` (belegt in `0b891130` mit `git diff --numstat` → `1 1`) und nur diese Zeile — der erste Aufruf trägt ein anderes Argument. Die Ausgabe in `d47c7c57` zeigt beides: die Erfolgszeile des **ersten** Aufrufs (`--lang go`, 26 Regelblöcke) und danach `full-smoke: FEHLER — sprachlos: harness/conventions.md fehlt im Ziel`. Damit ist die Frage beantwortet: der erste läuft grün durch, der zweite fällt. |
| F-7 | LOW | offen, unverändert | Plan §3 ist Planner-Artefakt; kein Gegenstand dieses Diffs. |
| F-8 | INFO | offen, unverändert | `docs/user/e2e-abdeckung.md` brauchte keine Regeneration: der verschobene Block liegt vollständig vor `:238`, die Stufen-Deklarationen liegen dahinter, und `make gates` (mit `test/e2e-abdeckung.bats`) ist grün. |

**Zur Mechanik von 367 und 368.** Bei gesetztem `# verify:` benutzt `harness/tools/mutate.sh`
die `# expect:`-Zeile nur als Vollständigkeits- und Berichtsfeld; das Fehlschlag-Muster kommt
aus `failure_form` (`full-smoke: FEHLER` bzw. `--- FAIL:`). Die Freitext-`expect`-Zeile von 367
entspricht damit dem Zuschnitt von `332` und `305`, und die beobachtete Meldung trifft das
Muster. 368 trifft die reale Zeile `internal/emit/baumaussage.go:36` und färbt genau den
benannten Test rot; die gelesene Ausgabe steht in `3b7d7baa`. Die SC2016-Korrektur in
`0b891130` lässt die getroffene Zeile unverändert und nimmt keine Inline-Suppression
(`AGENTS.md` §3.2).

## 2. F-5 — trägt das Urteil des Implementers?

**Ja, ich gebe meinen Befund auf.** Geprüft habe ich die drei Gründe einzeln:

1. *Die Namensliste ist nicht ersetzbar, ohne den Gegenstand zu verlieren.* Trägt — §1 des
   Plans schließt den automatischen Träger-Regel-Abgleich als **anderen Vorgang** aus, und ohne
   Namen gäbe es keine Inventur. Ein Reviewer, der hier auf Ersatz bestünde, forderte einen
   anderen Slice.
2. *Quell-seitig ist die Drift bewacht.* Trägt — `test/baum-inventur.bats` hält beide
   Richtungen gegen den vendored Baum, und `TestInventurMessTag_IstDerGefetchteStand` koppelt
   den Mess-Stand fail-closed an `fetch.DefaultTag` (`internal/emit/baumaussage.go:36` gegen
   `internal/fetch/baseline.go:48`), mit Mutation 368 als Zahn.
3. *Die Rest-Lücke ist die generische Eigenschaft jedes skip-if-present-Dokuments.* Trägt —
   die Klasse entsteht in `internal/emit/templates.go:304-313` und gilt für jedes
   Adopter-Boden-Dokument mit abgeleitetem Inhalt, nicht für diese Tabelle.

Entscheidend ist der vierte Punkt, den der Diff hinzufügt und den mein Befund verlangt hatte:
Die **Grenze steht jetzt an der Stelle, an der die Behauptung steht** — der emittierte Block
sagt dem Adopter, gegen welchen Stand gemessen ist, dass die Tabelle nicht mitwandert, dass ein
erneuter Bootstrap das Dokument nicht überschreibt und dass kein Lauf sie gegen den liegenden
Baum hält, samt dem Kommando, mit dem er selbst nachzählt. Beide Sätze sind am Stand des
Adopters wahr. Damit ist die Drift **erkennbar statt unsichtbar**, und genau das trennt eine
bewohnbare Zusage von einer Harness-Lüge (`v6.9.0` · `regelwerk/modul-13-quality-gates.md`
§Hard Rule (Doku-Disziplin): *„Ein Gate ohne seine Grenze behauptet ebenfalls zu viel"*).
Das Nicht-Anhalten war richtig: §4 reserviert die Rückführung `in-progress → open` für eine
Zelle, die einen Wert ohne angenommene ADR verlangt — dieser Fall lag nicht vor.

## 3. Findings dieser Runde

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| R2-1 | LOW | Mit `InventurMessTag` trägt eine sechste Stelle im Repo den Baseline-Tag, fail-closed gekoppelt und in `make gates` laufend. Der Absatz über die Provenienz-Kette zählt „Fünf Stellen", nennt die vier gekoppelten und die drei Tests, die sie halten — die neue Stelle und ihr Test stehen dort nicht. Wer dem Absatz beim nächsten Sprung als Checkliste folgt, bekommt ein Rot, dessen Adresse das Register nicht führt. Die engere Lesart („Stellen, die Tag **samt sha256** pinnen") schließt die neue aus; welche gilt, entscheidet der Eigentümer der Datei — `harness/conventions.md` schreibt der Architect (`AGENTS.md` §3.8), nicht dieser Lauf. | `MR-053` · `AGENTS.md` §3.8 | `harness/conventions.md:104-112` gegen `internal/emit/baumaussage.go:36` | ja — der nächste Baseline-Sprung; kein Gate hält den Absatz gegen die Menge der Tag-Stellen | Register der Pin-Stellen zählt eine neu entstandene nicht mit |
| R2-2 | INFO | Der neue Satz stützt sich auf `scan.ignore` der emittierten `.d-check.yml`. Dort steht der Ausschluss als `.harness/**` mit der Begründung *„tool-interne Ablage (gefetchtes Sprachskelett-Staging) — keine Adopter-Doku"*; der vendored Baum kommt in dieser Begründung nicht vor. Ein Adopter, der die Begründung als vollständig liest und den Glob auf das Staging verengt, nimmt den Ausschluss weg, auf den der Satz sich beruft. | Maintainability | `internal/emit/templates/d-check.yml:7-9` gegen `internal/emit/baumaussage.go:213` | nein | Zwei emittierte Artefakte tragen zur selben Zusage verschiedene Gründe |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| `AGENTS.md` §3.7 in den neuen und geänderten Kommentaren | geprüft, ohne Befund — der `InventurMessTag`-Kommentar trägt Zusage plus Sensor-Namen, der geänderte `emittierteKernpfade`-Kommentar beschreibt die Menge, die da ist; kein Lauf-Protokoll, keine verworfene Alternative, kein abwesender Text |
| `MR-025` / `MR-033` im Diff und in den Commit-Messages | geprüft, ohne Befund — keine eingefrorene Zahl im emittierten Text; die `26` steht in beiden Messages neben ihrem Kommando und ist als mitwandernd gekennzeichnet; der Mess-Stand `v6.9.0` steht als Bezugspunkt und ist gekoppelt |
| `MR-053` (lebender Pin nicht in zweiter Fassung) | geprüft, ohne Befund am Gegenstand der Regel — der Adaptions-Block führt keine zweite Fassung des Pins; die Buchhaltungs-Folge steht als R2-1 |
| Emittierter Datei-Satz | geprüft, ohne Befund — kein neuer Ziel-Pfad; der Diff berührt keine Pfad-Liste |
| `full-smoke`-Stufe nach dem Umbau | geprüft, ohne Befund — Funktionskörper unverändert, nur verschoben; beide Aufrufe (`:363`, `:1784`) stehen unverändert mit ihren eigenen Zielen |
| Neue Absätze des emittierten Blocks gegen `NeutralizeMakeClaims` | geprüft, ohne Befund — kein neuer `make`-Name; die fail-closed-Kante bleibt unberührt |
| Wahrheit der neuen Grenz-Sätze am Adopter-Stand | geprüft, ohne Befund — „wird von einem erneuten Bootstrap nicht überschrieben" (skip-if-present, `templates.go:310`) und „kein Lauf dieses Repos hält die Tabelle gegen den Baum" (keine solche Prüfung im emittierten Satz) sind beide zutreffend |
| Mutations-Fälle 367 und 368 | geprüft, ohne Befund — beide Operanden treffen genau eine reale Zeile, beide Fehlschlag-Muster sind durch `failure_form` gedeckt, beide Rot-Ausgaben sind gelesen und in der Message zitiert |
| Gate-Lockerung, Suppression | geprüft, ohne Befund — kein Modul abgeschaltet, keine Schwelle gesenkt, keine `nolint`/`shellcheck disable`-Zeile; `0b891130` löst SC2016 durch Umschreiben statt Unterdrücken |
| §1-Abgrenzung nach den Korrekturen | geprüft, ohne Befund — alle fünf Ausschlüsse weiter gewahrt; insbesondere entsteht kein Sensor, der Träger und Regel automatisch abbildet |
| Plan-Verweise in den Mutations-Kommentaren | geprüft, ohne Befund — dieselbe Form wie in Runde 1 unbeanstandet (Zweck-Aussage im Indikativ, keine Kennung als Beleg); keine Eskalation |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** Register der Pin-Stellen zählt eine neu entstandene nicht mit ·
Zwei emittierte Artefakte tragen zur selben Zusage verschiedene Gründe

Aus Runde 1 bleiben offen: *Plan-Tabelle führt die berührte Datei nicht* (F-7, Planner) und
*Erzeugte Abdeckungs-Sicht führt den neuen Zahn nicht* (F-8, INFO).

## Verdikt

**Merge-blockierend: nein.** Beide HIGH und alle vier MEDIUM aus Runde 1 sind erledigt, je mit
gelesenem Beleg; R2-1 ist eine Registerpflege in einem Architect-Artefakt und blockiert den
Slice nicht, R2-2 ist eine Notiz.

**Der Weg zu Verifikation und Closure ist frei.** Zwei Übergaben gehen neben dem Slice her:
R2-1 an den **Architect** (`harness/conventions.md` §Adoptierte Konventions-Quellen, Zählung und
Test-Liste der Tag-Stellen) und die Klassenfrage aus F-5 ebenfalls an den Architect — ob ein
emittiertes skip-if-present-Dokument abgeleitete Namenslisten tragen darf und woran ihre Grenze
hängt; beide sind Fragen über die Klasse, nicht über diese Tabelle, und keine ist eine
Bedingung dieses Slice. F-7 und F-8 gehören in die Closure-Runde des Planners.

**Übergabe:** Findings an den Implementer bzw. die genannten Rollen; die Finding-Klassen gehen
in die Slice-Closure §7 und von dort in den Zähler. Dieser Report ist Lauf-Beleg und ersetzt
keine Verifikation.
