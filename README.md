<h1> TER : Compiler vers Wasm </h1>

<h2> Année : L3 </h2>
<h2> Langage : OCaml </h2>

<p>
Le but de ce projet est de compiler un petit langage Imp vers Wasm.
Ce projet est réalisé dans le cadre d'une formation de sensibilisation à la recherche au sein du LMF (Laboratoire Méthodes Formelles) avec le chercheur Thibaut Balabonski.
</p>

<p>
GitHub de l'interpréteur utilisé pour exécuter les fichiers .wat et .wast : https://github.com/OCamlPro/owi

Commandes interpréteur :
  - owi run name.wat (--debug)
  - owi script name.wast (--debug)
  - owi fmt name.wat
  - owi fmt name.wast

Commandes compilateur :
  - ./impc.exe (--run | --debug) name.wast

Commandes pour compiler le projet :
  - make
  - dune build
</p>

<h3> Explications : </h3>

<p>
Organisation du code :
  - le répertoire Wasm contient des exemples de codes Wasm
  - le répertoire Imp contient le compilateur imp vers wasm script avec des exemples de fichiers à compiler
  - le répertoire Gc contient une tentative d'implémentation d'un GC pour les programmes Wasm (en cours)

Formats des fichiers :
  - .wat pour les fichiers en Wasm pur
  - .wast pour les fichiers en Wasm Script

Le compilateur génère des fichiers .wast afin d'utiliser la fichier print_i32 de l'interpréteur Owi (sinon on ne fait que du Wasm pur).

Linker des fonctions OCaml avec Wasm (à l'aide de l'interpréteur Owi) :

Disponible que en Wasm pur. Cela permet par exemple de s'affranchir de Wasm Script (posibilité de définir sa propre fonction d'affichage).
Grâce à cette fonctionnalité, on peut réaliser des choses impossibles en Wasm Pur comme afficher des caractères (exemple dans wasm/extern_module).
Plus d'informations ici : https://github.com/OCamlPro/owi/tree/main/example/define_host_function#using-and-defining-external-functions-host-functions.
</p>
