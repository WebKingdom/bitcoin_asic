// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vcomparator_tb.h for the primary calling header

#include "verilated.h"

#include "Vcomparator_tb__Syms.h"
#include "Vcomparator_tb___024unit.h"

void Vcomparator_tb___024unit___ctor_var_reset(Vcomparator_tb___024unit* vlSelf);

Vcomparator_tb___024unit::Vcomparator_tb___024unit(const char* _vcname__)
    : VerilatedModule(_vcname__)
 {
    // Reset structure values
    Vcomparator_tb___024unit___ctor_var_reset(this);
}

void Vcomparator_tb___024unit::__Vconfigure(Vcomparator_tb__Syms* _vlSymsp, bool first) {
    if (false && first) {}  // Prevent unused
    this->vlSymsp = _vlSymsp;
}

Vcomparator_tb___024unit::~Vcomparator_tb___024unit() {
}
