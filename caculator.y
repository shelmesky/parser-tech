/* Companion source code for "flex & bison", published by O'Reilly
 * Media, ISBN 978-0-596-15597-1
 * Copyright (c) 2009, Taughannock Networks. All rights reserved.
 * See the README file for license conditions and contact info.
 * $Header: /home/johnl/flnb/code/RCS/fb3-2.y,v 2.1 2009/11/08 02:53:18 johnl Exp $
 */
/* calculator with AST */

%{
#  include <stdio.h>
#  include <stdlib.h>
#  include "caculator.h"
%}

%union {
  struct ast *a;
  double d;
  struct symbol *s;		/* which symbol */
  struct symlist *sl;
  int fn;			/* which function */
}

// 声明token
// 这些终结符在词法分析中被设置了值，且返回了终结符的类型
/* declare tokens */
%token <d> NUMBER
%token <s> NAME
%token <fn> FUNC
%token EOL

// 这些是关键字，无法设置值
%token IF THEN ELSE WHILE DO LET

//设置结合性和优先级
%nonassoc <fn> CMP
%right '='
%left '+' '-'
%left '*' '/'
%nonassoc '|' UMINUS

// 这些是非终结符，给它们赋予一个类型
// 非终结符会被推导为终结符，所以这些类型是由其推导出的其他非终结符号和终结符号构成的
// 例如有 NAME -> exp -> stmt
// bison的LALR(1)使用自底向上的方式推导，从一个非终结符最终归约为AST的根
%type <a> exp stmt list explist
%type <sl> symlist

%start calclist

%%

stmt: IF exp THEN list           { $$ = newflow('I', $2, $4, NULL); }	// if (表达式) then 语句列表
   | IF exp THEN list ELSE list  { $$ = newflow('I', $2, $4, $6); }	// if (表达式) then 语句列表 else 语句列表
   | WHILE exp DO list           { $$ = newflow('W', $2, $4, NULL); }	// while (表达式) do 语句列表
   | exp								// 表达式
;

// 语句列表: 右递归
list: /* nothing */ { $$ = NULL; }
   | stmt ';' list { if ($3 == NULL)
	                $$ = $1;
                      else
			$$ = newast('L', $1, $3);
                    }
   ;

exp: exp CMP exp          { $$ = newcmp($2, $1, $3); }
   | exp '+' exp          { $$ = newast('+', $1,$3); }
   | exp '-' exp          { $$ = newast('-', $1,$3);}
   | exp '*' exp          { $$ = newast('*', $1,$3); }
   | exp '/' exp          { $$ = newast('/', $1,$3); }
   | '|' exp              { $$ = newast('|', $2, NULL); }
   | '(' exp ')'          { $$ = $2; }
   | '-' exp %prec UMINUS { $$ = newast('M', $2, NULL); }
   | NUMBER               { $$ = newnum($1); }
   | FUNC '(' explist ')' { $$ = newfunc($1, $3); }
   | NAME                 { $$ = newref($1); }
   | NAME '=' exp         { $$ = newasgn($1, $3); }
   | NAME '(' explist ')' { $$ = newcall($1, $3); }
;

explist: exp
 | exp ',' explist  { $$ = newast('L', $1, $3); }
;
symlist: NAME       { $$ = newsymlist($1, NULL); }
 | NAME ',' symlist { $$ = newsymlist($1, $3); }
;

// 顶层语法
calclist: /* nothing */
  | calclist stmt EOL {	// 语句
    if(debug) dumpast($2, 0);
     printf("= %4.4g\n> ", eval($2));
     treefree($2);
    }
  | calclist LET NAME '(' symlist ')' '=' list EOL {	// 函数定义
                       dodef($3, $5, $8);
                       printf("Defined %s\n> ", $3->name); }

  | calclist error EOL { yyerrok; printf("> "); }
 ;
%%
