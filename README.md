# pqhw
Post-quantum crypto implementations for the FPGAs

## Introduction
The **pqhw** implementations are a result of the [PQCRYPTO](https://pqcrypto.eu.org) project funded by the European Commission in the H2020 program. Note that these are research oriented implementations and not ready for productive use. It is published under the license contained in the license.rtf file and allows evaluation by academics but no commercial use. Please contact the authors if you intend to use this implementation for other purposes than academic evaluation and verification of our results. The implementations are distributed in the hope that they will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 

## Schemes included in pqhw
Currently **pqhw** contains implementations of the following post-quantum NIST PQC candidates:
* [NewHope-1024](https://newhopecrypto.org)

Currently **pqhw** contains implementations of the following post-quantum schemes that are not NIST PQC candidates:
* [BLISS](http://bliss.di.ens.fr/)

## Setup/Installation
* NewHope was tested with Vivado v2015.3 but should also work with other version of Vivado.
* BLISS was tested with ISE 14.7 but should also work with other version of ISE.
* You can find further information and a copy of the paper and other works on our [project website](http://http://www.seceng.rub.de/research/projects/pqc/).

## Running tests and benchmarks
* To see NewHope in action run the Test_NewHope.vhd testbench.
* To see BLISS in action run the bliss_sign_then_verify_tb.vhd testbench. Edit the generics to simulate different parameter sets. Some fixed paths might not work (relative is also not an option). Please fix them when you see the error messages. 

## Benchmarks
| scheme | implementation | LUT | FF | BRAM | DSP | MHz | Cycles
| ------ | ---------- | ------------- | ----- | ----- | ----- | ----- | ----------|
| NewHope-1024 | server | 5,142 |  4,452 | 4 | 2 | 125 | 171,124 |
| NewHope-1024 | client | 4,498 |  4,635 | 4 | 2 | 117 | 179,292 |

## License
* The License for NewHope can be found in NewHope/license.rtf
* The License for BLISS can be found in BLISS/lattice_processor/license.rtf