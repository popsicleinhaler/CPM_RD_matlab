RacRatio0 = x(:,:,2) / Rac_Square;
RacRatio = (x(:,:,2) + ((Rac*(Pax_Square*Rac_Square + Pax_Square*x(:,:,2)*alpha_R + PIX*Pax_Square*Rac_Square*k_X + PIX*Pax_Square*x(:,:,2)*alpha_R*k_X + GIT*PIX*Pax_Square*Rac_Square*k_G*k_X + GIT*PIX*x(:,:,6)*Paxtot*Rac_Square*k_C*k_G*k_X + GIT*PIX*x(:,:,6)*Paxtot*x(:,:,2)*alpha_R*k_C*k_G*k_X))/(PAKtot*Rac_Square*alpha_PAK*(Pax_Square + PIX*Pax_Square*k_X + GIT*PIX*x(:,:,6)*Paxtot*k_C*k_G*k_X)))) / Rac_Square;
RhoRatio = x(:,:,4) / Rho_Square;
PaxRatio = x(:,:,6) / Pax_Square;
K_is=1./((1+k_X*PIX+k_G*k_X*k_C*GIT*PIX*Paxtot*PaxRatio).*(1+alpha_R*RacRatio0)+k_G*k_X*GIT*PIX);
K=alpha_R*RacRatio0.*K_is.*(1+k_X*PIX+k_G*k_X*k_C*Paxtot*GIT*PIX*PaxRatio);
I_Ks=I_K*(1-K_is.*(1+alpha_R*RacRatio0));
Q_R = (I_R+I_Ks).*(L_rho^m./(L_rho^m+RhoRatio.^m));
Q_rho = I_rho*(L_R^m./(L_R^m +(RacRatio).^m));
Q_P = B_1*(K.^n./(L_K^n+K.^n));