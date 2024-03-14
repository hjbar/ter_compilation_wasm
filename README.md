<h1> TER : Compiler vers Wasm </h1>

<h2> Année : L3 </h2>
<h2> Langage : OCaml </h2>

<p>
Le but de ce projet est de compiler un petit langage Imp vers Wasm.
Ce projet est réalisé dans le cadre d'une formation de sensibilisation à la recherche au sein du LMF (Laboratoire Méthodes Formelles) avec le chercheur Thibaut Balabonski.
</p>

<p>
GitHub de l'interpréteur utilisé pour exécuter les fichiers .wat : https://github.com/OCamlPro/owi

Commandes interpréteur :
  - owi script name.wat (--debug)
  - owi fmt name.wat

Commandes compilateur :
  - ./impc.exe (--run | --debug) name.wat

Commandes pour compiler le projet :
  - make
  - dune build
</p>
