# Interrupt distributor

A unit to distribute N interrupt sources to M targets. The number of output
interrupt lines is N*M.

## Register map

TODO

## Testbench
In `tb/` there is a simple testbench. Run it by calling

```
make build
make sim
run -a
```
