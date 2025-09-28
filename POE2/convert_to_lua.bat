@echo off
for %%f in (*.txt) do (
    ren "%%f" "%%~nf.lua"
)
pause