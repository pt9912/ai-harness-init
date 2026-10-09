# Architect-Verdikt — `spec/architecture.md` nach `slice-kotlin-hexslice-mit-arch-gate`

**Eingang:** Review-Report `2026-10-09-slice-kotlin-hexslice-mit-arch-gate.md` LOW-1 und LOW-2,
Verifikation `2026-10-09-slice-kotlin-hexslice-mit-arch-gate-verifikation.md`, Gegenstand Commit
`9d1b0837`.
**Rolleninhaber:** Architect-Lauf vom 2026-10-09.

## 1. Wer schreibt `spec/architecture.md` (Rang 3)?

**Verdikt: keine Quelle benennt die Rolle — das ist der Befund; beantwortet wird die Frage hier
nicht.** Geprüft: [ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1
bindet nur `AGENTS.md` §3 und den Adaptions-Block;
[ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) trägt
Anweisungssätze, keine Spec;
[ADR-0062](../plan/adr/0062-eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-nicht-beantwortet.md)
nimmt die Spec-Straten unter *„Was hier NICHT entschieden ist"* ausdrücklich aus und nennt als
Adresse `slice-151-spec-straten-haben-eine-schreibende-rolle` (liegt in `open/`). Die Antwort
entscheidet eine **Klasse**, also ist ihre Form nach ADR-0062 Festlegung 2 eine ADR — und diese ADR
ist der Liefergegenstand von `slice-151`. Ein Verdikt nebenbei wäre genau die stille Antwort, die
Festlegung 2 verbietet.

**Weg:** `slice-151` braucht die Priorisierung `open → next` (Planner, Freigabe des Auftraggebers);
ein neuer Slice ist nicht nötig. Sein Liefergegenstand ist die Rollen-ADR, **kein** Satz in der
Spec (§Kopf *Berührte Spec-Stellen: —*); der Änderungsbedarf unten reist darum als Übergabe neben
ihm, nicht in ihm.

## 2. LOW-1 — Abschnitt „Layout je Sprache"

- **Kotlin-Teil:** gedeckt — die Folgepflicht aus
  [ADR-0088](../plan/adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) §Konsequenzen
  ist der Vorgang, zu dem die Änderung gehört (ADR-0062 Festlegung 1).
- **go-/cpp-Teil:** ohne Quelle geschrieben. **Akzeptiertes Negativ bis `slice-151`:** er bleibt
  stehen, weil er mit `langArchs()` übereinstimmt und ein Rückbau dasselbe quellenlose Schreiben
  wäre; die Rolle, die `slice-151` benennt, übernimmt ihn ausdrücklich oder streicht ihn.

## 3. LOW-2 — ARC-009 gegen den Absatz

**Übergabe (Änderungsbedarf an die Rolle, die `slice-151` benennt):** ARC-009 legt für `hexslice`
und `hexagonal` „Composition Root `cmd/`" sprachübergreifend fest; der Code und der Absatz
„Layout je Sprache" führen den Root je Sprache (`go` `cmd/`, `cpp` `src/main.cpp`, `kotlin`
`src/main/kotlin/app/Main.kt`). Zielform: ARC-009 nennt den Composition Root **je Sprache** oder
verweist innerhalb der Spec auf den Absatz — kein Verweis auf ADR, Slice oder MR
(Referenz-Richtung). Der Widerspruch bestand für `cpp` schon vor `9d1b0837`; er blockiert die
Closure von `slice-kotlin-hexslice-mit-arch-gate` nicht.

**Hinweis an den Planner:** Die go-/cpp-Sätze sind ein weiteres Auftreten der Klasse
`BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet` — Beleg bei der Closure
des Slice, sofern er die Klasse zählt.
