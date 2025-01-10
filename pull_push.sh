#!/bin/bash
git fetch upstream
git merge upstream/main
git add .
git commit -m "Last Version 1.0 "
git push origin main

