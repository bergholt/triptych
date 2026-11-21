# Sun: 72 digte til 72 solformørkelser

[English](README.md)

<img width="500" alt="Sun: 72 Poems for 72 Solar Eclipses" src="https://github.com/user-attachments/assets/d5f51300-d8fd-4a69-b945-eee171bda986" />

*Triptych* er en Prolog-implementering af systemdigtet *Sun*. Tre substantiver, tre verber og fire adverbier i to ordstillinger giver 72 digte, ét for hver solformørkelse i Saros 126 (1179–2459).

Den totale solformørkelse den 12. august 2026 er nr. 48 i serien. I `sun.pl` svarer den til *now, apertures emerge*.

## Ordforråd og ordstilling

| Ordklasse | Ord i rækkefølgen i `sun.pl` |
| --- | --- |
| Substantiver | `apertures`, `auguries`, `apparitions` |
| Verber | `align`, `thicken`, `emerge` |
| Adverbier | `rhythmically`, `vertically`, `recursively`, `now` |

Adverbiet står sidst (*apertures align now*) eller først med komma (*now, apertures align*). `now` indgår i 18 digte.

## Filer

| Fil | Indhold |
| --- | --- |
| [sun.pl](sun.pl) | Saros-tabel, opslag, ordskift, deltoner og fem udskriftsformater. |
| [saros.pl](saros.pl) | Minimal generator med engelske prædikatnavne. |
| [sol.pl](sol.pl) | Minimal generator med danske prædikatnavne. |
| [old-sun.pl](old-sun.pl) | Tidligere udgave med Saros-tabellen og tre udskriftsformater. |

De to minimale generatorer har `apparitions` før `auguries`. Derfor får nogle digte andre numre end i `sun.pl`.

## Kørsel med SWI-Prolog

```sh
swipl -q -s saros.pl -t halt
swipl -q -s sol.pl -t halt
swipl -q -s sun.pl -t halt
```

`sun.pl` kører `self_check/0` før standardudskriften, som viser nummer, dato, formørkelsestype og digt.

Start en interaktiv session med `swipl -q -s sun.pl`.

```prolog
?- poem(48, Text).
Text = 'now, apertures emerge'.
?- poem(N, 'now, apertures emerge').
N = 48.
```

I den interaktive session kan du vælge mellem `print_manifestations`, `print_saros_edition`, `print_glossematic_edition`, `print_mutation_edition` og `print_sounding_edition`.

## Formørkelser og deltoner

Modellen følger Hjelmslevs fire strata. Udtrykkets form og substans er henholdsvis ordgitteret og deltonerne. 

Indholdets form og substans er formørkelsesnumrene og tabellens astronomiske data.

Et trin i ordgitteret forskyder nummeret med 1 for adverbiet, 4 for verbet, 12 for substantivet og 36 ved skift af ordstilling.

Bogstavets alfabetplacering modulo 12 giver deltonenummeret over A2 (110 Hz). Resten 0 angiver stilhed. Kun `thicken` og `now` mangler første deltone.

## Bogudgaver

Forlaget Akse har udgivet *Sun: 72 Poems for 72 Solar Eclipses* i to indbundne udgaver. 

Begge bøger indeholder de 72 digte med tilhørende formørkelser og deltoner samt den trykte kildekode, men i forskellige rækkefølger.

| Udgivet | Sider | Format | ISBN |
| --- | ---: | --- | --- |
| 7. november 2026 | 84 | 12,5 × 19,6 cm | 9788797786772 |
| 11. november 2026 | 86 | 15,5 × 23,5 cm | 9788740991338 |
## Licens og citering

Koden er udgivet under MIT-licensen. Se [CITATION.cff](CITATION.cff) for citeringsoplysninge
