// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vdecoder.h"
#include "Vdecoder__Syms.h"

//============================================================
// Constructors

Vdecoder::Vdecoder(VerilatedContext* _vcontextp__, const char* _vcname__)
    : vlSymsp{new Vdecoder__Syms(_vcontextp__, _vcname__, this)}
    , rootp{&(vlSymsp->TOP)}
{
}

Vdecoder::Vdecoder(const char* _vcname__)
    : Vdecoder(nullptr, _vcname__)
{
}

//============================================================
// Destructor

Vdecoder::~Vdecoder() {
    delete vlSymsp;
}

//============================================================
// Evaluation loop

void Vdecoder___024root___eval_initial(Vdecoder___024root* vlSelf);
void Vdecoder___024root___eval_settle(Vdecoder___024root* vlSelf);
void Vdecoder___024root___eval(Vdecoder___024root* vlSelf);
#ifdef VL_DEBUG
void Vdecoder___024root___eval_debug_assertions(Vdecoder___024root* vlSelf);
#endif  // VL_DEBUG
void Vdecoder___024root___final(Vdecoder___024root* vlSelf);

static void _eval_initial_loop(Vdecoder__Syms* __restrict vlSymsp) {
    vlSymsp->__Vm_didInit = true;
    Vdecoder___024root___eval_initial(&(vlSymsp->TOP));
    // Evaluate till stable
    do {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial loop\n"););
        Vdecoder___024root___eval_settle(&(vlSymsp->TOP));
        Vdecoder___024root___eval(&(vlSymsp->TOP));
    } while (0);
}

void Vdecoder::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vdecoder::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vdecoder___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    // Initialize
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) _eval_initial_loop(vlSymsp);
    // Evaluate till stable
    do {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Clock loop\n"););
        Vdecoder___024root___eval(&(vlSymsp->TOP));
    } while (0);
    // Evaluate cleanup
}

//============================================================
// Utilities

VerilatedContext* Vdecoder::contextp() const {
    return vlSymsp->_vm_contextp__;
}

const char* Vdecoder::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

VL_ATTR_COLD void Vdecoder::final() {
    Vdecoder___024root___final(&(vlSymsp->TOP));
}
