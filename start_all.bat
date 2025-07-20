@echo off
start cmd /k "uvicorn backend.main:app --reload"
start cmd /k "flutter run -d chrome" 