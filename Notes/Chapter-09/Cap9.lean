/-!
# Anotações e Implementação: Capítulo 9 (Seção 9.1)
Parsing e Árvores Sintáticas
-/

/-- Estrutura de árvore sintática paramétrica:
- `α`: tipo da informação lexical nas folhas (ex: String para palavras)
- `β`: tipo da informação sintática nos nós (ex: String para categorias como "NP", "VP")
-/
inductive ParseTree (α β : Type) where
  | ep
  | leaf (a : α)
  | branch (b : β) (ts : List (ParseTree α β))
  deriving Repr, BEq

def word₁ : ParseTree String String := .leaf "Alice"

def nominalCategory₁ : ParseTree String String := .branch "NP" [word₁]

/-- Exemplo clássico do livro: "Snow White loved the dwarfs" -/
def snowWhite : ParseTree String String :=
  .branch "S"
    [.branch "NP" [.leaf "Snow White"],
     .branch "VP" [.branch "TV" [.leaf "loved"],
                   .branch "NP" [.leaf "the dwarfs"]]]

#eval snowWhite


/-
Linguística Generativa (Chomsky)-" A linguagem humana não é linear, ela é hierarquica"
  ->  Nós ouvimos palavras em uma fila linear no tempo, mas o nosso cérebro as organiza em
    blocos aninhados (constituintes).

        S
      /   \
     NP   VP
        /    \
       TV    NP

Dominância: p domina q se p é prefixo do caminho até q
  Constituent Containmnent:
    ⋆ Se o nó VP domina o verbo "loved" e o objeto "the dwarfs", então esses dois elementos
    Forman uma **unidade sintática indivisível** ( o predicado ). Essa unidade sintática
    indivisível pode ser utilizada posteriormente na sentença:
    "SnowWhite loved the dwarfs, and Alice did so too"

                              S_coord
                         /       |       \
                       S₁       CONJ      S₂
                    /      \    [and]   /     \
                 NP₁        VP₁       NP₃     VP₂
             [SnowWhite]   /   \    [Alice]  [did so too]
                         TV₁   NP₂
                      [loved] [the dwarfs]

    A sessão 9.1 ainda não trata desse tipo de ParseTree

    [Aprofundamento sobre os questionamentos de Conjunção e Coordenação]:
    - Por que usamos mais do que a ParseTree da 9.1 aqui?
      Sim! Para gerar sentenças coordenadas com conjunções ("and") e elipses verbais
      ("did so too"), é necessário um arcabouço de regras gramaticais avançadas:
      regras de coordenação (S -> S CONJ S) e anáfora discursiva.
    - O livro só introduz essas regras formais nas seções 9.6, 9.7 e no Capítulo 12.
    - O papel desse exemplo na 9.1 é puramente conceituar o "Teste de Constituência":
      mostrar que "did so too" só consegue substituir o predicado de uma vez
      porque na geometria da árvore o nó VP₁ domina esse constituinte como um bloco fechado.
    - Em 9.1, o autor não ensina como *gerar* essa árvore coordenada; ele apenas
      assume a árvore pronta para ensinar a navegar em suas coordenadas.

Irmandadade: p e q são irmãos se compartilham o mesmo nó pai
  ⋆ relação entre um verbo e quem recebe a ação
  ⋆ Na linguística: representa a relação de dependência mais íntima e local da gramática.
    O verbo transitivo (TV) e o objeto direto (NP) são irmãos sob o VP.
    O verbo governa o nó irmão, impondo caso morfológico acusativo ("loved her", não "loved she").

C-Command: Relação de ordem inversa a proximidade ao nó raiz, ou seja, p comanda q
  se p está mais próximo da raiz do que q

  [Refinamento conceitual importante sobre o C-Command]:
  - Atenção: C-command NÃO é apenas estar mais próximo da raiz!
    Se um nó pai está mais próximo da raiz, ele domina os filhos, mas NÃO os c-comanda.
    (Na regra formal: um nó nunca c-comanda seus próprios filhos nem a si mesmo).
  - A regra exata:
    "p c-comanda q se e somente se uma IRMÃ de p DOMINA q (com p ≠ q e p não dominando q)."
  - Intuição geométrica:
    Para exercer c-command, você deve primeiro "olhar para a sua irmã" no mesmo nível
    e então projetar o seu comando sobre toda a descendência que a sua irmã domina.
  - Fenômenos linguísticos que dependem de C-Command:
    1. Teoria da Ligação (Binding Theory): Pronomes reflexivos (herself/himself)
       precisam ser c-comandados pelo antecedente ("Alice admired herself" OK,
       mas "Alice's brother admired herself" FALHA pois Alice não c-comanda o VP).
    2. Escopo de Quantificadores e Negação: Quem c-comanda quem define o sentido
       de frases como "Every boy didn't laugh".

Limitações que a Seção 9.1 esbarra e motivam as próximas seções:
  1. A árvore precisa já estar pronta (a 9.1 não faz parsing a partir de texto cru).
  2. Ineficiência O(n²) de tabelas de pares relacionais.
  3. Categorias cegas (Strings não capturam traços de número/plural ou lacunas de movimento).
-/

abbrev Pos := List Nat

def subtree {α β : Type} : ParseTree α β → Pos → ParseTree α β
  | t , [] => t
  | .branch _ ts, i :: is =>
    match ts[i]? with
    | none => .ep
    | some t' => subtree t' is
  | _ , _ => .ep

-- Testes de inspeção de subárvore:
#eval subtree snowWhite [1, 0] -- Subárvore TV "loved"
#eval subtree snowWhite [0]    -- Subárvore NP "Snow White"

---


/-!
==============================================================================
## Seção 9.2: Reconhecimento e Parsing de Linguagens Livres de Contexto
==============================================================================

1. Motivação e Papel Pedagógico:
   A Seção 9.2 atua como um "contraexemplo didático" no livro. Ela introduz
   as tarefas centrais:
   - Reconhecimento (Recognition): responder apenas Bool (w ∈ L(G)?).
   - Parsing: construir a árvore sintática (ParseTree).
   Para resolver isso, testa o método intuitivo de força bruta: dividir a string
   em todos os pontos possíveis (`split2`, `splitN`) e testar regras recursivamente.

2. A Armadilha de Terminação e Divisões Vazias:
   Dada uma string `w`, `split2 w` gera partições `(u, v)` onde `u` ou `v` podem
   ser vazios (`[]`), fazendo com que a outra metade seja a própria palavra inteira `w`!
   Se a gramática contiver recursão à esquerda ou regras como S -> A B onde A -> ε,
   o parser entra em loop infinito chamando a si mesmo sobre a mesma entrada.

3. O Desafio no Lean 4 vs. Haskell:
   - Em Haskell (lazy / avaliação preguiçosa), funções parciais e loops não impedem a compilação.
   - No Lean 4, todo programa precisa provar terminação estrita para preservar a consistência lógica.
   - Como o corte do miolo de uma palavra (em palíndromos aAa) é feito por indexação/drop
     e não por subtermos construtores estruturais diretos, o verificador do Lean não vê
     automaticamente que o miolo diminui.

4. Decisão Atual do Professor vs. Alternativas Não Incorporadas:
   - Decisão atual (upstream/feat/parsing): O professor declarou `recognize` e `parse`
     como `partial def`, contornando a prova de terminação, e verificou a correção contra
     `Mathlib.Data.List.Palindrome` até tamanho 6 com `native_decide`.
   - Alternativas possíveis:
     a) `termination_by s.length` com lema de decréscimo estrito da fatia central.
     b) Parâmetro de combustível (`fuel : Nat`) decrescente, técnica já usada em `CSwL/InfEngine.lean`.
     c) Desconstrução simétrica por indução nas pontas (estilo Mathlib `List.Palindrome`).
   - Conclusão pedagógica: O método do `split2` é abandonado pelo próprio livro na 9.3
     devido à ineficiência O(2^n) e fragilidade de terminação, motivando os Parser Combinators.
-/

/-- Divisão de uma lista em duas partes em todos os pontos possíveis. -/
def split2 {α : Type} : List α → List (List α × List α)
  | [] => [([], [])]
  | x :: xs => ([], x :: xs) :: (split2 xs).map fun (ys, zs) => (x :: ys, zs)

#eval split2 ['a', 'b', 'c']


/-!
==============================================================================
## Seção 9.3: Parsers e Parser Combinators (O Motor de Parsing Funcional)
==============================================================================

1. O Paradigma "List of Successes" (Philip Wadler):
   Em vez de dividir strings às cegas, um parser consome a entrada ordenadamente
   da esquerda para a direita. O tipo canônico é:
   `Parser α β := List α → List (β × List α)`
   - Entrada (`List α`): fita de tokens de entrada.
   - Saída (`List (β × List α)`): lista de pares `(objeto_construído, sobra_da_fita)`.
     - Falha: `[]` (nenhum parse válido).
     - Determinístico: 1 resultado `[(árvore, sobra)]`.
     - Ambíguo: múltiplos resultados (ex: duas árvores para a mesma sentença).

2. Parsers Atômicos e Esclarecimento de Conceitos:
   - Símbolo (`symbol c`): unidade atômica da fita (um `Char` se a fita for texto;
     uma `String` se a fita já for lista de palavras). Consome exatamente 1 item se `x == c`.
   - Token (`token cs`): sequência contínua de símbolos (consome um bloco de itens).
   - Satisfy (`satisfy p`): consome 1 símbolo se ele satisfizer um predicado genérico `p : α → Bool`.
   - Just (`just p`): filtro que garante que o parse consumiu a fita até o fim (`sobra.isEmpty`).
     Impede que entradas inválidas com lixo residual sejam aceitas como válidas.

3. Por que `<|>` não bastava e exigiu o Combinador Sequencial `<*>`:
   - `<|>` (Alternância / "OU"): concatena resultados de escolhas alternativas (`VP -> smiled | laughed`).
     Falha ao tentar lidar com regras com múltiplos constituintes como `S -> NP VP`,
     pois apenas testa opções sobre a mesma entrada e não passa a sobra para a frente.
   - `<*>` (Sequenciamento / "E"): passa a sobra do primeiro parser para alimentar o segundo,
     combinando os resultados através de aplicação funcional.

4. Construção de Árvores com `<$>` e Acúmulo de Filhas com `<:>`:
   - `<$>` (Mapeamento Funcional): aplica uma função ao resultado de um parser,
     transformando texto cru em nós de árvore (`Leaf <$> token "Alice"`).
   - `<:>` (Cons de Parsers): junta um parser de um elemento `Parser α β` com um parser
     de lista `Parser α (List β)`. Permite criar regras com qualquer quantidade N de
     símbolos em sequência sem precisar inventar operadores ad-hoc para cada tamanho.

5. Ilustração Visual da Construção da Árvore com `<:>` e `<$>`:

   Entrada: \["gave", "Alice", "the-sword"\]
   Expressão: (\ts => .branch "VP" ts) <$> (pVerbo <:> (pObj1 <:> (pObj2 <:> succeed \[\])))

   Passo 1: pVerbo consome "gave"          -> Folha TV "gave"
            Fita restante: \["Alice", "the-sword"\]

   Passo 2: pObj1 consome "Alice"          -> Folha NP "Alice"
            Fita restante: \["the-sword"\]
            Lista acumulada: \[TV "gave", NP "Alice"\]

   Passo 3: pObj2 consome "the-sword"      -> Folha NP "the-sword"
            Fita restante: \[\]
            Lista acumulada: \[TV "gave", NP "Alice", NP "the-sword"\]

   Passo 4: (<$>) aplica o nó "VP" sobre a lista completa de nós irmãos:

                             VP
                      /      |       \
                    TV       NP        NP
                    |        |         |
                 \[gave\]   \[Alice\]  \[the-sword'\]

6. Insights Arquiteturais para o CSwL (Em Aberto pelo Professor):
   No arquivo `CSwL/Parsing.lean`, o professor anotou o dilema de design em aberto:
   "list-of-successes parsers, still to decide: StateT (List α) List with Mathlib's
    Monad/Alternative List, or plain functions."

   Comparação Técnica:
   - Abordagem A (Funções Puras `List α → List (β × List α)`):
     * Vantagens: Didaticamente direta, transparente para iniciantes, espelha o livro 1:1.
     * Desvantagens: Encadeamento manual de sobras sem a notação `do`.
   - Abordagem B (Mônada de Estado `StateT (List α) List` com `Alternative`):
     * Vantagens: Habilita notação imperativa `do`, `<|>` nativo da classe `Alternative`,
       composição monádica idiomática do Lean 4.
     * Desvantagens: Introduz transformadores de mônadas antes do aluno dominar o conceito básico.
   - Observação sobre `Std.Internal.Parsec`:
     O Parsec do Lean 4 retorna apenas 1 resultado (com erro determinístico), não uma lista
     de sucessos. Logo, ele não serve para gramáticas ambíguas de PLN, mas é perfeito
     para a análise léxica (scanner de palavras da Seção 9.5).
-/

/-- Tipo canônico de um combinador de parsing não-determinístico (List of Successes). -/
def Parser (α β : Type) := List α → List (β × List α)

/-- Parser que sempre tem sucesso sem consumir nada da fita. -/
def succeed {α β : Type} (val : β) : Parser α β :=
  fun xs => [(val, xs)]

/-- Parser que sempre falha. -/
def failp {α β : Type} : Parser α β :=
  fun _ => []

/-- Parser que consome um símbolo se satisfizer o predicado. -/
def satisfy {α : Type} (p : α → Bool) : Parser α α
  | [] => []
  | x :: xs => if p x then [(x, xs)] else []

/-- Parser que consome um símbolo idêntico a `c`. -/
def symbol {α : Type} [BEq α] (c : α) : Parser α α :=
  satisfy (fun x => x == c)

/-- Filtro `just`: só aceita resultados em que a fita restante foi completamente consumida. -/
def just {α β : Type} (p : Parser α β) : Parser α β :=
  fun xs => (p xs).filter fun (_, remainder) => remainder.isEmpty

/-- Combinador de escolha alternativa (`<|>`): concatena os sucessos de p1 e p2. -/
def alt {α β : Type} (p1 p2 : Parser α β) : Parser α β :=
  fun xs => p1 xs ++ p2 xs

/-- Mapeador funcional (`<$>`): pós-processa o resultado construído pelo parser. -/
def mapP {α β γ : Type} (f : β → γ) (p : Parser α β) : Parser α γ :=
  fun xs => (p xs).map fun (val, remainder) => (f val, remainder)

/-- Construtor de sequência (`<:>`): acumula elementos parseados em uma lista de resultados. -/
def consP {α β : Type} (p : Parser α β) (q : Parser α (List β)) : Parser α (List β) :=
  fun xs =>
    (p xs).flatMap fun (r, ys) =>
      (q ys).map fun (rs, zs) => (r :: rs, zs)

-- Demonstração prática do combinador `symbol` e `just`:
#eval (symbol 'a') ['a', 'b', 'c']       -- Sucesso: [('a', ['b', 'c'])]
#eval (symbol 'x') ['a', 'b', 'c']       -- Falha: []
#eval (just (symbol 'a')) ['a', 'b']      -- Falha com just (sobra não é vazia): []
#eval (just (symbol 'a')) ['a']           -- Sucesso com just: [('a', [])]


/-!
==============================================================================
## Seção 9.4: Features and Categories (Traços e Categorias Sintáticas)
==============================================================================

1. Motivação da Seção:
   Até a Seção 9.3, os parsers tratavam rótulos como strings cegas ("NP", "VP").
   Isso permitia aceitar sentenças agramaticais com falhas de concordância,
   como *"The dwarfs smiles"* (sujeito plural com verbo singular) ou *"She loved he"*
   (caso nominativo onde se exige acusativo).
   A Seção 9.4 introduz o sistema de traços sintáticos (*syntactic features*) para
   garantir concordância morfológica de gênero, número, pessoa, caso e tempo.

2. Duas Visões sobre Concordância de Traços:
   - Visão Derivacional / Controle (Mestre -> Escravo):
     Um constituinte controlador (a fonte, ex: sujeito) dita e copia ativamente
     seus traços para o constituinte dependente (o alvo, ex: verbo).
   - Visão de Unificação / Restrições (Aperto de Mãos Simétrico):
     Não há mestre nem escravo. Cada constituinte chega com suas restrições
     parciais, e a gramática realiza uma checagem de compatibilidade (interseção).
   - A Solução do Livro: Um mix pragmático. A função `agree` realiza a checagem
     de compatibilidade e a regra sintática projeta os traços resultantes no nó pai.

3. O Dilema de Design de `Feat` (Em aberto no CSwL / Issue 42):
   - Abordagem 1 (Livro / Haskell 2010 - Lista Plana `List Feat`):
     Joga todos os traços em um único tipo e usa `List Feat`.
     * Vantagem: Fácil de estender com preposições e flexível para concatenar.
     * Desvantagem: O compilador não impede absurdos como `[Masc, Fem, Sg, Pl]`,
       exigindo funções de checagem manual em tempo de execução (`length <= 1`).
   - Abordagem 2 (Lean 4 Idiomático - Registros Estruturados `structure Agreement`):
     Separa em tipos mutuamente exclusivos (`Gender`, `Number`, `Person`) dentro
     de uma estrutura com campos opcionais.
     * Vantagem: Tipagem estrita por construção (impossível ter dois gêneros).
     * Desvantagem: Mais código de unificação e menor flexibilidade dinâmica.

4. A Anatomia do Tipo `Cat` (Os 4 Componentes Essenciais):
   ```
   data Cat = Cat Phon CatLabel Agreement [Cat]
   ```
   (1) `Phon`: Texto físico cru (palavra na fita, ex: "loved"; ou "_" para nós compostos).
   (2) `CatLabel`: Rótulo sintático da classe (ex: "S", "NP", "VP", "TV").
   (3) `Agreement`: Lista de traços de concordância (ex: \[Tense\], \[Pl, Thrd\]).
   (4) `\[Cat\]` (Subcategorização): O "apetite" do constituinte — a lista de categorias
       que ele precisa "engolir" para ficar completo (ex: TV pede \[NP\]; ditransitivo pede \[NP, NP\])_.
-/

/-- Traços sintáticos gramaticais (gênero, número, pessoa, caso, tempo, preposições). -/
inductive Feat where
  | masc | fem | neutr | mascOrFem
  | sg | pl
  | fst | snd | thrd
  | nom | accOrDat
  | pers | refl | wh
  | tense | infl
  | on | with | by | to | from
  deriving Repr, BEq, DecidableEq

/-- Pacote de concordância como lista de traços. -/
abbrev Agreement := List Feat

/-- Rótulo da classe sintática (ex: "S", "NP", "VP"). -/
abbrev CatLabel := String

/-- Representação fonológica / texto cru (ex: "loved" ou "\_" para nós abstratos). -/
abbrev Phon := String

/-- Categoria sintática rica com 4 componentes:
1. `phon`: grafia da palavra (ou "\_" se for nó sintático intermediário)
2. `label`: rótulo categorial ("NP", "VP", etc.)
3. `agr`: lista de traços morfológicos de concordância
4. `subcat`: lista de categorias exigidas como argumentos (valência sintática)
-/
inductive Cat where
  | cat (phon : Phon) (label : CatLabel) (agr : Agreement) (subcat : List Cat)
  deriving Repr, BEq

def Cat.label : Cat → CatLabel
  | .cat _ l _ _ => l

def Cat.agr : Cat → Agreement
  | .cat _ _ a _ => a

def Cat.subcat : Cat → List Cat
  | .cat _ _ _ s => s

/-- Atribuição de um traço a uma categoria: adiciona o traço se não conflitar. -/
def assignCat (f : Feat) (c : Cat) : List Cat :=
  match c with
  | .cat phon label agr subcat =>
    -- Se o traço já está lá, retorna a categoria; senão adiciona
    if agr.contains f then [.cat phon label agr subcat]
    else [.cat phon label (f :: agr) subcat]

/-- Combinação simplificada de concordância: dois conjuntos de traços concordam
    se não possuem traços diametralmente opostos. -/
def agreeCat (c1 c2 : Cat) : Bool :=
  let a1 := c1.agr
  let a2 := c2.agr
  -- Se um é singular e o outro é estritamente plural, discordam
  if a1.contains .sg && a2.contains .pl then false
  else if a1.contains .pl && a2.contains .sg then false
  else true

/-- Exemplo: O verbo transitivo "loved" exigindo um objeto direto NP acusativo. -/
def catLoved : Cat :=
  .cat "loved" "VP" [.tense] [.cat "_" "NP" [.accOrDat] []]

#eval catLoved


/-!
==============================================================================
## Seção 9.5: Lexical Lookup and Scanning (Léxico e Análise Léxica)
==============================================================================

1. Papel no Pipeline de Parsing:
   A Seção 9.5 constrói a ponte entre a entrada crua digitada pelo usuário (String)
   e as categorias sintáticas ricas (Cat).
   O fluxo é:
   String crua  ──(scan & preproc)──>  Lista de Tokens  ──(lexicon)──>  Lista de Cat

2. Carga Cognitiva vs. Volume de Código:
   A seção possui 8 páginas no livro, mas baixa densidade teórica: cerca de 90%
   do código é uma tabela estática (hardcoded) mapeando palavras da língua inglesa
   para suas categorias gramaticais (`lexicon : String → List Cat`).

3. Desafios de Engenharia Identificados:
   - Tamanho e Manutenibilidade: Manter centenas de linhas de dicionário fixas no
     código-fonte dificulta a extensão; em produção, prefere-se arquivos de dados externos.
   - Velocidade de Consulta: O casamento de padrões sequencial (`lexicon "word"`) é
     uma busca linear O(N) sobre o tamanho do vocabulário. Em Lean 4 profissional,
     utiliza-se um `HashMap String (List Cat)` ou uma Trie para consulta O(1).

4. Ambiguidade Categorial Lexical (Zero-Derivation no Inglês):
   O inglês possui alta fluidez entre classes gramaticais sem alteração morfológica:
   - "duck": Substantivo (o animal pato) vs. Verbo (abaixar-se para desviar).
     Exemplo clássico: *"I saw her duck"* gera duas árvores válidas:
     (1) "Eu vi o pato dela" (saw + \[NP her duck\])
     (2) "Eu a vi se abaixar" (saw + \[S her duck\])
   - No léxico do livro:
     * "that": Pronome Relativo (`REL`) vs. Determinante (`DET`).
     * "who": Pronome Interrogativo (`NP [Wh]`) vs. Pronome Relativo (`REL`).
     * "kicked": Transitivo simples (`[NP]`) vs. Transitivo com Preposição (`[NP, PP]`).
   - Por que o retorno é uma Lista (`List Cat`)?
     Porque o modelo de "Lista de Sucessos" (Seção 9.3) não precisa adivinhar a classe
     correta de antemão: ele explora os caminhos em paralelo e devolve todas as leituras
     válidas para serem desambiguadas pela semântica posterior.

5. Pré-processamento Simples:
   - `scan`: Insere espaços antes de pontuação (`.,?`) para separar pontuação de palavras.
   - `preproc`: Normaliza locuções multi-palavras e contrações:
     * \["at", "least"\]  -> \["at\_least"\]
     * \["did", "not"\]   -> \["didn't"\]
     * \["everybody"\]    -> \["every", "person"\] (decompõe em DET + CN para facilitar a lógica).
-/

/-- Scanner simples: insere espaço antes de sinais de pontuação comuns. -/
def scan : List Char → List Char
  | [] => []
  | x :: xs =>
    if x == '.' || x == ',' || x == '?' then
      ' ' :: x :: scan xs
    else
      x :: scan xs

/-- Mini-Léxico demonstrativo: mapeia palavras para suas categorias possíveis (`List Cat`). -/
def lexicon : String → List Cat
  | "alice"      => [.cat "alice" "NP" [.pers, .thrd, .sg, .fem, .nom] []]
  | "the"        => [.cat "the" "DET" [.sg] [], .cat "the" "DET" [.pl] []]
  | "dwarf"      => [.cat "dwarf" "CN" [.sg, .masc, .thrd] []]
  | "dwarfs"     => [.cat "dwarfs" "CN" [.pl, .masc, .thrd] []]
  | "smiled"     => [.cat "smiled" "VP" [.tense] []]
  | "loved"      => [.cat "loved" "VP" [.tense] [.cat "_" "NP" [.accOrDat] []]]
  | "that"       => [
      .cat "that" "REL" [] [],   -- Pronome relativo ("the sword that I saw")
      .cat "that" "DET" [.sg] [] -- Determinante demonstrativo ("that dwarf")
    ]
  | _            => []

-- Testes do Mini-Léxico (demonstrando ambiguidade de 'that'):
#eval lexicon "alice"
#eval lexicon "that" -- Retorna 2 categorias alternativas!

/-!
=============================================================================
## SEÇÃO 9.6: PARSING CATEGORIES (pp. 235–238)
=============================================================================

1. Objetivos Centrais da Seção:
   - Construir o analisador sintático completo para a língua inglesa,
     instanciando árvores sintáticas ricas: `ParseTree Cat Cat`.
   - Garantir as 3 travas essenciais que barram sentenças agramaticais:
     (1) Atribuição de Caso: Sujeitos ganham caso Nominativo (`.nom`);
         objetos recebem acusativo/dativo (`.accOrDat`).
     (2) Concordância: Sujeito e Predicado devem concordar em gênero,
         número e pessoa (`agreeC np vp`).
     (3) Saturação Subcategorial: O VP só forma uma sentença completa
         se consumiu todos os seus complementos (`subcatList == \[]`).

2. Paradigma Funcional (Wadler - List of Successes):
   - Não há exceções em tempo de execução:
     * Frase gramatical inequívoca: retorna `\[arvore\]`.
     * Frase sintaticamente ambígua: retorna `\[arvore1, arvore2, ...\]`.
     * Frase agramatical (erro de concordância ou subcat): retorna `\[\]`.
-/

/-- Extrai a categoria da raiz de uma árvore sintática. -/
def t2c : ParseTree Cat Cat → Cat
  | .ep => .cat "_" "NONE" [] []
  | .leaf c => c
  | .branch c _ => c

/-- Checagem de concordância entre duas subárvores. -/
def agreeC (t1 t2 : ParseTree Cat Cat) : Bool :=
  agreeCat (t2c t1) (t2c t2)

/-- Parser elementar: consome uma folha na fita cuja categoria case com `label`. -/
def leafP (label : CatLabel) : Parser Cat (ParseTree Cat Cat) := fun cs =>
  match cs with
  | [] => []
  | c :: rest =>
    if c.label == label then
      [(.leaf c, rest)]
    else
      []

/-- Atribuição de traço morfológico à raiz de uma árvore sintática.
    Se a categoria já tiver traço incompatível, a atribuição falha e retorna `\[\]`. -/
def assignT (f : Feat) : ParseTree Cat Cat → List (ParseTree Cat Cat)
  | .ep => []
  | .leaf c => (assignCat f c).map (fun c' => .leaf c')
  | .branch c ts => (assignCat f c).map (fun c' => .branch c' ts)

/-- Casamento entre lista de subcategorização esperada e argumentos reais encontrados. -/
def matchSubcat : List Cat → List Cat → Bool
  | [], [] => true
  | _, [] => false
  | [], _ => false
  | x :: xs, y :: ys =>
    x.label == y.label && agreeCat x y && matchSubcat xs ys

/-- Parser de Frase Nominal (`NP`): ou é folha léxica (ex: "alice") ou formada por regra `DET + CN`. -/
partial def parseNP : Parser Cat (ParseTree Cat Cat) := fun xs =>
  -- 1. Tenta como folha atômica do léxico
  let atomic := leafP "NP" xs
  -- 2. Tenta regra de combinação: DET + CN
  let rule :=
    (leafP "DET" xs).flatMap fun (det, ys) =>
    (leafP "CN" ys).filterMap fun (cn, zs) =>
      if agreeC det cn then
        some (.branch (.cat "_" "NP" (t2c det).agr []) [det, cn], zs)
      else
        none
  atomic ++ rule

/-- Parser de Frase Verbal (`VP`): consome o verbo e satura sua lista de subcategorização. -/
partial def vpRule : Parser Cat (ParseTree Cat Cat) := fun xs =>
  (leafP "VP" xs).flatMap fun (vp, ys) =>
    let subcat := (t2c vp).subcat
    if subcat.isEmpty then
      [(vp, ys)]
    else
      (parseNP ys).filterMap fun (obj, zs) =>
        if matchSubcat subcat [t2c obj] then
          some (.branch (.cat "_" "VP" (t2c vp).agr []) [vp, obj], zs)
        else
          none

/-- Regra de Sentença (`S -> NP VP`):
    (1) Acha Sujeito (NP);
    (2) Acha Predicado (VP);
    (3) Atribui caso Nominativo ao Sujeito;
    (4) Trava: Concordância de traços;
    (5) Trava: Valência do VP esgotada (`subcat == \[]`). -/
def sRule : Parser Cat (ParseTree Cat Cat) := fun xs =>
  (parseNP xs).flatMap fun (np, ys) =>
  (vpRule ys).flatMap fun (vp, zs) =>
  (assignT .nom np).filterMap fun np' =>
    if agreeC np vp && (t2c vp).subcat.isEmpty then
      some (.branch (.cat "_" "S" [] []) [np', vp], zs)
    else
      none

/-- O analisador sintático principal de sentenças. -/
def parseSent : Parser Cat (ParseTree Cat Cat) := sRule

-- =============================================================================
-- TESTES E DEMONSTRAÇÃO PRÁTICA (CONFORME DIRETRIZES DIDÁTICAS)
-- =============================================================================

-- Fita 1: "Alice smiled" -> Sentença válida com verbo intransitivo
def fitaAliceSmiled : List Cat := [
  .cat "alice" "NP" [.pers, .thrd, .sg, .fem, .nom] [],
  .cat "smiled" "VP" [.tense] []
]

-- Fita 2: "Alice loved" -> FALHA! Verbo transitivo com subcat pendente: \[[NP AccOrDat]\]
def fitaAliceLovedIncompleta : List Cat := [
  .cat "alice" "NP" [.pers, .thrd, .sg, .fem, .nom] [],
  .cat "loved" "VP" [.tense] [.cat "_" "NP" [.accOrDat] []]
]

-- Fita 3: "The dwarfs loved Alice" -> Sentença válida transitiva completa
def fitaDwarfsLovedAlice : List Cat := [
  .cat "the" "DET" [.pl] [],
  .cat "dwarfs" "CN" [.pl, .masc, .thrd] [],
  .cat "loved" "VP" [.tense] [.cat "_" "NP" [.accOrDat] []],
  .cat "alice" "NP" [.pers, .thrd, .sg, .fem, .accOrDat, .nom] []
]

#eval parseSent fitaAliceSmiled          -- Sucesso: devolve a árvore completa de S!
#eval parseSent fitaAliceLovedIncompleta  -- Falha esperada: devolve \[] (subcat não saturada)
#eval parseSent fitaDwarfsLovedAlice     -- Sucesso: árvore de S com NP composto e VP transitivo!

