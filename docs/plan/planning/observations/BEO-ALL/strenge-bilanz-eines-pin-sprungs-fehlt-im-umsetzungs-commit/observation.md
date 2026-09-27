# Strenge-Bilanz eines Pin-Sprungs fehlt im Umsetzungs-Commit

**Sub-Area:** `*` (gesamtes Repo)

Ein Pin-Sprung-Commit liefert die von [`MR-063`](../../../../../../harness/conventions.md#mr-063)
verlangte Gegenmessung (Sonde je aktivem Modul, alte
gegen neue Fragmente) nicht vollständig mit, obwohl das Vorgänger-Muster sie vollständig in der
eigenen Commit-Message trug. Erst eine Reviewer-Runde deckt die Lücke auf; eine zweite
Implementer-Runde trägt sie nach.
