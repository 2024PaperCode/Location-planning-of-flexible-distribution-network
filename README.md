# Location-planning-of-flexible-distribution-network

The following points should be noted:

  1、For Case 2 and Case 6, the dual technique must be used for solution; otherwise, the solution may fail. As the solver is implemented via the primal-dual interior-point method, the
problem can be directly solved by the solver after being transformed into a dual problem. For the dualization of the problem, refer to the dual-OPF-CE.pdf. It should be noted that 
Reference [Zero Duality Gap in Optimal Power Flow Problem] (doi: 10.1109/TPWRS.2011.2160974) has proven that the relaxation problem and the dual OPF problem in the main text satisfy 
strong duality. The reasons why we did not adopt the dual OPF algorithm for Case 1, Case 3, Case 4 and Case 5 are as follows: At the beginning, we only considered small-scale 
problems, and large-scale problems were added later. Subsequently, we found that the original algorithm would fail to solve large-scale problems, so we adopted the dual OPF to solve 
large-scale problems. We also briefly introduced the dual OPF in the main text.

  2、When using the solver to calculate Case 1, Case 3, Case 4 and Case 5, numerical issues may arise, and the solutions obtained by using the two methods (the solution method for 
  the original problem and the solution method for the dual problem) may be inconsistent. This is because the default convergence accuracy of the solver is 1e-7, while the final 
  convergence accuracy of the above cases during the solution process ranges between 1e-4 and 1e-5. To improve the solution efficiency, we did not force the precision to be set as 1e-
  7 here. It should be noted that this solution accuracy has met the calculation 
  requirements.  For example, in the case of the IEEE 33-node system, when only the generator set costs are considered, the value obtained by using the algorithm in case1 is 78.34 US 
  dollars. The value obtained by using the dual algorithm is 78.09 US dollars. The gap 
  between the two is very small (0.3%). Therefore, the accuracy gap between the two can be ignored. 


  3、For Case 1, Case 3, Case 4 and Case 5, this paper adopts the graph decomposition technique, i.e., instead of treating the system as an integrated 66-bus system, it is regarded 
as two 33-bus systems. Each system has its own OPF, and communication between systems is carried out via SOPs or PRFCs (or treated as a virtual "wire").

If you have any questions about the manuscript or code, please contact 1743773910@qq.com or leave a message under this repository.
  
