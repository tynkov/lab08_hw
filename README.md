## Laboratory work VIII

Данная лабораторная работа посвящена изучению систем автоматизации, развёртывания и управления приложениями на примере **Docker**

## Homework

1. Cоздать конфигурацию **Docker**-контейнера в котором вы будете собирать проект. Эта конфигурация должна учитывать возможность передачи в этот контейнер вашего кода, сборки кода в контейнере и выгрузки оттуда файла с журнальной информацией.

Dockerfile
```dockerfile
FROM ubuntu:24.04

RUN apt update
RUN apt install -yy gcc g++ cmake

WORKDIR /src
COPY build.sh /build.sh
RUN chmod +x /build.sh

ENTRYPOINT ["/build.sh"]

```

build.sh
```bash
#!/bin/bash

cd /src
mkdir -p logs

echo -e "Конфигурация проекта:\n" > logs/log.txt
cmake -H. -Bbuild -DCMAKE_BUILD_TYPE=Release >> logs/log.txt
echo -e "\n\nСборка проекта:\n" >> logs/log.txt
cmake --build build >> logs/log.txt

```

<details><summary>$ docker build -t lab08 .</summary>
[+] Building 1.9s (11/11) FINISHED                                                                                                                                                                         docker:default
 => [internal] load build definition from Dockerfile                                                                                                                                                                 0.0s
 => => transferring dockerfile: 195B                                                                                                                                                                                 0.0s 
 => [internal] load metadata for docker.io/library/ubuntu:24.04                                                                                                                                                      1.6s 
 => [internal] load .dockerignore                                                                                                                                                                                    0.2s
 => => transferring context: 2B                                                                                                                                                                                      0.1s
 => [1/6] FROM docker.io/library/ubuntu:24.04@sha256:6015f66923d7afbc53558d7ccffd325d43b4e249f41a6e93eef074c9505d2233                                                                                                0.0s
 => [internal] load build context                                                                                                                                                                                    0.0s 
 => => transferring context: 30B                                                                                                                                                                                     0.0s 
 => CACHED [2/6] RUN apt update                                                                                                                                                                                      0.0s 
 => CACHED [3/6] RUN apt install -yy gcc g++ cmake                                                                                                                                                                   0.0s 
 => CACHED [4/6] WORKDIR /src                                                                                                                                                                                        0.0s 
 => CACHED [5/6] COPY build.sh /build.sh                                                                                                                                                                             0.0s 
 => CACHED [6/6] RUN chmod +x /build.sh                                                                                                                                                                              0.0s 
 => exporting to image                                                                                                                                                                                               0.0s 
 => => exporting layers                                                                                                                                                                                              0.0s 
 => => writing image sha256:7bca94e4b02bb0eb08e40f924c585b53c4d02946793c673bbf5fd193b96ba019                                                                                                                         0.0s 
 => => naming to docker.io/library/lab08
</details>

```bash
$ docker run --rm -v $(pwd):/src lab08
```

<details><summary>cat logs/log.txt</summary>
Конфигурация проекта:

-- The C compiler identification is GNU 13.3.0
-- The CXX compiler identification is GNU 13.3.0
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Check for working C compiler: /usr/bin/cc - skipped
-- Detecting C compile features
-- Detecting C compile features - done
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Check for working CXX compiler: /usr/bin/c++ - skipped
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Configuring done (0.3s)
-- Generating done (0.0s)
-- Build files have been written to: /src/build


Сборка проекта:

[ 10%] Building CXX object formatter_lib/CMakeFiles/formatter.dir/formatter.cpp.o
[ 20%] Linking CXX static library libformatter.a
[ 20%] Built target formatter
[ 30%] Building CXX object formatter_ex_lib/CMakeFiles/formatter_ex.dir/formatter_ex.cpp.o
[ 40%] Linking CXX static library libformatter_ex.a
[ 40%] Built target formatter_ex
[ 50%] Building CXX object solver_lib/CMakeFiles/solver.dir/solver.cpp.o
[ 60%] Linking CXX static library libsolver.a
[ 60%] Built target solver
[ 70%] Building CXX object hello_world_application/CMakeFiles/hello_world_application.dir/hello_world.cpp.o
[ 80%] Linking CXX executable hello_world_application
[ 80%] Built target hello_world_application
[ 90%] Building CXX object solver_application/CMakeFiles/solver_application.dir/equation.cpp.o
[100%] Linking CXX executable solver_application
[100%] Built target solver_application
</details>
   
   
2. Создать конвейер обработки в .github/workflows, в котором будут запускаться задачи создания контейнера, выполнение в нем нужных команд по загрузке кода, сборки и получения файла с информацией, а также публикация этого файла в качестве артефакта в github actions.

CI.yml
```yml
name: Build & Upload logs

on:
 push:
  branches: [main]
 pull_request:
  branches: [main]

jobs:
 build-docker:

  runs-on: ubuntu-latest

  steps:
  - name: Checkout repository
    uses: actions/checkout@v4

  - name: Build Docker image
    run: docker build -t lab08 .

  - name: Run Docker container
    run: docker run --rm -v $(pwd):/src lab08

  - name: Upload log as artifact
    uses: actions/upload-artifact@v4
    with:
     name: build-log
     path: logs/log.txt

```
