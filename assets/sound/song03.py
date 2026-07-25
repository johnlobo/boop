import mido
from mido import Message, MidiFile, MidiTrack

def crear_megatema_cyberpunk():
    mid = MidiFile()
    
    track_lead = MidiTrack()    # Canal A: Melodías y Solos
    track_harmony = MidiTrack() # Canal B: Contra-melodías y Arpegios
    track_bass = MidiTrack()    # Canal C: Bajo + Batería (Compartido)
    
    mid.tracks.extend([track_lead, track_harmony, track_bass])
    
    # Configuración de programas MIDI estándar
    track_lead.append(Message('program_change', program=80, time=0))
    track_harmony.append(Message('program_change', program=81, time=0))
    track_bass.append(Message('program_change', program=39, time=0))
    
    NEGRA = 240
    CORCHEA = 120
    SEMICORCHEA = 60

    # Funciones auxiliares para no repetir código de batería (Canal C)
    def añadir_ritmo_base(track, nota_bajo, repeticiones):
        for _ in range(repeticiones):
            # Tiempo 1: Bombo + Bajo
            track.append(Message('note_on', note=nota_bajo, velocity=120, time=0))
            track.append(Message('note_off', note=nota_bajo, velocity=0, time=CORCHEA))
            track.append(Message('note_on', note=nota_bajo, velocity=100, time=0))
            track.append(Message('note_off', note=nota_bajo, velocity=0, time=CORCHEA))
            # Tiempo 2: Caja (Ruido en nota 60) + Bajo
            track.append(Message('note_on', note=60, velocity=110, time=0))
            track.append(Message('note_off', note=60, velocity=0, time=CORCHEA))
            track.append(Message('note_on', note=nota_bajo, velocity=100, time=0))
            track.append(Message('note_off', note=nota_bajo, velocity=0, time=CORCHEA))

    # ==========================================================
    # FASE 1: INTRO EXTENDIDA (Bloques 1, 2, 3)
    # ==========================================================
    
    # Bloque 1: Solo Batería y Bajo arrancando motores
    track_lead.append(Message('note_off', note=0, velocity=0, time=NEGRA * 8))
    track_harmony.append(Message('note_off', note=0, velocity=0, time=NEGRA * 8))
    añadir_ritmo_base(track_bass, 35, 4) # Bajo en Si b

    # Bloque 2: Entra la armonía en colchón estático
    track_lead.append(Message('note_off', note=0, velocity=0, time=NEGRA * 8))
    for n in [57, 60, 64, 60, 57, 60, 64, 60, 55, 59, 62, 59, 55, 59, 62, 59]:
        track_harmony.append(Message('note_on', note=n, velocity=70, time=0))
        track_harmony.append(Message('note_off', note=n, velocity=0, time=CORCHEA))
    añadir_ritmo_base(track_bass, 36, 4) # Cambia a Do

    # Bloque 3: Pequeño anticipo de la melodía (Línea de sinth flotante)
    for n in [64, 67, 69, 71, 69, 67, 64, 62]:
        track_lead.append(Message('note_on', note=n, velocity=90, time=0))
        track_lead.append(Message('note_off', note=n, velocity=0, time=NEGRA))
    for n in [57, 60, 64, 60, 57, 60, 64, 60, 59, 62, 66, 62, 59, 62, 66, 62]:
        track_harmony.append(Message('note_on', note=n, velocity=70, time=0))
        track_harmony.append(Message('note_off', note=n, velocity=0, time=CORCHEA))
    añadir_ritmo_base(track_bass, 38, 4) # Sube a Re

    # ==========================================================
    # FASE 2: EL TEMA CENTRAL CYBERPUNK (Bloques 4, 5, 6)
    # ==========================================================
    
    # Bloque 4: El núcleo (La Menor) - Ritmo frenético
    m4 = [57, 60, 64, 67, 65, 64, 60, 57, 57, 60, 64, 67, 69, 67, 64, 60]
    a4 = [60, 64, 67, 71, 69, 67, 64, 60, 60, 64, 67, 71, 72, 71, 67, 64]
    for i in range(16):
        track_lead.append(Message('note_on', note=m4[i], velocity=105, time=0))
        track_lead.append(Message('note_off', note=m4[i], velocity=0, time=CORCHEA))
        track_harmony.append(Message('note_on', note=a4[i], velocity=75, time=0))
        track_harmony.append(Message('note_off', note=a4[i], velocity=0, time=CORCHEA))
    añadir_ritmo_base(track_bass, 45, 4) # Bajo pesado en La

    # Bloque 5: Variación del tema central con saltos de octava
    m5 = [69, 81, 79, 76, 74, 76, 74, 72, 69, 81, 79, 76, 77, 79, 81, 83]
    for n in m5:
        track_lead.append(Message('note_on', note=n, velocity=105, time=0))
        track_lead.append(Message('note_off', note=n, velocity=0, time=CORCHEA))
    for _ in range(2):
        for n in [53, 57, 60, 57, 55, 59, 62, 59]:
            track_harmony.append(Message('note_on', note=n, velocity=75, time=0))
            track_harmony.append(Message('note_off', note=n, velocity=0, time=CORCHEA))
    añadir_ritmo_base(track_bass, 41, 2) # Bajo en Fa
    añadir_ritmo_base(track_bass, 43, 2) # Bajo en Sol

    # Bloque 6: Contramelodía agresiva en el Canal B, el Canal A acompaña
    m6 = [72, 72, 71, 71, 69, 69, 67, 67, 65, 65, 64, 64, 62, 62, 59, 59]
    a6 = [57, 60, 64, 69, 55, 59, 62, 67, 53, 57, 60, 65, 52, 56, 59, 64]
    for i in range(16):
        track_lead.append(Message('note_on', note=m6[i], velocity=95, time=0))
        track_lead.append(Message('note_off', note=m6[i], velocity=0, time=CORCHEA))
        track_harmony.append(Message('note_on', note=a6[i], velocity=85, time=0))
        track_harmony.append(Message('note_off', note=a6[i], velocity=0, time=CORCHEA))
    añadir_ritmo_base(track_bass, 45, 4)

    # ==========================================================
    # FASE 3: DESARROLLO HEROICO (Bloques 7, 8, 9)
    # ==========================================================
    
    # Bloque 7: Apertura brillante (Do Mayor)
    m7 = [60, 64, 67, 72, 76, 72, 67, 64, 62, 65, 69, 74, 77, 74, 69, 65]
    for n in m7:
        track_lead.append(Message('note_on', note=n, velocity=100, time=0))
        track_lead.append(Message('note_off', note=n, velocity=0, time=CORCHEA))
    for _ in range(2):
        for n in [48, 52, 55, 52, 50, 53, 57, 53]:
            track_harmony.append(Message('note_on', note=n, velocity=70, time=0))
            track_harmony.append(Message('note_off', note=n, velocity=0, time=CORCHEA))
    añadir_ritmo_base(track_bass, 36, 2) # Do
    añadir_ritmo_base(track_bass, 38, 2) # Re

    # Bloque 8: El "Solo" del juego (Notas picadas sincopadas)
    m8 = [76, 76, 74, 76, 77, 77, 76, 77, 79, 79, 77, 79, 81, 81, 79, 81]
    for n in m8:
        track_lead.append(Message('note_on', note=n, velocity=110, time=0))
        track_lead.append(Message('note_off', note=n, velocity=0, time=CORCHEA))
    for n in [52, 55, 59, 55, 53, 57, 60, 57, 55, 59, 62, 59, 57, 60, 64, 60]:
        track_harmony.append(Message('note_on', note=n, velocity=75, time=0))
        track_harmony.append(Message('note_off', note=n, velocity=0, time=CORCHEA))
    añadir_ritmo_base(track_bass, 40, 1) # Mi
    añadir_ritmo_base(track_bass, 41, 1) # Fa
    añadir_ritmo_base(track_bass, 43, 1) # Sol
    añadir_ritmo_base(track_bass, 45, 1) # La

    # Bloque 9: Armonía militar/marcha (Bloques rítmicos juntos)
    for _ in range(4):
        for n_l, n_h in [(72, 60), (72, 60), (74, 62), (76, 64)]:
            track_lead.append(Message('note_on', note=n_l, velocity=100, time=0))
            track_lead.append(Message('note_off', note=n_l, velocity=0, time=CORCHEA))
            track_harmony.append(Message('note_on', note=n_h, velocity=80, time=0))
            track_harmony.append(Message('note_off', note=n_h, velocity=0, time=CORCHEA))
    añadir_ritmo_base(track_bass, 48, 4) # Do agudo

    # ==========================================================
    # FASE 4: GRAN CLÍMAX Y CONEXIÓN AL LOOP (Bloques 10, 11, 12)
    # ==========================================================
    
    # Bloque 10: Subida de tensión cromática (Semicorcheas puras de Tracker)
    m10 = [60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75]
    a10 = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63]
    b10 = [36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51]
    for i in range(16):
        track_lead.append(Message('note_on', note=m10[i], velocity=110, time=0))
        track_lead.append(Message('note_off', note=m10[i], velocity=0, time=SEMICORCHEA))
        track_harmony.append(Message('note_on', note=a10[i], velocity=80, time=0))
        track_harmony.append(Message('note_off', note=a10[i], velocity=0, time=SEMICORCHEA))
        track_bass.append(Message('note_on', note=b10[i], velocity=100, time=0))
        track_bass.append(Message('note_off', note=b10[i], velocity=0, time=SEMICORCHEA))

    # Bloque 11: El muro de sonido (Notas largas agudas y arpegio histérico)
    m11 = [76, 74, 79, 77, 81, 79, 83, 84]
    for n in m11:
        track_lead.append(Message('note_on', note=n, velocity=115, time=0))
        track_lead.append(Message('note_off', note=n, velocity=0, time=NEGRA))
    for _ in range(4):
        for n in [57, 60, 64, 69]:
            track_harmony.append(Message('note_on', note=n, velocity=85, time=0))
            track_harmony.append(Message('note_off', note=n, velocity=0, time=SEMICORCHEA))
    añadir_ritmo_base(track_bass, 45, 4)

    # Bloque 12: Caída libre y redoble ensordecedor para enlazar el patrón 0
    m12 = [84, 81, 77, 74, 72, 69, 65, 62]
    for n in m12:
        track_lead.append(Message('note_on', note=n, velocity=110, time=0))
        track_lead.append(Message('note_off', note=n, velocity=0, time=NEGRA))
    track_harmony.append(Message('note_off', note=0, velocity=0, time=NEGRA * 8)) # Silencio en B para destacar la caída
    
    # Canal C rompe el bajo y mete ráfagas de batería a toda velocidad
    for _ in range(16):
        track_bass.append(Message('note_on', note=60, velocity=120, time=0))
        track_bass.append(Message('note_off', note=60, velocity=0, time=SEMICORCHEA))

    mid.save('cyberpunk_largo_completo.mid')
    print("¡BRUTAL! Archivo 'cyberpunk_largo_completo.mid' con 12 bloques generado.")

if __name__ == '__main__':
    crear_megatema_cyberpunk()