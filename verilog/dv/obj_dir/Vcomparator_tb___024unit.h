// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vcomparator_tb.h for the primary calling header

#ifndef VERILATED_VCOMPARATOR_TB___024UNIT_H_
#define VERILATED_VCOMPARATOR_TB___024UNIT_H_  // guard

#include "verilated.h"

class Vcomparator_tb__Syms;
VL_MODULE(Vcomparator_tb___024unit) {
  public:

    // DESIGN SPECIFIC STATE
    CData/*0:0*/ __VmonitorOff;
    QData/*63:0*/ __VmonitorNum;

    // INTERNAL VARIABLES
    Vcomparator_tb__Syms* vlSymsp;  // Symbol table

    // CONSTRUCTORS
    Vcomparator_tb___024unit(const char* name);
    ~Vcomparator_tb___024unit();
    VL_UNCOPYABLE(Vcomparator_tb___024unit);

    // INTERNAL METHODS
    void __Vconfigure(Vcomparator_tb__Syms* symsp, bool first);
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);


#endif  // guard
