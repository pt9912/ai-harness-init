# Slice slice-014: Reviewer-Pflichtkontext und Wellen-Closure-Prozedur

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem die Datei liegt
(`open/` · `next/` · `in-progress/` · `done/`), Wechsel nur per `git mv` —
v3.1.0-Konvention (`modul-05`).

**Welle:** ohne Welle (Harness-Wartung). Einordnung *(Kontext, nicht normativ)*:
[roadmap](../in-progress/roadmap.md).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-17.

---

## 1. Ziel

Die zwei Stellen, an denen v3.1.0 inhaltlich **mehr** verlangt als der adoptierte
Stand — im Unterschied zu slice-013 keine Textersetzung, sondern zwei fehlende
Inhalte. Beide gegen v3.1.0 verifiziert (2026-07-17).

1. **Reviewer-Kontext-Eingang.** v3.1.0 führt ihn als „Operativen Pflichtteil"
   (`regelwerk/modul-10-review-harness.md:54-57`, wortgleich): „**Kontext-Eingang
   (Pflicht):** Diff · `spec/lastenheft.md` · ADRs, deren ID im PR/Commit vorkommt ·
   `AGENTS.md` §Hard Rules · vorherige Findings am gleichen Modul. Ohne den Block
   sieht der Reviewer Code, aber nicht die Verträge, gegen die er prüft."
   **Vorherige Findings am gleichen Modul** ist der einzige der fünf Punkte, den
   `.harness/skills/reviewer.md` heute nicht führt.
2. **Wellen-Closure-Prozedur.** Der adoptierte Stand (v3.1.0) schreibt fünf Schritte
   mit Beleg vor (`.harness/baseline/v3.1.0/regelwerk/modul-06-roadmap.md:53-84`):
   Trigger prüfen · **Carveout-Audit** · Closure-Notiz · **Wave-Self-Close-Commit** ·
   **Roadmap-Fortschreibung**. „Erst wenn alle fünf Belege vorliegen, ist die Welle
   *auditierbar* geschlossen." `welle-01-offline-kern.md` §3 (vor v3.1.0 geschrieben)
   deckte nur Schritt 1 und 3; die anderen drei fehlten. **Historische Notiz:** Die
   formalisierte Prozedur samt Begriff *Wave-Self-Close-Commit* ist v3.1.0-neu; der
   frühere adoptierte v1.2.0-Stand führte sie nicht (der damalige Cache-Beleg ist seit
   slice-011 entfernt — die Aussage steht als Historie, nicht mehr lokal nachmessbar).
   Warnung fürs Nachmessen: den **lab-Baum** heranziehen (`.harness/baseline/…`), nicht
   die didaktische `kurs/de/`-Fassung — die beiden divergieren.

**Abgrenzung.** Mechanik/Vendoring: slice-011. Tote Quellen-Pointer und §Baseline-Stand:
slice-012. Template-Referenzierung ([`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)) + Status→Lifecycle auf allen
aktiven Slices: slice-013 — **bereits `done/`**; sein Status-Sweep hat den Kopf *dieser*
Datei schon auf Lifecycle gezogen, die frühere Nicht-Parallelitäts-Auflage ist damit
erledigt. Der d-check-Pin-Sprung ist ein eigener Slice mit eigenem Risiko (Ziel-Version
bewusst nicht genannt — s. slice-013 §Abgrenzung).

## 2. Definition of Done

- [ ] `.harness/skills/reviewer.md` §Eingangs-Kontext führt „vorherige Findings am
      gleichen Modul"; Skill-Version gehoben (versioniert, **nicht** überschrieben —
      Modul 10). Die übrigen vier Pflicht-Punkte sind als vorhanden belegt (Grep),
      nicht angenommen.
- [ ] `welle-01-offline-kern.md` §3 trägt die drei fehlenden Closure-Schritte
      (Carveout-Audit · Wave-Self-Close-Commit · Roadmap-Fortschreibung) und nennt
      die Closure-Notiz unter `done/` (heute ohne Präfix, `:29`) — konsistent mit
      `docs/plan/planning/README.md:26`.
- [ ] `make gates` grün; Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.harness/skills/reviewer.md` | update | Pflicht-Kontext-Eingang (Modul 10), Version-Bump |
| `docs/plan/planning/welle-01-offline-kern.md` | update | Closure-Prozedur Schritte 2/4/5 + `done/`-Pfad |

## 4. Trigger

Inhaltlich unabhängig von slice-013 startbar, aber **nicht parallel** dazu (eine
Zeile Überschneidung im Kopf dieser Datei, s. §Abgrenzung). Sinnvoll nach slice-012,
weil der Reviewer-Skill dann auf eine erreichbare Quelle zeigt.

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **Der Skill wird versioniert, nicht überschrieben.** Modul 10 verlangt das
  ausdrücklich. Ein überschriebener Skill macht die Frage „gegen welche Fassung
  wurde damals geprüft?" unbeantwortbar — genau die Auditierbarkeit, die der
  Review-Harness herstellen soll.
- **Die Welle-Datei ist `in-progress`, nicht Archiv.** `welle-01-offline-kern.md`
  beschreibt eine **laufende** Welle; die Closure-Prozedur nachzutragen ändert die
  Regeln, nach denen sie schließt, *bevor* sie schließt. Das ist zulässig (die Welle
  hat noch keinen Closure-Trigger ausgelöst), aber es ist eine Änderung an einem
  aktiven Artefakt — im Review explizit zu prüfen, nicht als Doku-Kosmetik
  durchzuwinken.
- **Offen: `lastenheft_refs` vs. Klartext-`**Bezug:**`-Zeile.** Modul 15 streicht die
  Notiz, die die Klartext-Variante ausdrücklich erlaubte; Modul 16 fordert unverändert
  „Slices tragen `lastenheft_refs`" mit Beleg „Frontmatter-Grep". Das Repo fährt
  durchgehend Klartext und hat kein Frontmatter — entlastend liefert die vendored
  v3.1.0-Vorlage (`.harness/baseline/v3.1.0/templates/docs/plan/planning/slice.template.md`,
  [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)) **selbst** die Klartext-Form. Nicht akut (keine Welle in
  Freigabe, kein Release-Verzeichnis im Repo), aber die Wahl gehört als eigener
  MR-Eintrag festgeschrieben, bevor sie an einer gestrichenen Kurs-Notiz hängt.
- **Zur DoD-Länge.** Dieser Slice liegt bei 3 Häkchen und zwei Dateien in zwei
  Sub-Areas — unter jeder Lesart der „≤ 3 DoD-Punkte"-Regel unauffällig. Die
  Einheiten-Frage selbst ist in v3.1.0 nicht entscheidbar und in slice-013 §6
  dokumentiert; sie blockiert diesen Slice nicht.

## 7. Closure-Notiz (nach `done/`)

**Abschluss 2026-07-17.** Commits: Move nach `in-progress/` (reiner `git mv`),
Implementierung (`8d719c8`), Review-Fix + Closure (dieser), Move nach `done/`.

**Geliefert.** (1) `.harness/skills/reviewer.md` §Eingangs-Kontext führt „vorherige
Findings am gleichen Modul" (v3.1.0 `modul-10:54-57`); Version 1.0.0 → 1.1.0,
Baseline-Referenz auf v3.1.0 nachgezogen. (2) `welle-01-offline-kern.md` §3 von 2 auf
5 Closure-Schritte (v3.1.0 `modul-06:53-84`: + Carveout-Audit, Wave-Self-Close-Commit,
Roadmap-Fortschreibung), Closure-Notiz-Pfad auf `done/welle-01-results.md`. (3)
Reconciliation der veralteten Referenzen in slice-014 selbst (gelöschter Cache/Template).

**Zwei beobachtbare Closure-Kriterien.**
1. **`make gates` grün**: baseline-verify OK, d-check 38 / 0 Befunde, bats 47/47,
   shellcheck clean.
2. **Alle 5 Pflicht-Punkte per Grep belegt** (nicht angenommen); beide Kurs-Links
   (Modul 6/7) per `curl` HTTP 200; die 5 welle-01-Schritte per `sed` gegen
   `modul-06:53-84` deckungsgleich.

**Steering-Loop-Lerneintrag — geschärfte Regel.** *Bei „ergänzen"-DoDs den
Vorher-Nachher-Diff der Liste prüfen, nicht nur die Präsenz des neuen Elements.* Der
Review fand F-1: der reviewer.md-Rewrite hatte „den Slice-Plan" **still gestrichen**
(1-zu-1-Tausch statt Ergänzung) — ein Verstoß gegen genau das Modul-10-Prinzip
(versioniert, nicht überschrieben), das dieser Slice einführt. Behoben (Slice-Plan als
Repo-Ergänzung wiederhergestellt, 6 Elemente). Der Review am Reviewer-Skill hat die
Regel des Reviewer-Skills durchgesetzt — der beste Beleg für seinen Wert.

**Restrisiken.** F-2 (LOW): die Commit-Message von `8d719c8` zitiert `modul-10:54-56`
statt `54-57`; der **Dateitext** ist korrekt, die Message immutable — kein
History-Rewrite dafür. F-3 (INFO): `roadmap.md:21-22` trägt eine
Closure-Trigger-Kurzfassung, die auf §3 verweist (nicht veraltet, könnte aber driften).

**Regelwerk-Zug abgeschlossen.** slice-011…014 bringen das Repo auf die Baseline v3.1.0
(vendored, Quellen-Wahrheit, Referenz-Modell, inhaltliche Nachzüge). Offen als
`open/`-Kandidaten: slice-015 (Zitat-Sensor, blockiert), der d-check-Pin-Sprung, ein
Anker-Fragment-Sensor, `lastenheft_refs`-Klärung (slice-014 §6).

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe
[Kurs Modul 5](https://github.com/pt9912/ai-harness-course/blob/v3.1.0/kurs/de/02-planung/modul-05-planning-harness.md)):
`.harness/skills/` und die Planning-Doku teilen die adoptierte Harness-Mechanik
([`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)); GF (Doc führt).
