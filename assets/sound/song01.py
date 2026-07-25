import mido
from mido import Message, MidiFile, MidiTrack

def crear_cancion_larga_amstrad():
    mid = MidiFile()
    
    # Canales físicos del AY-3-8912
    track_lead = MidiTrack()    # Canal A
    track_harmony = MidiTrack() # Canal B
    track_bass = MidiTrack()    # Canal C
    
    mid.tracks.extend([track_lead, track_harmony, track_bass])
    
    # Ajustes de instrumentos MIDI estándar
    track_lead.append(Message('program_change', program=80, time=0))
    track_harmony.append(Message('program_change', program=81, time=0))
    track_bass.append(Message('program_change', program=38, time=0))
    
    NEGRA = 240
    CORCHEA = 120

    # ==========================================================
    # SECCIÓN 1 A 4: EL BLOQUE ORIGINAL (Aventurero / Do Mayor)
    # ==========================================================
    
    # 1. Intro
    m1 = [60, 64, 67, 72, 67, 64, 60, 64, 62, 65, 69, 74, 69, 65, 62, 65]
    a1 = [48, 52, 55, 52, 48, 52, 55, 52, 50, 53, 57, 53, 50, 53, 57, 53]
    b1 = [36, 36, 36, 36, 38, 38, 38, 38]
    
    # 2. Variación
    m2 = [65, 69, 72, 77, 72, 69, 65, 69, 67, 71, 74, 79, 74, 71, 67, 71]
    a2 = [53, 57, 60, 57, 53, 57, 60, 57, 55, 59, 62, 59, 55, 59, 62, 59]
    b2 = [41, 41, 41, 41, 43, 43, 43, 43]
    
    # 3. Puente Heroico
    m3 = [76, 74, 72, 71, 69, 71, 72, 74]
    a3 = [57, 60, 64, 60, 57, 60, 64, 60, 57, 60, 64, 60, 57, 60, 64, 60]
    b3 = [45, 45, 45, 45, 45, 45, 45, 45]
    
    # 4. Transición
    m4 = [79, 77, 76, 74, 72, 71, 69, 67]
    a4 = [67, 67, 65, 65, 62, 62, 59, 59]
    b4 = [43, 43, 43, 43, 43, 43, 43, 43]

    # Escribir bloques 1-4 en las pistas
    for n in m1+m2:
        track_lead.append(Message('note_on', note=n, velocity=100, time=0))
        track_lead.append(Message('note_off', note=n, velocity=0, time=CORCHEA))
    for n in m3+m4:
        track_lead.append(Message('note_on', note=n, velocity=100, time=0))
        track_lead.append(Message('note_off', note=n, velocity=0, time=NEGRA))

    for n in a1+a2+a3:
        track_harmony.append(Message('note_on', note=n, velocity=75, time=0))
        track_harmony.append(Message('note_off', note=n, velocity=0, time=CORCHEA))
    for n in a4:
        track_harmony.append(Message('note_on', note=n, velocity=75, time=0))
        track_harmony.append(Message('note_off', note=n, velocity=0, time=NEGRA))

    for n in b1+b2+b3+b4:
        track_bass.append(Message('note_on', note=n, velocity=110, time=0))
        track_bass.append(Message('note_off', note=n, velocity=0, time=NEGRA))

    # ==========================================================
    # NUEVO BLOQUE: SECCIONES 5 A 8 (Desarrollo Extendido)
    # ==========================================================
    
    # --- SECCIÓN 5: El giro oscuro (Gama de La Menor) ---
    m5 = [69, 72, 76, 81, 80, 77, 74, 71, 69, 72, 76, 81, 83, 80, 77, 76]
    a5 = [57, 57, 57, 57, 56, 56, 56, 56, 57, 57, 57, 57, 59, 59, 59, 59]
    b5 = [45, 45, 45, 45, 44, 44, 44, 44, 45, 45, 45, 45, 47, 47, 47, 47]

    for n in m5:
        track_lead.append(Message('note_on', note=n, velocity=100, time=0))
        track_lead.append(Message('note_off', note=n, velocity=0, time=CORCHEA))
    for n in a5:
        track_harmony.append(Message('note_on', note=n, velocity=70, time=0))
        track_harmony.append(Message('note_off', note=n, velocity=0, time=CORCHEA))
    for n in b5:
        track_bass.append(Message('note_on', note=n, velocity=110, time=0))
        track_bass.append(Message('note_off', note=n, velocity=0, time=NEGRA))

    # --- SECCIÓN 6: El Contraataque (Pregunta y Respuesta) ---
    # El canal A hace notas largas, el canal B responde con ráfagas
    m6 = [77, 77, 76, 76, 74, 74, 72, 72]
    a6 = [62, 65, 69, 72, 60, 64, 67, 72, 59, 62, 65, 69, 57, 60, 64, 69]
    b6 = [41, 41, 36, 36, 35, 35, 33, 33]

    for n in m6:
        track_lead.append(Message('note_on', note=n, velocity=100, time=0))
        track_lead.append(Message('note_off', note=n, velocity=0, time=NEGRA))
    for n in a6:
        track_harmony.append(Message('note_on', note=n, velocity=75, time=0))
        track_harmony.append(Message('note_off', note=n, velocity=0, time=CORCHEA))
    for n in b6:
        track_bass.append(Message('note_on', note=n, velocity=110, time=0))
        track_bass.append(Message('note_off', note=n, velocity=0, time=NEGRA))

    # --- SECCIÓN 7: Tensión pre-clímax (Escala ascendente rápida) ---
    m7 = [60, 62, 64, 65, 67, 69, 71, 72, 74, 76, 77, 79, 81, 83, 84, 86]
    a7 = [48, 50, 52, 53, 55, 57, 59, 60, 62, 64, 65, 67, 69, 71, 72, 74]
    b7 = [36, 38, 40, 41, 43, 45, 47, 48, 50, 52, 53, 55, 57, 59, 60, 62] # ¡El bajo sube también!

    for i in range(16):
        track_lead.append(Message('note_on', note=m7[i], velocity=100, time=0))
        track_lead.append(Message('note_off', note=m7[i], velocity=0, time=CORCHEA))
        
        track_harmony.append(Message('note_on', note=a7[i], velocity=70, time=0))
        track_harmony.append(Message('note_off', note=a7[i], velocity=0, time=CORCHEA))
        
        track_bass.append(Message('note_on', note=b7[i], velocity=105, time=0))
        track_bass.append(Message('note_off', note=b7[i], velocity=0, time=CORCHEA))

    # --- SECCIÓN 8: Gran Final y Enlace al Loop (Estabilización en Sol) ---
    m8 = [84, 83, 81, 79, 77, 76, 74, 67]
    a8 = [60, 60, 59, 59, 57, 57, 55, 55]
    b8 = [43, 43, 43, 43, 43, 43, 43, 43] # El bajo machaca el Sol (fundamental de dominante)

    for n in m8:
        track_lead.append(Message('note_on', note=n, velocity=100, time=0))
        track_lead.append(Message('note_off', note=n, velocity=0, time=NEGRA))
    for n in a8:
        track_harmony.append(Message('note_on', note=n, velocity=75, time=0))
        track_harmony.append(Message('note_off', note=n, velocity=0, time=NEGRA))
    for n in b8:
        track_bass.append(Message('note_on', note=n, velocity=110, time=0))
        track_bass.append(Message('note_off', note=n, velocity=0, time=NEGRA))

    # Guardar el archivo extendido
    mid.save('cancion_larga_amstrad.mid')
    print("¡Listo! Creado 'cancion_larga_amstrad.mid' con estructura extendida de 8 secciones.")

if __name__ == '__main__':
    crear_cancion_larga_amstrad()