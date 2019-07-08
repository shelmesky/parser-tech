cmake_minimum_required(VERSION 3.14)
project(parser_tech C)

set(CMAKE_C_STANDARD 11)

include_directories(.)

add_executable(parser_tech
        caculaotr-funcs.c
        caculator.h
        caculator.lex.c
        caculator.tab.c
        caculator.tab.h)

target_link_libraries(parser_tech m)
target_link_libraries(parser_tech fl)