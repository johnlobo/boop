import mido
from mido import Message, MidiFile, MidiTrack

def crear_tema_estrategia():
    mid = MidiFile()
    
    track_lead = MidiTrack()    # Canal A: Melodía solemne / Viento retro
    track_harmony = MidiTrack() # Canal B: Colchón de acordes / Armonía táctica
    track_bass = MidiTrack()    # Canal C: Bajo profundo + Caja militar (Ruido)
    
    mid.tracks.extend([track_lead, track_harmony, track_bass])
    
    # Programas MIDI sugeridos para emulación
    track_lead.append(Message('program_change', program=80, time=0))
    track_harmony.append(Message('program_change', program=81, time=0))
    track_bass.append(Message('program_change', program=38, time=0))
    
    # A 85 BPM, los tiempos son más largos y espaciados
    NEGRA = 360
    CORCHEA = 180
    BLANCA = 720
    REDONDA = 1440

    # ==========================================================
    # BLOQUE 1: LA NIEBLA DE GUERRA (Atmósfera y Planificación)
    # ==========================================================
    # Canal A: Melodía de notas muy largas, misteriosas (La Menor)
    for n in [57, 60, 59, 55, 57, 57]:
        track_lead.append(Message('note_on', note=n, velocity=90, time=0))
        track_lead.append(Message('note_off', note=n, velocity=0, time=BLANCA if n != 57 else REDONDA))
        
    # Canal B: Acordes lentos en segundo plano
    for n in [60, 64, 62, 59, 60, 60]:
        track_harmony.append(Message('note_on', note=n, velocity=65, time=0))
        track_harmony.append(Message('note_off', note=n, velocity=0, time=BLANCA if n != 60 else REDONDA))
        
    # Canal C: Bajo estático, profundo y espaciado
    for n in [33, 33, 35, 31, 33, 33]:
        track_bass.append(Message('note_on', note=n, velocity=100, time=0))
        track_bass.append(Message('note_off', note=n, velocity=0, time=BLANCA if n != 33 else REDONDA))

    # ==========================================================
    # BLOQUE 2: MARCHA TÁCTICA (Se añade percusión militar)
    # ==========================================================
    # Melodía sube un grado, notas más marcadas
    m2 = [60, 62, 64, 67, 65, 64, 62, 62]
    for n in m2:
        track_lead.append(Message('note_on', note=n, velocity=95, time=0))
        track_lead.append(Message('note_off', note=n, velocity=0, time=NEGRA))
        
    # Armonía hace contra-ritmo pausado
    a2 = [52, 55, 57, 60, 59, 57, 55, 55]
    for n in a2:
        track_harmony.append(Message('note_on', note=n, velocity=70, time=0))
        track_harmony.append(Message('note_off', note=n, velocity=0, time=NEGRA))
        
    # Canal C: Bajo intercalado con golpes de ruido (Caja militar en nota 60)
    # Ritmo: Bajo - Ruido - Bajo - Ruido
    for b_nota in [36, 38]:
        for _ in range(2):
            track_bass.append(Message('note_on', note=b_nota, velocity=110, time=0))
            track_bass.append(Message('note_off', note=b_nota, velocity=0, time=CORCHEA))
            track_bass.append(Message('note_on', note=60, velocity=85, time=0)) # Ruido
            track_bass.append(Message('note_off', note=60, velocity=0, time=CORCHEA))

    # ==========================================================
    # BLOQUE 3: TENSIÓN EN EL FRENTE (Modulación Menor Armónica)
    # ==========================================================
    # El Canal A y B hacen llamadas y respuestas (diálogo de generales)
    for _ in range(2):
        # Pregunta Canal A
        track_lead.append(Message('note_on', note=69, velocity=105, time=0))
        track_lead.append(Message('note_off', note=69, velocity=0, time=BLANCA))
        track_harmony.append(Message('note_off', note=0, velocity=0, time=BLANCA))
        
        # Respuesta Canal B
        track_lead.append(Message('note_off', note=0, velocity=0, time=BLANCA))
        track_harmony.append(Message('note_on', note=68, velocity=90, time=0)) # Nota de tensión (Sol #)
        track_harmony.append(Message('note_off', note=68, velocity=0, time=BLANCA))
        
    # El bajo avanza lentamente semitono a semitono marcando el peligro
    for b_nota in [33, 34, 35, 36]:
        track_bass.append(Message('note_on', note=b_nota, velocity=110, time=0))
        track_bass.append(Message('note_off', note=b_nota, velocity=0, time=NEGRA))

    # ==========================================================
    # BLOQUE 4: LA RESOLUCIÓN HEROICA (Ventaja en el Tablero)
    # ==========================================================
    # Melodía triunfal pero pausada, épica retro
    m4 = [72, 71, 69, 67, 69, 72, 74, 76]
    for n in m4:
        track_lead.append(Message('note_on', note=n, velocity=100, time=0))
        track_lead.append(Message('note_off', note=n, velocity=0, time=NEGRA))
        
    # El Canal B rompe en arpegios abiertos (estilo fantasía de 8 bits)
    a4 = [48, 52, 55, 60, 50, 53, 57, 62]
    for n in a4:
        track_harmony.append(Message('note_on', note=n, velocity=80, time=0))
        track_harmony.append(Message('note_off', note=n, velocity=0, time=CORCHEA))
        
    # Bajo estable apuntalando la épica
    for b_nota in [45, 43]:
        track_bass.append(Message('note_on', note=b_nota, velocity=110, time=0))
        track_bass.append(Message('note_off', note=b_nota, velocity=0, time=BLANCA))

    # ==========================================================
    # BLOQUE 5: ENLACE Y REORGANIZACIÓN (Retorno al bucle)
    # ==========================================================
    # Caída suave para enlazar con la intro misteriosa
    m5 = [74, 71, 67, 64, 62, 59, 55, 52]
    for n in m5:
        track_lead.append(Message('note_on', note=n, velocity=85, time=0))
        track_lead.append(Message('note_off', note=n, velocity=0, time=NEGRA))
        
    a5 = [55, 55, 52, 52, 50, 50, 47, 47]
    for n in a5:
        track_harmony.append(Message('note_on', note=n, velocity=60, time=0))
        track_harmony.append(Message('note_off', note=n, velocity=0, time=NEGRA))
        
    # El bajo clava un Sol largo para resolver hacia el Do/La de la intro
    track_bass.append(Message('note_on', note=31, velocity=105, time=0))
    track_bass.append(Message('note_off', note=31, velocity=0, time=REDONDA))

    mid.save('estrategia_por_turnos_amstrad.mid')
    print("¡Tema de estrategia 'estrategia_por_turnos_amstrad.mid' generado con éxito!")

if __name__ == '__main__':
    crear_tema_estrategia()