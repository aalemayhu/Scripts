#!/bin/bash

pr=$1
branch_name="pullrequest-$pr"
git fetch origin pull/$pr/head:$branch_name
git checkout $branch_name
