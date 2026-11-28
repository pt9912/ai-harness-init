**Vorgang:** slice-report-stub-am-unveraenderten-pfad
**Fund:** Review-Findung F-2 (MEDIUM; Quelle der Zeile ist die verkörperte
Reviewer-Zeile *„Mehrteilige Regel-Zusage im Kommentar ohne
Mutations-Deckung je Teil"*): der Kommentar über `schreibeReportStubs`
behauptete eine Deckung durch denselben Fall wie die Slice-Hälfte
(`TestAnwendenBrichtBeiVerletzterStubFormAb`, Fall 243) — beide setzen aber
die Slice-Vorlage an, der Lauf bricht bereits in `schreibeStubs`, bevor der
Report-Zweig betreten wird; die Bruchprobe auf der Report-Hälfte allein (nur
die Report-FormOK-Zeile in `internal/archive/anwenden.go` unwirksam gesetzt)
blieb bei `make test-go` komplett grün. Die mehrteilige Regel — FormOK vor
dem Schreibzug, je Vorlagen-Art eine — trug damit ihre gebaute Deckung nur
auf der lauten Hälfte; der stillen fehlte der Zahn, und der Kommentar nannte
einen Fall, der den Zweig nicht betritt. Behoben im Behebungszug (`b2088a1e`):
die Report-Verdrahtung trägt einen eigenen bindenden Fall
(`TestAnwendenBrichtBeiVerletzterReportStubFormAb`, Mutations-Anlage 819,
`test/mutations/…archive-welle-go-report-stub-form-verdrahtung.sh`).
