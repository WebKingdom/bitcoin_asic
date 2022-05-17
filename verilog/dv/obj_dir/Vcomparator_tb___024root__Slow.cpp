// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vcomparator_tb.h for the primary calling header

#include "verilated.h"

#include "Vcomparator_tb__Syms.h"
#include "Vcomparator_tb___024root.h"

void Vcomparator_tb___024root___ctor_var_reset(Vcomparator_tb___024root* vlSelf);

Vcomparator_tb___024root::Vcomparator_tb___024root(const char* _vcname__)
    : VerilatedModule(_vcname__)
 {
    // Reset structure values
    Vcomparator_tb___024root___ctor_var_reset(this);
}

void Vcomparator_tb___024root::__Vconfigure(Vcomparator_tb__Syms* _vlSymsp, bool first) {
    if (false && first) {}  // Prevent unused
    this->vlSymsp = _vlSymsp;
}

Vcomparator_tb___024root::~Vcomparator_tb___024root() {
}
