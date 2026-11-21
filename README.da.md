# Sun: 72 digte til 72 solformørkelser

[English](README.md)

<img width="500" alt="Sun: 72 Poems for 72 Solar Eclipses" src="https://github.com/user-attachments/assets/d5f51300-d8fd-4a69-b945-eee171bda986" />

*Triptych* er en Prolog-implementering af systemdigtet *Sun*. Tre substantiver, tre verber og fire adverbier kombineres i to ordstillinger. Det giver 72 digte, ét for hver solformørkelse i Saros 126 (1179–2459).

Den totale solformørkelse den 12. august 2026 er nummer 48 i serien. I `sun.pl` svarer den til *now, apertures emerge*.

## Ordforråd og ordstilling

| Ordklasse | Ord i rækkefølgen i `sun.pl` |
| --- | --- |
| Substantiver | `apertures`, `auguries`, `apparitions` |
| Verber | `align`, `thicken`, `emerge` |
| Adverbier | `rhythmically`, `vertically`, `recursively`, `now` |

Adverbiet står enten sidst (*apertures align now*) eller først med komma (*now, apertures align*). Hver kombination af de tre ord forekommer i begge ordstillinger. `now` indgår i 18 af de 72 digte.

## Filer

| Fil | Indhold |
| --- | --- |
| [sun.pl](sun.pl) | Udvidet udgave med opslag mellem digte og formørkelser, ordskift, deltoner og fem udskriftsformater. |
| [saros.pl](saros.pl) | Minimal generator med engelske prædikatnavne. |
| [sol.pl](sol.pl) | Minimal generator med danske prædikatnavne og samme engelske ordforråd. |
| [old-sun.pl](old-sun.pl) | Tidligere udgave med Saros-tabellen og tre udskriftsformater. |

De to minimale generatorer har `apparitions` før `auguries`. Derfor får nogle af digtene andre numre end i `sun.pl`.

## Kørsel

Med SWI-Prolog udskriver hver af disse kommandoer en liste med 72 digte.

```sh
swipl -q -s saros.pl -t halt
swipl -q -s sol.pl -t halt
swipl -q -s sun.pl -t halt
```

Ved indlæsning af `sun.pl` kontrollerer `self_check/0` blandt andet antallet af digte, deres entydighed og koblingen til Saros-tabellen. Standardudskriften viser nummer, dato, formørkelsestype og digt.

Start en interaktiv session med `swipl -q -s sun.pl`. Efter standardudskriften kan du slå op i begge retninger.

```prolog
?- poem(48, Text).
Text = 'now, apertures emerge'.

?- poem(N, 'now, apertures emerge').
N = 48.

?- saros_date(48, Year, Month, Day).
Year = 2026,
Month = 8,
Day = 12.
```

| Prædikat | Udskrift |
| --- | --- |
| `print_manifestations/0` | Nummer og digt |
| `print_saros_edition/0` | Digte med formørkelsernes datoer og typer |
| `print_glossematic_edition/0` | Ordvalg, ordstilling og formørkelsesdata |
| `print_mutation_edition/0` | Ændringer i ordvalg og ordstilling med udgangspunkt i digt 48 |
| `print_sounding_edition/0` | Deltoner for hvert ord og hvert digt |

## Formørkelser og deltoner

`sun.pl` forbinder fire dele i en model inspireret af Louis Hjelmslevs glossematik. Ordforrådet og de to ordstillinger udgør udtrykkets form. Deltonerne udgør udtrykkets substans. Rækken af formørkelsesnumre udgør indholdets form, og oplysningerne i Saros-tabellen udgør indholdets substans.

Når man går ét trin frem i en ordklasse eller skifter fra efterstillet til foranstillet adverbium, forskydes digtets nummer. Tabellen viser også forskellen i år, målt fra den første formørkelse i serien.

| Ændring | Trin i serien | År fra første formørkelse |
| --- | ---: | ---: |
| Adverbium | 1 | 18 |
| Verbum | 4 | 72 |
| Substantiv | 12 | 216 |
| Ordstilling | 36 | 649 |

Hvert bogstav får et deltonenummer ud fra sin plads i alfabetet modulo 12. Grundtonen er A2 (110 Hz). Resten 0 udskrives som stilhed. Gentagelser af samme deltonenummer tælles i hvert ord. `thicken` og `now` er de eneste ord, hvor første deltone mangler.

## Bogudgaver

Forlaget Akse har udgivet *Sun: 72 Poems for 72 Solar Eclipses* i to indbundne udgaver med forskellige omslag og forskellig rækkefølge. Hvert digt har sin egen side med den tilhørende formørkelse, bogstaverne og deltonerne. Kildekoden er trykt bagest.

| | Første udgave | Anden udgave |
| --- | --- | --- |
| Udgivet | 7. november 2026 | 11. november 2026 |
| Sider | 84 | 86 |
| Format | 12,5 × 19,6 cm | 15,5 × 23,5 cm |
| ISBN | 9788797786772 | 9788740991338 |

## Licens og citering

Koden er udgivet under MIT-licensen. Citeringsoplysninger findes i [CITATION.cff](CITATION.cff).
