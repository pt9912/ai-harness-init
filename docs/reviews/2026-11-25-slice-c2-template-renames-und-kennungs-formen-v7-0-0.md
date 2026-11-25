# Review-Report: slice-c2-template-renames-und-kennungs-formen-v7-0-0 — 2026-11-25

**Review-Art:** Code — geprüft gegen den Plan `slice-c2-template-renames-und-kennungs-formen-v7-0-0`
(§1 Ziel/Abgrenzung, §2 DoD, §3 Plan, §6 Risiken), die MR-Einträge `MR-030`/`MR-057`/`MR-059`/`MR-071`/`MR-078`/`MR-090`/`MR-091` und `AGENTS.md` §3.

**Gegenstand:** `90cb8acb` (Claim, reiner Move) · `010bc6bd` (Emit-Zug, 61 Dateien) · `0a080df5` (Verweis-Zug, 76 Dateien)

**Skill:** `.harness/skills/reviewer.md` @ 2.3.0
**Modell:** claude (glm-5.3-flash) · **Datum:** 2026-11-25

**Eingangs-Kontext:**

- Plan `slice-c2-template-renames-und-kennungs-formen-v7-0-0` (liegt in `in-progress/`)
- [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (Emitterseite),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- `MR-030`, `MR-057`, `MR-058`, `MR-059`, `MR-071`, `MR-078`, `MR-090`, `MR-091`
- `AGENTS.md` §3 (Hard Rules)

> **Zitier-Form:** Baseline-Stellen als Tag + Pfad in Inline-Code (`v7.0.0` ·
> `templates/docs/plan/planning/archive-stub-wave.template.md`). Der Plan und die
> MR-Eintrage stehen als **Kennung** (§3.11); ein `pfad`-Abfragent auf Code-Dateien
> zitiert den Stand des Laufs.

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | Der Emit-Zug zieht die Interface-Form im Kopf des emittierten Fragments auf `WAVE=<wave-id>` (Kopfzeilen 14/19/23/40), das Rezept übergibt aber weiter `"$(WELLE)"` — im emittierten Ziel verliert `make archive-welle WAVE=<id>` die Kennung an ein leeres Positionsargument. Bruchprobe in Kopie (Stub-Träger): `make -s -f archivierung.mk ARCHIV_CARRIER=./ai-harness-init archive-welle WAVE=wave-foo` → `CARRIER-ARGS: archive-welle ` (leer). | Plan §1 (Urteil Interface-Variable), `MR-057` Setzung 1, `AGENTS.md` §3.6 | `internal/emit/templates/enforce/archivierung.mk:42` | ja — Bootstrap-Ziel, `make archive-welle WAVE=<id>` mit Träger; kein Wächter: der Text-Sensor `internal/emit/archivierung_test.go` hält die Kopfzeile als Text und bleibt grün, ein Lauf-Zahn mit WAVE-Aufruf fehlt und die Lücke ist nicht benannt (`AGENTS.md` §3.6, Fassung „Wirkung im Ziel") | Interface-Formzug ohne Rezept-Nachziehung |
| F-2 | MEDIUM | Die Sensor-Prosa (gebundener Target-Vertrag) nennt `make archive-welle WAVE=<wave-id>`; das dogfood-eigene Makefile trägt die Form `WELLE=<welle-id>` und übergibt `"$(WELLE)"` — `make -n archive-welle WAVE=wave-01` → `.harness/state/bin/ai-harness-init archive-welle  ""`. Die neue Konfig-Form hat an keiner der zwei Enden (emittiertes Rezept F-1, Dogfood-Make-Variable) einen Träger. | `AGENTS.md` §3.9/§3.6 — halte die Konfig-Aussage am Aufruf, den der Bestand trägt | `harness/sensors/archive-welle.md` · `Makefile:594-596` | ja — `make -n archive-welle WAVE=<id>` / Ziel-Lauf | Target-Konfig-Form im Sensor-Text ohne Träger im Bestand |
| F-3 | LOW | Das emittierte Kommentar nennt als Beispiel weiterhin das `welle-`-Ziel-Beispiel (praefixlos), obwohl der Plan-Zug für `slice-mv.sh` sagte: Form-Zug dort, wo der Satz den alten Präfix trägt. Kommentar-Stelle, kein Verhaltenseffekt. | Plan §3 (Zeile `internal/emit/templates/enforce/slice-mv.sh`) | `internal/emit/templates/enforce/slice-mv.sh:50` | nein — kein Sensor liest emittierte Kommentare | Emittiertes Kommentar trägt die alte Kennungs-Form |
| F-4 | INFO | MR-078s Begründung trägt den einzigen Prosa-Zusatz über die Verweis-Ziehung hinaus (Stub-Vorlage erbt die Zeiger-Form `archive.zip`), ohne datierte Messstelle (`MR-058`-Form). Inhalt verifiziert (`v7.0.0` · `templates/docs/plan/planning/archive-stub-wave.template.md`:34; `internal/archive/collect.go:45` `archivName = "archive.zip"`), vom Plan DoD (3) getragen — als Grenze zur `MR-071`-Form benannt; R3s Alternative (Aussage betroffen → C7) wäre die andere Adresse gewesen. | `MR-071` (angenommene Einträge unverändert), Plan R3/DoD (3) | `harness/conventions/MR-078-wellenlose-slices-werden-bei-der-eigenen-closure-archiviert.md:28-34` | ja (Inhalt) / nein (Form — kein Sensor liest Begründungs-Zusätze) | Begründungs-Zusatz im angenommenen Eintrag ohne datierte Fundstelle |
| F-5 | INFO | Direkt über dem neu geschriebenen Ruhe-Marker bleibt „Die Welle … wartet auf ihren Start“ stehen, während der Start-Trigger laut Plan §4 am 2026-11-25 eingetreten ist und der Marker beanspruchte Arbeit meldet — zwei widersprüchliche Zustands-Zeilen unter Offene Wellen. Der Bestand ist kein Arbeitsauftrag (§3.7 Cutoff); die Zeile wurde nur neben der geschriebenen Zelle nicht mitgezogen. | `AGENTS.md` §3.7 (Zustandsfelder — Cutoff), Modul 6 §Offene Wellen | `docs/plan/planning/in-progress/roadmap.md:22-23` | nein — kein Sensor hält die Offene-Wellen-Prosa | Zustands-Prosa neben dem Ruhe-Marker ohne Nachzug |
| F-6 | INFO | Der Betreff von `0a080df5` nennt „Fundlisten je MR-057/057/078" — die zweite 057 meint `MR-059`. `MR-059` trägt seine Fundliste per Verweis auf `MR-057` §Grenze und brauchte keinen eigenen Zug (geprüft). Kein Gate liest die Kennung über die Anwesenheitsprüfung hinaus. | `MR-051` | Commit 0a080df5, Betreffzeile | nein | Doppelte Kennung in Commit-Message statt MR-059 |

## Belege (Kommando → Ausgabe)

| Kommando | Ausgabe |
|---|---|
| `git grep -lE 'slice-(\[0-9\]\|\\d)' -- harness/tools internal cmd Makefile d-check.mk ':!internal/emit'` | `cmd/ai-harness-init/kennungen_test.go` · `harness/tools/commit-msg-traceability.sh` · `harness/tools/full-smoke.sh` — identisch mit der Fundliste in `MR-057` §Grenze (Menge 3) |
| `git grep -lE 'slice-(\[0-9\]\|\\d)' -- internal/emit` | `agents_test.go`, `commands_test.go`, `emit.go`, `emit_test.go`, `templates/enforce/commit-msg-traceability.sh` — identisch mit der eingetragenen Menge 5 (Frisch-Messung nach dem Zug Bestand hat) |
| Bruchprobe F-1 (Kopie unter `/tmp`, Stub-Träger) | `CARRIER-ARGS: archive-welle ` — `WAVE=wave-foo` geht verloren |
| `make -n archive-welle WAVE=wave-01` | `.harness/state/bin/ai-harness-init archive-welle  ""` (F-2) |
| `test -f .harness/baseline/v7.0.0/templates/…/{wave,wave-results,archive-stub-slice,archive-stub-wave,NNNN-title}.template.md` und `MR-NNN-title.template.md` | alle sechs vorhanden — der Name-Zug ist vollständig; F-1 betrifft eine Rezept-Zeile, keinen Namen |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| `MR-057`/`MR-058`-Messung | geprüft, ohne Befund — beide Fundmengen am 2026-11-25 frisch reproduziert (nach dem Zug), Zahlen neben dem Kommando (`MR-025`) |
| `MR-059`-Trennung über die übrigen MR-Einträge | geprüft, ohne Befund — Stichproben `MR-019`/`MR-021`/`MR-029`/`MR-041`/`MR-048` (Indexzeile): ausschließlich Pfad-/Anker-Nachzüge; `MR-059` byte-gleich unberührt (Fundliste per Verweis) |
| `MR-030`-Urteil (Werkzeugnamen bleiben, Formen ziehen) | geprüft, ohne Befund — `internal/emit/commands.go` berührt, `plan-welle`/`close-welle`-Vorlagen behalten die deutschen Namen und tragen wave-Dateizeilen; `cp`-Ziele auf `wave.template.md`; `WAVE=`-Keying ist gezeichnet (siehe F-1/F-2 für die nicht mitgezogenen Rezept-/Makefile-Wurzeln) |
| Emissions-Komplett-Verdikt (7 Renames) | geprüft, ohne Befund — case-Listen/Konstanten/Link-Texte auf die sieben v7-Namen, Fixtures (templates_test.go Inventar + Ziel-Sets) am realen v7-Satz, emittierte Namen strukturell aus der Quelle (`v7.0.0` · Vorlagen-Dateien, ls); `emitteddocs`-Pfad braucht keinen Zug (nicht geführt) |
| environment-check-Singleton | geprüft, ohne Befund — default-disponiert nach `v7.0.0` · `regelwerk/grundlagen-harness-dateien.md` (ADR-0057-Form „nicht eingetragen = Singleton“), C4-Adresse im Fixtur-Kommentar (`templates_test.go:91-95`), Schicht-Zuordnung steht im Plan, nicht hier übernommen |
| Mutations-Neuanker (207/296/507 gesamplet + 215/222/223) | geprüft, ohne Befund — `files:`/`expect:`/`verify:`-Köpfe unangetastet, sed-Anker am umgezogenen Quell-Bestand; `make mutate-greift` 775/775 (Beleg des Laufs), `MR-090`-Anker am Commit |
| 145-Verweis-Nachzug (Stichprobe 6 Klassen: ADR-Zeitdokumente, Konventions-Index, Reviewer-Skill, MR-Einträge, Sensor-Prosa, Planning-Slices) | geprüft, ohne Befund für die Verweis-Form; `make docs-check` nach dem Report erwartet 0 `target-missing` |
| §3.11 an eingefrorenen ADRs (0061, 0100) | geprüft, ohne Befund — die zwei geänderten Zeilen sind Baseline-Pfadnachzüge (ortsfeste Pfadform inkl. Tag, per v7-Sprung nötig), keine Prozess-Adresse in einem eingefrorenen Text |
| Dogfood `ignore-refs` (`.d-check.yml:449/451`, alte Vorlagen-Namen) | geprüft, ohne Befund — inert als `MR-008`-Historie (Dateien, die ihren Lifecycle verlassen haben, §3.11-Ortsfestigkeit); jede weitere Senkung braucht eigene ADR (§3.5), bewusst nicht gezogen |
| Ruhe-Marker-Form (Roadmap) | geprüft, ohne Befund — Zustand + auflösbarer Anker, keine Chronik ( siehe F-5 für die Nachbarn) |
| emittierte `d-check.yml`-Namensform | geprüft, ohne Befund — `wave`-Klasse/-Token/-Regeln gezogen (Klassen-Zusammensetzung trägt C3, hier nicht berührt) |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 1 |
| LOW | 1 |
| INFO | 3 |

**Finding-Klassen dieses Laufs:** Interface-Formzug ohne Rezept-Nachziehung · Target-Konfig-Form im Sensor-Text ohne Träger im Bestand · Emittiertes Kommentar trägt die alte Kennungs-Form · Begründungs-Zusatz im angenommenen Eintrag ohne datierte Fundstelle · Zustands-Prosa neben dem Ruhe-Marker ohne Nachzug · Doppelte Kennung in Commit-Message statt MR-059

## Verdikt

**Merge-blockierend:** ja — F-1 bricht das emittierte `WAVE=`-Interface (der Träger verliert die Kennung); F-2 trägt dasselbe Muster am dogfood-eigenen Makefile nach. Beide gehören in denselben Nachzug (Rezept in `archivierung.mk:42` → `"$(WAVE)"` und, je Urteil, die Dogfood-Make-Variable oder die zurückgenommene Prosa) — dann ist der Slice nicht blockiert.

**Übergabe:** Findings an den Implementer; die Finding-Klassen gehen zusätzlich in die Slice-Closure §7. R2 (Mutations-Probe, Ausgang „weiter offen“) und ein Ausgang für jedes offene Risiko wandern unverändert in die Welle-Closure; F-4/F-5 gehen als Finding-Klassen in den Zähler der Slice-Closure §7.
