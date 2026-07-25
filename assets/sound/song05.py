import mido
from mido import Message, MidiFile, MidiTrack

def crear_tema_menu():
    mid = MidiFile()

    track_lead = MidiTrack()    # Canal A: Melodía juguetona / paso del gatito
    track_harmony = MidiTrack() # Canal B: Acordes sostenidos (pad armónico real)
    track_bass = MidiTrack()    # Canal C: Bajo, raíz de cada acorde

    mid.tracks.extend([track_lead, track_harmony, track_bass])

    # Programas MIDI sugeridos para emulación (mismos que el resto de temas)
    track_lead.append(Message('program_change', program=80, time=0))    # Square
    track_harmony.append(Message('program_change', program=81, time=0))
    track_bass.append(Message('program_change', program=38, time=0))    # Synth Bass

    # Referencia: ~100-110 BPM al importar en Arkos Tracker (más pausado que antes)
    NEGRA = 300
    CORCHEA = 150
    SEMICORCHEA = 75
    BLANCA = 600
    REDONDA = 1200

    # Progresión armónica base: I - vi - IV - V  (Sol - Mim - Do - Re)
    # Cada entrada: (raíz_bajo, tercera, quinta) en la octava de armonía/melodía
    PROGRESION = [
        (43, 71, 74),   # Sol:  bajo G2, armonía B4(3ra)/D5(5ta)
        (40, 67, 71),   # Mim:  bajo E2, armonía G4(3ra)/B4(5ta)
        (36, 64, 67),   # Do:   bajo C2, armonía E4(3ra)/G4(5ta)
        (38, 66, 69),   # Re:   bajo D2, armonía F#4(3ra)/A4(5ta)
    ]

    def acorde_pad(bajo, tercera, quinta, duracion_bajo=REDONDA):
        # Armonía: quinta sostenida, luego tercera sostenida (2 compases)
        track_harmony.append(Message('note_on', note=quinta, velocity=65, time=0))
        track_harmony.append(Message('note_off', note=quinta, velocity=0, time=BLANCA))
        track_harmony.append(Message('note_on', note=tercera, velocity=60, time=0))
        track_harmony.append(Message('note_off', note=tercera, velocity=0, time=BLANCA))
        # Bajo: raíz sostenida cubriendo los mismos 2 compases
        track_bass.append(Message('note_on', note=bajo, velocity=100, time=0))
        track_bass.append(Message('note_off', note=bajo, velocity=0, time=duracion_bajo))

    # ==========================================================
    # BLOQUE 1: DESPERTAR (intro pausada, un acorde por compás)
    # ==========================================================
    intro = [
        (67, 74, 71, 43),   # Sol:  raíz G4, quinta D5 | bajo G2
        (64, 71, 67, 40),   # Mim:  raíz E4, quinta B4 | bajo E2
        (60, 67, 64, 36),   # Do:   raíz C4, quinta G4 | bajo C2
        (62, 69, 66, 38),   # Re:   raíz D4, quinta A4 | bajo D2
    ]
    for raiz, quinta, tercera_armonia, bajo in intro:
        track_lead.append(Message('note_on', note=raiz, velocity=75, time=0))
        track_lead.append(Message('note_off', note=raiz, velocity=0, time=NEGRA))
        track_lead.append(Message('note_on', note=quinta, velocity=75, time=0))
        track_lead.append(Message('note_off', note=quinta, velocity=0, time=NEGRA))

        track_harmony.append(Message('note_on', note=tercera_armonia, velocity=55, time=0))
        track_harmony.append(Message('note_off', note=tercera_armonia, velocity=0, time=BLANCA))

        track_bass.append(Message('note_on', note=bajo, velocity=95, time=0))
        track_bass.append(Message('note_off', note=bajo, velocity=0, time=BLANCA))

    # ==========================================================
    # BLOQUE 2: PASEO JUGUETÓN (tema principal sobre I-vi-IV-V,
    # 2 compases por acorde = 8 compases; sincroniza con el ciclo
    # de 4 frames de la animación del gatito caminando)
    # ==========================================================
    melodias_tema = [
        [67, 69, 71, 74, 71, 69, 67, 64],   # sobre Sol
        [64, 67, 71, 67, 64, 62, 64, 67],   # sobre Mim
        [60, 64, 67, 72, 67, 64, 60, 62],   # sobre Do
        [62, 66, 69, 74, 69, 66, 62, 64],   # sobre Re
    ]
    for (bajo, tercera, quinta), melodia in zip(PROGRESION, melodias_tema):
        for n in melodia:
            track_lead.append(Message('note_on', note=n, velocity=100, time=0))
            track_lead.append(Message('note_off', note=n, velocity=0, time=CORCHEA))
        acorde_pad(bajo, tercera, quinta)

    # ==========================================================
    # BLOQUE 3: VARIACIÓN (mismo colchón armónico, melodía una
    # octava más aguda y ritmo más ligado, para dar desarrollo)
    # ==========================================================
    melodias_variacion = [
        [79, 76, 74, 71, 74, 76, 79, 81],   # sobre Sol
        [76, 74, 71, 67, 71, 74, 76, 79],   # sobre Mim
        [72, 71, 67, 64, 67, 71, 72, 74],   # sobre Do
        [74, 72, 69, 66, 69, 72, 74, 76],   # sobre Re
    ]
    for (bajo, tercera, quinta), melodia in zip(PROGRESION, melodias_variacion):
        for n in melodia:
            track_lead.append(Message('note_on', note=n, velocity=95, time=0))
            track_lead.append(Message('note_off', note=n, velocity=0, time=CORCHEA))
        acorde_pad(bajo, tercera, quinta)

    # ==========================================================
    # BLOQUE 4: SALTO Y MAULLIDO (llamada/respuesta sobre vi-V-I,
    # con acento "boop" — guiño al nombre del juego)
    # ==========================================================
    tension = [
        (40, 67, 71),   # Mim
        (38, 66, 69),   # Re
        (43, 71, 74),   # Sol (resuelve)
        (43, 71, 74),   # Sol (se sostiene)
    ]
    llamadas = [
        [74, 76, 79, 76],   # sobre Mim
        [71, 74, 78, 74],   # sobre Re
        [72, 74, 76, 79],   # sobre Sol
        [79, 76, 74, 72],   # sobre Sol (respuesta descendente)
    ]
    for i, ((bajo, tercera, quinta), frase) in enumerate(zip(tension, llamadas)):
        for n in frase:
            track_lead.append(Message('note_on', note=n, velocity=105, time=0))
            track_lead.append(Message('note_off', note=n, velocity=0, time=NEGRA))

        if i % 2 == 0:
            # "Boop!" — nota aguda staccato entre frases
            track_harmony.append(Message('note_on', note=84, velocity=115, time=0))
            track_harmony.append(Message('note_off', note=84, velocity=0, time=SEMICORCHEA))
            track_harmony.append(Message('note_off', note=0, velocity=0, time=BLANCA - SEMICORCHEA))
            track_bass.append(Message('note_on', note=bajo, velocity=105, time=0))
            track_bass.append(Message('note_off', note=bajo, velocity=0, time=BLANCA))
        else:
            acorde_pad(bajo, tercera, quinta, duracion_bajo=BLANCA)

    # ==========================================================
    # BLOQUE 5: REEXPOSICIÓN (vuelve el tema principal, resumido,
    # para reforzar el gancho antes de enlazar el loop)
    # ==========================================================
    bajo, tercera, quinta = PROGRESION[0]
    for n in [67, 69, 71, 74, 71, 69, 67, 64]:
        track_lead.append(Message('note_on', note=n, velocity=100, time=0))
        track_lead.append(Message('note_off', note=n, velocity=0, time=CORCHEA))
    acorde_pad(bajo, tercera, quinta)

    # ==========================================================
    # BLOQUE 6: ENLACE (V - I, resuelve y prepara el reenganche
    # suave con el Bloque 1)
    # ==========================================================
    m6 = [76, 74, 71, 67]
    for n in m6:
        track_lead.append(Message('note_on', note=n, velocity=80, time=0))
        track_lead.append(Message('note_off', note=n, velocity=0, time=NEGRA))

    track_harmony.append(Message('note_on', note=66, velocity=55, time=0))   # F#4 (Re)
    track_harmony.append(Message('note_off', note=66, velocity=0, time=BLANCA))
    track_harmony.append(Message('note_on', note=71, velocity=55, time=0))   # B4 (Sol)
    track_harmony.append(Message('note_off', note=71, velocity=0, time=BLANCA))

    track_bass.append(Message('note_on', note=38, velocity=100, time=0))     # D2 (V)
    track_bass.append(Message('note_off', note=38, velocity=0, time=BLANCA))
    track_bass.append(Message('note_on', note=31, velocity=100, time=0))     # G1 (I)
    track_bass.append(Message('note_off', note=31, velocity=0, time=REDONDA))

    mid.save('tema_menu_juguetin.mid')
    print("¡Tema de menú 'tema_menu_juguetin.mid' generado con éxito!")

if __name__ == '__main__':
    crear_tema_menu()
