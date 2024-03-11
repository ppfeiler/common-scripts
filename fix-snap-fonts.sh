#!/bin/bash

echo "Clean fonts..."
fc-cache -r && rm ~/.cache/fontconfig/*
