# MR-089 — Eine Laufzeit-Aussage über einen emittierten oder E2E-Lauf nennt Image-Lage und Variante

- **Datum:** 2026-10-09
- **Wirksamkeits-Anlass:** slice-kotlin-flaches-skelett — Lese-Schritt der Slice-Closure
  ([ADR-0085](../../docs/plan/adr/0085-slice-closure-mit-schwellen-uebertritt-ist-lese-schritt.md)
  Festlegung 1); der Register-Eintrag `BEO-ALL/kosten-einer-emittierten-pruefung-im-ziel-ungemessen`
  erreicht dort 3×.
- **Geltungsbereich:** jede Laufzeit- oder Kosten-Aussage, die ein Artefakt dieses Repos über einen
  Lauf **im gebootstrappten Ziel** oder über einen E2E-Lauf (`make full-smoke`, `make smoke` und ihre
  `-host`-Formen) schreibt — auch in einem Zeitdokument (Slice-§7, Review- oder Verifikations-Bericht)
  im Moment des Schreibens. **Nicht** der Bestand (kein Nachrüsten); **nicht** die emittierte Ebene;
  **nicht** [`make hook-overhead`](../sensors/hook-overhead.md), dessen Messung ihre Last selbst führt.
- **Ersetzt-Baseline-Regel:** keine — das Regelwerk am adoptierten Stand führt keine Regel über die
  Bedingungen einer Laufzeit-Zahl
  (`grep -rliE 'kalter|warmer|pull' .harness/baseline/v6.17.0/regelwerk/` ist leer); nach dem
  Wortlaut der Eintrags-Vorlage damit ein **Fork**, aus demselben Grund wie
  [`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
  den er für diese Zahlen-Klasse schärft.
- **Adaption.** Die Aussage nennt neben der Zahl (a) die **Image- und Cache-Lage** — Images lokal
  vorhanden oder gezogen, Build-Cache warm oder kalt — und (b) die **Ziel-Variante**, an der
  gemessen ist (`--lang`, `--arch`, sprachlos). Was davon nicht gemessen ist, steht als *ungemessen*
  daneben; eine Zahl über eine Variante gilt nicht für die übrigen.
- **Grenze.** Kein Sensor hält die Regel. Ein Doku-Sensor kann eine Dauer-Zahl im Text finden, aber
  nicht entscheiden, ob sie einen Lauf im Ziel beziffert und ob die genannte Lage die gemessene ist;
  die Kalt-Messung selbst braucht einen Host ohne Image-Cache und Netz, was `make gates` nicht hat.
  Träger ist der Lauf, der die Zahl schreibt, und der Review, der sie liest.
- **Begründung.** Drei Vorgänge haben einen Preis an der billigsten Variante oder Lage gemessen und
  als Preis des Laufs gelesen; die Regel macht die Reichweite der Zahl am Ort der Zahl sichtbar,
  statt eine Messung aller Varianten zu verlangen, die kein Lauf dieses Repos fahren kann.
  · seit slice-kotlin-flaches-skelett
- **Auflösungs-Trigger:** ein Sensor misst die Laufzeit eines gebootstrappten Ziels je Variante und
  Image-Lage selbst, **oder** ein Baseline-Stand führt die Regel — dann tritt dieser Eintrag zurück.
