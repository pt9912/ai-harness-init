# Review-Report — slice-csharp-hexslice-layout, Nacharbeit (Folgelauf zum Erst-Report)

**Reviewer:** Rolle Reviewer (frischer Kontext) · **Datum:** 2026-10-18
**Gegenstand:** Diff `4541d7e9..e1b5fa08` (fbc3059e Renderer/Test/Fälle 765+766, d7e8dc98 Stufe/Abdeckungs-Zeile/Fall 764,
4acb251b `spec/architecture.md`, 745af124 Pausen, 1765e7aa Messzahl (leerer Commit), e1b5fa08 `docs/user/e2e-abdeckung.md`)
**Plan:** `slice-csharp-hexslice-layout` (in-progress) · **Normativ:** ADR-0097, ADR-0096, ADR-0060, AGENTS.md §3
**Vorlauf:** `docs/reviews/2026-10-18-slice-csharp-hexslice-layout.md` (F1 Config-Kommentar nannte die falsche Ursache, F2 `port-locality`
ungeprüft, F3) und `docs/reviews/2026-10-18-adr-0097-review.md`.

## Summary

0 HIGH · 0 MEDIUM · 2 LOW · 2 INFO. Nichts blockiert den Merge. F1 und F2 des Erst-Reports sind behoben, und ich habe beides
selbst gefahren. Die zwei LOW betreffen die ungebundene Pausen-Zusage der Stufe und die nicht am selben Ort benannte
Gegenrichtung.

## Eigene Läufe (alle Exit-Codes selbst gelesen)

- `make host-bin` → 0. `ai-harness-init --lang csharp --arch hexslice .` im Probeverzeichnis unter `.harness/state/` → 0.
  `make build lint test a-check` im Probe-Ziel → **0**, a-check `gesamt: 0 Befund(e)`, **kein** Hinweis „erreichen den App-Baum nicht",
  kein „0 von N".
- **F2, rot am Ziel:** Zweite Slice `Other` nach der Vorschrift des Config-Kommentars (Verzeichnis `…/Other/Ports/outbound/`,
  Namensraum `…Other.Ports.outbound`, app-Glob und outbound-Port-Glob ergänzt), Zeile 1 von `Greet/Handler.cs` = `using …Other.Ports.outbound;`
  → `Handler.cs:1: port-locality: app außerhalb Port-Scope src/App/Hexagon/Application/Example/Other: …Other.Ports.outbound`,
  `port-locality: 1`, `make` Exit 2. Zurückgenommen → `0 Befund(e)`, Exit 0, kein Hinweis.
- **Gegenprobe Groß:** dasselbe Ziel mit `Ports/Outbound` in Verzeichnissen, Namensräumen und Globs → Exit 0 und
  `Hinweis: 2 Port-Glob(s) erreichen den App-Baum nicht — port-locality bleibt dafür ungeprueft`. Die Zusage im Config-Kommentar
  stimmt mit der Messung 2 der ADR überein.
- **Mutationen** (jeweils einzeln, `MUTATE_JOBS=1`, GNU-sed im PATH): 765 → `TestCsharpHexslice_RichtungsOrdnerKlein` rot; 766 →
  `TestArchGateConfig_CsharpGlobsMatchRenderedDirs` rot; 756 → `TestArchGateConfig_CsharpGlobsMatchRenderedDirs` rot; 760 →
  `TestCsharpHexslice_NamensraumGleichVerzeichnis` rot; 764 (`SMOKE_ARTIFACT_TARGET=artifact-host`) → `full-smoke: FEHLER — das emittierte
  C#-Arch-Gate bleibt bei einem fremden Port-using im Handler gruen (port-locality an Handler.cs bleibt aus` rot; 761, 762, 763 (je
  `artifact-host`) → jeweils die benannte `full-smoke: FEHLER …`-Zeile rot. Alle `mutate: 1 ok, 0 Befund(e)`; der Baum war danach sauber
  (`git status --short` leer).
- `make gates` (einmal am Ende, mit GNU-sed im PATH wegen `mutate-greift`) → **Exit 0**; darin `test` (bats samt Fall 177, Go), `lint`,
  `docs-check`, `mutate-greift`, `span-check`. Ein erster Lauf ohne GNU-sed im PATH fiel an `mutate-greift` (BSD-sed in den Fall-Skripten);
  das ist die Host-Umgebung, kein Befund am Diff.

## Findings

### L-1 — Pausen-Zusage der Stufe ist an keine Gegenprobe gebunden (LOW)

- `kategorie`: LOW · `quelle`: AGENTS.md §3.6 (Zusage ohne rot gesehenes Gegenbeispiel), §3.7 · `pfad`: `harness/tools/full-smoke.sh:3310`
  (Kommentar „Ein Bind-Mount unter macOS (colima) zeigt eine eben geschriebene Datei verzoegert … die Pausen … halten a-check vor dieser
  veralteten Sicht"), `:3317/3321/3339` (`sleep "$cshex_pause"`, `cshex_pause=2`).
- `befund`: Der Kommentar sagt zwei Dinge zu: eine Eigenschaft des Mounts (verzögerte Sicht mit der Größe der vorigen Fassung) und eine
  Wirkung (die Pausen halten a-check davor). Belegt ist beides allein durch eine Beobachtung in der Message von 745af124; im Baum steht
  weder eine Messung noch ein Fall, der ohne die Pausen rot würde. Ich habe die Verzögerung in 9 Versuchen ohne Pause nicht reproduziert
  (Präfix-Zeile in `Handler.cs` setzen und zurücknehmen, danach a-check, je sofort, 6 Mal; `.a-check.yml` umschreiben und sofort lesen,
  3 Mal): immer die erwartete Sicht. Das widerlegt die Beobachtung nicht (lastabhängig, einmalig), aber die Zusage ist nicht bindend, und
  die 2 s sind eine Schwelle, die nur durch zwei grüne N-Läufe der Messreihe gestützt ist. Die Maßnahme selbst ist ehrlich und billig
  (6 s), und sie schreibt keinen falschen Befund vor: ein stale Handler gäbe ein falsches Grün des Gates, das die Stufe als FEHLER
  („bleibt gruen") laut meldet, nicht still.
- `verifizierbar`: nein (kein Gate-Lauf, der die Mount-Sicht belegt). · `klasse`: „Umgebungs-Zusage im Kommentar aus einer Beobachtung ohne
  Gegenprobe".
- Zu (d), die anderen Stufen: Die Stufen, die ein Layer-File mit `{ printf …; cat orig; } >datei` umschreiben und sofort a-check fahren
  (Python-, Kotlin-, Java-hexSlice, `full-smoke.sh` um 3063, 3735, 3803), laufen ohne Pausen. Ich habe sie nicht unter Last gefahren. Aus
  dem Quelltext sehe ich keinen stillen Pfad: die roten Schritte erwarten Rot und melden bei Grün FEHLER; ein stale Sicht in den
  Rücknahme-Schritten färbt falsch ROT. Der Präfix-Fall „abgeschnittener Schwanz fällt nicht auf" trifft nur die Zeile 1, die a-check
  liest. Im neuen Stufen-Teil fehlt hinter der Rücknahme eine Prüfung auf „0 von N Import-Symbolen"; sie wäre gegen eine stale, an der
  `resolution` abgeschnittene Config das einzige stille Grün (Prüfung nach Rücknahme greift nur auf `erreichen den App-Baum nicht`). Die
  Lücke ist klein, weil die Stufe davor den Lauf mit derselben Config grün auf `0 von N` geprüft hat, und die Abdeckungs-Zeile sagt
  nichts darüber zu.
- Register: Ein Beleg (Mount-Lag, Stufe mit Config-Umschreiben) reicht für eine Beobachtung unter der Schwelle; Eintragen ist Sache der
  Slice-Closure (Planner), kein Auftrag an mich. Die Abdeckungs-Zeile nennt „der Lauf auf dem CI-Linux-Dateisystem" als ungemessen; die
  Mount-Verzögerung selbst nennt keine Zeile außer dem Kommentar der Stufe.

### L-2 — Die Gegenrichtung steht nur in der Abdeckungs-Zeile, nicht in Config-Kommentar und `spec/architecture.md` (LOW)

- `kategorie`: LOW · `quelle`: ADR-0097 Festlegung 4 und Messung 6, AGENTS.md §3.6 · `pfad`: `internal/gen/csharp_hexslice.go` (Config-Kommentar,
  Satz „Ein Namensraum, der keinem Verzeichnis folgt, loest ebenfalls nicht auf und faerbt nichts"); `spec/architecture.md` C#-Absatz.
- `befund`: Die ADR misst (Messung 6): Verzeichnis `outbound`, Namensraum `…Ports.Outbound` färbt a-check `wrong-direction`, wenn ein
  Adapter den Port importiert; eine Slice ohne Adapter-Import bliebe still, nicht gefahren. Die Abdeckungs-Zeile gibt das wieder. Der
  Config-Kommentar trägt weiter den absoluten Satz „faerbt nichts" (Bestand, vom Diff nicht berührt, aber im selben Absatz, den der Diff
  geändert hat) und nennt die Gegenrichtung nicht; `spec/architecture.md` nennt sie ebenfalls nicht. Ein Adopter liest im Kommentar
  „faerbt nichts" und erwartet an dieser Stelle ein stilles Grün, das das Gate in einem gemessenen Fall nicht liefert. Das ist die
  weniger gefährliche Richtung (rot statt still), darum LOW.
- `verifizierbar`: nein (kein Sensor liest Kommentar gegen ADR). · `klasse`: „Mehrere Orte derselben Grenz-Aussage, einer ohne den
  gemessenen Gegenfall".

### I-1 — Fälle 765 und 766: der benannte Test ist nicht der einzige rote (INFO)

- `quelle`: Reviewer-Skill (Mutations-Fall nennt einen Test, die Mutation färbt mehrere) · `pfad`: `test/mutations/765-…sh`, `766-…sh`.
- `befund`: Gegenprobe gefahren (Mutation angewandt, `make test-go`). 765 färbt `TestCsharpHexslice_RichtungsOrdnerKlein`,
  `TestGenerate_CsharpHexsliceProfile_FileSet` **und** `TestArchGateConfig_CsharpMatchesSkeleton` (beide haben die kleinen Pfade
  ausgeschrieben); 766 färbt `…GlobsMatchRenderedDirs`, `…RichtungsOrdnerKlein`, `…CsharpMatchesSkeleton` und `…CsharpEdgesMatchSkeleton`.
  Die Fall-Köpfe behaupten keine Exklusivität (765: „… GlobsMatchRenderedDirs und der Namensraum-Test bleiben gruen" ist wahr).
  `RichtungsOrdnerKlein` bindet die Eigenschaft statt einer Liste und ist darum kein Duplikat im Sinne von LOW: eine Mutation, die
  zugleich die ausgeschriebenen Erwartungen von `FileSet` und `MatchesSkeleton` mitzieht, färbt nur ihn. Diese Variante habe ich nicht
  gefahren.

### I-2 — Messreihe in 1765e7aa: Zuwachs liegt bei 8 bis 12 s, nicht 9 bis 12 s (INFO)

- `befund`: Aus den vier Stufenzeiten V 11/10, N 19/22 folgen Differenzen 8, 9, 11, 12 s (19−11 = 8). Die genannte Zerlegung
  (zweite Slice, zwei a-check-Läufe, 3 × 2 s Pausen = 6 s) passt dazu; die Gesamtdauern 362/334/331/372 s überlappen zwischen den
  Ständen, und die Message sagt das selbst. Variante (hexslice/csharp), Plattform, Image-Lage und Kommando sind benannt (MR-089). Eine
  eigene Messung ist Sache des Verifiers.

## Zu den Schwerpunkten

- **(a) F1 behoben:** Config-Kommentar nennt das kleingeschriebene Richtungs-Segment als Bedingung, Ports/ports gleich, und die
  Adopter-Anleitung (Verzeichnis, Namensraum, beide Globs klein) funktioniert, wie oben am Ziel gefahren. Jede Zusage ist an die
  Matrix der ADR (Messung 2) oder an meine Läufe gebunden. Offen bleibt L-2.
- **(b) F2 behoben:** s. Eigene Läufe. Der Lauf-Zahn liest `Handler.cs:1: port-locality…` und `Example/Other` wörtlich; die Rücknahme prüft
  Exit 0 und die Abwesenheit des Hinweises.
- **(c) Wächter:** 764 bindet die Meldung des Zweigs „bleibt gruen" (nur bei ausgefallenem `port-locality` erreichbar), das ist die
  behauptete Ursache; der sed-Anker greift den realen Renderer an (die Stufe liest die Richtung per `find` und fasst `[oO]utbound` an,
  damit die Mutation sie erreicht). 761–763 halten ihre Pins nach dem Stufen-Umbau. 756 und 760 sind neu gemessen rot.
- **(e) Fall 177:** Die Gleichung `A−B−C = D−2` hält (Lauf `make test`, Teil von `make gates`, Exit 0). Die zwei neuen `make`-Läufe tragen
  je ein eigenes `einordnen` in ihrem Fehlerzweig, 2 Stufen gegen 2 Einordnungen; keine Umgehung der Zählung, keine Lockerung nach §3.5.
- **(f) Konsistenz:** Stufen-Kopf, Abdeckungs-Zeile, Config-Kommentar und `spec/architecture.md` sagen übereinstimmend: `port-locality`
  gemessen, Schreibweise beim Adopter ohne Sensor, Sensor-Übereinstimmung der vier Orte ungehalten. Ausnahme: L-2. `harness/README.md`
  unberührt; keine Zeit- oder Liefersätze in den geänderten Kommentaren.
- **(h) §3.3:** `grep -n 'Inbound\|Outbound' test/mutations/7[4-6]*` nennt nur 764 (Z. 15), 765 (Z. 10), 766 (Z. 10), und zwar als
  Mutations-Ziel; in 748–763 steht keines. Kein Commit des Bereichs benennt eine Datei um (`git log --stat`: nur Inhaltsänderungen).
  Rename und Inhalt sind nicht vermischt.

## Geprüft, ohne Befund

- **Config-Kommentar (a):** jede Zusage gegen Messung 2/Matrix und eigene Läufe gehalten, bis auf L-2.
- **Lauf-Zahn im Ziel in derselben Lieferung (§3.6):** 764 liegt mit dem Text-Wächter 765/766 in derselben Lieferung; Stufe und Fall sind rot gesehen.
- **Renderer und Test (fbc3059e):** Verzeichnisse, Namensräume, Globs konsistent klein; `TestCsharpHexslice_NamensraumGleichVerzeichnis` und
  FileSet grün; die Zählprobe `n == 0` im neuen Test belegt, dass die Menge nicht leer ist.
- **ADR-0097 / ADR-0096 / ADR-0060:** Supersedes (Teil) nur an den drei aufgezählten Sätzen; Kanten-Menge, `resolution`, `exclude` unberührt;
  `inbound`/`outbound` folgen den Rollen-Namen von ADR-0060.
- **§3.2, §3.5, §3.8, §3.9:** keine Suppression, keine Schwellen- oder Modul-Lockerung, `spec/architecture.md` ohne Norm-Änderung (nur
  Beschreibung des Ist-Layouts), alle Läufe über `make`/Docker.
- **Abdeckungs-Zeile (§3.6 emittierte Zusage):** nennt, was gemessen ist, und am selben Ort die Grenzen (Richtungs-Regeln als rote Fälle,
  Schreibweise beim Adopter, Gegenrichtung, CI-Linux-Dateisystem); `docs/user/e2e-abdeckung.md` ist byte-gleich zur Deklaration
  (`make gates` grün).
- **Commit-Schnitt:** 1765e7aa ist leer und trägt die Messzahl in der Message (Form nach MR-051/MR-089); kein Commit mischt Rollen-Artefakte.
