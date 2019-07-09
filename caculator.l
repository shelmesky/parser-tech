/* Companion source code for "flex & bison", published by O'Reilly
 * Media, ISBN 978-0-596-15597-1
 * Copyright (c) 2009, Taughannock Networks. All rights reserved.
 * See the README file for license conditions and contact info.
 * $Header: /home/johnl/flnb/code/RCS/fb3-2.l,v 2.1 2009/11/08 02:53:18 johnl Exp $
 */
/* recognize tokens for the calculator */

%option noyywrap nodefault yylineno
%{
# include "caculator.h"
# include "caculator.tab.h"
%}

/* float exponent */
EXP	([Ee][-+]?[0-9]+)

%%
 /* single character ops */
"+" |
"-" |
"*" |
"/" |
"=" |
"|" |
"," |
";" |
"(" |
")"     { return yytext[0]; }

 /* 比较操作符, yylval是在.y文件中的联合类型 */
 /* 编译时词法和语法文件同时编译，所以这里可以直接设置yylval */
 /* comparison ops */
">"     { yylval.fn = 1; return CMP; }  // 设置fn值为某个操作符，并返回CMP类型
"<"     { yylval.fn = 2; return CMP; }
"<>"    { yylval.fn = 3; return CMP; }
"=="    { yylval.fn = 4; return CMP; }
">="    { yylval.fn = 5; return CMP; }
"<="    { yylval.fn = 6; return CMP; }

 /* 关键字 */

"if"    { return IF; }
"then"  { return THEN; }
"else"  { return ELSE; }
"while" { return WHILE; }
"do"    { return DO; }
"let"   { return LET;}

 /* 内置函数 */
"sqrt"  { yylval.fn = B_sqrt; return FUNC; }    // 设置fn为具体的函数，返回FUNC类型
"exp"   { yylval.fn = B_exp; return FUNC; }
"log"   { yylval.fn = B_log; return FUNC; }
"print" { yylval.fn = B_print; return FUNC; }

 /* debug hack */
"debug"[0-9]+ { debug = atoi(&yytext[5]); printf("debug set to %d\n", debug); }

 /* names */
[a-zA-Z][a-zA-Z0-9]*  { yylval.s = lookup(yytext); return NAME; }   // 设置yylval.s为lookup返回的一个symbol对象，返回NAME类型

[0-9]+"."[0-9]*{EXP}? |
"."?[0-9]+{EXP}? { yylval.d = atof(yytext); return NUMBER; }    // 设置yylval.d为转换后的浮点数，返回NUMBER类型

"//".*  
[ \t]   /* ignore white space */    // 忽略空白
\\\n    printf("c> "); /* ignore line continuation */   // 忽略新行，打印c>
"\n"    { return EOL; }

.	{ yyerror("Mystery character %c\n", *yytext); }
%%
