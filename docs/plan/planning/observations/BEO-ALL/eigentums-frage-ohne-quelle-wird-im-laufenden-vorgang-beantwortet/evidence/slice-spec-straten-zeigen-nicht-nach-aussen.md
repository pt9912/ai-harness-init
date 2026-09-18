**Vorgang:** slice-spec-straten-zeigen-nicht-nach-aussen

**Fund:** Der Vorgang ändert zwei Spec-Straten — zwölf Fundstellen und eine Historie-Zeile in
`spec/spezifikation.md`, eine Fundstelle und den Frische-Marker in `spec/architecture.md` —, und
keine Quelle benennt die Rolle, die das darf:

- [`AGENTS.md`](../../../../../../AGENTS.md) §3.8 grenzt die Architect-Zuordnung ausdrücklich auf
  `AGENTS.md` §3 und den Adaptions-Block ein und lässt die Frage für die Straten offen
  ([ADR-0015](../../../../adr/0015-rollen-eigentum-an-norm-artefakten.md) §Kontext trägt die Abwägung).
- Die Adresse liegt in `open/`:
  `slice-151-spec-straten-haben-eine-schreibende-rolle`, Kopf `Verantwortlich: — bis zur
  Priorisierung`.
- Die Setzung des Auftraggebers vom 2026-09-16 ließ die Verweise den Implementer im Sprung-Slice
  nachziehen; für diese zwei Dateien folgt daraus nichts.
- Das Architect-Verdikt zu diesem Vorgang greift der Frage nicht vor
  (`docs/reviews/2026-09-18-spec-straten-architect.md` §Was dieses Verdikt nicht entscheidet).

Der laufende Vorgang hat sie damit durch **Tun** beantwortet: der Implementer hat die Straten
geschrieben. Der Plan verlangt die Änderung und nennt keine Rolle — eine Pflicht ist keine
Zuständigkeit. Der Vorgang ist die **dritte** Belegdatei dieses Verzeichnisses, und damit erreicht
der Zähler die Schwelle, an die
[ADR-0048](../../../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) ihren fünften
Re-Evaluierungs-Trigger hängt.
