@echo off
REM ==============================
REM Fresh Git setup & push script
REM ==============================

REM Set project folder path
set PROJECT_PATH=C:\Users\avnis\My_Projects\Higgs-Boson-Classifier

REM Set GitHub repository URL
set REPO_URL=https://github.com/Avnishprojects/higgs.git

REM Go to project folder
cd /d "%PROJECT_PATH%"

REM Delete old Git history if exists
if exist .git (
    echo Deleting old Git history...
    rmdir /s /q .git
)

REM Initialize fresh Git
echo Initializing fresh Git...
git init
git branch -M main

REM Create .gitignore if it does not exist
if not exist .gitignore (
    echo Creating .gitignore...
    echo .ipynb_checkpoints/ > .gitignore
)

REM Add all files
echo Adding files to Git...
git add .

REM Commit
echo Committing files...
git commit -m "Initial commit - fresh Git"

REM Add remote
git remote add origin %REPO_URL%

REM Push to GitHub
echo Pushing to GitHub...
git push -u origin main --force

echo ==============================
echo Fresh Git setup ^& push completed!
pause
