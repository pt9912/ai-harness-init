# Slice slice-013: Ausfüll-Templates referenzieren + Slice-Köpfe auf v3.1.0-Form

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem die Datei liegt
(`open/` · `next/` · `in-progress/` · `done/`), Wechsel nur per `git mv` — v3.1.0-Konvention
(`modul-05`).

**Welle:** ohne Welle (Harness-Wartung). Einordnung *(Kontext, nicht normativ)*:
[roadmap](../in-progress/roadmap.md).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage), [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert) (dieser Slice erzeugt ihn).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-16. **Umgesetzt:** 2026-07-17.

**Kurs-Wechsel während der Umsetzung (2026-07-17):** Der Slice war als „Template-Kopien
auf v3.1.0 patchen" geplant. Ein Diff der Repo-Kopien gegen den vendorten v3.1.0-Baum
zeigte: alle fünf Kopien sind **verbatim/nachhinkend** (null Adaptionen), unreferenziert,
d-check-exempt. Statt sie zu patchen (und beim nächsten Bump erneut) werden sie
**gelöscht und referenziert** ([`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert), Nutzer-Entscheidung). Das
löst die Wartungsklasse dauerhaft. Damit entfallen zwei ursprüngliche Teilaufgaben
ganz (Template-Link-Pins und der `ADR-<NN>`-Platzhalter — beide lebten **nur** in den
gelöschten Templates).

---

## 1. Ziel

Zwei zusammenhängende Nachzüge, beide in *einer* Review-Sitzung prüfbar:

1. **Ausfüll-Templates referenzieren statt kopieren ([`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)).** Die fünf
   Repo-Kopien (`slice.template.md`, `welle.template.md` unter `docs/plan/planning/`,
   `NNNN-titel.template.md` unter `docs/plan/adr/`, `carveout.template.md` (Carveouts),
   `review-report.template.md` unter `docs/reviews/`) werden
   **gelöscht**. Einzige Quelle wird
   die committet vendored Baseline `.harness/baseline/<tag>/templates/…`; ein neues
   Artefakt entsteht per `cp` von dort. **Empirische Grundlage (2026-07-17 gemessen):**
   jeder Diff der Kopien gegen den vendorten Baum war reines Upstream-Lag (null
   Adaptionen), nichts Stabiles referenziert sie (kein Makefile/Hook/Test/README),
   sie sind ohnehin d-check-exempt. Das Kopier-Modell war hier reine Wartungskosten.
   Damit **entfallen zwei ursprüngliche Teilaufgaben ganz:** die Template-Link-Pins
   (`templates-v4` → `v3.1.0` in den Templates) und der `ADR-<NN>` → `ADR-<NNNN>`-Platzhalter
   — beide lebten **nur** in den nun gelöschten Templates.
2. **Slice-Köpfe: Status-Feld → Lifecycle-Notiz** auf den **echten** aktiven Slices.
   Der Slice-Kopf verliert `**Status:**` ersatzlos; an seine Stelle tritt die v3.1.0-Notiz,
   dass **das Verzeichnis der Zustand ist**. Reine Konformität. Betrifft `open/slice-001…005`,
   `open/slice-015`, `next/slice-014` und diesen Slice selbst. **`welle.template.md`
   ist gelöscht** (Punkt 1) — die Welle-Status-Frage stellt sich damit nicht mehr im
   Repo; die vendored `welle.template.md` behält ihr Feld (v3.1.0 streicht nur den
   *Slice*-Kopf).

Ebenfalls hier (Reste der Link-Pin-Klasse auf **echten** Dateien, nicht Templates):
`templates-v4` → `v3.1.0` in `open/slice-001…005`, `in-progress/roadmap.md` und dem
`harness.mk`-Kopfkommentar.

**Abgrenzung.** Mechanik/Vendoring: slice-011. Tote Quellen-Pointer und
§Baseline-Stand: slice-012. Die **inhaltlichen** Nachzüge (Reviewer-Skill-Pflichtkontext,
Wellen-Closure-Prozedur): slice-014. Der d-check-Pin-Sprung ist ein eigener Slice mit
eigenem Risiko (Ziel-Version bewusst **nicht** hier genannt — sie bewegte sich am
2026-07-17 viermal an *einem* Tag; maßgeblich ist `git tag` im d-check-Repo, der Pin
steht in `harness/conventions.md` §Baseline). **`done/` bleibt Archiv** — die
abgeschlossenen Slices behalten Status-Feld und `templates-v4`-Pins (bewusste
Entscheidung, siehe §6).

## 2. Definition of Done

- [ ] Die fünf Repo-Template-Kopien sind **gelöscht** (`slice.template.md`,
      `welle.template.md`, `NNNN-titel.template.md`, `carveout.template.md`,
      `review-report.template.md`); [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert) trägt die Adaption
      (Referenz statt Kopie) mit dem empirischen Nutzen-Beleg. Vor dem Löschen belegt,
      dass **nichts Mechanisches** sie referenziert (`grep` über
      Makefile/Hooks/Tests/Codex/READMEs → 0).
- [ ] Ein neues Artefakt lässt sich aus dem vendored Baum erzeugen — vorgeführt:
      `cp .harness/baseline/$(BASELINE_TAG)/templates/docs/plan/planning/slice.template.md …`
      liefert die v3.1.0-Ziel-Form (Lifecycle-Feld, `ADR-<NNNN>`, aktuelle Anker).
- [ ] `**Status:**` → `**Lifecycle:**`-Notiz in `open/slice-001…005`, `open/slice-015`,
      `next/slice-014` und diesem Slice (Verzeichnis = Zustand, Wechsel nur per `git mv`).
      `done/` unberührt (Archiv, s. §6).
- [ ] Rest-Link-Pins `templates-v4` → `v3.1.0` auf **echten** Dateien:
      `open/slice-001…005`, `in-progress/roadmap.md`, `harness.mk`-Kopfkommentar;
      jeder geänderte Link per `curl` erreichbar belegt
      ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
- [ ] `make gates` grün; Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/plan/planning/*.template.md` (slice, welle) | **löschen** | referenziert statt kopiert ([`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)) |
| `docs/plan/{adr,carveouts}/*.template.md`, `docs/reviews/*.template.md` | **löschen** | dito |
| `harness/conventions.md` | update | neuer [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert) |
| `docs/plan/planning/open/slice-001…005` | update | Link-Pins + Status → Lifecycle |
| `open/slice-015-zitat-sensor.md`, `next/slice-014`, dieser Slice | update | Status → Lifecycle |
| `docs/plan/planning/in-progress/roadmap.md`, `harness.mk` | update | Rest-Link-Pins |

## 4. Trigger

Nach slice-012 (Reihenfolge ist Bequemlichkeit, keine harte Abhängigkeit — die
Änderungen überschneiden sich nicht).

**Überschneidung mit slice-014 — nicht datei-disjunkt.** Der Status-Sweep (DoD 3)
erfasst *alle dann noch aktiven* Slice-Köpfe, also auch `next/slice-014-…md:3`,
solange slice-014 nicht in `done/` liegt. Die Berührung ist **eine Zeile** (das
Kopf-Feld), aber sie existiert: die beiden Slices **nicht parallel** fahren, sonst
Merge-Konflikt genau dort. Reihenfolge egal — läuft slice-014 zuerst durch nach
`done/`, greift für ihn die Archiv-Regel und der Sweep lässt ihn aus; läuft
slice-013 zuerst, nimmt der Sweep slice-014s Kopf mit.

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **Kurs-Wechsel mitten in der Umsetzung — und warum er trotzdem *ein* Slice bleibt.**
  Geplant war „Template-Kopien patchen". Der Ist-Zustand-Diff (die slice-012-Lehre,
  angewandt) zeigte, dass die Kopien verbatim/nachhinkend und unreferenziert sind →
  Referenz-Modell ([`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert), Nutzer-Entscheidung). Das ist kein Scope-Creep,
  sondern eine **Vereinfachung**: zwei Teilaufgaben (Template-Link-Pins, ADR-Platzhalter)
  entfallen ersatzlos, weil ihr Gegenstand gelöscht wird. Der Slice bleibt in *einer*
  Review-Sitzung prüfbar (Modul-5-Kriterium 3). **Preis der Abweichung:** ein
  Referenzpfad trägt den Tag und repinnt beim Bump — bewusst getragen, s.
  [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert) (Auflösungs-Trigger: sobald ein Template eine echte Repo-Adaption
  braucht, wird *es* wieder als Kopie geführt).
- **Anker-Beinahe-Fehler bewahrt (Zwei-Bäume-Falle, 3. Mal).** Der ursprüngliche Plan
  wollte zwei „tote Anker" auf `#ziel-form-…` umbiegen — verifiziert gegen den `lab`-Baum.
  Die Template-Links zeigen aber auf den **Kurs**, der die `## Worked Example …`- und
  `## Worked Mini-Example …`-Überschriften **behalten** hat (WebFetch gegen
  `kurs/de/` @ v3.1.0). Die Anker waren nie tot; Umbiegen hätte sie gebrochen. Mit dem
  Löschen der Templates ist der Punkt gegenstandslos — aber die Lehre bleibt: `d-check`
  prüft URL, nicht Fragment; Kurs-Anker gegen die **Kurs-Datei** verifizieren.
- **Offen — die „≤ 3 DoD-Punkte"-Regel ist in v3.1.0 nicht entscheidbar.** Modul 5
  hebt sie von der Faustregel zum **Regeltext**: „**Zu groß**, wenn eines zutrifft:
  mehr als drei DoD-Punkte · mehrere Schichten betroffen · nicht in *einer*
  Review-Sitzung prüfbar" (`modul-05:71-73`), und „Jeder Schnitt-Slice ist **einzeln
  lieferbar** […], hat **≤ 3 DoD-Punkte** und berührt **höchstens zwei Schichten**"
  (`modul-05:78-80`). **Aber v3.1.0 widerspricht sich selbst**
  (die eigene Vorlage liefert **5** DoD-Checkboxen) **und hat die Einheit
  wegdidaktisiert:** das `SL-014`-Worked-Example, das in v1.2.0 noch definierte, was
  ein DoD-Punkt *ist* (`SL-014a` = **ein Satz mit drei Klauseln** = „3 DoD-Punkte"),
  ist ab v3.0.0 ersatzlos entfallen — Modul 5 schrumpfte von **219 auf 120 Zeilen**,
  „Faustregel" und `SL-014` kommen null Mal vor (gemessen 2026-07-17 gegen den
  **adoptierten** v1.2.0-`lab-regelwerk`-Baum, nicht gegen `kurs/de/` — die beiden
  Bäume sind nicht deckungsgleich: die didaktische Kurs-Fassung desselben Moduls
  hat 300 Zeilen und führt `SL-014` weiterhin). Damit ist
  „zählt die Regel Häkchen oder Verhaltens-Zusagen?" **nicht mehr aus dem geltenden
  Text belegbar**, nur noch aus der Historie erschließbar. Wer die Zahl wörtlich auf
  Häkchen anwendet, bricht sie mit der Vorlage der Baseline selbst; wer sie auf
  Zusagen anwendet, liegt bei jedem Repo-Slice weit über 3. **Erst klären, dann
  schneiden** — dieser Slice ist bewusst nach Kriterium 3 („eine Review-Sitzung")
  geschnitten, das in *beiden* Lesarten unstrittig ist, nicht nach der Zahl. Danach
  ggf. eigener Slice, und nur für `open/`. `done/` bleibt unberührt.
- **`done/` bleibt Archiv — bewusste Entscheidung, keine Auslassung.** Die fünf
  abgeschlossenen Slices behalten Status-Feld und `templates-v4`-Pins. Begründung:
  sie sind Nachweis dessen, was zum Abschlusszeitpunkt galt; ein Archiv nachträglich
  auf eine neue Konvention zu ziehen, erzeugt Diff-Rauschen ohne Erkenntnisgewinn.
  Folge, die zu tragen ist: `grep`-Ergebnisse über `docs/plan/planning/` sind ab hier
  gemischt (Archiv alt, aktiv neu) — wer den Bestand zählt, muss `done/` ausnehmen.
- **Kein Handlungszwang bei `closure-note-reviewer.md`.** Der Skill ist **keine** neue
  Pflicht-Rolle (stand schon in v1.2.0; neu ist nur eine Vorlage). Die Vorlage
  verdrahtet ein Python-Tool und wäre 1:1 kopiert ein Verstoß gegen
  [`ADR-0003`](../../adr/0003-go-native-binaries.md) — und nach dem eigenen Reviewer-Skill selbst ein HIGH
  („halluziniertes Gate"). Die vorbestehende Lücke (Closure-Notiz-Pflicht ohne jeden
  Sensor) ist real, aber älter als dieses Upgrade → Kandidat für `open/`.
- **Kein Schema-Wechsel bei LH-IDs.** Modul 3 schreibt `<PREFIX>-FA-NNN`
  (dreistellig), das v3.1.0-eigene `lastenheft.template.md` `<NN>` (zweistellig) —
  ein Widerspruch **innerhalb** v3.1.0. Nicht als Schema-Wechsel lesen;
  `.d-check.yml` bleibt unangetastet.

## 7. Closure-Notiz (nach `done/`)

**Abschluss 2026-07-17.** Commits: Move nach `in-progress/` (reiner `git mv`),
Implementierung (`1b2428d`), Review-Nachtrag + Closure (dieser), Move nach `done/`.

**Geliefert.** (1) Die fünf Repo-Template-Kopien gelöscht; [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert) macht die
vendored Baseline zur einzigen Quelle (Referenz statt Kopie), mit Abgrenzung gegen
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
(emittierte Struktur bleibt co-located — kein Widerspruch). (2) Status-Feld →
Lifecycle-Notiz auf allen sechs aktiven Slice-Köpfen (`open/001…005`, `open/015`,
`next/014`, dieser Slice). (3) Rest-Link-Pins `templates-v4` → `v3.1.0` auf echten
Dateien (`open/001…005`, `roadmap.md`, `harness.mk`).

**Zwei beobachtbare Closure-Kriterien.**
1. **`make gates` grün**: baseline-verify OK, d-check 37 / 0 Befunde, bats 47/47,
   shellcheck clean.
2. **DoD 2 vorgeführt**: `cp .harness/baseline/$(BASELINE_TAG)/templates/…/slice.template.md`
   liefert die v3.1.0-Ziel-Form (Lifecycle-Feld, `ADR-<NNNN>`) — das Referenz-Modell
   ist nicht nur behauptet, sondern erzeugt ein korrektes Artefakt.

**Steering-Loop-Lerneintrag — geschärfte Regel + benannte Spec-Lücke.**
- **Geschärfte Regel (bestätigt slice-012):** *Bei Slice-Start den Ist-Zustand gegen
  den Plan messen.* Der Diff der Template-Kopien gegen den vendorten Baum (statt
  Blind-Patch) deckte auf, dass mein handabgeleiteter Plan zwei v3.1.0-Änderungen
  übersah **und** dass die Kopien null Adaptionen tragen — woraus der Referenz-Wechsel
  folgte. Ohne die Messung hätte der Slice throwaway-Arbeit patchen und beim nächsten
  Bump wiederholen müssen.
- **Zwei-Bäume-Falle, 3. Mal — jetzt mit Sensor-Kandidat.** Der Ursprungsplan wollte
  zwei „tote Anker" umbiegen (verifiziert gegen den `lab`-Baum), die im **Kurs** (dem
  echten Link-Ziel) quicklebendig sind. `d-check` prüft URL, nicht Fragment. Das ist
  dieselbe Klasse, die schon zweimal zuschlug (Reviewer-Refutationen, Wave-Self-Close).
  **Benannte Spec-Lücke:** kein Gate verifiziert externe Anker-Fragmente; ein
  „anchor-check gegen die Ziel-Datei" wäre der Sensor. Kandidat für `open/`, verwandt
  mit slice-015 (auch dort: kein Gate für eine Faktentreue-Klasse).
- **Review-Wert:** Der Review fand die fehlende
  [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)-Abgrenzung
  (INFO) — im Closure-Nachtrag ergänzt, bevor slice-003 sie überträgt.

**Restrisiken.** Tag im Referenzpfad (repinnt mit `BASELINE_TAG`, [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert));
`docs/plan/carveouts/*` verschwand mit dem Template (benigne, kehrt beim ersten
Carveout zurück — [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)).

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe
[Kurs Modul 5](https://github.com/pt9912/ai-harness-course/blob/v3.1.0/kurs/de/02-planung/modul-05-planning-harness.md)):
Planning-Doku und Vorlagen teilen die adoptierte Harness-Mechanik
([`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)); GF (Doc führt).
