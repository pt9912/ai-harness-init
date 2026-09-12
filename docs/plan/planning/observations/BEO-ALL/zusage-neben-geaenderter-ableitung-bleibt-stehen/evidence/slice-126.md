**Vorgang:** slice-126
**Fund:** Zweimal blieb in diesem Slice eine Zusage neben einer geänderten Ableitung stehen. Der neu
gesetzte `commits:`-Block machte `make doc-commits` über **jeder** Range unbedienbar (Abbruch mit
`Range-Basis-Vorfahren nicht lesbar`, Exit 2), während der Bestands-Absatz zu
`make history-range-guard` in [`harness/README.md`](../../../../../../../harness/README.md) es
weiter als lauffähiges history-lesendes Ziel führte, dem der Wächter vorangeht. Und der in Runde 2
verbreiterte Matcher des Hooks blockt seither eine Aufrufform, die derselbe Skriptkopf zwei Absätze
höher als *bewusst ausgenommen* deklarierte.
