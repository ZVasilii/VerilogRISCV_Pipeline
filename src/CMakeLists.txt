find_package(verilator REQUIRED HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT})

if(NOT verilator_FOUND)
  message(
    FATAL_ERROR
      "Verilator was not found."
  )
endif()

add_executable(core main.cpp)
target_compile_features(core PRIVATE cxx_std_20)
target_compile_options(core PRIVATE -Wall -Wextra -Wpedantic)

verilate(
  core
  SOURCES
  core.sv
  TRACE
  VERILATOR_ARGS
  -cc
  -Wall
  --exe)

target_link_libraries(core PRIVATE elfio::elfio)
target_include_directories(core SYSTEM
                           PRIVATE ${CMAKE_SOURCE_DIR}/thirdparty/ELFIO/)

target_link_libraries(core PRIVATE CLI11::CLI11)
target_include_directories(core SYSTEM
                           PRIVATE ${CMAKE_SOURCE_DIR}/thirdparty/CLI11/include)


target_include_directories(
  core SYSTEM PRIVATE ${VERILATOR_ROOT}/include)
