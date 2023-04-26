/*
 * Author: Caden Parajuli - caden.parajuli@bc.edu
 */

/* Header guards */
#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <stdlib.h>

#include "types.h"
#include "hash_table.h"

/* Forward typedef to resolve cyclic header inclusions */
typedef struct Type Type;

typedef struct Args Args;
typedef struct SymbolTable SymbolTable;
typedef struct TableEntry TableEntry;
typedef struct VarSymbol VarSymbol;
typedef struct TypeSymbol TypeSymbol;
typedef struct FunSymbol FunSymbol;

struct SymbolTable {
    HashTable * hash_table;
    SymbolTable * next;
};

struct VarSymbol {
    char * name;
    Type * type;
    int declared_at;
};

struct TypeSymbol {
    char * name;
    Type * type;
    int declared_at;
};

struct FunSymbol {
    /** Used to store functions and operators */
    char * name;
    Type * type;
    SymbolTable * symbol_table;
    Args ** args;
    int declared_at;
};

struct Args {
    /* name should be a key for the symbol table of the fun/op */
    char * name;
    Args * next;
};

SymbolTable * new_symbol_table(size_t size);
void free_table(SymbolTable * table);
void * get_symbol_current_scope(SymbolTable * table, const char * key);
void * get_symbol_lexical_scope(SymbolTable * table, const char * key);
int set_symbol(SymbolTable * table, const char * key, void * value);
int unset_symbol(SymbolTable * table, const char * key);

#endif