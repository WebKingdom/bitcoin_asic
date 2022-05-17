// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vcomparator_tb.h for the primary calling header

#ifndef VERILATED_VCOMPARATOR_TB___024ROOT_H_
#define VERILATED_VCOMPARATOR_TB___024ROOT_H_  // guard

#include "verilated.h"

class Vcomparator_tb__Syms;
class Vcomparator_tb___024unit;

VL_MODULE(Vcomparator_tb___024root) {
  public:
    // CELLS
    Vcomparator_tb___024unit* __PVT____024unit;

    // DESIGN SPECIFIC STATE
    CData/*0:0*/ comparator_tb__DOT__dut__DOT__outWire;
    VlWide<8>/*255:0*/ comparator_tb__DOT__hash;
    VlWide<8>/*255:0*/ comparator_tb__DOT__targetHash;
    VlWide<8>/*255:0*/ comparator_tb__DOT__dut__DOT__datareg;

    // INTERNAL VARIABLES
    Vcomparator_tb__Syms* vlSymsp;  // Symbol table

    // CONSTRUCTORS
    Vcomparator_tb___024root(const char* name);
    ~Vcomparator_tb___024root();
    VL_UNCOPYABLE(Vcomparator_tb___024root);

    // INTERNAL METHODS
    void __Vconfigure(Vcomparator_tb__Syms* symsp, bool first);
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);


#endif  // guard
