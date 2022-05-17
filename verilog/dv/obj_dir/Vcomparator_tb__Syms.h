// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VCOMPARATOR_TB__SYMS_H_
#define VERILATED_VCOMPARATOR_TB__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vcomparator_tb.h"

// INCLUDE MODULE CLASSES
#include "Vcomparator_tb___024root.h"
#include "Vcomparator_tb___024unit.h"

// SYMS CLASS (contains all model state)
class Vcomparator_tb__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vcomparator_tb* const __Vm_modelp;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vcomparator_tb___024root       TOP;
    Vcomparator_tb___024unit       TOP____024unit;

    // SCOPE NAMES
    VerilatedScope __Vscope_comparator_tb;

    // CONSTRUCTORS
    Vcomparator_tb__Syms(VerilatedContext* contextp, const char* namep, Vcomparator_tb* modelp);
    ~Vcomparator_tb__Syms();

    // METHODS
    const char* name() { return TOP.name(); }
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

#endif  // guard
