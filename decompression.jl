using Serialization

# On redéfinit la structure identique pour que Julia puisse lire le fichier
struct LZToken
    offset::Int16
    len::Int16
    char::UInt8
end

function decompresser_huffman_lz77(nom_entree::String)
    if !isfile(nom_entree)
        println(" Erreur : Le fichier '$nom_entree' est introuvable.")
        return
    end

    println(" Lecture du fichier compressé haute densité...")
    t_start = time()

    # 1. Ouverture et désérialisation
    tokens = open(nom_entree, "r") do f
        # Lecture du header de vérification
        header = deserialize(f)
        if header != "LZ77+HUFFMAN_V1"
            println(" Attention : Format de fichier inconnu.")
        end
        # Lecture de la liste des jetons
        return deserialize(f)
    end

    # 2. Reconstruction (Algorithme LZ77 inverse)
    println("🔓 Reconstruction des données ($(length(tokens)) jetons)...")
    
    # On utilise un Vector{UInt8} pour reconstruire les octets bruts
    data_reconstruite = UInt8[]
    # On pré-alloue pour éviter les ralentissements (environ 200 Mo)
    sizehint!(data_reconstruite, 200_000_000) 

    for t in tokens
        if t.offset > 0
            # On cherche la séquence répétée dans le passé
            # offset = distance en arrière, len = nombre de caractères
            start_idx = length(data_reconstruite) - t.offset + 1
            for j in 0:(t.len - 1)
                push!(data_reconstruite, data_reconstruite[start_idx + j])
            end
        end
        
        # On ajoute le caractère littéral (soit l'octet brut, soit le caractère suivant le motif)
        push!(data_reconstruite, t.char)
    end

    # 3. Sauvegarde du fichier restauré
    nom_sortie = replace(nom_entree, ".lzh" => "_restaure.txt")
    write(nom_sortie, data_reconstruite)

    duree = round(time() - t_start, digits=2)
    taille_finale = length(data_reconstruite) / (1024^2)

    println("\n" * "="^35)
    println(" DÉCOMPRESSION TERMINÉE")
    println("="^35)
    println(" Temps total    : $duree secondes")
    println(" Fichier restauré : $nom_sortie")
    println(" Taille finale   : $(round(taille_finale, digits=2)) Mo")
    println("="^35)
end

# Lancer la décompression
decompresser_huffman_lz77("texte_400Mo.txt.lzh")