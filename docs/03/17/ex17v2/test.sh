#!/bin/bash
set -e

make ex17
./ex17 db.dat c
./ex17 db.dat s 1 zed zed@zedshaw.com
./ex17 db.dat s 2 frank frank@zedshaw.com
./ex17 db.dat s 3 joe joe@zedshaw.com
./ex17 db.dat l
./ex17 db.dat d 2
./ex17 db.dat l
./ex17 db.dat g 3

rm db.dat ex17
