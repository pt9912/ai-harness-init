# MR-019 — Technik-Stratum als Rang 2 der Source Precedence

> **ÜBERHOLT: die Zahl „zwei Abweichungen von der Vorlagen-Form" → [`MR-021`](../conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben).** Die übrigen Setzungen dieses Eintrags gelten fort.

- **Datum:** 2026-08-01
- **Geltungsbereich:** [`spec/spezifikation.md`](../../spec/spezifikation.md),
  [`AGENTS.md`](../../AGENTS.md) §2, [`harness/README.md`](../README.md) §Source precedence,
  `.d-check.yml` (`matrix.classes`).
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  und er setzt keine Abweichung: er **baut eine zurück**.
  [`grundlagen-referenz-richtung.md`](../../.harness/baseline/v5.18.0/regelwerk/grundlagen-referenz-richtung.md#spec-straten-mehr-als-ein-spec-dokument)
  §Spec-Straten verlangt am adoptierten Stand `v5.12.0` eine Deklaration nur für den **anderen**
  Fall — *„Ein Repo kann mit zwei Straten fahren. Dann ist das eine Abweichung von der Baseline und
  wird als `MR-<NNN>` deklariert"* —, und dieser Eintrag hebt genau jene Deklaration aus
  [`MR-000`](../conventions.md#mr-000--baseline-aussage) auf. Alle drei Straten zu führen ist Default (*„Alle drei
  Straten sind obligatorisch"*). Die **Form des Gefäßes** tritt ebenfalls an keine Regel: eine
  Pflichtgliederung für `spec/spezifikation.md` gibt es nicht —
  [`modul-03-spec.md`](../../.harness/baseline/v5.18.0/regelwerk/modul-03-spec.md#ziel-form-spezifikation)
  §Ziel-Form: Spezifikation nennt Inhalts-Bereiche und operative Regeln, keine Abschnitts-Folge; die
  freigelassenen Nummern und der nicht nummerierte Abschnitt `Aufnahme-Regel` weichen von der
  **Vorlage** ab, und über die entscheidet nach §Freshness-Audit die Pflichtgliederung, nicht die
  Vorlage selbst.
- **Adaption:** Das Repo führt das **Technik-Stratum**. `spec/spezifikation.md` steht als
  eigener **Rang 2** zwischen Vertrag (Rang 1) und Sicht (Rang 3); die nachfolgenden Ränge
  verschieben sich um eins. Damit ist das Stratum **deklariert** — der Kurs
  ([`grundlagen-referenz-richtung.md` §Spec-Straten](../../.harness/baseline/v5.18.0/regelwerk/grundlagen-referenz-richtung.md#spec-straten-mehr-als-ein-spec-dokument))
  verlangt die Deklaration hier und nennt ein undeklariertes Spec-Dokument *„nicht normativ
  zitierbar“*.
- **Hebt die 2-Strata-Klausel aus [`MR-000`](../conventions.md#mr-000--baseline-aussage) auf** —
  *„2-Strata-Spec (Lastenheft → Architektur, keine separate Spezifikations-Datei)“*. Die
  Vorlage lässt für akzeptierte Einträge genau diesen Weg zu (*„nur neue Einträge oder
  explizite Aufhebungen via neuen MR“*); [`MR-000`](../conventions.md#mr-000--baseline-aussage) bleibt deshalb
  unangetastet, seine übrigen Setzungen (ID-Schema, Verzeichniskonvention) gelten fort.
- **Form des Gefäßes.** Die Abschnittsnummern sind die der vendored Vorlage
  `.harness/baseline/v3.5.2/templates/spec/spezifikation.template.md` und werden **nie neu
  vergeben**: geführt sind die Abschnitte 3 · 5 · 6 plus die Historie (7), die übrigen
  (1 · 2 · 4) lassen ihre Nummer frei. Grund ist die Anker-Stabilität — ein `Schärft:`-Zeiger
  steht in Dokumenten, die ab *Accepted* nicht mehr geändert werden dürfen
  ([`AGENTS.md`](../../AGENTS.md) §3.4). Zwei Abweichungen von der Vorlagen-Form: §5 trägt die
  Drei-Spalten-Gestalt, die
  [`modul-15-observability.md`](../../.harness/baseline/v5.18.0/regelwerk/modul-15-observability.md)
  vorschreibt (Feld · Pflicht/Optional · Incident-Frage) statt der Vorlagen-Spalten
  *Span · Pflicht-Attribute · Quelle* — die Vorlage verweist an dieser Stelle selbst auf das
  Modul, und der vorhandene Bestand trägt bereits diese drei Spalten; und vor §3 steht ein
  **nicht nummerierter** Abschnitt `Aufnahme-Regel`, den die Vorlage nicht kennt — er nennt die
  Bedingungen, unter denen ein Satz hierher gehört, nimmt keine Nummer und verschiebt damit
  keinen Anker.
- **Sensor, und seine Grenze (gemessen 2026-08-01).** `spec/spezifikation.md` ist in
  `.d-check.yml` der `matrix`-Klasse `spec-straten` beigetreten. Rot färbt `make docs-check`
  damit jeden Link im bindenden Text (außerhalb der Historie-Tabelle), dessen **Ziel** in der
  `matrix`-Klasse `adr` oder `slice` liegt, als `matrix-forbidden` — entschieden wird über die
  Klasse des Ziels, nicht über den Text der Kennung —, und eine **nackte** `ADR-`-Kennung als
  `id-unlinked`. **Nicht** rot färbt eine **nackte** `slice-`-Kennung (`ids.patterns` führt kein
  Muster für sie), und ebensowenig eine `ADR-`- oder `slice-`-Kennung, deren Link an einem Ziel
  außerhalb beider Klassen endet — beides lässt den Gate bei Exit 0. Diesen Rest der Regel trägt
  der Mensch.
- **Begründung (gemessen 2026-08-01 am Stand `5200da6`, jede Zahl über die Blockgrenzen
  `grep -nE '^### MR-[0-9]{3}|^## Modus-Deklaration'`).** Der Adaptions-Block hat technische
  Festlegungen aufgenommen, für die er nicht das Gefäß ist:
  [`MR-018`](../conventions.md#mr-018--span-schema-der-telemetrie-erfassung) trug dort **824 Zeilen** und damit
  mehr als die übrigen achtzehn Einträge **zusammen** (801). Am 2026-07-28 waren es noch **47**;
  von den 803 Zeilen, um die die Datei seither gewachsen war, entfielen **777 auf diesen einen
  Eintrag**. Der Eintrag nennt den Grund selbst — die Tabelle *„wächst mit jedem Feld“* und
  gehört nicht in eine ab *Accepted* immutable Entscheidung. Das ist die Definition des
  Technik-Stratums; das Gefäß fehlte, also wuchs der Inhalt in das nächstbeste. Dazu ein
  Rang-Befund: der Adaptions-Block steht in **keiner** der beiden Precedence-Listen des Repos —
  eine fortschreibbare technische Festlegung lag damit in einem ungerangten Dokument.
- **Was hier NICHT entschieden ist:** dass Bestand aus dem Adaptions-Block umzieht. Diese
  Adaption legt das Gefäß an und rangt es; welcher Satz wohin wandert, ist eine eigene Arbeit
  — und der Umzug einer Festlegung, deren Zielort eine akzeptierte ADR vorschreibt, braucht
  zuerst deren Teil-Revision
  ([`ADR-0013`](../../docs/plan/adr/0013-technik-stratum-als-zielort.md)).
- **Auflösungs-Trigger:** permanent. Fällt der letzte Abschnitt mit Bestand weg, ist das
  Stratum neu zu begründen — ein Spec-Dokument ohne Inhalt ist ein Rang ohne Gegenstand.
