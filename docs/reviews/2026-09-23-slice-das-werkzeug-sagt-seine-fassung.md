# Review-Report: slice-das-werkzeug-sagt-seine-fassung — 2026-09-23

**Review-Art:** Code — Code-Review gegen Plan + ADR + Konventionen (Modul 10
§Drei Review-Arten).

**Gegenstand:** Commit `05ded93c` (Rolle Implementer: `--version` meldet die
Fassung oder ihren Fehlt-Fall laut) innerhalb der Range `406d0a1e..05ded93c`
— 14 Dateien, +249/−7. Die drei vorderen Commits der Range (ADR-0063
*Proposed*, Plan-Übergabe, slice-mv) sind Architect-/Planner-Artefakte und
diesem Lauf nur Eingangs-Kontext, nicht Prüfgegenstand.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13)
**Modell:** glm-5.3-flash · **Datum:** 2026-09-23

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Slice `slice-das-werkzeug-sagt-seine-fassung` (Kennung, Stand in
  `in-progress/`; §1 Ausschlüsse, §2 DoD, §3 Plan-Tabelle, §6 Risiken gelesen)
- `ADR-0063` (*Proposed* — die drei Festlegungen sind die Semantik, gegen die
  der Code gehalten wird), `ADR-0058` (*Accepted*), `ADR-0059` (*Accepted*),
  `MR-048`
- `LH-QA-02` (Reproduzierbarkeit)
- `AGENTS.md` §3, insbesondere §3.2 (Lint-Suppression), §3.6 (Rot-Beleg),
  §3.7 (Kommentar-Regeln), §3.9 (Docker-only)

**Sensor-Läufe dieses Laufs:** `make test-go` mit angewandtem
`test/mutations/399-fassung-fehlt-fall-entstaerkt.sh` — **rot aus dem richtigen
Grund**: `--- FAIL: TestVersionFehltFallIstLaut … Exit 0 ohne Injektion, want 2
(ADR-0063 Festlegung 2) — stderr: ""`. Die Meldung entspricht der in der
Fall-Datei vorhergesagten Ursache (Zweig feuert nie → leere Ausgabe auf stdout,
Exit 0), und **nur** der erwartete Wächter fiel —
`TestVersionMeldetDieInjizierteFassung` blieb unter der Mutation grün. Die
Mutation wurde zurückgenommen; der Arbeitsbaum ist clean und mit dem Stempel-Stand
identisch (`git diff 05ded93c` leer). `make gates` wurde gemäß Auftrag **nicht**
wiederholt; der Stempel-Bezug ist geprüft: `.harness/state/gates-passed.diffsha`
vorhanden, HEAD ist `05ded93c`, Baum clean — die Neuberechnung des Hashs ist der
Kanal des Stop-Hooks, hier nur der Bezug.

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Das Handbuch nennt Flag und Exit des Fehlt-Falls (`benutzerhandbuch.md:149` — „meldet das laut und bricht mit Exit 2 ab"), aber nicht seinen Wortlaut; `grep -rn 'keine Fassung injiziert' docs/` → 0 Treffer, der Wortlaut steht nur im Quelltext. `ADR-0063` Folgepflicht 3 verlangt, dass der Handbuch-Nachzug „den Fehlt-Fall-Wortlaut samt Exit" nennt — der Wortlaut ist laut Festlegung 2 der Anker der Skriptbarkeit. | ADR-0063 (Folgepflicht 3) | docs/user/benutzerhandbuch.md:149 | ja — `grep -rn 'keine Fassung injiziert' docs/` (0 Treffer heute) | ADR-Folgepflicht: Fehlt-Fall-Wortlaut fehlt im Handbuch |
| F-2 | MEDIUM | Die Festlegung-1-Hälfte „übergeben, nicht Pin-Default" ist ungewacht: Legt ein späterer Lauf `TRAEGER_VERSION ?= $(TRAEGER_TAG)` im Makefile an, injiziert jeder lokale Bau den Pin-Stand, der Fehlt-Fall wird unerreichbar — und kein Wächter färbt rot. Die vier neuen Fälle decken Fehlt-Fall (399), falschen Wert (400), Operand (401) und Durchreichung (402); `test/release-matrix.bats` prüft die Anwesenheit der Durchreichung, nicht die Abwesenheit eines Defaults, und die Go-Tests setzen die Variable direkt. | ADR-0063 Festlegung 1 · `AGENTS.md` §3.6 | Makefile:45 · test/mutations/ | ja — ein Fall für die Default-Einführung fällt heute an keinem Wächter | Fehlende Negativ-Absicherung der Übergeben-nicht-Default-Semantik |
| F-3 | LOW | Das Formel-Skeleton behauptet an unveränderter Stelle „kein Wert reist im Binary" — `ADR-0063` Festlegung 1 lässt genau einen Wert ins Binary reisen (die Fassung als Release-Entscheidung); der Satz ist seit diesem Diff überbreit und liest sich als Verbot auch der Fassung. | ADR-0063 Festlegung 1 | harness/tools/homebrew-formula.rb.tmpl:3 | ja — `grep -rn 'kein Wert reist im Binary'` (eine Fundstelle außerhalb der Baseline) | Lebende Zusage nicht an ADR-Wechsel nachgezogen |
| F-4 | LOW | Die nutzer-sichtbare Fehlt-Fall-Meldung endet auf „(Bau ohne Release-Injektion, ADR-0063 Festlegung 2)" — eine repo-interne Referenz, die ein Installierer außerhalb des Repos (Weg A/C) nicht auflösen kann; die ADR friert mit Accept ein, während der Wortlaut laut Festlegung 2 skriptbar bleiben soll. | Maintainability | cmd/ai-harness-init/version.go:25 | nein — Urteil über die Zielgruppe; die Stelle zeigt der Quelltext | Repo-interne Norm-Referenz in nutzer-sichtbarer Ausgabe |
| F-5 | LOW | §3 der Plan-Datei listet `.golangci.yml` nicht, obwohl der Diff dort die zentrale Lint-Ausnahme anlegt — die Datei-Tabelle deckt den Diff an dieser Stelle nicht. | Maintainability | slice-das-werkzeug-sagt-seine-fassung §3 | ja — Dateiliste des Commits gegen §3 | Diff-Artefakt fehlt in der Plan-Tabelle |
| F-6 | INFO | Die §3-Korrektur (Dispatch-Ebene unter `cmd/`, nicht `internal/`) ist inhaltlich zutreffend — der Version-Dispatch sitzt in `cmd/ai-harness-init/main.go` —, aber sie ist eine Plan-Korrektur, die die Implementer-Rolle im eigenen Commit schreibt; der Plan ist das Planner-Artefakt. Der Planner bestätigt sie bei der Closure. | `v6.9.0` · `regelwerk/modul-08-agentenrollen.md` §Rollen-Sequenz für einen Slice | slice-das-werkzeug-sagt-seine-fassung §3 | nein — Rollen-Urteil, kein Gate | Plan-Korrektur in fremder Rolle |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Festlegung 1 — Injektions-Quelle: kein Rezept benutzt den Pin-Default; kein `TRAEGER_VERSION ?=` im Makefile (nur `TRAEGER_TAG ?=` an der Fetch-Achse, :45, und dessen `export`, :53); Dockerfile `ARG TRAEGER_VERSION=` leer (:96); die vier Bau-Rezepte reichen nur `$(TRAEGER_VERSION)` durch | geprüft, ohne Befund |
| Festlegung 1 — Workflow: `TRAEGER_VERSION: ${{ github.ref_type == 'tag' && github.ref_name || '' }}` — Tag-Ref übergibt den Ref-Namen, dispatch auf einem Zweig LEER; `homebrew-formula-fill.sh` nutzt dasselbe `GITHUB_REF_NAME` — derselbe Wert, derselben Schnitt | geprüft, ohne Befund |
| Festlegung 2 — Fehlt-Fall-Form: Wortlaut auf stderr, Exit 2, stdout bleibt leer (`version.go`, `runVersion`); geführter Ausgang im Dispatch **vor** dem Flag-Parsen (`main.go:173`); `--version` mit Zusatz-Argument fällt durchs Flag-Parsen in die unbekannte-Flag-Sperre (Exit 2 + Usage, `main.go:184-194`); kein Fall im Init-Pfad; `TestVersionFehltFallIstLaut` hält Exit **und** zwei Wortlaut-Teile **und** leeres stdout | geprüft, ohne Befund |
| Festlegung 3 — pin-kopplung-Test unberührt (`test/traeger-fetch.bats` nicht in der Dateiliste des Commits), Formel-Nachzug-Mechanik unberührt, Formel liest weiter aus dem Release (`homebrew-formula.rb.tmpl` lädt je Plattform das Release-Binary — Weg C trägt deshalb wahr), `compile` un-injiziert (compile-Stage ohne `ldflags`/`ARG`), emittierte Ebene (`internal/`) unberührt | geprüft, ohne Befund |
| Byte-identische Eigenschaft des Default-Pfads (`MR-048`): mit leerem/ungesetztem Wert ergibt `${TRAEGER_VERSION:+ …}` nichts — der `ldflags`-String bleibt exakt `-s -w`; die Form hält der neue bats-Test (byte-exakter Grep auf den Operanden), der Default-Pfad hängt wie bisher an `build`/`artifact`/beiden Smokes (der Live-Vergleich zweier Bauten blieb dem Stempel und den artifact/smoke-Zähnen überlassen — kein zweiter Gate-Lauf gemäß Auftrag) | geprüft, ohne Befund |
| Lint-Ausnahme (`AGENTS.md` §3.2): zentral in `.golangci.yml:176-184` mit Why-Kommentar, verengt auf Datei (`cmd/ai-harness-init/version\.go$`) **und** Bezeichner-Text (`^fassung is a global variable`); kein inline `//nolint` im Diff | geprüft, ohne Befund |
| Workflow-Regeln (`MR-014`/`MR-069`): der `env`-Block ist Bau-Parameter, kein Check in der YAML; der Start-Smoke ruft `--version` nicht (`start-smoke.sh:38` ruft `--help`) — die Kommentar-Aussage im Workflow hält | geprüft, ohne Befund |
| Handbuch Ist-Zustand: die drei Zusätze (Weg A :115, Weg B :149, Weg C :156) sind präsentisch — keine Chronik, keine Prognose; Weg B trägt den Fehlt-Fall wahrheitsgemäß, die Substanz trägt `ADR-0063` Festlegung 2 mit Re-Evaluierungs-Trigger 3 (Quell-Bau ohne Injektion → Fehlt-Fall laut) | geprüft, ohne Befund (der Wortlaut-Aspekt ist F-1) |
| Mutations-Konvention: Nummerierung fortlaufend (398 → 399-402), Header-Felder (`files:`/`expect:`/`verify:`) konform zum Treiber (`harness/tools/mutate.sh`), Fall-Kommentare präsentisch; die sed-Anker von 400/401/402 gegen den Quell-Bestand gemessen (399 zusätzlich live rot) | geprüft, ohne Befund (die Deckungs-Lücke steht als F-2) |
| Live-Rot: Fall 399 gefahren, Meldung gelesen, Ursache gegen die Fall-Vorhersage geprüft — trifft (Exit 0, leeres stderr, nur der erwartete Wächter) | Rot aus dem richtigen Grund, Meldung gelesen |
| Gates-Stempel-Bezug: `.harness/state/gates-passed.diffsha` vorhanden; HEAD `05ded93c`, Arbeitsbaum clean, `git diff 05ded93c` leer — kein zweiter Gate-Lauf (Auftrag); die Hash-Neuberechnung ist Kanal des Stop-Hooks | geprüft, ohne Befund |
| §1-Ausschlüsse: keine Änderung an Formel-Mechanik, `SHA256SUMS`-Erzeugung, `ADR-0058`/`ADR-0059`, `test/traeger-fetch.bats`, `internal/` — die Dateiliste des Commits enthält none davon | geprüft, ohne Befund |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 3 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** ADR-Folgepflicht: Fehlt-Fall-Wortlaut fehlt
im Handbuch · Fehlende Negativ-Absicherung der Übergeben-nicht-Default-Semantik ·
Lebende Zusage nicht an ADR-Wechsel nachgezogen · Repo-interne Norm-Referenz in
nutzer-sichtbarer Ausgabe · Diff-Artefakt fehlt in der Plan-Tabelle ·
Plan-Korrektur in fremder Rolle

## Verdikt

**Merge-blockierend:** nein — keine HIGH-Findings. Die zwei MEDIUM sind vor der
Slice-Closure zu klären (F-1 ist ein Nachzug in der Reichweite von Liefer-Punkt 3;
F-2 ist ein Wächter-Nachzug), keiner davon verschiebt die Abnahme selbst.

**Substanz-Prüfung der drei `ADR-0063`-Festlegungen** (der Acceptance-Trigger der
ADR verlangt eine Reviewer-Runde, die gegen `ADR-0058` Festlegung 2 samt
Alternative A und Re-Evaluierungs-Trigger 1, `ADR-0059` Festlegungen 2 und 3 und
`MR-048` auf Konsistenz prüft): geprüft — Festlegung 1 (Injektion liest den
übergebenen Wert, kein Rezept berührt den Pin-Default, Workflow übergibt LEER bei
Nicht-Tag-Ref), Festlegung 2 (Fehlt-Fall laut, Exit 2, geführter Dispatch, kein
Fall im Init-Pfad, Zusatz-Argument fällt in die Flag-Sperre), Festlegung 3
(Pin-Achse, zwei Kanäle, byte-identischer Default-Pfad, emittierte Ebene
unberührt). **Kein blockierender Befund an der Substanz der drei Festlegungen** —
F-1 trägt am Umfang von Folgepflicht 3, F-2 an der Wächter-Deckung einer Hälfte
von Festlegung 1; der Code selbst hält beide Festlegungen. Ein Befund an der
Darstellung hindert die Annahme nach dem Acceptance-Trigger nicht.

**Nicht geprüft (Grenze des Laufs):** ein realer Workflow-Lauf (kein
Tag-Dispatch hier); der Live-Vergleich zweier Bauten auf Byte-Gleichheit (die
Form hält der bats-Test, der Vergleich hängt an den artifact/smoke-Zähnen im
Stempel); `make mutate` als Ganzes (gemäß Auftrag nur ein gezielter Fall).

**Übergabe:** Findings gehen an den Implementer (F-1, F-3, F-4, F-5 als Nachzüge;
F-2 als Wächter-Nachzug) bzw. an den Planner (F-6). Die Finding-Klassen gehen
zusätzlich in die Slice-Closure §7 und von dort in den Zähler. Dieser Report ist
ein Lauf-Beleg und ersetzt keine Verifikation gegen DoD/Spec (Modul 11).