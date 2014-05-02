# Manchester City FC BBC Sport News Parser

A program for fetching BBC Sport news RSS feed and emailing news stories about Manchester City FC

## Prerequisites

I use the [Postmark API](https://postmarkapp.com) to send the emails so you will need a postmark API key to make the program work

## Installation

````
$ bundle
````

## Usage

First put your Postmark API key in a file named '.postmark_api_key' then run:

````
$ ruby city.rb me@somewhere.com
````

## To Do

* Move postmark api and database file to the users home directory.

## Author

* Morwenna Jessop (mo@supershinyrobot.com)

## License

See LICENSE.md
