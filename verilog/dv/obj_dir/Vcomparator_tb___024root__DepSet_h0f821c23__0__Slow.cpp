// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vcomparator_tb.h for the primary calling header

#include "verilated.h"

#include "Vcomparator_tb___024root.h"

VL_ATTR_COLD void Vcomparator_tb___024root___initial__TOP__0(Vcomparator_tb___024root* vlSelf);

VL_ATTR_COLD void Vcomparator_tb___024root___eval_initial(Vcomparator_tb___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vcomparator_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcomparator_tb___024root___eval_initial\n"); );
    // Body
    Vcomparator_tb___024root___initial__TOP__0(vlSelf);
}

VL_ATTR_COLD void Vcomparator_tb___024root___settle__TOP__0(Vcomparator_tb___024root* vlSelf);

VL_ATTR_COLD void Vcomparator_tb___024root___eval_settle(Vcomparator_tb___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vcomparator_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcomparator_tb___024root___eval_settle\n"); );
    // Body
    Vcomparator_tb___024root___settle__TOP__0(vlSelf);
}

VL_ATTR_COLD void Vcomparator_tb___024root___final(Vcomparator_tb___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vcomparator_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcomparator_tb___024root___final\n"); );
}

VL_ATTR_COLD void Vcomparator_tb___024root___ctor_var_reset(Vcomparator_tb___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vcomparator_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcomparator_tb___024root___ctor_var_reset\n"); );
    // Body
    VL_RAND_RESET_W(256, vlSelf->comparator_tb__DOT__hash);
    VL_RAND_RESET_W(256, vlSelf->comparator_tb__DOT__targetHash);
    VL_RAND_RESET_W(256, vlSelf->comparator_tb__DOT__dut__DOT__datareg);
    vlSelf->comparator_tb__DOT__dut__DOT__outWire = VL_RAND_RESET_I(1);
}
