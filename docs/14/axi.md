# AMBA AXI protocol

## Introduction
The AXI protocol supports high-performance, high-frequency system designs for communication between master and slave components

The AXI protocol is transactions-based and defines five independent channels:
- Write request, which has signal names beginning with AW
- Write data, which has signal names beginning with W
- Write response, which has signal names beginning with B
- Read request, which has signal names beginning with AR
- Read data, which has signal names beginning with R

Each of the five independent channels consists of a set of information signals and VALID and READY signals that provide a two-way handshake mechanism. The information source uses the VALID signal to show when valid address, data, or control information is available on the channel. The destination uses the READY signal to show when it can accept the information