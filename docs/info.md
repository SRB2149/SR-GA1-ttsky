<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

My project is a small FPGA/CPLD-like device which I am calling the SR-GA1 (GA = gate array).
It consists of a 4x7 grid of configurable logic blocks (CLBs) as well as some clock routing logic
and very basic IO control.

Data is shifted in via fixed input 0 whilst being clocked with the system clock. The FPGA configuration shift register
has no resets (to save space) so configuration is required every time it is powered up. 
The reset pin is used to reset the CLB's single data register and it is synchronous to the relevant CLB column clock.

## How to test

First use my [FPGA programming software](https://github.com/SRB2149/SR-GA1)) 
to create a design and then export the generated bitstream. Copy that bitstream to the RP2040
and use my programmer script to setup the FPGA for use. Then drive the IO as you wish.

## External hardware

You will need a computer which can run my FPGA programming software 
(see my main [SR-GA1 Github](https://github.com/SRB2149/SR-GA1)) 
to create the bitstream which can then be shifted into the FPGA. 
Beyond that, nothing is needed.