import CSwLMeta
import Bib
import Mathlib.Tactic.Use

open Verso.Genre Manual
open CSwLMeta

#doc (Manual) "Lógica de predicados" =>
%%%
tag := "FOL"
%%%

```lean
namespace FOL
```

Frases como "Todo príncipe viu uma dama" não podem ser expressas em lógica proposicional — ficariam como átomos `p`/`q` totalmente desconectados, sem capturar que a mesma entidade que é "príncipe" foi a que realizou o ato de ver. Lógica de predicados acrescenta três ingredientes:

* proposições básicas, predicados `n`-ário seguidos de `n` variáveis;
* fórmulas universalmente quantificadas, `∀` seguido de variável e fórmula;
* fórmulas existencialmente quantificadas, `∃` seguido de variável e fórmula.

Também chamada de "lógica de primeira ordem" (FOL, "first order logic") está relacionado a quantificação ser sobre entidades, objetos de primeira ordem. Vamos assumir que predicados aridade até 3 (relações unárias, binárias e ternárias). Relações com mais de três argumentos quase nunca são necessárias para capturar a semântica de linguagem natural. A BNF completa segue abaixo e gera fórmulas como `¬P x`, `∀ x R x x` e `∀ x ∃ y R x y`.

```bnf
v    ::= "x" | "y" | "z" | v "'" ;
P    ::= "P" | P "'" ;
R    ::= "R" | R "'" ;
S    ::= "S" | S "'" ;
atom ::= P v | R v v | S v v v ;
F    ::= atom
  | "(" v "=" v ")" ("identidade")
  | "¬" F ("negação")
  | "(" F "∧" F ")" ("conjunção")
  | "(" F "∨" F ")" ("disjunção")
  | "∀" v F ("quantificação universal")
  | "∃" v F ("quantificação existencial") ;
```

Em Lean, o mesmo tipo `Prop` em Lean pode ser usado na representação de fórmulas de primeira ordem. Também veremos como as fórmulas podem ser manipuladas como dados.

# As regras dos quantificadores em Lean

O Lean se baseia em na teoria dos tipos, na qual se assume que cada variável pertence a algum tipo. Você pode pensar em um tipo como um "universo" ou um "domínio de discurso", no sentido da lógica de primeira ordem.

Seguindo a apresentação de Lógica Proposicional, quatro novas regras precisam ser explicadas, duas para cada quantificador.

```lean
section

variable (U : Type)
variable (P Q : U → Prop)
```

A introdução de `∀` diz que para provar que algo vale de todo `x`, tome um `x`
arbitrário e prove que vale para ele. É a mesma `intro` agora sobre um objeto em vez de uma hipótese. A eliminação de `∀` é aplicação: de `∀ x P x` e de um objeto `d`, sai `P d`.

```lean
example (h : ∀ x, P x) : ∀ y, P y := by
  intro y
  exact h y
```

A introdução de `∃` exige exibir a testemunha. A tática `use` substitui a variável quantificada pelo objeto passado, e deixa como objetivo o que falta provar sobre ele.

```lean
example (y : U) (h : P y) : ∃ x, P x :=
  Exists.intro y h

example (y : U) (h : P y) : ∃ x, P x := by
  use y
```

A eliminação de `∃` é a mais delicada. De `∃ x P x` sabe-se que há uma testemunha, mas não sabemos qual elemento do domínio ela é. A tática `obtain` aplica o teorema `Exists.elim`, introduz com um nome, junto com a propriedade que ele satisfaz.

```lean
example (h : ∃ x, P x ∧ Q x) : ∃ x, Q x := by
  apply Exists.elim h
  intro d hd
  use d
  exact hd.2

example (h : ∃ x, P x ∧ Q x) : ∃ x, Q x := by
  obtain ⟨d, hP, hQ⟩ := h
  exact ⟨d, hQ⟩
```

Podemos ainda considera uma lógica de múltiplos tipos, onde podemos ter múltiplos universos. Por exemplo, podemos querer usar a lógica de primeira ordem para geometria, com quantificadores sobre pontos e linhas. Mas acima restringimos os predicados a um único universo `U`.

A demonstração abaixo não é válida se não declararmos uma variável `u : U`, mesmo que `u` não apareça no enunciado do teorema. Isso destaca uma diferença entre a lógica de primeira ordem e a lógica implementada em Lean. Na dedução natural, podemos provar `∀ x P x → ∃ x P x`, o que mostra que nosso sistema de prova assume implicitamente que o universo tem pelo menos um objeto. Em contraste, a afirmação `(∀ x : U, P x) → ∃ x : U, P x` não é demonstrável em Lean. Em outras palavras, em Lean, é possível que um tipo esteja vazio, e, portanto, a prova acima requer uma suposição explícita de que existe um elemento `u : U`.

```lean
variable (u : U)

example: (∀ x , P x) → ∃ x, P x := by
 intro h
 use u
 exact h u

end
```

::::exercise (rating := 2) (name := "forall-exists-swap")

Prove o primeiro exemplo.

```lean
example {U : Type} (R : U → U → Prop) :
  (∃ y, ∀ x, R x y) → (∀ x, ∃ y, R x y) :=
 solution!(by
  intro h
  obtain ⟨d, hd⟩ := h
  intro x
  exact ⟨d, hd x⟩)
```

Explique porque a volta da implicação não vale.

:::solution
A volta não vale. De `∀x ∃y Rxy` cada `x` pode ter a sua testemunha, e nada obriga que seja a mesma para todos.
:::

::::

# Ligação de variáveis

Numa fórmula `∀x F` (ou `∃x F`), o quantificador liga toda ocorrência de
`x` em `F` que não esteja já ligada por um `∀x`/`∃x` interno a `F`. Uma fórmula é *aberta* se tem ao menos uma ocorrência livre de variável, e *fechada* (também chamada *sentença*) caso contrário. Por exemplo, `(Px ∧ ∃x Rxx)` é aberta, o `x` de `Px` está fora do escopo do `∃x`. Mas `∃x (Px ∧ ∃x Rxx)` é uma sentença.

Essa distinção é o que motiva a ambiguidade de escopo de "Todo príncipe viu uma dama". Duas leituras possíveis, "para cada príncipe existe uma dama (talvez diferente) que ele viu" contra "existe uma dama que todo príncipe viu", formalizadas respectivamente como:

```
∀x (Prince x → ∃y (Lady y ∧ Saw x y))
∃y (Lady y ∧ ∀x (Prince x → Saw x y))
```

Repare que a leitura universal usa `→` como conectivo principal, e
a existencial usa `∧`. Já "Algum príncipe viu uma dama bonita" admite apenas uma formalização, `∃x∃y (Prince x ∧ Lady y ∧ Beautiful y ∧ Saw x y)`.

:::dev "Alexandre (arademaker)"

Em Lean, indexar por aridade é mais natural do que empilhar primos: um
`structure PredSymbol` com campos `name : String` e `arity : Nat` já
representa "infinitos predicados de cada aridade finita" sem precisar
de uma família de gramáticas, uma por aridade. Fica como observação,
`Formula` (abaixo) não adota `PredSymbol`.

:::


# O tipo Fórmulas de FOL

Uma variável carrega nome e um índice (lista de naturais usada para gerar
variáveis "frescas" a partir de uma dada variável):

```lean
structure Variable where
  name : String
  index : List Nat
  deriving DecidableEq

def Variable.format : Variable → Std.Format
  | ⟨name, []⟩ => name
  | ⟨name, [i]⟩ => name ++ toString i
  | ⟨name, is⟩ =>
    name ++ String.intercalate "_" (is.map toString)

instance : Repr Variable := ⟨fun v _ => v.format⟩

def x : Variable := ⟨"x", []⟩
def y : Variable := ⟨"y", []⟩
def z : Variable := ⟨"z", []⟩
```

`Formula α` é parametrizado no tipo dos termos que preenchem os predicados — por ora nossos termos são apenas `Variable`.

```lean
inductive Formula (α : Type) where
  | atom (name : String) (args : List α)
  | eq (t1 t2 : α)
  | top
  | bot
  | neg (f : Formula α)
  | impl (f1 f2 : Formula α)
  | equi (f1 f2 : Formula α)
  | conj (f1 f2 : Formula α)
  | disj (f1 f2 : Formula α)
  | forall_ (v : Variable) (f : Formula α)
  | exists_ (v : Variable) (f : Formula α)
```

A conjunção e a disjunção são binárias, e `top` e `bot` são construtores próprios — o mesmo que fizemos para as fórmulas proposicionais, pelo mesmo motivo. O `α` em `atom` não cria esse problema, porque é parâmetro, não o próprio tipo. A notação n-ária se recupera com as funções abaixo. Uma conjunção vazia é `top`, uma disjunção vazia é `bot`, como fizemos em LP.

```lean
def Formula.conjs {α : Type} : List (Formula α) → Formula α
  | [] => .top
  | [f] => f
  | f :: fs => .conj f (Formula.conjs fs)

def Formula.disjs {α : Type} : List (Formula α) → Formula α
  | [] => .bot
  | [f] => f
  | f :: fs => .disj f (Formula.disjs fs)
```

E a instância de `Repr` para exibirmos fórmulas de forma legível. Note que ela demanda que o tipo `α` tenha também uma instância de `Repr`.

```lean
def Formula.format {α} [Repr α] : Formula α → Std.Format
  | .atom name [] => name
  | .atom name args =>
    name ++ "[" ++
      Std.Format.joinSep (args.map (repr ·)) ", " ++ "]"
  | .eq t1 t2 => f!"{repr t1} = {repr t2}"
  | .neg f => f!"~{f.format}"
  | .impl f1 f2 =>
    f!"({f1.format} ==> {f2.format})"
  | .equi f1 f2 =>
    f!"({f1.format} <=> {f2.format})"
  | .top => "true"
  | .bot => "false"
  | .conj f1 f2 =>
    f!"({f1.format} & {f2.format})"
  | .disj f1 f2 =>
    f!"({f1.format} | {f2.format})"
  | .forall_ v f => f!"A {repr v} {f.format}"
  | .exists_ v f => f!"E {repr v} {f.format}"

instance {α} [Repr α] : Repr (Formula α) :=
  ⟨fun f _ => f.format⟩

```

`Repr` é a classe que o `#eval` procura primeiro, e é por isso que basta escrever `#eval formula0`. Ela devolve um `Std.Format`, e não uma `String`. O segundo argumento que a instância ignora é a precedência.

A seguir, `formula1` expressa que o predicado `R` é reflexivo enquanto `formula2` expressa que ele é simétrico.

```lean
def formula1 : Formula Variable :=
  .forall_ x (.atom "R" [x, x])

def formula2 : Formula Variable :=
  .forall_ x (.forall_ y
    (.impl (.atom "R" [x, y]) (.atom "R" [y, x])))
```

Coletar as variáveis livres de uma fórmula é uma operação que faremos
mais de uma vez, com termos de tipos diferentes. Definimos uma só vez,
deixando como parâmetro a função que extrai as variáveis de um termo —
o que muda de um caso para outro é apenas ela. Nos quantificadores,
`filter` remove a variável ligada, e remove *todas* as suas
ocorrências.

```lean
def Formula.freeVars {α} (vars : α → List Variable) :
    Formula α → List Variable
  | .atom _ args => (args.map vars).flatten
  | .eq t1 t2 => vars t1 ++ vars t2
  | .top => []
  | .bot => []
  | .neg f => f.freeVars vars
  | .impl f1 f2 => f1.freeVars vars ++ f2.freeVars vars
  | .equi f1 f2 => f1.freeVars vars ++ f2.freeVars vars
  | .conj f1 f2 => f1.freeVars vars ++ f2.freeVars vars
  | .disj f1 f2 => f1.freeVars vars ++ f2.freeVars vars
  | .forall_ v f => (f.freeVars vars).filter (· != v)
  | .exists_ v f => (f.freeVars vars).filter (· != v)
```

::::exercise (rating := 2) (name := "closed-form")

Escreva uma função `closedForm : Formula Variable → Bool` que verifica
se uma fórmula é fechada. Aqui cada termo é uma variável, então
extrair as variáveis de um termo é devolvê-lo numa lista de um
elemento.  As fórmulas fechadas são as que têm a lista de livres vazia.

```lean
def freeVarsInFormula (f : Formula Variable) :
    List Variable :=
  solution!(f.freeVars ([·]))

def closedForm (f : Formula Variable) : Bool :=
  solution!((freeVarsInFormula f).isEmpty)
```

::::

::::exercise (rating := 1) (name := "implication-as-abbrev")

Implicações e equivalências podem ser vistas como abreviações, pois se
definem a partir de negação, conjunção e disjunção — as mesmas
equivalências usadas na lógica proposicional. Escreva uma função
`withoutIDs : Formula Variable → Formula Variable` que substitui cada
fórmula por uma equivalente sem ocorrências de `impl` ou `equi`.

```lean
def withoutIDs (frm : Formula Variable) :
    Formula Variable :=
  solution!(
    match frm with
    | .atom name args => .atom name args
    | .eq t1 t2 => .eq t1 t2
    | .top => .top
    | .bot => .bot
    | .neg f => .neg (withoutIDs f)
    | .impl f1 f2 =>
      .disj (.neg (withoutIDs f1)) (withoutIDs f2)
    | .equi f1 f2 =>
      let g1 := withoutIDs f1
      let g2 := withoutIDs f2
      .conj (.disj (.neg g1) g2) (.disj (.neg g2) g1)
    | .conj f1 f2 =>
      .conj (withoutIDs f1) (withoutIDs f2)
    | .disj f1 f2 =>
      .disj (withoutIDs f1) (withoutIDs f2)
    | .forall_ v f => .forall_ v (withoutIDs f)
    | .exists_ v f => .exists_ v (withoutIDs f))
```

::::

::::exercise (rating := 2) (name := "negation-normal-form")

Toda fórmula de lógica de predicados pode ser transformada em uma equivalente na *forma normal da negação* (NNF, "negation normal form"), onde negações só ocorrem diante de átomos. A receita é "empurrar" as negações através dos quantificadores por `¬ ∀x F ≡  ∃x ¬F` e `¬ ∃x F ≡ ∀x ¬F`, e através de disjunções e conjunções pelas leis de De Morgan: `¬(F1 ∧ F2) ≡ ¬F1 ∨ ¬F2` e `¬(F1 ∨ F2) ≡ ¬F1 ∧ ¬F2`. Finalmente, `¬¬F ≡ F` elimina dupla negação. Complete o código da função `nnf`.

Dica: a receita acima diz o que fazer com `¬` diante de alguma subfórmula. Isso sugere duas funções, uma para cada situação em que uma subfórmula pode aparecer. As duas se chamam mutuamente, e por isso vão num bloco `mutual`.

- `nnfPos f` devolve a NNF de `f`;
- `nnfNeg f` devolve a NNF de `¬f`.

Trate `impl` e `equi` diretamente nas duas funções, sem passar por
`withoutIDs`.

```lean
mutual
def nnfPos (frm : Formula Variable) : Formula Variable :=
 solution!(
  match frm with
  | .atom n a => .atom n a
  | .eq t1 t2 => .eq t1 t2
  | .top => .top
  | .bot => .bot
  | .neg f => nnfNeg f
  | .impl f1 f2 => .disj (nnfNeg f1) (nnfPos f2)
  | .equi f1 f2 =>
    .conj (.disj (nnfNeg f1) (nnfPos f2))
          (.disj (nnfNeg f2) (nnfPos f1))
  | .conj f1 f2 => .conj (nnfPos f1) (nnfPos f2)
  | .disj f1 f2 => .disj (nnfPos f1) (nnfPos f2)
  | .forall_ v f => .forall_ v (nnfPos f)
  | .exists_ v f => .exists_ v (nnfPos f))

def nnfNeg (frm : Formula Variable) : Formula Variable :=
 solution!(
  match frm with
  | .atom n a => .neg (.atom n a)
  | .eq t1 t2 => .neg (.eq t1 t2)
  | .top => .bot
  | .bot => .top
  | .neg f => nnfPos f
  | .impl f1 f2 => .conj (nnfPos f1) (nnfNeg f2)
  | .equi f1 f2 =>
    .disj (.conj (nnfPos f1) (nnfNeg f2))
          (.conj (nnfPos f2) (nnfNeg f1))
  | .conj f1 f2 => .disj (nnfNeg f1) (nnfNeg f2)
  | .disj f1 f2 => .conj (nnfNeg f1) (nnfNeg f2)
  | .forall_ v f => .exists_ v (nnfNeg f)
  | .exists_ v f => .forall_ v (nnfNeg f))
end

def Formula.nnf (f : Formula Variable) : Formula Variable :=
  solution!(nnfPos f)

#eval Formula.neg formula2
#eval (Formula.neg formula2).nnf
```

::::

# Símbolos de função

Termos denotam objetos do domínio, e diferentes termos podem denotar um mesmo objeto como o termo `(5 + 3) × 4`, `8 × 4` e `32`. Para representar termos mais complexos que apenas variáveis, a solução é introduzir símbolos funcionais para as operações entre termos. Da mesma forma como escolhemos representar relações binárias quaisquer, ao invés de fixar símbolos específicos para relações como "menor que".

```lean
inductive Term where
  | var (v : Variable)
  | struct (name : String) (args : List Term)

def Term.format : Term → Std.Format
  | .var v => repr v
  | .struct name [] => name
  | .struct name args =>
    name ++ "[" ++
      Std.Format.joinSep
        (args.map Term.format) "," ++ "]"

instance : Repr Term := ⟨fun t _ => t.format⟩

def tx : Term := .var x
def ty : Term := .var y
def tz : Term := .var z
```

Um termo `t` é *livre para* a variável `v` na fórmula `F` se toda ocorrência livre de `v` em `F` pode ser substituída por `t` sem que nenhuma das variáveis de `t` fique ligada. Por exemplo, `y` é livre para `x` em `Px → ∀x Px`, mas o mesmo termo não é livre para `x` em `∀y Rxy → ∀x Rxx`. Da mesma forma, `g(x,y)` não é livre para `x` em `∀y Rxy → ∀x Rxx`.

Um termo livre para uma variável `v` pode ser substituído nas ocorrências livres de `v` sem uma mudança não intencional de significado. Considere a fórmula aberta `∀y Rxy → ∀x Rxx`. Se substituirmos a ocorrência livre de `x` nessa fórmula por `y`, obtemos uma fórmula fechada `∀y Ryy → ∀x Rxx`. Uma variável que originalmente era livre acabou capturada.

Se `t` não é livre para `v` em `F`, podemos sempre renomear as variáveis ligadas de `F` para garantir que a substituição de `t` por `v` em `F` tenha o significado correto. Embora `g(y,c)` não seja livre para `x` em `∀y Rxy → ∀x Rxx`, o termo é livre para `x` em `∀z Rxz → ∀x Rxx`, que é uma chamada *variante alfabética* da fórmula original. Uma variante alfabética de uma fórmula é uma fórmula que difere da original apenas por usar variáveis ligadas diferentes.

A função `isVar` verifica se um termo é uma variável. As funções `varsInTerm` e `varsInTerms` retornam as variáveis que ocorrem num termo ou numa lista de termos sem duplicatas.

```lean
def isVar : Term → Bool
  | .var _ => true
  | .struct _ _ => false

mutual
def varsInTerm : Term → List Variable
  | .var v => [v]
  | .struct _ ts => varsInTerms ts

def varsInTerms (ts : List Term) : List Variable :=
  ts.map varsInTerm |>.flatten |>.eraseDups

end
```

Agora que temos o tipo `Term` podemos usar `Formula Term` ao invés de `Formula Variable`.

::::exercise (rating := 1) (name := "vars-in-formula")

Implemente uma função `varsInForm : Formula Term → List Variable` que
dá a lista de variáveis que ocorrem numa fórmula. Aqui não se trata de
ocorrências *livres*: conte todas, inclusive a variável que cada
quantificador liga. Mantenha a lista sem duplicatas, como fazem
`varsInTerm` e `varsInTerms`.

```lean
def Formula.varsInForm (frm : Formula Term) : List Variable :=
  solution!(
   let tmp :=
    match frm with
    | .atom _ args => varsInTerms args
    | .eq t1 t2 => varsInTerms [t1, t2]
    | .top => []
    | .bot => []
    | .neg f => f.varsInForm
    | .impl f1 f2 => f1.varsInForm ++ f2.varsInForm
    | .equi f1 f2 => f1.varsInForm ++ f2.varsInForm
    | .conj f1 f2 => f1.varsInForm ++ f2.varsInForm
    | .disj f1 f2 => f1.varsInForm ++ f2.varsInForm
    | .forall_ v f => v :: f.varsInForm
    | .exists_ v f => v :: f.varsInForm
   tmp.eraseDups)
```

::::

::::exercise (rating := 2) (name := "free-vars-in-formula")

Implemente `freeVarsInForm : Formula Term → List Variable`, que dá a
lista de variáveis com ocorrências livres numa fórmula.

```lean
def Formula.freeVarsInForm (f : Formula Term) : List Variable :=
  solution!(f.freeVars varsInTerm)
```

::::

::::exercise (rating := 2) (name := "open-form")

Usando a função `freeVarsInForm`, complete a função `openForm`, que verifica se uma fórmula é aberta. Reaproveite as funções anteriores.

```lean
def openForm (f : Formula Term) : Bool :=
  solution!(!f.freeVarsInForm.isEmpty)
```

::::

# Semântica da lógica de predicados

Por conveniência, nos limitamos a um fragmento de língua com apenas três letras de predicado: `P` (unário), `R` (binário), e `S` (ternário).

Como deve ser uma estrutura extralinguística para as constantes `P`, `R` e `S`? Tal estrutura deve conter ao menos um domínio de discurso `D`, formado por entidades individuais, com uma interpretação para `P`, para `R` e para `S`. Essas interpretações são dadas por uma função `Interp`, que a cada nome de predicado e a cada lista de elementos do domínio associa a afirmação de que a relação vale entre eles.

```lean
abbrev Interp (D : Type) := String → List D → Prop
```

Um conjunto de símbolos de relação, com suas aridades, especifica uma linguagem
de lógica de predicados `L`. Uma estrutura `M = (D, I)`, formada por um domínio
não vazio `D` com uma função de interpretação para os símbolos de relação de `L`,
é chamada de *modelo* para `L`. Sempre suporemos que o domínio de um modelo é não
vazio.

Eis um modelo concreto, com domínio de três elementos. `P` vale para `1` ou `3`;
`R` relaciona `1` a `1` e `2`, `2` a `2`, e `3` a `1` e `2`.

```lean
def M : Interp Nat
  | "P", [d] => d = 1 ∨ d = 3
  | "R", [d, e] =>
      (d = 1 ∧ (e = 1 ∨ e = 2))
      ∨ (d = 2 ∧ e = 2)
      ∨ (d = 3 ∧ (e = 1 ∨ e = 2))
  | _, _ => False
```

Dada uma estrutura com função de interpretação `M = (D, I)`, podemos definir uma
valoração para as fórmulas da lógica de predicados, desde que saibamos lidar com
os valores das variáveis individuais. Seja `V` o conjunto das variáveis da
linguagem. Uma função `g : V → D` é chamada de *atribuição de variáveis*, ou
valoração.

Escrevemos `g[v := d]` para a valoração que é como `g` exceto pelo fato de que
`v` recebe o valor `d` — onde `g` poderia ter atribuído um valor diferente.

```lean
def Assign (D : Type) := Variable → D

def Assign.update {D : Type} (g : Assign D)
    (v : Variable) (d : D) : Assign D :=
  fun w => if w = v then d else g w
```

Seja `M` um modelo para a linguagem `L`, seja `g` uma atribuição de variáveis
para `L` em `M`, e seja `F` uma fórmula de `L`. Estamos prontos para definir a
noção `M ⊨ᵍ F`, "F é verdadeira em M sob a atribuição g", ou: "g satisfaz F no
modelo M".

O que segue é uma definição recursiva de verdade para as fórmulas da lógica de
predicados. As cláusulas dos quantificadores são as que fazem a atribuição mudar:
`∀v F` vale quando `F` vale para toda escolha de valor de `v`, e `∃v F` quando
vale para ao menos uma.

```lean
def Formula.holds {D : Type} (I : Interp D)
  (g : Assign D) : Formula Variable → Prop
  | .atom name args => I name (args.map g)
  | .eq t1 t2 => g t1 = g t2
  | .top => True
  | .bot => False
  | .neg f => ¬ Formula.holds I g f
  | .impl f1 f2 =>
    Formula.holds I g f1 → Formula.holds I g f2
  | .equi f1 f2 =>
    Formula.holds I g f1 ↔ Formula.holds I g f2
  | .conj f1 f2 =>
    Formula.holds I g f1 ∧ Formula.holds I g f2
  | .disj f1 f2 =>
    Formula.holds I g f1 ∨ Formula.holds I g f2
  | .forall_ v f =>
    ∀ d : D, Formula.holds I (g.update v d) f
  | .exists_ v f =>
    ∃ d : D, Formula.holds I (g.update v d) f
```

Um caso por construtor, e cada caso troca o construtor pelo conectivo correspondente do Lean. Se avaliamos fórmulas fechadas, isto é, sem variáveis livres, a atribuição `g` se torna irrelevante.

A definição de verdade faz uso essencial das atribuições e, ainda assim, nos
exercícios em que se olha apenas para fórmulas fechadas, a verdade ou a falsidade
não depende de qual atribuição se use. Poder-se-ia pensar, portanto, que é
possível dispensar as atribuições por completo, contanto que nos limitemos a
definir os valores de verdade das fórmulas fechadas da lógica de predicados.

O problema é que, ao aplicar a definição de verdade acima a uma sentença, por
exemplo a `∀x(Px → ∃yRxy)`, a cláusula que trata do quantificador universal faz
referência à noção de verdade para a fórmula `(Px → ∃yRxy)`, que é uma fórmula
aberta. Para determinar se ela é verdadeira temos de saber que objeto `x` denota.
A situação é inteiramente análoga à interpretação de sentenças de língua natural:

```
Todo mestre tem um aprendiz.
Ele tem um aprendiz.
```

Para determinar a verdade da segunda temos de saber quem é o referente do pronome
_ele_.

Uma sentença da lógica de predicados é *logicamente válida* se é verdadeira em
todo modelo; a notação é `⊨ F`. Da convenção de que os domínios de nossos modelos
são sempre não vazios segue que `⊨ ∀xF → ∃xF`, para toda `F` com no máximo a
variável `x` livre.

Uma sentença `C` *se segue logicamente* de uma sentença `P` (`P` de premissa, `C`
de conclusão; dizemos também que `P` implica logicamente `C`) se todo modelo que
torna `P` verdadeira também torna `C` verdadeira. A notação é `P ⊨ C`.

Como julgar afirmações da forma `P ⊨ C`? É claro como podemos refutá-la: achando
um contraexemplo. Um contraexemplo a `P ⊨ C` é um modelo `M` com `M ⊨ P` mas não
`M ⊨ C`.

::::exercise (rating := 2) (name := "quantifier-strength")

Mostre que `∀x(Ax ∧ Bx)` significa algo mais forte que "todo A é B", e que
`∃x(Ax → Bx)` significa algo mais fraco que "algum A é B".

:::solution
`∀x(Ax ∧ Bx)` diz que tudo no domínio é A e é B — não apenas que os A são B. Ela
é falsa em qualquer modelo que tenha um objeto fora de A, mesmo que todos os A
sejam B. A tradução correta de "todo A é B" é `∀x(Ax → Bx)`.

`∃x(Ax → Bx)` é verdadeira assim que houver um objeto que não seja A, porque a
implicação vale vacuamente para ele. Ela não afirma que existe um A que é B; a
tradução correta de "algum A é B" é `∃x(Ax ∧ Bx)`.
:::

::::

::::exercise (rating := 2) (name := "translate-quantified")

Traduza as sentenças a seguir para lógica de predicados, garantindo que as
condições de verdade sejam capturadas.

1. _Someone walks and someone talks._
2. _No wizard cast a spell or mixed a potion._
3. _Every ballad that is sung by a princess is beautiful._
4. _If a knight finds a dragon, he fights it._

```lean
def someoneWalksAndTalks : Formula Variable :=
  solution!(.conj
    (.exists_ x (.atom "Walk" [x]))
    (.exists_ y (.atom "Talk" [y])))

def noWizardCastOrMixed : Formula Variable :=
  solution!(.forall_ x
    (.impl (.atom "Wizard" [x])
      (.neg (.disj (.atom "CastSpell" [x])
                   (.atom "MixedPotion" [x])))))

def everyBalladBeautiful : Formula Variable :=
  solution!(.forall_ x
    (.impl
      (.conj (.atom "Ballad" [x])
        (.exists_ y (.conj (.atom "Princess" [y])
                           (.atom "Sung" [y, x]))))
      (.atom "Beautiful" [x])))

def knightFightsDragon : Formula Variable :=
  solution!(.forall_ x (.forall_ y
    (.impl
      (.conj (.atom "Knight" [x])
        (.conj (.atom "Dragon" [y])
               (.atom "Finds" [x, y])))
      (.atom "Fights" [x, y]))))
```

A fórmula é uma proposta; a verificação é mostrar que ela afirma o que se
queria. `Formula.holds` leva uma fórmula à proposição que ela afirma, dada uma
interpretação, então basta enunciar a condição de verdade pretendida com os
quantificadores do próprio Lean e exigir que as duas coincidam. Como `holds`
calcula, cada teorema fecha por `Iff.rfl`.

```lean
theorem someoneWalksAndTalks_means {D : Type}
    (I : Interp D) (g : Assign D) :
    Formula.holds I g someoneWalksAndTalks ↔
      ((∃ d : D, I "Walk" [d]) ∧ (∃ d : D, I "Talk" [d])) :=
  solution!(Iff.rfl)

theorem knightFightsDragon_means {D : Type}
    (I : Interp D) (g : Assign D) :
    Formula.holds I g knightFightsDragon ↔
      (∀ a : D, ∀ b : D,
        I "Knight" [a] ∧ I "Dragon" [b] ∧ I "Finds" [a, b] →
        I "Fights" [a, b]) :=
  solution!(Iff.rfl)
```

O segundo é o que torna a discussão abaixo verificável: a força universal dos
indefinidos não é uma opinião sobre a tradução, é o que o `∀` do lado direito
diz, e o `Iff.rfl` confirma que a fórmula proposta diz o mesmo.

:::solution
As duas primeiras são diretas, mas repare no escopo da negação em (2): _no
wizard cast a spell or mixed a potion_ nega a disjunção inteira, não cada
disjunto separadamente. Escrever `∀x(Wizard x → (¬CastSpell x ∨ ¬MixedPotion
x))` afirmaria algo mais fraco — que nenhum mago fez as duas coisas.

A terceira mostra por que a cláusula relativa entra como conjunto na
antecedente: _every ballad that is sung by a princess_ restringe o domínio da
quantificação, e a restrição é `Ballad x ∧ ∃y(Princess y ∧ Sung y x)`.

A quarta é a mais instrutiva. Os artigos indefinidos de _a knight_ e _a dragon_
parecem pedir `∃`, mas dentro do antecedente de uma condicional eles ganham
força universal: a sentença diz que *todo* par cavaleiro-dragão que se encontra
luta. Traduzir com `∃` daria `∃x∃y(Knight x ∧ Dragon y ∧ Finds x y → Fights x
y)`, que é quase trivialmente verdadeira — basta haver um par que não se
encontra. E os pronomes _he_ e _it_ retomam justamente as variáveis ligadas
pelos quantificadores, que é o que permite a tradução funcionar.
:::

::::

::::exercise (rating := 2) (name := "valid-consequence")

Quais das afirmações seguintes valem? Se uma vale, explique por quê; se não,
dê um contraexemplo.

1. `∀xPx ⊨ ∃xPx`
2. `∃x∃yRxy ⊨ ∃xRxx`
3. `∃y∀xRxy ⊨ ∀x∃yRxy`

:::solution
1. Vale, e é aqui que a exigência de domínio não vazio faz trabalho: tomando
   qualquer `d` do domínio, de `∀xPx` sai `Pd`, que testemunha `∃xPx`. Num
   domínio vazio a premissa seria vacuamente verdadeira e a conclusão falsa.
2. Não vale. Contraexemplo: domínio `{1, 2}` com `R` valendo apenas de `1` para
   `2`. A premissa é verdadeira, e nenhum objeto se relaciona consigo mesmo.
3. Vale. Se há um `d` tal que todo `x` se relaciona com `d`, então para cada `x`
   esse mesmo `d` testemunha `∃yRxy`.
:::

::::

```lean
end FOL
```
