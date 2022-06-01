// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vdecoder.h for the primary calling header

#ifndef VERILATED_VDECODER___024ROOT_H_
#define VERILATED_VDECODER___024ROOT_H_  // guard

#include "verilated.h"

class Vdecoder__Syms;
VL_MODULE(Vdecoder___024root) {
  public:

    // DESIGN SPECIFIC STATE
    IData/*31:0*/ decoder_tb__DOT__target;
    VlWide<8>/*255:0*/ decoder_tb__DOT__dec1__DOT__decoded;

    // INTERNAL VARIABLES
    Vdecoder__Syms* vlSymsp;  // Symbol table

    // CONSTRUCTORS
    Vdecoder___024root(const char* name);
    ~Vdecoder___024root();
    VL_UNCOPYABLE(Vdecoder___024root);

    // INTERNAL METHODS
    void __Vconfigure(Vdecoder__Syms* symsp, bool first);
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);


#endif  // guard
