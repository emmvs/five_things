# Five Things App

## Overview

The 5 Things App is designed to help users appreciate the smaller joys in life by listing down five things that make them happy every day.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine

### Prerequisites & System Dependencies

Ensure that you have the following installed on your local machine:

* [Ruby](https://www.ruby-lang.org/en/documentation/installation/) - 3.4.4
* [Rails](https://guides.rubyonrails.org/v5.0/getting_started.html) - 8.0.3
* PostgreSQL
* (Optional) [Ngrok](https://ngrok.com/) - For mobile testing

### PWA Features

The app is a Progressive Web App (PWA) with:
- ✅ **Offline Support** - Works without internet connection
- ✅ **Install to Home Screen** - Install on iOS, Android, and Desktop
- ✅ **Network Status Detection** - Shows when you're offline/online
- ✅ **Auto-Updates** - Prompts when new version is available
- ✅ **Responsive Design** - Optimized for mobile and desktop

See [docs/PWA_OFFLINE.md](docs/PWA_OFFLINE.md) for detailed documentation.

### Testing on Mobile Devices

**Option 1: Using ngrok (with Procfile.dev)**
```bash
bin/dev  # Starts Rails server + ngrok automatically
```

**Option 2: Manual ngrok + debugging**
```bash
# Terminal 1
rails s

# Terminal 2
ngrok http 3000
```
Then visit the ngrok HTTPS URL on your mobile device.

Note: PWA features require HTTPS, which ngrok provides automatically.

### Installation

1. Clone the repository to your local machine
   
`git clone https://github.com/yourusername/five-things.git`

2. Navigate to the project directory

`cd five-things`

3. Install necessary gems

`bundle install`

4. Install PostgreSQL

```
brew install postgresql
brew services start postgresql
```

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

```bash
rspec # run all tests
rspec spec/requests/users_spec.rb # run a specific test
```

### Services

- Poetry Service: Fetches a random poem to display on the page.

### Deployment Instructions

1. Precompile assets

`rails assets:precompile`

3. Push to your deployment platform

## Contributing

If you would like to contribute, please fork the repository and use a feature branch. Pull requests are warmly welcome.

## Contact

- Repository: [Five Things App](https://github.com/emmvs/five_things)
- Developer: Emma Rünzel - emma@ruenzel.de

**Enjoy Five Things, and remember to appreciate the litte things!**

Made with ♥️ by emmvs
