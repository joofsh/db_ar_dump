# Db_Ar_Dump

A script that can be used to convert your current database into an active_record seed data file.

## Installation

The easiest way to use DB_Ar_Dump is to pull the script alone into your rails application's scripts/ directory:

    cd script
    curl -O https://raw.github.com/joofsh/db_ar_dump/master/db_ar_dump.rb

## Usage

Run the script within your rails application with the following command:

    rails runner script/db_ar_dump.rb
