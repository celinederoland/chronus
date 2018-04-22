#!/usr/bin/env bash

export BASE_DIR=$(pwd)

mkdir workbox
cd workbox
mkdir code
mkdir cache
mkdir docker
mkdir resources

cd cache
mkdir .composer
mkdir .m2
cd ..

cd docker
git clone git@bitbucket.org:celinederoland/chronus.git