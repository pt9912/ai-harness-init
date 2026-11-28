# Review-Report: slice-altbestand-stubs-voll-v1 — 2026-11-28

**Review-Art:** Code — geprüft gegen den Slice-Plan
(`slice-altbestand-stubs-voll-v1`) und ADR-0112 (nicht gegen DoD — Verifier,
Modul 11).

**Gegenstand:** der Implementer-Zug des Slices — Commits `a95c6fcd` (LPa:
Differenzial, Umzugs-Stub-Write, `FormOKUmzug`, `ZuStagen`), `9f955675` (LPb:
Umzugs-Stub-Vorlage + Emissions-Kopie + bats-Kopplung), `a585983e` (LPc:
`UmzugsFunde`/`UmzugsStubs` in `vorschau.go`, Sensor-Doku), `b1f12b9a`
(Anlage 828 zum Berührt-Anker umgeankert), `5af1ad5c` (id-unlinked-Nachzug am
Sensor-Text). Range-Prüfung `a95c6fcd^..5af1ad5c`, Einzelfiles gegen die
Zwei-Parallel-Züge gehalten.

**Skill:** `.harness/skills/reviewer.md` @ v2.3.0 ·
**Modell:** claude (glm-5.3-flash) · **Datum:** 2026-11-28

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis; die `<Platzhalter>` darin sind Formbeispiele)*. Dieser
> Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link
> (`v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt>). Der vendored Baum trägt
> genau einen Tag; der Sprung löscht den alten, und ein Link darauf färbt beim
> nächsten Bump ein Artefakt rot, das niemand mehr anfassen darf. Ein
> `pfad`-Feld auf den **geprüften Gegenstand** ist davon nicht betroffen.

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Slice-Plan `slice-altbestand-stubs-voll-v1` (in-progress, Stand 2026-11-28)
- ADR-0112 (`Accepted`, Festlegungen 1–4, §Fitness Function) · ADR-0061
  (Formel Festlegung 1, Form-Präzedenz Festlegung 2) · ADR-0042 (Festlegungen
  1–4 unverändert) · ADR-0033 (Abnahme-Kriterien 1 und 2) · ADR-0041
- `AGENTS.md` §3 (Hard Rules, insbesondere §3.4, §3.5, §3.7) ·
  `LH-QA-01` · MR-071/MR-090 (Anlage-Disziplin) · MR-072 (Report-Klasse,
  unverändert)
- vorherige Findings am Modul: die Reports unter `docs/reviews/2026-11-27-*`
  und `docs/reviews/2026-11-28-slice-report-stub-am-unveraenderten-pfad.md`

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | LOW | Der Kommentar nennt als führende Funktion `ReferenzierteUmzuege` (schreibender Lauf) — eine solche Kennung existiert nicht; die Funktion heißt `referenzierteUmzuege` (unexportiert). Ein Leser, der dem Namen folgt, findet nichts. | AGENTS.md §3.7 | `internal/archive/scan.go` (Kommentar zu `SuchraumDifferenzial`, „fuehrt ReferenzierteUmzuege (schreibender Lauf)“) | nein — kein Gate liest Funktionsnamen in Kommentaren | Kommentar benennt eine nicht existierende Kennung |
| F-2 | LOW | Der Fall-Kopf verweist für die Messung des Schreiber-Zugs auf Fall 822 — `test/mutations/822-push-main-gates-erzwungen-voll.sh` misst eine andere Sache (push-gates-Verdrahtung); der Schreiber-Zug des Umzugs-Stubs misst die Anlage 826. Der nächste Lauf, der dem Verweis folgt, liest den falschen Sensor. | MR-071 · MR-090 (Anlage-Disziplin der Fall-Köpfe) | `test/mutations/827-archive-welle-go-umzug-funde-verdrahtung.sh` („den Schreiber der Stubs — den misst 822“) | nein — kein Gate hält Fall-Kopf-Quer-Verweise auf andere Fälle | Falscher Fall-Anker im Mutations-Fall-Kopf |
| F-3 | LOW | Die Funde-Zeile der Vorschau (`UmzugsFunde` über `Haenger`/`treffer`) und die Stub-Menge des schreibenden Laufs (`referenzierteUmzuege` über `zieleTrifft`) sind zwei getrennte Traversierungen desselben Kriteriums; kein Test hält ihre Gleichheit am Lauf. Weicht eine Fassung ab (etwa eine Verankerung der Treffer-Form in nur einer), meldet die Vorprüfung eine Stub-Menge, die der Lauf nicht schreibt — still, ohne Rot. | Maintainability (neuer öffentlicher Vertrag, ADR-0112 Festlegung 3) | `internal/archive/vorschau.go` (`UmzugsFunde`) · `internal/archive/anwenden.go` (`referenzierteUmzuege`) | nein — kein Gate fängt die Abweichung; 826 und 827 binden je Fassung einzeln, keine bindet beide zusammen | Funde-Zeile und Stub-Menge führen dasselbe Kriterium doppelt ohne Gleichheits-Bindung |
| F-4 | INFO | Die Containment-Form der Stub-Auslösung prüft den Basename ohne Grenze davor und danach (`strings.Contains`); ein gleichlautender Name im Fließtext (etwa `slice-100-a.md.alt` in einer ADR) löst einen Umzugs-Stub aus. Die Richtung ist die fail-closed-sichere und ist im Code als GRENZE benannt — bewusste Designnotiz. Sonde gelesen, nicht gefahren (kein Test fährt den Gegenfall). | Maintainability | `internal/archive/scan.go` (`zieleTrifft`, „GRENZE: gefunden wird der BASENAME als Teilzeichenkette“ in `schreibeUmzugStubs`) | nein — kein Gate fährt den Grenz-Fall | Containment-Grenze des Stub-Kriteriums benannt, nicht gefahren |
| F-5 | INFO | Die Form-Prüfung des Umzugs-Stubs hält den Zeiger per Teilzeichenkette (`done/`) — ein stehen gebliebener Platzhalter `done/<wave-id>/<pfad-im-arbeitsbaum>` enthält dieselbe Teilzeichenkette und besteht die Form; der Stub würde mit Platzhalter committet. Die Grenze ist im bats-Kopf der Vorlagen-Kopplung als GRENZE benannt („geprüft wird die Richtung Code → Vorlage“); sie überträgt sich vom Bestand (FormOK/`archive.zip`) unverändert auf die neue Klasse. | Maintainability | `internal/archive/stub.go` (`FormOKUmzug`, `fehlt = … doneName+"/"`) | nein — kein Gate schreibt einen Stub mit verletztem Platzhalter | Zeiger-Form hält Teilzeichenkette statt aufgelöster Adresse |

**Zu den Formen-Fahrten des Reviewer-Skills (LOW/INFO-Eskalation):** die
Containment-Grenze (F-4) und die Zeiger-Form (F-5) sind gelesen und aus der
Form gefolgt; die Grenz-Sonden selbst (fremder Wert, unreplatzter Platzhalter
als committeter Stub) sind nicht als Test gefahren — der Probe-Aufwand an
einem Kopie-Baum stand gegen den Budgetrahmen des Laufs, beide Stellen
benennen ihre Grenze im Code selbst.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Differenzial-Kriterium je ADR-0112 Festlegung 1 (`internal/archive/scan.go` `SuchraumDifferenzial`) | geprüft, ohne Befund — exakt `Suchraum \ SuchraumNachzug` (Ausnahmen-Basis bleibt drin, `docs/plan/adr` fällt); ein vierter ausgenommener Baum trägt das Kriterium ohne neuen Entscheid (Containment an `AusgenommenNachzug`); Anlage 826 färbt `TestAnwendenSchreibtDenUmzugsStubAnDerFlachenAdresse` rot (gefahren, s. u.) |
| Die drei realen ADR-Fundstellen (ADR-0061 eine, ADR-0071 zwei, ADR-0100 zwei) | geprüft, ohne Befund — Zeilen gegen die Dateien belegt (0061 → `slice-216`; 0071 Zeilen 49/132 → `slice-109`; 0100 Zeilen 36/120 → `slice-d-check-sprung-v0930`); die ADR-Datei bleibt nach dem Lauf unangetastet (Test-Sonde im Wächter) und der Verweis löst am Stub der Alt-Adresse weiter auf |
| Reihen-Fassung: Write vor dem Nachziehen (Anlage 828) | geprüft, ohne Befund — am `inhaltsSchritt`-Weg liegt `schreibeUmzugsStubs` vor `Nachziehen`, und Anlage 828 (nach dem Umanken in `b1f12b9a`, am berührt-Anker) färbt `TestUmzugsStubVorDemNachziehenGesehen` rot; der Verweis-Übertrag geht je H1-Form durch die Nachzugs-Regex (`(^|[^A-Za-z0-9_-])done/<base>`) |
| `[haenger]`-Sperre bleibt auf ihrer Rolle | geprüft, ohne Befund — die `sperren()`-Form ist im Zug unberührt; der Wächter hält die Sperre für die Klasse leer (der schreibende Lauf trägt die Pflicht) bei gleichzeitiger Funde-Zeile je verweisender ADR-Datei und ausgeschriebener Leere; 827 färbt rot, die Leere ist über `TestVorschauSagtKeinenUmzugsStubOhneReferenz` behalten |
| §3.5-Fall (Gate-Lockerung, `ignore-refs`, `.gitignore`) | geprüft, ohne Befund — `.d-check.yml` und `.gitignore` ohne Änderung über den ganzen Zug (`git diff --stat` leer); die zwei ADR-0039/ADR-0042-Paare stehen unverändert; die drei Gegenformen bleiben benannt, nicht geschlossen (kein Sensor, je ADR-0112 Festlegung 4) |
| Fremd-Datei-Freiheit gegen die Parallel-Züge | geprüft, ohne Befund — `git show --name-only` je Commit: der ci-stempel-Zug berührt allein `harness/tools/working-tree-hash.sh`, der Zug dieses Slice allein `internal/archive/**`, `docs/plan/planning/archive-stub-umzug.template.md`, die Emissions-Kopie, `test/archiv-stub-vorlagen.bats`, `test/mutations/825–828`, `harness/sensors/archive-welle.md` und `cmd/ai-harness-init/kennungen_test.go` — keine Überschneidung |
| ADR-0016-Verweis (2 Fundstellen, Code-Span) | geprüft, ohne Befund am Code — das Kriterium löst Link- und Code-Span-Form identisch über Containment (keine Stub-Verwechslung je Code-Span); **Hinweis für die Verifikation:** die zwei ADR-0042-Festlegung-3-Paare für die ADR-0016-Quelle stehen noch NICHT in `.d-check.yml` — sie trägt der Lauf, der den Move vollzieht (ADR-0042 Festlegung 3, „eingetragen von dem Lauf, nicht vorher“); der Umzugs-Stub löst die zwei Adressen zugleich wieder lebend |
| LPb Vorlage + Emissions-Kopie + bats-Kopplung | geprüft, ohne Befund — Emissions-Kopie byte-gleich (`cmp`, gemessen), Form je Festlegung 2 (H1, Umzugs-Zeiger, Zustand, kein `##`-Glied, kein Archiv-Zeiger), die Kopplung je Block aufgelöst (`ARCHIV_BLOECKE` gegen `stubVorlageUmzug` mit eigenem Testsatz), `kennungen_test.go` erlaubt ADR-0061/ADR-0112 für die Vorlage |
| Sensor-Doku des Archivierungslaufs (`harness/sensors/archive-welle.md`) | geprüft, ohne Befund — Umzugs-Stub-Klasse und Funde-Zeile nachgezogen; `5af1ad5c` löst die id-unlinked-Nennung der ADR-0061 (docs-check-host am Lauf, vom Gates-Nachlauf zu tragen) |
| Mutations-Anlage 825–828 (Vollzug) | geprüft, ohne Befund — vier Fälle gefahren, jeder färbt seinen benannten Wächter rot (Beleg unten); der grüne Vorlauf `make test-go` vor der ersten Mutation ist grün |

**Geprüft, ohne Befund, je Sensor-Lauf:**

- `make mutate MUTATE_CASES="825-archive-welle-go-umzug-stub-form-verdrahtung 826-archive-welle-go-umzug-differenzial 827-archive-welle-go-umzug-funde-verdrahtung 828-archive-welle-go-umzug-stub-nach-dem-nachzug"` → `4 ok, 0 Befund(e)`; je Fall der benannte Wächter in der Fehlschlag-Ausgabe („rot“: `TestAnwendenBrichtBeiVerletzterUmzugStubFormAb`, `TestAnwendenSchreibtDenUmzugsStubAnDerFlachenAdresse`, `TestVorschauNenntUmzugsStubsJeVerweisenderDatei`, `TestUmzugsStubVorDemNachziehenGesehen`); grüner Vorlauf `make test-go` vor der ersten Mutation.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 3 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** Kommentar benennt eine nicht existierende
Kennung · Falscher Fall-Anker im Mutations-Fall-Kopf · Funde-Zeile und
Stub-Menge führen dasselbe Kriterium doppelt ohne Gleichheits-Bindung ·
Containment-Grenze des Stub-Kriteriums benannt, nicht gefahren · Zeiger-Form
hält Teilzeichenkette statt aufgelöster Adresse

## Verdikt

**Merge-blockierend:** nein — kein HIGH, kein MEDIUM; die drei LOW- und zwei
INFO-Findings sind Doku-/Anlagen-und-Wartnungsstellen ohne Verhaltensbruch am
Bestand.

**Rollenwiderspruch:** keiner geplant — kein HIGH-Finding, der Konflikt-Pfad
aus Modul 8 ist entfallen.

**Übergabe:** Findings an den Implementer (F-1/F-2 sind Nachzüge im selben
Zug, je ein Commit mit Kennung; F-3 braucht einen Wächter, der Funde-Zeile
gegen die geschriebene Stub-Menge am Lauf hält — ein Lauf-Test über
Vorschau+Anwenden am selben Fixture genügt; die Finding-Klassen gehen in die
Slice-Closure §7).

**Empfehlungen an die Verifikation** (Modul-11-Gegenstand, nicht hier geprüft):

- Realer Altbestand-Lauf in der Vor-Schau-Fassung:
  `.harness/state/bin/ai-harness-init archive-welle --vorschau altbestand` —
  die Funde-Zeile gegen die Kontext-Messung der ADR-0112 halten (3
  ADR-Dateien/5 Fundstellen plus ADR-0016 2 und die übrigen
  Kontext-Fundstellen), und die Stub-Menge dieser Zeile gegen das, was der
  schreibende Lauf unter `done/` hinterlässt, am selben Lauf halten (F-3).
- Nach dem realen Ablage-Lauf: `make docs-check-host` — die Verweise aus
  ADR-0061 (eine), ADR-0071 (zwei) und ADR-0100 (zwei) lösen an den
  Umzugs-Stubs der Alt-Adressen auf; der reale Ordnungs-Zug (Write vor dem
  Nachziehen) ist am echten Baum zu sehen, nicht nur an den Test-Fixtures.
- ADR-0042 Festlegung 3: der Move-Lauf trägt die zwei namentlich geschnittenen
  `ignore-refs`-Paare der ADR-0016-Quelle ein und misst die Deckung je
  Wächter-Form (`0` auf der Markdown-Achse, Code-Span-Achse unbewacht —
  dieselbe benannte Lücke wie bei ADR-0030 Folgepflicht 2).
- Review der Vorlagen-Kopie über die bats-Fassung:
  `make test-bats BATS_TARGET=test/archiv-stub-vorlagen.bats` (Deckungs-Fall
  je Block, byte-gleich zur Emissions-Kopie) — der Gates-Nachlauf des
  Koordinators trägt sie; ein eigener Lauf hier war aus dem
  Parallel-Betriebs-Rahmen nicht angefordert.
- Exklusivitäts-Gegenprobe der vier neuen Mutations-Fälle (Skip-Sonde
  ausschließlich im benannten Wächter) ist gelesen, nicht gefahren; Struktur:
  826 färbt neben seinem Wächter zwangsläufig auch den Funde-Zeilen-Wächter
  (gemeinsame Quelle `SuchraumDifferenzial` — struktureller Nebeneffekt, kein
  Fall-Kopf behauptet Exklusivität), 825/827/828 sind nach Form isoliert.
