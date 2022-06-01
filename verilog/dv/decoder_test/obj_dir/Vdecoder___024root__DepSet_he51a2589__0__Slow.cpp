// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vdecoder.h for the primary calling header

#include "verilated.h"

#include "Vdecoder__Syms.h"
#include "Vdecoder___024root.h"

VL_ATTR_COLD void Vdecoder___024root___initial__TOP__0(Vdecoder___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vdecoder__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vdecoder___024root___initial__TOP__0\n"); );
    // Init
    VlWide<8>/*255:0*/ decoder_tb__DOT__fullTarget;
    CData/*3:0*/ decoder_tb__DOT__dec1__DOT__sizeTens;
    CData/*3:0*/ decoder_tb__DOT__dec1__DOT__sizeOnes;
    IData/*31:0*/ decoder_tb__DOT__dec1__DOT__spacing;
    IData/*31:0*/ decoder_tb__DOT__dec1__DOT__leftBuffer;
    IData/*31:0*/ decoder_tb__DOT__dec1__DOT__i;
    VlWide<4>/*127:0*/ __Vtemp_hff926249__0;
    // Body
    decoder_tb__DOT__dec1__DOT__sizeTens = (vlSelf->decoder_tb__DOT__target 
                                            >> 0x1cU);
    decoder_tb__DOT__dec1__DOT__sizeOnes = (0xfU & 
                                            (vlSelf->decoder_tb__DOT__target 
                                             >> 0x18U));
    decoder_tb__DOT__dec1__DOT__spacing = (((IData)(decoder_tb__DOT__dec1__DOT__sizeTens) 
                                            << 4U) 
                                           + (IData)(decoder_tb__DOT__dec1__DOT__sizeOnes));
    decoder_tb__DOT__dec1__DOT__leftBuffer = ((IData)(0x20U) 
                                              - decoder_tb__DOT__dec1__DOT__spacing);
    decoder_tb__DOT__dec1__DOT__i = 0xffU;
    while (VL_GTS_III(32, decoder_tb__DOT__dec1__DOT__i, 
                      ((IData)(0xfeU) - decoder_tb__DOT__dec1__DOT__leftBuffer))) {
        vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                     & (decoder_tb__DOT__dec1__DOT__i 
                                                        >> 5U))] 
            = ((~ ((IData)(1U) << (0x1fU & decoder_tb__DOT__dec1__DOT__i))) 
               & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
               (7U & (decoder_tb__DOT__dec1__DOT__i 
                      >> 5U))]);
        decoder_tb__DOT__dec1__DOT__i = (decoder_tb__DOT__dec1__DOT__i 
                                         - (IData)(1U));
    }
    vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                 & ((((IData)(0xffU) 
                                                      - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                     - (IData)(0x19U)) 
                                                    >> 5U))] 
        = (((~ ((IData)(1U) << (0x1fU & (((IData)(0xffU) 
                                          - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                         - (IData)(0x19U))))) 
            & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
            (7U & ((((IData)(0xffU) - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                    - (IData)(0x19U)) >> 5U))]) | (
                                                   (1U 
                                                    & vlSelf->decoder_tb__DOT__target) 
                                                   << 
                                                   (0x1fU 
                                                    & (((IData)(0xffU) 
                                                        - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                       - (IData)(0x19U)))));
    vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                 & (((IData)(1U) 
                                                     + 
                                                     (((IData)(0xffU) 
                                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                      - (IData)(0x19U))) 
                                                    >> 5U))] 
        = (((~ ((IData)(1U) << (0x1fU & ((IData)(1U) 
                                         + (((IData)(0xffU) 
                                             - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                            - (IData)(0x19U)))))) 
            & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
            (7U & (((IData)(1U) + (((IData)(0xffU) 
                                    - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                   - (IData)(0x19U))) 
                   >> 5U))]) | ((1U & (vlSelf->decoder_tb__DOT__target 
                                       >> 1U)) << (0x1fU 
                                                   & ((IData)(1U) 
                                                      + 
                                                      (((IData)(0xffU) 
                                                        - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                       - (IData)(0x19U))))));
    vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                 & (((IData)(2U) 
                                                     + 
                                                     (((IData)(0xffU) 
                                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                      - (IData)(0x19U))) 
                                                    >> 5U))] 
        = (((~ ((IData)(1U) << (0x1fU & ((IData)(2U) 
                                         + (((IData)(0xffU) 
                                             - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                            - (IData)(0x19U)))))) 
            & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
            (7U & (((IData)(2U) + (((IData)(0xffU) 
                                    - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                   - (IData)(0x19U))) 
                   >> 5U))]) | ((1U & (vlSelf->decoder_tb__DOT__target 
                                       >> 2U)) << (0x1fU 
                                                   & ((IData)(2U) 
                                                      + 
                                                      (((IData)(0xffU) 
                                                        - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                       - (IData)(0x19U))))));
    vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                 & (((IData)(3U) 
                                                     + 
                                                     (((IData)(0xffU) 
                                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                      - (IData)(0x19U))) 
                                                    >> 5U))] 
        = (((~ ((IData)(1U) << (0x1fU & ((IData)(3U) 
                                         + (((IData)(0xffU) 
                                             - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                            - (IData)(0x19U)))))) 
            & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
            (7U & (((IData)(3U) + (((IData)(0xffU) 
                                    - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                   - (IData)(0x19U))) 
                   >> 5U))]) | ((1U & (vlSelf->decoder_tb__DOT__target 
                                       >> 3U)) << (0x1fU 
                                                   & ((IData)(3U) 
                                                      + 
                                                      (((IData)(0xffU) 
                                                        - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                       - (IData)(0x19U))))));
    vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                 & (((IData)(4U) 
                                                     + 
                                                     (((IData)(0xffU) 
                                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                      - (IData)(0x19U))) 
                                                    >> 5U))] 
        = (((~ ((IData)(1U) << (0x1fU & ((IData)(4U) 
                                         + (((IData)(0xffU) 
                                             - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                            - (IData)(0x19U)))))) 
            & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
            (7U & (((IData)(4U) + (((IData)(0xffU) 
                                    - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                   - (IData)(0x19U))) 
                   >> 5U))]) | ((1U & (vlSelf->decoder_tb__DOT__target 
                                       >> 4U)) << (0x1fU 
                                                   & ((IData)(4U) 
                                                      + 
                                                      (((IData)(0xffU) 
                                                        - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                       - (IData)(0x19U))))));
    vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                 & (((IData)(5U) 
                                                     + 
                                                     (((IData)(0xffU) 
                                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                      - (IData)(0x19U))) 
                                                    >> 5U))] 
        = (((~ ((IData)(1U) << (0x1fU & ((IData)(5U) 
                                         + (((IData)(0xffU) 
                                             - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                            - (IData)(0x19U)))))) 
            & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
            (7U & (((IData)(5U) + (((IData)(0xffU) 
                                    - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                   - (IData)(0x19U))) 
                   >> 5U))]) | ((1U & (vlSelf->decoder_tb__DOT__target 
                                       >> 5U)) << (0x1fU 
                                                   & ((IData)(5U) 
                                                      + 
                                                      (((IData)(0xffU) 
                                                        - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                       - (IData)(0x19U))))));
    vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                 & (((IData)(6U) 
                                                     + 
                                                     (((IData)(0xffU) 
                                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                      - (IData)(0x19U))) 
                                                    >> 5U))] 
        = (((~ ((IData)(1U) << (0x1fU & ((IData)(6U) 
                                         + (((IData)(0xffU) 
                                             - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                            - (IData)(0x19U)))))) 
            & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
            (7U & (((IData)(6U) + (((IData)(0xffU) 
                                    - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                   - (IData)(0x19U))) 
                   >> 5U))]) | ((1U & (vlSelf->decoder_tb__DOT__target 
                                       >> 6U)) << (0x1fU 
                                                   & ((IData)(6U) 
                                                      + 
                                                      (((IData)(0xffU) 
                                                        - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                       - (IData)(0x19U))))));
    vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                 & (((IData)(7U) 
                                                     + 
                                                     (((IData)(0xffU) 
                                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                      - (IData)(0x19U))) 
                                                    >> 5U))] 
        = (((~ ((IData)(1U) << (0x1fU & ((IData)(7U) 
                                         + (((IData)(0xffU) 
                                             - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                            - (IData)(0x19U)))))) 
            & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
            (7U & (((IData)(7U) + (((IData)(0xffU) 
                                    - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                   - (IData)(0x19U))) 
                   >> 5U))]) | ((1U & (vlSelf->decoder_tb__DOT__target 
                                       >> 7U)) << (0x1fU 
                                                   & ((IData)(7U) 
                                                      + 
                                                      (((IData)(0xffU) 
                                                        - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                       - (IData)(0x19U))))));
    vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                 & (((IData)(8U) 
                                                     + 
                                                     (((IData)(0xffU) 
                                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                      - (IData)(0x19U))) 
                                                    >> 5U))] 
        = (((~ ((IData)(1U) << (0x1fU & ((IData)(8U) 
                                         + (((IData)(0xffU) 
                                             - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                            - (IData)(0x19U)))))) 
            & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
            (7U & (((IData)(8U) + (((IData)(0xffU) 
                                    - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                   - (IData)(0x19U))) 
                   >> 5U))]) | ((1U & (vlSelf->decoder_tb__DOT__target 
                                       >> 8U)) << (0x1fU 
                                                   & ((IData)(8U) 
                                                      + 
                                                      (((IData)(0xffU) 
                                                        - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                       - (IData)(0x19U))))));
    vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                 & (((IData)(9U) 
                                                     + 
                                                     (((IData)(0xffU) 
                                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                      - (IData)(0x19U))) 
                                                    >> 5U))] 
        = (((~ ((IData)(1U) << (0x1fU & ((IData)(9U) 
                                         + (((IData)(0xffU) 
                                             - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                            - (IData)(0x19U)))))) 
            & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
            (7U & (((IData)(9U) + (((IData)(0xffU) 
                                    - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                   - (IData)(0x19U))) 
                   >> 5U))]) | ((1U & (vlSelf->decoder_tb__DOT__target 
                                       >> 9U)) << (0x1fU 
                                                   & ((IData)(9U) 
                                                      + 
                                                      (((IData)(0xffU) 
                                                        - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                       - (IData)(0x19U))))));
    vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                 & (((IData)(0xaU) 
                                                     + 
                                                     (((IData)(0xffU) 
                                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                      - (IData)(0x19U))) 
                                                    >> 5U))] 
        = (((~ ((IData)(1U) << (0x1fU & ((IData)(0xaU) 
                                         + (((IData)(0xffU) 
                                             - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                            - (IData)(0x19U)))))) 
            & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
            (7U & (((IData)(0xaU) + (((IData)(0xffU) 
                                      - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                     - (IData)(0x19U))) 
                   >> 5U))]) | ((1U & (vlSelf->decoder_tb__DOT__target 
                                       >> 0xaU)) << 
                                (0x1fU & ((IData)(0xaU) 
                                          + (((IData)(0xffU) 
                                              - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                             - (IData)(0x19U))))));
    vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                 & (((IData)(0xbU) 
                                                     + 
                                                     (((IData)(0xffU) 
                                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                      - (IData)(0x19U))) 
                                                    >> 5U))] 
        = (((~ ((IData)(1U) << (0x1fU & ((IData)(0xbU) 
                                         + (((IData)(0xffU) 
                                             - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                            - (IData)(0x19U)))))) 
            & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
            (7U & (((IData)(0xbU) + (((IData)(0xffU) 
                                      - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                     - (IData)(0x19U))) 
                   >> 5U))]) | ((1U & (vlSelf->decoder_tb__DOT__target 
                                       >> 0xbU)) << 
                                (0x1fU & ((IData)(0xbU) 
                                          + (((IData)(0xffU) 
                                              - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                             - (IData)(0x19U))))));
    vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                 & (((IData)(0xcU) 
                                                     + 
                                                     (((IData)(0xffU) 
                                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                      - (IData)(0x19U))) 
                                                    >> 5U))] 
        = (((~ ((IData)(1U) << (0x1fU & ((IData)(0xcU) 
                                         + (((IData)(0xffU) 
                                             - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                            - (IData)(0x19U)))))) 
            & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
            (7U & (((IData)(0xcU) + (((IData)(0xffU) 
                                      - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                     - (IData)(0x19U))) 
                   >> 5U))]) | ((1U & (vlSelf->decoder_tb__DOT__target 
                                       >> 0xcU)) << 
                                (0x1fU & ((IData)(0xcU) 
                                          + (((IData)(0xffU) 
                                              - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                             - (IData)(0x19U))))));
    vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                 & (((IData)(0xdU) 
                                                     + 
                                                     (((IData)(0xffU) 
                                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                      - (IData)(0x19U))) 
                                                    >> 5U))] 
        = (((~ ((IData)(1U) << (0x1fU & ((IData)(0xdU) 
                                         + (((IData)(0xffU) 
                                             - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                            - (IData)(0x19U)))))) 
            & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
            (7U & (((IData)(0xdU) + (((IData)(0xffU) 
                                      - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                     - (IData)(0x19U))) 
                   >> 5U))]) | ((1U & (vlSelf->decoder_tb__DOT__target 
                                       >> 0xdU)) << 
                                (0x1fU & ((IData)(0xdU) 
                                          + (((IData)(0xffU) 
                                              - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                             - (IData)(0x19U))))));
    vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                 & (((IData)(0xeU) 
                                                     + 
                                                     (((IData)(0xffU) 
                                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                      - (IData)(0x19U))) 
                                                    >> 5U))] 
        = (((~ ((IData)(1U) << (0x1fU & ((IData)(0xeU) 
                                         + (((IData)(0xffU) 
                                             - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                            - (IData)(0x19U)))))) 
            & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
            (7U & (((IData)(0xeU) + (((IData)(0xffU) 
                                      - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                     - (IData)(0x19U))) 
                   >> 5U))]) | ((1U & (vlSelf->decoder_tb__DOT__target 
                                       >> 0xeU)) << 
                                (0x1fU & ((IData)(0xeU) 
                                          + (((IData)(0xffU) 
                                              - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                             - (IData)(0x19U))))));
    vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                 & (((IData)(0xfU) 
                                                     + 
                                                     (((IData)(0xffU) 
                                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                      - (IData)(0x19U))) 
                                                    >> 5U))] 
        = (((~ ((IData)(1U) << (0x1fU & ((IData)(0xfU) 
                                         + (((IData)(0xffU) 
                                             - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                            - (IData)(0x19U)))))) 
            & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
            (7U & (((IData)(0xfU) + (((IData)(0xffU) 
                                      - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                     - (IData)(0x19U))) 
                   >> 5U))]) | ((1U & (vlSelf->decoder_tb__DOT__target 
                                       >> 0xfU)) << 
                                (0x1fU & ((IData)(0xfU) 
                                          + (((IData)(0xffU) 
                                              - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                             - (IData)(0x19U))))));
    vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                 & (((IData)(0x10U) 
                                                     + 
                                                     (((IData)(0xffU) 
                                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                      - (IData)(0x19U))) 
                                                    >> 5U))] 
        = (((~ ((IData)(1U) << (0x1fU & ((IData)(0x10U) 
                                         + (((IData)(0xffU) 
                                             - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                            - (IData)(0x19U)))))) 
            & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
            (7U & (((IData)(0x10U) + (((IData)(0xffU) 
                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                      - (IData)(0x19U))) 
                   >> 5U))]) | ((1U & (vlSelf->decoder_tb__DOT__target 
                                       >> 0x10U)) << 
                                (0x1fU & ((IData)(0x10U) 
                                          + (((IData)(0xffU) 
                                              - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                             - (IData)(0x19U))))));
    vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                 & (((IData)(0x11U) 
                                                     + 
                                                     (((IData)(0xffU) 
                                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                      - (IData)(0x19U))) 
                                                    >> 5U))] 
        = (((~ ((IData)(1U) << (0x1fU & ((IData)(0x11U) 
                                         + (((IData)(0xffU) 
                                             - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                            - (IData)(0x19U)))))) 
            & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
            (7U & (((IData)(0x11U) + (((IData)(0xffU) 
                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                      - (IData)(0x19U))) 
                   >> 5U))]) | ((1U & (vlSelf->decoder_tb__DOT__target 
                                       >> 0x11U)) << 
                                (0x1fU & ((IData)(0x11U) 
                                          + (((IData)(0xffU) 
                                              - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                             - (IData)(0x19U))))));
    vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                 & (((IData)(0x12U) 
                                                     + 
                                                     (((IData)(0xffU) 
                                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                      - (IData)(0x19U))) 
                                                    >> 5U))] 
        = (((~ ((IData)(1U) << (0x1fU & ((IData)(0x12U) 
                                         + (((IData)(0xffU) 
                                             - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                            - (IData)(0x19U)))))) 
            & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
            (7U & (((IData)(0x12U) + (((IData)(0xffU) 
                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                      - (IData)(0x19U))) 
                   >> 5U))]) | ((1U & (vlSelf->decoder_tb__DOT__target 
                                       >> 0x12U)) << 
                                (0x1fU & ((IData)(0x12U) 
                                          + (((IData)(0xffU) 
                                              - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                             - (IData)(0x19U))))));
    vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                 & (((IData)(0x13U) 
                                                     + 
                                                     (((IData)(0xffU) 
                                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                      - (IData)(0x19U))) 
                                                    >> 5U))] 
        = (((~ ((IData)(1U) << (0x1fU & ((IData)(0x13U) 
                                         + (((IData)(0xffU) 
                                             - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                            - (IData)(0x19U)))))) 
            & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
            (7U & (((IData)(0x13U) + (((IData)(0xffU) 
                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                      - (IData)(0x19U))) 
                   >> 5U))]) | ((1U & (vlSelf->decoder_tb__DOT__target 
                                       >> 0x13U)) << 
                                (0x1fU & ((IData)(0x13U) 
                                          + (((IData)(0xffU) 
                                              - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                             - (IData)(0x19U))))));
    vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                 & (((IData)(0x14U) 
                                                     + 
                                                     (((IData)(0xffU) 
                                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                      - (IData)(0x19U))) 
                                                    >> 5U))] 
        = (((~ ((IData)(1U) << (0x1fU & ((IData)(0x14U) 
                                         + (((IData)(0xffU) 
                                             - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                            - (IData)(0x19U)))))) 
            & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
            (7U & (((IData)(0x14U) + (((IData)(0xffU) 
                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                      - (IData)(0x19U))) 
                   >> 5U))]) | ((1U & (vlSelf->decoder_tb__DOT__target 
                                       >> 0x14U)) << 
                                (0x1fU & ((IData)(0x14U) 
                                          + (((IData)(0xffU) 
                                              - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                             - (IData)(0x19U))))));
    vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                 & (((IData)(0x15U) 
                                                     + 
                                                     (((IData)(0xffU) 
                                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                      - (IData)(0x19U))) 
                                                    >> 5U))] 
        = (((~ ((IData)(1U) << (0x1fU & ((IData)(0x15U) 
                                         + (((IData)(0xffU) 
                                             - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                            - (IData)(0x19U)))))) 
            & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
            (7U & (((IData)(0x15U) + (((IData)(0xffU) 
                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                      - (IData)(0x19U))) 
                   >> 5U))]) | ((1U & (vlSelf->decoder_tb__DOT__target 
                                       >> 0x15U)) << 
                                (0x1fU & ((IData)(0x15U) 
                                          + (((IData)(0xffU) 
                                              - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                             - (IData)(0x19U))))));
    vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                 & (((IData)(0x16U) 
                                                     + 
                                                     (((IData)(0xffU) 
                                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                      - (IData)(0x19U))) 
                                                    >> 5U))] 
        = (((~ ((IData)(1U) << (0x1fU & ((IData)(0x16U) 
                                         + (((IData)(0xffU) 
                                             - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                            - (IData)(0x19U)))))) 
            & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
            (7U & (((IData)(0x16U) + (((IData)(0xffU) 
                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                      - (IData)(0x19U))) 
                   >> 5U))]) | ((1U & (vlSelf->decoder_tb__DOT__target 
                                       >> 0x16U)) << 
                                (0x1fU & ((IData)(0x16U) 
                                          + (((IData)(0xffU) 
                                              - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                             - (IData)(0x19U))))));
    vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                 & (((IData)(0x17U) 
                                                     + 
                                                     (((IData)(0xffU) 
                                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                                      - (IData)(0x19U))) 
                                                    >> 5U))] 
        = (((~ ((IData)(1U) << (0x1fU & ((IData)(0x17U) 
                                         + (((IData)(0xffU) 
                                             - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                            - (IData)(0x19U)))))) 
            & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
            (7U & (((IData)(0x17U) + (((IData)(0xffU) 
                                       - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                      - (IData)(0x19U))) 
                   >> 5U))]) | ((1U & (vlSelf->decoder_tb__DOT__target 
                                       >> 0x17U)) << 
                                (0x1fU & ((IData)(0x17U) 
                                          + (((IData)(0xffU) 
                                              - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                             - (IData)(0x19U))))));
    decoder_tb__DOT__dec1__DOT__i = (((IData)(0xffU) 
                                      - decoder_tb__DOT__dec1__DOT__leftBuffer) 
                                     - (IData)(0x1aU));
    while (VL_LTS_III(32, 0xffffffffU, decoder_tb__DOT__dec1__DOT__i)) {
        vlSelf->decoder_tb__DOT__dec1__DOT__decoded[(7U 
                                                     & (decoder_tb__DOT__dec1__DOT__i 
                                                        >> 5U))] 
            = ((~ ((IData)(1U) << (0x1fU & decoder_tb__DOT__dec1__DOT__i))) 
               & vlSelf->decoder_tb__DOT__dec1__DOT__decoded[
               (7U & (decoder_tb__DOT__dec1__DOT__i 
                      >> 5U))]);
        decoder_tb__DOT__dec1__DOT__i = (decoder_tb__DOT__dec1__DOT__i 
                                         - (IData)(1U));
    }
    decoder_tb__DOT__fullTarget[0U] = vlSelf->decoder_tb__DOT__dec1__DOT__decoded[0U];
    decoder_tb__DOT__fullTarget[1U] = vlSelf->decoder_tb__DOT__dec1__DOT__decoded[1U];
    decoder_tb__DOT__fullTarget[2U] = vlSelf->decoder_tb__DOT__dec1__DOT__decoded[2U];
    decoder_tb__DOT__fullTarget[3U] = vlSelf->decoder_tb__DOT__dec1__DOT__decoded[3U];
    decoder_tb__DOT__fullTarget[4U] = vlSelf->decoder_tb__DOT__dec1__DOT__decoded[4U];
    decoder_tb__DOT__fullTarget[5U] = vlSelf->decoder_tb__DOT__dec1__DOT__decoded[5U];
    decoder_tb__DOT__fullTarget[6U] = vlSelf->decoder_tb__DOT__dec1__DOT__decoded[6U];
    decoder_tb__DOT__fullTarget[7U] = vlSelf->decoder_tb__DOT__dec1__DOT__decoded[7U];
    __Vtemp_hff926249__0[0U] = 0x2e766364U;
    __Vtemp_hff926249__0[1U] = 0x725f7462U;
    __Vtemp_hff926249__0[2U] = 0x636f6465U;
    __Vtemp_hff926249__0[3U] = 0x6465U;
    vlSymsp->_vm_contextp__->dumpfile(VL_CVT_PACK_STR_NW(4, __Vtemp_hff926249__0));
    VL_PRINTF_MT("-Info: decoder_tb.sv:11: $dumpvar ignored, as Verilated without --trace\n");
    vlSelf->decoder_tb__DOT__target = 0x1903a30cU;
    VL_WRITEF("FINISHED decoder_tb\nOutput: %x\n",256,
              decoder_tb__DOT__fullTarget.data());
    VL_FINISH_MT("decoder_tb.sv", 15, "");
}
