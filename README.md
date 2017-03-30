# 8x8-Switch-using-System-Verilog


Introduction:
-------------
In this project 8X8 switch has been implemented using System Verilog. The design has 8 input ports and 8 output ports. The serial data can come from any of the 8 input ports and get routed to any of the 8 output ports. The design has FIFO implemented to buffer packets so that there is no loss of packets even when all input ports are transmitting data to one output port. The design has been verified for 4 tests SMOKE test, 1PORT test, 4PORT test and CONCURRENT test and found to be functionally working well for all test cases. The design is further synthesized and timing verifications are done and the design met the timing requirements for 24ns clock frequency (30ns is the requirement for the project). Gate level verifications have been performed and ensured the design works for all 4 tests even after synthesis. This document describes the input and output protocol specification, RTL simulation results, Synthesis logs and Gate level verification results.


Input Protocol:
---------------
Cycle   Frame_n[i]    Valid_v[i]    di[i]
1           0               1         A0   (Address 0)  
2           0               1         A1  
3           0               1         A2
4           0               1         A3
5           0               1         X (Padding)
6           0               1         X 
7           0               0         P0 (Payload 0th bit)
8           0               0         P1
...
...
...
38          0               0          P30 
39          1               0          P31 (Last bit of data)
40          1               1          X 


Output Protocol:
---------------
Cycle   Frame_n[i]    Valid_v[i]    di[i]
1           0               0         P0 (Payload 0th bit)
2           0               0         P1
...
...
30          0               0         P30 
31          1               0         P31 (Last bit of data)
32          1               1         X



