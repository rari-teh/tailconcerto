@ECHO OFF
SET /A POINTER=2314
SET /A XA=19
:LOOP
ECHO %XA%
java -jar jpsxdec.jar -x tcntscu.idx -i %pointer% -replaceaudio garfunkel\%xa%.wav
IF %XA% EQU 87 GOTO END
SET /A POINTER=%POINTER%+1
SET /A XA=%XA%+1
GOTO LOOP
:END
