# RISC-V-Single-cycle
### A modular RTL design of a Single Cycle RISC-V core

This project aims on implementing 5-types of instrcutions from RISC-V ISA :
1. **R-Type**: Register instructions, that operate on the core's registers.
2. **I-Type**: Immediate instructions, that also include immediate operands along with registers in there operations.
3. **B-Type**: Branch instructions, that are used branching (conditional) to different parts of the program being executed.
4. **L-Type**: Load instructions, that are used to load data from the data-memory to the core's registers.
5. **S-Type**: Store instructions, that are used for storing the data from the core's registers to the data-memory.

**Tools used**: Xilinx Vivado (Simulation and Synthesis), VS Code (Code Editor).
Reference Documents will be avaialble in the **Documentation** folder. 

For the most part I have made the design and simulation files **modular** and **self commenting**.
If you still have any doubts or want detailed report you can refer my **Documenation** folder.

I am also working on a **new revision** of this **RISC-V core** that **supports Pipelining**.
