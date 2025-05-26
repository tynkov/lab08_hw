cmake_minimum_required(VERSION 3.4)
project(hello_world_application)

add_executable(hello_world_application hello_world.cpp)
target_link_libraries(hello_world_application formatter_ex)

