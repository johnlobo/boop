; Subsong 3
; ----------------------
Subsong3_DisarkByteRegionStart0
Subsong3_Start
    db 2    ; ReplayFrequency (0=12.5hz, 1=25hz, 2=50hz, 3=100hz, 4=150hz, 5=300hz).
    db 1    ; Digichannel (>=0).
    db 1    ; PSG count (>0).
    db 0    ; Loop start index (>=0).
    db 0    ; End index (>=0).
    db 7    ; Initial speed (>=0).
    db 26    ; Base note index (>=0).

Subsong3_Linker
Subsong3_DisarkPointerRegionStart1
; Position 0
Subsong3_Linker_Loop
    dw Subsong3_Track0
    dw Subsong3_Track1
    dw Subsong3_Track2
    dw Subsong3_LinkerBlock0
Subsong3_DisarkPointerRegionEnd1
    dw 0    ; Loop.
Subsong3_DisarkWordForceReference2
    dw Subsong3_Linker_Loop

Subsong3_LinkerBlock0
    db 20    ; Height.
    db 0    ; Transposition 0.
    db 0    ; Transposition 1.
    db 0    ; Transposition 2.
Subsong3_DisarkWordForceReference3
    dw Subsong3_SpeedTrack0    ; SpeedTrack address.
Subsong3_DisarkWordForceReference4
    dw Subsong3_EventTrack0    ; EventTrack address.


Subsong3_Track0
    db 216
    db 1    ; New Instrument (1).
    db 1    ; Index to an effect block.
    db 60    ; Waits for 1 line.

    db 95
    db 0    ; Index to an effect block.
    db 60    ; Waits for 1 line.

    db 88
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 32
    db 60    ; Waits for 1 line.

    db 31
    db 60    ; Waits for 1 line.

    db 24
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 24
    db 61
    db 127    ; Waits for 128 lines.


Subsong3_Track1
    db 247
    db 2    ; New Instrument (2).
    db 1    ; Index to an effect block.
    db 51
    db 48
    db 46
    db 48
    db 50
    db 51
    db 60    ; Waits for 1 line.

    db 51
    db 48
    db 44
    db 43
    db 44
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 103
    db 0    ; Index to an effect block.
    db 100
    db 1    ; Index to an effect block.
    db 61
    db 127    ; Waits for 128 lines.


Subsong3_Track2
    db 243
    db 3    ; New Instrument (3).
    db 0    ; Index to an effect block.
    db 60    ; Waits for 1 line.

    db 48
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 46
    db 60    ; Waits for 1 line.

    db 48
    db 60    ; Waits for 1 line.

    db 44
    db 60    ; Waits for 1 line.

    db 39
    db 60    ; Waits for 1 line.

    db 41
    db 60    ; Waits for 1 line.

    db 39
    db 100
    db 1    ; Index to an effect block.
    db 61
    db 127    ; Waits for 128 lines.


; The speed tracks
Subsong3_SpeedTrack0
    db 255    ; Wait for 128 lines.

; The event tracks
Subsong3_EventTrack0
    db 255    ; Wait for 128 lines.

Subsong3_DisarkByteRegionEnd0
