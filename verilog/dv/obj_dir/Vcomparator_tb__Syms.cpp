// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "Vcomparator_tb__Syms.h"
#include "Vcomparator_tb.h"
#include "Vcomparator_tb___024root.h"
#include "Vcomparator_tb___024unit.h"

// FUNCTIONS
Vcomparator_tb__Syms::~Vcomparator_tb__Syms()
{
}

Vcomparator_tb__Syms::Vcomparator_tb__Syms(VerilatedContext* contextp, const char* namep,Vcomparator_tb* modelp)
    : VerilatedSyms{contextp}
    // Setup internal state of the Syms class
    , __Vm_modelp{modelp}
    // Setup module instances
    , TOP(namep)
    , TOP____024unit(Verilated::catName(namep, "$unit"))
{
    // Configure time unit / time precision
    _vm_contextp__->timeunit(-9);
    _vm_contextp__->timeprecision(-12);
    // Setup each module's pointers to their submodules
    TOP.__PVT____024unit = &TOP____024unit;
    // Setup each module's pointer back to symbol table (for public functions)
    TOP.__Vconfigure(this, true);
    TOP____024unit.__Vconfigure(this, true);
    // Setup scopes
    __Vscope_comparator_tb.configure(this, name(), "comparator_tb", "comparator_tb", -9, VerilatedScope::SCOPE_OTHER);
}
