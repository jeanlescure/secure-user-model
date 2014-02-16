#Secure User Model
###A simple yet robustly secure user implementation for Ruby on Rials which includes user creation and authentication methods.

This is a copy-paste code base which I'm currently using in several projects to test out a new model for user management which is extremely robust and secure.

I do intend to make a gem out of this project eventually. If you have any use for it as is or if you're interested in moving this project along in order to make it a gem, by all means contact me.

## Installation

1. Bundle and Migrate:
  * `bundle install`
  * `rake db:migrate`
  
## Usage

  1. start the server: `rails s -p 8080`
  2. navigate to the server url: `http://localhost:8080`
  
## TODOs

  * Add functionality to edit user info.
  * Add an view with form for editing user info.
  * Actually implement localization (the code base and locales for english and spanish is there, it just needs to be switched depending on each user's preferences).