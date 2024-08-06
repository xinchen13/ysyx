// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtop.h for the primary calling header

#ifndef VERILATED_VTOP___024ROOT_H_
#define VERILATED_VTOP___024ROOT_H_  // guard

#include "verilated.h"

class Vtop__Syms;

class Vtop___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk,0,0);
    VL_IN8(rst_n,0,0);
    VL_IN8(ps2_clk,0,0);
    VL_IN8(ps2_data,0,0);
    VL_OUT8(overflow,0,0);
    CData/*1:0*/ top__DOT__state;
    CData/*1:0*/ top__DOT__next_state;
    CData/*7:0*/ top__DOT__scan_code_buf;
    CData/*0:0*/ top__DOT__ready;
    CData/*7:0*/ top__DOT__scan_code;
    CData/*7:0*/ top__DOT__count;
    CData/*2:0*/ top__DOT__u_ps2_keyboard__DOT__w_ptr;
    CData/*2:0*/ top__DOT__u_ps2_keyboard__DOT__r_ptr;
    CData/*3:0*/ top__DOT__u_ps2_keyboard__DOT__count;
    CData/*2:0*/ top__DOT__u_ps2_keyboard__DOT__ps2_clk_sync;
    CData/*0:0*/ top__DOT__u_ps2_keyboard__DOT____Vlvbound_h1a91ade8__0;
    CData/*0:0*/ __Vtrigrprev__TOP__clk;
    CData/*0:0*/ __VactContinue;
    VL_OUT16(scan_code_seg,15,0);
    VL_OUT16(ascii_seg,15,0);
    VL_OUT16(count_seg,15,0);
    SData/*9:0*/ top__DOT__u_ps2_keyboard__DOT__buffer;
    IData/*31:0*/ __VstlIterCount;
    IData/*31:0*/ __VactIterCount;
    VlUnpacked<CData/*7:0*/, 8> top__DOT__u_ps2_keyboard__DOT__fifo;
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<1> __VactTriggered;
    VlTriggerVec<1> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vtop__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vtop___024root(Vtop__Syms* symsp, const char* v__name);
    ~Vtop___024root();
    VL_UNCOPYABLE(Vtop___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);


#endif  // guard
