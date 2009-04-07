@echo off

if "" == "%1%" goto NO_SCENARIO
set SCENARIO=%1
shift
:NO_SCENARIO

jruby -S rake features TEST_SCENARIO=%SCENARIO%
