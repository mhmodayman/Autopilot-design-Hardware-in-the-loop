function state_dot = state_dot_fn2(t,vector)
%This program calculates the states derivative for the a/c nonlinear model
%It requires the Operating Conditions, Initial Conditions (global variables) & Controllers
global choice OC_ch uo vo wo po qo ro phio thetao epsaio deo dTo dao dro de dT da dr desired_pitch


 if choice==4
    %----------FOXTROT - A twin engined, jet fighter/bomber aircraft
    %----------Opertating Conditions--------
        if OC_ch==3
            Uo=350; %m/s
            alphao=1.6; %deg
            gammao=0; %deg
            %----------A/C Characteristics------
            Ix=33900; Iy=16600; Iz=190000; Ixz=3000; %kg.m^2
            %----------Stability Derivatives-------
            Xu=-0.0135; Xw=0.006; Xde=0.77; XdT=0.00006;
            Zu=0.0125; Zw=-0.727; Zwd=0; Zq=-1.25; Zde=-20.7; ZdT=-0.00005;
            Mu=0.009; Mw=-0.08; Mwd=-0.001; Mq=-0.745; Mde=-23.5; MdT=-0.000003;
            Yv=-176/Uo; Yp=0; Yr=0; Lbetad=-14.1; Lpd=-1.38; Lrd=0.318; Nbetad=12.3; Npd=-0.038; Nrd=-0.4;
            Ydast=-0.0009; Ydrst=0.004; Ldad=10.9; Ldrd=3; Ndad=0.67; Ndrd=3.2;
        end
 end

g=9.801;
Lbeta=-(Nbetad*Ixz-Ix*Lbetad)/Ix; Nbeta=(Iz*Nbetad-Ixz*Lbetad)/Iz;
Lp=-(Npd*Ixz-Ix*Lpd)/Ix; Np=(Iz*Npd-Ixz*Lpd)/Iz;
Lr=-(Nrd*Ixz-Ix*Lrd)/Ix; Nr=(Iz*Nrd-Ixz*Lrd)/Iz;
Lda=-(Ndad*Ixz-Ix*Ldad)/Ix; Nda=(Iz*Ndad-Ixz*Ldad)/Iz;
Ldr=-(Ndrd*Ixz-Ix*Ldrd)/Ix; Ndr=(Iz*Ndrd-Ixz*Ldrd)/Iz;
u=vector(1); v=vector(2); w=vector(3); p=vector(4); q=vector(5); r=vector(6); phi=vector(7); theta=vector(8); epsai=vector(9);

K = [0.0031   -0.7217   -7.7460]; % gains
de = desired_pitch*K(3) - w*K(1)- q*K(2) - theta*K(3);
if de > 0.5
    de = 0.5;
elseif de < -0.5
    de = -0.5;
end

%-----------------States Dots---------------
J = Ix*Iz-Ixz^2; 
c1=((Iy-Iz)*Iz-Ixz^2)/J; c2=(Ix-Iy+Iz)*Ixz/J; c3=Iz/J; c4=Ixz/J; c5=(Iz-Ix)/Iy; c6=Ixz/Iy; c7=1/Iy; c8=(Ix*(Ix-Iy)+Ixz^2)/J; c9=Ix/J;

Fx_m = g*(sin(thetao)-sin(theta))+Xu*(u-uo)+Xw*(w-wo)+Xde*(de-deo)+XdT*(dT-dTo);
Fy_m = g*(sin(phi)*cos(theta)-sin(phio)*cos(thetao))+Yv*(v-vo)+Yp*(p-po)+Yr*(r-ro)+Ydast*uo*(da-dao)+Ydrst*uo*(dr-dro);
Fz_m = g*(cos(theta)*cos(phi)-cos(thetao)*cos(phio))+Zu*(u-uo)+Zw*(w-wo)+Zq*(q-qo)+Zde*(de-deo)+ZdT*(dT-dTo);

L = Ix*(Lbeta*(atan(v/u)-atan(vo/uo))+Lp*(p-po)+Lr*(r-ro)+Lda*(da-dao)+Ldr*(dr-dro));
M = Iy*(Mu*(u-uo)+Mw*(w-wo)+Mq*(q-qo)+Mde*(de-deo)+MdT*(dT-dTo));
N = Iz*(Nbetad*(atan(v/u)-atan(vo/uo))+Np*(p-po)+Nr*(r-ro)+Nda*(da-dao)+Ndr*(dr-dro));

udot = Fx_m-q*w+r*v;
vdot = Fy_m-r*u+p*w;
wdot = Fz_m+q*u-p*v;

pdot = (c1*r+c2*p)*q+c3*L+c4*N;
qdot = c5*p*r-c6*(p^2-r^2)+c7*M;
rdot = (c8*p-c2*r)*q+c4*L+c9*N;

phidot   = p+tan(theta)*(q*sin(phi)+r*cos(phi));
thetadot = q*cos(phi)-r*sin(phi);
epsaidot =(q*sin(phi)+r*cos(phi))/cos(theta);

pndot = u*cos(theta)*cos(epsai)+v*(sin(phi)*sin(theta)*cos(epsai)-cos(phi)*sin(epsai))+w*(sin(phi)*sin (epsai)+cos(phi)*sin(theta)*cos(epsai));
pedot = u*cos(theta)*sin(epsai)+v*(sin(phi)*sin(theta)*sin(epsai)+cos(phi)*cos(epsai))+w*(cos(phi)*sin(theta)*sin (epsai)-sin(phi)*cos(epsai));
pddot = -u*sin(theta)+v*sin(phi)*cos(theta)+w*cos(phi)*cos(theta);

state_dot=[pndot pedot pddot udot vdot wdot pdot qdot rdot phidot thetadot epsaidot]';