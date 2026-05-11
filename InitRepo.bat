@echo off
git init
git add .
git commit -m "Initial commit"
set /p "repo=Repository addres: "
git remote add origin %repo%
git branch -M main
git push -u origin main
echo Done
pause
exit