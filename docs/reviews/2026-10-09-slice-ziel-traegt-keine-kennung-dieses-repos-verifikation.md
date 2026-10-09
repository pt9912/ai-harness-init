# Verifikation slice-ziel-traegt-keine-kennung-dieses-repos

- **Rolle:** Verifier (Modul 11), frischer Kontext; Bericht an den Planner.
- **Gegenstand:** Slice-Plan `slice-ziel-traegt-keine-kennung-dieses-repos` (in-progress), Commits
  `e051aba6`, `3922608f`, `47365e76`; Bezug `LH-QA-01`, `LH-FA-01`, `ADR-0090` (Accepted).
  Geprüfter Stand: HEAD `47365e76`.
- **Urteil:** **bedingt bestätigt.** Die Liefer-Punkte DoD 1–3 sind bestätigt, jeweils mit Rot-Beleg
  und einer Messung am realen Ziel. Offen bleibt eine Folgepflicht aus `ADR-0090`: das
  Benutzerhandbuch nennt `KENNUNG` beim Altbestand-Lauf nicht. Außerdem sind die Befund-Fixes aus
  `47365e76` nicht nachgeprüft (siehe offene Punkte).

## Verdikte je DoD-Punkt

- **DoD 1 — Emittierte Dateien: bestätigt.** Ziel a (`--lang go --arch hexslice`) und Ziel b
  (sprachlos, dann `add-lang kotlin apps/kt --arch hexslice`) habe ich mit dem Träger von HEAD
  gebootstrappt (`make host-bin`, `.harness/state/bin/ai-harness-init`) und darin
  `grep -rnE 'ADR-[0-9]|MR-[0-9]|LH-[A-Z]|SPEC-[0-9]|DC-[A-Z]|AC-[A-Z]|slice-[0-9]|Spezifikation von ai-harness-init|[Dd]ogfood|AGENTS\.md §' --exclude-dir=.git --exclude-dir=baseline`
  gefahren. In beiden Zielen erscheinen nur folgende Treffer:
  - die Saat-Kennungen in `spec/` und `MR-000` in `harness/conventions.md`;
  - das Vorlagen-Beispiel `LH-QA-01` in `conventions.md` Z. 201 (§1 nimmt es aus);
  - die Platzhalter `ADR-NNNN` und `LH-XX-NN`;
  - `AGENTS.md §3.3` in `harness/README.md` Z. 93. Das ist Vorlagentext und verweist auf die
    AGENTS.md des Ziels; dort ist §3.3 „git mv + Inhaltsänderung = zwei Commits“, der Verweis
    löst also im Ziel auf;
  - `LH-FA-01` in `selbstpruefung.{mk,sh}`. Der Grund dafür steht in `erlaubteKennungen()`, und
    `patterns=` in `tools/harness/commit-msg-traceability.sh` des Ziels trifft `LH-[A-Z]{2}-[0-9]{2}`.

  `harness/mk/traeger.mk` beschreibt das Ziel („… fuehrt das Ziel nicht“).
  `harness/erfassung-feldliste.md` enthält keinen `Quelle: Spezifikation von ai-harness-init`-Satz.
  Unter `apps/` gibt es keinen Treffer. `apps/kt` trägt das Kotlin-Modul: `build.gradle.kts`,
  `src/main/kotlin/app/hexagon/…`, `harness/mk/apps-kt.mk` und `arch-apps-kt.mk`.
  Der abgelegte Träger im Ziel enthält als einzige Kennung `LH-FA-01` in den beiden
  Selbstprüfungs-Strings:
  `grep -aoE '.{0,60}(ADR-[0-9]{4}|MR-[0-9]{3}|LH-[A-Z]{2}-[0-9]{2}|SPEC-[0-9]{3}|DC-[A-Z]+-[A-Z]+-[0-9]+|slice-[0-9]+).{0,40}' .harness/state/bin/ai-harness-init`.
- **DoD 2 — Meldungen des Trägers: bestätigt.**
  - Das `grep`-Kommando aus §1 gibt am Wortlaut 3 Zeilen aus: `main.go:133`, `main.go:134` und
    `templates.go:263`. Alle drei sind Zeilenend-Kommentare, die nach §1 nicht zählen. Nach der
    Definition des Plans bleiben also 0 Nicht-Kommentar-Treffer. Das Kommando selbst filtert
    Zeilenend-Kommentare allerdings nicht heraus.
  - `traegerAusnahmen()` ist leer.
  - Die Hilfe von `archive-welle --help` nennt `--kennung`. Die Gesamthilfe (`--help`) führt in
    ihrer Verwendungszeile weiter `archive-welle [--vorschau] <welle-id>`. Das ist keine Kennung,
    aber eine unvollständige Hilfe (INFO).
  - Der Altbestand-Commit im Ziel trifft das Muster: Laut `make full-smoke` bricht „Altbestand ohne
    KENNUNG (golang): Abbruch vor dem Move“ ab, und der Lauf mit `KENNUNG=LH-FA-01` geht am nur für
    diesen Lauf aktivierten Träger durch. Das emittierte `archivierung.mk` reicht `$(KENNUNG)` ohne
    Default durch (`ADR-0090` Festlegung 2). Im Dogfood-Makefile steht `ARCHIV_KENNUNG` mit der
    Voreinstellung `ADR-0041` nur für `altbestand`.
- **DoD 3 — Wächter: bestätigt.** Rot-Belege:
  - `make mutate MUTATE_CASES='638-… 640-… 642-… 649-… 650-… 651-…'` → `6 ok, 0 Befund(e)`.
  - Die behaupteten Meldungen habe ich selbst gelesen. Dazu habe ich die Fälle 649, 650 und 651
    in einer `git archive`-Kopie außerhalb des Repos angewandt und dort `make test-go` gefahren
    (EXIT 2):
    - `internal/emit/enforce.go:483: MR-077` (649, Rechts-Grenze vor `-wort`);
    - `internal/archive/vorschau.go:129: Abschnittsnummer: AGENTS.md 3` (650);
    - `StreicheFremdeKennungen("# Ausgabe als Text (UTF-8).") = "# Ausgabe als Text.", erwartet …`
      sowie die ISO-8601- und SHA-256-Zeilen (651).

    Andere Tests sind in diesem Lauf nicht rot geworden.
  - Teil (a) hält Fall 641. Ich habe ihn nicht nachgefahren; der Review meldet ihn ok.
  - Teil (c) habe ich an der realen Quelle geprüft. Das Muster der Stufe (`FREMDE_KENNUNG_RE` aus
    `harness/tools/full-smoke.sh`) habe ich auf die rohe `--print-mk`-Ausgabe der gepinnten
    Digests angewandt:
    - d-check `sha256:e82ef2d2…`: 11 Treffer (`DC-FA-CLI-010`, `-009`, `-011` …);
    - a-check `sha256:97cb6d4e…`: 3 Treffer (`ADR-0030`, `AC-QA-03`, `slice-082`);
    - adaptiert in `d-check.mk` und `a-check.mk` von Ziel a sowie in `d-check.mk` und
      `arch-apps-kt.mk` von Ziel b: je 0.

    Ohne die Adaption würde die Stufe also rot. Klammer-Reste (`()`, `, )`) bleiben in den
    adaptierten Fragmenten nicht zurück.
- **DoD 4 — `make gates`: bestätigt** auf dem Stand mit diesem Bericht; Lauf und Ausgabe stehen in
  der Commit-Message des Verifier-Commits.
- **DoD 5 — Review: bestätigt mit Vorbehalt.** Der Report `2026-10-09-slice-ziel-traegt-keine-kennung-dieses-repos`
  liegt vor und hat das Ergebnis „blockiert“ (1 HIGH, 1 MEDIUM, 2 LOW, 2 INFO). Die Fixes stehen in
  `47365e76`. Eine Nachprüfung durch den Reviewer gibt es nicht. Den HIGH-1-, MEDIUM-1- und
  LOW-1-Fix habe ich über die Fälle 649, 650 und 651 mit gelesener Meldung belegt (siehe DoD 3).
- **DoD 6 — Doku-Update: bedingt.** `harness/README.md` §Traceability,
  `harness/sensors/archive-welle.md`, `close-welle.md` (Vorlage) und `hooks-install.mk` (Kopf)
  nennen `KENNUNG`. Das **Benutzerhandbuch** dagegen
  (`docs/user/benutzerhandbuch.md` Z. 444, `grep -n 'altbestand' docs/user/benutzerhandbuch.md`)
  beschreibt `WELLE=altbestand` ohne `KENNUNG` und ohne den Pflicht-Abbruch.
  `ADR-0090` §Konsequenzen, Folgepflicht, verlangt aber: „Handbuch und `close-welle.md`-Vorlage
  nennen das Argument, wo sie den Altbestand-Lauf zeigen“. Wörtlich lässt die DoD das zu („nur,
  falls sie eine der geänderten Meldungen zitieren“). Die Accepted-ADR geht jedoch vor.
- **DoD 7–10 (Closure-Notiz, Register, Risiko-Ausgänge, Paarungen): nicht Gegenstand.** Diese
  Punkte gehören dem Planner und sind offen.

## `make full-smoke`

- `make full-smoke` → `EXIT 0`, `real 5m22,491s`.
- **Lage (MR-089):** Die Images lagen lokal vor (0× `Pull complete`), der Build-Cache war warm
  (602× `CACHED`).
- **Variante:** Standard-Lauf mit allen Stufen über `make artifact` (Linux-Träger); nicht
  `full-smoke-host`.
- Die Stufe `fremde_kennungen_im_fragment` lief und war grün:
  `full-smoke: fremde Kennungen: d-check.mk und a-check.mk des Ziels tragen keine Kennung aus einem fremden Register.`,
  `Stufe fremde Kennungen dauerte 7 ms.` Sie liest nur das Root-Modul-Ziel (go/hexslice). Diese
  Grenze steht im Stufenkopf. Das `add-lang`-Fragment habe ich oben von Hand gemessen.
- Die Zeilen `FEHLER` im Log sind eingerückte erwartete Negativfälle (`selbstpruefung`,
  `e2e-abdeckung`). Der Lauf endet mit OK.

## Plan-vs-Code

- **Plan → Code:** Alle Zeilen aus §3 sind umgesetzt. Bei `internal/archive/anwenden.go`
  (`kennungSuffix`) weicht die Form ab: Der Plan wollte einen „Suffix, der das Muster des
  Ziel-Trägers trifft“. Umgesetzt ist eine Kennung, die der Aufrufer nennt (`--kennung`, Pflicht
  für `altbestand`) — nach `ADR-0090`, nicht nach dem Plan-Text. Die in §4 vorgesehene Übergabe an
  den Architect hat stattgefunden, und zwar als ADR statt als Rückführung nach `open`. Der Plan
  nennt diese Lösung nicht.
- **Code ohne Plan:** Die folgenden Änderungen stehen nicht in §3:
  - `--kennung` in `parseArchiveWelle`;
  - `ARCHIV_KENNUNG` im Makefile;
  - `close-welle.md` und `hooks-install.mk`;
  - `harness/sensors/archive-welle.md` und `harness/README.md`;
  - die Fälle 643–648.

  Alle sind durch die Folgepflicht in `ADR-0090` gedeckt. Andere Änderungen ohne Plan habe ich
  nicht gefunden.
- **Plan-Punkt offen:** §3 *Skip-if-present-Altbestand* verlangt, dass der Implementer den aus
  Go-Konstanten emittierten Text je Release-Träger misst oder die Lücke in §7 benennt. Eine
  Messung habe ich in den Commit-Messages nicht gefunden. Damit fällt der Punkt der Closure-Notiz
  zu.

## Lücke nach MR-071 (nicht nachgefahren)

- In `47365e76` sind diese Dateien geändert: `internal/emit/emit.go`,
  `internal/archive/vorschau.go`, `kennungen_test.go`, `emit_test.go`, `export_test.go`. Deren
  `# files:` nennen 15 schon bestehende Fälle, die ohne Lauf blieben, dazu den geänderten Fall 641:
  `40`, `310`, `311`, `325`, `327`, `329`, `330`, `331`, `332`, `333`, `504`, `505`, `508`, `559`,
  `641`, `638`.
- Von diesen habe ich nur 638 gefahren (ok). Es bleiben **15** ohne Lauf.
- Ermittelt habe ich die Menge mit
  `grep -lE "^# files:.*(^|[ ,])$f([ ,]|$)" test/mutations/*.sh` je geänderter Datei, ohne
  `docs/` und ohne `test/mutations/`.
- Für `3922608f` nennt dieselbe Abfrage 65 Fälle. Ob sie gelaufen sind, habe ich nicht geprüft.

## Negativbefunde

- **ADR-0090:** Festlegung 1 (Kennung vom Aufrufer) und Festlegung 2 (kein Default im
  Binär-Träger und im emittierten `archivierung.mk`, Default nur im Dogfood) sind eingehalten.
  Festlegung 3a (Sperre vor Pflicht) belegt der `[flacher-klon]`-Lauf in full-smoke.
- **LH-QA-01:** Keine Zusage im Wächter-Kopf ist breiter als der Sensor. Die Grenzen (Namensform,
  Klartext ohne Marker, nicht erreichte Fehlerpfade, Root-Modul in full-smoke) sind benannt.
- **LH-FA-01:** Beide Bootstraps sind mit Exit 0 durchgelaufen, `add-lang` an einem
  Unterverzeichnis ebenfalls.

## Offene Punkte für Planner/Architect

- Handbuch Z. 444: entweder `KENNUNG` im Slice nachziehen (Folgepflicht aus `ADR-0090`) oder
  ausdrücklich dem Release-Schnitt zuweisen. Das muss der Planner entscheiden; der Implementer
  sollte es nicht still auslassen.
- Die Review-Fixes aus `47365e76` hat der Reviewer nicht nachgeprüft (Review „blockiert“).
  Entscheiden, ob die Verifier-Belege oben (649, 650, 651 mit gelesener Meldung) für die Closure
  genügen.
- MR-071: 15 Fälle ohne Lauf (Liste oben).
- §6: die vier Risiken brauchen einen Ausgang. R1 ist durch `ADR-0090` und full-smoke getragen,
  R2 durch `festlegungenDerFeldliste`, R3 durch die full-smoke-Stufe (kein Gate). R4
  (Altbestand-Ziele ≤ `v0.5.0`) ist weiter offen.
- §3 Skip-if-present: Messung der Go-Konstanten-Emission oder benannte Lücke in §7.
- INFO: Die Verwendungszeile der Gesamthilfe nennt `--kennung` nicht.
