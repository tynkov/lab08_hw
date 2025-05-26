## Laboratory work VI

## Homework

После того, как вы настроили взаимодействие с системой непрерывной интеграции,</br>
обеспечив автоматическую сборку и тестирование ваших изменений, стоит задуматься</br>
о создание пакетов для измениний, которые помечаются тэгами (см. вкладку [releases](https://github.com/tp-labs/lab06/releases)).</br>
Пакет должен содержать приложение _solver_ из [предыдущего задания](https://github.com/tp-labs/lab03#задание-1)
Таким образом, каждый новый релиз будет состоять из следующих компонентов:
- архивы с файлами исходного кода (`.tar.gz`, `.zip`)
- пакеты с бинарным файлом _solver_ (`.deb`, `.rpm`, `.msi`, `.dmg`)

Для этого нужно добавить ветвление в конфигурационные файлы для **CI** со следующей логикой:</br>
если **commit** помечен тэгом, то необходимо собрать пакеты (`DEB, RPM, WIX, DragNDrop, ...`) </br>
и разместить их на сервисе **GitHub**.

CPackConfig.cmake
```cmake
include(InstallRequiredSystemLibraries)

set(CPACK_PACKAGE_CONTACT "andrey.tynkov@gmail.com")
set(CPACK_PACKAGE_VERSION "1.0.0.0")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "C++ program for solving quadratic equations")

set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_CURRENT_SOURCE_DIR}/LICENSE)
set(CPACK_RESOURCE_FILE_README ${CMAKE_CURRENT_SOURCE_DIR}/README.md)

set(CPACK_RPM_PACKAGE_NAME "solverapp-dev")
set(CPACK_RPM_PACKAGE_LICENSE "MIT")
set(CPACK_RPM_PACKAGE_GROUP "solver")
set(CPACK_RPM_PACKAGE_RELEASE 1)

set(CPACK_DEBIAN_PACKAGE_NAME "solverapp-dev")
set(CPACK_DEBIAN_PACKAGE_PREDEPENDS "cmake >= 3.10")
set(CPACK_DEBIAN_PACKAGE_RELEASE 1)
```

CMakeLists.txt
```cmake
cmake_minimum_required(VERSION 3.10)

project(solver)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(formatter_lib)
add_subdirectory(formatter_ex_lib)
add_subdirectory(solver_lib)
add_subdirectory(hello_world_application)
add_subdirectory(solver_application)

include(CPackConfig.cmake)
include(CPack)
```

release.yml
```yml
name: Release

on:
 push:
  tags:
  - 'v*'

permissions:
 contents: write

jobs:
 build-linux:
  runs-on: ubuntu-latest
  steps:
  - name: Checkout repository
    uses: actions/checkout@v4

  - name: Install dependencies
    run: sudo apt-get update && sudo apt-get install -y rpm

  - name: Configure
    run: cmake -S. -B build -DCMAKE_BUILD_TYPE=Release

  - name: Build
    run: cmake --build build --config Release

  - name: Create DEB & RPM packages
    run: |
     cd build
     cpack -G DEB
     cpack -G RPM

  - name: Archive source code
    run: |
     git archive --format=zip --output=source.zip HEAD
     git archive --format=tar.gz --output=source.tar.gz HEAD

  - name: Upload artifacts
    uses: actions/upload-artifact@v4
    with:
     name: linux-packages
     path: |
      build/*.deb
      build/*.rpm
      source.zip
      source.tar.gz

 build-windows:
  runs-on: windows-latest
  steps:
  - name: Checkout repository
    uses: actions/checkout@v4

  - name: Configure
    run: cmake -S. -B build -G "Visual Studio 17 2022" -A x64

  - name: Build
    run: cmake --build build --config Release

  - name: Create MSI package
    run: |
     cd build
     cpack -G WIX

  - name: Upload artifacts
    uses: actions/upload-artifact@v4
    with:
     name: windows-package
     path: build/*.msi

 build-macos:
  runs-on: macos-latest
  steps:
  - name: Checkout repository
    uses: actions/checkout@v4

  - name: Configure
    run: cmake -S. -B build -DCMAKE_BUILD_TYPE=Release

  - name: Build
    run: cmake --build build --config Release

  - name: Create DMG package
    run: |
     cd build
     cpack -G DragNDrop

  - name: Upload artifacts
    uses: actions/upload-artifact@v4
    with:
     name: macos-package
     path: build/*.dmg

 release:
  needs: [build-linux, build-windows, build-macos]
  runs-on: ubuntu-latest
  steps:
  - name: Download artifacts
    uses: actions/download-artifact@v4
    with:
     path: artifacts

  - name: Upload GitHub Release
    uses: softprops/action-gh-release@v1
    with:
     tag_name: ${{ github.ref_name }}
     files: artifacts/**/*.*
    env:
     GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
