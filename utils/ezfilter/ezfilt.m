function [filtX, hAmpX,pX] = ezfilt(X,cuts,Fs,filtType)
% filtX = ezfilt(X,cuts,Fs,filtType)
% X: Signal to be filtered (can be vector or samples x trials matrix)
% cuts: Cutoff frequency or band pass/stop frequencies
% Fs: sampling rate (Hz)
% filtType: 'low','high','stop','pass'
%
% filtX: filtered signal
% hAmpX: hilbert amplitude of filtered signal

n=[];
if any(isnan(X))
    n = isnan(X);
    ind = 1:length(X);
    X = interp1(ind(~n),X(~n),ind,'linear',0);
end
switch filtType
    case 'low'
        assert(length(cuts)==1, 'Use a single cutoff frequency for low-pass filter');
        filtX = lopass_butterworth(X,cuts,Fs,4);
    case 'high'
        assert(length(cuts)==1, 'Use a single cutoff frequency for high-pass filter');
        filtX = hipass_butterworth(X,cuts,Fs,4);
    case 'pass'
        assert(length(cuts)==2, 'Use two cutoff frequencies for band-pass filter');
        filtX = bandpass_butterworth(X,cuts,Fs,2);
    case 'stop'
        assert(length(cuts)==2, 'Use two cutoff frequencies for band-stop filter');
        filtX = bandstop_butterworth(X,cuts,Fs,4);
end

if nargout >= 2
    H=hilbert(filtX);
    hAmpX = abs(H);
    pX = angle(H);
    if ~isempty(n)
        hAmpX(n) = 0;
        pX(n) = nan;
    end
end

if ~isempty(n)
    filtX(n)=nan;
end