#!/bin/bash
cd "${BASH_SOURCE%/*}/"
cd app
pod install
cd ../server
npm install
npm start