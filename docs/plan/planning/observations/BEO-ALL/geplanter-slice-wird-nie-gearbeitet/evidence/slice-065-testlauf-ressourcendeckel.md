**Vorgang:** slice-065-testlauf-ressourcendeckel
**Fund:** Der Slice wurde am 2026-07-29 geschnitten und lag bis zu dieser Stilllegung in
`next/`, ohne dass eine Implementation ihn beanspruchte — geprüft hat seinen Schnitt nicht
die Umsetzung, sondern der eigene Trigger-Abschnitt (§4): `next→in-progress` war schon beim
Schreiben *nicht erfüllt*, weil §3 mit fünf Gegenständen die Größen-Regel überschritt. Der
Re-Schnitt trennt Deckel/Wächter/Cache-Zusage
(`slice-go-testlauf-bekommt-einen-ressourcendeckel`) von der Melder-Verankerung
(`slice-agent-watch-sh-wird-verankert`). Anders als die Gelegenheit unter
[`observation.md`](../observation.md) §Benannt, nicht gezählt (Gruppierung eines
Go-Slice-Vorrats) ist dies eine eigene Gelegenheit: ein einzelner, zu groß geschnittener
Slice, dessen Größen-Regel nie erfüllt war.
