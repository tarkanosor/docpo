@echo off
for %%f in (*.lua) do (
    ren "%%f" "%%~nf.txt"
)
pause