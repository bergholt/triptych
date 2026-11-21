; ========================================================================
; SUN
; ========================================================================
;
; sun.asm
; Sun: 72 Poems for the Solar Eclipse of August 12th 2026
; After the glossematic and acoustic architecture of https://bergholt.net/sun
; An x86-64 assembly realisation of sun.pl
; (github.com/bergholt/triptych, MIT license).
;
; NASM syntax, 64-bit Linux, no C library: the program talks to the kernel
; through two system calls, write and exit.
;
; BUILD  : nasm -f elf64 sun.asm -o sun.o && ld sun.o -o sun
; RUN    : ./sun                       (Saros edition, the default)
;          ./sun glossematic           (or: manifestations, saros,
;                                       mutation, sounding)
; ONLINE : paste the whole file into an online NASM x86-64 runner
;          (mycompiler.io, Coddy) and press Run. Those runners pass no
;          arguments, so the edition comes from DEFAULT_EDITION below.
;
; Exit status: 0 printed, 1 a self-check failed (sun_check_failed(label)
; on stderr), 2 unknown edition name.
;
; Translation notes.
;   Prolog states relations and lets the engine search; assembly has only
;   registers, memory and jumps, so every search is a loop written out.
;   A cell of the grid is one 64-bit register holding four byte-sized
;   indices: byte 0 noun, byte 1 verb, byte 2 adverb, byte 3 order. The
;   two directions of selection/5 are `selection` (ordinal -> cell, by
;   division through the strides) and `encode` (cell -> ordinal, by the
;   same strides multiplied back); `build_cells` enumerates the inventory
;   in the order Prolog finds the solutions (order, noun, verb, adverb).
;
;   Nothing numerical is written into the code: cardinalities are counted
;   from the inventory tables, strides are multiplied from cardinalities,
;   intervals are read from the Saros table, spectra are computed from the
;   letters. The eleven checks of sun.pl's self_check/0 then hold these
;   derived values to the numbers the work asserts, before any edition is
;   printed.
;
;   Gamma is stored as a signed integer in ten-thousandths (-1.5356 is
;   -15356), the precision the Prolog table and printer use, so no floating
;   point is involved anywhere.
;
;   Functions follow the System V calling convention: arguments in rdi,
;   rsi, rdx; result in rax; rbx, rbp and r12-r15 preserved.
;
;   The inventory order is part of the artwork: changing it changes eclipse
;   assignments. Astronomical data and the epigraph are retained from the
;   original; the checks validate structure, not external accuracy. ASCII
;   output; dates use the original Julian/Gregorian catalogue convention.
;
; Two findings the sounding rule yields that the essay does not state:
;   'recursively' touches partial 1 once (its final y, 25 mod 12);
;   'thicken' never touches partial 1 at all (t h i c k e n = 8 8 9 3 11 5 2).
; The words that leave the drone hanging are therefore exactly the two
; Germanic cells. The sounding check asserts that equivalence. Under a
; literal mod 12 the letter l (12) yields partial 0, printed as a silence.

; Edition printed when the program is run without an argument:
; 0 manifestations, 1 saros, 2 glossematic, 3 mutation, 4 sounding.
DEFAULT_EDITION equ 1

default rel
global _start

SYS_WRITE   equ 1
SYS_EXIT    equ 60
STDOUT      equ 1
STDERR      equ 2

OBUF_SIZE   equ 65536
MAXCELLS    equ 256
POEM_W      equ 64

; ============================================================
; I. GLOSSEMATIC INVENTORY AND STRATA
; ============================================================

CAT_NOUN    equ 0
CAT_VERB    equ 1
CAT_ADVERB  equ 2
CAT_ORDER   equ 3
NCAT        equ 4               ; categories, in the order sun.pl declares them
NLEX        equ 3               ; noun, verb, adverb hold words

REG_LATINATE equ 0              ; latinate covers Greek
REG_GERMANIC equ 1
REF_AUTONOMOUS equ 0
REF_DEICTIC    equ 1
MODE_EVENT     equ 0
MODE_ACTION    equ 1
MODE_MANNER    equ 2
MODE_TACTILE   equ 3            ; tactile_density
MODE_TEMPORAL  equ 4            ; temporal_utterance

section .rodata

; The four strata of the work (Hjelmslev, Prolegomena, def. 16-20).
stratum_ef:     db "expression/form: paradigmatic_syntagmatic_grid", 0
stratum_es:     db "expression/substance: overtone_field_above_a2", 0
stratum_cf:     db "content/form: saros_126_ordinal_series", 0
stratum_cs:     db "content/substance: solar_eclipse_ephemeris", 0

; The ten words and the two orders.
w_apertures:    db "apertures", 0
w_auguries:     db "auguries", 0
w_apparitions:  db "apparitions", 0
w_align:        db "align", 0
w_thicken:      db "thicken", 0
w_emerge:       db "emerge", 0
w_rhythmically: db "rhythmically", 0
w_vertically:   db "vertically", 0
w_recursively:  db "recursively", 0
w_now:          db "now", 0
w_suffix:       db "suffix", 0
w_prefix:       db "prefix", 0

; Diachronic precursor (2011): the grid this one regularises.
p_interpretants: db "interpretants", 0
p_phases:        db "phases", 0
p_conscience:    db "conscience", 0
p_flow:          db "flow", 0
p_infer:         db "infer", 0
p_projects:      db "projects", 0
p_conclusively:  db "conclusively", 0

cn_noun:        db "noun", 0
cn_verb:        db "verb", 0
cn_adverb:      db "adverb", 0
cn_order:       db "order", 0

section .data

; Paradigmatic invariants: 3 x 3 x 4 = 36 commutable selections.
; Syntagmatic invariants: 2 orders permute 36 to 72.
; The position of each word in its table is its index.
noun_words:     dq w_apertures, w_auguries, w_apparitions
noun_end:
verb_words:     dq w_align, w_thicken, w_emerge
verb_end:
adverb_words:   dq w_rhythmically, w_vertically, w_recursively, w_now
adverb_end:
order_words:    dq w_suffix, w_prefix
order_end:

; Each category: its table and its cardinality, counted from the table.
cat_tab:        dq noun_words,   (noun_end - noun_words) / 8
                dq verb_words,   (verb_end - verb_words) / 8
                dq adverb_words, (adverb_end - adverb_words) / 8
                dq order_words,  (order_end - order_words) / 8
cat_names:      dq cn_noun, cn_verb, cn_adverb, cn_order

precursor_2011: dq p_interpretants, p_phases, p_conscience
                dq p_flow, p_infer, p_projects
                dq w_rhythmically, p_conclusively, w_vertically

; ============================================================
; VIII (data). MARKED CELLS: REGISTER, REFERENCE, MODE
; ============================================================

; word, register, reference, mode (16 bytes per entry)
%macro LEX 4
    dq %1
    db %2, %3, %4, 0, 0, 0, 0, 0
%endmacro
LEX_SIZE equ 16

lex_tab:
    LEX w_apertures,    REG_LATINATE, REF_AUTONOMOUS, MODE_EVENT
    LEX w_auguries,     REG_LATINATE, REF_AUTONOMOUS, MODE_EVENT
    LEX w_apparitions,  REG_LATINATE, REF_AUTONOMOUS, MODE_EVENT
    LEX w_align,        REG_LATINATE, REF_AUTONOMOUS, MODE_ACTION
    LEX w_emerge,       REG_LATINATE, REF_AUTONOMOUS, MODE_ACTION
    LEX w_rhythmically, REG_LATINATE, REF_AUTONOMOUS, MODE_MANNER
    LEX w_vertically,   REG_LATINATE, REF_AUTONOMOUS, MODE_MANNER
    LEX w_recursively,  REG_LATINATE, REF_AUTONOMOUS, MODE_MANNER
    LEX w_thicken,      REG_GERMANIC, REF_AUTONOMOUS, MODE_TACTILE
    LEX w_now,          REG_GERMANIC, REF_DEICTIC,    MODE_TEMPORAL
lex_end:

; ============================================================
; V (data). CONTENT-FORM: SAROS 126 (1179 J - 2459)
; ============================================================

T_PARTIAL   equ 0
T_ANNULAR   equ 1
T_HYBRID    equ 2
T_TOTAL     equ 3

; ordinal, year, month, day, type, gamma (ten-thousandths): 12 bytes each
%macro ECL 6
    db %1, %5, %3, %4
    dw %2, 0
    dd %6
%endmacro
E_ORD       equ 0
E_TYPE      equ 1
E_MON       equ 2
E_DAY       equ 3
E_YEAR      equ 4
E_GAMMA     equ 8
ECL_SIZE    equ 12

saros_tab:
    ECL  1, 1179,  3, 10, T_PARTIAL, -15356
    ECL  2, 1197,  3, 20, T_PARTIAL, -14880
    ECL  3, 1215,  3, 31, T_PARTIAL, -14344
    ECL  4, 1233,  4, 11, T_PARTIAL, -13717
    ECL  5, 1251,  4, 22, T_PARTIAL, -13041
    ECL  6, 1269,  5,  2, T_PARTIAL, -12291
    ECL  7, 1287,  5, 14, T_PARTIAL, -11500
    ECL  8, 1305,  5, 24, T_PARTIAL, -10658
    ECL  9, 1323,  6,  4, T_ANNULAR,  -9799
    ECL 10, 1341,  6, 14, T_ANNULAR,  -8922
    ECL 11, 1359,  6, 26, T_ANNULAR,  -8038
    ECL 12, 1377,  7,  6, T_ANNULAR,  -7168
    ECL 13, 1395,  7, 17, T_ANNULAR,  -6318
    ECL 14, 1413,  7, 27, T_ANNULAR,  -5506
    ECL 15, 1431,  8,  8, T_ANNULAR,  -4737
    ECL 16, 1449,  8, 18, T_ANNULAR,  -4030
    ECL 17, 1467,  8, 29, T_ANNULAR,  -3391
    ECL 18, 1485,  9,  9, T_ANNULAR,  -2811
    ECL 19, 1503,  9, 20, T_ANNULAR,  -2314
    ECL 20, 1521,  9, 30, T_ANNULAR,  -1892
    ECL 21, 1539, 10, 12, T_ANNULAR,  -1551
    ECL 22, 1557, 10, 22, T_ANNULAR,  -1266
    ECL 23, 1575, 11,  2, T_ANNULAR,  -1061
    ECL 24, 1593, 11, 22, T_ANNULAR,   -906
    ECL 25, 1611, 12,  4, T_ANNULAR,   -803
    ECL 26, 1629, 12, 14, T_ANNULAR,   -725
    ECL 27, 1647, 12, 26, T_ANNULAR,   -675
    ECL 28, 1666,  1,  5, T_ANNULAR,   -624
    ECL 29, 1684,  1, 16, T_ANNULAR,   -565
    ECL 30, 1702,  1, 28, T_ANNULAR,   -484
    ECL 31, 1720,  2,  8, T_ANNULAR,   -375
    ECL 32, 1738,  2, 18, T_ANNULAR,   -211
    ECL 33, 1756,  3,  1, T_ANNULAR,      6
    ECL 34, 1774,  3, 12, T_ANNULAR,    284
    ECL 35, 1792,  3, 22, T_ANNULAR,    618
    ECL 36, 1810,  4,  4, T_ANNULAR,   1031
    ECL 37, 1828,  4, 14, T_HYBRID ,   1498
    ECL 38, 1846,  4, 25, T_HYBRID ,   2038
    ECL 39, 1864,  5,  6, T_HYBRID ,   2622
    ECL 40, 1882,  5, 17, T_TOTAL  ,   3269
    ECL 41, 1900,  5, 28, T_TOTAL  ,   3943
    ECL 42, 1918,  6,  8, T_TOTAL  ,   4658
    ECL 43, 1936,  6, 19, T_TOTAL  ,   5389
    ECL 44, 1954,  6, 30, T_TOTAL  ,   6135
    ECL 45, 1972,  7, 10, T_TOTAL  ,   6872
    ECL 46, 1990,  7, 22, T_TOTAL  ,   7597
    ECL 47, 2008,  8,  1, T_TOTAL  ,   8307
    ECL 48, 2026,  8, 12, T_TOTAL  ,   8977
    ECL 49, 2044,  8, 23, T_TOTAL  ,   9613
    ECL 50, 2062,  9,  3, T_PARTIAL,  10191
    ECL 51, 2080,  9, 13, T_PARTIAL,  10723
    ECL 52, 2098,  9, 25, T_PARTIAL,  11184
    ECL 53, 2116, 10,  6, T_PARTIAL,  11589
    ECL 54, 2134, 10, 17, T_PARTIAL,  11931
    ECL 55, 2152, 10, 28, T_PARTIAL,  12213
    ECL 56, 2170, 11,  8, T_PARTIAL,  12426
    ECL 57, 2188, 11, 18, T_PARTIAL,  12591
    ECL 58, 2206, 12,  1, T_PARTIAL,  12711
    ECL 59, 2224, 12, 11, T_PARTIAL,  12791
    ECL 60, 2242, 12, 22, T_PARTIAL,  12836
    ECL 61, 2261,  1,  2, T_PARTIAL,  12873
    ECL 62, 2279,  1, 13, T_PARTIAL,  12899
    ECL 63, 2297,  1, 23, T_PARTIAL,  12940
    ECL 64, 2315,  2,  5, T_PARTIAL,  12991
    ECL 65, 2333,  2, 15, T_PARTIAL,  13087
    ECL 66, 2351,  2, 27, T_PARTIAL,  13209
    ECL 67, 2369,  3,  9, T_PARTIAL,  13392
    ECL 68, 2387,  3, 20, T_PARTIAL,  13624
    ECL 69, 2405,  3, 31, T_PARTIAL,  13928
    ECL 70, 2423,  4, 11, T_PARTIAL,  14282
    ECL 71, 2441,  4, 21, T_PARTIAL,  14706
    ECL 72, 2459,  5,  3, T_PARTIAL,  15188
saros_end:

section .rodata

tn_partial:     db "partial", 0
tn_annular:     db "annular", 0
tn_hybrid:      db "hybrid", 0
tn_total:       db "total", 0

m_jan: db "Jan",0
m_feb: db "Feb",0
m_mar: db "Mar",0
m_apr: db "Apr",0
m_may: db "May",0
m_jun: db "Jun",0
m_jul: db "Jul",0
m_aug: db "Aug",0
m_sep: db "Sep",0
m_oct: db "Oct",0
m_nov: db "Nov",0
m_dec: db "Dec",0

; Editions and their texts.
en_manifestations: db "manifestations", 0
en_saros:          db "saros", 0
en_glossematic:    db "glossematic", 0
en_mutation:       db "mutation", 0
en_sounding:       db "sounding", 0

epi_1:  db "Nulle archive sans dehors.", 0
epi_2:  db "-- Jacques Derrida, Mal d'archive, Galilee, 1995, page 26", 0
s_dash2:        db "--", 0
s_gloss_head:   db "expression-form / content-form", 0
s_mut_head:     db "mutation: the chain held, one cell exchanged", 0
s_drone_a:      db "drone A2 ", 0
s_drone_b:      db " Hz; partial = alphabet position mod 12; noun, verb, adverb", 0
s_sp:           db " ", 0
s_2sp:          db "  ", 0
s_comma:        db ", ", 0
s_dotsp:        db ". ", 0
s_julian:       db " J", 0
s_slash:        db " / ", 0
s_arrow:        db "  ->  ", 0
s_gamma:        db "gamma ", 0
s_stride:       db "stride ", 0
s_interval:     db "  interval ", 0
s_years:        db " years", 0
s_from:         db "from ", 0
s_commut:       db "  commutation ", 0
s_permut:       db "  permutation ", 0
s_to:           db "-> ", 0
s_yrs:          db "y  ", 0
s_bar:          db " | ", 0
s_silence:      db "silence", 0
s_nofund:       db "   [no fundamental]", 0
s_colon:        db ": ", 0
s_rb:           db "]  ", 0

s_fail_a:       db "sun_check_failed(", 0
s_fail_b:       db ")", 10, 0
s_usage:        db "usage: sun [manifestations | saros | glossematic | mutation | sounding]", 10, 0

l_inventory:    db "inventory", 0
l_edition:      db "edition_order", 0
l_cardinality:  db "cardinality", 0
l_unique:       db "unique_poems", 0
l_coverage:     db "eclipse_coverage", 0
l_selection:    db "selection", 0
l_marked:       db "marked_cells", 0
l_anchor:       db "anchor", 0
l_boundaries:   db "boundaries", 0
l_mutation:     db "mutation", 0
l_sounding:     db "sounding", 0

; Literals the checks compare against: separate strings, so the checks
; hold the inventory to the text rather than to itself.
x_apertures:    db "apertures", 0
x_auguries:     db "auguries", 0
x_apparitions:  db "apparitions", 0
x_align:        db "align", 0
x_thicken:      db "thicken", 0
x_emerge:       db "emerge", 0
x_rhythmically: db "rhythmically", 0
x_vertically:   db "vertically", 0
x_recursively:  db "recursively", 0
x_now:          db "now", 0
x_suffix:       db "suffix", 0
x_prefix:       db "prefix", 0
x_anchor:       db "now, apertures emerge", 0
x_poem1:        db "apertures align rhythmically", 0
x_poem36:       db "apparitions emerge now", 0
x_poem37:       db "rhythmically, apertures align", 0
x_poem72:       db "now, apparitions emerge", 0

section .data

type_names:     dq tn_partial, tn_annular, tn_hybrid, tn_total
month_tab:      dq m_jan, m_feb, m_mar, m_apr, m_may, m_jun
                dq m_jul, m_aug, m_sep, m_oct, m_nov, m_dec
ed_names:       dq en_manifestations, en_saros, en_glossematic
                dq en_mutation, en_sounding
ed_funcs:       dq ed_manifestations, ed_saros, ed_glossematic
                dq ed_mutation, ed_sounding
NED equ 5

; The schema the edition must have, word by word (edition_order).
exp_noun:       dq x_apertures, x_auguries, x_apparitions
exp_verb:       dq x_align, x_thicken, x_emerge
exp_adverb:     dq x_rhythmically, x_vertically, x_recursively, x_now
exp_order:      dq x_suffix, x_prefix
exp_end:
exp_tab:        dq exp_noun,   (exp_verb - exp_noun) / 8
                dq exp_verb,   (exp_adverb - exp_verb) / 8
                dq exp_adverb, (exp_order - exp_adverb) / 8
                dq exp_order,  (exp_end - exp_order) / 8

DRONE_HZ        equ 110         ; A2
ANCHOR          equ 48          ; 12 August 2026: "now, apertures emerge"

section .bss

obuf:       resb OBUF_SIZE
opos:       resq 1
enum_ord:   resq MAXCELLS       ; cells: ordinals, in enumeration order
enum_cell:  resq MAXCELLS       ; cells: the packed cell of each
enum_n:     resq 1
mbuf:       resb 256            ; one manifestation
tbuf:       resb 256            ; scratch text
numbuf:     resb 32
specbuf:    resb 16             ; one spectrum: weight of partials 0..11
poems:      resb MAXCELLS * POEM_W
xbuf:       resq MAXCELLS       ; mutation targets
xbuf2:      resq MAXCELLS
sbuf:       resq MAXCELLS       ; sorting scratch

section .text

; ============================================================
; XI (a). OUTPUT
; ============================================================

; write_all(rdi=fd, rsi=buf, rdx=len): write until done.
write_all:
.again:
    test    rdx, rdx
    jz      .done
    mov     eax, SYS_WRITE
    push    rdi
    push    rsi
    push    rdx
    syscall
    pop     rdx
    pop     rsi
    pop     rdi
    test    rax, rax
    jle     .done                   ; error: give up quietly
    add     rsi, rax
    sub     rdx, rax
    jmp     .again
.done:
    ret

flush:
    mov     edi, STDOUT
    lea     rsi, [obuf]
    mov     rdx, [opos]
    call    write_all
    mov     qword [opos], 0
    ret

; emit_char(dil)
emit_char:
    mov     rax, [opos]
    cmp     rax, OBUF_SIZE
    jb      .room
    push    rdi
    call    flush
    pop     rdi
    xor     eax, eax
.room:
    lea     rcx, [obuf]
    mov     [rcx + rax], dil
    inc     rax
    mov     [opos], rax
    ret

emit_nl:
    mov     dil, 10
    jmp     emit_char

; emit_str(rdi=zero-terminated string)
emit_str:
    push    rbx
    mov     rbx, rdi
.l: movzx   edi, byte [rbx]
    test    edi, edi
    jz      .e
    call    emit_char
    inc     rbx
    jmp     .l
.e: pop     rbx
    ret

emit_line:
    call    emit_str
    jmp     emit_nl

; emit_spaces(rdi=count, may be <= 0)
emit_spaces:
    push    rbx
    mov     rbx, rdi
.l: test    rbx, rbx
    jle     .e
    mov     dil, ' '
    call    emit_char
    dec     rbx
    jmp     .l
.e: pop     rbx
    ret

; strlen(rdi) -> rax
strlen:
    xor     eax, eax
.l: cmp     byte [rdi + rax], 0
    je      .e
    inc     rax
    jmp     .l
.e: ret

; streq(rdi, rsi) -> rax = 1 if the strings are equal
streq:
.l: mov     al, [rdi]
    cmp     al, [rsi]
    jne     .no
    test    al, al
    jz      .yes
    inc     rdi
    inc     rsi
    jmp     .l
.yes:
    mov     eax, 1
    ret
.no:
    xor     eax, eax
    ret

; scat(rdi=dest, rsi=src) -> rax = end of dest (its terminating 0)
scat:
    mov     rax, rdi
.l: mov     cl, [rsi]
    mov     [rax], cl
    test    cl, cl
    jz      .e
    inc     rax
    inc     rsi
    jmp     .l
.e: ret

; emit_padr(rdi=string, rsi=width): string, then spaces to width
emit_padr:
    push    rbx
    push    r12
    mov     rbx, rdi
    mov     r12, rsi
    call    emit_str
    mov     rdi, rbx
    call    strlen
    mov     rdi, r12
    sub     rdi, rax
    call    emit_spaces
    pop     r12
    pop     rbx
    ret

; emit_padl(rdi=string, rsi=width): spaces to width, then string
emit_padl:
    push    rbx
    push    r12
    mov     rbx, rdi
    mov     r12, rsi
    call    strlen
    mov     rdi, r12
    sub     rdi, rax
    call    emit_spaces
    mov     rdi, rbx
    call    emit_str
    pop     r12
    pop     rbx
    ret

; itoa(rdi=signed value, rsi=dest): decimal, zero-terminated
itoa:
    mov     rax, rdi
    mov     r8, rsi
    test    rax, rax
    jns     .pos
    mov     byte [r8], '-'
    inc     r8
    neg     rax
.pos:
    lea     r9, [rsp - 40]          ; digits, reversed, in the red zone
    xor     ecx, ecx
    mov     r10d, 10
.d: xor     edx, edx
    div     r10
    add     dl, '0'
    mov     [r9 + rcx], dl
    inc     rcx
    test    rax, rax
    jnz     .d
.r: dec     rcx
    mov     dl, [r9 + rcx]
    mov     [r8], dl
    inc     r8
    test    rcx, rcx
    jnz     .r
    mov     byte [r8], 0
    ret

; emit_num(rdi=signed value)
emit_num:
    lea     rsi, [numbuf]
    call    itoa
    lea     rdi, [numbuf]
    jmp     emit_str

; emit_numl(rdi=signed value, rsi=width): right-aligned
emit_numl:
    push    rbx
    mov     rbx, rsi
    lea     rsi, [numbuf]
    call    itoa
    lea     rdi, [numbuf]
    mov     rsi, rbx
    call    emit_padl
    pop     rbx
    ret

; ============================================================
; II. EXPRESSION-FORM: CARDINALITY AND STRIDE
; ============================================================

; card(rdi=category) -> rax = number of invariants
card:
    lea     rax, [cat_tab]
    shl     rdi, 4
    mov     rax, [rax + rdi + 8]
    ret

; invariant(rdi=category, rsi=index) -> rax = string
invariant:
    lea     rax, [cat_tab]
    shl     rdi, 4
    mov     rax, [rax + rdi]
    mov     rax, [rax + rsi*8]
    ret

; system_cardinality -> rax = product of the four cardinalities
system_card:
    push    rbx
    push    r12
    mov     r12d, 1
    xor     ebx, ebx
.l: mov     rdi, rbx
    call    card
    imul    r12, rax
    inc     rbx
    cmp     rbx, NCAT
    jb      .l
    mov     rax, r12
    pop     r12
    pop     rbx
    ret

; "The categories are not distinguished by part of speech. They are
;  distinguished by how far a commutation carries you through the cycle."
; stride(rdi=category) -> rax: ordinals moved by one step within it.
;   adverb 1, verb A, noun A*V, order A*V*N. Derived.
stride:
    push    rbx
    push    r12
    push    r13
    mov     rbx, rdi
    mov     edi, CAT_ADVERB
    call    card
    mov     r12, rax                ; A
    mov     edi, CAT_VERB
    call    card
    mov     r13, rax                ; V
    mov     eax, 1
    cmp     rbx, CAT_ADVERB
    je      .done
    mov     rax, r12
    cmp     rbx, CAT_VERB
    je      .done
    imul    r12, r13                ; A*V
    mov     rax, r12
    cmp     rbx, CAT_NOUN
    je      .done
    mov     edi, CAT_NOUN
    call    card
    imul    rax, r12                ; A*V*N
.done:
    pop     r13
    pop     r12
    pop     rbx
    ret

; ============================================================
; III. SELECTION (BOTH DIRECTIONS)
; ============================================================

; cell_idx(rdi=cell, rsi=category) -> rax = that category's index
cell_idx:
    mov     rcx, rsi
    shl     ecx, 3
    mov     rax, rdi
    shr     rax, cl
    and     eax, 0xff
    ret

; cell_word(rdi=cell, rsi=category) -> rax = that category's word
cell_word:
    push    rsi
    call    cell_idx
    pop     rdi
    mov     rsi, rax
    jmp     invariant

; selection(rdi=ordinal) -> rax = cell, or -1 outside the grid.
; A bound ordinal decodes directly through the strides.
selection:
    push    rbx
    push    r12
    push    r13
    push    r14
    mov     rbx, rdi
    cmp     rbx, 1
    jl      .bad
    call    system_card
    cmp     rbx, rax
    jg      .bad
    lea     r12, [rbx - 1]          ; k, the remainder still to place
    xor     r13d, r13d              ; the cell being built
    mov     r14d, CAT_ORDER         ; order, noun, verb, then adverb
.next:
    mov     rdi, r14
    call    stride
    mov     rcx, rax
    mov     rax, r12
    xor     edx, edx
    div     rcx                     ; rax = index, rdx = remainder
    mov     r12, rdx
    mov     rcx, r14
    shl     ecx, 3
    shl     rax, cl
    or      r13, rax
    ; order -> noun -> verb -> adverb
    cmp     r14, CAT_ORDER
    jne     .not_order
    mov     r14d, CAT_NOUN
    jmp     .next
.not_order:
    cmp     r14, CAT_NOUN
    jne     .not_noun
    mov     r14d, CAT_VERB
    jmp     .next
.not_noun:
    cmp     r14, CAT_VERB
    jne     .placed
    mov     r14d, CAT_ADVERB
    jmp     .next
.placed:
    ; Each index must name an invariant of its category.
    xor     r14d, r14d
.valid:
    mov     rdi, r13
    mov     rsi, r14
    call    cell_idx
    mov     r12, rax
    mov     rdi, r14
    call    card
    cmp     r12, rax
    jae     .bad
    inc     r14
    cmp     r14, NCAT
    jb      .valid
    mov     rax, r13
    jmp     .out
.bad:
    mov     rax, -1
.out:
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret

; encode(rdi=cell) -> rax = ordinal, by the same strides as selection,
; so the mapping cannot drift between directions.
encode:
    push    rbx
    push    r12
    push    r13
    push    r14
    mov     rbx, rdi
    mov     r12d, 1
    xor     r13d, r13d
.l: mov     rdi, rbx
    mov     rsi, r13
    call    cell_idx
    mov     r14, rax
    mov     rdi, r13
    call    stride
    imul    rax, r14
    add     r12, rax
    inc     r13
    cmp     r13, NCAT
    jb      .l
    mov     rax, r12
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret

; build_cells: an unbound ordinal enumerates the inventory and encodes,
; in the order Prolog would find the solutions: order, noun, verb, adverb.
build_cells:
    push    rbx
    push    rbp
    push    r12
    push    r13
    push    r14
    push    r15
    xor     ebp, ebp                ; count
    xor     r12d, r12d              ; order
.o: mov     edi, CAT_ORDER
    call    card
    cmp     r12, rax
    jae     .done
    xor     r13d, r13d              ; noun
.n: mov     edi, CAT_NOUN
    call    card
    cmp     r13, rax
    jae     .o_next
    xor     r14d, r14d              ; verb
.v: mov     edi, CAT_VERB
    call    card
    cmp     r14, rax
    jae     .n_next
    xor     r15d, r15d              ; adverb
.a: mov     edi, CAT_ADVERB
    call    card
    cmp     r15, rax
    jae     .v_next
    cmp     rbp, MAXCELLS
    jae     .done
    mov     rbx, r12
    shl     rbx, 24
    mov     rax, r15
    shl     rax, 16
    or      rbx, rax
    mov     rax, r14
    shl     rax, 8
    or      rbx, rax
    or      rbx, r13
    mov     rdi, rbx
    call    encode
    lea     rcx, [enum_ord]
    mov     [rcx + rbp*8], rax
    lea     rcx, [enum_cell]
    mov     [rcx + rbp*8], rbx
    inc     rbp
    inc     r15
    jmp     .a
.v_next:
    inc     r14
    jmp     .v
.n_next:
    inc     r13
    jmp     .n
.o_next:
    inc     r12
    jmp     .o
.done:
    mov     [enum_n], rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbp
    pop     rbx
    ret

; ============================================================
; IV. SYNTAGMATIC FUNCTION AND MANIFESTATION
; ============================================================

%macro APPW 1                       ; append the cell's word of a category
    mov     rdi, rbx
    mov     esi, %1
    call    cell_word
    mov     rdi, r12
    mov     rsi, rax
    call    scat
    mov     r12, rax
%endmacro
%macro APPS 1                       ; append a fixed string
    mov     rdi, r12
    lea     rsi, [%1]
    call    scat
    mov     r12, rax
%endmacro

; render_cell(rdi=cell, rsi=dest) -> rax = end of text, or 0.
;   suffix: noun verb adverb        prefix: adverb, noun verb
render_cell:
    push    rbx
    push    r12
    push    r13
    mov     rbx, rdi
    mov     r12, rsi
    mov     byte [r12], 0
    mov     esi, CAT_ORDER
    call    cell_word
    mov     r13, rax
    mov     rdi, r13
    lea     rsi, [w_suffix]
    call    streq
    test    rax, rax
    jnz     .suffix
    mov     rdi, r13
    lea     rsi, [w_prefix]
    call    streq
    test    rax, rax
    jnz     .prefix
    xor     eax, eax
    jmp     .out
.suffix:
    APPW    CAT_NOUN
    APPS    s_sp
    APPW    CAT_VERB
    APPS    s_sp
    APPW    CAT_ADVERB
    mov     rax, r12
    jmp     .out
.prefix:
    APPW    CAT_ADVERB
    APPS    s_comma
    APPW    CAT_NOUN
    APPS    s_sp
    APPW    CAT_VERB
    mov     rax, r12
.out:
    pop     r13
    pop     r12
    pop     rbx
    ret

; manifestation(rdi=ordinal, rsi=dest) -> rax = end of text, or 0.
manifestation:
    push    rbx
    mov     rbx, rsi
    call    selection
    cmp     rax, -1
    je      .no
    mov     rdi, rax
    mov     rsi, rbx
    call    render_cell
    pop     rbx
    ret
.no:
    xor     eax, eax
    pop     rbx
    ret

; emit_manifestation(rdi=ordinal) -> rax = 0 if there is none
emit_manifestation:
    lea     rsi, [mbuf]
    call    manifestation
    test    rax, rax
    jz      .e
    lea     rdi, [mbuf]
    call    emit_str
    mov     eax, 1
.e: ret

; poems_of(rdi=text, rsi=out) -> rax = count: the poem read back to its
; ordinal(s), poem(N, Text) with Text bound.
poems_of:
    push    rbx
    push    r12
    push    r13
    push    r14
    mov     r12, rdi
    mov     r13, rsi
    xor     ebx, ebx
    xor     r14d, r14d
.l: cmp     rbx, [enum_n]
    jae     .e
    lea     rax, [enum_cell]
    mov     rdi, [rax + rbx*8]
    lea     rsi, [tbuf]
    call    render_cell
    test    rax, rax
    jz      .n
    lea     rdi, [tbuf]
    mov     rsi, r12
    call    streq
    test    rax, rax
    jz      .n
    lea     rax, [enum_ord]
    mov     rax, [rax + rbx*8]
    mov     [r13 + r14*8], rax
    inc     r14
.n: inc     rbx
    jmp     .l
.e: mov     rax, r14
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret

; ============================================================
; V. CONTENT-FORM: SAROS 126
; ============================================================

; saros(rdi=ordinal) -> rax = its eclipse record, or 0
saros:
    lea     rax, [saros_tab]
    lea     rcx, [saros_end]
.l: cmp     rax, rcx
    jae     .no
    movzx   edx, byte [rax + E_ORD]
    cmp     rdx, rdi
    je      .yes
    add     rax, ECL_SIZE
    jmp     .l
.no:
    xor     eax, eax
.yes:
    ret

; ============================================================
; VI-VII. SEMIOTIC FUNCTION; MUTATION
; ============================================================

; displacement(rdi=n1, rsi=n2) -> rax = signed years, rdx = 1 if defined.
; A mutation registers on the content plane as a displacement in years.
displacement:
    push    rbx
    push    r12
    mov     rbx, rsi
    call    saros
    test    rax, rax
    jz      .no
    movzx   r12d, word [rax + E_YEAR]
    mov     rdi, rbx
    call    saros
    test    rax, rax
    jz      .no
    movzx   eax, word [rax + E_YEAR]
    sub     rax, r12
    mov     edx, 1
    jmp     .out
.no:
    xor     eax, eax
    xor     edx, edx
.out:
    pop     r12
    pop     rbx
    ret

; char_interval(rdi=category) -> rax: the years one minimal step through
; the category carries the reader, from the series' first member.
char_interval:
    call    stride
    lea     rsi, [rax + 1]
    mov     edi, 1
    jmp     displacement

; exchanges(rdi=category, rsi=n1, rdx=out) -> rax = count.
; Hold every category but one and exchange the member of that one
; (Hjelmslev, def. 54-56); targets in ascending ordinal order. Cells are
; compared by index, which is comparison by word because every paradigm
; holds distinct words (the inventory check).
exchanges:
    push    rbx
    push    rbp
    push    r12
    push    r13
    push    r14
    push    r15
    mov     r12, rdi                ; the category exchanged
    mov     r14, rdx                ; out
    xor     r15d, r15d              ; count
    mov     rdi, rsi
    call    selection
    cmp     rax, -1
    je      .done
    mov     r13, rax                ; c1
    xor     ebx, ebx
.l: cmp     rbx, [enum_n]
    jae     .done
    lea     rax, [enum_cell]
    mov     rbp, [rax + rbx*8]      ; c2
    xor     ecx, ecx
.k: cmp     ecx, NCAT
    jae     .hit
    mov     rax, r13
    mov     rdx, rbp
    mov     r8d, ecx
    shl     ecx, 3
    shr     rax, cl
    shr     rdx, cl
    mov     ecx, r8d
    and     eax, 0xff
    and     edx, 0xff
    cmp     rcx, r12
    je      .exchanged
    cmp     eax, edx                ; held: must agree
    jne     .skip
    jmp     .k_next
.exchanged:
    cmp     eax, edx                ; exchanged: must differ
    je      .skip
.k_next:
    inc     ecx
    jmp     .k
.hit:
    lea     rax, [enum_ord]
    mov     rax, [rax + rbx*8]
    mov     [r14 + r15*8], rax
    inc     r15
.skip:
    inc     rbx
    jmp     .l
.done:
    mov     rax, r15
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbp
    pop     rbx
    ret

; commutation(rdi=category, rsi=n1, rdx=out): one member of one paradigm
; exchanged with the chain held.
commutation:
    cmp     rdi, CAT_ORDER
    je      .none
    jmp     exchanges
.none:
    xor     eax, eax
    ret

; permutation(rdi=n1, rsi=out): the chain shifted with the paradigms held.
permutation:
    mov     rdx, rsi
    mov     rsi, rdi
    mov     edi, CAT_ORDER
    jmp     exchanges

; ============================================================
; VIII. MARKED CELLS: REGISTER, DEIXIS, BODY
; ============================================================

; register(rdi=word) -> rax = register, or -1
register:
    push    rbx
    push    r12
    mov     r12, rdi
    lea     rbx, [lex_tab]
.l: lea     rax, [lex_end]
    cmp     rbx, rax
    jae     .no
    mov     rdi, r12
    mov     rsi, [rbx]
    call    streq
    test    rax, rax
    jnz     .yes
    add     rbx, LEX_SIZE
    jmp     .l
.yes:
    movzx   eax, byte [rbx + 8]
    jmp     .out
.no:
    mov     rax, -1
.out:
    pop     r12
    pop     rbx
    ret

; functive(rdi=category, rsi=word) -> rax = 1 if the word is in it
functive:
    push    rbx
    push    r12
    push    r13
    mov     r12, rdi
    mov     r13, rsi
    xor     ebx, ebx
.l: mov     rdi, r12
    call    card
    cmp     rbx, rax
    jae     .no
    mov     rdi, r12
    mov     rsi, rbx
    call    invariant
    mov     rdi, rax
    mov     rsi, r13
    call    streq
    test    rax, rax
    jnz     .out
    inc     rbx
    jmp     .l
.no:
    xor     eax, eax
.out:
    pop     r13
    pop     r12
    pop     rbx
    ret

; cell_is(rdi=ordinal, rsi=category, rdx=word) -> rax = 1 if that cell
; selects that word.
cell_is:
    push    rbx
    push    r12
    mov     rbx, rsi
    mov     r12, rdx
    call    selection
    cmp     rax, -1
    je      .no
    mov     rdi, rax
    mov     rsi, rbx
    call    cell_word
    mov     rdi, rax
    mov     rsi, r12
    call    streq
    jmp     .out
.no:
    xor     eax, eax
.out:
    pop     r12
    pop     rbx
    ret

; Predicates over an ordinal (rdi) -> rax = 0 or 1.

; 18 require a present body; 54 can be read from anywhere.
p_deictic:
    mov     esi, CAT_ADVERB
    lea     rdx, [w_now]
    jmp     cell_is

p_autonomous:
    push    rbx
    mov     rbx, rdi
    call    selection
    cmp     rax, -1
    je      .no
    mov     rdi, rbx
    call    p_deictic
    xor     eax, 1
    pop     rbx
    ret
.no:
    xor     eax, eax
    pop     rbx
    ret

; 24 import tactile density (Old English thiccian).
p_tactile:
    mov     esi, CAT_VERB
    lea     rdx, [w_thicken]
    jmp     cell_is

; 36 where the body breaks through measurement (24 + 18 - 6).
p_bodily:
    push    rbx
    mov     rbx, rdi
    call    p_tactile
    test    rax, rax
    jnz     .out
    mov     rdi, rbx
    call    p_deictic
.out:
    pop     rbx
    ret

; 6 where the two Germanic cells align.
p_germanic:
    push    rbx
    mov     rbx, rdi
    call    p_tactile
    test    rax, rax
    jz      .out
    mov     rdi, rbx
    call    p_deictic
.out:
    pop     rbx
    ret

; 'now' in the prefix order, and in the suffix order.
p_now_prefix:
    push    rbx
    mov     rbx, rdi
    call    p_deictic
    test    rax, rax
    jz      .out
    mov     rdi, rbx
    mov     esi, CAT_ORDER
    lea     rdx, [w_prefix]
    call    cell_is
.out:
    pop     rbx
    ret

p_now_suffix:
    push    rbx
    mov     rbx, rdi
    call    p_deictic
    test    rax, rax
    jz      .out
    mov     rdi, rbx
    mov     esi, CAT_ORDER
    lea     rdx, [w_suffix]
    call    cell_is
.out:
    pop     rbx
    ret

; The line's adverb never touches the fundamental.
p_unanchored:
    call    selection
    cmp     rax, -1
    je      .no
    mov     rdi, rax
    mov     esi, CAT_ADVERB
    call    cell_word
    mov     rdi, rax
    call    touches
    xor     eax, 1
    ret
.no:
    xor     eax, eax
    ret

; count_of(rdi=predicate) -> rax = how many ordinals satisfy it
count_of:
    push    rbx
    push    r12
    push    r13
    mov     r12, rdi
    xor     ebx, ebx
    xor     r13d, r13d
.l: cmp     rbx, [enum_n]
    jae     .e
    lea     rax, [enum_ord]
    mov     rdi, [rax + rbx*8]
    call    r12
    add     r13, rax
    inc     rbx
    jmp     .l
.e: mov     rax, r13
    pop     r13
    pop     r12
    pop     rbx
    ret

; ============================================================
; IX. EXPRESSION-SUBSTANCE: THE OVERTONE FIELD ABOVE A2
; ============================================================

; Each letter selects a partial of the drone by alphabet position modulo
; twelve; letters are weighted by recurrence within the word; the line is
; parsed noun, verb, adverb whatever its syntactic order.

; spectrum(rdi=word) -> rax = specbuf, the weight of each partial 0..11
spectrum:
    lea     rax, [specbuf]
    mov     qword [rax], 0
    mov     qword [rax + 8], 0
    mov     r8, rax
.l: movzx   ecx, byte [rdi]
    test    ecx, ecx
    jz      .e
    inc     rdi
    cmp     ecx, 'a'
    jb      .l
    cmp     ecx, 'z'
    ja      .l
    lea     eax, [ecx - 96]         ; alphabet position
    xor     edx, edx
    mov     r9d, 12
    div     r9d                     ; edx = position mod 12
    inc     byte [r8 + rdx]
    jmp     .l
.e: mov     rax, r8
    ret

; partial_weight(rdi=word, rsi=partial) -> rax
partial_weight:
    push    rsi
    call    spectrum
    pop     rsi
    movzx   eax, byte [rax + rsi]
    ret

; touches(rdi=word) -> rax = 1 if the word sounds the fundamental
touches:
    mov     esi, 1
    call    partial_weight
    test    eax, eax
    setnz   al
    movzx   eax, al
    ret

; spectrum_size(rdi=word) -> rax = how many partials it sounds
spectrum_size:
    call    spectrum
    xor     ecx, ecx
    xor     edx, edx
.l: cmp     byte [rax + rcx], 0
    je      .n
    inc     edx
.n: inc     ecx
    cmp     ecx, 12
    jb      .l
    mov     eax, edx
    ret

; grounding(rdi=ordinal) -> rax = letters of the line that sound the
; fundamental, or -1 outside the grid.
grounding:
    push    rbx
    push    r12
    push    r13
    call    selection
    cmp     rax, -1
    je      .out
    mov     rbx, rax
    xor     r12d, r12d              ; category
    xor     r13d, r13d              ; sum
.l: mov     rdi, rbx
    mov     rsi, r12
    call    cell_word
    mov     rdi, rax
    mov     esi, 1
    call    partial_weight
    add     r13, rax
    inc     r12
    cmp     r12, NLEX
    jb      .l
    mov     rax, r13
.out:
    pop     r13
    pop     r12
    pop     rbx
    ret

; emit_spectrum(rdi=word): "1 4 5x2 ..."; partial 0 is a silence
emit_spectrum:
    push    rbx
    push    r12
    push    r13
    call    spectrum
    xor     ebx, ebx                ; partial
    xor     r12d, r12d              ; something printed yet
.l: cmp     ebx, 12
    jae     .e
    lea     rax, [specbuf]
    movzx   r13d, byte [rax + rbx]
    test    r13d, r13d
    jz      .n
    test    r12d, r12d
    jz      .first
    mov     dil, ' '
    call    emit_char
.first:
    mov     r12d, 1
    test    ebx, ebx
    jnz     .num
    lea     rdi, [s_silence]
    call    emit_str
    jmp     .weight
.num:
    mov     rdi, rbx
    call    emit_num
.weight:
    cmp     r13d, 1
    jbe     .n
    mov     dil, 'x'
    call    emit_char
    mov     rdi, r13
    call    emit_num
.n: inc     ebx
    jmp     .l
.e: pop     r13
    pop     r12
    pop     rbx
    ret

; ============================================================
; X. FORMATTING
; ============================================================

; before_reform(edi=year, esi=month, edx=day) -> rax
before_reform:
    cmp     edi, 1582
    jl      .yes
    jg      .no
    cmp     esi, 10
    jl      .yes
    jg      .no
    cmp     edx, 15
    jl      .yes
.no:
    xor     eax, eax
    ret
.yes:
    mov     eax, 1
    ret

; emit_date(rdi=record): "48. 12 Aug 2026    "
emit_date:
    push    rbx
    mov     rbx, rdi
    movzx   edi, byte [rbx + E_ORD]
    mov     esi, 2
    call    emit_numl
    lea     rdi, [s_dotsp]
    call    emit_str
    movzx   edi, byte [rbx + E_DAY]
    mov     esi, 2
    call    emit_numl
    mov     dil, ' '
    call    emit_char
    movzx   eax, byte [rbx + E_MON]
    lea     rcx, [month_tab]
    mov     rdi, [rcx + rax*8 - 8]
    call    emit_str
    mov     dil, ' '
    call    emit_char
    movzx   edi, word [rbx + E_YEAR]
    call    emit_num
    movzx   edi, word [rbx + E_YEAR]
    movzx   esi, byte [rbx + E_MON]
    movzx   edx, byte [rbx + E_DAY]
    call    before_reform
    lea     rdi, [s_julian]
    test    eax, eax
    jnz     .mark
    lea     rdi, [s_2sp]
.mark:
    call    emit_str
    lea     rdi, [s_2sp]
    call    emit_str
    pop     rbx
    ret

; emit_type(rdi=record): the eclipse type, padded to 9
emit_type:
    movzx   eax, byte [rdi + E_TYPE]
    lea     rcx, [type_names]
    mov     rdi, [rcx + rax*8]
    mov     esi, 9
    jmp     emit_padr

; emit_gamma(rdi=record): gamma to four decimals, from ten-thousandths
emit_gamma:
    push    rbx
    movsxd  rbx, dword [rdi + E_GAMMA]
    test    rbx, rbx
    jns     .pos
    mov     dil, '-'
    call    emit_char
    neg     rbx
.pos:
    mov     rax, rbx
    xor     edx, edx
    mov     ecx, 10000
    div     rcx
    mov     rbx, rdx                ; fraction
    mov     rdi, rax
    call    emit_num
    mov     dil, '.'
    call    emit_char
    cmp     rbx, 1000
    jae     .frac
    mov     dil, '0'
    call    emit_char
    cmp     rbx, 100
    jae     .frac
    mov     dil, '0'
    call    emit_char
    cmp     rbx, 10
    jae     .frac
    mov     dil, '0'
    call    emit_char
.frac:
    mov     rdi, rbx
    call    emit_num
    pop     rbx
    ret

; ============================================================
; XI (b). EDITIONS
; ============================================================

emit_epigraph:
    lea     rdi, [epi_1]
    call    emit_line
    lea     rdi, [epi_2]
    call    emit_line
    lea     rdi, [s_dash2]
    jmp     emit_line

ed_manifestations:
    push    rbx
    push    r12
    call    emit_epigraph
    xor     ebx, ebx
.l: cmp     rbx, [enum_n]
    jae     .e
    lea     rax, [enum_ord]
    mov     r12, [rax + rbx*8]
    mov     rdi, r12
    lea     rsi, [mbuf]
    call    manifestation
    test    rax, rax
    jz      .n
    mov     rdi, r12
    call    emit_num
    lea     rdi, [s_dotsp]
    call    emit_str
    lea     rdi, [mbuf]
    call    emit_line
.n: inc     rbx
    jmp     .l
.e: pop     r12
    pop     rbx
    ret

ed_saros:
    push    rbx
    call    emit_epigraph
    lea     rbx, [saros_tab]
.l: lea     rax, [saros_end]
    cmp     rbx, rax
    jae     .e
    movzx   edi, byte [rbx + E_ORD]
    lea     rsi, [mbuf]
    call    manifestation
    test    rax, rax
    jz      .n
    mov     rdi, rbx
    call    emit_date
    mov     rdi, rbx
    call    emit_type
    lea     rdi, [mbuf]
    call    emit_line
.n: add     rbx, ECL_SIZE
    jmp     .l
.e: pop     rbx
    ret

%macro EMITW 1                      ; emit the cell's word of a category
    mov     rdi, r12
    mov     esi, %1
    call    cell_word
    mov     rdi, rax
    call    emit_str
%endmacro
%macro EMITS 1
    lea     rdi, [%1]
    call    emit_str
%endmacro

ed_glossematic:
    push    rbx
    push    r12
    call    emit_epigraph
    EMITS   s_gloss_head
    call    emit_nl
    EMITS   s_dash2
    call    emit_nl
    lea     rbx, [saros_tab]
.l: lea     rax, [saros_end]
    cmp     rbx, rax
    jae     .e
    movzx   edi, byte [rbx + E_ORD]
    lea     rsi, [mbuf]
    call    manifestation
    test    rax, rax
    jz      .n
    movzx   edi, byte [rbx + E_ORD]
    call    selection
    mov     r12, rax
    mov     rdi, rbx
    call    emit_date
    mov     dil, '['
    call    emit_char
    EMITW   CAT_ORDER
    EMITS   s_colon
    EMITW   CAT_NOUN
    EMITS   s_slash
    EMITW   CAT_VERB
    EMITS   s_slash
    EMITW   CAT_ADVERB
    EMITS   s_rb
    mov     rdi, rbx
    call    emit_type
    EMITS   s_gamma
    mov     rdi, rbx
    call    emit_gamma
    EMITS   s_arrow
    lea     rdi, [mbuf]
    call    emit_line
.n: add     rbx, ECL_SIZE
    jmp     .l
.e: pop     r12
    pop     rbx
    ret

; emit_move(rdi=kind text, rsi=category name, rdx=target ordinal):
; one line of the mutation edition.
emit_move:
    push    rbx
    push    r12
    push    r13
    push    r14
    mov     r12, rdi
    mov     r13, rsi
    mov     r14, rdx
    mov     rdi, r14
    lea     rsi, [mbuf]
    call    manifestation
    test    rax, rax
    jz      .out
    mov     rdi, r14
    call    saros
    test    rax, rax
    jz      .out
    mov     rbx, rax
    mov     rdi, r12
    call    emit_str
    mov     rdi, r13
    mov     esi, 7
    call    emit_padr
    EMITS   s_to
    mov     rdi, rbx
    call    emit_date
    mov     rdi, rbx
    call    emit_type
    EMITS   s_gamma
    mov     rdi, rbx
    call    emit_gamma
    EMITS   s_2sp
    mov     edi, ANCHOR
    mov     rsi, r14
    call    displacement
    mov     r12, rax
    test    r12, r12
    js      .signed
    mov     dil, '+'
    call    emit_char
.signed:
    mov     rdi, r12
    call    emit_num
    EMITS   s_yrs
    lea     rdi, [mbuf]
    call    emit_line
.out:
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret

ed_mutation:
    push    rbx
    push    r12
    push    r13
    call    emit_epigraph
    EMITS   s_mut_head
    call    emit_nl
    EMITS   s_dash2
    call    emit_nl
    ; The characteristic interval of each category.
    xor     ebx, ebx
.ci:
    cmp     rbx, NCAT
    jae     .ci_done
    lea     rax, [cat_names]
    mov     rdi, [rax + rbx*8]
    mov     esi, 8
    call    emit_padr
    EMITS   s_stride
    mov     rdi, rbx
    call    stride
    mov     rdi, rax
    mov     esi, 2
    call    emit_numl
    EMITS   s_interval
    mov     rdi, rbx
    call    char_interval
    mov     rdi, rax
    mov     esi, 3
    call    emit_numl
    EMITS   s_years
    call    emit_nl
    inc     rbx
    jmp     .ci
.ci_done:
    EMITS   s_dash2
    call    emit_nl
    ; From the anchor ...
    EMITS   s_from
    mov     edi, ANCHOR
    call    emit_num
    EMITS   s_dotsp
    mov     edi, ANCHOR
    call    emit_manifestation
    call    emit_nl
    ; ... every commutation, noun, verb, adverb ...
    xor     r12d, r12d
.cat:
    cmp     r12, NLEX
    jae     .perm
    mov     rdi, r12
    mov     esi, ANCHOR
    lea     rdx, [xbuf]
    call    commutation
    mov     r13, rax
    xor     ebx, ebx
.move:
    cmp     rbx, r13
    jae     .cat_next
    lea     rdi, [s_commut]
    lea     rax, [cat_names]
    mov     rsi, [rax + r12*8]
    lea     rax, [xbuf]
    mov     rdx, [rax + rbx*8]
    call    emit_move
    inc     rbx
    jmp     .move
.cat_next:
    inc     r12
    jmp     .cat
    ; ... then the permutation.
.perm:
    mov     edi, ANCHOR
    lea     rsi, [xbuf]
    call    permutation
    mov     r13, rax
    xor     ebx, ebx
.pmove:
    cmp     rbx, r13
    jae     .e
    lea     rdi, [s_permut]
    lea     rsi, [cn_order]
    lea     rax, [xbuf]
    mov     rdx, [rax + rbx*8]
    call    emit_move
    inc     rbx
    jmp     .pmove
.e: pop     r13
    pop     r12
    pop     rbx
    ret

ed_sounding:
    push    rbx
    push    r12
    push    r13
    push    r14
    call    emit_epigraph
    EMITS   s_drone_a
    mov     edi, DRONE_HZ
    call    emit_num
    EMITS   s_drone_b
    call    emit_nl
    EMITS   s_dash2
    call    emit_nl
    ; Each word's spectrum.
    xor     r12d, r12d              ; category
.wc:
    cmp     r12, NLEX
    jae     .lines
    xor     r13d, r13d              ; index
.wi:
    mov     rdi, r12
    call    card
    cmp     r13, rax
    jae     .wc_next
    mov     rdi, r12
    mov     rsi, r13
    call    invariant
    mov     rbx, rax
    mov     rdi, rbx
    mov     esi, 13
    call    emit_padr
    mov     rdi, rbx
    call    emit_spectrum
    mov     rdi, rbx
    call    touches
    test    eax, eax
    jnz     .wnl
    EMITS   s_nofund
.wnl:
    call    emit_nl
    inc     r13
    jmp     .wi
.wc_next:
    inc     r12
    jmp     .wc
    ; Each line's grounding and spectra.
.lines:
    EMITS   s_dash2
    call    emit_nl
    xor     ebx, ebx
.ln:
    cmp     rbx, [enum_n]
    jae     .e
    lea     rax, [enum_ord]
    mov     r14, [rax + rbx*8]
    mov     rdi, r14
    mov     esi, 2
    call    emit_numl
    EMITS   s_dotsp
    mov     rdi, r14
    call    grounding
    mov     rdi, rax
    mov     esi, 2
    call    emit_numl
    EMITS   s_2sp
    lea     rax, [enum_cell]
    mov     r13, [rax + rbx*8]
    xor     r12d, r12d
.part:
    test    r12, r12
    jz      .nobar
    EMITS   s_bar
.nobar:
    mov     rdi, r13
    mov     rsi, r12
    call    cell_word
    mov     r14, rax
    mov     rdi, r14
    call    emit_str
    mov     dil, ' '
    call    emit_char
    mov     rdi, r14
    call    emit_spectrum
    inc     r12
    cmp     r12, NLEX
    jb      .part
    call    emit_nl
    inc     rbx
    jmp     .ln
.e: pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret

; ============================================================
; XII. EDITION CHECKS
; ============================================================

; The generator derives everything from the inventory; these checks hold
; the derived edition to the numbers this artwork asserts of itself.
; Each returns rax = 1 when it holds.

; Every paradigm holds distinct words; every lexicon entry is a word of
; the grid; every word of the grid has its lexicon entry.
chk_inventory:
    push    rbx
    push    r12
    push    r13
    push    r14
    xor     r12d, r12d              ; category
.c: cmp     r12, NCAT
    jae     .meta
    xor     r13d, r13d              ; i
.i: mov     rdi, r12
    call    card
    cmp     r13, rax
    jae     .c_next
    lea     r14, [r13 + 1]          ; j
.j: mov     rdi, r12
    call    card
    cmp     r14, rax
    jae     .i_next
    mov     rdi, r12
    mov     rsi, r13
    call    invariant
    mov     rbx, rax
    mov     rdi, r12
    mov     rsi, r14
    call    invariant
    mov     rdi, rbx
    mov     rsi, rax
    call    streq
    test    eax, eax
    jnz     .fail
    inc     r14
    jmp     .j
.i_next:
    inc     r13
    jmp     .i
.c_next:
    inc     r12
    jmp     .c
.meta:
    lea     rbx, [lex_tab]
.m: lea     rax, [lex_end]
    cmp     rbx, rax
    jae     .words
    xor     r12d, r12d
.mc:
    cmp     r12, NLEX
    jae     .fail                   ; in no paradigm
    mov     rdi, r12
    mov     rsi, [rbx]
    call    functive
    test    eax, eax
    jnz     .m_next
    inc     r12
    jmp     .mc
.m_next:
    add     rbx, LEX_SIZE
    jmp     .m
.words:
    xor     r12d, r12d
.wc:
    cmp     r12, NLEX
    jae     .ok
    xor     r13d, r13d
.wi:
    mov     rdi, r12
    call    card
    cmp     r13, rax
    jae     .wc_next
    mov     rdi, r12
    mov     rsi, r13
    call    invariant
    mov     rdi, rax
    call    register
    cmp     rax, -1
    je      .fail
    inc     r13
    jmp     .wi
.wc_next:
    inc     r12
    jmp     .wc
.ok:
    mov     eax, 1
    jmp     .out
.fail:
    xor     eax, eax
.out:
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret

; The inventory is exactly the schema of the edition, word by word.
chk_edition:
    push    rbx
    push    r12
    push    r13
    xor     r12d, r12d
.c: cmp     r12, NCAT
    jae     .ok
    mov     rdi, r12
    call    card
    lea     rcx, [exp_tab]
    mov     rdx, r12
    shl     rdx, 4
    cmp     rax, [rcx + rdx + 8]
    jne     .fail
    xor     r13d, r13d
.i: mov     rdi, r12
    call    card
    cmp     r13, rax
    jae     .c_next
    mov     rdi, r12
    mov     rsi, r13
    call    invariant
    mov     rbx, rax
    lea     rcx, [exp_tab]
    mov     rdx, r12
    shl     rdx, 4
    mov     rcx, [rcx + rdx]
    mov     rsi, [rcx + r13*8]
    mov     rdi, rbx
    call    streq
    test    eax, eax
    jz      .fail
    inc     r13
    jmp     .i
.c_next:
    inc     r12
    jmp     .c
.ok:
    mov     eax, 1
    jmp     .out
.fail:
    xor     eax, eax
.out:
    pop     r13
    pop     r12
    pop     rbx
    ret

chk_cardinality:
    call    system_card
    cmp     rax, 72
    sete    al
    movzx   eax, al
    ret

; 72 poems, all different.
chk_unique:
    push    rbx
    push    r12
    push    r13
    cmp     qword [enum_n], 72
    jne     .fail
    xor     ebx, ebx
.r: cmp     rbx, [enum_n]
    jae     .cmp
    lea     rax, [enum_cell]
    mov     rdi, [rax + rbx*8]
    mov     rsi, rbx
    imul    rsi, POEM_W
    lea     rax, [poems]
    add     rsi, rax
    call    render_cell
    test    rax, rax
    jz      .fail
    inc     rbx
    jmp     .r
.cmp:
    xor     ebx, ebx
.i: cmp     rbx, [enum_n]
    jae     .ok
    lea     r12, [rbx + 1]
.j: cmp     r12, [enum_n]
    jae     .i_next
    mov     rdi, rbx
    imul    rdi, POEM_W
    lea     rax, [poems]
    add     rdi, rax
    mov     rsi, r12
    imul    rsi, POEM_W
    add     rsi, rax
    call    streq
    test    eax, eax
    jnz     .fail
    inc     r12
    jmp     .j
.i_next:
    inc     rbx
    jmp     .i
.ok:
    mov     eax, 1
    jmp     .out
.fail:
    xor     eax, eax
.out:
    pop     r13
    pop     r12
    pop     rbx
    ret

; sort_q(rdi=array, rsi=count): insertion sort, ascending
sort_q:
    mov     rcx, 1
.o: cmp     rcx, rsi
    jae     .e
    mov     rax, [rdi + rcx*8]
    mov     rdx, rcx
.i: test    rdx, rdx
    jz      .put
    mov     r8, [rdi + rdx*8 - 8]
    cmp     r8, rax
    jle     .put
    mov     [rdi + rdx*8], r8
    dec     rdx
    jmp     .i
.put:
    mov     [rdi + rdx*8], rax
    inc     rcx
    jmp     .o
.e: ret

; The sorted ordinals of the Saros table are the ordinals of the grid.
chk_coverage:
    push    rbx
    push    r12
    lea     rbx, [saros_tab]
    xor     r12d, r12d
.l: lea     rax, [saros_end]
    cmp     rbx, rax
    jae     .sort
    cmp     r12, MAXCELLS
    jae     .fail
    movzx   eax, byte [rbx + E_ORD]
    lea     rcx, [sbuf]
    mov     [rcx + r12*8], rax
    inc     r12
    add     rbx, ECL_SIZE
    jmp     .l
.sort:
    cmp     r12, [enum_n]
    jne     .fail
    lea     rdi, [sbuf]
    mov     rsi, r12
    call    sort_q
    xor     ebx, ebx
.c: cmp     rbx, r12
    jae     .ok
    lea     rax, [sbuf]
    mov     rcx, [rax + rbx*8]
    lea     rax, [enum_ord]
    cmp     rcx, [rax + rbx*8]
    jne     .fail
    inc     rbx
    jmp     .c
.ok:
    mov     eax, 1
    jmp     .out
.fail:
    xor     eax, eax
.out:
    pop     r12
    pop     rbx
    ret

; Selection enumerates ordinals in ascending order and decodes each
; ordinal to the same cell it was encoded from; nothing outside 1..72
; decodes.
chk_selection:
    push    rbx
    push    r12
    xor     ebx, ebx
.l: cmp     rbx, [enum_n]
    jae     .bounds
    lea     rax, [enum_ord]
    mov     r12, [rax + rbx*8]
    test    rbx, rbx
    jz      .first
    cmp     r12, [rax + rbx*8 - 8]
    jle     .fail                   ; not ascending
.first:
    mov     rdi, r12
    call    selection
    lea     rcx, [enum_cell]
    cmp     rax, [rcx + rbx*8]
    jne     .fail
    mov     rdi, rax
    call    encode
    cmp     rax, r12
    jne     .fail
    inc     rbx
    jmp     .l
.bounds:
    xor     edi, edi
    call    selection
    cmp     rax, -1
    jne     .fail
    mov     edi, 73
    call    selection
    cmp     rax, -1
    jne     .fail
    mov     eax, 1
    jmp     .out
.fail:
    xor     eax, eax
.out:
    pop     r12
    pop     rbx
    ret

%macro COUNT_IS 2
    lea     rdi, [%1]
    call    count_of
    cmp     rax, %2
    jne     .fail
%endmacro

chk_marked:
    COUNT_IS p_deictic, 18
    COUNT_IS p_autonomous, 54
    COUNT_IS p_now_prefix, 9
    COUNT_IS p_now_suffix, 9
    COUNT_IS p_tactile, 24
    COUNT_IS p_germanic, 6
    COUNT_IS p_bodily, 36
    mov     eax, 1
    ret
.fail:
    xor     eax, eax
    ret

chk_anchor:
    mov     edi, ANCHOR
    call    saros
    test    rax, rax
    jz      .fail
    cmp     word [rax + E_YEAR], 2026
    jne     .fail
    cmp     byte [rax + E_MON], 8
    jne     .fail
    cmp     byte [rax + E_DAY], 12
    jne     .fail
    cmp     byte [rax + E_TYPE], T_TOTAL
    jne     .fail
    cmp     dword [rax + E_GAMMA], 8977
    jne     .fail
    mov     edi, ANCHOR
    lea     rsi, [mbuf]
    call    manifestation
    test    rax, rax
    jz      .fail
    lea     rdi, [mbuf]
    lea     rsi, [x_anchor]
    call    streq
    test    eax, eax
    jz      .fail
    lea     rdi, [x_anchor]
    lea     rsi, [xbuf]
    call    poems_of
    cmp     rax, 1
    jne     .fail
    cmp     qword [xbuf], ANCHOR
    jne     .fail
    mov     eax, 1
    ret
.fail:
    xor     eax, eax
    ret

%macro POEM_IS 2
    mov     edi, %1
    lea     rsi, [mbuf]
    call    manifestation
    test    rax, rax
    jz      .fail
    lea     rdi, [mbuf]
    lea     rsi, [%2]
    call    streq
    test    eax, eax
    jz      .fail
%endmacro

chk_boundaries:
    POEM_IS 1,  x_poem1
    POEM_IS 36, x_poem36
    POEM_IS 37, x_poem37
    POEM_IS 72, x_poem72
    mov     eax, 1
    ret
.fail:
    xor     eax, eax
    ret

%macro STRIDE_IS 3                  ; category, stride, interval
    mov     edi, %1
    call    stride
    cmp     rax, %2
    jne     .fail
    mov     edi, %1
    call    char_interval
    test    edx, edx
    jz      .fail
    cmp     rax, %3
    jne     .fail
%endmacro

; list_is(rdi=list, rsi=count, rdx=expected, rcx=expected count) -> rax
list_is:
    cmp     rsi, rcx
    jne     .no
    xor     r8d, r8d
.l: cmp     r8, rsi
    jae     .yes
    mov     rax, [rdi + r8*8]
    cmp     rax, [rdx + r8*8]
    jne     .no
    inc     r8
    jmp     .l
.yes:
    mov     eax, 1
    ret
.no:
    xor     eax, eax
    ret

section .rodata
exp_noun_48:    dq 60, 72
exp_years_48:   dq 2242, 2459
exp_verb_48:    dq 40, 44
exp_adverb_48:  dq 45, 46, 47
section .text

; contains(rdi=list, rsi=count, rdx=value) -> rax
contains:
    xor     ecx, ecx
.l: cmp     rcx, rsi
    jae     .no
    cmp     [rdi + rcx*8], rdx
    je      .yes
    inc     rcx
    jmp     .l
.yes:
    mov     eax, 1
    ret
.no:
    xor     eax, eax
    ret

; The essay's intervals and its anchor commutation, derived not asserted.
chk_mutation:
    push    rbx
    push    rbp
    push    r12
    push    r13
    push    r14
    push    r15
    STRIDE_IS CAT_ADVERB, 1, 18
    STRIDE_IS CAT_VERB, 4, 72
    STRIDE_IS CAT_NOUN, 12, 216
    STRIDE_IS CAT_ORDER, 36, 649
    ; The anchor's noun is apertures, and commuting it reaches 2242, 2459.
    mov     edi, ANCHOR
    call    selection
    mov     rdi, rax
    mov     esi, CAT_NOUN
    call    cell_word
    mov     rdi, rax
    lea     rsi, [x_apertures]
    call    streq
    test    eax, eax
    jz      .fail
    mov     edi, CAT_NOUN
    mov     esi, ANCHOR
    lea     rdx, [xbuf]
    call    commutation
    mov     r12, rax
    lea     rdi, [xbuf]
    mov     rsi, r12
    lea     rdx, [exp_noun_48]
    mov     ecx, 2
    call    list_is
    test    eax, eax
    jz      .fail
    xor     ebx, ebx
.yr:
    cmp     rbx, r12
    jae     .verbs
    lea     rax, [xbuf]
    mov     rdi, [rax + rbx*8]
    call    saros
    test    rax, rax
    jz      .fail
    movzx   eax, word [rax + E_YEAR]
    lea     rcx, [exp_years_48]
    cmp     rax, [rcx + rbx*8]
    jne     .fail
    inc     rbx
    jmp     .yr
.verbs:
    mov     edi, CAT_VERB
    mov     esi, ANCHOR
    lea     rdx, [xbuf]
    call    commutation
    lea     rdi, [xbuf]
    mov     rsi, rax
    lea     rdx, [exp_verb_48]
    mov     ecx, 2
    call    list_is
    test    eax, eax
    jz      .fail
    mov     edi, CAT_ADVERB
    mov     esi, ANCHOR
    lea     rdx, [xbuf]
    call    commutation
    lea     rdi, [xbuf]
    mov     rsi, rax
    lea     rdx, [exp_adverb_48]
    mov     ecx, 3
    call    list_is
    test    eax, eax
    jz      .fail
    ; permutation(48, 12, prefix, suffix), 649 years back.
    mov     edi, ANCHOR
    lea     rsi, [xbuf]
    call    permutation
    lea     rdi, [xbuf]
    mov     rsi, rax
    mov     edx, 12
    call    contains
    test    eax, eax
    jz      .fail
    mov     edi, ANCHOR
    mov     esi, CAT_ORDER
    lea     rdx, [x_prefix]
    call    cell_is
    test    eax, eax
    jz      .fail
    mov     edi, 12
    mov     esi, CAT_ORDER
    lea     rdx, [x_suffix]
    call    cell_is
    test    eax, eax
    jz      .fail
    mov     edi, ANCHOR
    mov     esi, 12
    call    displacement
    cmp     rax, -649
    jne     .fail
    ; Every mutation registers on the content plane, and each
    ; commutation is its own inverse.
    xor     ebx, ebx                ; i over the cells
.n1:
    cmp     rbx, [enum_n]
    jae     .ok
    lea     rax, [enum_ord]
    mov     r12, [rax + rbx*8]      ; n1
    xor     ebp, ebp                ; category 0..3 (3 = permutation)
.kind:
    cmp     rbp, NCAT
    jae     .n1_next
    mov     rdi, rbp
    mov     rsi, r12
    lea     rdx, [xbuf]
    cmp     rbp, CAT_ORDER
    je      .perm
    call    commutation
    jmp     .got
.perm:
    mov     rdi, r12
    lea     rsi, [xbuf]
    call    permutation
.got:
    mov     r13, rax                ; count
    xor     r14d, r14d
.each:
    cmp     r14, r13
    jae     .kind_next
    lea     rax, [xbuf]
    mov     r15, [rax + r14*8]      ; n2
    cmp     r15, r12
    je      .inverse
    mov     rdi, r12
    mov     rsi, r15
    call    displacement
    test    edx, edx
    jz      .fail
    test    rax, rax
    jz      .fail
.inverse:
    cmp     rbp, CAT_ORDER
    je      .each_next
    mov     rdi, rbp
    mov     rsi, r15
    lea     rdx, [xbuf2]
    call    commutation
    lea     rdi, [xbuf2]
    mov     rsi, rax
    mov     rdx, r12
    call    contains
    test    eax, eax
    jz      .fail
.each_next:
    inc     r14
    jmp     .each
.kind_next:
    inc     rbp
    jmp     .kind
.n1_next:
    inc     rbx
    jmp     .n1
.ok:
    mov     eax, 1
    jmp     .out
.fail:
    xor     eax, eax
.out:
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbp
    pop     rbx
    ret

%macro WEIGHT_IS 3
    lea     rdi, [%1]
    mov     esi, %2
    call    partial_weight
    cmp     rax, %3
    jne     .fail
%endmacro

; The sounding claims that survive the literal rule, plus the two findings.
chk_sounding:
    push    rbx
    push    r12
    push    r13
    ; spectrum(now) is exactly 2, 3, 11, once each.
    lea     rdi, [x_now]
    call    spectrum
    xor     ecx, ecx
.sn:
    movzx   edx, byte [rax + rcx]
    mov     r8d, 0
    cmp     ecx, 2
    je      .one
    cmp     ecx, 3
    je      .one
    cmp     ecx, 11
    jne     .cmp
.one:
    mov     r8d, 1
.cmp:
    cmp     edx, r8d
    jne     .fail
    inc     ecx
    cmp     ecx, 12
    jb      .sn
    ; The words without the fundamental are exactly the Germanic words.
    xor     r12d, r12d
.wc:
    cmp     r12, NLEX
    jae     .weights
    xor     r13d, r13d
.wi:
    mov     rdi, r12
    call    card
    cmp     r13, rax
    jae     .wc_next
    mov     rdi, r12
    mov     rsi, r13
    call    invariant
    mov     rbx, rax
    mov     rdi, rbx
    call    touches
    xor     eax, 1                  ; fundamental-free
    mov     r8, rax
    push    r8
    mov     rdi, rbx
    call    register
    pop     r8
    cmp     rax, REG_GERMANIC
    sete    al
    movzx   eax, al
    cmp     rax, r8
    jne     .fail
    ; Every noun opens on the fundamental.
    cmp     r12, CAT_NOUN
    jne     .wi_next
    test    r8, r8
    jnz     .fail
.wi_next:
    inc     r13
    jmp     .wi
.wc_next:
    inc     r12
    jmp     .wc
.weights:
    WEIGHT_IS x_thicken, 8, 2
    WEIGHT_IS x_emerge, 5, 3
    WEIGHT_IS x_rhythmically, 1, 4
    WEIGHT_IS x_vertically, 1, 2
    WEIGHT_IS x_recursively, 1, 1
    lea     rdi, [x_align]
    call    spectrum_size
    cmp     rax, 5
    jne     .fail
    ; No line is ungrounded; find the least grounding.
    mov     r12, -1                 ; least so far (unsigned max)
    xor     ebx, ebx
.g: cmp     rbx, [enum_n]
    jae     .least
    lea     rax, [enum_ord]
    mov     rdi, [rax + rbx*8]
    call    grounding
    test    rax, rax
    jz      .fail
    cmp     rax, r12
    jae     .g_next
    mov     r12, rax
.g_next:
    inc     rbx
    jmp     .g
    ; The least grounded lines are exactly ones where both body cells
    ; sound; the deictic lines are exactly those whose adverb is
    ; unanchored.
.least:
    xor     ebx, ebx
.m: cmp     rbx, [enum_n]
    jae     .ok
    lea     rax, [enum_ord]
    mov     r13, [rax + rbx*8]
    mov     rdi, r13
    call    grounding
    cmp     rax, r12
    jne     .deixis
    mov     rdi, r13
    call    p_germanic
    test    eax, eax
    jz      .fail
.deixis:
    mov     rdi, r13
    call    p_deictic
    mov     r8, rax
    push    r8
    mov     rdi, r13
    call    p_unanchored
    pop     r8
    cmp     rax, r8
    jne     .fail
    inc     rbx
    jmp     .m
.ok:
    mov     eax, 1
    jmp     .out
.fail:
    xor     eax, eax
.out:
    pop     r13
    pop     r12
    pop     rbx
    ret

; ============================================================
; XIII. ENTRY POINT
; ============================================================

%macro CHECK 2
    call    %1
    test    eax, eax
    jnz     %%ok
    lea     rdi, [%2]
    jmp     check_failed
%%ok:
%endmacro

; Write a string to stderr.
err_str:
    push    rbx
    mov     rbx, rdi
    call    strlen
    mov     rdx, rax
    mov     rsi, rbx
    mov     edi, STDERR
    call    write_all
    pop     rbx
    ret

check_failed:                       ; rdi = label
    push    rdi
    lea     rdi, [s_fail_a]
    call    err_str
    pop     rdi
    call    err_str
    lea     rdi, [s_fail_b]
    call    err_str
    mov     edi, 1
    jmp     exit

usage:
    lea     rdi, [s_usage]
    call    err_str
    mov     edi, 2
    jmp     exit

exit:                               ; edi = status
    mov     eax, SYS_EXIT
    syscall

; Validate quietly, then print an edition.
_start:
    mov     r12, [rsp]              ; argc
    lea     r13, [rsp + 8]          ; argv
    call    build_cells
    CHECK   chk_inventory,   l_inventory
    CHECK   chk_edition,     l_edition
    CHECK   chk_cardinality, l_cardinality
    CHECK   chk_unique,      l_unique
    CHECK   chk_coverage,    l_coverage
    CHECK   chk_selection,   l_selection
    CHECK   chk_marked,      l_marked
    CHECK   chk_anchor,      l_anchor
    CHECK   chk_boundaries,  l_boundaries
    CHECK   chk_mutation,    l_mutation
    CHECK   chk_sounding,    l_sounding
    mov     ebx, DEFAULT_EDITION
    cmp     r12, 1
    jbe     .run
    cmp     r12, 2
    jne     usage
    mov     r14, [r13 + 8]          ; argv[1]
    xor     ebx, ebx
.find:
    cmp     rbx, NED
    jae     usage
    lea     rax, [ed_names]
    mov     rdi, [rax + rbx*8]
    mov     rsi, r14
    call    streq
    test    eax, eax
    jnz     .run
    inc     rbx
    jmp     .find
.run:
    lea     rax, [ed_funcs]
    call    [rax + rbx*8]
    call    flush
    xor     edi, edi
    jmp     exit
