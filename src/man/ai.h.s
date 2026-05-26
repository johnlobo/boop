;;-----------------------------LICENSE NOTICE------------------------------------
;;
;;  This program is free software: you can redistribute it and/or modify
;;  it under the terms of the GNU Lesser General Public License as published by
;;  the Free Software Foundation, either version 3 of the License, or
;;  (at your option) any later version.
;;
;;  This program is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU Lesser General Public License for more details.
;;
;;  You should have received a copy of the GNU Lesser General Public License
;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;-------------------------------------------------------------------------------

;;------------------------------------------------------------------------------
;; AI module: single-player opponent for boop.
;;
;; The AI always plays as Player 2. Difficulty level is chosen via
;; menu_level.s and stored in man_ai_level before man_ai_init is called.
;;
;; Difficulty levels (man_ai_level 0-3):
;;   0 = GATITO TIMIDO   - random, kitten-first, slow to play
;;   1 = GATO JUGUETON   - slight positional awareness
;;   2 = GATA ASTUTA     - defensive + offensive balance
;;   3 = MAESTRO FELINO  - full heuristic, fast
;;
;; Integration:
;;   man_match_update calls man_ai_update when num_players==1 AND P2's turn.
;;   man_match_init calls man_ai_init after setting up the board.
;;------------------------------------------------------------------------------

;;------------------------------------------------------------------------------
;; AI profile struct layout (6 bytes per profile, in _ai_profiles table):
;;   offset 0: delay_frames  - post-evaluation pause before playing
;;   offset 1: W_defense     - weight: opponent cat-pair reduction
;;   offset 2: W_align       - weight: own piece-pair improvement
;;   offset 3: W_center      - weight: center proximity bonus
;;   offset 4: W_kitten      - weight: 3-in-a-row kitten lines created
;;   offset 5: rand_mask     - AND mask for random noise added to score
;;------------------------------------------------------------------------------
AI_PROFILE_SIZE    = 6
AI_WIN_SENTINEL    = 255   ;; score used when a winning move is found

;;------------------------------------------------------------------------------
;; Public data
;;------------------------------------------------------------------------------
.globl man_ai_level           ;; byte 0-3: current AI difficulty (set by menu_level)

;;------------------------------------------------------------------------------
;; Public routines
;;------------------------------------------------------------------------------
.globl man_ai_init            ;; call before each AI turn (resets eval state)
.globl man_ai_update          ;; call every frame when it is P2's turn (1-player)
