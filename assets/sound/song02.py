import mido
from mido import Message, MidiFile, MidiTrack

def crear_tema_ritmico_amstrad():
    mid = MidiFile()
    
    # 3 canales para el chip del Amstrad
    track_lead = MidiTrack()    # Canal A: Melodía cortante
    track_harmony = MidiTrack() # Canal B: Arpegio/Pad de soporte
    track_bass = MidiTrack()    # Canal C: Bajo + Batería (Compartido)
    
    mid.tracks.extend([track_lead, track_harmony, track_bass])
    
    # Instrumentos MIDI estándar aproximados
    track_lead.append(Message('program_change', program=80, time=0))
    track_harmony.append(Message('program_change', program=81, time=0))
    track_bass.append(Message('program_change', program=39, time=0)) # Bajo más agresivo
    
    NEGRA = 240
    CORCHEA = 120
    SEMICORCHEA = 60

    # ==========================================================
    # SECCIÓN 1: INTRO (Estableciendo el ritmo de bajo y batería)
    # ==========================================================
    # Canal A y B esperan 4 compases mientras el bajo y la batería arrancan
    track_lead.append(Message('note_off', note=0, velocity=0, time=NEGRA * 16))
    track_harmony.append(Message('note_off', note=0, velocity=0, time=NEGRA * 16))
    
    # Canal C: Ritmo base (Nota 36 = Bombo/Bajo, Nota 40 = Caja/Ruido)
    # Patrón: Bombo - Bajo - Caja - Bajo
    for _ in range(4):
        # Tiempo 1: Bombo + Bajo (C2)
        track_bass.append(Message('note_on', note=36, velocity=120, time=0))
        track_bass.append(Message('note_off', note=36, velocity=0, time=CORCHEA))
        track_bass.append(Message('note_on', note=36, velocity=100, time=0))
        track_bass.append(Message('note_off', note=36, velocity=0, time=CORCHEA))
        # Tiempo 2: Caja (simulada en MIDI con nota alta o ruido)
        track_bass.append(Message('note_on', note=60, velocity=110, time=0)) # Sonará a Caja si le pones ruido en Arkos
        track_bass.append(Message('note_off', note=60, velocity=0, time=CORCHEA))
        track_bass.append(Message('note_on', note=36, velocity=100, time=0))
        track_bass.append(Message('note_off', note=36, velocity=0, time=CORCHEA))

    # ==========================================================
    # SECCIÓN 2: ENTRA LA MELODÍA OSCURA (La Menor / Am)
    # ==========================================================
    # Canal A: Melodía sincopada, misteriosa
    m2 = [57, 60, 64, 67, 65, 64, 60, 57,  57, 60, 64, 67, 69, 67, 64, 60]
    for n in m2:
        track_lead.append(Message('note_on', note=n, velocity=100, time=0))
        track_lead.append(Message('note_off', note=n, velocity=0, time=CORCHEA))
        
    # Canal B: Acompañamiento en terceras picadas
    a2 = [60, 64, 67, 71, 69, 67, 64, 60,  60, 64, 67, 71, 72, 71, 67, 64]
    for n in a2:
        track_harmony.append(Message('note_on', note=n, velocity=70, time=0))
        track_harmony.append(Message('note_off', note=n, velocity=0, time=CORCHEA))
        
    # Canal C: Mantiene el patrón de bajo/batería pesada durante la melodía
    for _ in range(4):
        track_bass.append(Message('note_on', note=36, velocity=120, time=0))
        track_bass.append(Message('note_off', note=36, velocity=0, time=CORCHEA))
        track_bass.append(Message('note_on', note=36, velocity=100, time=0))
        track_bass.append(Message('note_off', note=36, velocity=0, time=CORCHEA))
        track_bass.append(Message('note_on', note=60, velocity=110, time=0)) 
        track_bass.append(Message('note_off', note=60, velocity=0, time=CORCHEA))
        track_bass.append(Message('note_on', note=36, velocity=100, time=0))
        track_bass.append(Message('note_off', note=36, velocity=0, time=CORCHEA))

    # ==========================================================
    # SECCIÓN 3: EL CAMBIO DE RITMO (Fa Mayor - Sol Mayor)
    # ==========================================================
    # Canal A: Notas largas heroicas
    m3 = [65, 67, 69, 72, 67, 69, 71, 74]
    for n in m3:
        track_lead.append(Message('note_on', note=n, velocity=100, time=0))
        track_lead.append(Message('note_off', note=n, velocity=0, time=NEGRA))
        
    # Canal B: Arpegio veloz de fondo (típico chiptune)
    a3 = [53, 57, 60, 57, 53, 57, 60, 57,  55, 59, 62, 59, 55, 59, 62, 59]
    for n in a3:
        track_harmony.append(Message('note_on', note=n, velocity=75, time=0))
        track_harmony.append(Message('note_off', note=n, velocity=0, time=CORCHEA))
        
    # Canal C: El bajo cambia a Fa (41) y Sol (43) pero el bombo/caja sigue picando
    for b_nota in [41, 43]:
        for _ in range(2):
            track_bass.append(Message('note_on', note=b_nota, velocity=120, time=0))
            track_bass.append(Message('note_off', note=b_nota, velocity=0, time=CORCHEA))
            track_bass.append(Message('note_on', note=b_nota, velocity=100, time=0))
            track_bass.append(Message('note_off', note=b_nota, velocity=0, time=CORCHEA))
            track_bass.append(Message('note_on', note=60, velocity=110, time=0))
            track_bass.append(Message('note_off', note=60, velocity=0, time=CORCHEA))
            track_bass.append(Message('note_on', note=b_nota, velocity=100, time=0))
            track_bass.append(Message('note_off', note=b_nota, velocity=0, time=CORCHEA))

    # ==========================================================
    # SECCIÓN 4: DESCONTROL DE SEMICORCHEAS Y CIERRE (Pre-loop)
    # ==========================================================
    # Canal A y B se unen para hacer un descenso ultra rápido en cascada
    m4 = [76, 74, 72, 71, 69, 67, 65, 64, 62, 60, 59, 57, 55, 53, 52, 50]
    a4 = [64, 62, 60, 59, 57, 55, 53, 52, 50, 48, 47, 45, 43, 41, 40, 38]
    for i in range(16):
        track_lead.append(Message('note_on', note=m4[i], velocity=100, time=0))
        track_lead.append(Message('note_off', note=m4[i], velocity=0, time=SEMICORCHEA))
        track_harmony.append(Message('note_on', note=a4[i], velocity=75, time=0))
        track_harmony.append(Message('note_off', note=a4[i], velocity=0, time=SEMICORCHEA))

    # Canal C: Redoble final de batería (puro ruido rápido) para enlazar el loop
    for _ in range(8):
        track_bass.append(Message('note_on', note=60, velocity=115, time=0))
        track_bass.append(Message('note_off', note=60, velocity=0, time=SEMICORCHEA))

    # Guardar canción ritmica
    mid.save('cyberpunk_bateria_amstrad.mid')
    print("¡Archivo 'cyberpunk_bateria_amstrad.mid' generado con éxito!")

if __name__ == '__main__':
    crear_tema_ritmico_amstrad()