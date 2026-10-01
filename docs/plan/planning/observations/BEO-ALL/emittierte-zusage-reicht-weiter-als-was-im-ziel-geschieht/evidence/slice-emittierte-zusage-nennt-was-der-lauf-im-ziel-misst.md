**Vorgang:** slice-emittierte-zusage-nennt-was-der-lauf-im-ziel-misst
**Fund:** Die Stufen 2 und 5 in `harness/tools/full-smoke.sh` deklarieren [`LH-FA-13`](../../../../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans) ohne Teilabdeckungs-Text
und messen dort nur `rollen_typen_im_ziel` bzw. `feldliste_im_ziel`; die erzeugte Sicht liest sich als
Deckung der ganzen Anforderung. Die Fehlerrichtung ist die dieses Eintrags (Review F3, Verifikation).
