N  = 6;       % filter order
fc = 20000;      % Hz  -3 dB frequency
fs = 48000;     % Hz  sample frequency
a  = biquad_synth(N,fc,fs);

a
b= [1 2 1];
b
K1= sum(a(1,:))/4;
K2= sum(a(2,:))/4;
K3= sum(a(3,:))/4;
K1
K2
K3