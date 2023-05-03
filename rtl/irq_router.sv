// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Alessandro Ottaviano <aottaviano@iis.ee.ethz.ch>
// Robert Balas <balasr@iis.ee.ethz.ch>

// Distribute NumIntrSrc interrupts to NumIntrTargets targets according to a
// configurable mask. 1s in the mask indicate valid targets for the single
// interrupt line.

`include "register_interface/assign.svh"
`include "register_interface/typedef.svh"

module irq_router import irq_router_reg_pkg::*; #(
  parameter type         reg_req_t      = logic,
  parameter type         reg_rsp_t      = logic,
  parameter int unsigned NumIntrSrc     = 64,
  parameter int unsigned NumIntrTargets = 2
) (
  input logic                                  clk_i,
  input logic                                  rst_ni,

  input reg_req_t                              reg_req_i,
  output reg_rsp_t                             reg_rsp_o,

  input logic                 [NumIntrSrc-1:0]  irqs_i,
  output logic  [NumIntrTargets*NumIntrSrc-1:0] irqs_distributed_o
);

  if (NumIntrTargets > 32)
    $fatal(1, "maximum number supported targets is 32");

  irq_router_reg2hw_t [NumIntrSrc-1:0] irq_router_reg2hw;
  irq_router_hw2reg_t [NumIntrSrc-1:0] irq_router_hw2reg;

  reg_req_t [NumIntrSrc-1:0] reg_int_req;
  reg_rsp_t [NumIntrSrc-1:0] reg_int_rsp;

  logic [15:0] which_irq;

  // Top level address decoding and bux muxing. All registers of the irq
  // router are 32 bits wide.
  always_comb begin : irq_router_addr_decode
    which_irq = reg_req_i.addr[15:2];

    reg_int_req = '0;
    reg_rsp_o   = '0;

    reg_int_req[which_irq] = reg_req_i;
    reg_int_req[which_irq].addr = reg_req_i.addr[1:0];
    reg_rsp_o = reg_int_rsp[which_irq];
  end

  // Target configuration registers
  for (genvar i = 0; i < NumIntrSrc; i++) begin : gen_irq_router_regs
    irq_router_reg_top #(
      .reg_req_t(reg_req_t),
      .reg_rsp_t(reg_rsp_t)
    ) i_irq_router_reg_top (
      .clk_i,
      .rst_ni,

      .reg2hw (irq_router_reg2hw[i]),
      .hw2reg (irq_router_hw2reg[i]),

      .reg_req_i(reg_int_req[i]),
      .reg_rsp_o(reg_int_rsp[i]),

      .devmode_i(1'b1)
    );
  end // block: gen_irq_router_regs

  // Support array of NumIntrTargets*NumIntrSrc from input interrupt array
  logic [NumIntrTargets*NumIntrSrc-1:0] irqs_cloned;
  for (genvar i = 0; i < NumIntrTargets; i++) begin : gen_irq_il
    for (genvar j = 0; j < NumIntrSrc; j++) begin : gen_irq_jl
      assign irqs_cloned[j+(i*NumIntrSrc)] = irqs_i[j];
    end
  end

  // Array of masks for NumIntrTargets*NumIntrSrc
  logic [NumIntrTargets*NumIntrSrc-1:0] irqs_target_mask;
  for (genvar i = 0; i < NumIntrSrc; i++) begin : gen_mask_il
    for (genvar j = 0; j < NumIntrTargets; j++) begin : gen_mask_jl
      assign irqs_target_mask[i+(NumIntrSrc*j)] = irq_router_reg2hw[i].irq_target_mask.q[j];
    end
  end

  // Distribution of NumIntrSrc interrupts to NumIntrTargets targets according to mask
  assign irqs_distributed_o = irqs_cloned & irqs_target_mask;

endmodule // irq_router
