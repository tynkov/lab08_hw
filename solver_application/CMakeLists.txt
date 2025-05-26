cmake_minimum_required(VERSION 3.4)
project(solver_application)

add_executable(solver_application equation.cpp)
target_link_libraries(solver_application formatter_ex solver)
