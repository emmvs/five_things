# Five Things App

## Overview

The "Five Things" app is designed to help users appreciate the smaller joys in life. In addition to listing down five things that make them happy, users can enjoy a random poem each time they visit the dashboard.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites & System Dependencies

Ensure that you have the following installed on your local machine:

* [Ruby](https://www.ruby-lang.org/en/documentation/installation/) - 3.1.2
* [Rails](https://guides.rubyonrails.org/v5.0/getting_started.html) - 7.0.6
* PostgreSQL

### Installation

1. Clone the repository to your local machine
   
`git clone https://github.com/yourusername/five-things.git`

2. Navigate to the project directory

`cd five-things`

3. Install necessary gems

`bundle install`

### Database Creation

1. Create the database

`rails db:create`

3. Migrate the database

`rails db:migrate`

### Database Initialization

1. Seed the database

`rails db:seed`

### Running Tests

1. To run the complete test suite, execute

`rspec`

### Services

- Poetry Service: Fetches a random poem to display on the page.

### Deployment Instructions

1. Precompile assets

`rails assets:precompile`

3. Push to your deployment platform

## Contributing

If you would like to contribute, please fork the repository and use a feature branch. Pull requests are warmly welcome.

## Contact

- Repository: [Five Things App](https://github.com/yourusername/five-things-app)
- Developer: Emma Rünzel - emma@ruenzel.de

**Enjoy the Five Things App, and remember to appreciate the litte things!**
