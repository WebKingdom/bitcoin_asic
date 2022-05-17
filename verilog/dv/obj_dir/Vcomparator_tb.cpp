// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vcomparator_tb.h"
#include "Vcomparator_tb__Syms.h"

//============================================================
// Constructors

Vcomparator_tb::Vcomparator_tb(VerilatedContext* _vcontextp__, const char* _vcname__)
    : vlSymsp{new Vcomparator_tb__Syms(_vcontextp__, _vcname__, this)}
    , __PVT____024unit{vlSymsp->TOP.__PVT____024unit}
    , rootp{&(vlSymsp->TOP)}
{
}

Vcomparator_tb::Vcomparator_tb(const char* _vcname__)
    : Vcomparator_tb(nullptr, _vcname__)
{
}

//============================================================
// Destructor

Vcomparator_tb::~Vcomparator_tb() {
    delete vlSymsp;
}

//============================================================
// Evaluation loop

void Vcomparator_tb___024root___eval_initial(Vcomparator_tb___024root* vlSelf);
void Vcomparator_tb___024root___eval_settle(Vcomparator_tb___024root* vlSelf);
void Vcomparator_tb___024root___eval(Vcomparator_tb___024root* vlSelf);
#ifdef VL_DEBUG
void Vcomparator_tb___024root___eval_debug_assertions(Vcomparator_tb___024root* vlSelf);
#endif  // VL_DEBUG
void Vcomparator_tb___024root___final(Vcomparator_tb___024root* vlSelf);

static void _eval_initial_loop(Vcomparator_tb__Syms* __restrict vlSymsp) {
    vlSymsp->__Vm_didInit = true;
    Vcomparator_tb___024root___eval_initial(&(vlSymsp->TOP));
    // Evaluate till stable
    do {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial loop\n"););
        Vcomparator_tb___024root___eval_settle(&(vlSymsp->TOP));
        Vcomparator_tb___024root___eval(&(vlSymsp->TOP));
    } while (0);
}

void Vcomparator_tb::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vcomparator_tb::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vcomparator_tb___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    // Initialize
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) _eval_initial_loop(vlSymsp);
    // Evaluate till stable
    do {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Clock loop\n"););
        Vcomparator_tb___024root___eval(&(vlSymsp->TOP));
    } while (0);
    // Evaluate cleanup
}

//============================================================
// Utilities

VerilatedContext* Vcomparator_tb::contextp() const {
    return vlSymsp->_vm_contextp__;
}

const char* Vcomparator_tb::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

VL_ATTR_COLD void Vcomparator_tb::final() {
    Vcomparator_tb___024root___final(&(vlSymsp->TOP));
}
