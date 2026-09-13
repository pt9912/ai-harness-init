**Vorgang:** slice-225
**Fund:** Zwei Sendungen dieses Slice hatten keinen annehmenden Träger — dieselben zwei Formen wie
bei `slice-224`, nur diesmal in umgekehrter Richtung erzeugt.

**Kein Empfänger.** [`MR-057`](../../../../../../../harness/conventions.md#mr-057) benennt in seinem Abschnitt *Grenze* zwei Dogfood-Stellen, die eine
Slice-Kennung an Ziffern binden, erklärt den Nachzug zur **Implementer**-Arbeit und datiert ihn
*„fällig, bevor die erste benannte Kennung vergeben wird"*. Eine Adresse dafür existierte nicht:

```sh
git grep -ln 'slice-mv\.sh\|archive/stub\.go' -- \
  'docs/plan/planning/open/*.md' 'docs/plan/planning/next/*.md' 'docs/plan/planning/in-progress/*.md'
# slice-188, slice-215 — beide mit anderem Gegenstand
```

Die Fälligkeit war damit schärfer als bei einer gewöhnlichen Übergabe und trotzdem ohne Kennung:
Die erste benannte Kennung entsteht in derselben Closure, die den Träger schneidet.

**Empfänger, der ausschließt.** `slice-224` §9 adressiert die Zeile zu
`lab/templates/.d-check.yml` an `slice-225`; dessen §1 schließt die emittierte Vorlage aus und
nennt vier Adressen, von denen keine sie annimmt — geprüft von zwei Rollen unabhängig. Die
Sendung hatte damit zwei Absender-Aussagen und keinen Empfänger, und `slice-224` liegt in `done/`
und ist nicht mehr änderbar.

Beide Formen fallen durch dieselbe Lücke, die dieser Eintrag seit `slice-125` führt: Die
Folge-Slice-Paarung prüft **genannte** Kennungen auf Existenz, nicht darauf, ob der genannte Plan
den Gegenstand annimmt; eine Sendung **ohne** Kennung ist für sie gar kein Gegenstand. Die Closure
hat für jede der zwei einen Träger geschnitten.
