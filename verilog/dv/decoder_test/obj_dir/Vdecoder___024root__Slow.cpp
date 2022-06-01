// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vdecoder.h for the primary calling header

#include "verilated.h"

#include "Vdecoder__Syms.h"
#include "Vdecoder___024root.h"

void Vdecoder___024root___ctor_var_reset(Vdecoder___024root* vlSelf);

Vdecoder___024root::Vdecoder___024root(const char* _vcname__)
    : VerilatedModule(_vcname__)
 {
    // Reset structure values
    Vdecoder___024root___ctor_var_reset(this);
}

void Vdecoder___024root::__Vconfigure(Vdecoder__Syms* _vlSymsp, bool first) {
    if (false && first) {}  // Prevent unused
    this->vlSymsp = _vlSymsp;
}

Vdecoder___024root::~Vdecoder___024root() {
}
