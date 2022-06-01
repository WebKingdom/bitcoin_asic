// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vdecoder.h for the primary calling header

#include "verilated.h"

#include "Vdecoder___024root.h"

VL_ATTR_COLD void Vdecoder___024root___initial__TOP__0(Vdecoder___024root* vlSelf);

VL_ATTR_COLD void Vdecoder___024root___eval_initial(Vdecoder___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vdecoder__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vdecoder___024root___eval_initial\n"); );
    // Body
    Vdecoder___024root___initial__TOP__0(vlSelf);
}

VL_ATTR_COLD void Vdecoder___024root___eval_settle(Vdecoder___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vdecoder__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vdecoder___024root___eval_settle\n"); );
}

VL_ATTR_COLD void Vdecoder___024root___final(Vdecoder___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vdecoder__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vdecoder___024root___final\n"); );
}

VL_ATTR_COLD void Vdecoder___024root___ctor_var_reset(Vdecoder___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vdecoder__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vdecoder___024root___ctor_var_reset\n"); );
    // Body
    vlSelf->decoder_tb__DOT__target = VL_RAND_RESET_I(32);
    VL_RAND_RESET_W(256, vlSelf->decoder_tb__DOT__dec1__DOT__decoded);
}
