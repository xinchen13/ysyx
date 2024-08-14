#include "sdb.h"

static elfStFunc nemu_elfstfunc;

void init_ftrace_stfunc(const char *elf_file) {
    // elf_file == NULL
    if (elf_file == NULL) {
        printf("no valid elf_file, please check\n");
        return;
    }

    // init
    for (int i = 0; i < ELF_ST_FUNC_NUM; i++) {
        for (int j = 0; j < ELF_ST_NAME_LEN; j++) {
            nemu_elfstfunc.name[i][j] = '\0';
        }
        nemu_elfstfunc.addr[i] = 0x00000000;
        nemu_elfstfunc.size[i] = 0;
    }
    nemu_elfstfunc.valid_func = 0;

    // get file pointer: fp
    // printf("elf_file = %s\n", elf_file); // for debug
    FILE *fp = fopen(elf_file, "rb");
    if (!fp) {
        perror("Error opening file\n");
        exit(EXIT_FAILURE);
    }

    // read elf header: elf_header
    Elf32_Ehdr elf_header;
    if (fread(&elf_header, sizeof(Elf32_Ehdr), 1, fp) <= 0) {
        perror("Error reading\n");
        exit(EXIT_FAILURE);
    }

    // get section header: sh_table
    Elf32_Shdr sh_table[elf_header.e_shnum];
    fseek(fp, elf_header.e_shoff, SEEK_SET);
    if (fread(sh_table, sizeof(Elf32_Shdr), elf_header.e_shnum, fp) <= 0) {
        perror("Error reading\n");
        exit(EXIT_FAILURE);
    }

    // get index of .strtab and .symtab
    int symtab_index = -1, strtab_index = -1;
    for (int i = 0; i < elf_header.e_shnum; i++) {
        if (sh_table[i].sh_type == SHT_SYMTAB) {
            symtab_index = i;
            break;
        }
    }
    for (int i = 0; i < elf_header.e_shnum; i++) {
        if (sh_table[i].sh_type == SHT_STRTAB) {
            strtab_index = i;
            break;
        }
    }
    if (symtab_index == -1 || strtab_index == -1) {
        fprintf(stderr, "Symbol table or string table not found.\n");
        fclose(fp);
        exit(EXIT_FAILURE);
    }
    // debug
    // printf("INDEX: symtab = %d, strtab = %d\n", symtab_index, strtab_index);

    // read strtab first
    char string_table[sh_table[strtab_index].sh_size];
    fseek(fp, sh_table[strtab_index].sh_offset, SEEK_SET);
    if (fread(string_table, sh_table[strtab_index].sh_size, 1, fp) <= 0) {
        perror("Error reading\n");
        exit(EXIT_FAILURE);
    }

    // read symtab
    fseek(fp, sh_table[symtab_index].sh_offset, SEEK_SET);
    Elf32_Sym symbol;

    for (int i = 0; i < sh_table[symtab_index].sh_size / sizeof(Elf32_Sym); i++) {
        if (fread(&symbol, sizeof(Elf32_Sym), 1, fp) <= 0) {
            perror("Error reading\n");
            exit(EXIT_FAILURE);
        }

        // fetch name from strtab
        const char *symbol_name = string_table + symbol.st_name;

        if (ELF32_ST_TYPE(symbol.st_info) == STT_FUNC) {
            strcpy(nemu_elfstfunc.name[nemu_elfstfunc.valid_func], symbol_name);
            nemu_elfstfunc.addr[nemu_elfstfunc.valid_func] = symbol.st_value;
            nemu_elfstfunc.size[nemu_elfstfunc.valid_func] = symbol.st_size;
            nemu_elfstfunc.valid_func++;
        }
    }
    // display_elfstfunc(elfstfunc);  // for debug
}

void display_elfstfunc() {
    for (int i = 0; i < nemu_elfstfunc.valid_func; i++) {
        printf("func %d: name=%s, addr=%08x, size=%d\n", i, nemu_elfstfunc.name[i], nemu_elfstfunc.addr[i], nemu_elfstfunc.size[i]);
    }
}

void ftrace_call(word_t curr_addr, word_t j_addr, int depth) {
    for (int i = 0; i < nemu_elfstfunc.valid_func; i++) {
        if ((j_addr >= nemu_elfstfunc.addr[i]) && (j_addr < nemu_elfstfunc.addr[i] + nemu_elfstfunc.size[i])) {
            printf(FMT_PADDR ":%*scall [%s@" FMT_PADDR "]\n", curr_addr, depth, "    ", nemu_elfstfunc.name[i], j_addr);
        }
    }
}

void ftrace_retn(word_t curr_addr, int depth) {
    for (int i = 0; i < nemu_elfstfunc.valid_func; i++) {
        if ((curr_addr >= nemu_elfstfunc.addr[i]) && (curr_addr < nemu_elfstfunc.addr[i] + nemu_elfstfunc.size[i])) {
            printf(FMT_PADDR ":%*sretn [%s]\n", curr_addr, depth, "    ", nemu_elfstfunc.name[i]);
        }
    }
}