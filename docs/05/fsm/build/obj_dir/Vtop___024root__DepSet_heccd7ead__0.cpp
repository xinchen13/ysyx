// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtop.h for the primary calling header

#include "verilated.h"

#include "Vtop___024root.h"

void Vtop___024root___eval_act(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_act\n"); );
}

extern const VlUnpacked<CData/*7:0*/, 256> Vtop__ConstPool__TABLE_h6bb5baf1_0;
extern const VlUnpacked<CData/*7:0*/, 16> Vtop__ConstPool__TABLE_h1f93ebb4_0;
extern const VlUnpacked<CData/*7:0*/, 32> Vtop__ConstPool__TABLE_h66eba408_0;

VL_INLINE_OPT void Vtop___024root___nba_sequent__TOP__0(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___nba_sequent__TOP__0\n"); );
    // Init
    CData/*0:0*/ top__DOT__display_en;
    top__DOT__display_en = 0;
    CData/*7:0*/ top__DOT__ascii_code;
    top__DOT__ascii_code = 0;
    CData/*7:0*/ top__DOT____Vcellout__u_scan_code_l__seg_display;
    top__DOT____Vcellout__u_scan_code_l__seg_display = 0;
    CData/*7:0*/ top__DOT____Vcellout__u_scan_code_h__seg_display;
    top__DOT____Vcellout__u_scan_code_h__seg_display = 0;
    CData/*7:0*/ top__DOT____Vcellout__u_ascii_l__seg_display;
    top__DOT____Vcellout__u_ascii_l__seg_display = 0;
    CData/*7:0*/ top__DOT____Vcellout__u_ascii_h__seg_display;
    top__DOT____Vcellout__u_ascii_h__seg_display = 0;
    CData/*7:0*/ top__DOT____Vcellout__u_count_l__seg_display;
    top__DOT____Vcellout__u_count_l__seg_display = 0;
    CData/*7:0*/ top__DOT____Vcellout__u_count_h__seg_display;
    top__DOT____Vcellout__u_count_h__seg_display = 0;
    CData/*7:0*/ __Vtableidx1;
    __Vtableidx1 = 0;
    CData/*4:0*/ __Vtableidx2;
    __Vtableidx2 = 0;
    CData/*4:0*/ __Vtableidx3;
    __Vtableidx3 = 0;
    CData/*4:0*/ __Vtableidx4;
    __Vtableidx4 = 0;
    CData/*4:0*/ __Vtableidx5;
    __Vtableidx5 = 0;
    CData/*3:0*/ __Vtableidx6;
    __Vtableidx6 = 0;
    CData/*3:0*/ __Vtableidx7;
    __Vtableidx7 = 0;
    CData/*2:0*/ __Vdly__top__DOT__u_ps2_keyboard__DOT__ps2_clk_sync;
    __Vdly__top__DOT__u_ps2_keyboard__DOT__ps2_clk_sync = 0;
    CData/*2:0*/ __Vdly__top__DOT__u_ps2_keyboard__DOT__r_ptr;
    __Vdly__top__DOT__u_ps2_keyboard__DOT__r_ptr = 0;
    CData/*2:0*/ __Vdlyvdim0__top__DOT__u_ps2_keyboard__DOT__fifo__v0;
    __Vdlyvdim0__top__DOT__u_ps2_keyboard__DOT__fifo__v0 = 0;
    CData/*7:0*/ __Vdlyvval__top__DOT__u_ps2_keyboard__DOT__fifo__v0;
    __Vdlyvval__top__DOT__u_ps2_keyboard__DOT__fifo__v0 = 0;
    CData/*0:0*/ __Vdlyvset__top__DOT__u_ps2_keyboard__DOT__fifo__v0;
    __Vdlyvset__top__DOT__u_ps2_keyboard__DOT__fifo__v0 = 0;
    CData/*2:0*/ __Vdly__top__DOT__u_ps2_keyboard__DOT__w_ptr;
    __Vdly__top__DOT__u_ps2_keyboard__DOT__w_ptr = 0;
    CData/*3:0*/ __Vdly__top__DOT__u_ps2_keyboard__DOT__count;
    __Vdly__top__DOT__u_ps2_keyboard__DOT__count = 0;
    // Body
    __Vdly__top__DOT__u_ps2_keyboard__DOT__ps2_clk_sync 
        = vlSelf->top__DOT__u_ps2_keyboard__DOT__ps2_clk_sync;
    __Vdly__top__DOT__u_ps2_keyboard__DOT__count = vlSelf->top__DOT__u_ps2_keyboard__DOT__count;
    __Vdly__top__DOT__u_ps2_keyboard__DOT__w_ptr = vlSelf->top__DOT__u_ps2_keyboard__DOT__w_ptr;
    __Vdly__top__DOT__u_ps2_keyboard__DOT__r_ptr = vlSelf->top__DOT__u_ps2_keyboard__DOT__r_ptr;
    __Vdlyvset__top__DOT__u_ps2_keyboard__DOT__fifo__v0 = 0U;
    __Vdly__top__DOT__u_ps2_keyboard__DOT__ps2_clk_sync 
        = ((6U & ((IData)(vlSelf->top__DOT__u_ps2_keyboard__DOT__ps2_clk_sync) 
                  << 1U)) | (IData)(vlSelf->ps2_clk));
    if (vlSelf->rst_n) {
        vlSelf->top__DOT__scan_code_buf = ((IData)(vlSelf->top__DOT__ready)
                                            ? (IData)(vlSelf->top__DOT__scan_code)
                                            : (IData)(vlSelf->top__DOT__scan_code_buf));
        if ((2U == (IData)(vlSelf->top__DOT__state))) {
            vlSelf->top__DOT__count = (0xffU & ((IData)(1U) 
                                                + (IData)(vlSelf->top__DOT__count)));
        }
    } else {
        vlSelf->top__DOT__scan_code_buf = 0U;
        vlSelf->top__DOT__count = 0U;
    }
    if (vlSelf->rst_n) {
        if (vlSelf->top__DOT__ready) {
            __Vdly__top__DOT__u_ps2_keyboard__DOT__r_ptr 
                = (7U & ((IData)(1U) + (IData)(vlSelf->top__DOT__u_ps2_keyboard__DOT__r_ptr)));
            if (((IData)(vlSelf->top__DOT__u_ps2_keyboard__DOT__w_ptr) 
                 == (7U & ((IData)(1U) + (IData)(vlSelf->top__DOT__u_ps2_keyboard__DOT__r_ptr))))) {
                vlSelf->top__DOT__ready = 0U;
            }
        }
        if ((IData)((4U == (6U & (IData)(vlSelf->top__DOT__u_ps2_keyboard__DOT__ps2_clk_sync))))) {
            if ((0xaU == (IData)(vlSelf->top__DOT__u_ps2_keyboard__DOT__count))) {
                if (VL_UNLIKELY((((~ (IData)(vlSelf->top__DOT__u_ps2_keyboard__DOT__buffer)) 
                                  & (IData)(vlSelf->ps2_data)) 
                                 & VL_REDXOR_32((0x1ffU 
                                                 & ((IData)(vlSelf->top__DOT__u_ps2_keyboard__DOT__buffer) 
                                                    >> 1U)))))) {
                    VL_WRITEF("receive %x\n",8,(0xffU 
                                                & ((IData)(vlSelf->top__DOT__u_ps2_keyboard__DOT__buffer) 
                                                   >> 1U)));
                    __Vdlyvval__top__DOT__u_ps2_keyboard__DOT__fifo__v0 
                        = (0xffU & ((IData)(vlSelf->top__DOT__u_ps2_keyboard__DOT__buffer) 
                                    >> 1U));
                    __Vdlyvset__top__DOT__u_ps2_keyboard__DOT__fifo__v0 = 1U;
                    __Vdlyvdim0__top__DOT__u_ps2_keyboard__DOT__fifo__v0 
                        = vlSelf->top__DOT__u_ps2_keyboard__DOT__w_ptr;
                    vlSelf->top__DOT__ready = 1U;
                    __Vdly__top__DOT__u_ps2_keyboard__DOT__w_ptr 
                        = (7U & ((IData)(1U) + (IData)(vlSelf->top__DOT__u_ps2_keyboard__DOT__w_ptr)));
                    vlSelf->overflow = ((IData)(vlSelf->overflow) 
                                        | ((IData)(vlSelf->top__DOT__u_ps2_keyboard__DOT__r_ptr) 
                                           == (7U & 
                                               ((IData)(1U) 
                                                + (IData)(vlSelf->top__DOT__u_ps2_keyboard__DOT__w_ptr)))));
                }
                __Vdly__top__DOT__u_ps2_keyboard__DOT__count = 0U;
            } else {
                vlSelf->top__DOT__u_ps2_keyboard__DOT____Vlvbound_h1a91ade8__0 
                    = vlSelf->ps2_data;
                if (VL_LIKELY((9U >= (IData)(vlSelf->top__DOT__u_ps2_keyboard__DOT__count)))) {
                    vlSelf->top__DOT__u_ps2_keyboard__DOT__buffer 
                        = (((~ ((IData)(1U) << (IData)(vlSelf->top__DOT__u_ps2_keyboard__DOT__count))) 
                            & (IData)(vlSelf->top__DOT__u_ps2_keyboard__DOT__buffer)) 
                           | (0x3ffU & ((IData)(vlSelf->top__DOT__u_ps2_keyboard__DOT____Vlvbound_h1a91ade8__0) 
                                        << (IData)(vlSelf->top__DOT__u_ps2_keyboard__DOT__count))));
                }
                __Vdly__top__DOT__u_ps2_keyboard__DOT__count 
                    = (0xfU & ((IData)(1U) + (IData)(vlSelf->top__DOT__u_ps2_keyboard__DOT__count)));
            }
        }
    } else {
        __Vdly__top__DOT__u_ps2_keyboard__DOT__count = 0U;
        __Vdly__top__DOT__u_ps2_keyboard__DOT__w_ptr = 0U;
        __Vdly__top__DOT__u_ps2_keyboard__DOT__r_ptr = 0U;
        vlSelf->overflow = 0U;
        vlSelf->top__DOT__ready = 0U;
    }
    vlSelf->top__DOT__state = ((IData)(vlSelf->rst_n)
                                ? (IData)(vlSelf->top__DOT__next_state)
                                : 0U);
    vlSelf->top__DOT__u_ps2_keyboard__DOT__ps2_clk_sync 
        = __Vdly__top__DOT__u_ps2_keyboard__DOT__ps2_clk_sync;
    vlSelf->top__DOT__u_ps2_keyboard__DOT__w_ptr = __Vdly__top__DOT__u_ps2_keyboard__DOT__w_ptr;
    vlSelf->top__DOT__u_ps2_keyboard__DOT__count = __Vdly__top__DOT__u_ps2_keyboard__DOT__count;
    vlSelf->top__DOT__u_ps2_keyboard__DOT__r_ptr = __Vdly__top__DOT__u_ps2_keyboard__DOT__r_ptr;
    if (__Vdlyvset__top__DOT__u_ps2_keyboard__DOT__fifo__v0) {
        vlSelf->top__DOT__u_ps2_keyboard__DOT__fifo[__Vdlyvdim0__top__DOT__u_ps2_keyboard__DOT__fifo__v0] 
            = __Vdlyvval__top__DOT__u_ps2_keyboard__DOT__fifo__v0;
    }
    __Vtableidx1 = vlSelf->top__DOT__scan_code_buf;
    top__DOT__ascii_code = Vtop__ConstPool__TABLE_h6bb5baf1_0
        [__Vtableidx1];
    __Vtableidx6 = (0xfU & (IData)(vlSelf->top__DOT__count));
    top__DOT____Vcellout__u_count_l__seg_display = 
        Vtop__ConstPool__TABLE_h1f93ebb4_0[__Vtableidx6];
    __Vtableidx7 = (0xfU & ((IData)(vlSelf->top__DOT__count) 
                            >> 4U));
    top__DOT____Vcellout__u_count_h__seg_display = 
        Vtop__ConstPool__TABLE_h1f93ebb4_0[__Vtableidx7];
    vlSelf->top__DOT__scan_code = vlSelf->top__DOT__u_ps2_keyboard__DOT__fifo
        [vlSelf->top__DOT__u_ps2_keyboard__DOT__r_ptr];
    vlSelf->count_seg = (((IData)(top__DOT____Vcellout__u_count_h__seg_display) 
                          << 8U) | (IData)(top__DOT____Vcellout__u_count_l__seg_display));
    vlSelf->top__DOT__next_state = ((0U == (IData)(vlSelf->top__DOT__state))
                                     ? ((IData)(vlSelf->top__DOT__ready)
                                         ? 1U : 0U)
                                     : ((1U == (IData)(vlSelf->top__DOT__state))
                                         ? (((IData)(vlSelf->top__DOT__ready) 
                                             & (0xf0U 
                                                == (IData)(vlSelf->top__DOT__scan_code)))
                                             ? 2U : 1U)
                                         : ((2U == (IData)(vlSelf->top__DOT__state))
                                             ? ((IData)(vlSelf->top__DOT__ready)
                                                 ? 2U
                                                 : 0U)
                                             : 0U)));
    top__DOT__display_en = ((1U == (IData)(vlSelf->top__DOT__state)) 
                            & (0xf0U != (IData)(vlSelf->top__DOT__scan_code)));
    __Vtableidx2 = ((0x1eU & ((IData)(vlSelf->top__DOT__scan_code_buf) 
                              << 1U)) | (IData)(top__DOT__display_en));
    top__DOT____Vcellout__u_scan_code_l__seg_display 
        = Vtop__ConstPool__TABLE_h66eba408_0[__Vtableidx2];
    __Vtableidx3 = ((0x1eU & ((IData)(vlSelf->top__DOT__scan_code_buf) 
                              >> 3U)) | (IData)(top__DOT__display_en));
    top__DOT____Vcellout__u_scan_code_h__seg_display 
        = Vtop__ConstPool__TABLE_h66eba408_0[__Vtableidx3];
    __Vtableidx4 = ((0x1eU & ((IData)(top__DOT__ascii_code) 
                              << 1U)) | (IData)(top__DOT__display_en));
    top__DOT____Vcellout__u_ascii_l__seg_display = 
        Vtop__ConstPool__TABLE_h66eba408_0[__Vtableidx4];
    __Vtableidx5 = ((0x1eU & ((IData)(top__DOT__ascii_code) 
                              >> 3U)) | (IData)(top__DOT__display_en));
    top__DOT____Vcellout__u_ascii_h__seg_display = 
        Vtop__ConstPool__TABLE_h66eba408_0[__Vtableidx5];
    vlSelf->scan_code_seg = (((IData)(top__DOT____Vcellout__u_scan_code_h__seg_display) 
                              << 8U) | (IData)(top__DOT____Vcellout__u_scan_code_l__seg_display));
    vlSelf->ascii_seg = (((IData)(top__DOT____Vcellout__u_ascii_h__seg_display) 
                          << 8U) | (IData)(top__DOT____Vcellout__u_ascii_l__seg_display));
}

void Vtop___024root___eval_nba(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_nba\n"); );
    // Body
    if (vlSelf->__VnbaTriggered.at(0U)) {
        Vtop___024root___nba_sequent__TOP__0(vlSelf);
    }
}

void Vtop___024root___eval_triggers__act(Vtop___024root* vlSelf);
#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__act(Vtop___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__nba(Vtop___024root* vlSelf);
#endif  // VL_DEBUG

void Vtop___024root___eval(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval\n"); );
    // Init
    VlTriggerVec<1> __VpreTriggered;
    IData/*31:0*/ __VnbaIterCount;
    CData/*0:0*/ __VnbaContinue;
    // Body
    __VnbaIterCount = 0U;
    __VnbaContinue = 1U;
    while (__VnbaContinue) {
        __VnbaContinue = 0U;
        vlSelf->__VnbaTriggered.clear();
        vlSelf->__VactIterCount = 0U;
        vlSelf->__VactContinue = 1U;
        while (vlSelf->__VactContinue) {
            vlSelf->__VactContinue = 0U;
            Vtop___024root___eval_triggers__act(vlSelf);
            if (vlSelf->__VactTriggered.any()) {
                vlSelf->__VactContinue = 1U;
                if (VL_UNLIKELY((0x64U < vlSelf->__VactIterCount))) {
#ifdef VL_DEBUG
                    Vtop___024root___dump_triggers__act(vlSelf);
#endif
                    VL_FATAL_MT("/home/xinchen/ysyx/docs/05/fsm/vsrc/top.v", 1, "", "Active region did not converge.");
                }
                vlSelf->__VactIterCount = ((IData)(1U) 
                                           + vlSelf->__VactIterCount);
                __VpreTriggered.andNot(vlSelf->__VactTriggered, vlSelf->__VnbaTriggered);
                vlSelf->__VnbaTriggered.set(vlSelf->__VactTriggered);
                Vtop___024root___eval_act(vlSelf);
            }
        }
        if (vlSelf->__VnbaTriggered.any()) {
            __VnbaContinue = 1U;
            if (VL_UNLIKELY((0x64U < __VnbaIterCount))) {
#ifdef VL_DEBUG
                Vtop___024root___dump_triggers__nba(vlSelf);
#endif
                VL_FATAL_MT("/home/xinchen/ysyx/docs/05/fsm/vsrc/top.v", 1, "", "NBA region did not converge.");
            }
            __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
            Vtop___024root___eval_nba(vlSelf);
        }
    }
}

#ifdef VL_DEBUG
void Vtop___024root___eval_debug_assertions(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_debug_assertions\n"); );
    // Body
    if (VL_UNLIKELY((vlSelf->clk & 0xfeU))) {
        Verilated::overWidthError("clk");}
    if (VL_UNLIKELY((vlSelf->rst_n & 0xfeU))) {
        Verilated::overWidthError("rst_n");}
    if (VL_UNLIKELY((vlSelf->ps2_clk & 0xfeU))) {
        Verilated::overWidthError("ps2_clk");}
    if (VL_UNLIKELY((vlSelf->ps2_data & 0xfeU))) {
        Verilated::overWidthError("ps2_data");}
}
#endif  // VL_DEBUG
