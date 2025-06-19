function [total_cost, loss_cost, device_cost] = OPFCE(nsop, nrpfc, fr_sop,to_sop, Cmax_sop, fr_rpfc,to_rpfc, Cmax_rpfc, mpc, baseMVA, bus, gen, branch, gencost, nl, ns, ng, Ybus)
    ndevice = nsop + nrpfc;
    k = cell(ndevice,2);
    fr = [fr_sop, fr_rpfc];
    to = [to_sop, to_rpfc];
    Cmax = [Cmax_sop, Cmax_rpfc];

    Pmin_cons = zeros([1,ns]);
    Qmin_cons = zeros([1,ns]);
    Pmax_cons = zeros([1,ns]);
    Qmax_cons = zeros([1,ns]);
    Vmax_cons = zeros([1,ns]);
    Vmin_cons = zeros([1,ns]);
    Pd = zeros([1,ns]);
    Qd = zeros([1,ns]);
    Plm_max = zeros(ns);
    Slm_max = zeros(ns);
    
    e = eye(ns);
    Y_k = cell(1, ns);
    Y_k_pa = cell(1, ns);
    Y_lm = cell(1, nl);
    Y_lm_pa= cell(1, nl);
    M_k = cell(1, ns);


    for i = 1:ns
        yktmp = e(:, i)*(e(:, i))'*Ybus;
        Y_k{i} = 0.5.*[real(yktmp + yktmp.'),  imag(yktmp.' - yktmp); imag(yktmp - yktmp.'), real(yktmp + yktmp.')];
        Y_k_pa{i} = -0.5.*[imag(yktmp + yktmp.'), real(yktmp - yktmp.'); real(yktmp.' - yktmp), imag(yktmp + yktmp.')];
        M_k{i} = [e(:, i)*(e(:,i)'), zeros(ns); zeros(ns), e(:, i)*(e(:,i)')];
    
        Vmin_cons(i) = bus(i,13);
        Vmax_cons(i) = bus(i,12);
    
        Pd(i) = bus(i,3);
        Qd(i) = bus(i,4);
    end
    
    for i = 1:ng
        Qmax_cons(gen(i,1)) = Qmax_cons(gen(i,1)) + gen(i,4);
        Qmin_cons(gen(i,1)) = Qmin_cons(gen(i,1)) + gen(i,5);
        Pmax_cons(gen(i,1)) = Pmax_cons(gen(i,1)) + gen(i,9);
        Pmin_cons(gen(i,1)) = Pmin_cons(gen(i,1)) + gen(i,10);
    end

    
    for i = 1:nl
        p = branch(i,1);
        q = branch(i,2);
        yltmp = Ybus(p,q).*(e(:, p)*(e(:, p)')-e(:, p)*(e(:, q)'));
        Y_lm{i} = 0.5.*[real(yltmp + yltmp.'), imag(yltmp.' - yltmp); imag(yltmp - yltmp.'), real(yltmp + yltmp.')];
        Y_lm_pa{i} = -0.5.*[imag(yltmp + yltmp.'), real(yltmp - yltmp.'); real(yltmp.' - yltmp), imag(yltmp + yltmp.')];
        Plm_max(p, q) = Plm_max(p, q) + branch(i,6);
        Slm_max(p, q) = Slm_max(p, q) + branch(i,6);
        Plm_max(q, p) = Plm_max(p, q);
        Slm_max(q, p) = Slm_max(p, q);
    end

    
    Pmin_cons = Pmin_cons ./ baseMVA;
    Pmax_cons = Pmax_cons ./ baseMVA;
    Qmin_cons = Qmin_cons ./ baseMVA;
    Qmax_cons = Qmax_cons ./ baseMVA;
    Pd = Pd ./ baseMVA;
    Qd = Qd ./ baseMVA;
    Plm_max = Plm_max ./ baseMVA;
    Slm_max = Slm_max ./ baseMVA;
    Cmax = Cmax ./ baseMVA;
    

    lambda_ud = sdpvar(ns, 1);
    lambda_up = sdpvar(ns, 1);
    gama_ud = sdpvar(ns, 1);
    gama_up = sdpvar(ns, 1);
    miu_ud = sdpvar(ns, 1);
    miu_up = sdpvar(ns, 1);
    lambda_lm = sdpvar(nl, 1);

    r_k1 = sdpvar(ng, 1);
    r_k2 = sdpvar(ng, 1);

    for i = 1 : ndevice
        k{i, 1} = sdpvar(3, 3, 'symmetric');
        k{i, 2} = sdpvar(3, 3, 'symmetric');
    end
    
    
    r_lm = cell(1, nl);
    for i = 1:nl
        r_lm{i} = sdpvar(3, 3, 'symmetric');
    end
    

    lambda_k = sdpvar(ns, 1);
    gama_k = sdpvar(ns, 1);
    miu_k = sdpvar(ns, 1);
    for i = 1 : ns
        if ismember(i, gen(:,1))
            [row, col] = find(gen(:,1) == i);
            ck1 = gencost(row,6)*baseMVA;
            ck2 = gencost(row,5)*baseMVA^2;
            lambda_k(i) = -lambda_ud(i)+lambda_up(i)+ck1+2*sqrt(ck2)*r_k1(row);
        else
            lambda_k(i) = -lambda_ud(i)+lambda_up(i);
        end
        gama_k(i) = -gama_ud(i)+gama_up(i);
        miu_k(i) = -miu_ud(i)+miu_up(i);
    end

    h = 0;
    A = 0;

    for i = 1 : ns
        h = h + lambda_ud(i)*Pmin_cons(i) - lambda_up(i)*Pmax_cons(i) + lambda_k(i)*Pd(i) + ...
                    gama_ud(i)*Qmin_cons(i) - gama_up(i)*Qmax_cons(i) + gama_k(i)*Qd(i) + ...
                    miu_ud(i)*Vmin_cons(i)*Vmin_cons(i) - miu_up(i)*Vmax_cons(i)*Vmax_cons(i);
        A = A + lambda_k(i)*Y_k{i} + gama_k(i)*Y_k_pa{i} + miu_k(i)*M_k{i};
        if ismember(i,gen(:,1))
            [row, col] = find(gen(:,1) == i);
            ck0 = gencost(row,7);
            h = h + (ck0 - r_k2(row));
        end
    end

    for i = 1 : ndevice
        h = h  - (Cmax(i)*Cmax(i)*k{i,1}(1,1) + k{i,1}(2,2) + k{i,1}(3,3));
        h = h  - (Cmax(i)*Cmax(i)*k{i,2}(1,1) + k{i,2}(2,2) + k{i,2}(3,3));
    end
    

    for i = 1 : nl
        p = branch(i,1);
        q = branch(i,2);
        h = h - (lambda_lm(i) * Plm_max(p,q) + Slm_max(p,q)*Slm_max(p,q)*r_lm{i}(1,1) +r_lm{i}(2,2) + r_lm{i}(3,3));
        A = A + ((2*r_lm{i}(1,2)+lambda_lm(i))*Y_lm{i} + 2*r_lm{i}(1,3)*Y_lm_pa{i});
    end


    
    obj = -h; % max h  <-->  min -h
    constraint = [A>=0];
    for i = 1: ng
        constraint = [constraint, [1 r_k1(i); r_k1(i) r_k2(i)] >= 0];
    end

    for i = 1 : nl
        constraint = [constraint, r_lm{i} >= 0];
    end

    constraint = [constraint, lambda_ud >= 0, lambda_up >= 0, ...
              gama_ud >= 0, gama_up >= 0, ...
              miu_ud >= 0, miu_up >= 0, ...
              lambda_lm >= 0
              ];
     
    for i = 1 : ndevice
        constraint = [constraint, -lambda_ud(fr(i))+lambda_up(fr(i))+lambda_ud(to(i))-lambda_up(to(i))+k{i,1}(1,2)+k{i,2}(1,2) == 0];
        constraint = [constraint, k{i,1} >= 0, k{i,2} >= 0];
        if i <= nsop
            constraint = [constraint, -gama_ud(fr(i))+gama_up(fr(i))+k{i,1}(1,3) == 0];
            constraint = [constraint, -(gama_ud(to(i))-gama_up(to(i)))+k{i,2}(1,3) == 0];
        else
            constraint = [constraint, -gama_ud(fr(i))+gama_up(fr(i))+gama_ud(to(i))-gama_up(to(i))+k{i,1}(1,3)+k{i,2}(1,3) == 0];
        end
    end




    % The constraints and objective function have both been constructed. 
    % At this point, the solver is called and the constraints and objective function are passed into it.

    
end
