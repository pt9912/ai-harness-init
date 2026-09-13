**Vorgang:** slice-224
**Fund:** DoD-2 sagte zu, das Such-Kommando liefere *„nur noch Treffer in `implement-slice.md`"*.
Gefahren liefert es mehr, und der Grund ist der Plan selbst:

```sh
git grep -cE 'slice-<NNN>|welle-<NN>' -- docs/plan/planning .claude/commands \
  ':!docs/plan/planning/done'
# .claude/commands/implement-slice.md:3
# docs/plan/planning/done/slice-224-delta-nachweis-und-planungs-nachzug.md:12
# docs/plan/planning/next/slice-225-gate-index-steht-einmal.md:2
```

**Kein Erwartungswert** ([`MR-025`](../../../../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Die zwölf Treffer dieses Plans stehen in seinen eigenen Beleg-Kommandos und
Nachweis-Zellen — er beschreibt die Umstellung und muss dafür beide Formen nennen. Zwei davon
stehen in der Zusage-Zeile selbst: Die DoD zitiert das Muster, das sie zu tilgen verspricht.

Der zugesagte Wert wird erst mit dem `git mv` nach `done/` erreichbar, weil der Pathspec `done/`
ausnimmt — im Moment des Abhakens ist die Zusage nicht erfüllbar, und wer sie trotzdem abhakt,
hat entweder das Zitat aus der Begründung getilgt oder den Bereich anders gelesen, als er
dasteht. Zwei Rollen haben denselben Satz beanstandet, keine hat ihn geändert: Der Wortlaut einer
DoD ist das Abnahmekriterium, und das schreibt die ausführende Rolle nicht um
([`AGENTS.md`](../../../../../../../AGENTS.md) §3.10). Die Closure hat ihn **präzisiert, nicht
abgehakt** — sie trennt jetzt *verwendet* von *zitiert* und nennt den Bestand beider Klassen.
