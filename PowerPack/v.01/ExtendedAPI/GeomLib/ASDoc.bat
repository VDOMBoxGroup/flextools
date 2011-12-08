setlocal enabledelayedexpansion
@echo off
cls
set ASDOC_PATH=C:\Program Files\Adobe\Flex Builder 3\sdks\3.0.0\bin\aasdoc
set DEFAULT_OUTPUT_FOLDER=asdocs
set ASDOCS_FOLDER=asdocs
set DESTINATION_FOLDER=bin

set CUR_VOLUME=%~d0
set CUR_FOLDER_PATH=%~p0
set CUR_FOLDER_PATH=%CUR_FOLDER_PATH:~0,-1%

rem *************************************************************************************************
rem GET DESTINATION PATH AND CURRENT FOLDER NAME
rem *************************************************************************************************
SET SUBSTR=%DESTINATION_FOLDER%
SET STRING=%CUR_FOLDER_PATH%
:next_for
FOR /F "usebackq tokens=1,* delims=\" %%i IN ('!STRING!') DO (
	SET STRING=%%j
	
	IF "%%i"=="!SUBSTR!" (
		SET DESTINATION_PATH=!NEWSTRING!
	)
	
	IF "!NEWSTRING!"=="" (
		SET NEWSTRING=!NEWSTRING!%%i
	) ELSE (
		SET NEWSTRING=!NEWSTRING!\%%i
	)
	
	IF EXIST "!CUR_VOLUME!\!NEWSTRING!\!DESTINATION_FOLDER!" (
		SET DESTINATION_PATH=!NEWSTRING!\!DESTINATION_FOLDER!
	)

	IF NOT "!STRING!"=="" GOTO :next_for
	SET FOLDER_NAME=%%i
)

rem *************************************************************************************************
IF "%FOLDER_NAME%"=="" (
	ECHO ERROR: You cannot run me from root directory.
	ECHO.
	GOTO :exit
)

SET OUTPUT_PATH=%CUR_VOLUME%\%DESTINATION_PATH%\%ASDOCS_FOLDER%\%FOLDER_NAME%
IF "%DESTINATION_PATH%"=="" (
	SET OUTPUT_PATH=%CUR_VOLUME%\%DEFAULT_OUTPUT_FOLDER%\%FOLDER_NAME%
	ECHO INFO: Destination folder not found.
	ECHO.
	ECHO INFO: Default output path "!OUTPUT_PATH!" will be used.
	ECHO.
)

IF EXIST "%OUTPUT_PATH%" (
	ECHO WARNING: Output folder "%OUTPUT_PATH%" already exists.
	ECHO.
	ECHO WARNING: Do you want to clear this folder before proceed
	ECHO.
	RMDIR /S "%OUTPUT_PATH%"
) 

IF NOT EXIST "%OUTPUT_PATH%" (
	MKDIR "%OUTPUT_PATH%"
)

rem *************************************************************************************************
rem RUN ASDOC SCRIPT
rem *************************************************************************************************

:execute

IF EXIST "%CUR_FOLDER_PATH%\..\asdoc-config.xml" (
	SET CONFIG=-load-config+="%CUR_FOLDER_PATH%\..\asdoc-config.xml"
) 

rem call "%ASDOC_PATH%" -help
call "%ASDOC_PATH%" -doc-sources "%CUR_VOLUME%%CUR_FOLDER_PATH%" -output "%OUTPUT_PATH%" %CONFIG%

:exit
PAUSE
