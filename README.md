# Location-planning-of-flexible-distribution-network

The following points should be noted:

  1、For Case 2 and Case 6, the dual technique must be used for solution; otherwise, the solution may fail. For the dualization of the problem, refer to the dual-OPF-CE.pdf. It 
  should be noted that Reference [Zero Duality Gap in Optimal Power Flow Problem] (doi: 10.1109/TPWRS.2011.2160974) has proven that the relaxation problem and the dual OPF problem in 
  the main text satisfy strong duality, that is, its dual gap is zero. Therefore, the two solving methods are essentially equivalent. The reasons why we did not adopt the dual OPF algorithm for Case 1, Case 3, Case 4 and Case 5 are as follows: 
  At the beginning, we only considered small-scale problems, and large-scale problems were added later. Subsequently, we found that the original algorithm would fail to solve large-
  scale problems, so we adopted the dual OPF to solve large-scale problems. We also briefly introduced the dual OPF in the main text. Due to the particularity of this transformation (see the PDF for details), the general transformation is highly difficult. Therefore, we have not introduced it into the main text.

  2、The solution accuracy is generally set to 1e-7, but in order to accelerate the calculation in the paper, we set the solution accuracy to 1e-4. It should be noted that the 
accuracy of 1e-4 roughly meets the accuracy requirements, and the optimal gap between the two is very small , for example, for IEEE 33 bus system, the value is 78.07 when 
the accuracy is 1e-4 and 78.09 when the accuracy is 1e-7, so the two can be approximately considered equal.

  3、For Case 1, Case 3, Case 4 and Case 5, this paper adopts the graph decomposition technique, i.e., instead of treating the system as an integrated 66-bus system, it is regarded 
as two 33-bus systems. Each system has its own OPF, and communication between systems is carried out via SOPs or PRFCs (or treated as a virtual "wire").

  4、The calculation times listed in the paper are all based on the testing of the dual method, which is the average time obtained from two runs.


If you have any questions about the manuscript or code, please contact 1743773910@qq.com or leave a message under this repository.

  
