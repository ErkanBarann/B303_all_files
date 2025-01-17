#!/bin/bash
git fetch upstream
git merge upstream/main
git add .
git commit -m "Last Version 1.3 "
git push origin main

