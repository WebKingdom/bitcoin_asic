// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vcomparator_tb.h for the primary calling header

#include "verilated.h"

#include "Vcomparator_tb__Syms.h"
#include "Vcomparator_tb___024root.h"

VL_ATTR_COLD void Vcomparator_tb___024root___initial__TOP__0(Vcomparator_tb___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vcomparator_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcomparator_tb___024root___initial__TOP__0\n"); );
    // Body
    vlSelf->comparator_tb__DOT__dut__DOT__datareg[0U] = 0U;
    vlSelf->comparator_tb__DOT__dut__DOT__datareg[1U] = 0U;
    vlSelf->comparator_tb__DOT__dut__DOT__datareg[2U] = 0U;
    vlSelf->comparator_tb__DOT__dut__DOT__datareg[3U] = 0U;
    vlSelf->comparator_tb__DOT__dut__DOT__datareg[4U] = 0U;
    vlSelf->comparator_tb__DOT__dut__DOT__datareg[5U] = 0U;
    vlSelf->comparator_tb__DOT__dut__DOT__datareg[6U] = 0U;
    vlSelf->comparator_tb__DOT__dut__DOT__datareg[7U] = 0U;
    vlSelf->comparator_tb__DOT__dut__DOT__outWire = 0U;
    vlSymsp->TOP____024unit.__VmonitorNum = 1U;
    vlSelf->comparator_tb__DOT__targetHash[0U] = 7U;
    vlSelf->comparator_tb__DOT__targetHash[1U] = 0U;
    vlSelf->comparator_tb__DOT__targetHash[2U] = 0U;
    vlSelf->comparator_tb__DOT__targetHash[3U] = 0U;
    vlSelf->comparator_tb__DOT__targetHash[4U] = 0U;
    vlSelf->comparator_tb__DOT__targetHash[5U] = 0U;
    vlSelf->comparator_tb__DOT__targetHash[6U] = 0U;
    vlSelf->comparator_tb__DOT__targetHash[7U] = 0U;
    vlSelf->comparator_tb__DOT__hash[0U] = 0xfU;
    vlSelf->comparator_tb__DOT__hash[1U] = 0U;
    vlSelf->comparator_tb__DOT__hash[2U] = 0U;
    vlSelf->comparator_tb__DOT__hash[3U] = 0U;
    vlSelf->comparator_tb__DOT__hash[4U] = 0U;
    vlSelf->comparator_tb__DOT__hash[5U] = 0U;
    vlSelf->comparator_tb__DOT__hash[6U] = 0U;
    vlSelf->comparator_tb__DOT__hash[7U] = 0U;
}

VL_ATTR_COLD void Vcomparator_tb___024root___settle__TOP__0(Vcomparator_tb___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vcomparator_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcomparator_tb___024root___settle__TOP__0\n"); );
    // Body
    if (VL_LTE_W(8, vlSelf->comparator_tb__DOT__hash, vlSelf->comparator_tb__DOT__targetHash)) {
        vlSelf->comparator_tb__DOT__dut__DOT__outWire = 1U;
        vlSelf->comparator_tb__DOT__dut__DOT__datareg[0U] 
            = vlSelf->comparator_tb__DOT__hash[0U];
        vlSelf->comparator_tb__DOT__dut__DOT__datareg[1U] 
            = vlSelf->comparator_tb__DOT__hash[1U];
        vlSelf->comparator_tb__DOT__dut__DOT__datareg[2U] 
            = vlSelf->comparator_tb__DOT__hash[2U];
        vlSelf->comparator_tb__DOT__dut__DOT__datareg[3U] 
            = vlSelf->comparator_tb__DOT__hash[3U];
        vlSelf->comparator_tb__DOT__dut__DOT__datareg[4U] 
            = vlSelf->comparator_tb__DOT__hash[4U];
        vlSelf->comparator_tb__DOT__dut__DOT__datareg[5U] 
            = vlSelf->comparator_tb__DOT__hash[5U];
        vlSelf->comparator_tb__DOT__dut__DOT__datareg[6U] 
            = vlSelf->comparator_tb__DOT__hash[6U];
        vlSelf->comparator_tb__DOT__dut__DOT__datareg[7U] 
            = vlSelf->comparator_tb__DOT__hash[7U];
    }
    if (VL_UNLIKELY(((~ (IData)(vlSymsp->TOP____024unit.__VmonitorOff)) 
                     & (1U == vlSymsp->TOP____024unit.__VmonitorNum)))) {
        VL_WRITEF("time=%3#, hash=%64x, targetHash=%64x, out=%b  outputHash=%64x\n\n",
                  64,VL_TIME_UNITED_Q(1000),256,vlSelf->comparator_tb__DOT__hash.data(),
                  256,vlSelf->comparator_tb__DOT__targetHash.data(),
                  1,(IData)(vlSelf->comparator_tb__DOT__dut__DOT__outWire),
                  256,vlSelf->comparator_tb__DOT__dut__DOT__datareg.data());
    }
    if (VL_UNLIKELY(((~ (IData)(vlSymsp->TOP____024unit.__VmonitorOff)) 
                     & (1U == vlSymsp->TOP____024unit.__VmonitorNum)))) {
        VL_WRITEF("time=%3#, hash=%64x, targetHash=%64x, out=%b  outputHash=%64x\n\n",
                  64,VL_TIME_UNITED_Q(1000),256,vlSelf->comparator_tb__DOT__hash.data(),
                  256,vlSelf->comparator_tb__DOT__targetHash.data(),
                  1,(IData)(vlSelf->comparator_tb__DOT__dut__DOT__outWire),
                  256,vlSelf->comparator_tb__DOT__dut__DOT__datareg.data());
    }
}
