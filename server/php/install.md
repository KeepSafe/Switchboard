Setup new Heroku app

login:
philipp$ heroku login
Enter your Heroku credentials.
Email: xxx@getkeepsafe.com
Password (typing will be hidden): 
Authentication successful.

Create app:
heroku apps:create switchboard
Creating switchboard... done, stack is cedar
http://switchboard.herokuapp.com/ | git@heroku.com:switchboard.git

git clone git@heroku.com:switchboard.git .

Use a starter kit to run PHP on Heroku
https://github.com/winglian/Heroku-PHP