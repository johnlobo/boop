; Subsong 0
; ----------------------
Subsong0_DisarkByteRegionStart0
Subsong0_Start
    db 2    ; ReplayFrequency (0=12.5hz, 1=25hz, 2=50hz, 3=100hz, 4=150hz, 5=300hz).
    db 1    ; Digichannel (>=0).
    db 1    ; PSG count (>0).
    db 0    ; Loop start index (>=0).
    db 3    ; End index (>=0).
    db 9    ; Initial speed (>=0).
    db 24    ; Base note index (>=0).

Subsong0_Linker
Subsong0_DisarkPointerRegionStart1
; Position 0
Subsong0_Linker_Loop
    dw Subsong0_Track0
    dw Subsong0_Track1
    dw Subsong0_Track2
    dw Subsong0_LinkerBlock0
; Position 1
    dw Subsong0_Track3
    dw Subsong0_Track4
    dw Subsong0_Track5
    dw Subsong0_LinkerBlock0
; Position 2
    dw Subsong0_Track6
    dw Subsong0_Track7
    dw Subsong0_Track8
    dw Subsong0_LinkerBlock0
; Position 3
    dw Subsong0_Track9
    dw Subsong0_Track10
    dw Subsong0_Track11
    dw Subsong0_LinkerBlock0
Subsong0_DisarkPointerRegionEnd1
    dw 0    ; Loop.
Subsong0_DisarkWordForceReference2
    dw Subsong0_Linker_Loop

Subsong0_LinkerBlock0
    db 64    ; Height.
    db 0    ; Transposition 0.
    db 0    ; Transposition 1.
    db 0    ; Transposition 2.
Subsong0_DisarkWordForceReference3
    dw Subsong0_SpeedTrack0    ; SpeedTrack address.
Subsong0_DisarkWordForceReference4
    dw Subsong0_EventTrack0    ; EventTrack address.


Subsong0_Track0
    db 204
    db 1    ; New Instrument (1).
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 83
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 12
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 19
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 73
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 80
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 9
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 16
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 81
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 88
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 17
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 24
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 71
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 78
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 7
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 14
    db 61
    db 127    ; Waits for 128 lines.


Subsong0_Track1
    db 232
    db 2    ; New Instrument (2).
    db 1    ; Index to an effect block.
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 45
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 40
    db 60    ; Waits for 1 line.

    db 38
    db 60    ; Waits for 1 line.

    db 36
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 40
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 48
    db 60    ; Waits for 1 line.

    db 47
    db 60    ; Waits for 1 line.

    db 45
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 40
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 41
    db 60    ; Waits for 1 line.

    db 45
    db 60    ; Waits for 1 line.

    db 48
    db 60    ; Waits for 1 line.

    db 45
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 41
    db 60    ; Waits for 1 line.

    db 40
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 38
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 47
    db 60    ; Waits for 1 line.

    db 45
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 38
    db 60    ; Waits for 1 line.

    db 43
    db 61
    db 127    ; Waits for 128 lines.


Subsong0_Track2
    db 62 + 2 * 64    ; Optimized wait for 4 lines.

    db 240
    db 3    ; New Instrument (3).
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 47
    db 60    ; Waits for 1 line.

    db 45
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 50
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 47
    db 60    ; Waits for 1 line.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 45
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 47
    db 62 + 3 * 64    ; Optimized wait for 5 lines.

    db 47
    db 60    ; Waits for 1 line.

    db 50
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 47
    db 60    ; Waits for 1 line.

    db 45
    db 61
    db 127    ; Waits for 128 lines.


Subsong0_Track3
    db 204
    db 1    ; New Instrument (1).
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 83
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 12
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 19
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 80
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 87
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 16
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 23
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 81
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 88
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 17
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 24
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 71
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 78
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 7
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 14
    db 61
    db 127    ; Waits for 128 lines.


Subsong0_Track4
    db 171
    db 2    ; New Instrument (2).
    db 60    ; Waits for 1 line.

    db 40
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 45
    db 60    ; Waits for 1 line.

    db 48
    db 60    ; Waits for 1 line.

    db 47
    db 60    ; Waits for 1 line.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 40
    db 60    ; Waits for 1 line.

    db 47
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 40
    db 60    ; Waits for 1 line.

    db 41
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 40
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 45
    db 60    ; Waits for 1 line.

    db 48
    db 60    ; Waits for 1 line.

    db 45
    db 60    ; Waits for 1 line.

    db 41
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 45
    db 60    ; Waits for 1 line.

    db 47
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 60    ; Waits for 1 line.

    db 50
    db 60    ; Waits for 1 line.

    db 47
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 40
    db 60    ; Waits for 1 line.

    db 38
    db 60    ; Waits for 1 line.

    db 36
    db 61
    db 127    ; Waits for 128 lines.


Subsong0_Track5
    db 62 + 0 * 64    ; Optimized wait for 2 lines.

    db 176
    db 3    ; New Instrument (3).
    db 60    ; Waits for 1 line.

    db 47
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 45
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 52
    db 60    ; Waits for 1 line.

    db 50
    db 60    ; Waits for 1 line.

    db 47
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 52
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 50
    db 60    ; Waits for 1 line.

    db 47
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 60    ; Waits for 1 line.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 53
    db 60    ; Waits for 1 line.

    db 52
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 60    ; Waits for 1 line.

    db 50
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 47
    db 60    ; Waits for 1 line.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 50
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 47
    db 60    ; Waits for 1 line.

    db 43
    db 61
    db 127    ; Waits for 128 lines.


Subsong0_Track6
    db 201
    db 1    ; New Instrument (1).
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 80
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 9
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 16
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 80
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 87
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 16
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 23
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 81
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 88
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 17
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 24
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 71
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 78
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 7
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 14
    db 61
    db 127    ; Waits for 128 lines.


Subsong0_Track7
    db 168
    db 2    ; New Instrument (2).
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 45
    db 60    ; Waits for 1 line.

    db 48
    db 60    ; Waits for 1 line.

    db 47
    db 60    ; Waits for 1 line.

    db 45
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 40
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 47
    db 60    ; Waits for 1 line.

    db 52
    db 60    ; Waits for 1 line.

    db 50
    db 60    ; Waits for 1 line.

    db 47
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 40
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 41
    db 60    ; Waits for 1 line.

    db 45
    db 60    ; Waits for 1 line.

    db 48
    db 60    ; Waits for 1 line.

    db 53
    db 60    ; Waits for 1 line.

    db 52
    db 60    ; Waits for 1 line.

    db 48
    db 60    ; Waits for 1 line.

    db 45
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 38
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 47
    db 60    ; Waits for 1 line.

    db 50
    db 60    ; Waits for 1 line.

    db 48
    db 60    ; Waits for 1 line.

    db 47
    db 60    ; Waits for 1 line.

    db 43
    db 61
    db 127    ; Waits for 128 lines.


Subsong0_Track8
    db 62 + 0 * 64    ; Optimized wait for 2 lines.

    db 176
    db 3    ; New Instrument (3).
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 52
    db 60    ; Waits for 1 line.

    db 50
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 47
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 47
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 47
    db 60    ; Waits for 1 line.

    db 50
    db 60    ; Waits for 1 line.

    db 52
    db 62 + 3 * 64    ; Optimized wait for 5 lines.

    db 45
    db 60    ; Waits for 1 line.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 45
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 53
    db 60    ; Waits for 1 line.

    db 52
    db 60    ; Waits for 1 line.

    db 47
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 50
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 60    ; Waits for 1 line.

    db 45
    db 61
    db 127    ; Waits for 128 lines.


Subsong0_Track9
    db 204
    db 1    ; New Instrument (1).
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 83
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 12
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 19
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 81
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 88
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 17
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 24
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 71
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 78
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 7
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 14
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 76
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 83
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 12
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 19
    db 61
    db 127    ; Waits for 128 lines.


Subsong0_Track10
    db 171
    db 2    ; New Instrument (2).
    db 60    ; Waits for 1 line.

    db 40
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 48
    db 60    ; Waits for 1 line.

    db 47
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 40
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 45
    db 60    ; Waits for 1 line.

    db 41
    db 60    ; Waits for 1 line.

    db 45
    db 60    ; Waits for 1 line.

    db 48
    db 60    ; Waits for 1 line.

    db 50
    db 60    ; Waits for 1 line.

    db 48
    db 60    ; Waits for 1 line.

    db 45
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 40
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 45
    db 60    ; Waits for 1 line.

    db 47
    db 60    ; Waits for 1 line.

    db 48
    db 60    ; Waits for 1 line.

    db 50
    db 60    ; Waits for 1 line.

    db 52
    db 60    ; Waits for 1 line.

    db 55
    db 60    ; Waits for 1 line.

    db 52
    db 60    ; Waits for 1 line.

    db 50
    db 60    ; Waits for 1 line.

    db 48
    db 60    ; Waits for 1 line.

    db 47
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 40
    db 60    ; Waits for 1 line.

    db 38
    db 61
    db 127    ; Waits for 128 lines.


Subsong0_Track11
    db 176
    db 3    ; New Instrument (3).
    db 60    ; Waits for 1 line.

    db 47
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 60    ; Waits for 1 line.

    db 50
    db 62 + 3 * 64    ; Optimized wait for 5 lines.

    db 48
    db 60    ; Waits for 1 line.

    db 45
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 41
    db 60    ; Waits for 1 line.

    db 45
    db 60    ; Waits for 1 line.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 60    ; Waits for 1 line.

    db 47
    db 60    ; Waits for 1 line.

    db 45
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 41
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 40
    db 60    ; Waits for 1 line.

    db 38
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 45
    db 60    ; Waits for 1 line.

    db 47
    db 60    ; Waits for 1 line.

    db 48
    db 60    ; Waits for 1 line.

    db 50
    db 60    ; Waits for 1 line.

    db 48
    db 60    ; Waits for 1 line.

    db 47
    db 61
    db 127    ; Waits for 128 lines.


; The speed tracks
Subsong0_SpeedTrack0
    db 255    ; Wait for 128 lines.

; The event tracks
Subsong0_EventTrack0
    db 255    ; Wait for 128 lines.

Subsong0_DisarkByteRegionEnd0
