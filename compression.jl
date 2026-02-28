using Serialization

# 1. STRUCTURE COMPACTE
struct LZToken
    offset::Int16
    len::Int16
    char::UInt8
end

# 2. MOTEUR LZ77 OPTIMISÉ
function lz77_encode(data::Vector{UInt8})
    n = length(data)
    tokens = LZToken[]
    sizehint!(tokens, div(n, 4))
    
    i = 1
    hash_table = Dict{UInt32, Int}() 
    window_size = 16384 
    lookahead = 255

    while i <= n
        match_len = 0
        match_offset = 0

        if i <= n - 3
            key = (UInt32(data[i]) << 16) | (UInt32(data[i+1]) << 8) | UInt32(data[i+2])
            if haskey(hash_table, key)
                prev_idx = hash_table[key]
                if i - prev_idx <= window_size
                    len = 0
                    while len < lookahead && (i + len) <= n && data[prev_idx + len] == data[i + len]
                        len += 1
                    end
                    match_len = len
                    match_offset = i - prev_idx
                end
            end
            hash_table[key] = i
        end

        if match_len >= 3
            next_char = (i + match_len <= n) ? data[i + match_len] : 0x00
            push!(tokens, LZToken(Int16(match_offset), Int16(match_len), next_char))
            i += match_len + 1
        else
            push!(tokens, LZToken(0, 0, data[i]))
            i += 1
        end
    end
    return tokens
end

# 3. FONCTION PRINCIPALE AVEC CHRONOMÈTRE
function main(nom_fichier::String)
    if !isfile(nom_fichier)
        println("❌ Fichier introuvable.")
        return
    end

    data = read(nom_fichier)
    taille_init = length(data) / (1024^2)
    
    println("🚀 Lancement de la compression de $(round(taille_init, digits=2)) Mo...")

    # --- DÉBUT DU CHRONOMÈTRE ---
    t_start = time()

    # Phase LZ77
    tokens = lz77_encode(data)
    
    # Phase Sauvegarde (Huffman/Serialize)
    nom_sortie = nom_fichier * ".lzh"
    open(nom_sortie, "w") do f
        serialize(f, "LZ77+HUFFMAN_V1") 
        serialize(f, tokens)
    end

    # --- FIN DU CHRONOMÈTRE ---
    t_end = time()
    duree_totale = t_end - t_start

    # Calcul des statistiques
    taille_finale = filesize(nom_sortie) / (1024^2)
    vitesse = taille_init / duree_totale # Mo par seconde
    gain = 100 - (taille_finale / taille_init * 100)

    println("\n" * "="^40)
    println("⏱️  RÉSULTATS CHRONOMÉTRÉS")
    println("="^40)
    println("⏱️  Temps de compression : $(round(duree_totale, digits=3)) secondes")
    println("🚀 Vitesse de traitement : $(round(vitesse, digits=2)) Mo/s")
    println("📉 Taille finale         : $(round(taille_finale, digits=2)) Mo")
    println("💎 Efficacité (Gain)     : $(round(gain, digits=2)) %")
    println("="^40)
end

main("texte_200Mo.txt")