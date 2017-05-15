This program launches another program(child) N time (0<N<255). Name of child program install in textfile in K line(0<K<255).
When you want to start this program you need to write for example: laba7.exe file.txt 3
/*
laba7.exe - name of main program
file.txt - name of file which contains line with name of child program and number of repetition 
3 - K-line
*/
This program has troubles:
1) If K-line didn't exit, I wouldn't know what happen. 
2) If name of file didn't fill completely in one buffer, we would have a problem.
3) Code has repetitions(translate, Translate1)