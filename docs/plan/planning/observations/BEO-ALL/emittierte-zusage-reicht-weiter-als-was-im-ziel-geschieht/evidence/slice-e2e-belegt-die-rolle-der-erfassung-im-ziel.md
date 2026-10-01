**Vorgang:** slice-e2e-belegt-die-rolle-der-erfassung-im-ziel
**Fund:** Die Deklaration der zwei Stufen, die `traeger_im_ziel` rufen, nennt [`LH-FA-15`](../../../../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung), und
die Matrix liest sich daraus als Deckung der ganzen Anforderung (`make doc-trace`: *E2E ok*).
Gemessen ist allein die Ableitung des Emitters aus einem synthetischen `agent_type` (Kriterien
*Rolle besetzt* und *abgeleitet, erster Teil*); nicht gemessen sind die Rolle aus
`tool_response.agentType`, die Lesevorschrift und der echte `agent_type` des Agenten-Werkzeugs.
Die Kurzbeschreibungen der Stufen sagen es nicht. Die Fehlerrichtung ist die dieses Eintrags:
die emittierte Sicht reicht weiter als das, was im Ziel gemessen wird (Verifikation, Finding F1).
