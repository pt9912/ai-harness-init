# Verifikation slice-mutations-fall-111-haengt-an-den-test-der-branch-kennzeichnung (HEAD 9f9985bd)

Rolle Verifier. Frage: bauen wir es richtig, gegen Plan und DoD. Diff `220480c6..HEAD`: Commit `bc86f4ed`
(Fall 111, eine Datei) und `9f9985bd` (`spec/spezifikation.md`, drei Stellen), vollstaendig gelesen.
Messungen mit `PATH=/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH`; das Brechen in einer `git archive`-Kopie,
die am Ende entfernt ist, und ueber `MUTATE_CASES=… make mutate` (isolierte Kopien, Beleg-Slot unberuehrt).
Geprueft ist die DoD vor Review/Closure; Review, Closure-Notiz, Register und Paarungen sind nicht dran.

## Verdikte je DoD-Punkt

- **D1 Fall 111 umgehaengt — bestaetigt.**
  - `# expect:` == `TestFeldliste_KennzeichnungNenntGenauDieFaelleDerSpezifikation`; Kopfkommentar nennt die heutige
    Eigenschaft (`branch` Pflichtfeld der Draht-Form, Kennzeichnung `nicht bekannt: .git/HEAD`, `SPEC-087`/`SPEC-014`),
    keine Chronik, kein Befund- oder Slice-Name (§3.7).
  - **Rot-Beleg selbst gefahren.** Kopie von HEAD, Fall-Skript angewendet (`emit.go:54` `json:"branch,omitempty"`),
    `make test-go` vier Mal: Lauf 1, 2, 3, 4 je EXIT 2, je **genau ein** `--- FAIL`, immer
    `TestFeldliste_KennzeichnungNenntGenauDieFaelleDerSpezifikation` mit
    `fieldlist_test.go:269: die Feldliste nennt "branch" als Feld mit Kennzeichnung, der Traeger fuehrt es nicht als Pflichtfeld`.
    `TestMandatoryFieldsAlwaysPresent` ist in keinem Log rot (`grep -c` -> 0). (Ein fuenfter Versuch brach mit
    Docker-Fehler ab, siehe F-2, und ist nicht gezaehlt; er wurde wiederholt.)
  - Ursache gelesen: der Test leitet `Required` aus dem Tag ab (`span.SchemaFields()`); `omitempty` nimmt `branch` aus den
    Pflichtfeldern, der Satz der Feldliste nennt es weiter — das ist die behauptete Ursache, nicht irgendeine.
  - `MUTATE_CASES=111-span-korrelationsfeld-verschwindet make mutate` drei Mal einzeln: je EXIT 0,
    `ok 111-… -> TestFeldliste_KennzeichnungNenntGenauDieFaelleDerSpezifikation rot`, `1 ok, 0 Befund(e)`, 4.1–4.3 s.
  - `make mutate-greift` -> `653 Fall/Faelle, 653 greifen, 0 Befund(e)`.
- **D2 Spec nachgezogen — bestaetigt, mit Abweichung vom Wortlaut (F-1).**
  - `SPEC-061`: Satz „an `tool_use_id` und an `tool`“, Bindung ohne Zeile 111 (110, 130 bleiben). Praezisiert-Spalte
    `LH-FA-13` unveraendert (MR-075 gehalten); beide Zeilen im Diff, nur Satz/Bindung geaendert.
  - `SPEC-014`: Bindung nennt jetzt `TestFeldliste_KennzeichnungNenntGenauDieFaelleDerSpezifikation` (Fall 111), Faelle 598, 599
    bleiben; Praezisiert-Spalte `LH-FA-13` unveraendert.
  - Historienzeile 2026-10-16 vorhanden (Spec §Historie, letzte Zeile).
  - `SPEC-087` (Zeile 180) hat die Spalten ID · Werkzeug · Festlegung · Praezisiert (`LH-FA-13`, `LH-FA-15`), **keine Bindungs-Spalte**;
    die Zeile nennt `branch` als Fall (`SPEC-014`). Der Auftrag liess „SPEC-087 bzw. SPEC-014“ zu; die Bindung in
    `SPEC-014` ist die einzig moegliche Stelle, die Abweichung ist keine.
  - Eigener Commit `9f9985bd`, Spec-Stellen im Kopf des Plans genannt (`SPEC-061`, `SPEC-087`, `SPEC-014`).
- **D3 `make gates` — bestaetigt.** `make gates` EXIT 0 am HEAD `9f9985bd`; `.harness/state/gates-passed.head` ==
  `git rev-parse HEAD`; `git status --short` leer. `make docs-check` -> `d-check: 2713 Datei(en) geprueft, 0 Befund(e)`.
  HEAD bewegte sich waehrend des Laufs nicht.
- **D4 Review, D5 Closure-Notiz, D6 Register, D7 Risiko-Ausgaenge, D8 Paarungen — nicht dran** (Review/Planner nach dieser Verifikation).

## Fuenfer-Lauf (111, 501, 502, 608, 609) — selbst gefahren

Trenner in `MUTATE_CASES` ist das Leerzeichen (Komma -> `unbekannter Fall`, Abbruch vor jedem Fall).
Drei Laeufe, je EXIT 2, **alle unvollstaendig**, gleiche Signatur:

| Lauf | ok (Zeit) | ohne Ergebnis | Worker-Status |
|---|---|---|---|
| 1 | 111 (4.65 s), 501 (93.7 s), 502 (93.5 s) | 608, 609 | 3, 3, 1, 3 |
| 2 | 111 (4.56 s), 501, 502 (je ~93.7 s) | 608, 609 | 3, 3, 1, 3 |
| 3 | 608 (4.59 s), 501, 502 (~99.7 s) | 111, 609 | 3, 3, 3, 1 |

Vollstaendiges Log gelesen (`$TMPDIR/m5-{1,2,3}.log`). Die Ursache steht in jedem Log gleich: Worker 3 (Lauf 3: Worker 4)
bricht im Gruen-Vorlauf `make test-go` ohne Mutation mit
`docker: Error response from daemon: No such image: sha256:<id>` (`make[1]: *** [test-go] Error 125`) ab; die anderen
Worker melden „ein anderer Worker hat den Lauf abgebrochen“, Status 3. In Lauf 1 und 2 meldet 111 `ok -> …Feldliste… rot`
(richtiger Test); „rot, aber … faellt nicht — falscher Grund“ trat **in keinem Lauf** auf (nicht reproduziert).

Dieselbe Docker-Meldung trat bei mir einmal ausserhalb des Treibers auf (`make test-go` in der Kopie, Lauf 3 oben), als ein
anderer Lauf (Reviewer-Seite, `mutate.lock` hielt ihn) denselben Tag `ai-harness-init:test` neu baute.

## Findings

- **F-1 (Bewertung Fall 111, kein Befund gegen die DoD):** Der Fall faerbt in 3 Treiberlaeufen und 4 Direktlaeufen
  ausschliesslich den benannten Test; im Fuenferlauf, soweit er ein Ergebnis fuer 111 lieferte (Lauf 1, 2), ebenso. Ein
  einzelnes beim Implementer gesehenes „falscher Grund“ kann ich nicht ausschliessen, aber auch nicht herstellen; mit 5
  gelesenen Rot-Laeufen ohne Abweichung ist „rot aus dem richtigen Grund“ **belegt, nicht widerlegt**.
- **F-2 (Fuenfer-Lauf, deterministisch, nicht Fall 111, nicht Last-Flake):** 3 von 3 Laeufen brechen, je mit
  `No such image` im Gruen-Vorlauf eines Workers. Das ist keine Test-Zeitueberschreitung unter Sperre (Klasse
  `slice-span-sperre-haelt-den-test-unter-last`), sondern ein Docker-Image-Verlust im Bild-Build der parallelen Kopien
  (gleicher Tag `ai-harness-init:test`, Colima-Store); er zeigt sich auch bei einem fremden gleichzeitigen Build. Der
  Treiber bewertet dies richtig (BEFUND, Teillauf, kein Beleg) — aber „Fuenferlauf gruen“ ist auf diesem Host/Stand
  **nicht herstellbar**, der Slice darf sich nicht darauf berufen. Fuer den Planner: eigene Beobachtung, zugehoerig zu
  `slice-roter-gruen-vorlauf-des-mutate-treibers-zeigt-sein-log` (der Gruen-Vorlauf-Fehler wird dort zwar gezeigt, die
  Ursache liegt aber in der Bild-Zuordnung); nicht Gegenstand dieses Slice.
- **F-3 (macOS, bestaetigt, nicht Gegenstand):** `harness/tools/mutate-auswahl.sh:186` (`paste -sd' '`) und `:219`
  (`paste -sd,`) geben keinen Datei-Operanden an. BSD-`paste` bricht darauf ab:
  `printf 'a\nb\n' | paste -sd'|'` -> `usage: paste [-s] [-d delimiters] file ...`, rc=1; mit `-` am Ende laeuft es
  (`a,b`). Das Skript selbst habe ich nicht gefahren (der Push-Zweig waere ein Nebeneffekt); die Bestaetigung ist Lesung
  plus Nachstellen der Zeile. Planner nimmt es bei der Closure auf.
- Plan-vs-Code: Diff stimmt mit der §3-Tabelle (Fall 111, Spec) ueberein; Gebautes ohne Plan nicht gefunden. Fall 111
  ist die einzige geaenderte Fall-Datei; 110/130/305/171 unberuehrt (Abgrenzung §1 gehalten).
- Zustand: `git worktree list` nennt nur den Hauptbaum; kein Push, kein Tag; Kopien entfernt.

## Offen fuer Planner/Architect

- F-2 als Beobachtung/Folge aufnehmen (nicht in diesem Slice, §1 grenzt Last-Flake und Gruen-Vorlauf aus).
- F-3 bei der Closure aufnehmen.
- Mutate-Lock: Verifier und Reviewer teilten sich waehrend der Laeufe `.harness/state/mutate.lock` und den Docker-Tag;
  parallele Laeufe verschiedener Rollen am selben Baum verfaelschen Messungen (siehe F-2).
