# ADR-0101: Die Baseline-Verweis-Form in ADRs — der lebende Verweis trägt die Kennungs-Form, nicht einen Tag-Pfad

**Status:** Accepted

**Datum:** 2026-11-26

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(die Reproduzierbarkeits-Kette bleibt; hier geht es um die Form, in der ein ADR sie zitiert),
`ADR-0100` <!-- d-check:ignore (Supersedes-Lineage: Teil-Supersede, siehe das Supersedes-Feld) -->,
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md)
(die Nachbar-Achse: der Verweis trägt Tag und Zitat, nicht den Pfad in den Arbeits-Cache),
[ADR-0079](0079-tote-adresse-in-den-vendored-baum-aus-zwei-accepted-adrs.md)
(der Vorläufer der namentlichen Paare für tote Adressen in `Accepted`-ADRs),
[`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist),
[`MR-053`](../../../harness/conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)

**Supersedes:** `ADR-0100` <!-- d-check:ignore (Supersedes-Lineage auf superseded ADR) --> in dieser einen Zeile: das dort benannte Verweis-Form-Argument — die Modul-Kennung hinter einem Link in den gepinnten Baum — ist die Form-Klasse, die den Kern der ADR beim nächsten Bump rotieren lässt; der Rest der ADR-0100 (die Setzungen zur Gegenmessung eines d-check-Sprungs) bleibt unverändert regierend.

**Schärft:** — Prozess-ADR ohne Spec-Stratum. Die Pin-Kette
([`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit))
und die Ordnungskanten der ADR-0100 bleiben unberührt; geändert wird nur die
Verweis-Form, die eine ADR gegenüber dem Baseline-Regelwerk trägt.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR).

---

## Kontext

Die Verweis-Züge eines Baseline-Sprungs ziehen die Baseline-Zeiger des Bestands
auf den neuen Stand — der C2-Verweis-Zug des Sprungs `v6.18.1` → `v7.0.0`
hat **145** Ziel-Verweise auf den `v7.0.0`-Baum umgezogen. Eine der betreffenden
Zeilen liegt **im Kern einer `Accepted`-ADR**
(`ADR-0100` <!-- d-check:ignore (Supersedes-Lineage: Teil-Supersede, siehe das Supersedes-Feld) -->, Z. 134 —
der Modul-13-Link der Symlink-Smoke-Bilanz, Form
`[Modul 13](../../../.harness/baseline/<tag>/regelwerk/modul-13-…)`). Der Nachzug
schrieb den Tag-Pfad in den Kern der eingefrorenen Datei und färbte damit den
`adr-immutable`-Job rot (`core-drift-vcs`).

Die Form-Klasse der Zeile: ein Markdown-Link in den gepinnten Baum
`.harness/baseline/<tag>/…` **stellt den getaggten Teil der Adresse** —
und der Tag rotiert mit jedem Bump. In einer lebenden Datei ist das eine
Reparatur je Bump (die der Verweis-Zug fährt); im Kern einer eingefrorenen ADR
ist sie eine Kern-Änderung, die von [`make adr-immutable`](../../../harness/sensors/adr-immutable.md)
rot gemeldet wird, **beim Nachzug und bei jeder späteren Bump-Reparatur** —
das Wächter-Ticket (`core-drift-vcs`) kehrt mit jedem Sprung zurück an genau
dieser Zeilen-Klasse.

Zwei Stände stehen nach der Heilung nebeneinander, beide bewusst: die
zurückgenommene Zeile liest den **Entstehungsstand** (byte-genau am
`39f57f73`, Verweis auf `v6.18.1`), der Bestand daneben trägt den
`v7.0.0`-Baum — die Adresse in der Revert-Zeile ist damit tot, und sie
trägt ein eigenes Ventil (Festlegung 2).

## Entscheidung

Wir wählen: **Ein lebender Verweis auf das Baseline-Regelwerk in einem ADR trägt
die Kennungs-Form** — Inline-Code der Modul-Kennung mit `§`-Anker, gelesen als
„Baseline-Regelwerk `modul-13-…` §Die dritte Lage“ — **ohne** den Tag-Pfad und
ohne Markdown-Link in den gepinnten Baum. Der gepinnte Stand
(`harness/conventions.md` §Baseline) ist die **eine** Stelle, an der er im
Repo steht; eine ADR, die ihn zusätzlich nennt, rotiert mit dem Bump und
stellt ein zweites Mal dieselbe Setzung — die rotierende Kopie ist die
Form-Klasse, die im Kern der eingefrorenen Datei das Wächter-Ticket
bringt.

Nicht von der Regel getroffen sind die **datierten Messstand-Zitate**: die
Zitate, die ihre Aussage an einem verstrichenen Stand tragen (die
[`MR-053`-Form](../../../harness/conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)),
schreiben den Tag, an dem sie wahr waren, und rotieren
mit einem Bump **nicht** — die Form-Klasse dieser ADR ist der *lebende*
Verweis, der den aktuellen adoptierten Stand anspricht.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — die Pfad-Zeile je Bump nachziehen (die Form der Verweis-Züge) | Die Adresse löst in jedem Stand auf | Im Kern der eingefrorenen ADR ist jede Nachzugs-Änderung eine Kern-Änderung — der `adr-immutable`-Job rotiert mit jedem Bump gegen dieselbe Zeile, das zurückgekehrte Wächter-Ticket ist die Regel |
| B — `d-check:ignore` an der Fundstelle in ADR-0100 | Kein Config-Eintrag; die Fundstelle ist am Ort benannt | Der Marker ist selbst eine Zeile im Kern der eingefrorenen ADR — dieselbe Form-Klasse, die diese ADR ausschließt; jede spätere Berührung der Zeile brächte das Ticket zurück |
| **C — die Kennungs-Form ab jetzt in neuen ADR-Zeilen, daneben das namentliche Paar (ADR-0079-Form) für die Revert-Zeile** | Der ADR-Kern wird vom Bump unberührt und löst die Klasse statt der Linie; die tote Adresse trägt ein gemessenes Ventil | Der Config-Eintrag ist eine Senkung — er trägt darum Deckungsvorgabe mit `Deckung: 1` und bewacht in beiden Richtungen (`test/ignore-refs-restbreite.bats`) |

## Konsequenzen

- Positiv: Der Bump nach dem nächsten rotiert keinen ADR-Kern — die
  Verweis-Züge berühren die Zeilen-Klasse in `docs/plan/adr/**` nicht mehr.
- Negativ: Die Revert-Zeile in ADR-0100 bleibt eine tote Adresse —
  der Verweis-Kenner löst nach dem Bump `v6.18.1` nicht mehr, und
  ein Paar im `ignore-refs`-Block trägt sie (Festlegung 2).
  Die tote Adresse ist deklariert, nicht still.
- Folgepflicht: ein `ignore-refs`-Paar
  (`in: docs/plan/adr/0100-…`, `refs: [".harness/baseline/**"]`,
  Deklaration `Deckung: 1`) im selben Zug mit dieser ADR — Messung
  `test/ignore-refs-restbreite.bats`, in beiden Richtungen (ADR-0039
  Festlegung 2); der ADR-Index trägt beide Stande (ADR-0100
  `Superseded by`, ADR-0101 `Accepted`).
- Cut-off: ab dieser ADR — Bestands-Zeilen, die die link-Form
  bereits tragen, sind ausgenommen (kein Nachrüsten
  über eingefrorene Kerne); neue ADR-Verweise tragen die
  Form ab dem ersten Schreiben.

## Re-Evaluierungs-Trigger

Permanent in der Form *„gilt unbefristet"* — bis eine dieser Bedingungen
eintritt:

1. **d-check kennt die Klasse selbst** — ein d-check-Stand liefert ein
   Modul, das Referenzen aus eingefrorenen Artefakten von der Ziel-Prüfung
   selbst ausnimmt (der `ignore-refs`-Glob trägt das Paar dann nicht mehr);
   das Paar entfällt, Folge-ADR mit `supersedes`.
2. **Bump, kein Befund** — der Bump nach dem nächsten zieht ADR-Kern-Zeilen
   nicht mehr nach (kein `adr-immutable`-Ticket an der Form-Klasse);
   die Aussage über die Form trägt der nächste Verweis-Zug als Befund-0
   (Fundliste seiner Fundstellen, [`MR-051`-Form](../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)).

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-11-26 | Accepted; supersedes [ADR-0100](0100-die-gegenmessung-schrumpft-auf-die-einheimische-flaeche.md) — die Pfad-Zeile Z. 134 am Entstehungsstand `39f57f73` zurückgenommen | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) · slice-c7-adaptions-nachzuege-v7-0-0 |
| 2026-11-26 | Berichtigung — die zwei „Festlegung 2“-Verweise im Kern (Kontext-Terminal, Konsequenzen-Negativ-Bullet) zeigen auf keine nummerierte Festlegung dieser ADR; der verwiesene Inhalt trägt als Konsequenzen-Bullet (die tote Adresse, das Ventil). Der Kern bleibt mit den Verweisen unverändert ([`AGENTS.md`](../../../AGENTS.md) §3.4: Nachzug darf nicht); die nachgelagerte Verweis-Stelle der Gate-Konfiguration zeigt auf das Konsequenzen-Bullet | Review [`2026-11-25-slice-c7-adaptions-nachzuege-v7-0-0.md`](../../reviews/2026-11-25-slice-c7-adaptions-nachzuege-v7-0-0.md) F-3 |
