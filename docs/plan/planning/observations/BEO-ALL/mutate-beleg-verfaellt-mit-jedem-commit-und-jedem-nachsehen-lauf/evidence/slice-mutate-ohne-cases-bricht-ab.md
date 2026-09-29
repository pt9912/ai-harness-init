**Vorgang:** slice-mutate-ohne-cases-bricht-ab
**Fund:** Der Beleg verfiel in der Rollen-Folge des Vorgangs erneut: drei reale
`make mutate`-Läufe (Reviewer: Fall 264, 94,23 s; Verifier: Fall 264, 99 s; Fall
500, 101 s — je gezielte Teilläufe mit `MUTATE_CASES`) gelten ab ihrem Start als
Entwertung des Beleg-Slots (`SOFORTIGE ENTWERTUNG` in `harness/tools/mutate.sh`),
und die drei Doku-Commits der Rollen-Folge (`62fe669a` Review-Report,
`34887329` Review-Behebung, `a35c4404` Verifier-Report) ändern den Schlüssel
über den ganzen Baum erneut — ein Beleg aus dem Lauf einer vorigen Rolle gilt am
Endstand nicht. Die zweite Hälfte der Beobachtung — der Nachsehen-Lauf, der den
Slot löscht — ist durch die Vollauf-Sperre dieses Vorgangs entschärft: ein
Aufruf ohne `MUTATE_CASES` bricht vor der Entwertung ab. Dass die Schonung des
Slots dabei an der Beleg-Mechanik nach
[`ADR-0035`](../../../../../../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
hängt (`MUTATE_FORCE=1`, nur volle Läufe schreiben), ist der Grund, warum das
Risiko R1 des Vorgangs weiter offen bleibt.
