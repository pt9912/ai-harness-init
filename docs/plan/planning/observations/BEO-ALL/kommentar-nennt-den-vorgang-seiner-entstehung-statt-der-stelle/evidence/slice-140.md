**Vorgang:** slice-140
**Fund:** Zwei Fundstellen, eine Gelegenheit. (a) Zwei der vier neuen Mutations-Fälle tragen im
Kopfkommentar die Herkunft ihres Anlasses statt der Stelle, die sie mutieren —
`grep -nE '^#.*(Review-Klasse|Runde [0-9])' test/mutations/29{3,4}-*.sh` nennt vier Zeilen, darunter
*„Review-Klasse Vorwaerts-Korrektur-oeffnet-die-Gegenrichtung, Runde 3 MEDIUM-1"*; das ist wörtlich
die von [`AGENTS.md`](../../../../../../../AGENTS.md) §3.7 als *falsch* ausgeschriebene Form, und die
Runden-Kennung löst nach `docs/reviews/**` auf, das in keinem Rang der Source Precedence steht.
(b) Der Doc-Block an `StripCommentHints` sagt, die Fence-Eigenschaft hänge *„an einer von Hand
geprueften Reihenfolge"* — ein Partizip, das einen **Vorgang** behauptet, wo eine **Eigenschaft**
gemeint ist; der Vorgang steht in keinem lebenden Artefakt und wäre über 91 zu schließende
Kommentare in 48 Vorlagen als Handarbeit auch nicht durchführbar. `make comment-claims` erreicht
weder `test/mutations/` noch die Frage, *worüber* ein Kommentar spricht.
