# Welle welle-erfassungsschicht-im-ziel — Erfassungsschicht im Ziel — Closure-Notiz

> **Zitier-Form** *(bleibt stehen — Norm, kein Ausfüll-Hinweis).* Dieses
> Artefakt friert ein; was es zitiert, bewegt sich weiter. Deshalb: **Kennung,
> nicht Adresse** — `slice-<Kennung>` statt seines Lifecycle-Pfads, `make <target>`
> statt eines Links auf die Sensor-Datei, eine Baseline-Stelle als
> `v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt> statt als Link
> (Baseline-Regelwerk `grundlagen-harness-dateien.md` §harness/README.md als
> Einstiegspunkt — beim Ausfüllen mit dem adoptierten Tag schreiben).

**Welle:** welle-erfassungsschicht-im-ziel
**Abschluss:** 2026-10-08
**Verantwortlich:** pt9912

## Was wurde geliefert?

- Jede Span-Zeile nennt die Fassung ihrer Erfassungsregel (`rule_version`, Fassung 5)
  ([`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans)):
  `slice-span-traegt-die-fassung-seiner-erfassungsregel`.
- Ein unbekannter Wert trägt die Kennzeichnung *nicht bekannt*, `[]` heißt *keiner*
  ([`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung),
  [`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans)):
  `slice-agent-role-traegt-nicht-bekannt`.
- Die emittierte Feldliste nennt Verfügbarkeit und Aufbewahrung
  ([`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)):
  `slice-emittierte-feldliste-traegt-verfuegbarkeit-und-aufbewahrung`.
- Der Fingerabdruck trägt seinen Ausgang
  ([`LH-FA-14`](../../../../spec/lastenheft.md#lh-fa-14--redaktion-und-erfassungs-umfang),
  [`ADR-0087`](../../adr/0087-fingerabdruck-gilt-auch-fuer-das-emittierte.md)):
  `slice-107-inhalts-hash-traegt-eine-entscheidung`.
- Das Ende-Ereignis trägt seinen Ausgang außerhalb der Lieferung: `slice-205` stillgelegt,
  Gegenstand *entfallen* (Auftraggeber-Entscheidung, `LH-FA-14` *Erfassungs-Umfang* bleibt).
- Das *Mehr*: `make gates` und `make full-smoke` grün auf demselben Commit (§Verifikation).

## Was hat funktioniert?

- Fassung vor Kennzeichnung (Welle-Plan §5): die Umstellung auf *nicht bekannt* lief als erster
  hochgezählter Bedeutungswechsel unter der neuen Regel (Fassung 5, `SPEC-096`).
- Ein Konflikt mit Rang 1 (`slice-205`) ging als Übergabe an den Auftraggeber und endete als
  Stilllegung, nicht als Change Request durch die Welle.

## Was ging anders als geplant?

- **Schritt 4 nicht ausgeführt:** `.harness/state/bin/ai-harness-init archive-welle --vorschau welle-erfassungsschicht-im-ziel`
  sperrt mit `[untergrenze]` (198 wellenlose Slices flach in `done/`, kein `done/*/archiv.zip`) und
  `[haenger]` (ADR-0016 → zwei Review-Reports von `slice-050`). Der Altbestand-Lauf
  `archive-welle altbestand` ist ein eigener Vorgang (Auftraggeber-Freigabe vom 2026-10-08).
- `slice-205` trug nach der Stilllegung weiter das Kopf-Feld dieser Welle; berichtigt auf
  *ohne Welle* vor dem Self-Close, damit die Archivierung ihn nicht nach der Welle einsammelt.
- **Bestands-Lese-Schritt:** Vorschläge an den Auftraggeber, nichts stillgelegt, nichts abgelehnt —
  `slice-feldabdeckung-existenz-sensor` bestätigt (Wortlaut-Sensor Feldliste ↔ Spec fehlt weiter) ·
  `slice-119-zusage-ohne-fall-wird-sichtbar` bestätigt, Priorität hoch ·
  `slice-069-zahn-bindet-zusicherung` bestätigt · `slice-153-wellen-commands-nennen-die-roadmap-abschnitte`
  prüfen (Gruppierungs-Kandidat mit dem Sensor der Klasse `zusage-neben-geaenderter-ableitung-bleibt-stehen`) ·
  `slice-113-co-001-ist-faellig` bestätigt.

## Steering-Loop-Einträge

- **Spec-Festlegung mit Sensor verkörpert:** ein Bedeutungswechsel eines Span-Felds trägt eine neue
  Fassung — `spec/spezifikation.md` §5, `SPEC-088`/`SPEC-089`/`SPEC-094`
  ([`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans)); Sensor
  `TestCurrentRuleVersionIsTheLastSpecFassung` (`make test`) mit den Mutations-Fällen 592/593. Kein
  `liegt in`, kein Herkunfts-Anker: der Zielort trägt seine eigene Kennung
  ([`ADR-0049`](../../adr/0049-ausgang-traegt-die-benannte-luecke.md) Festlegung 1). Grenze: ob ein
  Wechsel als solcher erkannt und hochgezählt wird, hält kein Wächter (`SPEC-094`); ein Golden-Test je
  Fassung ist baubar, nicht gebaut, Trigger ist ein neuer Beleg der Klasse.
  Auslöser: `BEO-ALL/span-feld-bedeutung-wechselt-ohne-fassungs-angabe` (`slice-204-das-programm-feld-nennt-das-programm`,
  `slice-program-feld-nennt-weder-operator-noch-wertfragment`, `slice-span-pflichtfeld-traegt-nicht-bekannt`,
  `slice-span-traegt-die-fassung-seiner-erfassungsregel` — 4×).
- **Kein neuer Beleg, Lesart bestätigt:** `BEO-ALL/zusicherung-ueber-der-leeren-menge-wahr` (3 Belege,
  *verkörpert*) — eine leere Bezugsmenge, die der messende Lauf selbst als Grenze benennt und deren
  Zusage an anderer Stelle über einer nicht leeren Menge getragen wird, zählt nicht als Auftreten.
- **Wiederauftreten mit geplantem Träger:** `BEO-ALL/neuer-waechter-ohne-mutations-fall` →
  `slice-119-zusage-ohne-fall-wird-sichtbar`; `BEO-ALL/zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel`
  → `slice-069-zahn-bindet-zusicherung`; `BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen` →
  `slice-153-wellen-commands-nennen-die-roadmap-abschnitte`. `BEO-ALL/geplanter-slice-wird-nie-gearbeitet`
  (`slice-205`) steht verkörpert in `.claude/commands/plan-welle.md`, kein neuer Ausgang.

## Beobachtungs-Register (Zeiger)

- Ablage: [`../observations/`](../observations/README.md). Lese-Schritt: `make register-ausgang` →
  `235 Eintraege, 66 ueber der Schwelle, 0 Befund(e)` (vor dem Self-Close-Commit).
- **Paarungen:** (a) kein Eintrag dieser Notiz und keine §7 der Welle-Slices trägt `liegt in` — kein
  Gegenstand. (b) jeder genannte Slice existiert im Lifecycle (`ls docs/plan/planning/*/<kennung>*.md`:
  `slice-119`, `slice-069`, `slice-153`, `slice-113`, `slice-feldabdeckung-existenz-sensor` in `open/`;
  die vier Welle-Slices und `slice-205` in `done/`). (c) erste Hälfte: jede genannte `BEO-ALL/<slug>`
  existiert als Verzeichnis. Register-Paarung (c), zweite Hälfte: 2 Verzeichnisse ohne Beleg,
  namentlich `BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`,
  `BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab`; nicht als getragen behauptet
  (`for d in docs/plan/planning/observations/BEO-ALL/*/; do n=$(ls "$d"evidence/*.md 2>/dev/null | wc -l); [ "$n" -eq 0 ] && echo "$d"; done`).

## Folge-Slices

- Kein neuer Slice. Die *geplant*-Ausgänge tragen `slice-119-zusage-ohne-fall-wird-sichtbar`,
  `slice-069-zahn-bindet-zusicherung` und `slice-153-wellen-commands-nennen-die-roadmap-abschnitte`.
- Nächste startbare Welle: `welle-handbuch-zeigt-den-bestand` (Start-Trigger eingetreten); die
  Kotlin-Welle wartet auf die Annahme von
  [`ADR-0088`](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md). Eröffnet ist keine.

## Verifikation

- Schritt 1: Verifier-Beleg `docs/reviews/2026-10-08-welle-erfassungsschicht-im-ziel-trigger.md` auf
  `e66fec9d` — die vier Slices in `done/`; `make gates` rc=0; `make full-smoke` rc=0 auf demselben
  Commit; CI auf dem Commit success. Grenze: die Abdeckungs-Zeilen von `full-smoke` nennen ihre
  Teilmessung selbst. Ein Replay-Set führt dieses Repo nicht.
- Schritt 2: `CO-001` *Auflösung fällig* mit Folge-Slice `slice-113`, `CO-002` permanent; kein
  bootstrap-aware Gate; ADR-Zweig: keine Folge-ADR — die Teil-Ablösung von
  [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) und
  [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) durch `ADR-0087`
  ist mit der Annahme erledigt, ihre Re-Evaluierungs-Trigger feuerten nicht; Hard Rules bestätigt
  (Architect-Verdikt `docs/reviews/2026-10-08-welle-erfassungsschicht-im-ziel-architect-verdikt.md`).
