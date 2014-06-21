@echo off

if not exist r:\ (net use r: \\storage\nbu > nul)
title RvRoot! RED power!
color 4f
pushd c:\
echo You've got the power. Use tcmd.
