:user_configuration

if exist "%FLEX_SDK%" goto succeed

:: Path to Flex SDK (muuta vastavalt kasutajale)
set FLEX_SDK=C:\Program Files (x86)\FlashDevelop\Tools\flexsdk
::set FLEX_SDK=C:\Program Files\FlashDevelop\Tools\flexsdk\frameworks\libs\player\11.0\playerglobal.swc
::set FLEX_SDK=C:\Program Files\FlashDevelop\Tools\flexsdk\
::C:\Program Files\FlashDevelop\Tools\flexsdk\bin

:validation
if not exist "%FLEX_SDK%" goto flexsdk
goto succeed

:flexsdk
echo.
echo ERROR: incorrect path to Flex SDK in 'bat\SetupSDK.bat'
echo.
echo %FLEX_SDK%
echo.
if %PAUSE_ERRORS%==1 pause
exit

:succeed
set PATH=%PATH%;%FLEX_SDK%\bin

