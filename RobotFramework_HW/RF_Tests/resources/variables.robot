*** Settings ***
Documentation    Robot resources and variables for all tests

Library    DatabaseLibrary

Resource    test_data.robot

*** Variables ***
${DBHost}         EPPLWARW01DC\\SQLEXPRESS
${DBName}         AdventureWorks2012
${DBPass}         test_user
${DBPort}         1433
${DBUser}         test_user



