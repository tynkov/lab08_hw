cmake_minimum_required(VERSION 3.10)
project(solver)

add_library(solver STATIC solver.cpp)
target_include_directories(solver PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
