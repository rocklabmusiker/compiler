 /*
  * Authors:
  *   Andrew Clark     - andrew.clark.6@bc.edu
  *   Alex Liu         - alex.liu@bc.edu
  *   Caden Parajuli   - caden.parajuli@bc.edu
  *   Micheal Lebreck  - michael.lebreck@bc.edu
  *   William Morrison - william.morrison.2@bc.edu
  */

%language "C"
%define parse.error detailed
%define api.pure full

%{
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>

extern char * yytext;
extern int yylval;
extern int yylex();
extern FILE *  yyin;
%}

%code provides {
int yyerror(const char * const msg);
}

/* yyunion */
%union{
    struct Node * node;
    char * string;
    int integer;
}

/* TOKENS */

/* Various brackets and other simple tokens */
%token LBRACE RBRACE LPAREN RPAREN LSQB RSQB COMMA SEMICOLON DOT BACKSLASH BACKTICK ARROW
/* Arithmetic and bitwise operators */
%token PLUS_OP MULT_OP BIT_AND_OP BIT_OR_OP BIT_NOT_OP BIT_XOR_OP
%token RPLUS_OP RMULT_OP RBIT_AND_OP RBIT_OR_OP RBIT_XOR_OP
/* Logical operators */
%token AND NOT OR XOR
/* Assignment and comparison operators */
%token ASSIGN_OP COMPARE_OP
/* Keywords */
%token FUN IF ELIF ELSE FOR WHILE IMPORT CASE SWITCH TYPE RETURN BREAK CONTINUE
/* Literals */
%token INT_LIT STR_LIT ID


/* PRECEDENCE */

/* if-elif-else parsing, lowest precedence */
%right THEN ELIF ELSE
/* Arrow */
%right ARROW
/* Dot */
%left DOT
/* Assignment operators */
%right ASSIGN_OP
/* Comparison operators */
%right COMPARE_OP
/* Logical operators */
%right NOT
%left AND
%left OR XOR
/* Arithmetic operators */
%left PLUS_OP
%right RPLUS_OP
%left MULT_OP
%right RMULT_OP
%right POW_OP
/* Binary operators */
%right BIT_NOT_OP
%left BIT_AND_OP
%left BIT_OR_OP BIT_XOR_OP
%right RBIT_AND_OP
%right RBIT_OR_OP RBIT_XOR_OP
/* Unary operator precedence */
%right UNARY

%%

program:
    statement_list
    ;

statement_list:
    statement
    | statement_list statement
    ;

/* TODO add more statement types */
statement:
    expr_statement
    | if_statement
    | function_def
    | control_statement
    | varible_declaration
    ;

varible_declaration:
    type
    ;

expr_statement:
    expr SEMICOLON
    ;

expr:
    assign_expr
    | expr assign_expr
    ;

assign_expr:
    logical_expr
    | ID ASSIGN_OP assign_expr
    ;

/* Note that the logical not precedence is still fairly low */
logical_expr:
    compare_expr
    | NOT logical_expr
    | logical_expr AND logical_expr
    | logical_expr OR logical_expr
    | logical_expr XOR logical_expr
    ;

compare_expr:
    bitwise_expr
    | bitwise_expr COMPARE_OP bitwise_expr
    ;

bitwise_expr:
    arithmetic_expr
    | bitwise_expr BIT_AND_OP bitwise_expr
    | bitwise_expr RBIT_AND_OP bitwise_expr
    | bitwise_expr BIT_OR_OP bitwise_expr
    | bitwise_expr RBIT_OR_OP bitwise_expr
    | bitwise_expr BIT_XOR_OP bitwise_expr
    | bitwise_expr RBIT_XOR_OP bitwise_expr
    ;

arithmetic_expr:
    unary_expr
    | arithmetic_expr POW_OP arithmetic_expr
    | arithmetic_expr MULT_OP arithmetic_expr
    | arithmetic_expr RMULT_OP arithmetic_expr
    | arithmetic_expr PLUS_OP arithmetic_expr
    | arithmetic_expr RPLUS_OP arithmetic_expr
    ;

/* NOTE I think these all need to be terminals for precedence to work, but feel free to simplify it if not */
unary_expr:
    member_expr
    | PLUS_OP logical_expr %prec UNARY
    | MULT_OP logical_expr %prec UNARY
    | BIT_AND_OP logical_expr %prec UNARY
    | BIT_OR_OP logical_expr %prec UNARY
    | BIT_NOT_OP logical_expr %prec UNARY
    | BIT_XOR_OP logical_expr %prec UNARY
    | RPLUS_OP logical_expr %prec UNARY
    | RMULT_OP logical_expr %prec UNARY
    | RBIT_AND_OP logical_expr %prec UNARY
    | RBIT_OR_OP logical_expr %prec UNARY
    | RBIT_XOR_OP logical_expr %prec UNARY
    ;

member_expr:
    primary_expr
    | member_expr DOT primary_expr
    | member_expr LSQB expr RSQB
    ;

primary_expr:
    ID
    | literal
    | LPAREN expr RPAREN
    | function_call
    ;

function_call:
    member_expr LPAREN argument_list RPAREN
    ;

argument_list:
    expr
    | argument_list COMMA expr
    ;

function_def:
    FUN ID LPAREN argument_list_specifier RPAREN ARROW type LBRACE statement_list RBRACE
    | FUN BACKTICK user_operator BACKTICK LPAREN argument_list_specifier RPAREN ARROW type LBRACE statement_list RBRACE
    /* Function definition with generic parameters, have to define more grammar rules first */
    /* | FUN ID LSQB generic_parameters RSQB LPAREN argument_list_specifier_with_generic RPAREN ARROW type_specifier_with_generics LBRACE statement_list RBRACE */
    ;

argument_list_specifier:
    argument_specifier
    | argument_list_specifier COMMA argument_specifier
    ;

argument_specifier:
    type ID
    ;

/* TODO: add pointer (or some sort of reference type) supprt, perhaps with `ptr` keyword, and add tuples. */
type:
    ID
    | ID LSQB INT_LIT RSQB      /* Arrays */
    | function_type
    ;

function_type:
    LPAREN type_list RPAREN ARROW type
    ;

type_list:
    type
    | type_list COMMA type
    ;

/* TODO Add more literal types */
literal:
    INT_LIT
    | STR_LIT
    ;

user_operator:
    PLUS_OP | MULT_OP | BIT_AND_OP | BIT_OR_OP | BIT_NOT_OP | BIT_XOR_OP
    | RPLUS_OP | RMULT_OP | RBIT_AND_OP | RBIT_OR_OP | RBIT_XOR_OP
    | ASSIGN_OP | COMPARE_OP
    ;

if_elif:
    IF LPAREN expr RPAREN LBRACE statement_list RBRACE %prec THEN
    | if_elif ELIF LPAREN expr RPAREN LBRACE statement_list RBRACE
    ;

if_statement:
    if_elif
    | if_elif ELSE LBRACE statement_list RBRACE
    ;

control_statement:
    RETURN expr SEMICOLON
    | BREAK expr SEMICOLON
    | CONTINUE expr SEMICOLON
    ;


%%

int yyerror(const char * const msg) {
    fprintf(stderr, "yyerror: %s\n", msg);
    return EXIT_FAILURE;
}
