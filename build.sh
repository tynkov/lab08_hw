#!/bin/bash

cd /src
mkdir -p logs

echo -e "Конфигурация проекта:\n" > logs/log.txt
cmake -H. -Bbuild -DCMAKE_BUILD_TYPE=Release >> logs/log.txt
echo -e "\n\nСборка проекта:\n" >> logs/log.txt
cmake --build build >> logs/log.txt
