*apertures align recursively / now, apparitions emerge*

# Triptych
A Prolog (or *pro-logos*) realisation of a system poem.
The generator produces 72 variants of the poem:
> 3 nouns × 3 verbs × 4 adverbs × 2 syntactic orders = 72

One variant for each solar eclipse in Saros 126 (1179–2459).
## About
*Sun* is built on glossematics, the theory of language Louis Hjelmslev worked out in the 1940s. For Hjelmslev a language is *form* first of all, a web of relations laid across unshaped *substance*, and it runs on two planes at once: *expression* on the side of the signifier, *content* on the side of the signified. Underneath the signs he places *figurae*, a small closed stock of sub-elements that recombine to make everything a language can say.

In *Sun* the figurae are ten words: three nouns, three verbs, four adverbs, the last of them the deictic *now*. The grid combines them and seventy-two variants fall out, one per eclipse of Saros 126. Seventy-two is the entire vocabulary of the thing. There is no seventy-third.
## Why Prolog
Prolog suits this better than a procedural language would. You don't give it steps to run; you state the constraints and let it find whatever satisfies them. Its one building block is the relation, the *predicate*, which is also where Hjelmslev begins: his primitive unit is the *function*, the dependency between two terms, and the terms are only ever what the relation needs them to be. Relation first, contents second, in both systems.

So the poems aren't composed one at a time. The program goes through the grid, turns up every combination the constraints permit, and the seventy-two that survive are what the system proves. They are closer to theorems than to anything a person sat down and wrote.

Prolog has the right ancestry for it, too. It came out of Alain Colmerauer's group in Marseille around 1972, from work on parsing natural language, which is why it handles word order and the placing of *now* as exactly as it does.
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
**The Antikythera mechanism** — a hand-cranked bronze calculator from around the 2nd century BCE. One of its dials was a spiral marked with the eclipses it could predict across the Saros cycle, a single glyph for each. *Sun* keeps that gesture, one mark per eclipse, but nothing of the machine itself: no bronze, no gears, no fixed longitude to read it from. A grid needs no place to stand. The only thing locating these poems is the *now* at the close of each line.

**Howard Russell Butler's eclipse triptych** — three oil paintings of total eclipses (Baker, Oregon, 1918; Lompoc, California, 1923; Middletown, Connecticut, 1925). Butler worked from shorthand notes scribbled during the few minutes of totality, then rebuilt the full canvases afterward for the Hayden Planetarium. 

His three-panel form is the model for the triptych here, and so is the double life he gave each painting: a piece of scientific record that is also a thing made to be looked at. Three videos, three nouns, one brief event written down to be built later.

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
