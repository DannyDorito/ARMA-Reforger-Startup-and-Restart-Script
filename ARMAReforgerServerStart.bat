::
:: ARMAReforgerServerStart.bat
:: By: Jstrow and Danny Dorito, originally for CSG Exile
:: Minor edits and support by NIXON : https://github.com/niklashenrixon
::
@ECHO OFF
COLOR F
ECHO MESSAGE: Pre startup initialised

:: Command window name, does not affect anything else
:: Default is: ARMA Reforger Server
SET S_NAME=ARMA Reforger Server
:: Path to the ARMA Reforger Server executable,
:: For example: "C:\Program Files (x86)\Steam\steamapps\common\ArmaReforger\ or "C:\ArmaReforger"
:: Supports Running from different drives, for network paths, mount to drive letter or see UNC Path help
:: Cannot be blank
SET EXE_PATH="C:\Program Files (x86)\Steam\steamapps\common\ArmaReforger\"
:: Name of executable
:: Default is: ArmaReforgerServer.exe
:: Cannot be blank
SET EXE="ArmaReforgerServer.exe"
:: Default is: 192.168.1.10
SET AS2_IP=192.168.1.10
:: Default is: 7777
SET AS2_PORT=7777
:: Can be used to override both gameHostBindAddress and gameHostRegisterBindAddress values present in server config.
:: Default is: 192.168.1.42
SET BIND_IP=192.168.1.42
:: Can be used to override both gameHostBindPort and gameHostRegisterBindPort values present in server config.
:: Default is: 2302
SET BIND_PORT=2302
:: Starts up an RplSession in local client mode. The session tries to connect to the provided IP.
:: Default is: 127.0.0.1
SET CLIENT_IP=127.0.0.1
:: Used by servers to point to a JSON server configuration.
:: For more info see: https://community.bistudio.com/wiki/Arma_Reforger:Server_Hosting
SET CONFIG=myConfigFile.json
:: As of 0.9.5 it is heavily recommended to use this startup parameter, please remove from .json config file if using
:: Set to a value in the 60..120 range; otherwise, the server can try to use all the available resources!
SET MAX_FPS=120
:: Extra launch parameters
:: For more info see: https://community.bistudio.com/wiki/Arma_Reforger:Startup_Parameters#Hosting
SET ADDITIONAL_PARAMETERS=-scriptAuthorizeAll -logAppend
:: Restart timeout in seconds
:: For example, 3 hour restarts would be 3 * 60 = 10800
:: Set to 0 to disable automatic restarts
SET RESTART_TIMEOUT=10800

:: Steam automatic update for the server files
:: Get from here https://developer.valvesoftware.com/wiki/SteamCMD
:: Set to true to enable, false to disable
:: Default is: false
SET USE_STEAM_UPDATER=false
:: Path to the Steam CMD server executable, for example:  C:\Program Files (x86)\SteamCMD\
:: Cannot be blank
SET PATH_TO_STEAM_CMD_EXE="changeme"
:: Name of executable
:: Default is: 'SteamCMD.exe'
:: Cannot be blank
SET STEAMCMD="SteamCMD.exe"
:: Name of the Steam account that SteamCMD uses
:: It is highly advised that you use a separate Steam account for the ARMA Reforger server if you choose to use this feature
:: 2FA may be an issues always please be careful with passwords
SET ACCOUNT_NAME=changeme
:: It is highly advised that you use a separate Steam account for the ARMA Reforger server
:: Password of the Steam account that SteamCMD uses, 2FA may be an issues always please be careful with passwords
SET ACCOUNT_PASSWORD=changeme
:: Additional apps or mods that you wish SteamCMD to update for you,
:: this will have to match the workshop item id
:: for example 2288339650 2288336145 for Namalsk
SET ADDITIONAL_ITEMS=changeme

:: ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ::
::             DO NOT CHANGE ANYTHING BELOW THIS POINT               ::
::               UNLESS YOU KNOW WHAT YOU ARE DOING                  ::
:: ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ::

TITLE %S_NAME%

SET ERROR=

ECHO.
ECHO MESSAGE: Starting vars checks

IF %AS2_PORT% ==0 (
	SET ERROR=AS2_PORT
	GOTO CONFIG_ERROR
)
IF %BIND_PORT% ==0 (
	SET ERROR=BIND_PORT
	GOTO CONFIG_ERROR
)
IF %SERVER_FPS_LIMIT% GTR 120 (
	SET ERROR=SERVER_FPS_LIMIT
	GOTO CONFIG_ERROR
)
IF %SERVER_FPS_LIMIT% LEQ 1 (
	SET ERROR=SERVER_FPS_LIMIT
	GOTO CONFIG_ERROR
)

IF %USE_STEAM_UPDATER% ==false (
	GOTO NO_STEAM
)
IF %PATH_TO_STEAM_CMD_EXE% =="changeme" (
	SET ERROR=USE_STEAM_UPDATER = true so, PATH_TO_STEAM_CMD_EXE
	GOTO CONFIG_ERROR
)
IF %ACCOUNT_NAME% ==changeme (
	SET ERROR=USE_STEAM_UPDATER = true so, ACCOUNT_NAME
	GOTO CONFIG_ERROR
)
IF %ACCOUNT_PASSWORD% ==changeme (
	SET ERROR=USE_STEAM_UPDATER = true so, ACCOUNT_PASSWORD
	GOTO CONFIG_ERROR
)

:: Skip if SteamCMD update is disabled
:NO_STEAM

ECHO.
ECHO MESSAGE: Variable checks completed
SET LOOPS=0
IF %USE_STEAM_UPDATER% ==true (
	ECHO MESSAGE: Steam Automatic Update Starting
	START "%S_NAME%" /wait %PATH_TO_STEAM_CMD_EXE% %STEAMCMD% +login %ACCOUNT_NAME% %ACCOUNT_PASSWORD% +force_install_dir %EXE_PATH% +app_update 1874880 %ADDITIONAL_ITEMS% validate +quit
	ECHO MESSAGE: Steam Automatic Update Completed
)
ECHO.
ECHO MESSAGE: Pre startup complete!

:LOOP
TASKLIST /FI IMAGENAME eq %EXE% 2>NUL | find /I /N %EXE% >NUL
IF %ERRORLEVEL% == 0 GOTO LOOP

ECHO MESSAGE: Starting server at: %DATE%, %TIME%
IF %LOOPS% NEQ 0 (
	ECHO MESSAGE: Restarts: %LOOPS%
)

:: Start the ARMA Reforger
CD /D %EXE_PATH%
START "%S_NAME%" /MIN /D %EXE_PATH% %EXE% -config=%CONFIG% -a2sIpAddress=%AS2_IP% -a2sPort=%AS2_PORT% -bindIP=%BIND_IP% -bindPort=%BIND_PORT% -clent=%CLIENT_IP% -maxFPS=%MAX_FPS% %ADDITIONAL_PARAMETERS%
ECHO MESSAGE: To stop the server, close %~nx0 then the other tasks, otherwise it will restart

IF %RESTART_TIMEOUT%=0 (
 GOTO RESTART_SKIP
)
TIMEOUT %RESTART_TIMEOUT%
TASKKILL /im %EXE% /F

:RESTART_SKIP
TIMEOUT 30
ECHO.

:: Restart/Crash Handler
:LOOPING
SET /A LOOPS+=1
TIMEOUT /t 5
TASKLIST /FI IMAGENAME eq %EXE% 2>NUL | find /I /N %EXE% >NUL
ECHO %ERRORLEVEL%
IF %ERRORLEVEL%==0 GOTO LOOPING
GOTO LOOP

:: Generic config error catching
:CONFIG_ERROR
COLOR C
ECHO ERROR: %ERROR% not set correctly, please check the config
PAUSE
COLOR F
