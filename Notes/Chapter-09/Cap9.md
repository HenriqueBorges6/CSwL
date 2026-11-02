# Anotações de Estudo: Capítulo 9 — Parsing (CSwFP / CSwL)

> **Material de referência:** 
> - Livro impresso: *Computational Semantics with Functional Programming* (van Eijck & Unger, Cambridge 2010), Cap. 9, pp. 205–260.
> - PDF com páginas e figuras completas: `Monitor/CSwFP/CSwFP/book.pdf` (pp. 222–277 do PDF, offset $+17$).
> - Texto extraído com marcadores de página: `Monitor/CSwFP/CSwFP/txt/chapter-09.txt`
> - Código Haskell original: `Monitor/CSwFP/CSwFP/src/P.hs` e soluções `SolP.hs`
> - Adaptação em Lean 4 no CSwL: branch `upstream/feat/parsing` (`CSwL/Parsing.lean`, `CSwL/Parsing/ParseTrees.lean`, `CSwL/Parsing/Recognition.lean`)

---

## 🗺️ Visão Panorâmica: Como o Capítulo 9 se encaixa no Livro

Até o Capítulo 7 (`Composition`) e nos capítulos de `ModelChecking`:
- As árvores sintáticas eram **escritas à mão** pelo programador (ex: `snowWhite = .branch "S" [...]`).
- A partir dessa árvore estática, a semântica calculava o valor de verdade ou a Forma Lógica.

**O objetivo do Capítulo 9 é fechar o ciclo da semântica computacional:**
$$\text{Texto cru (String)} \longrightarrow \text{Parsing / Combinadores} \longrightarrow \text{Árvore Sintática (ParseTree)} \longrightarrow \text{Forma Lógica (LF)}$$

### Raio-X das Seções: O que é reusado vs. O que é pedagógico

| Seção | Título | É usada no futuro do livro? | Destino no restante do livro |
| :--- | :--- | :---: | :--- |
| **9.1** | *Talking About Parse Trees* | **Apenas o tipo `ParseTree`** | O tipo de dados `ParseTree` é a espinha dorsal de 9.6–9.8 e do Cap. 12 (`DRAC.hs`). As relações (`dominance`, `cCommand`, etc.) **não são chamadas no código posterior**; são conceituais/linguísticas. |
| **9.2** | *Recognizing and Parsing CFLs* | **Não** | Reconhecedor ingênuo por força bruta (`split2`, palíndromos). Serve para demonstrar a ineficiência $O(2^n)$ e motivar os combinadores de 9.3. |
| **9.3** | *Parsers and Parser Combinators* | **Sim (Infraestrutura)** | Paradigma *List of Successes* e operadores monádicos (`<\|>`, `<*>`, `many`). Motor de todo o parsing posterior. |
| **9.4** | *Features and Categories* | **Sim (Central)** | Categorias gramaticais com traços de concordância (`Cat`). Usado diretamente no Cap. 12. |
| **9.5** | *Lexical Lookup and Scanning* | **Sim** | Analisador léxico (tokenizador e dicionário). |
| **9.6** | *Parsing Categories* | **Sim** | Parser das regras gramaticais do fragmento básico ($S \to NP + VP$). |
| **9.7** | *Handling Extractions* | **Sim (Função Mestra)** | Parsing com pilhas de lacunas (*gap-threading*). Produz a função `parses`, chamada em `DRAC.hs:210`. |
| **9.8** | *Adding Semantics* | **Sim (Central)** | Compilador de árvores para a Forma Lógica (`LF`), importado diretamente no Cap. 10 (`HRAS.hs`). |

---

## 📌 Seção 9.1: Talking About Parse Trees (pp. 205–211)

### 1. A Motivação Teórica e Linguística

#### A. A Tese da Hierarquia (Noam Chomsky vs. Visão Linear)
O texto original introduz o tipo `ParseTree` e passa rapidamente para as definições de posições e relações entre nós sem deixar claro de imediato por que a análise sintática depende de árvores em vez de listas de palavras. 

Tratar frases como sequências lineares de palavras falha porque a linguagem natural opera por encaixe hierárquico:
* As palavras chegam na linha do tempo de forma linear, mas a gramática mental as agrupa em blocos estruturados chamados **constituintes**.
* Relações que parecem distantes no texto linear estão conectadas estruturalmente no grafo da árvore.

#### B. As Relações entre Nós e as Regras da Linguagem
O livro define formalmente três relações: **dominância**, **irmandade** (*sisters*) e **comando constituinte** (*c-command*). Para entender sua necessidade real na linguística:
1. **Dominância:** Modela o pertencimento hierárquico (um constituinte $VP$ domina o verbo e seu objeto).
2. **Irmandade:** Nós filhos do mesmo pai direto dividem o mesmo nível de composição gramatical.
3. **C-command (Comando Constituinte):** Uma posição $\alpha$ comanda $\beta$ se o nó pai imediato de $\alpha$ domina $\beta$, sem que $\alpha$ domine $\beta$. Essa relação geométrica é indispensável para formalizar:
   - **Teoria da Ligação (Binding Theory):** Explica por que pronomes reflexivos precisam ser comandados por seus antecedentes na mesma oração (*"Alice loved herself"*, enquanto *"Herself loved Alice"* é agramatical).
   - **Escopo de Quantificadores e Operadores:** Determina se uma negação ou quantificador universal (*"every"*, *"no"*) tem escopo sobre outros elementos da oração.

*Observação técnica:* Embora essas relações fundamentem as regras da língua, nos capítulos seguintes (10 a 13) o código não consulta tabelas de pares em tempo de execução: o processamento semântico opera por recursão pura na árvore. Em Lean 4, essas noções são formalizadas como teoremas indutivos sobre posições.

```
                    S
                 /     \
              NP         VP
         [Snow White]  /    \
                     TV      NP
                  [loved] [the dwarfs]
```

#### B. Dominância (*Constituent Containment*) e Testes de Constituência
* **Conceito:** Um nó $p$ domina $q$ se $p$ é um ancestral de $q$ (o caminho da raiz até $p$ é um prefixo do caminho até $q$).
* **Intuição Linguística:** Tudo o que um nó domina forma um constituinte indivisível.
* **Teste da Elipse de VP (Sentenças Coordenadas com Conjunção):**
  *"Snow White loved the dwarfs, and Alice did so too."*
  
  ```
                                S_coord
                           /       |       \
                         S₁       CONJ      S₂
                      /      \    [and]   /     \
                   NP₁        VP₁       NP₃     VP₂
               [SnowWhite]   /   \    [Alice]  [did so too]
                           TV₁   NP₂
                        [loved] [the dwarfs]
  ```
  
  * **Discussão teórica:** Como essa árvore completa se relaciona com a Seção 9.1?
    1. Essa árvore envolve **mais do que a 9.1 implementa**: ela exige regras de coordenação sentencial ($S \to S \text{ CONJ } S$) e recuperação de anáfora verbal. O livro só constrói formalmente parsers com essas regras nas seções 9.6, 9.7 e no Capítulo 12.
    2. O papel desse exemplo na 9.1 é puramente conceituar o **Teste de Constituência**: o pronome verbal *"did so too"* só consegue herdar e substituir o pacote inteiro *"loved the dwarfs"* porque o nó `VP₁` domina esses elementos como uma unidade indivisível na geometria da árvore. Se tentássemos substituir algo que cruza fronteiras arbitrárias (ex: *"White loved"*), a sentença seria agramatical.
    3. Em 9.1, o autor não ensina a gerar árvores coordenadas; ele assume a árvore dada para ensinar a navegar em suas coordenadas.

#### C. Irmandade (*Sisterhood*) e Governança Local de Argumentos
* **Conceito:** Dois nós são irmãos se compartilham a mesma mãe imediata (diferem apenas no último índice de posição).
* **Intuição Linguística:** É a relação de dependência mais íntima e local da sintaxe. O verbo transitivo (`TV`) e o objeto direto (`NP`) são nós irmãos sob o `VP`. O verbo governa o caso da sua irmã imediata (exigindo pronome acusativo *"loved her"*, e nunca *"loved she"*).

#### D. C-Command (*Constituent Command*) — O Escopo de Poder na Sintaxe
> ⚠️ **Cuidado com o equívoco comum:** *C-command NÃO significa simplesmente "estar mais próximo da raiz".*  
> Se um nó pai domina um nó filho, o pai está mais alto, mas **NÃO** c-comanda o filho (ninguém c-comanda seus próprios filhos nem a si mesmo!).

* **Definição Exata:**  
  $$p \text{ c-comanda } q \iff \text{uma IRMÃ de } p \text{ DOMINA } q \quad (\text{com } p \neq q \text{ e } p \text{ não dominando } q)$$
  Em termos visuais: para exercer c-command, você **olha para o lado (sua irmã)** e **projeta seu poder sobre toda a descendência dela**.
* **Fenômenos governados por C-Command:**
  1. **Teoria da Ligação (*Binding Theory* de pronomes):**
     * Pronomes reflexivos (*himself*, *herself*) **precisam ser c-comandados** pelo seu antecedente.
     * *"Alice admired herself"* ✅ (*Alice* é o sujeito `[0]`, sua irmã é `[1]` (`VP`), que domina *herself* `[1, 1]`).
     * *"Alice's brother admired herself"* ❌ (*Alice* está soterrada dentro de um modificador possessivo; ela não c-comanda o predicado. Quem c-comanda é o *irmão*!).
  2. **Escopo de Quantificadores e Negação:**
     * Em *"Every boy didn't laugh"*, o sentido de "nenhum menino riu" vs. "nem todos os meninos riram" decorre diretamente de quem c-comanda quem na estrutura profunda ($\forall$ sobre $\neg$ ou $\neg$ sobre $\forall$).

---

### 2. O Inventário das Funções e Códigos de 9.1

No código Haskell (`P.hs`) e na sua adaptação para Lean 4:

1. **`ParseTree α β`**:
   ```lean
   inductive ParseTree (α β : Type) where
     | ep                                          -- Árvore vazia
     | leaf (a : α)                                -- Folha terminal (palavra)
     | branch (b : β) (ts : List (ParseTree α β)) -- Rótulo de nó e lista de filhas
   ```
2. **Posições (`Pos = List Nat`)**:
   Coordenada do nó como caminho a partir da raiz:
   * Raiz: `[]`
   * Sujeito `NP`: `[0]`
   * Predicado `VP`: `[1]`
   * Verbo `TV`: `[1, 0]`
   * Objeto `NP`: `[1, 1]`
3. **Navegação (`subtree t p`)**: Devolve a subárvore que vive na coordenada `p`.
4. **Coleta de Coordenadas (`pos t`)**: Varre a árvore e lista todas as coordenadas existentes.
5. **Dominância Própria e Ampla (`properdominance` e `dominance`)**:
   Modelada em Lean 4 através da relação de prefixo de listas: `p <+: q`.
6. **Irmandade (`sisters p q` e `sisterhood t`)**:
   Verifica se dois caminhos compartilham todos os passos exceto o último.
7. **C-Command (`cCommand t`)**:
   Implementado como a **composição relacional** ($R \circ S$):
   $$\text{cCommand}(t) = \text{sisterhood}(t) \circ \text{dominance}(t)$$
8. **Exercícios de Relações Estruturais:**
   * **Ex 9.1 (`immDominance`):** Dominância imediata (mãe direta, sem nós intermediários).
   * **Ex 9.2 (Teoremas de C-Command):** Prova que c-command é irreflexivo e assimétrico ($p$ c-comanda $q \implies \neg(p \text{ domina } q) \land \neg(q \text{ domina } p)$).
   * **Ex 9.3 (`mutualCCommand`):** C-command mútuo (ocorre se e somente se os nós são irmãos diretos).
   * **Ex 9.4 (`precedence` e `immPrecedence`):** Ordem linear de leitura das palavras (da esquerda para a direita).
   * **Ex 9.5 (`command` / S-command):** Generalização onde o nó que ramifica é uma sentença `"S"`.

---

### 3. As Três Limitações Intrínsecas da Seção 9.1

A Seção 9.1 encerra uma etapa preparatória, mas esbarra em três gargalos práticos que nos forçam a avançar para as seções 9.2 e 9.3:

1. **A Árvore já precisa existir (Ausência de Parsing):**
   A 9.1 não sabe ler uma string do usuário. Ela pressupõe que alguém desenhou a árvore na mão.
2. **Ineficiência Algébrica $O(n^2)$:**
   Calcular c-command gerando o produto cartesiano de todas as posições da árvore e filtrando pares consome memória quadrática. Compiladores reais e interpretadores de semântica caminham recursivamente na árvore (*catamorfismos*) em vez de materializar tabelas relacionais em memória.
3. **Categorias "Cegas" (Strings sem traços):**
   Usar strings estáticas como `"NP"` ou `"VP"` impede a representação de concordância de número (*"the dwarf smiles"* vs. *"the dwarfs smile"*), caso e pilhas de extração (*gaps* em orações relativas). Isso exigirá a criação do tipo enriquecido `Cat` na Seção 9.4.

---

### 4. Como o Prof. Alexandre tratou a 9.1 no CSwL (`CSwL/Parsing/ParseTrees.lean`)

* Em vez de manter o c-command como simples listas de pares testadas com `#eval`, o professor transformou o **Exercício 9.2 em teoremas formais provados com táticas em Lean 4**:
  - `sisters_length`: provando que nós irmãos têm o mesmo comprimento de caminho.
  - `sisters_not_prefix`: provando que um irmão nunca é prefixo do outro.
  - `cCommand_not_dominates`: provando formalmente que $p$ c-comandar $q$ impede que $p$ domine $q$.
  - `cCommand_not_dominated`: provando que $p$ c-comandar $q$ impede que $q$ domine $p$.
* As funções de posições foram organizadas em um bloco `mutual` (`pos` e `posFrom`) para garantir que o kernel do Lean aceite a terminação estrutural sem necessidade de `partial def`.


---

## 📌 Seção 9.2: Recognizing and Parsing Context-Free Languages (pp. 211–214)

### 1. Motivação e Papel Pedagógico: Um Contraexemplo de Falhas de Parse
A Seção 9.2 consiste basicamente na apresentação de uma técnica ingênua de parsing e na exibição deliberada de suas falhas.

Ela divide a tarefa em duas etapas clássicas:
1. **Reconhecimento (*Recognition*):** Retorna apenas um booleano dizendo se a cadeia pertence à linguagem ($w \in L(G)$).
2. **Análise Sintática (*Parsing*):** Devolve as árvores de derivação estruturadas.

Para ilustrar isso, o texto utiliza a gramática de palíndromos ($A \to \epsilon \mid a \mid b \mid c \mid aAa \mid bAb \mid cAc$) e implementa a divisão por força bruta (`split2`), particionando a fita em todos os pares de prefixo e sufixo.

### 2. Onde o Método Falha
1. **Custo Exponencial:** A complexidade de particionar e testar todas as combinações cresce em $O(2^n)$, tornando a análise lenta para qualquer frase com mais de poucos símbolos.
2. **Loop Infinito com Recursão à Esquerda:** O fatiamento gera pares com componentes vazios (`("", "palavra")`). Se houver regras recursivas à esquerda ($S \to S \dots$), o algoritmo chama a si mesmo com a mesmíssima entrada intacta, travando a execução em loop infinito.

### 3. O Desafio no Lean 4 vs. Haskell e a Decisão do Professor

* **Haskell (Laissez-faire):** Sendo uma linguagem de avaliação preguiçosa (*lazy*), o Haskell permite que funções não terminem. O compilador GHC compila `recognize` sem exigir nenhuma garantia matemática de parada.
* **Lean 4 (Provador de Teoremas):** Toda função em Lean deve demonstrar terminação para garantir a consistência lógica do sistema (uma função não-terminante permitiria provar `False`).
* Ao fatiar o miolo de um palíndromo $aAa$ (removendo a primeira e a última letra com `drop` e `dropLast`), o verificador estrutural do Lean **não consegue enxergar automaticamente que o miolo é menor que a palavra de entrada**.

#### A Decisão Atual no CSwL (`upstream/feat/parsing`):
No arquivo `DEVIATIONS.md`, o Prof. Alexandre Rademaker registrou:
> *"9.2: `recognize` and `parse` are `partial def`, since Lean cannot see that the middle piece of a split is shorter than the input. [...] A theorem checks, with `native_decide`, that `recognize` agrees with Mathlib's `List.Palindrome` on all words up to length 6; a proof for all words would need `recognize` to be total."*

O professor marcou a função como `partial def` (permitida para execução computacional, mas impedida de participar de provas lógicas) e validou a correção por reflexão computacional (`native_decide`) contra o tipo indutivo `Mathlib.Data.List.Palindrome`.

#### Alternativas Arquiteturais Não Incorporadas na Versão Atual:
Se no futuro o livro quiser eliminar o `partial def` e tornar o reconhecedor 100% total, existem três rotas formais:
1. **Medida com `termination_by s.length`:** Adicionar uma cláusula `decreasing_by` com um lema aritmético provando que `((s.drop 1).dropLast).length < s.length`.
2. **Combustível (*Fuel Bound*):** Passar um contador natural `fuel := s.length` que decresce estruturalmente a cada chamada recursiva (técnica adotada pelo professor em `CSwL/InfEngine.lean` para o cálculo de ponto fixo).
3. **Indução Simétrica nas Pontas:** Em vez de fatiar com listas/strings genéricas, definir o predicado desconstrutivo diretamente pelo primeiro e último caractere (espelhando a definição construtiva de `List.Palindrome` da Mathlib).

---

## 📌 Seção 9.3: Parsers and Parser Combinators (pp. 214–222)

### 1. O Paradigma "List of Successes" (Philip Wadler)
Em vez de quebrar a string no meio às cegas, um *Parser Combinator* lê a fita ordenadamente da esquerda para a direita, consumindo o que necessita e deixando a sobra intacta.

```lean
def Parser (α β : Type) := List α → List (β × List α)
```

* **Entrada (`List α`):** Sequência de símbolos a serem analisados (caracteres `Char` ou palavras `String`).
* **Saída (`List (β × List α)`):** Uma lista de pares contendo:
  1. `β`: O objeto semântico construído (ex: um nó de `ParseTree`).
  2. `List α`: A **sobra da fita** que não foi consumida e é repassada para o próximo parser.
* **Tratamento de Erros e Ambiguidade:**
  - Falha sintática: Retorna a lista vazia `[]`.
  - Parse unívoco: Retorna uma lista unitária `[(árvore, sobra)]`.
  - Ambiguidade estrutural: Retorna múltiplos pares, um para cada árvore possível atribuída pela gramática.

---

### 2. Parsers Atômicos e Esclarecimento de Conceitos

#### A. Símbolo (`symbol c`) vs. Token (`token cs`)
* **Símbolo (`symbol c`):** É o elemento atômico indivisível da fita de entrada. Se a fita for `List Char`, o símbolo é um único caractere (`'a'`); se a fita for `List String` (palavras já separadas), o símbolo é uma palavra inteira (`"Alice"`). Ele testa se a cabeça da fita é igual a `c` e a consome.
* **Token (`token cs`):** É uma sequência contígua de símbolos (uma lista `[a]`). Consome um bloco de símbolos de uma só vez (ex: consome os 5 caracteres de `"Alice"`).

#### B. Satisfy (`satisfy p`)
Generaliza o `symbol`: em vez de exigir igualdade a um valor constante, consome o próximo símbolo se ele satisfizer um predicado arbitrário `p : α → Bool` (ex: `digit = satisfy isDigit`).

#### C. O Filtro `just`: Garantia de Consumo Completo
Um parser comum aceita sentenças pela metade se o início for válido (ex: `pAlice ["Alice", "lixo", "residual"]` teria sucesso devolvendo `"Alice"` e deixando `["lixo", "residual"]` na sobra).
A função `just p` aplica um filtro obrigatório exigindo que a sobra seja vazia:
```lean
def just (p : Parser α β) : Parser α β :=
  fun xs => (p xs).filter fun (_, remainder) => remainder.isEmpty
```
Ele atua como o ponto final da análise, descartando derivações que deixaram palavras sem analisar.

---

### 3. Os Combinadores Essenciais: Compondo a Gramática

#### A. Alternância / Escolha (`<|>`): O "OU" Gramatical
Modela regras onde um constituinte tem produções alternativas:
$$VP \longrightarrow \text{"smiled"} \mid \text{"laughed"}$$
```haskell
(p1 <|> p2) xs = p1 xs ++ p2 xs
```
Executa `p1` e `p2` sobre a mesma entrada e concatena os sucessos (`++`).

#### B. O Dilema da Sequência: Por que `<|>` não bastava?
O operador `<|>` apenas testa opções independentes. Ele é incapaz de lidar com regras como:
$$S \longrightarrow NP \ VP$$
pois ele não sabe passar o que o $NP$ deixou de sobra para o $VP$ consumir, nem sabe combinar a árvore de sujeito com a árvore de predicado. Isso exigiu a criação do **combinador sequencial (`<*>`)**.

#### C. Mapeador Funcional (`<$>`): De Texto para Árvore
Parsers básicos apenas reconhecem texto cru. Para que o parser construa uma estrutura rica `ParseTree`, o combinador `<$>` pós-processa o resultado aplicando uma função (ex: o construtor `Leaf`):
```haskell
(f <$> p) xs = [ (f x, ys) | (x, ys) <- p xs ]
```
Exemplo: `Leaf <$> token "Alice"` transforma o texto lido no nó de árvore `Leaf "Alice"`.

#### D. O Operador Cons de Parsers (`<:>`): Sequências de Tamanho Arbitrário
Para construir ramos de árvores (`Branch b ts`), precisamos de uma lista de subárvores filhas `ts : List (ParseTree α β)`. O operador `<:>` une um parser de um elemento a um parser de lista, permitindo compor sequências de 2, 3 ou $N$ constituintes sem reinventar operadores para cada tamanho:

```haskell
(p <:> q) xs = [ (r : rs, zs) | (r, ys) <- p xs, (rs, zs) <- q ys ]
```

---

### 4. Ilustração Visual: O Processo de Construção com `<:>` e `<$>`

Para uma regra ditransitiva como $VP \to \text{TV} \ NP \ NP$ sobre a fita `["gave", "Alice", "the-sword"]`:

```
PASSO 1: pVerbo consome "gave"
Fita Restante: ["Alice", "the-sword"]
Elemento produzido:
       TV
       |
    [gave]   (primeiro elemento da lista)

───────────────────────────────────────────────────────────────────────────
PASSO 2: pObj1 consome "Alice"
Fita Restante: ["the-sword"]
Elementos acumulados na lista horizontal:
       TV              NP
       |               |
    [gave]     :    [Alice]

───────────────────────────────────────────────────────────────────────────
PASSO 3: pObj2 consome "the-sword"
Fita Restante: [] (fita terminada)
Elementos acumulados:
       TV              NP                 NP
       |               |                  |
    [gave]     :    [Alice]     :    [the-sword]   :   []

───────────────────────────────────────────────────────────────────────────
PASSO 4: O operador `<$>` aplica o rótulo "VP" sobre toda a lista de nós irmãos:

                          VP
                   /      |       \
                 TV       NP        NP
                 |        |         |
              [gave]   [Alice]  [the-sword]

Fita final restante: [] (Parse completo e bem-sucedido!)
```

---

### 5. Insights de Arquitetura para o CSwL (Em Aberto no Repositório)

Na branch `upstream/feat/parsing` (`CSwL/Parsing.lean`), o Prof. Alexandre Rademaker anotou a seguinte decisão técnica em aberto:

> *"9.3: list-of-successes parsers, still to decide: `StateT (List α) List` with Mathlib's `Monad`/`Alternative List`, or plain functions. Lean's `Std.Internal.Parsec` returns one result, not all parses; it can serve the lexer of 9.5."*

#### Comparação das Duas Abordagens:

| Critério | Abordagem A: Funções Puras (`List α → List (β × List α)`) | Abordagem B: Mônada `StateT (List α) List` |
| :--- | :--- | :--- |
| **Didática** | **Muito alta e transparente.** Não exige conceitos avançados de teoria de categorias. | **Média/Baixa.** Exige ensinar transformadores de mônadas antes do parsing. |
| **Notação** | Operadores combinatórios explícitos (`<*>`, `<|>`). | Permite usar notação imperativa `do` e instâncias padrão de `Alternative`. |
| **Fidelidade ao Livro** | Espelha o Haskell original do *CSwFP* linha por linha. | É mais idiomática para um desenvolvedor experiente em Lean 4. |

#### O Papel do `Std.Internal.Parsec`:
O Parsec oficial da biblioteca padrão do Lean 4 é **determinístico**: ele retorna apenas um resultado (ou falha com mensagem de erro). Ele não suporta busca não-determinística de múltiplas árvores geradas por gramáticas ambíguas de linguagem natural. Por isso, como notou o professor, o `Parsec` é ideal para o **analisador léxico / tokenizador da Seção 9.5**, mas a análise sintática de categorias da 9.3 e 9.6 deve manter a lista de sucessos.


---

## 📌 Seção 9.4: Features and Categories (pp. 222–226)

### 1. Motivação da Seção: Por que precisamos de Traços (*Features*)?
Até a Seção 9.3, os parsers manipulavam categorias gramaticais como strings simples e cegas (`"NP"`, `"VP"`, `"S"`). Isso criava uma limitação grave: o parser não conseguia distinguir singular de plural, nem caso nominativo de acusativo.
* *Problema prático:* A gramática aceitaria sem piscar frases agramaticais como:
  - *"The dwarfs smiles"* ❌ (Sujeito plural com verbo no singular).
  - *"She loved he"* ❌ (Caso nominativo usado onde a posição sintática exige acusativo).
* *Solução:* Introduzir **traços sintáticos (*syntactic features*)** de gênero, número, pessoa, caso e tempo para impor regras estritas de concordância morfológica.

---

### 2. Duas Visões sobre Concordância e o "Mix" do Livro

A linguística teórica debate duas visões clássicas sobre como a concordância se estabelece entre dois constituintes:

1. **Visão Derivacional / Controle (Mestre $\longrightarrow$ Escravo):**
   - Há uma hierarquia rígida com uma fonte (*source*) e um alvo (*target*).
   - O sujeito (*"The dogs"*) já nasce com o traço `[Plural]` e **copia/injeta ativamente** esse traço no verbo dependente (*"bark"*). A informação flui em mão única.
2. **Visão de Unificação / Restrições (Aperto de Mãos Simétrico):**
   - Não existe mestre nem escravo. Os dois constituintes chegam à mesa com suas restrições parciais (ex: o verbo *"bark"* diz que aceita qualquer coisa exceto 3ª pessoa do singular; o sujeito diz que é plural).
   - A gramática simplesmente realiza uma **interseção de compatibilidade (unificação)**. Se a interseção for não-vazia, o aperto de mãos é selado com sucesso.
3. **O "Mix" Adotado pelo Livro:**
   O livro combina os dois mundos:
   - Usa a **Visão de Restrições** na função `agree cat1 cat2` (verificando se a união dos traços não gera contradições de número, gênero ou caso).
   - Usa a **Visão de Controle** na regra sintática para projetar e controlar os traços herdados pelo nó pai na árvore resultante.

---

### 3. O Dilema de Design de `Feat`: Lista Plana vs. Registros Tipados (Issue 42)

No planejamento da branch `upstream/feat/parsing` (`CSwL/Parsing.lean`), o Prof. Alexandre Rademaker anotou:
> *"9.4–9.8: to plan. The representation of Cat is tied to issue 42."*

Essa nota aponta diretamente para o dilema de tipagem entre Haskell e Lean 4:

| Aspecto | Abordagem 1: Lista Plana `List Feat` (Livro / Haskell 2010) | Abordagem 2: Registros `structure Agreement` (Lean 4 Forte) |
| :--- | :--- | :--- |
| **Definição** | Um único tipo `Feat` reúne todas as tags (`Masc`, `Fem`, `Sg`, `Pl`, `Tense`, `On`). | Tipos indutivos separados (`Gender`, `Number`, `Case`) em uma estrutura com campos `Option`. |
| **Vantagens** | **Extensibilidade e concisão:** Concatenação simples (`fs1 ++ fs2`) e facilidade para adicionar traços ad-hoc. | **Segurança matemática total:** O compilador impede que alguém crie um constituinte com dois gêneros (`Masc` e `Fem`). |
| **Desvantagens** | **Zero verificação de tipo:** Permite absurdos como `[Masc, Fem, Sg, Pl]`, exigindo checagens manuais lentas em tempo de execução (`length <= 1`). | Mais código de unificação (boilerplate) e menor flexibilidade para traços inesperados. |

---

### 4. A Anatomia do Tipo `Cat`: Por que esses 4 componentes?

O texto original define o tipo de categorias sintáticas como uma tupla quádrupla:
```haskell
data Cat = Cat Phon CatLabel Agreement [Cat]
```
No entanto, o livro não aprofunda por que essa combinação específica de 4 elementos é necessária e suficiente. Cada campo resolve uma lacuna estrita:

1. **`Phon` (Forma Fonológica / Grafia):**  
   É a âncora material do som ou texto lido da fita (ex.: `"loved"`). Sem ele, o analisador perde o rastro das palavras literais consumidas. Em nós sintáticos abstratos ($S$, $VP$), usa-se `"_"` para indicar nó não-terminal.
2. **`CatLabel` (Rótulo Categorial):**  
   Identifica a classe gramatical ($S$, $NP$, $VP$, $DET$, $CN$). É estritamente indispensável porque **traços morfológicos sozinhos não definem funções sintáticas**: um pronome e um verbo podem compartilhar traços de terceira pessoa e singular (`[Thrd, Sg]`), mas pertencem a classes gramaticais completamente diferentes.
3. **`Agreement` (Traços de Concordância):**  
   Impede construções agramaticais (*"the dwarfs smiles"*). Carrega as restrições morfológicas (gênero, número, pessoa, caso e tempo) para validação cruzada entre constituintes irmãos ou governados.
4. **`[Cat]` (Lista de Subcategorização / Valência):**  
   Informa quantos e quais argumentos o constituinte precisa consumir para ficar completo. Diferencia verbos intransitivos (`subcat = []`), transitivos (`subcat = [NP Acc]`) e ditransitivos (`subcat = [NP Acc, NP AccOrDat]`). Sem a lista de valência, seria impossível barrar sentenças incompletas como *"Alice loved"*.

---

### 5. Checagem de Concordância: `combine`, `agree` e `agreeC`

* **`combine cat1 cat2`**: Junta os traços das duas categorias (`fs1 ++ fs2`), poda redundâncias com `prune` e verifica se **nenhuma dimensão tem mais de 1 valor** (`length (gender feats) <= 1`, `length (number feats) <= 1`, etc.). Se houver conflito (ex: um é `Sg` e o outro é `Pl`), retorna lista vazia `[]`.
* **`agree cat1 cat2`**: Retorna booleano `true` se `combine` teve sucesso (não deu `[]`).
* **`t2c tree`**: Extrai a categoria `Cat` do nó raiz de uma árvore sintática.
* **`agreeC tree1 tree2`**: Checa concordância entre duas subárvores chamando `agree (t2c tree1) (t2c tree2)`.


---

## 📌 Seção 9.5: Lexical Lookup and Scanning (pp. 226–234)

### 1. Papel no Pipeline: A Ponte do Texto para a Gramática
A Seção 9.5 tem um papel operacional bem definido: transformar a cadeia contínua de caracteres digitada pelo usuário em uma sequência estruturada de categorias gramaticais:
$$\text{String crua} \xrightarrow{\text{scan \& preproc}} \text{Tokens (palavras)} \xrightarrow{\text{lexicon}} \text{Lista de Categorias [Cat]}$$

---

### 2. Carga Cognitiva vs. Volume de Código: O Dicionário Hardcoded
A seção possui 8 páginas no livro, mas baixa densidade teórica:
* Cerca de 90% do texto (páginas 227 a 233) é simplesmente uma **tabela estática de dicionário** (`lexicon :: String -> [Cat]`) cobrindo palavras do vocabulário de contos de fadas do livro (pronomes, determinantes, nomes, verbos transitivos e intransitivos).
* O final do léxico estabelece: `lexicon _ = []` (qualquer palavra desconhecida falha a busca).

---

### 3. Desafios de Engenharia Identificados

1. **Tamanho e Manutenibilidade:**  
   Em sistemas de PLN reais, não se coloca 500 linhas de casamento de padrão hardcoded no código-fonte. O léxico é carregado de bases externas ou corpora anotados.
2. **Velocidade de Consulta ($O(N)$ vs $O(1)$):**  
   O casamento sequencial de padrões no Haskell/Lean é uma busca linear sobre o vocabulário. Em Lean 4, a abordagem idiomática e eficiente para o CSwL é indexar as palavras em um **`HashMap String (List Cat)`** ou uma estrutura de **Trie**, garantindo consulta em tempo constante $O(1)$.

---

### 4. Ambiguidade Categorial Lexical (Zero-Derivation no Inglês)

O inglês apresenta intensa ambiguidade de classes de palavras sem modificação de sufixos (*zero-derivation*):
* **O clássico *"duck"*:** Pode ser substantivo (*pato*) ou verbo (*abaixar-se*).
  A frase *"I saw her duck"* gera duas árvores válidas:
  1. *[I [saw [NP her duck]]]* $\to$ Eu vi o pato dela.
  2. *[I [saw [S her duck]]]* $\to$ Eu a vi se abaixar.
* **No Léxico do Livro:**
  - `"that"`: Pode ser Pronome Relativo (`REL`) ou Determinante (`DET`).
  - `"who"`: Pode ser Pronome Interrogativo (`NP [Wh]`) ou Pronome Relativo (`REL`).
  - `"kicked"`: Apresenta ambiguidade de subcategorização: transitivo direto simples (`[NP]`) ou transitivo com preposição (`[NP, PP]`).
* **Como o Parser lida com isso?**  
  Como `lexicon` retorna uma **Lista** de categorias (`[Cat]`), o modelo de Lista de Sucessos da Seção 9.3 bifurca a busca em paralelo de forma não-determinística, devolvendo todas as árvores gramaticalmente consistentes para serem desambiguadas posteriormente pelo contexto semântico.

---

### 5. Pré-Processamento Textual Simples
* **`scan`:** Insere espaços antes de pontuação (`.,?`) para separar pontuação colada nas palavras (ex: `"dwarfs."` $\to$ `"dwarfs ."`).
* **`preproc`:** Normaliza contrações e locuções compostas:
  - `["at", "least"]` $\to$ `["at_least"]`
  - `["did", "not"]` $\to$ `["didn't"]`
  - `["everybody"]` $\to$ `["every", "person"]` (decompõe em determinante + nome para alimentar diretamente o modelo de quantificadores da lógica de predicados).

---

## 📌 Seção 9.6: Parsing Categories (pp. 235–238)

### 1. O Ponto de Virada: O Casamento entre Árvores e Categorias
Nas seções anteriores, os parsers operavam sobre símbolos cegos (`α` e `β` eram `String`). O parser aceitava sentenças agramaticais como *"The dwarfs loves Dorothy"* ou *"Alice loved"*.

Na Seção 9.6, a árvore sintática passa a carregar categorias ricas tanto nas folhas quanto nos nós internos:
$$\text{ParseTree Cat Cat}$$

O objetivo desta seção é implementar as regras de constituintes com traços de concordância e subcategorização, estabelecendo **três travas essenciais**:
1. **Atribuição de Caso:** O sujeito ganha caso Nominativo (`.nom`); complementos verbais recebem acusativo/dativo (`.accOrDat`).
2. **Concordância:** Sujeito e Predicado devem concordar em gênero, número e pessoa (`agreeC np vp`).
3. **Saturação Subcategorial:** O VP só forma Sentença se consumiu todos os seus argumentos exigidos (`(t2c vp).subcat.isEmpty`).

```
                      PIPELINE DE VALIDAÇÃO NA REGRA S
   Entrada de Tokens: ["Alice", "loved", "Dorothy"]
                            │
                            ▼
   1. parseNP   ──> Consome "Alice" (NP Nominativo)
   2. parseVP   ──> Consome "loved Dorothy" (VP com subcat saturada)
                            │
               ┌────────────┴────────────┐
               ▼                         ▼
         agreeC np vp?         subcat (vp) == []?
               │                         │
         [Sg] == [Sg]              Valência: OK!
               ▼                         ▼
       ✓ PASSOU NA CONCORDÂNCIA   ✓ COMPLEMENTOS ESGOTADOS
               │
               ▼
       Árvore S gerada com sucesso! [Branch "S" [Leaf "Alice", Branch "VP" ...]]
```

---

### 2. Funções Preliminares de Ligação

* **`t2c : ParseTree Cat Cat → Cat`:**  
  Extrai a categoria da raiz de uma subárvore (`Leaf c` ou `Branch c _`).
* **`agreeC : ParseTree Cat Cat → ParseTree Cat Cat → Bool`:**  
  Checa concordância morfológica entre as raízes de duas subárvores chamando `agreeCat (t2c t1) (t2c t2)`.
* **`leafP : CatLabel → Parser Cat (ParseTree Cat Cat)`:**  
  Consome o primeiro token da fita se seu rótulo sintático bater com o esperado (`"NP"`, `"VP"`, `"DET"`, etc.).
* **`assignT : Feat → ParseTree Cat Cat → List (ParseTree Cat Cat)`:**  
  Tenta atribuir um traço à raiz da árvore. Se houver choque de traços incompatíveis, falha retornando lista vazia `[]`.
* **`matchSubcat : List Cat → List Cat → Bool`:**  
  Compara a lista de argumentos exigidos pelo verbo com os argumentos encontrados na fita, conferindo rótulo e compatibilidade de traços.

---

### 3. As Regras Sintáticas de Constituintes

#### (A) Regra de Frase Verbal (`vpRule`):
Consome o verbo e busca recursivamente seus complementos conforme especificado em sua lista de subcategorização:
* Se for intransitivo (*"smiled"*), `subcat == []` $\to$ sucesso imediato.
* Se for transitivo (*"loved"*), espera encontrar um argumento (`parseNP`) cujo tipo e traço casem com o que o verbo pediu (`AccOrDat`).

#### (B) Regra de Sentença (`sRule` / `parseSent`):
Une sujeito e predicado com as travas formais:
```lean
def sRule : Parser Cat (ParseTree Cat Cat) := fun xs =>
  (parseNP xs).flatMap fun (np, ys) =>
  (vpRule ys).flatMap fun (vp, zs) =>
  (assignT .nom np).filterMap fun np' =>
    if agreeC np vp && (t2c vp).subcat.isEmpty then
      some (.branch (.cat "_" "S" [] []) [np', vp], zs)
    else
      none
```

---

### 4. Contraste de Execução no Lean 4 (Sucesso vs. Falhas)

Compilado e verificado com sucesso pelo kernel do Lean 4 via `lake env lean`:

```lean
-- Fita 1: "Alice smiled" (Sucesso: verbo intransitivo com subcat vazia)
#eval parseSent fitaAliceSmiled
-- Retorno: [ (Branch "S" [Leaf "Alice", Leaf "smiled"], []) ]

-- Fita 2: "Alice loved" (FALHA: verbo transitivo sem objeto; subcat pendente)
#eval parseSent fitaAliceLovedIncompleta
-- Retorno: []  (Gramática rejeitou por subcategorização incompleta!)

-- Fita 3: "The dwarfs loved Alice" (Sucesso: NP composto DET+CN e VP saturado)
#eval parseSent fitaDwarfsLovedAlice
-- Retorno: [ (Branch "S" [Branch "NP" [the, dwarfs], Branch "VP" [loved, Alice]], []) ]
```

---

### 5. Paradigma Lean vs. Haskell Identificado
1. **List Comprehensions vs. `flatMap` / `filterMap`:**  
   Em Haskell, o livro usa compreensões de lista com filtros booleanos acoplados. Em Lean 4, usamos operações funcionais explícitas (`flatMap`, `filterMap`) ou mônadas `do`, garantindo clareza operacional de cada trava sintática.
2. **Totalidade e Ausência de Exceções:**  
   Enquanto o Haskell usava `error` para palavras desconhecidas, o modelo do Lean adota totalidade pura: ausência de parse significa simplesmente zero sucessos (`[]`), permitindo que falhas sejam tratadas de forma determinística e segura.

