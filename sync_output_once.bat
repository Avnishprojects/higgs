@echo off
REM -------------------------------
REM EC2 output folder -> Local copy (zip + download + unzip)
REM Fully automated, one click
REM -------------------------------

REM -------------------------------
REM User settings
REM -------------------------------
SET PEM_FILE=C:\Users\avnis\My_Projects\Higgs-Boson-Classifier\higgsnewkeys.pem
SET LOCAL_DIR=C:\Users\avnis\My_Projects\Higgs-Boson-Classifier
SET EC2_USER=ubuntu
SET EC2_IP=13.233.233.136
SET EC2_PROJECT_DIR=/home/ubuntu/higgsnew
SET EC2_OUTPUT_DIR=%EC2_PROJECT_DIR%/output
SET EC2_ZIP_FILE=%EC2_PROJECT_DIR%/output.zip

echo -------------------------------
echo Installing zip on EC2 if missing...
echo -------------------------------
ssh -i "%PEM_FILE%" %EC2_USER%@%EC2_IP% "which zip || sudo apt update && sudo apt install zip -y"

echo -------------------------------
echo Creating zip of output folder on EC2...
echo -------------------------------
ssh -i "%PEM_FILE%" %EC2_USER%@%EC2_IP% "cd %EC2_PROJECT_DIR% && zip -r output.zip output/"

echo -------------------------------
echo Checking if zip was created...
echo -------------------------------
ssh -i "%PEM_FILE%" %EC2_USER%@%EC2_IP% "ls -l %EC2_ZIP_FILE%"

echo -------------------------------
echo Downloading zip file to local machine...
echo -------------------------------
scp -i "%PEM_FILE%" %EC2_USER%@%EC2_IP%:%EC2_ZIP_FILE% "%LOCAL_DIR%"

echo -------------------------------
echo Checking if zip exists locally...
echo -------------------------------
if not exist "%LOCAL_DIR%\output.zip" (
    echo ERROR: output.zip not found locally! Exiting.
    pause
    exit /b
)

echo -------------------------------
echo Unzipping locally into project output folder...
echo -------------------------------
powershell -Command "Expand-Archive -Force '%LOCAL_DIR%\output.zip' -DestinationPath '%LOCAL_DIR%\output'"

echo -------------------------------
echo Cleaning up zip files...
echo -------------------------------
ssh -i "%PEM_FILE%" %EC2_USER%@%EC2_IP% "rm %EC2_ZIP_FILE%"
del "%LOCAL_DIR%\output.zip"

echo -------------------------------
echo Done! Output folder is ready in local project directory.
echo -------------------------------
pause
