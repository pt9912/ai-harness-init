**Vorgang:** Review-Reports `docs/reviews/2026-09-14-adr-0048-konsistenzrunde.md` (MEDIUM-1, LOW-2)
und `docs/reviews/2026-09-14-adr-0048-konsistenzrunde-2.md` (MEDIUM-1) — der Vorgang ist das
Schreiben von
[ADR-0048](../../../../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) über seine
drei Konsistenzrunden. Drei Funde, **eine** Gelegenheit, und das Erstauftreten, das dem Eintrag die
Kennung gibt.
**Fund:** Dreimal sagt eine Überschrift etwas anderes als ihr Rumpf.
**Breiter:** Die Überschrift der ersten Festlegung setzte die Regel für *„ein Planungs-Artefakt"*,
der Rumpf arbeitete sie nur *„für den Welle-Plan"* aus, und der Gattungsbegriff war nirgends
abgegrenzt — die Datei selbst las ihre Festlegung bereits breit und wandte sie auf
`docs/plan/planning/README.md` an, das kein Welle-Plan ist.
**Unbestimmt:** Die Überschrift der zweiten Festlegung nannte zwei Limitatoren — *„so weit wie die
dort genannten Artefakte und die zitierten Quellen"* — ohne Verknüpfungsregel; unter der
Vereinigungs-Lesart widersprachen sich die beiden Festlegungen für genau das Artefakt, das den
Konflikt erzeugt hatte. Aufgelöst wurde das erst vom Folgesatz.
**Gezählt:** Dieselbe Überschrift zählte **zwei** zitierte Quellen, wo der ausgelegte Satz **drei**
nennt, und quantifizierte dann über alle von ihm genannten Artefakte; die Überschrift war korrekt,
der Rumpf nicht.

Alle drei sind vor dem Accept behoben. Der Ort ist in allen drei Fällen die **Adresse**, unter der
die Festlegung anderswo zitiert wird.
