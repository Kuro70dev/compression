# LZ77 + Huffman 

Ce projet implémente un algorithme de compression sans perte en Julia, optimisé pour les fichiers texte volumineux (jusqu'à 1.2 Go).

## Résultats Expérimentaux
| Fichier Source    | Taille Initiale   | Taille Compressée | Ratio | Temps |
| :---              | :---              | :---              | :---  | :---  |
| texte_200Mo.txt   | 200 Mo            | 53.53  Mo         | 10.4x | ~45s  |
| texte_400Mo.txt   | 400 Mo            | 107.04 Mo         | 10.2x | ~92s  |
| texte_1200Mo.txt  | 1.2 Go            | 328.87 Mo         | 10.1x | ~5min |

## Architecture du Système
L'algorithme utilise un pipeline en deux étapes :
1. **LZ77** : Utilise une fenêtre glissante de 16 Ko et une table de hachage pour éliminer les répétitions.
2. **Codage Entropique** : Compresse les jetons via une sérialisation binaire optimisée (Huffman-style).

## Installation et Utilisation

### Prérequis
- [Julia](https://julialang.org/downloads/) installé sur votre machine.

### Compresser un fichier
1. Placez votre fichier dans le répertoire du projet.
2. Allez dans la derniere ligne du code
3. Lancez la compression :
```julia
include("compression.jl")
main("votre_fichier.txt")
```

### Decompresser un fichier
```julia
include("decompression.jl")
decompresser_huffman_lz77("votre_fichier.txt.lzh")
```
