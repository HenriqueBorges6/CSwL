import CSwLMeta
import Bib
import Mathlib.Algebra.Group.Nat.Even
import Mathlib.Data.Rel
import Mathlib.Logic.Relation
import Mathlib.Data.Set.Basic
import Mathlib.Data.Set.Insert
import Mathlib.Data.Finset.Prod
import Mathlib.Data.Fintype.Prod
import Mathlib.Data.Setoid.Basic
import Mathlib.Tactic

open Verso.Genre Manual
open CSwLMeta

#doc (Manual) "Conjuntos e Relações" =>
%%%
tag := "Sets"
htmlSplit := .never
file := "Sets"
%%%

Conjuntos e relações são a notação que todo texto de matemática pressupõe.
Este capítulo é onde eles se tornam objetos do Lean — e onde as afirmações
que se costuma fazer sobre eles passam a ser teoremas a demonstrar.

```lean
namespace Sets

open Set
```

# Conjuntos e notação de conjuntos

Um conjunto de elementos de `α` por sua função característica: a função
que, dado um elemento, responde se ele pertence ao conjunto. Há duas
maneiras de responder:

* `α → Bool` calcula a resposta. O resultado é `true` ou `false`, e
  pode-se rodar.
* `α → Prop` enuncia a resposta. O resultado é uma afirmação, que se pode
  provar.

A segunda versão é, literalmente, como conjuntos são definidos no Lean.

```lean (name := c3print1)
#print Set
```

```leanOutput c3print1
def Set.{u} : Type u → Type u :=
fun α => α → Prop
```

```lean
def S1 : Set ℕ := {10}
def S2 : Set ℕ := {10, 20}
```

```lean (name := c3check1)
#check S1
```

```leanOutput c3check1
Sets.S1 : Set ℕ
```

```lean (name := c3check2)
#check 10 ∈ S1
```

```leanOutput c3check2
10 ∈ S1 : Prop
```

```lean (name := c3check3)
#check S1 ⊆ S2
```

```leanOutput c3check3
S1 ⊆ S2 : Prop
```

```lean
example : (10 ∈ S1) = (S1 10) := rfl
```

Um `Set α` é uma função `α → Prop`, e nada mais. A notação de conjunto que
se escreve na prática é açúcar para construir essa função, e pertencer é
aplicá-la — as duas coisas são a mesma, e o `rfl` prova:

```lean
example : {n : Nat | n > 2} = Set.ofPred (λ n ↦ n > 2) :=
  rfl

example (p : Nat → Prop) (x : Nat) :
    (x ∈ {n | p n}) = p x := rfl
```

conjunto vazio e conjunto universal

```lean
def my_emptyset : Set ℕ := fun _ ↦ False
example: my_emptyset = ∅  := by rfl

def my_univ : Set ℕ := fun _ ↦ True
example: my_univ = Set.univ := by rfl
```

Escrever `x ∈ A` em vez de `A x` é comodidade de leitura. Vale saber
disso porque, quando uma prova sobre conjuntos empacar, desdobrar a
notação até a aplicação costuma destravar — e o desdobramento é `rfl`,
não um passo que precise de justificativa. Então `above2`, aplicado, é o
predicado aplicado — e `above2 3` é literalmente `3 > 2`, sem nenhuma
camada de conjunto no meio:

```lean
def above2 : Set Nat := {n | n > 2}

example : (3 ∈ above2) = above2 3 := rfl
example : above2 3 = (3 > 2) := rfl
```

`decide` sozinho *não* fecha `3 ∈ above2`: a mensagem é `failed to
synthesize Decidable (3 ∈ above2)`. O motivo é que `above2` é um `def`, e
`decide` não desdobra definições — para ele o objetivo é opaco. `unfold`
faz esse desdobramento manualmente, e depois `decide` calcula:

```lean
example : 3 ∈ above2 := by
  unfold above2
  decide
```

## Aquecimento: conjuntos com nome

```lean
def above5 : Set Nat := {n | n > 5}
```

::::exercise (rating := 1) (name := "five-in-above2")

*A1.* Prove que 5 pertence a `above2`.

```lean
example : 5 ∈ above2 := solution!(by
  unfold above2
  decide)
```

::::

::::exercise (rating := 1) (name := "one-not-in-above2")

*A2.* Prove que 1 não pertence a `above2`. `x ∉ A` abrevia `¬ (x ∈ A)`,
que por sua vez é `x ∈ A → False`.

```lean
example : 1 ∉ above2 := solution!(by
  unfold above2
  decide)
```

::::

::::exercise (rating := 1) (name := "above5-subset-above2")

*A3.* Prove a inclusão. `unfold above2 above5` desdobra as duas
definições; `simp only [Set.mem_ofPred_eq] at h` desdobra a pertinência
em `h` até a desigualdade, que `omega` então resolve.

```lean
example : above5 ⊆ above2 := solution!(by
  unfold above5 above2
  intro x h
  simp only [Set.mem_ofPred_eq] at h ⊢
  omega)
```

::::

União e interseção são disjunção e conjunção elemento a elemento. As duas
inclusões abaixo valem para conjuntos quaisquer, e as provas não
precisam saber nada sobre eles.

::::exercise (rating := 1) (name := "union-contains")

*A4.* Todo conjunto está contido na sua união com outro. Depois do
`intro`, `Or.inl` prova uma disjunção pelo lado esquerdo.

```lean
example (A B : Set Nat) : A ⊆ A ∪ B := solution!(by
  intro x h
  exact Or.inl h)
```

::::

::::exercise (rating := 1) (name := "intersection-contained")

*A5.* E a interseção está contida em cada um dos dois.

```lean
example (A B : Set Nat) : A ∩ B ⊆ A := solution!(by
  intro x h
  exact h.1)
```

::::

A Mathlib tem esses dois últimos prontos, com os nomes
`Set.subset_union_left` e `Set.inter_subset_left`. Aqui o exercício é
escrever a prova, não encontrá-los — mas vale procurar depois, para ver
como as coisas se chamam.

## Mais teoria dos conjuntos

```lean
section
variable {α : Type} (A B C D : Set α)

example : A ⊆ A := by
  rw [subset_def]
  intro x h
  assumption

example (A B : Set ℕ) :
    (A ⊆ B) = (∀ x, x ∈ A → x ∈ B) := rfl
```

```lean (name := c3check4)
#check mem_inter_iff
```

```leanOutput c3check4
Set.mem_inter_iff.{u} {α : Type u} (x : α) (a b : Set α) : x ∈ a ∩ b ↔ x ∈ a ∧ x ∈ b
```

```lean
example : A ∩ B ⊆ B := by
  intro x h
  rw [mem_inter_iff] at h
  obtain ⟨xA,xB⟩ := h
  exact xB
```

```lean (name := c3check5)
#check subset_def
```

```leanOutput c3check5
Set.subset_def.{u} {α : Type u} {s t : Set α} : (s ⊆ t) = ∀ x ∈ s, x ∈ t
```

*A6.* Transitividade da inclusão.

```lean
example : A ⊆ B → B ⊆ C → A ⊆ C := sorry
```

```lean (name := c3check6)
#check Set.inter_def
```

```leanOutput c3check6
Set.inter_def.{u} {α : Type u} {s₁ s₂ : Set α} : s₁ ∩ s₂ = {a | a ∈ s₁ ∧ a ∈ s₂}
```

*A7.* Se `A` está contido em `B` e em `C`, está contido na interseção.

```lean
example : A ⊆ B → A ⊆ C → A ⊆ B ∩ C := sorry
```

::::exercise (rating := 1) (name := "empty-subset")

Explique por que `∅ ⊆ A` vale para todo conjunto `A`. Prove-o. O
argumento é vacuoso, e a prova deve exibir isso.

*Não vale usar `Set.empty_subset`* (nem `simp`, que o encontra): esse
lema é exatamente o enunciado, e citá-lo apagaria o exercício.

```lean
example : ∅ ⊆ A := solution!(by
  intro x hx
  exact False.elim hx)
```

::::

::::exercise (rating := 1) (name := "empty-vs-singleton")

Explique a diferença entre `∅` e `{∅}`.

`∅` é o conjunto que não tem elemento nenhum; `{∅}` é um conjunto que tem
exatamente um elemento, e esse elemento é o conjunto vazio. São,
portanto, objetos distintos: um está vazio, o outro não. A confusão vem
de olhar para o "conteúdo do conteúdo" — o único elemento de `{∅}` é ele
mesmo vazio, mas isso não faz o recipiente ficar vazio.

Cardinalidades: `|∅| = 0` e `|{∅}| = 1`. (A prova abaixo explora
justamente isso: `∅ ∈ {∅}` vale por `rfl`, e transportar essa
pertinência pela igualdade suposta daria `∅ ∈ ∅`, isto é, `False`.)

*Não vale usar `Set.singleton_ne_empty`, `Set.empty_ne_singleton` nem
`simp`.*

```lean
example :
    (∅ : Set (Set α)) ≠ ({∅} : Set (Set α)) := solution!(by
  intro h
  have hmem : (∅ : Set α) ∈ ({∅} : Set (Set α)) := rfl
  rw [← h] at hmem
  exact hmem)
```

::::

::::exercise (rating := 2) (name := "double-complement")

Verifique que o complemento do complemento de `A` é `A`.

Use `Set.ext`. Uma das duas direções precisa de raciocínio clássico: vale
`Classical.byContradiction`, `Classical.em` ou `Classical.byCases`.

*Não vale usar `compl_compl`* (nem `simp`, nem `tauto`, nem `grind`): a
Mathlib prova esse lema para qualquer álgebra de Boole, e conjuntos são
uma. Aqui o exercício é o argumento sobre elementos.

*Qual inclusão precisou do argumento clássico?* A direção que precisa é
`Aᶜᶜ ⊆ A`, isto é, `¬¬(x ∈ A) → x ∈ A` (eliminação da dupla negação). A
outra, `A ⊆ Aᶜᶜ`, ou seja `x ∈ A → ¬¬(x ∈ A)`, é construtiva: dados
`hx : x ∈ A` e `hnx : x ∈ Aᶜ`, basta aplicar `hnx hx` para obter
`False`. A razão é que, na leitura construtiva, `¬ P` é `P → False`; de
uma função que transforma "refutações de `P`" em absurdo não se extrai,
por meios construtivos, uma _prova_ de `P`. Passar de `¬¬P` para `P` é
exatamente o conteúdo do terceiro excluído.

```lean
example : Aᶜᶜ = A := solution!(by
  apply Set.ext
  intro x
  constructor
  · intro hx
    exact Classical.byContradiction hx
  · intro hx hnx
    exact hnx hx)

end
```

::::

### Calcular ou enunciar

`α → Prop` enuncia a pertinência. Existe também `α → Bool`, que a
calcula, e é o que se usa quando o conjunto é finito e a resposta tem
que ser computada — é o caso da verificação de modelos, no fim do livro,
onde decidir se uma sentença vale num modelo é percorrer um domínio finito.

Ser par, na versão que se calcula.

```lean
def isEven (n : Nat) : Bool := n % 2 == 0
```

```lean (name := c3eval1)
#eval isEven 4
```

```leanOutput c3eval1
true
```

```lean (name := c3eval2)
#eval isEven 5
```

```leanOutput c3eval2
false
```

A versão que se enuncia já existe na biblioteca: `Even n` afirma que `n`
é o dobro de algum número, sem dizer como encontrá-lo. Aqui está a
distinção em ato. `isEven` é um algoritmo — divide e compara o resto.
`Even` é uma condição de verdade — existe um `r` tal que `n = r + r`.
São conteúdos diferentes, e por isso vale a pena que sejam objetos
diferentes.

```lean (name := c3print2)
#print Even
```

```leanOutput c3print2
def Even.{u_2} : {α : Type u_2} → [Add α] → α → Prop :=
fun {α} [Add α] a => ∃ r, a = r + r
```

Provar `Even 4` é exibir o `r` que a afirmação promete, junto com a
verificação de que ele serve.

```lean
example : Even 4 := by
  unfold Even
  apply Exists.intro 2   -- alternative `use`
  rfl
```

Nada obriga, a priori, uma afirmação e um algoritmo a dizerem a mesma
coisa. Que estes dois digam é um fato sobre os naturais, Mathlib já traz
a prova, sob o nome `Nat.even_iff`:

```lean
example (n : Nat) : Even n ↔ n % 2 = 0 := Nat.even_iff
```

Provado isso, `Even n` passa a ser uma afirmação que se pode calcular
para um `n` dado — e o Lean faz isso sem que se peça nada:

```lean (name := c3eval3)
#eval Even 4
```

```leanOutput c3eval3
true
```

Vale reparar no que acabou de acontecer. `Even 4` é uma afirmação, não
um programa; ainda assim o `#eval` respondeu `true`. Há um mecanismo por
trás disso, que registra quais afirmações admitem esse cálculo e como
fazê-lo — e ele é uma classe de tipos, como o `BEq` e o `DecidableEq` de
{ref "IntroL"}[Programação Funcional no Lean]. A classe se chama `Decidable`.

# Relações

Um conjunto representa a função que responde se um elemento pertence.
Uma relação binária faz o mesmo com _pares_: é a função que, dados dois
elementos, responde se estão na relação. Em Lean isso não é analogia
nenhuma — é a definição:

```lean (name := c3print3)
#print Rel
```

```leanOutput c3print3
@[reducible] def Rel.{u_6, u_7} : Type u_6 → Type u_7 → Type (max u_6 u_7) :=
fun α β => α → β → Prop
```

`Rel α β` é `α → β → Prop`. É a primeira vez neste capítulo que o
domínio deixa de ser um tipo qualquer e passa a ter conteúdo linguístico:
um domínio de duas entidades, e a relação de gostar entre elas.

O domínio de entidades. Duas bastam para os exemplos deste capítulo.

```lean
inductive Entity where
  | dorothy | toto
deriving DecidableEq

def likesR : Entity → Entity → Prop
  | .dorothy, .toto => True
  | .toto, .dorothy => True
  | _, _            => False
```

```lean (name := c3check7)
#check (likesR : Rel Entity Entity)
```

```leanOutput c3check7
likesR : Entity → Entity → Prop
```

## Inversa

A inversa de uma relação troca a ordem dos argumentos, e é `flip` quem
faz isso. Em língua, é o que a voz passiva faz: _Dorothy likes Toto_ e
_Toto is liked by Dorothy_ descrevem o mesmo par, em ordens opostas.

```lean (name := c3check8)
#check (flip likesR)
```

```leanOutput c3check8
flip likesR : Entity → Entity → Prop
```

```lean
example :
    flip likesR .toto .dorothy =
      likesR .dorothy .toto := rfl
```

## Composição

Compor duas relações é encadeá-las por um elemento intermediário: `R`
composta com `S` relaciona `x` a `z` quando existe um `y` com `x R y` e
`y S z`. É `Relation.Comp`, e provar uma composição é exibir esse
intermediário.

Composição é o que define parentesco em cadeia: "avô" é "pai" composto
com "pai". Aqui, quem gosta de quem gosta de quem:

```lean
example : Relation.Comp likesR likesR .dorothy .dorothy :=
  ⟨.toto, trivial, trivial⟩
```

## Propriedades

Reflexividade, simetria e transitividade se enunciam com quantificador e
conectivo, e são afirmações sobre a relação inteira — não sobre um par.

```lean
def Reflexive' (R : α → α → Prop) : Prop := ∀ x, R x x
def Symmetric' (R : α → α → Prop) : Prop :=
  ∀ x y, R x y → R y x
def Transitive' (R : α → α → Prop) : Prop :=
  ∀ x y z, R x y → R y z → R x z
```

`likesR` é simétrica, e a prova percorre os casos: `decide` não serve,
porque `Prop` aqui não é decidível de graça, mas o casamento de padrão
resolve.

```lean
example : Symmetric' likesR := by
  intro x y h
  cases x <;> cases y <;> simp_all [likesR]
```

As três juntas dão uma _relação de equivalência_, e a biblioteca tem o
nome pronto: `Equivalence`. A igualdade é o exemplo canônico.

```lean (name := c3check9)
#check @Equivalence
```

```leanOutput c3check9
@Equivalence : {α : Sort u_1} → (α → α → Prop) → Prop
```

```lean
example :
    Equivalence (· = · : Entity → Entity → Prop) :=
  eq_equivalence
```

## Calcular ou enunciar, outra vez

Vale a mesma escolha da seção de conjuntos. A divisibilidade vem na
biblioteca na versão que enuncia — `m ∣ n` afirma que existe um fator
que leva de `m` a `n`, e provar é exibi-lo — e ainda assim se calcula,
porque a instância `Decidable` existe:

```lean
example : (3 : Nat) ∣ 12 := ⟨4, rfl⟩
```

```lean (name := c3eval4)
#eval (3 ∣ 12 : Prop)
```

```leanOutput c3eval4
true
```

```lean (name := c3eval5)
#eval (5 ∣ 12 : Prop)
```

```leanOutput c3eval5
false
```

```lean
example : ∀ n : Nat, n ∣ n := fun _ => Nat.dvd_refl _
```

Relação é a estrutura que a verificação de modelos vai usar para dar
modelo a um fragmento — um domínio de entidades e, para cada verbo, a
relação que ele denota — e à qual o tratamento de verbos de mais de dois
lugares, e do escopo entre eles, volta mais tarde.

:::dev "Alexandre (arademaker)"
Estamos apresentando conceitos dentro do enunciado de um exercício. Talvez seja melhor evitar isso.
:::

::::exercise (rating := 2) (name := "cartesian-square")

Tome `A` como o conjunto `{Kasparov, Karpov, Anand}`. Encontre `A × A`.

Como `A` é finito, o produto cartesiano é finito e a Mathlib o calcula:
`Finset` é o tipo dos conjuntos finitos, `Fintype α` é a evidência de
que `α` tem finitos elementos (e dá `Finset.univ`, o conjunto de todos
eles), e `s ×ˢ t` é o produto cartesiano de dois `Finset`. Construa `A ×
A` e prove que tem nove elementos.

A evidência de que `Player` é finito: a lista dos seus elementos, mais a
prova de que não falta ninguém. (O normal seria `deriving Fintype`, mas
o gerador automático está quebrado nesta versão da Mathlib — então a
instância vai à mão, o que também mostra o que um `Fintype` é.)

```lean
inductive Player where
  | kasparov | karpov | anand
deriving Repr, DecidableEq

instance : Fintype Player :=
  ⟨{.kasparov, .karpov, .anand},
   fun x => by cases x <;> decide⟩

def playerPairs : Finset (Player × Player) :=
  solution!(Finset.univ ×ˢ Finset.univ)

theorem playerPairs_test : playerPairs.card = 9 :=
  solution!(by decide)
```

:::gradeTheorem "1" playerPairs_test
:::
::::

::::exercise (rating := 2) (name := "successor-composition")

Qual é a composição de `{(n, n + 2) | n ∈ ℕ}` com ela mesma?

Enuncie a resposta e prove.

```lean
def plusTwo : Rel Nat Nat := fun a b => b = a + 2

theorem plusTwo_test (a c : Nat) :
    Relation.Comp plusTwo plusTwo a c ↔ c = a + 4 :=
    solution!(by
  constructor
  · intro ⟨b, hb, hc⟩
    have hb' : b = a + 2 := hb
    have hc' : c = b + 2 := hc
    omega
  · intro hc
    exact ⟨a + 2, rfl, show c = a + 2 + 2 by omega⟩)
```

:::gradeTheorem "1" plusTwo_test
:::
::::

::::exercise (rating := 2) (name := "converse-subset")

Mostre que de `R˘ ⊆ R` segue que `R = R˘`.

A Mathlib tem `Std.Symm.flip_eq : flip r = r` para relações simétricas.
Usá-lo é permitido — mas então o trabalho é seu de construir a instância
`Std.Symm R` a partir de `h`, que é o mesmo argumento. A prova direta é
mais curta.

```lean
theorem flip_eq_test {α : Type} (R : Rel α α)
    (h : flip R ≤ R) : R = flip R := solution!(by
  apply le_antisymm
  · intro x y hxy
    exact h y x hxy
  · exact h)
```

:::gradeTheorem "1" flip_eq_test
:::
::::

::::exercise (rating := 2) (name := "which-are-transitive")

Quais das relações seguintes são transitivas?

1. `{(1,2), (2,3), (3,4)}`
2. `{(1,2), (2,3), (3,4), (1,3), (2,4)}`
3. `{(1,2), (2,3), (3,4), (1,3), (2,4), (1,4)}`
4. `{(1,2), (2,1)}`
5. `{(1,1), (2,2)}`

Estas relações são finitas, e por isso podem ser dadas como o `Finset`
dos seus pares — e aí a transitividade _se decide_: escreva-a como uma
proposição sobre os pares do `Finset` e o `decide` calcula a resposta.

Complete `isTransitive` e depois decida os cinco casos. É `abbrev`, e
não `def`, para que a instância `Decidable` seja encontrada através da
definição — trocar por `def` faz o `decide` falhar com `failed to
synthesize Decidable (isTransitive r3)`, porque a busca de instâncias
não desdobra um `def`.

```lean
abbrev isTransitive (r : Finset (Nat × Nat)) : Prop :=
  solution!(∀ p ∈ r, ∀ q ∈ r, p.2 = q.1 → (p.1, q.2) ∈ r)

def r1 : Finset (Nat × Nat) := {(1,2), (2,3), (3,4)}
def r2 : Finset (Nat × Nat) :=
  {(1,2), (2,3), (3,4), (1,3), (2,4)}
def r3 : Finset (Nat × Nat) :=
  {(1,2), (2,3), (3,4), (1,3), (2,4), (1,4)}
def r4 : Finset (Nat × Nat) := {(1,2), (2,1)}
def r5 : Finset (Nat × Nat) := {(1,1), (2,2)}

theorem r1_test : ¬ isTransitive r1 := solution!(by decide)
theorem r2_test : ¬ isTransitive r2 := solution!(by decide)
theorem r3_test :   isTransitive r3 := solution!(by decide)
theorem r4_test : ¬ isTransitive r4 := solution!(by decide)
theorem r5_test :   isTransitive r5 := solution!(by decide)
```

:::gradeTheorem "1" r1_test r2_test r3_test r4_test r5_test
:::
::::

::::exercise (rating := 2) (name := "transitive-iff-comp")

Verifique que uma relação `R` é transitiva se e somente se `R ∘ R ⊆ R`.

*Não vale usar `SetRel.isTrans_iff_comp_subset_self`*, que é este
enunciado na versão "relação como conjunto de pares" (vale abrir
`Mathlib/Data/Rel.lean` e ver: o exercício aparece lá provado, com esse
nome). Prove as duas direções.

```lean
theorem isTrans_iff_test {α : Type} (R : Rel α α) :
    IsTrans α R ↔ Relation.Comp R R ≤ R := solution!(by
  constructor
  · intro htrans x z ⟨y, hxy, hyz⟩
    exact htrans.trans x y z hxy hyz
  · intro hsub
    exact ⟨fun x y z hxy hyz => hsub x z ⟨y, hxy, hyz⟩⟩)
```

:::gradeTheorem "1" isTrans_iff_test
:::
::::

::::exercise (rating := 2) (name := "transitive-not-idempotent")

Você pode dar um exemplo de relação transitiva `R` para a qual `R ∘ R =
R` não vale?

Exiba a testemunha completando `counterexample` e prove as duas coisas:
que ela é transitiva, e que a composição com ela mesma não lhe é igual.

```lean
def counterexample : Rel Nat Nat :=
  solution!(fun a b => a < b)

theorem counterexample_trans : IsTrans Nat counterexample :=
  solution!(⟨fun _ _ _ hxy hyz => Nat.lt_trans hxy hyz⟩)

theorem counterexample_different :
    Relation.Comp counterexample counterexample ≠
      counterexample :=
  solution!(by
    intro h
    have h01 :
        Relation.Comp counterexample counterexample
          0 1 := by
      rw [h]; exact Nat.lt_succ_self 0
    obtain ⟨b, hb0, hb1⟩ := h01
    have hb0' : 0 < b := hb0
    have hb1' : b < 1 := hb1
    omega)
```

:::gradeTheorem "1" counterexample_trans counterexample_different
:::
::::

# Funções

Funções já apareceram — o capítulo sobre Lean as apresentou como tipo
primitivo, `α → β`. O que se acrescenta aqui é a ligação com as relações:
uma função é uma relação com uma restrição. Para cada `a`, no máximo um
`b` está relacionado a ele. `Rel α β`, do jeito que ficou definido acima,
não impõe isso — `likesR` bem poderia relacionar `dorothy` a duas
entidades diferentes. Uma função é o caso particular em que a resposta é
única, e é justamente essa unicidade que permite escrever `f x` em vez de
"algum `b` tal que `(x, b) ∈ f`".

## Função característica

Toda relação, vista como conjunto de pares, tem uma função
característica: a função que decide se um par está nela. Reaproveitando
`likesR` de acima — que já é a própria função característica da relação
de gostar, escrita como `Entity → Entity → Prop`: dados `x` e `y`,
`likesR x y` é a afirmação "x gosta de y", nem mais nem menos. Isto
prepara a leitura da seção seguinte: conjunto e relação *são* funções
para `Prop` (ou `Bool`), não apenas "correspondem" a elas.

::::exercise (rating := 1) (name := "successor-as-relation")

A função sucessor `s : ℕ → ℕ` é dada por `n ↦ n + 1`. Qual é a
composição de `s` com ela mesma?

`∘` é `Function.comp`, e duas funções são iguais quando concordam em
todo ponto — é o que `funext` diz.

```lean
def s : Nat → Nat := fun n => n + 1

theorem s_comp_test : s ∘ s = fun n => n + 2 := solution!(by
  funext n
  rfl)
```

:::gradeTheorem "1" s_comp_test
:::
::::

::::exercise (rating := 1) (name := "leq-as-function")

`≤` é uma relação binária sobre os naturais. Qual é a função
característica correspondente?

Escreva a função e prove que ela é adequada — que responde `true`
exatamente quando a relação vale.

Aqui `Prop` e `Bool` se encontram: `m ≤ n` é uma proposição, `leChar m
n` é um cálculo. A ponte é `decide`, e os lemas que a atravessam são
`decide_eq_true_iff`, `of_decide_eq_true` e `decide_eq_true`.

```lean
def leChar : Nat → Nat → Bool :=
  solution!(fun m n => decide (m ≤ n))

theorem leChar_test (m n : Nat) :
    leChar m n = true ↔ m ≤ n := solution!(by
  constructor
  · intro h
    exact of_decide_eq_true h
  · intro h
    exact decide_eq_true h)
```

:::gradeTheorem "1" leChar_test
:::
::::

::::exercise (rating := 2) (name := "graph-is-functional")

Seja `f : A → B` uma função. Mostre que a relação `R` dada por `(x, y) ∈
R` se e somente se `f x = f y` é uma relação de equivalência sobre `A`.

`Equivalence R` é a estrutura com os três campos `refl`, `symm` e
`trans`; `Setoid α` é a mesma coisa empacotada com a relação, e é o que
a Mathlib usa para quocientes.

*Não vale usar `Setoid.ker`*: é exatamente esta relação, já construída
na Mathlib com a prova de que é de equivalência. Prove os três campos.

```lean
def kernel {α β : Type} (f : α → β) : Rel α α :=
  fun x y => f x = f y

theorem ex_3_12 {α β : Type} (f : α → β) :
    Equivalence (kernel f) :=
  solution!({ refl  := fun _ => rfl
              symm  := fun h => h.symm
              trans := fun h1 h2 => h1.trans h2 })
```

:::gradeTheorem "1" ex_3_12
:::
::::

O mesmo fato, empacotado: um `Setoid` é uma relação mais a prova de que
ela é de equivalência. Reaproveite `ex_3_12`.

```lean
def kernelSetoid {α β : Type} (f : α → β) : Setoid α :=
  solution!(⟨kernel f, ex_3_12 f⟩)
```

```lean
end Sets
```
