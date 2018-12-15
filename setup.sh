#!/bin/sh

groupadd -g 1000 b-con
useradd -u 1000 -g 1000 -G sudo b-con

