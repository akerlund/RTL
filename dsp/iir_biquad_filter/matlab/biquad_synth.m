% biquad_synth.m    2/10/18 Neil Robertson
% Synthesize even-order IIR Butterworth lowpass filter as cascaded biquads.
% This function computes the denominator coefficients a of the biquads.
% N= filter order (must be even)
% fc= -3 dB frequency in Hz
% fs= sample frequency in Hz
% a = matrix of denominator coefficients of biquads.  Size = (N/2,3)
%     each row of a contains the denominator coeffs of a biquad.
%     There are N/2 rows.
% Note numerator coeffs of each biquad= K*[1 2 1], where K = (1 + a1 + a2)/4.
%
function a = biquad_synth(N,fc,fs);
if fc>=fs/2;
  error('fc must be less than fs/2')
end
if mod(N,2)~=0
    error('N must be even')
end
%I.  Find analog filter poles above the real axis (half of total poles)
k= 1:N/2;
theta= (2*k -1)*pi/(2*N);
pa= -sin(theta) + j*cos(theta);     % poles of filter with cutoff = 1 rad/s
pa= fliplr(pa);                  %reverse sequence of poles ? put high Q last
% II.  scale poles in frequency
Fc= fs/pi * tan(pi*fc/fs);          % continuous pre-warped frequency
pa= pa*2*pi*Fc;                     % scale poles by 2*pi*Fc
% III.  Find coeffs of biquads
% poles in the z plane
p= (1 + pa/(2*fs))./(1 - pa/(2*fs));      % poles by bilinear transform
% denominator coeffs 
for k= 1:N/2;
    a1= -2*real(p(k));
    a2= abs(p(k))^2;
    a(k,:)= [1 a1 a2];             %coeffs of biquad k
end