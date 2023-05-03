// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Package auto-generated by `reggen` containing data structure

package irq_router_reg_pkg;

  // Address widths within the block
  parameter int BlockAw = 2;

  ////////////////////////////
  // Typedefs for registers //
  ////////////////////////////

  typedef struct packed {
    logic [31:0] q;
  } irq_router_reg2hw_irq_target_mask_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } irq_router_hw2reg_irq_target_mask_reg_t;

  // Register -> HW type
  typedef struct packed {
    irq_router_reg2hw_irq_target_mask_reg_t irq_target_mask; // [31:0]
  } irq_router_reg2hw_t;

  // HW -> register type
  typedef struct packed {
    irq_router_hw2reg_irq_target_mask_reg_t irq_target_mask; // [32:0]
  } irq_router_hw2reg_t;

  // Register offsets
  parameter logic [BlockAw-1:0] IRQ_ROUTER_IRQ_TARGET_MASK_OFFSET = 2'h 0;

  // Register index
  typedef enum int {
    IRQ_ROUTER_IRQ_TARGET_MASK
  } irq_router_id_e;

  // Register width information to check illegal writes
  parameter logic [3:0] IRQ_ROUTER_PERMIT [1] = '{
    4'b 1111  // index[0] IRQ_ROUTER_IRQ_TARGET_MASK
  };

endpackage
