; Subsong 1
; ----------------------
Subsong1_DisarkByteRegionStart0
Subsong1_Start
    db 2    ; ReplayFrequency (0=12.5hz, 1=25hz, 2=50hz, 3=100hz, 4=150hz, 5=300hz).
    db 1    ; Digichannel (>=0).
    db 1    ; PSG count (>0).
    db 0    ; Loop start index (>=0).
    db 5    ; End index (>=0).
    db 8    ; Initial speed (>=0).
    db 28    ; Base note index (>=0).

Subsong1_Linker
Subsong1_DisarkPointerRegionStart1
; Position 0
Subsong1_Linker_Loop
    dw Subsong1_Track0
    dw Subsong1_Track1
    dw Subsong1_Track2
    dw Subsong1_LinkerBlock0
; Position 1
    dw Subsong1_Track3
    dw Subsong1_Track4
    dw Subsong1_Track5
    dw Subsong1_LinkerBlock0
; Position 2
    dw Subsong1_Track0
    dw Subsong1_Track6
    dw Subsong1_Track7
    dw Subsong1_LinkerBlock0
; Position 3
    dw Subsong1_Track3
    dw Subsong1_Track8
    dw Subsong1_Track9
    dw Subsong1_LinkerBlock0
; Position 4
    dw Subsong1_Track10
    dw Subsong1_Track11
    dw Subsong1_Track12
    dw Subsong1_LinkerBlock0
; Position 5
    dw Subsong1_Track13
    dw Subsong1_Track14
    dw Subsong1_Track15
    dw Subsong1_LinkerBlock0
Subsong1_DisarkPointerRegionEnd1
    dw 0    ; Loop.
Subsong1_DisarkWordForceReference2
    dw Subsong1_Linker_Loop

Subsong1_LinkerBlock0
    db 64    ; Height.
    db 0    ; Transposition 0.
    db 0    ; Transposition 1.
    db 0    ; Transposition 2.
Subsong1_DisarkWordForceReference3
    dw Subsong1_SpeedTrack0    ; SpeedTrack address.
Subsong1_DisarkWordForceReference4
    dw Subsong1_EventTrack0    ; EventTrack address.


Subsong1_Track0
    db 204
    db 4    ; New Instrument (4).
    db 2    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 83
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 76
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 83
    db 0    ; Index to an effect block.
    db 60    ; Waits for 1 line.

    db 12
    db 60    ; Waits for 1 line.

    db 72
    db 2    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 79
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 72
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 79
    db 0    ; Index to an effect block.
    db 60    ; Waits for 1 line.

    db 8
    db 60    ; Waits for 1 line.

    db 79
    db 2    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 86
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 79
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 86
    db 0    ; Index to an effect block.
    db 60    ; Waits for 1 line.

    db 15
    db 60    ; Waits for 1 line.

    db 74
    db 2    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 81
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 74
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 81
    db 0    ; Index to an effect block.
    db 60    ; Waits for 1 line.

    db 10
    db 61
    db 127    ; Waits for 128 lines.


Subsong1_Track1
    db 235
    db 6    ; New Instrument (6).
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 39
    db 60    ; Waits for 1 line.

    db 41
    db 60    ; Waits for 1 line.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 39
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 36
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 39
    db 60    ; Waits for 1 line.

    db 41
    db 60    ; Waits for 1 line.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 41
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 38
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 36
    db 61
    db 127    ; Waits for 128 lines.


Subsong1_Track2
    db 240
    db 6    ; New Instrument (6).
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 39
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 39
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 41
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 44
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 41
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 61
    db 127    ; Waits for 128 lines.


Subsong1_Track3
    db 204
    db 4    ; New Instrument (4).
    db 2    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 83
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 76
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 83
    db 0    ; Index to an effect block.
    db 60    ; Waits for 1 line.

    db 12
    db 60    ; Waits for 1 line.

    db 72
    db 2    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 79
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 72
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 79
    db 0    ; Index to an effect block.
    db 60    ; Waits for 1 line.

    db 8
    db 60    ; Waits for 1 line.

    db 79
    db 2    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 86
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 79
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 86
    db 0    ; Index to an effect block.
    db 60    ; Waits for 1 line.

    db 15
    db 60    ; Waits for 1 line.

    db 71
    db 2    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 78
    db 0    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 71
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 78
    db 0    ; Index to an effect block.
    db 60    ; Waits for 1 line.

    db 7
    db 61
    db 127    ; Waits for 128 lines.


Subsong1_Track4
    db 171
    db 5    ; New Instrument (5).
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 60    ; Waits for 1 line.

    db 48
    db 60    ; Waits for 1 line.

    db 50
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 51
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 41
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 41
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 38
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 36
    db 61
    db 127    ; Waits for 128 lines.


Subsong1_Track5
    db 167
    db 5    ; New Instrument (5).
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 44
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 51
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 50
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 39
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 41
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 38
    db 61
    db 127    ; Waits for 128 lines.


Subsong1_Track6
    db 176
    db 6    ; New Instrument (6).
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 51
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 50
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 60    ; Waits for 1 line.

    db 48
    db 60    ; Waits for 1 line.

    db 50
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 53
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 50
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 51
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 50
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 61
    db 127    ; Waits for 128 lines.


Subsong1_Track7
    db 176
    db 6    ; New Instrument (6).
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 39
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 39
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 41
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 44
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 41
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 61
    db 127    ; Waits for 128 lines.


Subsong1_Track8
    db 171
    db 6    ; New Instrument (6).
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 39
    db 60    ; Waits for 1 line.

    db 41
    db 60    ; Waits for 1 line.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 39
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 36
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 39
    db 60    ; Waits for 1 line.

    db 41
    db 60    ; Waits for 1 line.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 41
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 38
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 36
    db 61
    db 127    ; Waits for 128 lines.


Subsong1_Track9
    db 167
    db 6    ; New Instrument (6).
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 44
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 51
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 50
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 39
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 41
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 38
    db 61
    db 127    ; Waits for 128 lines.


Subsong1_Track10
    db 200
    db 4    ; New Instrument (4).
    db 2    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 79
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 8
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 79
    db 0    ; Index to an effect block.
    db 60    ; Waits for 1 line.

    db 8
    db 60    ; Waits for 1 line.

    db 74
    db 2    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 81
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 10
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 81
    db 0    ; Index to an effect block.
    db 60    ; Waits for 1 line.

    db 10
    db 60    ; Waits for 1 line.

    db 76
    db 2    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 83
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 12
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 83
    db 0    ; Index to an effect block.
    db 60    ; Waits for 1 line.

    db 12
    db 60    ; Waits for 1 line.

    db 72
    db 2    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 79
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 8
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 79
    db 0    ; Index to an effect block.
    db 60    ; Waits for 1 line.

    db 8
    db 61
    db 127    ; Waits for 128 lines.


Subsong1_Track11
    db 176
    db 6    ; New Instrument (6).
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 51
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 55
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 53
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 51
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 41
    db 60    ; Waits for 1 line.

    db 43
    db 60    ; Waits for 1 line.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 50
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 39
    db 61
    db 127    ; Waits for 128 lines.


Subsong1_Track12
    db 172
    db 6    ; New Instrument (6).
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 39
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 36
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 51
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 50
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 41
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 39
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 61
    db 127    ; Waits for 128 lines.


Subsong1_Track13
    db 197
    db 4    ; New Instrument (4).
    db 2    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 76
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 5
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 76
    db 0    ; Index to an effect block.
    db 60    ; Waits for 1 line.

    db 5
    db 60    ; Waits for 1 line.

    db 74
    db 2    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 81
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 10
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 81
    db 0    ; Index to an effect block.
    db 60    ; Waits for 1 line.

    db 10
    db 60    ; Waits for 1 line.

    db 71
    db 2    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 78
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 7
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 78
    db 0    ; Index to an effect block.
    db 60    ; Waits for 1 line.

    db 7
    db 60    ; Waits for 1 line.

    db 76
    db 2    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 83
    db 1    ; Index to an effect block.
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 12
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 83
    db 0    ; Index to an effect block.
    db 60    ; Waits for 1 line.

    db 12
    db 61
    db 127    ; Waits for 128 lines.


Subsong1_Track14
    db 171
    db 6    ; New Instrument (6).
    db 60    ; Waits for 1 line.

    db 46
    db 60    ; Waits for 1 line.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 51
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 53
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 51
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 50
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 50
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 36
    db 61
    db 127    ; Waits for 128 lines.


Subsong1_Track15
    db 176
    db 6    ; New Instrument (6).
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 39
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 41
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 50
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 51
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 48
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 46
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 44
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 43
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 41
    db 62 + 1 * 64    ; Optimized wait for 3 lines.

    db 39
    db 61
    db 127    ; Waits for 128 lines.


; The speed tracks
Subsong1_SpeedTrack0
    db 255    ; Wait for 128 lines.

; The event tracks
Subsong1_EventTrack0
    db 255    ; Wait for 128 lines.

Subsong1_DisarkByteRegionEnd0
