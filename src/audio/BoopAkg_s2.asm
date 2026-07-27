; Subsong 2
; ----------------------
Subsong2_DisarkByteRegionStart0
Subsong2_Start
    db 2    ; ReplayFrequency (0=12.5hz, 1=25hz, 2=50hz, 3=100hz, 4=150hz, 5=300hz).
    db 1    ; Digichannel (>=0).
    db 1    ; PSG count (>0).
    db 0    ; Loop start index (>=0).
    db 0    ; End index (>=0).
    db 6    ; Initial speed (>=0).
    db 24    ; Base note index (>=0).

Subsong2_Linker
Subsong2_DisarkPointerRegionStart1
; Position 0
Subsong2_Linker_Loop
    dw Subsong2_Track0
    dw Subsong2_Track1
    dw Subsong2_Track2
    dw Subsong2_LinkerBlock0
Subsong2_DisarkPointerRegionEnd1
    dw 0    ; Loop.
Subsong2_DisarkWordForceReference2
    dw Subsong2_Linker_Loop

Subsong2_LinkerBlock0
    db 8    ; Height.
    db 0    ; Transposition 0.
    db 0    ; Transposition 1.
    db 0    ; Transposition 2.
Subsong2_DisarkWordForceReference3
    dw Subsong2_SpeedTrack0    ; SpeedTrack address.
Subsong2_DisarkWordForceReference4
    dw Subsong2_EventTrack0    ; EventTrack address.


Subsong2_Track0
    db 216
    db 5    ; New Instrument (5).
    db 1    ; Index to an effect block.
    db 60    ; Waits for 1 line.

    db 31
    db 60    ; Waits for 1 line.

    db 24
    db 60    ; Waits for 1 line.

    db 100
    db 2    ; Index to an effect block.
    db 61
    db 127    ; Waits for 128 lines.


Subsong2_Track1
    db 240
    db 5    ; New Instrument (5).
    db 1    ; Index to an effect block.
    db 52
    db 55
    db 52
    db 45
    db 47
    db 48
    db 61
    db 127    ; Waits for 128 lines.


Subsong2_Track2
    db 235
    db 5    ; New Instrument (5).
    db 0    ; Index to an effect block.
    db 60    ; Waits for 1 line.

    db 112
    db 1    ; Index to an effect block.
    db 60    ; Waits for 1 line.

    db 104
    db 0    ; Index to an effect block.
    db 60    ; Waits for 1 line.

    db 112
    db 1    ; Index to an effect block.
    db 61
    db 127    ; Waits for 128 lines.


; The speed tracks
Subsong2_SpeedTrack0
    db 255    ; Wait for 128 lines.

; The event tracks
Subsong2_EventTrack0
    db 255    ; Wait for 128 lines.

Subsong2_DisarkByteRegionEnd0
