#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

#define MAX_DATA 512
#define MAX_ROWS 100

struct Address {
    int id;
    int set;
    int age;
    char name[MAX_DATA];
    char email[MAX_DATA];
};

struct Database {
    struct Address rows[MAX_ROWS];
};

struct Connection {
    FILE *file;
    struct Database *db;
};

struct Connection *conn = NULL;

void Database_close()
{
    if(conn) {
        if(conn->file) fclose(conn->file);
        if(conn->db) free(conn->db);
        free(conn);
    }
}

void die(const char *message)
{
    if(errno) {
        perror(message);
    } else {
        printf("ERROR: %s\n", message);
    }

    Database_close();
    exit(1);
}

void Address_print(struct Address *addr)
{
    printf("%d %d %s %s\n",
            addr->id,addr->age, addr->name, addr->email);
}

void Database_load()
{
    int rc = fread(conn->db, sizeof(struct Database), 1, conn->file);
    if(rc != 1) die("Failed to load database.");
}

void Database_open(const char *filename, char mode)
{
    conn = malloc(sizeof(struct Connection));
    if(!conn) die("Memory error");

    conn->db = malloc(sizeof(struct Database));
    if(!conn->db) die("Memory error");

    if(mode == 'c') {
        conn->file = fopen(filename, "w");
    } else {
        conn->file = fopen(filename, "r+");

        if(conn->file) {
            Database_load();
        }
    }

    if(!conn->file) die("Failed to open the file");

}

void Database_write()
{
    rewind(conn->file);

    int rc = fwrite(conn->db, sizeof(struct Database), 1, conn->file);
    if(rc != 1) die("Failed to write database.");

    rc = fflush(conn->file);
    if(rc == -1) die("Cannot flush database.");
}

void Database_create()
{
    int i = 0;

    for(i = 0; i < MAX_ROWS; i++) {
        // make a prototype to initialize it
        struct Address addr = {.id = i, .set = 0};
        // then just assign it
        conn->db->rows[i] = addr;
    }
}

void Database_set(int id, int age, const char *name, const char *email)
{
    struct Address *addr = &conn->db->rows[id];
    if(addr->set) die("Already set, delete it first");

    addr->set = 1;
    addr->age = age;
    // WARNING: bug, read the "How To Break It" and fix this
    char *res = strncpy(addr->name, name, MAX_DATA);
    // demonstrate the strncpy bug
    if(!res) die("Name copy failed");

    res = strncpy(addr->email, email, MAX_DATA);
    if(!res) die("Email copy failed");

    addr->name[MAX_DATA-1] = '\0';
    addr->email[MAX_DATA-1] = '\0';
}

void Database_get(int id)
{
    struct Address *addr = &conn->db->rows[id];

    if(addr->set) {
        Address_print(addr);
    } else {
        die("ID is not set");
    }
}

void Database_find(char *pattern, char *find_key)
{
    struct Database *db = conn->db;

    for(int i = 0; i < MAX_ROWS; i++){
        struct Address *addr = &db->rows[i];
        if (strcmp(pattern, "name") == 0){
            if (strcmp(addr->name, find_key) == 0 && addr->set) {
                Address_print(addr);
            }
        }
        else if(strcmp(pattern, "email") == 0){
            if (strcmp(addr->email, find_key) == 0 && addr->set) {
                Address_print(addr);
            }
        }
        else if(strcmp(pattern, "age") == 0){
            if (addr->age == atoi(find_key) && addr->set) {
                Address_print(addr);
            }
        }
        else{
            die("Input the f**king right attribute!");
        }
    }
}

void Database_delete(int id)
{
    struct Address addr = {.id = id, .set = 0};
    conn->db->rows[id] = addr;
}

void Database_list()
{
    int i = 0;
    struct Database *db = conn->db;

    for(i = 0; i < MAX_ROWS; i++) {
        struct Address *cur = &db->rows[i];

        if(cur->set) {
            Address_print(cur);
        }
    }
}



int main(int argc, char *argv[])
{
    if(argc < 3) die("USAGE: ex17 <dbfile> <action> [action params]");

    char *filename = argv[1];
    char action = argv[2][0];
    Database_open(filename, action);
    int id = 0;

    if(argc > 3) id = atoi(argv[3]);
    if(id >= MAX_ROWS) die("There's not that many records.");

    switch(action) {
        case 'c':
            Database_create();
            Database_write();
            break;

        case 'g':
            if(argc != 4) die("Need an id to get");

            Database_get(id);
            break;

        case 's':
            if(argc != 7) die("Need id, age, name, email to set");

            Database_set(id, atoi(argv[4]), argv[5], argv[6]);
            Database_write();
            break;

        case 'd':
            if(argc != 4) die("Need id to delete");

            Database_delete(id);
            Database_write();
            break;

        case 'l':
            Database_list();
            break;
        case 'f':
            if(argc != 5) die("Need patern, key to set");
            Database_find(argv[3],argv[4]);
            break;
        default:
            die("Invalid action, only: c=create, g=get, s=set, d=del, l=list");
    }

    Database_close();

    return 0;
}