f_somekinase = 0;
f_PP2A = 0;
f_someTppase = 0;
f_RhoGDP = -(k1.*u(:,1).*u(:,2).*u(:,3))+(k2.*u(:,4))+(k6.*u(:,9));
f_GEFRho = -(k1.*u(:,1).*u(:,2).*u(:,3))+(k2.*u(:,4))+(k3.*u(:,4));
f_GTP = -(k1.*u(:,1).*u(:,2).*u(:,3))+(k2.*u(:,4))-(k7.*u(:,3).*u(:,11).*u(:,12))+(k8.*u(:,13))+(k13.*u(:,6).*u(:,10))-(k14.*u(:,3).*u(:,8));
f_RhoGTP = -(k4.*u(:,5).*u(:,7).*u(:,8))+(k5.*u(:,9))+(k3.*u(:,4));
f_GDP = -(k13.*u(:,6).*u(:,10))+(k14.*u(:,3).*u(:,8))+(k3.*u(:,4))+(k9.*u(:,13));
f_ADP = -(k4.*u(:,5).*u(:,7).*u(:,8))+(k5.*u(:,9))-(k10.*u(:,8).*u(:,14).*u(:,15))+(k11.*u(:,16))+(k13.*u(:,6).*u(:,10))-(k14.*u(:,3).*u(:,8))+(k17.*u(:,10).*u(:,20))-(k18.*u(:,8).*u(:,21))+(k19.*u(:,10).*u(:,20))-(k20.*u(:,8).*u(:,23))-(k21.*u(:,8).*u(:,21))+(k22.*u(:,10).*u(:,20))-(k23.*u(:,8).*u(:,23))+(k24.*u(:,10).*u(:,20))+(k31.*u(:,10).*u(:,29))-(k32.*u(:,8).*u(:,30))+(k33.*u(:,10).*u(:,31))-(k34.*u(:,8).*u(:,32))+(k35.*u(:,10).*u(:,33))-(k36.*u(:,8).*u(:,34))+(k55.*u(:,10).*u(:,20))-(k56.*u(:,8).*u(:,21));
f_ATP = -(k13.*u(:,6).*u(:,10))+(k14.*u(:,3).*u(:,8))-(k17.*u(:,10).*u(:,20))+(k18.*u(:,8).*u(:,21))-(k19.*u(:,10).*u(:,20))+(k20.*u(:,8).*u(:,23))+(k21.*u(:,8).*u(:,21))-(k22.*u(:,10).*u(:,20))+(k23.*u(:,8).*u(:,23))-(k24.*u(:,10).*u(:,20))-(k31.*u(:,10).*u(:,29))+(k32.*u(:,8).*u(:,30))-(k33.*u(:,10).*u(:,31))+(k34.*u(:,8).*u(:,32))-(k35.*u(:,10).*u(:,33))+(k36.*u(:,8).*u(:,34))-(k55.*u(:,10).*u(:,20))+(k56.*u(:,8).*u(:,21))+(k6.*u(:,9))+(k12.*u(:,16));
f_RacGDP = -(k7.*u(:,3).*u(:,11).*u(:,12))+(k8.*u(:,13))+(k12.*u(:,16));
f_GEFRac = -(k7.*u(:,3).*u(:,11).*u(:,12))+(k8.*u(:,13))+(k59.*u(:,41))-(k60.*u(:,12))+(k9.*u(:,13));
f_RacGTP = -(k10.*u(:,8).*u(:,14).*u(:,15))+(k11.*u(:,16))-(k15.*u(:,14).*u(:,18))+(k16.*u(:,19))-(k53.*u(:,14).*u(:,37))+(k54.*u(:,38))+(k9.*u(:,13));
f_PAK = -(k15.*u(:,14).*u(:,18))+(k16.*u(:,19))-(k37.*u(:,18).*u(:,35))+(k38.*u(:,36))-(k43.*u(:,18).*u(:,31))+(k44.*u(:,33))-(k45.*u(:,18).*u(:,32))+(k46.*u(:,34));
f_RacGTPPAK = (k15.*u(:,14).*u(:,18))-(k16.*u(:,19));
f_Paxillin = -(k17.*u(:,10).*u(:,20))+(k18.*u(:,8).*u(:,21))-(k19.*u(:,10).*u(:,20))+(k20.*u(:,8).*u(:,23))+(k21.*u(:,8).*u(:,21))-(k22.*u(:,10).*u(:,20))+(k23.*u(:,8).*u(:,23))-(k24.*u(:,10).*u(:,20))-(k25.*u(:,20).*u(:,22))+(k26.*u(:,26))-(k55.*u(:,10).*u(:,20))+(k56.*u(:,8).*u(:,21));
f_Paxillin_P = (k17.*u(:,10).*u(:,20))-(k18.*u(:,8).*u(:,21))-(k21.*u(:,8).*u(:,21))+(k22.*u(:,10).*u(:,20))-(k27.*u(:,21).*u(:,22))+(k28.*u(:,27))-(k51.*u(:,21).*u(:,34))+(k52.*u(:,37))+(k55.*u(:,10).*u(:,20))-(k56.*u(:,8).*u(:,21));
f_FAK = -(k25.*u(:,20).*u(:,22))+(k26.*u(:,26))-(k27.*u(:,21).*u(:,22))+(k28.*u(:,27))-(k29.*u(:,22).*u(:,23))+(k30.*u(:,28));
f_Paxillin_TP = (k19.*u(:,10).*u(:,20))-(k20.*u(:,8).*u(:,23))-(k23.*u(:,8).*u(:,23))+(k24.*u(:,10).*u(:,20))-(k29.*u(:,22).*u(:,23))+(k30.*u(:,28))-(k57.*u(:,23).*u(:,39))+(k58.*u(:,40));
f_PaxillinFAK = (k25.*u(:,20).*u(:,22))-(k26.*u(:,26));
f_Paxillin_PFAK = (k27.*u(:,21).*u(:,22))-(k28.*u(:,27));
f_GIT = -(k31.*u(:,10).*u(:,29))+(k32.*u(:,8).*u(:,30))-(k39.*u(:,29).*u(:,35))+(k40.*u(:,31))-(k47.*u(:,29).*u(:,36))+(k48.*u(:,33));
f_GIT_P = (k31.*u(:,10).*u(:,29))-(k32.*u(:,8).*u(:,30))-(k41.*u(:,30).*u(:,35))+(k42.*u(:,32))-(k49.*u(:,30).*u(:,36))+(k50.*u(:,34));
f_PIXGIT = -(k33.*u(:,10).*u(:,31))+(k34.*u(:,8).*u(:,32))+(k39.*u(:,29).*u(:,35))-(k40.*u(:,31))-(k43.*u(:,18).*u(:,31))+(k44.*u(:,33));
f_PIXGIT_P = (k33.*u(:,10).*u(:,31))-(k34.*u(:,8).*u(:,32))+(k41.*u(:,30).*u(:,35))-(k42.*u(:,32))-(k45.*u(:,18).*u(:,32))+(k46.*u(:,34));
f_PAKPIXGIT_P = (k35.*u(:,10).*u(:,33))-(k36.*u(:,8).*u(:,34))+(k45.*u(:,18).*u(:,32))-(k46.*u(:,34))+(k49.*u(:,30).*u(:,36))-(k50.*u(:,34))-(k51.*u(:,21).*u(:,34))+(k52.*u(:,37));
subs2__0 = - f_ATP - f_FAK - f_GTP - f_GIT_P - f_PIXGIT_P - f_Paxillin - f_PAKPIXGIT_P - f_RacGDP - f_Paxillin_P - f_RhoGDP - f_PaxillinFAK - f_Paxillin_TP;
subs2__1 = - f_GEFRho - f_RhoGDP - f_RhoGTP;
subs2__2 = -f_GTP;
subs2__3 = -f_ATP;
subs2__4 = -f_RacGTPPAK;
subs2__5 = -f_GDP;
subs2__6 = -f_ADP;
subs2__7 = -f_PaxillinFAK;
subs2__8 = -f_RhoGDP;
subs2__9 = -f_RacGDP;
subs2__10 = -f_PIXGIT_P;
subs2__11 = -f_PIXGIT;
subs2__12 = -f_GEFRho;
subs2__13 = -f_RhoGTP;
subs2__14 = -f_RacGTP;
subs2__15 = -f_Paxillin;
subs2__16 = -f_PAK;
subs2__17 = -f_GIT_P;
subs2__18 = -f_GIT;
subs2__19 = subs2__1 + subs2__3 + subs2__6;
subs2__20 = subs2__2 + subs2__3 + subs2__4 + subs2__5 + subs2__6 + subs2__8 + subs2__9 + subs2__13 + subs2__14;
subs2__21 = subs2__4 + subs2__10 + subs2__11 + subs2__16;
subs2__22 = subs2__2 + subs2__5 + subs2__12;

Rx = [f_RhoGDP,...
f_GEFRho,...
f_GTP,...
subs2__12,...
f_RhoGTP,...
f_GDP,...
subs2__1,...
f_ADP,...
subs2__1,...
f_ATP,...
f_RacGDP,...
f_GEFRac,...
subs2__22,...
f_RacGTP,...
subs2__19,...
subs2__19,...
f_somekinase,...
f_PAK,...
f_RacGTPPAK,...
f_Paxillin,...
f_Paxillin_P,...
f_FAK,...
f_Paxillin_TP,...
f_PP2A,...
f_someTppase,...
f_PaxillinFAK,...
f_Paxillin_PFAK,...
subs2__7 - f_Paxillin_PFAK - f_FAK,...
f_GIT,...
f_GIT_P,...
f_PIXGIT,...
f_PIXGIT_P,...
subs2__2 + subs2__3 + subs2__7 + subs2__8 + subs2__9 + subs2__11 + subs2__15 + subs2__18,...
f_PAKPIXGIT_P,...
subs2__21,...
subs2__17 + subs2__18 + subs2__21,...
subs2__7 - f_PAKPIXGIT_P + subs2__10 + subs2__15 + subs2__17 + subs2__20,...
subs2__20,...
subs2__0,...
subs2__0,...
subs2__22 - f_GEFRac];