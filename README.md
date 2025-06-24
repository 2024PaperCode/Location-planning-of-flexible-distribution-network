# Location-planning-of-flexible-distribution-network

The following points should be noted:

  1、For all cases in the paper, due to the low solution efficiency of the W matrix, we adopted acceleration techniques for it: for small-scale cases, we adopted the **graph 
decomposition technique**, i.e., instead of treating the system as an integrated 66-bus system, it is regarded as two 33-bus systems. Each system has its own OPF, and communication 
between systems is carried out via SOPs or PRFCs (or treated as a virtual "wire"). For more detailed information on graph decomposition techniques, please refer to [A Two-Stage 
Decomposition Approach for AC Optimal Power Flow] (doi: 10.1109/TPWRS.2020.3002189). For large-scale cases, we adopted dual technology, and the dualization of the problem is 
detailed in <<dual-OPF-CE.pdf>>. It should be noted that Reference [Zero Duality Gap in Optimal Power Flow Problem] (doi: 10.1109/TPWRS.2011.2160974) has proven that the relaxation 
problem and the dual OPF problem in the main text **satisfy strong duality**, that is, its dual gap is zero. **Therefore,the two solving methods are essentially equivalent.**

  2、The solution accuracy is generally set to 1e-7, but in order to accelerate the calculation in the paper, we set the solution accuracy to 1e-4. It should be noted that the 
accuracy of 1e-4 roughly meets the accuracy requirements, and the optimal gap between the two is very small , for example, for IEEE 33 bus system, the value is 78.34 when 
the accuracy is 1e-4 and 78.10 when the accuracy is 1e-7, the optimal gap between the two is approximately 0.3%. So the two can be approximately considered equal.

If you have any questions about the manuscript or code, please contact 1743773910@qq.com or leave a message under this repository.

  
