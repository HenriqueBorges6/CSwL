# Sumário e Mapa Conceitual: Capítulo 9 (Parsing)
*Notas de estudo e prototipagem: Seções 9.1 a 9.6*

---

## Fluxo Geral do Reconhecimento Sintático

```
Texto cru ("Alice loved Dorothy")
        │
        ▼ (9.5: scan e preproc)
Palavras ("alice", "loved", "dorothy")
        │
        ▼ (9.5: lexicon)
Lista de categorias por palavra ([[NP], [VP subcat:[NP]], [NP]])
        │
        ▼ (9.3 e 9.6: combinadores e regras sintáticas)
Travas aplicadas:
  • Caso: Sujeito recebe Nom, Objeto recebe AccOrDat
  • Concordância: agreeC np vp
  • Valência: subcat do VP esgotada ([])
        │
        ▼ (9.1: ParseTree Cat Cat)
Árvore sintática completa (ou [] se a frase for agramatical)
```

---

## Descrição das Seções e Tópicos Críticos

### 9.1: Estruturas de Árvores Sintáticas (Parse Trees)
- **Função:** Define a árvore (`ParseTree α β`) e a indexação de nós por posições numéricas (`Pos = List Nat`).
- **Pontos técnicos:**
  - `leaf` para nós terminais, `branch` com lista de filhas para nós internos e `ep` para derivação vazia.
  - Três relações de ordem parcial entre posições: dominância, irmandade (*sisters*) e comando constituinte (*c-command*).
- **Lacunas do texto original & Tópicos de atenção:**
  - **Motivação fraca para árvores e relações:** O texto introduz posições, dominância, irmandade e *c-command* quase como geometria combinatória abstrata, sem explicitar de saída por que a sintaxe precisa de árvores em vez de cadeias lineares, nem como essas relações modelam regras reais da língua (como a Teoria da Ligação de pronomes reflexivos e o escopo de quantificadores).
  - **Assimetria prática:** As funções de pares `List (Pos × Pos)` não são chamadas pelo código dos capítulos seguintes (10 a 13), que operam puramente por recursão estrutural sobre a árvore.
  - **Adaptação formal em Lean 4:** Em vez de construir listas de pares finitas, o Lean 4 permite enunciar e provar teoremas indutivos sobre as relações estruturais (`cCommand_not_dominates`, `sisters_not_prefix`).

---

### 9.2: Reconhecimento por Divisão (Splitting)
- **Função:** Apresenta uma abordagem ingênua de reconhecimento para demonstrar o funcionamento de gramáticas livres de contexto e, principalmente, **evidenciar onde e por que ela falha**.
- **Pontos técnicos:**
  - Usa a gramática de palíndromos ($S \to a S a \mid b S b \mid \dots$) e a função `split2` para fatiar a lista em todas as partições possíveis de prefixo e sufixo.
- **Lacunas do texto original & Tópicos de atenção:**
  - **Foil pedagógico (contraexemplo deliberado):** A seção serve quase exclusivamente para mostrar falhas estruturais: tem complexidade exponencial ($O(2^n)$) e entra em loop infinito quando há regras recursivas à esquerda que admitem partições vazias ($A \to A \dots$).
  - **Problema de parada no Lean 4:** O compilador do Lean 4 não aceita divisão não-estrutural sem justificativa de terminação, exigindo `partial def`, medida de comprimento explícita (`termination_by`) ou verificação finita (`native_decide` contra `Mathlib.Data.List.Palindrome`).

---

### 9.3: Combinadores de Parser
- **Função:** Introduz a ideia central do capítulo: construir analisadores complexos a partir de funções pequenas usando a técnica de *List of Successes* (Wadler):
  $$\text{Parser } \alpha \; \beta = \text{List } \alpha \to \text{List } (\beta \times \text{List } \alpha)$$
- **Pontos técnicos:**
  - Primitivas: `satisfy`, `symbol`, `token`.
  - Combinadores operacionais: escolha/alternância (`<|>`), sequência monádica (`<*>`), construtor de nós (`<:>`), fechamento de fita (`just`) e repetições (`many`, `some`).
- **Lacunas do texto original & Tópicos de atenção:**
  - **Tratamento de erros por totalidade:** Falha sintática não gera exceções impuras nem interrompe o processo: retorna lista vazia (`[]`). A ambiguidade retorna múltiplos sucessos.
  - **Modelagem em Lean 4:** Pode ser escrita como função pura com operadores manuais ou através do transformador `StateT (List α) List`, que herda nativamente as instâncias de `Alternative` e `Monad` da biblioteca.

---

### 9.4: Categorias e Traços
- **Função:** Estabelece a ligação direta entre a técnica de parsing e a língua natural, introduzindo traços morfológicos e categorias sintáticas ricas para impedir sentenças agramaticais (*"The dwarfs loves"*).
- **Pontos técnicos:**
  - Traços (`Feat`): gênero, número, pessoa, caso, tempo e marcação preposicional.
  - Prova de expressividade: uma Context-Free Grammar aumentada com traços finitos **continua sendo formalmente uma Context-Free Grammar** (CFG), pois equivale a uma multiplicação finita de regras.
  - Unificação de traços: `combine`, `agree` e poda de redundâncias (`prune`).
- **Lacunas do texto original & Tópicos de atenção:**
  - **Por que 4 componentes em `Cat`?** O texto define `Cat Phon CatLabel Agreement [Cat]` mas não aprofunda por que cada um dos 4 é estritamente indispensável:
    1. `Phon`: a âncora material do som/grafia na fita (ou `"_"` em nós compostos).
    2. `CatLabel`: a identidade funcional na árvore ($S$, $NP$, $VP$), necessária porque traços sozinhos não distinguem classes gramaticais.
    3. `Agreement`: o pacote de restrições de compatibilidade (número, gênero, pessoa) que impede anomalias morfológicas.
    4. `[Cat]` (subcategorização): a valência sintática que define quantos argumentos o elemento precisa consumir para se completar.
  - **Dilema da Issue 42 no Lean 4:** A lista plana do Haskell (`List Feat`) permite estados contraditórios como `[Masc, Fem, Sg, Pl]`, exigindo validação manual em tempo de execução. O Lean 4 permite modelar registros tipados (`structure Agreement`), tornando estados contraditórios impossíveis por construção.

---

### 9.5: Consulta Lexical e Normalização
- **Função:** Constrói a ponte prática entre as palavras do texto e os tipos da gramática via tabela de dicionário (`lexicon : String → List Cat`).
- **Pontos técnicos:**
  - `scan`: isola pontuações coladas em palavras.
  - `preproc`: normaliza locuções (*"at least"* $\to$ *"at_least"*) e decompõe pronomes quantificados (*"everybody"* $\to$ *"every person"*).
- **Lacunas do texto original & Tópicos de atenção:**
  - **Baixa densidade teórica, alto volume de código:** A maior parte da seção é apenas um dicionário fixo (hardcoded) em Haskell.
  - **Ambiguidade categorial (*zero-derivation*):** Palavras em inglês mudam de classe sem sufixos morfológicos (ex.: *"duck"* como nome ou verbo; *"that"* como pronome relativo ou determinante). O retorno como `List Cat` delega a resolução para a busca concorrente do parser.
  - **Eficiência de engenharia:** A busca linear por casamento de padrões tem custo $O(N)$ sobre o vocabulário. Em produção, um `HashMap` ou Trie reduz a consulta para $O(1)$.

---

### 9.6: Regras Sintáticas com Categorias
- **Função:** Reaplica os combinadores da Seção 9.3 sob o ferramental de categorias ricas da 9.4 e o vocabulário da 9.5, incorporando as regras estruturais da língua inglesa.
- **Pontos técnicos:**
  - Transição de tipos: a árvore torna-se tipada como `ParseTree Cat Cat`.
  - Regra verbal (`vpRule`): consome o verbo na fita e consome argumentos subsequentes até esgotar a lista `subcat`.
  - Regra de sentença (`sRule` / `parseSent`): conecta sujeito e predicado sob três travas essenciais:
    1. Atribuição de caso nominativo ao sujeito (`assignT .nom`).
    2. Checagem de concordância de traços entre sujeito e predicado (`agreeC np vp`).
    3. Exigência de valência verbal esgotada (`(t2c vp).subcat == []`).
- **Lacunas do texto original & Tópicos de atenção:**
  - **Consumo total da fita:** A sentença só fecha se o resto da fita for estritamente vazio (`(s, [])`). Tokens sobrando descartam o ramo.
  - **Barra de subcategorização incompleta:** Um verbo transitivo sem objeto (*"Alice loved"*) não forma sentença porque a condição `subcat == []` falha no nó $S$, podando o resultado sem lançar exceções.

---

## Decisões Técnicas: Haskell 2010 vs. Lean 4

| Ponto | Haskell (CSwFP) | Lean 4 (CSwL) |
| :--- | :--- | :--- |
| **Composição de regras** | List Comprehensions com predicados embutidos | Sintaxe monádica `do` com `guard` ou `flatMap`/`filterMap` |
| **Palavras fora do léxico** | Chamada impura a `error "..."` | Totalidade funcional retornando `[]` ou tipo de erro `Except` |
| **Garantia de parada** | Confiada à avaliação preguiçosa | Prova por medida de tamanho (`termination_by`) ou `partial def` |
| **Representação de traços** | `List Feat` não tipada | `structure Agreement` com campos opcionais ou tipos indutivos fechados |
| **Busca lexical** | Casamento linear $O(N)$ | Estrutura indexada $O(1)$ (`HashMap` / Trie) |
