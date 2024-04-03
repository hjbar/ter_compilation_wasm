<h1> GC Wasm pour Imp </h1>

<h2> Problème : </h2>

<p>
On ne peut pas inspecter la pile en Wasm.

Ainsi, on ne peut pas identifier les racines afin de savoir quels sont espaces encore vivants.

De plus, même si on savait quelles étaient les racines, comme on ne peut pas inspecter la pile, on ne pourrait pas modifier les valeurs empilées qui devraient être modifiées.
</p>

<h2> Solution : </h2>

<p>
La solution est de ne pas utiliser la pile Wasm car elle nous restreint (trop) pour l'implémentation d'un GC.

On peut donc alors "simuler" une pile directement dans la mémoire du module.
C'est ce qu'on appelle une shadow stack.

Ainsi, comme on a accès à la mémoire du module, on pourrait alors inspecter la stack, ce qui résoudrait nos problèmes.
</p>

<h2> To do : </h2>

<p>
Implémenter la shadow stack.
</p>
