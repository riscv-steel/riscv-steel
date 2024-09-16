# -----------------------------------------------------------------------------
# Copyright (c) 2020-2024 RISC-V Steel contributors
#
# This work is licensed under the MIT License, see LICENSE file for details.
# SPDX-License-Identifier: MIT
# -----------------------------------------------------------------------------

include(FetchContent)

FetchContent_Declare(steel
  GIT_REPOSITORY https://github.com/riscv-steel/libsteel.git
  GIT_TAG v1.2
)

FetchContent_MakeAvailable(steel)
