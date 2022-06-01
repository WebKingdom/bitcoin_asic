// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VDECODER__SYMS_H_
#define VERILATED_VDECODER__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vdecoder.h"

// INCLUDE MODULE CLASSES
#include "Vdecoder___024root.h"

// SYMS CLASS (contains all model state)
class Vdecoder__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vdecoder* const __Vm_modelp;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vdecoder___024root             TOP;

    // CONSTRUCTORS
    Vdecoder__Syms(VerilatedContext* contextp, const char* namep, Vdecoder* modelp);
    ~Vdecoder__Syms();

    // METHODS
    const char* name() { return TOP.name(); }
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

#endif  // guard
