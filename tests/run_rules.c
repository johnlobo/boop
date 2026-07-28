#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "z80ex.h"

enum {
    MEMORY_SIZE = 65536,
    LOAD_ADDRESS = 0x0100,
    RETURN_ADDRESS = 0x0080,
    STACK_ADDRESS = 0xf000,
    BOARD_SIZE = 36,
    PLAYER_CATS = 4,
    PLAYER_KITTENS = 5,
    MAX_STEPS = 1000000
};

enum Piece {
    EMPTY = 0,
    P1_CAT = 1,
    P1_KITTEN = 2,
    P2_CAT = 3,
    P2_KITTEN = 4
};

struct Symbols {
    uint16_t board;
    uint16_t cursor_col;
    uint16_t cursor_row;
    uint16_t cursor_piece;
    uint16_t simulation_mode;
    uint16_t player1;
    uint16_t player2;
    uint16_t boop;
    uint16_t boop_cat;
};

struct Machine {
    uint8_t memory[MEMORY_SIZE];
    uint8_t image[MEMORY_SIZE];
    struct Symbols symbols;
    Z80EX_CONTEXT *cpu;
};

static int tests_run;
static int tests_failed;

static Z80EX_BYTE memory_read(Z80EX_CONTEXT *cpu, Z80EX_WORD address,
                              int m1_state, void *user_data) {
    struct Machine *machine = user_data;
    (void)cpu;
    (void)m1_state;
    return machine->memory[address];
}

static void memory_write(Z80EX_CONTEXT *cpu, Z80EX_WORD address,
                         Z80EX_BYTE value, void *user_data) {
    struct Machine *machine = user_data;
    (void)cpu;
    machine->memory[address] = value;
}

static Z80EX_BYTE port_read(Z80EX_CONTEXT *cpu, Z80EX_WORD port,
                            void *user_data) {
    (void)cpu;
    (void)port;
    (void)user_data;
    return 0xff;
}

static void port_write(Z80EX_CONTEXT *cpu, Z80EX_WORD port,
                       Z80EX_BYTE value, void *user_data) {
    (void)cpu;
    (void)port;
    (void)value;
    (void)user_data;
}

static Z80EX_BYTE interrupt_read(Z80EX_CONTEXT *cpu, void *user_data) {
    (void)cpu;
    (void)user_data;
    return 0xff;
}

static void die(const char *message, const char *path) {
    if (path != NULL) {
        fprintf(stderr, "%s: %s: %s\n", message, path, strerror(errno));
    } else {
        fprintf(stderr, "%s\n", message);
    }
    exit(EXIT_FAILURE);
}

static void load_binary(struct Machine *machine, const char *path) {
    FILE *file = fopen(path, "rb");
    size_t capacity = MEMORY_SIZE - LOAD_ADDRESS;
    size_t size;

    if (file == NULL) die("cannot open game binary", path);
    size = fread(machine->image + LOAD_ADDRESS, 1, capacity, file);
    if (ferror(file)) die("cannot read game binary", path);
    if (!feof(file)) die("game binary does not fit in Z80 memory", NULL);
    fclose(file);
    if (size == 0) die("game binary is empty", NULL);
}

static uint16_t *symbol_slot(struct Symbols *symbols, const char *name) {
    if (!strcmp(name, "_match_board")) return &symbols->board;
    if (!strcmp(name, "_cursor_col")) return &symbols->cursor_col;
    if (!strcmp(name, "_cursor_row")) return &symbols->cursor_row;
    if (!strcmp(name, "_cursor_piece")) return &symbols->cursor_piece;
    if (!strcmp(name, "_match_simulation_mode")) return &symbols->simulation_mode;
    if (!strcmp(name, "man_match_player1")) return &symbols->player1;
    if (!strcmp(name, "man_match_player2")) return &symbols->player2;
    if (!strcmp(name, "_match_boop")) return &symbols->boop;
    if (!strcmp(name, "_match_boop_cat")) return &symbols->boop_cat;
    return NULL;
}

static void load_symbols(struct Machine *machine, const char *path) {
    FILE *file = fopen(path, "r");
    char line[256];
    char name[128];
    unsigned address;

    if (file == NULL) die("cannot open linker symbols", path);
    while (fgets(line, sizeof line, file) != NULL) {
        uint16_t *slot;
        if (sscanf(line, "DEF %127s 0x%x", name, &address) != 2) continue;
        slot = symbol_slot(&machine->symbols, name);
        if (slot != NULL && address < MEMORY_SIZE) *slot = (uint16_t)address;
    }
    fclose(file);

    if (!machine->symbols.board || !machine->symbols.cursor_col ||
        !machine->symbols.cursor_row || !machine->symbols.cursor_piece ||
        !machine->symbols.simulation_mode || !machine->symbols.player1 ||
        !machine->symbols.player2 || !machine->symbols.boop ||
        !machine->symbols.boop_cat) {
        die("one or more required symbols are missing from the .noi file", NULL);
    }
}

static void reset_fixture(struct Machine *machine) {
    memcpy(machine->memory, machine->image, MEMORY_SIZE);
    memset(machine->memory + machine->symbols.board, EMPTY, BOARD_SIZE);
    memset(machine->memory + machine->symbols.player1, 0, 6);
    memset(machine->memory + machine->symbols.player2, 0, 6);
    machine->memory[machine->symbols.simulation_mode] = 1;
    machine->memory[RETURN_ADDRESS] = 0x76; /* HALT */
    z80ex_reset(machine->cpu);
}

static uint8_t *cell(struct Machine *machine, int row, int col) {
    return &machine->memory[machine->symbols.board + row * 6 + col];
}

static void place(struct Machine *machine, int row, int col, enum Piece piece) {
    *cell(machine, row, col) = (uint8_t)piece;
}

static void run_routine(struct Machine *machine, uint16_t address) {
    unsigned steps;
    uint16_t sp = STACK_ADDRESS - 2;

    machine->memory[sp] = RETURN_ADDRESS & 0xff;
    machine->memory[sp + 1] = RETURN_ADDRESS >> 8;
    z80ex_set_reg(machine->cpu, regSP, sp);
    z80ex_set_reg(machine->cpu, regPC, address);

    for (steps = 0; steps < MAX_STEPS; ++steps) {
        z80ex_step(machine->cpu);
        if (z80ex_doing_halt(machine->cpu)) return;
    }
    die("Z80 routine did not return before the instruction limit", NULL);
}

static void boop_from(struct Machine *machine, int row, int col, int cat) {
    machine->memory[machine->symbols.cursor_row] = (uint8_t)row;
    machine->memory[machine->symbols.cursor_col] = (uint8_t)col;
    machine->memory[machine->symbols.cursor_piece] = cat ? 0 : 1;
    run_routine(machine, cat ? machine->symbols.boop_cat : machine->symbols.boop);
}

static void report(const char *name, int passed) {
    ++tests_run;
    if (passed) {
        printf("ok %d - %s\n", tests_run, name);
    } else {
        ++tests_failed;
        printf("not ok %d - %s\n", tests_run, name);
    }
}

static int board_equals(struct Machine *machine, const uint8_t expected[BOARD_SIZE]) {
    return memcmp(machine->memory + machine->symbols.board,
                  expected, BOARD_SIZE) == 0;
}

static void test_kitten_pushes_kitten(struct Machine *machine) {
    uint8_t expected[BOARD_SIZE] = {0};
    reset_fixture(machine);
    place(machine, 2, 2, P1_KITTEN);
    place(machine, 2, 3, P2_KITTEN);
    expected[2 * 6 + 2] = P1_KITTEN;
    expected[2 * 6 + 4] = P2_KITTEN;
    boop_from(machine, 2, 2, 0);
    report("a kitten pushes an adjacent kitten", board_equals(machine, expected));
}

static void test_kitten_does_not_push_cat(struct Machine *machine) {
    uint8_t expected[BOARD_SIZE] = {0};
    reset_fixture(machine);
    place(machine, 2, 2, P1_KITTEN);
    place(machine, 2, 3, P2_CAT);
    expected[2 * 6 + 2] = P1_KITTEN;
    expected[2 * 6 + 3] = P2_CAT;
    boop_from(machine, 2, 2, 0);
    report("a kitten does not push a cat", board_equals(machine, expected));
}

static void test_cat_pushes_cat(struct Machine *machine) {
    uint8_t expected[BOARD_SIZE] = {0};
    reset_fixture(machine);
    place(machine, 3, 3, P1_CAT);
    place(machine, 2, 2, P2_CAT);
    expected[3 * 6 + 3] = P1_CAT;
    expected[1 * 6 + 1] = P2_CAT;
    boop_from(machine, 3, 3, 1);
    report("a cat pushes another cat diagonally", board_equals(machine, expected));
}

static void test_occupied_destination_blocks_push(struct Machine *machine) {
    uint8_t expected[BOARD_SIZE] = {0};
    reset_fixture(machine);
    place(machine, 2, 1, P1_CAT);
    place(machine, 2, 2, P2_KITTEN);
    place(machine, 2, 3, P1_KITTEN);
    memcpy(expected, machine->memory + machine->symbols.board, BOARD_SIZE);
    boop_from(machine, 2, 1, 1);
    report("an occupied destination blocks a push", board_equals(machine, expected));
}

static void test_kitten_ejection_returns_reserve(struct Machine *machine) {
    uint8_t expected[BOARD_SIZE] = {0};
    reset_fixture(machine);
    place(machine, 0, 1, P1_KITTEN);
    place(machine, 0, 0, P2_KITTEN);
    expected[0 * 6 + 1] = P1_KITTEN;
    boop_from(machine, 0, 1, 0);
    report("an ejected P2 kitten returns to its reserve",
           board_equals(machine, expected) &&
           machine->memory[machine->symbols.player2 + PLAYER_KITTENS] == 1);
}

static void test_cat_ejection_returns_reserve(struct Machine *machine) {
    uint8_t expected[BOARD_SIZE] = {0};
    reset_fixture(machine);
    place(machine, 4, 5, P2_CAT);
    place(machine, 5, 5, P1_CAT);
    expected[4 * 6 + 5] = P2_CAT;
    boop_from(machine, 4, 5, 1);
    report("an ejected P1 cat returns to its reserve",
           board_equals(machine, expected) &&
           machine->memory[machine->symbols.player1 + PLAYER_CATS] == 1);
}

static void test_all_eight_directions(struct Machine *machine) {
    static const int directions[8][2] = {
        {-1, -1}, {-1, 0}, {-1, 1}, {0, -1},
        {0, 1}, {1, -1}, {1, 0}, {1, 1}
    };
    uint8_t expected[BOARD_SIZE] = {0};
    int i;
    reset_fixture(machine);
    place(machine, 2, 2, P1_CAT);
    expected[2 * 6 + 2] = P1_CAT;
    for (i = 0; i < 8; ++i) {
        int row = 2 + directions[i][0];
        int col = 2 + directions[i][1];
        int dest_row = 2 + 2 * directions[i][0];
        int dest_col = 2 + 2 * directions[i][1];
        place(machine, row, col, P2_KITTEN);
        expected[dest_row * 6 + dest_col] = P2_KITTEN;
    }
    boop_from(machine, 2, 2, 1);
    report("a cat applies boop in all eight directions", board_equals(machine, expected));
}

int main(int argc, char **argv) {
    struct Machine machine;

    if (argc != 3) {
        fprintf(stderr, "usage: %s GAME.bin GAME.noi\n", argv[0]);
        return EXIT_FAILURE;
    }
    memset(&machine, 0, sizeof machine);
    load_binary(&machine, argv[1]);
    load_symbols(&machine, argv[2]);
    machine.cpu = z80ex_create(memory_read, &machine, memory_write, &machine,
                               port_read, &machine, port_write, &machine,
                               interrupt_read, &machine);
    if (machine.cpu == NULL) die("cannot create Z80 emulator", NULL);

    printf("TAP version 13\n");
    test_kitten_pushes_kitten(&machine);
    test_kitten_does_not_push_cat(&machine);
    test_cat_pushes_cat(&machine);
    test_occupied_destination_blocks_push(&machine);
    test_kitten_ejection_returns_reserve(&machine);
    test_cat_ejection_returns_reserve(&machine);
    test_all_eight_directions(&machine);
    printf("1..%d\n", tests_run);

    z80ex_destroy(machine.cpu);
    if (tests_failed) {
        fprintf(stderr, "%d of %d tests failed\n", tests_failed, tests_run);
        return EXIT_FAILURE;
    }
    printf("All %d Z80 rules tests passed.\n", tests_run);
    return EXIT_SUCCESS;
}
