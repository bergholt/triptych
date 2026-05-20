# Triptych
A Prolog (or *pro-logos*) realisation of a system poem.
The generator produces 72 variants of the poem:
> 3 nouns × 3 verbs × 4 adverbs × 2 syntactic orders = 72

One variant for each solar eclipse in Saros 126 (1179–2459).
## About
*Sun* treats language as a combinatory machine in the Hjelmslevian sense of glossematics: meaning emerges not from words in isolation but from finite elements permuted through fixed constraints. 
A ten-word grid, three nouns, three verbs, four adverbs, the last being the deictic *now*, generates seventy-two variants, structurally mapped onto the seventy-two eclipses of Saros 126.
For Louis Hjelmslev, a language is pure *form*: a network of relations laid over an unformed *substance*, and articulated across two planes: *expression* (the signifier side) and *content* (the signified side). 
Beneath its signs sit *figurae*, a small closed inventory of elements that recombine under rule to yield an unbounded output. *Sun* takes this literally. Ten words are the inventory, the grid is the rule, and the seventy-two poems are what the system contains.
## Why Prolog
Prolog mirrors the structuralist logic of the combinatory machine. Unlike procedural languages, it is *declarative*: it states the constraints of a system rather than the steps to execute it. Its primitive is the relation, the *predicate*, exactly as Hjelmslev's primitive is the *function*, the dependence between elements. 
In both, the relation comes first; the terms are defined by the positions they occupy within it. The program proceeds by exhaustively enumerating every admissible combination of the grid. The poems are therefore not *written* one by one, they are *proved*, each a logical consequence of the paradigmatic axes. 
The language's own roots are in computational linguistics: Prolog was built in Alain Colmerauer's Marseille group around 1972, out of work on parsing natural language, which is the source of its precise control over syntactic order and deictic anchoring.
## Usage
Requires SWI-Prolog.
```bash
swipl saros.pl
```
Output:
```
1. apertures align rhythmically
2. apertures align vertically
3. apertures align recursively
4. apertures align now
...
72. now, apparitions emerge
```
## Why 72
- 72 eclipses in Saros 126 (1179–2459)
- 72 variants of the poem
- 72 lines of code
- 72 outputs when run
## Inspiration
**The Antikythera mechanism** — the bronze, hand-cranked calculator (c. 2nd century BCE) whose spiral dial carried one glyph for each eclipse it could predict across the Saros cycle. *Sun* keeps the gesture but drops the bronze: one variant per eclipse of Saros 126. Where the mechanism was bound to a longitude, the grid is placeless, anchored only by the deictic *now*.
**Howard Russell Butler's eclipse triptych** (1918 Baker, Oregon; 1923 Lompoc, California; 1925 Middletown, Connecticut): three oil paintings of total solar eclipses, recorded in rapid shorthand during the few minutes of totality and reconstructed for the Hayden Planetarium. 
Butler's three-panel form, and his treatment of the corona as at once a scientific record and an aesthetic object, is the precedent for the triptych: three videos, three nouns, one transient event encoded for later realization.
## Further reading
For the full essay on heteroglossia, chronotopes, and glossematics, see [bergholt.net/glossary](https://bergholt.net/glossary).
## License
MIT License. Feel free to use for your own projects.

---

> Now, as we have already seen (pp. 9–10), process and system are concepts of great generality, which cannot be restricted exclusively to semiotic objects. We find convenient and traditional special designations for a semiotic process and a semiotic system respectively in the names *syntagmatic* and *paradigmatic*. When it is a question of language (in the ordinary sense of the word), which indeed alone interests us for the present, we can also use simpler designations: the process can here be called a *text*, and the system a *language*.
>
> A process and a system that belongs to it ("lies behind it") together contract a function, which, depending on the point of view, may be conceived as a relation or as a correlation. A closer investigation of this function soon shows us that it is a determination in which the system is the constant: the process determines the system. The decisive point is not the superficial relationship consisting in the fact that the process is the more immediately accessible for observation, while the system must be "ordered to" the process—"discovered" behind it by means of a procedure—and so is only mediately knowable insofar as it is not presented to us on the basis of a previously performed procedure. This superficial relationship might make it seem that the process can exist without a system but not vice versa. But the decisive point is that the existence of a system is a necessary premiss for the existence of a process: the process comes into existence by virtue of a system's being present behind it, a system which governs and determines it in its possible development. A process is unimaginable—because it would be in an absolute and irrevocable sense inexplicable—without a system lying behind it. On the other hand, a system is not unimaginable without a process; the existence of a system does not presuppose the existence of a process. The system does not come into existence by virtue of a process's being found.
>
> It is thus impossible to have a text without a language lying behind it. On the other hand, one can have a language without a text constructed in that language.
>
> This means that the language in question is foreseen by linguistic theory as a possible system, but that no process belonging to it is present as realised. The textual process is *virtual*.
>
> — Louis Hjelmslev, *Prolegomena to a Theory of Language*, 1961 (*Omkring sprogteoriens grundlæggelse*, 1943)

---

Copenhagen, 2026
