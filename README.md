*apertures align recursively / now, apparitions emerge*

# Triptych

A Prolog (or *pro-logos*) realisation of a system poem.

The generator produces 72 variants of the poem:

> 3 nouns × 3 verbs × 4 adverbs × 2 syntactic orders = 72

One variant for each solar eclipse in Saros 126 (1179–2459).

`saros.pl` is a minimal version of the work consisting of a 72-line Prolog program that generaes all 72 variants of the poem-structure. `sun.pl` is an expanded implementation that makes the underlying linguistic and conceptual structure explicit.

## About

*Sun* is inspired by glossematics, the theory of language the Danish Linguist Louis Hjelmslev worked out in the 1930s. For Hjelmslev a language is *form* first of all, a web of relations laid across unshaped *substance*, and it runs on two planes at once: *expression* on the side of the signifier, *content* on the side of the signified. Underneath the signs he places *figurae*, a small closed stock of sub-elements that recombine to make everything a language can say.

*Sun* consists of  three nouns, three verbs, four adverbs, the last of which is the deictic *now*. 

The grid combines them and seventy-two variants fall out, one per eclipse of Saros 126.

## Why Prolog

Prolog suits this better than a procedural language would. You don't give it steps to run; you state the constraints and let it find whatever satisfies them. Its one building block is the relation, the *predicate*, which is also where Hjelmslev begins: his primitive unit is the *function*, the dependency between two terms, and the terms are only ever what the relation needs them to be. Relation first, contents second, in both systems.

So the poems aren't composed one at a time. The program goes through the grid, turns up every combination the constraints permit, and the seventy-two that survive are the program's ooutput. Prolog has the right ancestry for it, too, I think, as it came out of Alain Colmerauer's group in Marseille around 1972, from work on parsing natural language, which is why it handles word order exactly as it does.

## Usage

```bash
swipl saros.pl
```

Output:

```text
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
- '72, the year Prolog appeared
- The Danish original, *Omkring sprogteoriens grundlæggelse*, uses the word 'sproget' 172 times

## Further reading

For the full essay on glossematics, heteroglossia and the system poetry genealogy, see [bergholt.net/sun](https://bergholt.net/sun).

## Background

> We must, therefore, register the relation between expression-correlation and content-correlation for all entities of the text in both planes. The distinctive factor is seen to be relevant for all inventorying. A correlation in one plane, which in this way has relation to a correlation in the other plane of a language, we shall call a commutation. This is a practical definition; in the theory, we seek, to be sure, a more abstract and more general formulation. Just as we can imagine a correlation and an exchange within a paradigm that have relation to a corresponding correlation and to a corresponding exchange within a paradigm in the other plane of a language, so also we can imagine a relation and a shift within a chain that have relation to a corresponding relation and to a corresponding shift within a chain in the other plane of a language; in such a case we shall speak of a permutation. A permutation is frequently found between signs of relatively large extension; and it is even possible to define words as minimal permutable signs. As a common term for commutation and permutation we choose mutation.
>
> (Hjelmslev 75)

> Now, as we have already seen (pp. 9–10), process and system are concepts of great generality, which cannot be restricted exclusively to semiotic objects. We find convenient and traditional special designations for a semiotic process and a semiotic system respectively in the names *syntagmatic* and *paradigmatic*. When it is a question of language (in the ordinary sense of the word), which indeed alone interests us for the present, we can also use simpler designations: the process can here be called a *text*, and the system a *language*.
>
> A process and a system that belongs to it ("lies behind it") together contract a function, which, depending on the point of view, may be conceived as a relation or as a correlation. A closer investigation of this function soon shows us that it is a determination in which the system is the constant: the process determines the system. The decisive point is not the superficial relationship consisting in the fact that the process is the more immediately accessible for observation, while the system must be "ordered to" the process—"discovered" behind it by means of a procedure—and so is only mediately knowable insofar as it is not presented to us on the basis of a previously performed procedure. This superficial relationship might make it seem that the process can exist without a system but not vice versa. But the decisive point is that the existence of a system is a necessary premiss for the existence of a process: the process comes into existence by virtue of a system's being present behind it, a system which governs and determines it in its possible development. A process is unimaginable—because it would be in an absolute and irrevocable sense inexplicable—without a system lying behind it. On the other hand, a system is not unimaginable without a process; the existence of a system does not presuppose the existence of a process. The system does not come into existence by virtue of a process's being found.
>
> It is thus impossible to have a text without a language lying behind it. On the other hand, one can have a language without a text constructed in that language.
>
> This means that the language in question is foreseen by linguistic theory as a possible system, but that no process belonging to it is present as realised. The textual process is *virtual*.
>
> (Hjelmslev 39)

## Works Cited

Hjelmslev, Louis. *Prolegomena to a Theory of Language*. Translated by Francis J. Whitfield, U of Wisconsin P, 1961. Originally published as *Omkring sprogteoriens grundlæggelse*, *Festskrift udgivet af Københavns Universitet i anledning af Universitetets Aarsfest*, Nov. 1943, pp. 3–113; also published separately by Ejnar Munksgaard, Copenhagen, 1943.

## License

MIT License. Feel free to use for your own projects.

---

*copenhagen | may | 2026 | kasper bergholt*
