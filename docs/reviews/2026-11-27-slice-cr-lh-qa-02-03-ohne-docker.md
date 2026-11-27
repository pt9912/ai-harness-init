# Review — slice-cr-lh-qa-02-03-ohne-docker

**Datum:** 2026-11-27 · **Reviewer:** Modul 10 (frischer Kontext)
**Diff:** Commit `a87c7bcc` (CR 0.28.0: docker-los als Pflicht-Weg) — ändert ausschließlich `spec/lastenheft.md` (15+, 10−); Abgleich-Runde auf Commit `083323e1` (CR 0.28.1: Folgestellen) im Addendum unten
**Plan:** [`docs/plan/planning/in-progress/slice-cr-lh-qa-02-03-ohne-docker.md`](../plan/planning/in-progress/slice-cr-lh-qa-02-03-ohne-docker.md)
**Kontext-Eingang:** der Slice-Plan · `spec/lastenheft.md` (LH-QA-01…04, LH-FA-06…09, Historie) · `MR-015`, `MR-042` · `AGENTS.md` §3 (§3.5–3.9 im Fokus) · Commit-Kette `7631f2b5`→`55f3038f`→`a87c7bcc`. Vorherige Reports unter `docs/reviews/` (letzte ~5) geladen; keiner trägt wiederkehrenden Befund zu Spec-Änderungs-Commits.

## Findings

**F-1 · MEDIUM · Quelle: LH-QA-03 vs. LH-FA-07 · Pfad: `spec/lastenheft.md:196` (LH-FA-07) gegen `:580`–`:592` (neue LH-QA-03)**
Der CR änderte allein LH-QA-02/03; innerhalb desselben abnahmebindenden Dokuments bleibt LH-FA-07 mit dem harten Satz *„a-check läuft Docker-only"* stehen — unter der neuen LH-QA-03 (`docker` ist **Weg, keine Pflicht**) sind zwei einander entgegengesetzte Aussagen über dieselbe Anforderung im Vertrag. Die vier übrigen `bash + git + docker`-Sätze (Zeilen 155, 196b, 297, 482) sind Superset-Zusagen („braucht über X hinaus nichts") und vertragen die neue Fassung; LH-FA-07s „läuft Docker-only" ist es nicht. Der Slice-Plan §6 (Risiko 1) hatte nur die LH-QA-04-Kollision vorab benannt — diese Stelle nicht.
`verifizierbar:` ja (Lesen; `sed -n '196,199p' spec/lastenheft.md`).
`klasse:` CR ändert Anforderung, abhängige Stellen im selben Dokument bleiben unbehandelt.

**F-2 · MEDIUM · Quelle: LH-QA-04 vs. LH-QA-03 · Pfad: `spec/lastenheft.md:596`–`:597`**
LH-FA-04-Abschnitt LH-QA-04 behält den unhedgeden Satz *„das Tool ruft Host-`docker` (Docker Desktop liefert die docker-CLI auf macOS/Windows)"*. Nach dem CR ist `docker` Weg, nicht Pflicht — der Satz beschreibt einen Zustand, den der Vertrag nicht mehr zusagt. Der Slice-Plan §6 (Risiko 1) hat die Kollision vorab benannt und den Ausgang der Closure/der ADR-Arbeit zugewiesen; der Befund steht hier als observable bis dahin dokumentiert.
`verifizierbar:` ja (Lesen).
`klasse:` Kollision zweier Anforderungen bei Fassungs-Änderung — Ausgang steht aus (geplant).

**F-3 · MEDIUM · Quelle: LH-QA-02 · Pfad: `spec/lastenheft.md:577`, `:578`, `:592`**
Die neue Fassung trägt den Begriff **„Inventar-Soll" / „Inventar-Pins"** in Anforderung und Messmethode; er löst außerhalb dieser drei Sätze nirgends (`grep -rn -i 'inventar' spec/ docs/plan/adr/` → nur die drei neuen Zeilen plus unrelated Treffer). Die Mechanik ist bewusst Gegenstand von `slice-adr-gates-laeufen-host-native` — aber eine Messmethode, deren Bezugsobjekt kein heute existierendes Artefakt trägt, ist bis dahin nicht einlösbar (dasselbe Muster, das Zeile 0.13.0 selbst als *„so nicht einlösbar"* zurückgenommen hat). Kein halluziniertes Gate im §3.1-Sinn — es wird kein `make`-Target genannt —, aber die Reproduzierbarkeits-Messmethode des docker-los Wegs verweist auf ein Konstrukt ohne Träger.
`verifizierbar:` ja (`grep -rn -i inventar spec/`); einlösbar erst mit dem Mechanik-ADR.
`klasse:` Messmethode verweist auf Konstrukt ohne Träger (Spec-Treue-Lücke).

**F-4 · MEDIUM · Quelle: MR-042 · Pfad: `spec/lastenheft.md:688` (Historie-Zeile 0.28.0, Änderungs-Spalte)**
Die Zeile trägt *„Getrieben von welle-ohne-docker"* in der Änderungs-Spalte — den Anlass (der interne Vorgang, in dessen Kontext die Vertragsänderung beschlossen wurde). MR-042 löst genau das auf: der Anlass gehört in die Closure-Notiz, die Verweis-Spalte trägt die annehmende Instanz. Die Bestands-Praxis nach dem MR-042-Schnitt (2026-09-02) bildet das ab — Zeilen 0.14.0 bis 0.27.1 nennen keinen internen Vorgang; „Getrieben von" steht nur in Zeilen 0.10.0–0.13.0 (Bestand vor dem Schnitt, und 0.13.0/„Getrieben von slice-048" war der Wirksamkeits-Anlass von MR-042 selbst). Die Historie-Zeile ist Protokoll und wird nicht rückwirkend geändert — die Stellung ist damit permanent.
`verifizierbar:` ja (`grep -n 'Getrieben von' spec/lastenheft.md`).
`klasse:` Anlass in Historie statt Closure-Notiz.

**F-5 · LOW · Quelle: LH-QA-03 (Briefing-Zitat) · Pfad: `AGENTS.md:417` und §3.9-Eröffnung**
Die AGENTS.md-Stellen zitieren LH-QA-03 mit der parenthethischen Zusicherung *„(Bootstrap-Laufzeit braucht git + docker)"*, §3.9 entsprechend *„der Host braucht git, docker und GNU make, sonst nichts (LH-QA-03, ADR-0003)"*. Nach dem CR sagt die zitierte Quelle das Gegenteil (nur git; docker Weg). Doku-Drift am Briefing — der Zitat-Anker trägt die beanspruchte Aussage nicht mehr; das Briefing ist Architektur-Arbeit der Welle, nicht des CR.
`verifizierbar:` ja (Lesen).
`klasse:` Briefing-Zitat trägt die zugeordnete Fassung nicht mehr.

**F-6 · INFO · Quelle: MR-015 (Historie-Form) · Pfad: `spec/lastenheft.md:688`**
Die Grade-Begründung komprimiert zu „Minor (Anforderung + Messmethode je Weg)". Die Präzedenz-Zeilen (0.26.0, 0.27.0, 0.27.1) begründen Minor ausbuchstabiert — „weil sich die Aussage eines Akzeptanzkriteriums ändert; keine neue Anforderung". Die neue Fassung führt mit „Tool-Pin + Tool-/Versions-Check" und „Inventar-Soll" Zusage-Elemente für emittierte Ziel-Repos ein, die zuvor nicht dastanden; die Zeile benennt keine dieser Zusage-Elemente als „neue Anforderung". Dokumentationswürdige Annahme an einer unumkehrbaren Stelle.
`verifizierbar:` ja (Vergleich der Zeilen).
`klasse:` Grade-Begründung hinter dem Inhalt der Zeile.

**F-7 · INFO · Quelle: Maintainability (Plan §6) · Pfad: `spec/lastenheft.md:688`**
Der Slice-Plan §6 (Risiko 2) versprach: *„der CR trägt das als Übergangs-Satz (Auftraggeber-Beschluss ≠ abgeschlossener Umbau)"*. Die Zeile nennt Beschluss und Ziel („Labor und Produkt färbt ein docker-los Gate-Weg"), aber nicht den Ist-Stand, dass Gates und CI bis zum Wellen-Abschluss docker-getrieben bleiben — die Grenze trägt sie nur implizit.
`verifizierbar:` ja (Vergleich Plan §6 vs. Zeile).
`klasse:` Zugesagter Übergangs-Satz nur implizit getragen.

## Negativbefunde (geprüft, ohne Befund)

- **MR-015 Formkörper** — eigener Commit ausschließlich `spec/lastenheft.md` (`git show --stat a87c7bcc` → 1 Datei); Verweis-Spalte *„Nutzer-Entscheidung 2026-11-27"*; Datum 2026-11-27; Header-Bump 0.27.1 → 0.28.0; Historie-Zeile vollständig am Ende. Ohne Befund.
- **Setzung-2-Abweichung: benannt, nicht kaschiert** — der nachträgliche CR zur Move-Reihenfolge ist in der Zeile ausdrücklich mit Grund und Präzedenz benannt; Zeile 0.18.0 trägt denselben Formkörper nachprüfbar (`spec/lastenheft.md:674`). Ohne Befund.
- **Anker-Links der neuen Zeilen** — `#lh-qa-02--reproduzierbarkeit`, `#lh-qa-03--minimale-abhängigkeiten`, `#lh-qa-04--plattform-matrix` lösen auf existierende Headings (`spec/lastenheft.md:570, 575, 580, 594`, unverändert — Heading-Anker stabil); der `MR-015`-Anker steht als explizite `<a id>` in `harness/conventions.md:120`. Ohne Befund.
- **Commit-Message-Traceability** — Betreff trägt die Slice-Kennung und beide `LH-*`-IDs. Ohne Befund.
- **Kein Gate-Lockerungs-Objekt im Diff** — der neue Weg senkt keine Schwelle und schaltet kein Modul ab; LH-QA-01-Messmethode („make gates grün out-of-the-box") bleibt unverändert. Ohne Befund (die Einlösbarkeit des neuen Wegs ist F-3).

## Nicht gefahrene Sensoren / offene Risiken

- `make docs-check` lief **nicht** (d-check fährt im gepinnten Image; Docker-Daemon aus, Auftraggeber-Beschluss). `spec/lastenheft.md` ist d-check-Target (`.d-check.yml:443`); die Link-Pflege der neuen Zeilen beruht auf der manuellen Anker-Prüfung oben — ein CI-Lauf auf dem Push wäre der Nachweis, der die Lücke schließt; Stand hier: offen.
- `make gates` wurde nicht gefahren; der Stop-Hook ist per Marker ausgesetzt (Revozatur mit der Closure von welle-ohne-docker). Für den reinen Doku-Diff ohne Code-Berührung bleibt das ohne Code-Gate-Auswirkung; der Rückstand ist an die Welle gebunden, nicht an diesen Slice.

## Verdikt

Kein HIGH — Merge-fähig unter zwei offenen Verträgs-Spannungen, die die Welle ohnehin bearbeitet (F-1, F-2). F-3 und F-4 sollten in der Closure-Notiz dieses Slices angesprochen sein, bevor er nach `done/` geht; F-4 ist durch die Unumkehrbarkeit der Zeile nur über die Closure-Doku zu entlasten.

---

## Addendum — Abgleich-Runde über Commit `083323e1` (CR 0.28.1, Folgestellen-Pull nach diesem Report)

**Gegenstand:** `083323e1` ändert ausschließlich `spec/lastenheft.md` (9+, 5−): Header 0.28.0 → 0.28.1; LH-FA-07-Minimal-Satz; LH-QA-04-Anforderung; Historie-Zeile 0.28.1 (Übergangs-Aussage, MR-042-Korrektur an 0.28.0 dokumentiert).

**Fassung je Befund:**

- **F-1 — gelöst.** LH-FA-07 (`spec/lastenheft.md:195`–`:197`) sagt jetzt *„a-check läuft make-getrieben, netzlos, read-only — das emittierte Repo braucht über `git` hinaus nichts außer den Gate-Werkzeugen des jeweiligen Gate-Wegs … Tool-/Versions-Check am Host oder gepinnte Images"*. Der Satz ist in sich geschlossen (git plus je-Weg-Werkzeuge) und widerspricht der LH-QA-03-Fassung nicht mehr. Der Doppel-Verweis auf LH-QA-03 (im Bullet-Kopf und inline) ist Stil, kein Befund.
- **F-2 — gelöst.** LH-QA-04 (`:597`–`:601`) sagt jetzt *„je Gate-Weg trägt das Tool die dortige Werkzeug-Form"* — gepinnte Images über Host-`docker` **oder** den Tool-/Versions-Check des docker-los Wegs. Die Kollision ist aufgelöst, der Docker-Desktop-Satz steht jetzt nur noch als Weg-Beschreibung, nicht als Pflicht.
- **F-3 — gelöst.** Die 0.28.1-Zeile (`:692`) trägt die Übergangs-Aussage ausdrücklich: *„das Inventar-Soll und der Tool-/Versions-Check sind Ziel-Bild; die Mechanik folgt in welle-ohne-docker (MR-015 Doc-führt, Präzedenz 0.6.0)"*. Die Präzedenz ist nachprüfbar — Zeile 0.6.0 (`:664`) sagt *„Implementierung folgt als späterer Slice (Doc-führt)"* und trägt dieselbe Struktur (Ziel-Bild im Vertrag, Umsetzung folgt). Das Anforderungs-/Messmethode-Nennen des Konstrukts ist damit als Ziel-Bild deklariert statt als ungedeckte Zusage.
- **F-4 — gelöst im Rahmen der Regel.** Die 0.28.0-Zeile bleibt unverändertes Protokoll; die Korrektur ist in der 0.28.1-Zeile dokumentiert (*„die Klausel ‚Getrieben von welle-ohne-docker' … entbehrt nach MR-042 des Orts — der Anlass steht in der Closure-Notiz des Slices"*). Die Form folgt Präzedenz 0.14.1 (`spec/lastenheft.md:673`, *„Korrektur an 0.14.0"* — dokumentierte Rücknahme an einer erläuternden Stelle statt Umschreiben des Protokolls); Präzedenz verifiziert. Der Anlass selbst steht jetzt in der Closure-Notiz aufzunehmen — Übergabe an die Closure (Planner), nicht an diesen Abgleich.
- **F-6 — gelöst für die abgleichende Hälfte.** Die neuen Zusage-Elemente sind jetzt als Ziel-Bild deklariert, und die 0.28.1-Zeile trägt eine vollständige Grade-Begründung nach Präzedenz-Form (*„Patch, weil 0.28.1 die Aussage von 0.28.0 über die Folgestellen zu Ende führt; keine neue Anforderung, keine Messmethode geändert"* — beides hält: Anforderung geändert nur in LH-FA-07/LH-QA-04, Messmethoden unberührt). Die komprimierte 0.28.0-Begründung bleibt Bestand-Protokoll.
- **F-7 — gelöst.** Der Übergangs-Satz ist jetzt ausdrücklich in der 0.28.1-Zeile („Ziel-Bild … Mechanik folgt"), statt implizit.

**Formkörper der 0.28.1-Zeile — geprüft, ohne Befund:** eigener Commit ausschließlich `spec/lastenheft.md` (`git show --stat 083323e1` → 1 Datei); Verweis-Spalte *„Nutzer-Entscheidung 2026-11-27"*; Header konsistent 0.28.1; Commit-Message trägt die Slice-Kennung und `LH-QA-03`; alle Links der Zeile lösen (`#lh-fa-07--arch-gate-baseline-emittieren`, `#lh-qa-04--plattform-matrix`, `#mr-015--…` via `<a id>` in `harness/conventions.md:120`, `../harness/conventions/MR-042-….md` existiert). Der vom Koordinator behobene `lh-qa-07`-Anker-Typo ist im Bestand nicht mehr vorhanden (`grep -i 'lh-qa-07' spec/lastenheft.md` → 0 Treffer). Die 0.28.1-Zeile nennt die MR-015-Setzung-2-Abweichung nicht erneut — der Folgestellen-Commit gehört derselben Move-Reihenfolge an; Präzedenz 0.27.1 (`:687`, Nachzug-Zeile ohne erneute Abweichungs-Benennung) deckt das, kein Befund. `grep -n 'lh-qa-07'` → 0.

**Verbleibend offen:**

1. **F-5 als verbleibende Übergabe** — ich sehe es so wie der Koordinator: das `AGENTS.md`-Zitat (`:417` *„Bootstrap-Laufzeit braucht git + docker"* und §3.9 *„der Host braucht git, docker und GNU make, sonst nichts (LH-QA-03, ADR-0003)"*) ist Briefing-Drift gegen die neue Fassung der zitierten Quelle. `AGENTS.md` §3 ist ein Architect-Artefakt (§3.8) — der Träger ist der Architect-Slice der Welle, dessen DoD die §3.9-Fassung trägt; der Abgleich-Commit hätte sie nicht anfassen dürfen. F-5 bleibt als offene Übergabe an denselben benannt, nicht geschlossen.
2. **Review-Report liegt uncommitted** — `git status --short` → `?? docs/reviews/2026-11-27-slice-cr-lh-qa-02-03-ohne-docker.md`. Die 0.28.1-Zeile verweist auf ihn als Code-Span (`docs/reviews/2026-11-27-slice-cr-lh-qa-02-03-ohne-docker.md`, kein Markdown-Link — kein d-check-Link-Objekt), aber bis der Report committet ist, zeigt der Verweis im gemergten Stand ins Leere. Übergabe an den ausführenden Lauf; keine produktive Änderung durch den Reviewer.
3. **Nicht gefahrene Sensoren bleiben** wie oben — `make docs-check` und `make gates` (Docker aus, Stop-Hook per Marker ausgesetzt); der Nachweis der Link-Pflege beider CR-Commits ist der CI-Lauf auf dem Push. Der Abgleich-Commit `083323e1` lag im Push nicht allein an der Spitze; Stand hier unverändert offen.

**Fassung der Verbleib-Quelle:** F-1 bis F-4 und F-6/F-7 sind zum Stand `083323e1` gelöst oder mit dokumentierter Korrektur entlastet; offen sind F-5 (Architect-Slice der Welle), der uncommitted Report und die nicht gefahrenen Sensoren.
