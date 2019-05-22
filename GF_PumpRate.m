function GF_PumpRate(hPump,rate)

%Set pump rate directly (ml/min)
fprintf(hPump,'RAT%0.3f\n',rate);

vprintf(1,'Updated pump rate: %.3f ml/min\n',rate)

