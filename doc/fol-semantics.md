
A grande mudança em relação à lógica proposicional é justamente esta:

> Na proposicional, uma interpretação diz quais proposições são verdadeiras.

> Na primeira ordem, uma interpretação precisa dizer **quais são os
> objetos do mundo e como os símbolos da linguagem se referem a
> eles**.

### MWE: alunos e disciplinas

Comece com a assinatura:

* constante `alice`
* constante `bob`
* predicado unário `Student(x)`
* predicado binário `Likes(x,y)`

E uma sentença:

$$
\forall x\,(Student(x)\rightarrow Likes(x,alice)).
$$

Pergunte:

> **O que precisamos saber para decidir se essa fórmula é verdadeira?**

Isso leva naturalmente à estrutura semântica.

Escolha um domínio minúsculo:

$$
D=\{a,b,c\}.
$$

E uma interpretação \(I\):

$$
I(alice)=a,\qquad I(bob)=b
$$

e, por exemplo,

$$
Student^I=\{a,b\}
$$

$$
Likes^I=\{(a,a),(a,b),(b,a),(b,b)\}.
$$

Agora podemos avaliar:

$$
I\models\forall x(Student(x)\rightarrow Likes(x,alice)).
$$

Porque para cada elemento de \(D\), se ele pertence a \(Student^I\), então o par correspondente está em \(Likes^I\).

---

### O detalhe que eu acho mais importante para a sua aula

Depois de apresentar **uma** estrutura, mude apenas \(Likes^I\):

$$
Likes^I=\{(a,a),(a,b),(b,b)\}.
$$

Agora a fórmula é **falsa**, pois:

$$
Student(b)
$$

é verdadeira, mas

$$
Likes(b,alice)
$$

é falsa.

Isso dá uma demonstração muito concreta de que:

> **A mesma fórmula pode ser verdadeira em uma interpretação e falsa em outra.**

E aí você pode fazer a analogia com a aula anterior:

### Proposicional

$$
p\land q
$$

Uma interpretação é essencialmente:

$$
I:\{p,q\}\to\{\mathsf{true},\mathsf{false}\}.
$$

### Primeira ordem

Para

$$
\forall x(Student(x)\rightarrow Likes(x,alice))
$$

uma interpretação precisa fornecer muito mais:

$$
\mathcal M=(D,I)
$$

onde:

* \(D\) é o **domínio**;
* \(I\) diz a que objeto cada constante se refere;
* \(I\) diz quais objetos satisfazem cada predicado;
* \(I\) diz quais pares (ou \(n\)-uplas) satisfazem cada relação.

---

### E então vem o MWE realmente interessante

Eu faria uma pequena mudança na fórmula:

$$
\forall x(Student(x)\rightarrow Likes(x,alice))
$$

para

$$
\exists x(Student(x)\land Likes(x,alice)).
$$

Pergunte:

> O que mudou semanticamente?

A resposta não é simplesmente "agora procuramos um aluno". Você pode **mostrar a avaliação recursivamente**:

$$
\mathcal M,g\models\exists x\,\varphi
$$

sse existe \(d\in D\) tal que

$$
\mathcal M,g[x\mapsto d]\models\varphi.
$$

Aqui aparece, de maneira bastante natural, a necessidade de uma **valoração \(g\)** para variáveis.

Isso é, na minha opinião, o ponto em que vale introduzir formalmente:

$$
\boxed{\mathcal M,g\models\varphi}
$$

em vez de apenas

$$
\mathcal M\models\varphi.
$$

Você pode dizer:

> Constantes são interpretadas pela estrutura; variáveis são interpretadas pela valoração.

E então mostrar:

$$
g(x)=b
$$

e avaliar

$$
Student(x)\land Likes(x,alice)
$$

como

$$
Student(b)\land Likes(b,a).
$$

---

### Uma sequência de 15–20 minutos

Eu estruturaria o MWE assim:

1. **Assinatura**

   $$
   alice,\ bob,\ Student,\ Likes
   $$

2. **Uma estrutura concreta**

   $$
   D=\{a,b,c\}
   $$

3. **Interpretar os símbolos**

4. Avaliar uma fórmula fechada:

   $$
   \forall x(Student(x)\to Likes(x,alice))
   $$

5. Alterar a estrutura e mostrar que o valor de verdade muda.

6. Introduzir variável livre:

   $$
   Student(x)\to Likes(x,alice)
   $$

7. Perguntar:

   > "Isso tem um valor de verdade?"

   **Não sem uma valoração \(g\).**

8. Introduzir:

   $$
   \mathcal M,g\models\varphi
   $$

9. Finalmente, mostrar que:

   $$
   \mathcal M\models\varphi
   $$

   é o caso em que \(\varphi\) é uma **sentença**, portanto seu valor não depende da valoração.

Isso faz a semântica de FOL parecer uma extensão muito natural da proposicional, em vez de uma coleção de novas definições.
