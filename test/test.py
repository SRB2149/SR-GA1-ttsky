# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from cocotb.types import LogicArray

import random

#CONSTANTS
SCAN_PATH_LENGTH = 581 #20*28 + 3 * 7
VERBOSE = True

def rand_seq(length):
    seq = []
    for i in range(length):
        seq.append(random.randint(0,1))
    return seq
    
def const_seq(length, val):
    seq = []
    for i in range(length):
        seq.append(val)
    return seq

def scan_in(dut, seq):
    for i in range(SCAN_PATH_LENGTH):
        if VERBOSE:
            dut._log.info(f"Loading bit[{i}] with value {seq[i]}")
        val = LogicArray(dut.ui_in.value)
        val[0] = seq[i]
        dut.ui_in.value = val
        await ClockCycles(dut.clk, 1)


@cocotb.test()
async def test_scan_path(dut):
    dut._log.info("Start")

    # Set the clock period to 250 ns (4 MHz)
    clock = Clock(dut.clk, 250, unit="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test scan path")
    
    # Get random sequence
    seq = const_seq(SCAN_PATH_LENGTH, 1)

    # Scan in 111111111...
    scan_in(dut, seq):
        
    dut._log.info(f"Written {SCAN_PATH_LENGTH} bits into the programming shift register")

    # Check the output is correct
    for i in range(SCAN_PATH_LENGTH):
        dut._log.info(f"Reading bit: {i}")
        val = LogicArray(dut.ui_in.value)
        val[0] = 0
        dut.ui_in.value = val
        await ClockCycles(dut.clk, 1)
        assert dut.uo_out.value[0] == 1
