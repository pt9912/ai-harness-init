# Review-Report: ADR-0072 Konsistenzrunde — 2026-09-29

**Review-Art:** ADR-Konsistenzprüfung — die Runde, die der Acceptance-Trigger der ADR (§Der
Acceptance-Trigger) vor der Annahme verlangt.

**Gegenstand:** `docs/plan/adr/0072-ziel-fassung-regiert-den-sprung-v6130.md` — Commit
`1abe98b4`, Status `Proposed`. Die ADR ist die §4-Start-Bedingung des Sprung-Slice
`slice-sprung-auf-v6130-wird-vollzogen`
([`../../docs/plan/planning/next/slice-sprung-auf-v6130-wird-vollzogen.md`](../../docs/plan/planning/done/slice-sprung-auf-v6130-wird-vollzogen.md)).

**Report-Kennung für den Accept-Übergang** ([ADR-0040](../../docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
Festlegung 1: Kennung, kein Pfad-Link): `2026-09-29-adr-0072-konsistenzrunde`

**Skill:** `.harness/skills/reviewer.md` @ Version 2.3.0 (2026-09-27)
**Modell:** glm-5.3-flash · **Datum:** 2026-09-29 · frischer Kontext; kein früherer Report zu
dieser ADR liegt in `docs/reviews/`.

**Eingangs-Kontext:**

- die ADR selbst (Commit `1abe98b4`)
- die fünf im Acceptance-Trigger genannten Vergleichs-ADRs: [ADR-0018](../../docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md),
  [ADR-0043](../../docs/plan/adr/0043-ziel-fassung-regiert-den-sprung-v671.md),
  [ADR-0047](../../docs/plan/adr/0047-ziel-fassung-regiert-den-sprung-v680.md),
  [ADR-0056](../../docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md),
  [ADR-0040](../../docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) — sämtlich `Accepted`
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules)
- Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR)
- der Sprung-Slice-Plan (s. o.), `harness/migration.md` §3, `harness/conventions.md` §Baseline
- Kurs-Klon `K` (Host-Voraussetzung, [ADR-0052](../../docs/plan/adr/0052-host-lokaler-pfad-in-eingefrorenen-artefakten.md)) — strikt nur lesen (`git log`/`diff`/`show`)

---

## Die drei benannten Prüfgegenstände

### 1. Delegat-Abwägung — bestätigt

Die ADR führt die Abwägung, die der zweite Re-Evaluierungs-Trigger von
[ADR-0047](../../docs/plan/adr/0047-ziel-fassung-regiert-den-sprung-v680.md) verlangt, und stützt sie auf die
gemessene Wirkungslosigkeit des Delegat-Deltas (Festlegung 1, Grund 1). Die Messung ist real:
`modul-04-adrs.md` trägt +39/−6, bestehend aus dem neuen Abschnitt *„Nachzug ist keine
Überschreibung"* und der Regel zur Wächter-Aufnahme in den PR-blockierenden Satz — beide am Tag
`v6.13.0` verbatim geprüft, die Charakterisierung der ADR (§Stufe (b)) trifft den Inhalt. Keine
der drei Durchgangs-Stellen liest diese Texte: die Adaptions-Frage („Regelt die neue Fassung das,
wofür diese Adaption angelegt wurde?") und die fünf Ausgänge stehen im byte-gleichen
Prozedur-Abschnitt, der Form-Durchgang arbeitet auf Vorlagen-Diffs, die Stichprobe liest
Abschnitte ohne Delta. **In beide Richtungen geprüft:** *zu viel* behauptet die ADR nicht — sie
verwirft ausdrücklich die allgemeine Regel „bei byte-gleicher Prozedur regiert die Ziel-Fassung"
(§Was diese Festlegungen nicht tun) und hält in ihrem vierten Re-Evaluierungs-Trigger die
Wieder-Öffnung für ein Delegat-Delta bereit, das einen Durchgang anders laufen ließe; *zu wenig*
behauptet sie nicht — die Wahl ist nicht beliebig, weil Grund 1 jedes inhaltliche Gegenargument
nimmt und Grund 2 (Tag-Klammer) trägt, dieselbe tragende Struktur wie in den angenommenen
Vorgängerinnen. Die Prozedur-Charakterisierung („siebente Eigenschaften", fünf Ausgänge, Delegate)
deckt sich mit dem geprüften `v6.13.0`-Text.

### 2. Delta-Walkthrough je Release — bestätigt

Festlegung 2 lässt die Fragen, Ausgänge und die Volltext-Lesung des Freshness-Audits unangetastet:
die Grundgesamtheit bleibt die volle Liste (71 Einträge, gemessen), die Partition ordnet nur die
Reihenfolge der Lesung der 19 geänderten Dateien, und die Umkehrung („gelesen = gefunden") ist
ausdrücklich **nicht** Regel. Das ist Organisation der Lesung, keine zweite Prozedur — die
Prozedur selbst ist byte-gleich (s. u.), sie kann also durch die Festlegung keinen anderen Text
bekommen haben. Die Release-Attribution je Ausgang ist eine Angabe zum Übergabe-Artefakt, keine
neue Ausgangs-Klasse; die fünf Ausgänge bleiben die geschlossene Menge aus
[ADR-0018](../../docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 4. Ein Randmangel der Rahmen-Formulierung
steht als F-5 (INFO).

### 3. Delta-Basis-Lesart — bestätigt

Die Lesart trägt, und die Lücke ist benannt, nicht still geflickt. Gemessen: der im ADR-Abschnitt
§Die Delta-Basis zitierte Grep gegen `harness/conventions.md` läuft an current HEAD tatsächlich
leer (Exit 1) — die Aufzählung ist durch `fc340eff` (2026-09-18, Setzung des Auftraggebers
„Wir brauchen keine Chronik/Forensik in dieser Datei") gezogen, der Commit wird korrekt zitiert.
Der Schluss *Basis = `v6.9.0`* folgt für diesen Sprung aus dem Zusammenfall von letztem Durchgang
und vendorten Stand, und beide Hälften sind belegt: der Freshness-Durchgang gegen `v6.9.0` lief
am 2026-09-16 (Commit `0b7cd…`/`31ba5903`, „Freshness-Review Adaptions-Block gegen v6.9.0" /
„Baseline-Buchung v6.9.0"), und `ls -1 .harness/baseline/` meldet genau `v6.9.0`. Die offene
Frage, wie künftige Sprünge die Basis **zeigen**, steht ausdrücklich nicht zur Entscheidung
(§Die Delta-Basis, §Was diese Festlegungen nicht tun letzter Punkt, Prüfgegenstand 3); die
Lücke ist im Acceptance-Trigger verankert, nicht verschwiegen. [ADR-0043](../../docs/plan/adr/0043-ziel-fassung-regiert-den-sprung-v671.md)
Festlegung 2 wird gelesen, nicht ersetzt. Der stale Mess-Stand in `harness/migration.md` §3 (der
dort zitierte Grep liest eine zurückgenommene Form) ist in §Konsequenzen als Architekt-Folgepflicht
„mit dem Vollzug" verbucht.

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Re-Evaluierungs-Trigger 2 nennt §Baseline als den Ort, an dem eine Bewegung des Zielstands vor dem Vollzug sichtbar ist — die eigene Kopplung bucht die Zielstand-Setzung auf `v6.13.0` samt Zeiger aber erst **mit dem Vollzug**; bis dahin trägt §Baseline unverändert `v6.9.0`, eine Bewegung des beauftragten Ziels ist dort nicht lesbar, und der Trigger kann in der gebotenen Form nicht feuern. Der Text ist von [ADR-0056](../../docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md) übernommen, deren Kanal deshalb lebendig war, weil dort die Setzung bei ADR-Zeit gebucht wurde (§Konsequenzen: „erledigt"). | [ADR-0072](../../docs/plan/adr/0072-ziel-fassung-regiert-den-sprung-v6130.md) §Re-Evaluierungs-Trigger vs. §Kopplung · [ADR-0056](../../docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Re-Evaluierungs-Trigger 2 | `docs/plan/adr/0072-ziel-fassung-regiert-den-sprung-v6130.md` (§Kopplung, §Re-Evaluierungs-Trigger) | ja — lesbar; Gegenprobe: nach der Kopplung gibt es vor dem Vollzug keinen §Baseline-Zustand, gegen den eine Bewegung lesbar wäre | Re-Evaluierungs-Trigger benennt einen Beobachtungskanal, den die eigene Buchungs-Form leert |
| F-2 | MEDIUM | Die Bezug-Aussage zu [ADR-0056](../../docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md) — „ihr zweiter [Re-Evaluierungs-Trigger] ist eingetreten" — wird vom Bestand widerlegt: Setzung (`8ae647cc`) und Vollzugs-Buchung (`31ba5903`) des v6.9.0-Sprungs fielen auf denselben Tag 2026-09-16; ein Zielstand-Wechsel vor dem Vollzug ist in der History von `harness/conventions.md` nicht erkennbar. ADR-0056 Trigger 2 beschreibt den Verlust ihres Objekts — ihr Sprung ist regulär vollzogen. Die Aussage ist unbelegt und liest sich, als hätte die Vorgängerin ihr Objekt verloren. | [ADR-0056](../../docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Re-Evaluierungs-Trigger 2 · [ADR-0016](../../docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md) (Beleg trägt Tag und Zitat) | `docs/plan/adr/0072-ziel-fassung-regiert-den-sprung-v6130.md` (§Bezug, ADR-0056-Klammer) | ja — `git log --format='%h %ad %s' --date=short -- harness/conventions.md` über 2026-09-15..19; `git log -1 31ba5903` | Bezug-Aussage über einen Trigger-Zustand ohne Beleg |
| F-3 | LOW | Die Zählung „zum siebten Mal" (§Stufe (a)) greift zu kurz: die Kette des zweiten Falls aus [ADR-0018](../../docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 zählt ADR-0031, ADR-0036, ADR-0038, ADR-0043 („zum vierten Mal"), ADR-0044 („zum fünften Mal"), ADR-0047 („zum sechsten Mal") und [ADR-0056](../../docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md) (§Stufe (a) instanziiert den Fall) — der vorliegende Sprung ist das **achte** Mal. Option E („der nächste Sprung erbt die Messpflicht ein achtes Mal") erbt die Verschiebung. | [ADR-0018](../../docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 · [MR-025](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) | `docs/plan/adr/0072-ziel-fassung-regiert-den-sprung-v6130.md` (§Stufe (a), §Verglichene Alternativen Option E) | ja — die Ordinal-Zeilen der Vorgänger-ADRs | Ordinal-Zählung über einer Kette, deren Glieder je ihren eigenen Stand tragen |
| F-4 | LOW | Die Kommando-Ausgabe unter §Die Delta-Basis ist unvollständig abgetragen: `git log --oneline -S 'Delta-Nachweis' -- harness/conventions.md \| head -2` liefert **zwei** Zeilen (`fc340eff`, `31ba5903`); abgetragen ist nur die erste — ausgerechnet die zweite (`31ba5903`, „Baseline-Buchung v6.9.0") ist der Beleg für die Lesart des Abschnitts. | [MR-025](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) · [ADR-0016](../../docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md) | `docs/plan/adr/0072-ziel-fassung-regiert-den-sprung-v6130.md` (§Die Delta-Basis) | ja — Kommando wiederholen | Kommando-Ausgabe unvollständig abgetragen |
| F-5 | INFO | Der Kontext-Satz „sie ordnet nur die Reihenfolge, in der die 19 Dateien gelesen werden" unterbeschreibt die eigene Festlegung 2, die zusätzlich die Release-Attribution je Ausgang setzt — der Acceptance-Trigger (Prüfgegenstand 2) nennt beide Hälften. Ein Durchgang, der sich am Kontext-Satz orientiert, liefert Ausgänge ohne Attribution. | [ADR-0072](../../docs/plan/adr/0072-ziel-fassung-regiert-den-sprung-v6130.md) §Der Delta-Walkthrough | `docs/plan/adr/0072-ziel-fassung-regiert-den-sprung-v6130.md` (§Der Delta-Walkthrough, Schlusssatz) | nein — kein Sensor liest die Attribution | Kontext-Satz führt weniger als die Festlegung, die er einführt |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Realitätsdeckung der Messzahlen (Kurs-Klon, nur lesen) | geprüft, ohne Befund — 27 Dateien +313/−80; Partition 16/+88/−45 · 14/+82/−22 · 8/+103/−17 · 3/+45/−1; keine A/D-Datei; 19 von 26 Regelwerk-Dateien, 8 Vorlagen; 13 Welle-Commits; Wellen-Verteilung 138–142/143–147/148–150/151–153; Meta-Frage-Grep 3× „Übergang" — alle Zahlen tragen |
| Byte-Gleichheit des Prozedur-Abschnitts | geprüft, ohne Befund — Endpoint-Diff 0 **und** zusätzlich alle vier Release-Paare je 0 (v6.9.0→v6.10.0→v6.11.0→v6.12.0→v6.13.0); die Delegaten-Liste (5 Dateien inkl. `modul-06-roadmap.md`) ist an beiden Tags identisch |
| modul-02-Einzeldelta | geprüft, ohne Befund — 1/1, Hunk ist exakt die Outline-Matrix (`LH-RB-*` in die Kennungs-Liste), liegt außerhalb des Prozedur-Abschnitts |
| modul-04-Charakterisierung | geprüft, ohne Befund — +39/−6; neuer Abschnitt „Nachzug ist keine Überschreibung" und die `make gates`-Wächter-Regel am Tag `v6.13.0` verbatim verifiziert; die ADR deutet ihren Inhalt nicht (Prüfgegenstand 1) |
| Konsistenz gegen ADR-0018 | geprüft, ohne Befund — Festlegung 3 (Kriterium, Stufe (a)) angewendet, Festlegung 2 (Prozedur ≠ Ist-Maßstab) in §Das Vorlagen-Delta honoriert, Festlegung 4 (keine Ausgangs-Deutung) explizit begrenzt |
| Konsistenz gegen ADR-0043/0047/0056/0040 | geprüft, ohne Befund in der Sache — Leseregel gelesen statt ersetzt; Trigger-Formen korrekt geführt (F-2 betrifft die Bezug-Aussage, nicht die Trigger der ADR selbst); Acceptance-Trigger in der Form der Vorgängerinnen, Accept-Übergang muss den Report als Kennung nennen |
| Supersedes-Frage | geprüft, ohne Befund — kein `Supersedes`; jede Sprung-ADR bleibt auf ihren Sprung geschlossen, [ADR-0056](../../docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md) bleibt für `v6.8.0` → `v6.9.0` wahr; die Reihe wird ergänzt, nicht abgelöst |
| ADR-nennt-keine-Slices | geprüft, ohne Befund — 0 Slice-Kennungen in der ADR; der Sprung-Slice wird nur als „Sprung-Slice" ohne Kennung genannt |
| Form der Ziel-Vorlage (MADR, `modul-04`) | geprüft, ohne Befund — alle Pflicht-Sektionen vorhanden (Kontext · Entscheidung · Verglichene Alternativen · Konsequenzen · Fitness Function · Re-Evaluierungs-Trigger · Geschichte), Bezug/Schärft/Kopplung/Regeln im Kopf |
| Status-Angaben im Bezug | geprüft, ohne Befund — ADR-0031 und ADR-0052 korrekt als `Proposed` markiert, alle übrigen bezogenen ADRs sind `Accepted` |
| ADR-Index | geprüft, ohne Befund — die Zeile der ADR-0072 steht (Folgepflicht „erledigt: dieser Commit" hält) |
| Emittierte Ebene | geprüft, ohne Befund — `InventurMessTag` (Zeile 36, `internal/emit/baumaussage.go`) steht auf `v6.9.0`, `internal/emit` trägt genau die zwei genannten Dateien; die ADR ändert an der emittierten Ebene nichts außer der Adresse |
| Auto-Kontext-Zahlen | geprüft, ohne Befund — 7 tag-tragende Symlinks, 6 der 19 geänderten Dateien im Auto-Kontext (dreimal so viele wie beim vorigen Sprung: 2), 71 aktive Einträge — gemessen, nicht beurteilt, wie der Bezug verspricht |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 2 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** Re-Evaluierungs-Trigger benennt einen Beobachtungskanal, den die
eigene Buchungs-Form leert · Bezug-Aussage über einen Trigger-Zustand ohne Beleg · Ordinal-Zählung
über einer Kette, deren Glieder je ihren eigenen Stand tragen · Kommando-Ausgabe unvollständig
abgetragen · Kontext-Satz führt weniger als die Festlegung, die er einführt

## Verdikt

**Merge-blockierend: nein.** Kein HIGH; die drei benannten Prüfgegenstände tragen alle, und jede
Messzahl der ADR hat sich gegen den Bestand und den Kurs-Klon bestätigt. Die zwei MEDIUM sind vor
dem Accept-Übergang zu klären:

- **F-1** lässt den eigenen Trigger 2 ohne lebenden Beobachtungskanal — entweder die
  Buchungs-Form der Kopplung oder der Kanal im Trigger ist anzupassen; solange die Datei
  `Proposed` ist, ist die Behebung zulässig.
- **F-2** friert bei Annahme eine falsche Aussage über [ADR-0056](../../docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md)
  ein; sie ist zu berichtigen oder zu belegen (der Bestand belegt sie nicht).

Nach [ADR-0040](../../docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 verlangt der
Accept-Übergang nach einer **nicht blockierenden** Runde keine erneute Runde — die Behebung von
F-1 bis F-5 durch denselben Architect-Lauf vor dem Umschlag genügt (Präzedenz: [ADR-0047](../../docs/plan/adr/0047-ziel-fassung-regiert-den-sprung-v680.md)
§Geschichte). **Die ADR ist damit zur Annahme bereit, sobald F-1 und F-2 behoben sind**; F-3/F-4
sind Form-Belege, F-5 eine Randnotiz.

Dieser Report ist ein Lauf-Beleg und ersetzt keine Verifikation (Modul 11, getrennter Kontext).
Die Finding-Klassen gehen in die Slice-Closure §7 und von dort in den Steering-Loop-Zähler.
