
### Exemplo

Suponha três proposições:

* \(p\): Alice está na sala.
* \(q\): Bob está na sala.
* \(r\): Carol está na sala.

Sem nenhuma informação adicional, temos \(2^3=8\) interpretações possíveis:

| \(p\) | \(q\) | \(r\) |
| ----- | ----- | ----- |
| F     | F     | F     |
| F     | F     | V     |
| F     | V     | F     |
| F     | V     | V     |
| V     | F     | F     |
| V     | F     | V     |
| V     | V     | F     |
| V     | V     | V     |

Agora suponha que sabemos:

$$
\Gamma = \{p \lor q,\quad \neg r\}
$$

Ou seja:

1. **Alice ou Bob está na sala.**
2. **Carol não está na sala.**

A pergunta passa a ser:

> Quais interpretações são compatíveis com \(\Gamma\)?

As interpretações admissíveis são apenas:

| \(p\) | \(q\) | \(r\) | \(p\lor q\) | \(\neg r\) |
| ----- | ----- | ----- | ----------- | ---------- |
| F     | V     | F     | V           | V          |
| V     | F     | F     | V           | V          |
| V     | V     | F     | V           | V          |

Ou seja, podemos definir:

$$
\operatorname{Mod}(\Gamma)
=
\{I\mid I\models\varphi\text{ para toda }\varphi\in\Gamma\}.
$$

E então temos a ideia que eu enfatizaria para os alunos:

> **Uma fórmula não determina uma interpretação; ela elimina interpretações que não são compatíveis com ela. Um conjunto de fórmulas elimina ainda mais interpretações.**

Isso prepara muito naturalmente a definição de consequência lógica:

$$
\Gamma\models\varphi
$$

significa:

> **toda interpretação que sobrevive às restrições impostas por \(\Gamma\) também satisfaz \(\varphi\).**

### Um passo particularmente didático

Depois pergunte:

> A partir de \(\Gamma=\{p\lor q,\neg r\}\), podemos concluir \(p\)?

Não, porque ainda sobrevive a interpretação \(p=F,q=V,r=F\).

Podemos concluir \(p\lor q\)? Sim — trivialmente, porque essa é uma das restrições.

Podemos concluir \(\neg r\)? Sim.

Agora acrescente:

$$
q\rightarrow \neg p
$$

Então as interpretações sobreviventes passam a ser apenas:

| \(p\) | \(q\) | \(r\) |
| ----- | ----- | ----- |
| F     | V     | F     |
| V     | F     | F     |

E agora **\(p\) e \(q\) continuam indeterminados individualmente**.

Se acrescentarmos ainda:

$$
q
$$

resta uma única interpretação:

$$
p=F,\quad q=V,\quad r=F.
$$

Esse é um excelente momento para mostrar a diferença entre:

* **satisfatibilidade:** existe uma interpretação que satisfaz \(\Gamma\);
* **consequência lógica:** todas as interpretações que satisfazem \(\Gamma\) satisfazem \(\varphi\);
* **teoria completa:** \(\Gamma\) restringe as interpretações a uma única valuation, nesse exemplo.

E isso conecta diretamente com dedução natural:

$$
\Gamma\vdash\varphi
$$

é a afirmação sintática correspondente à ideia semântica

$$
\Gamma\models\varphi.
$$

