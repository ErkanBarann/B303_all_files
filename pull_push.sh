#!/bin/bash
git fetch upstream
git merge upstream/main
git add .
git commit -m "Last Version"
git push origin main

