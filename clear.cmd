@echo off

taskkill /IM info.exe /f

set dt=%DATE:~6,4%%DATE:~3,2%%DATE:~0,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%
set dt=%dt: =0%

mkdir dat_backup
mkdir dat_backup\%dt%

copy /Y firms.dat       dat_backup\%dt%\firms.dat
copy /Y portfolio.dat   dat_backup\%dt%\portfolio.dat
copy /Y scripts.dat     dat_backup\%dt%\scripts.dat
copy /Y unins000.dat    dat_backup\%dt%\unins000.dat
copy /Y alerts.dat      dat_backup\%dt%\alerts.dat
copy /Y alltrade.dat    dat_backup\%dt%\alltrade.dat
copy /Y banners.dat     dat_backup\%dt%\banners.dat
copy /Y classes.dat     dat_backup\%dt%\classes.dat
copy /Y limits.dat      dat_backup\%dt%\limits.dat
copy /Y locales.dat     dat_backup\%dt%\locales.dat
copy /Y orders.dat      dat_backup\%dt%\orders.dat
copy /Y par.dat         dat_backup\%dt%\par.dat
copy /Y search.dat      dat_backup\%dt%\search.dat
copy /Y sec.dat         dat_backup\%dt%\sec.dat
copy /Y StratVolat.dat  dat_backup\%dt%\StratVolat.dat
copy /Y tmsg.dat        dat_backup\%dt%\tmsg.dat
copy /Y transresult.dat dat_backup\%dt%\transresult.dat
copy /Y trades.dat      dat_backup\%dt%\trades.dat
copy /Y tradermsg.dat   dat_backup\%dt%\stradermsg.dat
copy /Y trans.dat       dat_backup\%dt%\trans.dat
copy /Y stradermsg.dat  dat_backup\%dt%\stradermsg.dat
					 
del portfolio.dat /F /Q

del acnt.dat /F /Q
del alltrade.dat /F /Q
del banners.dat /F /Q

del firms.dat /F /Q
del limits.dat /F /Q
del locales.dat /F /Q
del orders.dat /F /Q

del search.dat /F /Q

del StratVolat.dat /F /Q
del tmsg.dat /F /Q
del transresult.dat /F /Q
del trades.dat /F /Q
del tradermsg.dat /F /Q
del trans.dat /F /Q
del stradermsg.dat /F /Q
 
del *.log /F /Q

start info.exe
