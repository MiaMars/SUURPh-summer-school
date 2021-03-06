function [monitored] = hybrid_monitor(t, states, parameters)
  % Computes monitored expressions of the hybrid ODE

  % Assign states
  if length(states)~=11
    error('Expected the states array to be of size 11.');
  end
  TCa=states(1); TMon=states(2); AMATP=states(3); MATP=states(4);...
    MADPP=states(5); AwMADPP=states(6); AsMADPP=states(7); AsMADP=states(8);...
    AMADP=states(9); MADP=states(10); M=states(11);

  % Assign parameters
  if length(parameters)~=47
    error('Expected the parameters array to be of size 47.');
  end
  stretch=parameters(1); velocity=parameters(2); Ca_amplitude=parameters(3);...
    Ca_diastolic=parameters(4); start_time=parameters(5); tau1=parameters(6);...
    tau2=parameters(7); ATP=parameters(8); F_physiol=parameters(9);...
    Fmax=parameters(10); N_v=parameters(11); TCa_stretch=parameters(14);...
    TMon_coop=parameters(15); TMon_pow=parameters(16);...
    detachVel=parameters(17); k5_stretch=parameters(18);...
    k5_xb=parameters(19); k7_base=parameters(20); k7_force=parameters(21);...
    k7_stretch=parameters(22); k_1=parameters(23); k_10=parameters(24);...
    k_11=parameters(25); k_12=parameters(26); k_13=parameters(27);...
    k_14=parameters(28); k_2=parameters(29); k_3=parameters(30);...
    k_4=parameters(31); k_5=parameters(32); k_6=parameters(33);...
    k_7=parameters(34); k_8=parameters(35); k_9=parameters(36);...
    k_m1=parameters(37); k_m3=parameters(38); k_m4=parameters(39);...
    k_m5=parameters(40); k_m6=parameters(41); k_m8=parameters(42);...
    k_off=parameters(43); k_on=parameters(44); tm_off=parameters(45);...
    tm_on=parameters(46); v50=parameters(47);

  % Init return args
  monitored = zeros(27, 1);

  % Expressions for the Equation for simulated calcium transient component
  monitored(1) = (tau1/tau2)^(-1/(-1 + tau1/tau2)) - (tau1/tau2)^(-1/(1 -...
    tau2/tau1));
  monitored(2) = ((t > start_time)*(Ca_diastolic + (Ca_amplitude -...
    Ca_diastolic)*(-exp((start_time - t)/tau2) + exp((start_time -...
    t)/tau1))/monitored(1)) + ~(t > start_time)*(Ca_diastolic));

  % Expressions for the Troponin component
  monitored(16) = -k_off*TCa + k_on*stretch^TCa_stretch*(1.0 - TCa)*(2.0 -...
    AMATP - AwMADPP - M - MADP - MADPP - MATP)*monitored(2);
  monitored(17) = monitored(16);

  % Expressions for the Tropomyosin component
  monitored(18) = -tm_off*TMon + tm_on*(1.0 + (TMon_coop +...
    stretch)*TMon)^TMon_pow*(1.0 - TMon)*TCa;

  % Expressions for the Crossbridge component
  monitored(3) = ((stretch < 1.0)*(-0.4666667 + 1.4666667*stretch) +...
    ~(stretch < 1.0)*(((stretch <= 1.1)*(1.0) + ~(stretch <= 1.1)*(2.61333337 -...
    1.4666667*stretch))));
  monitored(4) = k_5*TMon;
  monitored(5) = k_7*(k7_base - k7_stretch*stretch + abs(velocity))/(1.0 +...
    k7_force*(1.0 - AMATP - AsMADPP - AwMADPP - M - MADP - MADPP -...
    MATP)*monitored(3)/Fmax);
  monitored(6) = abs(velocity)^N_v/(v50^N_v + abs(velocity)^N_v);

  % Transition ratios for state variables
  monitored(7) = -k_m1*AMATP + ATP*k_1*(1.0 - AMADP - AMATP - AsMADP -...
    AsMADPP - AwMADPP - M - MADP - MADPP - MATP);
  monitored(8) = k_2*(1.0 + detachVel*monitored(6))*AMATP;
  monitored(9) = k_3*MATP - k_m3*MADPP;
  monitored(10) = k_4*MADPP - k_m4*(1.0 + detachVel*monitored(6))*AwMADPP;
  monitored(11) = -k_m5*AsMADPP + (1.0 + k5_xb*(1.0 - AMATP - AwMADPP - M -...
    MADP - MADPP - MATP))^2*(0.4 + k5_stretch*stretch)*AwMADPP*monitored(4);
  monitored(12) = k_6*AsMADPP - k_m6*AsMADP;
  monitored(13) = AsMADP*monitored(5);
  monitored(14) = k_8*AMADP - k_m8*(1.0 - AMADP - AMATP - AsMADP - AsMADPP -...
    AwMADPP - M - MADP - MADPP - MATP);

  % State variables of actin-myosin complex
  monitored(19) = -monitored(8) + monitored(7);
  monitored(20) = -monitored(9) + ATP*k_14*M + monitored(8);
  monitored(21) = -monitored(10) + k_13*AsMADPP*monitored(6) + monitored(9);
  monitored(22) = -monitored(11) + monitored(10);
  monitored(23) = -monitored(12) - k_13*AsMADPP*monitored(6) + monitored(11);
  monitored(24) = -monitored(13) - k_11*AsMADP*monitored(6) + monitored(12);
  monitored(25) = -monitored(14) - k_10*AMADP*monitored(6) + monitored(13);
  monitored(26) = -k_12*MADP + k_10*AMADP*monitored(6) +...
    k_11*AsMADP*monitored(6);
  monitored(27) = k_12*MADP + k_9*(1.0 - AMADP - AMATP - AsMADP - AsMADPP -...
    AwMADPP - M - MADP - MADPP - MATP)*monitored(6) - ATP*k_14*M;

  % Active force
  monitored(15) = F_physiol*(1.0 - AMATP - AsMADPP - AwMADPP - M - MADP -...
    MADPP - MATP)*monitored(3)/Fmax;
end