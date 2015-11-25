Scheduler Backend
======

##Project Description

The frontend application for our scheduler app, connecting via api to the backend application for data storage.

###Setup:

Install node and mongodb, then run:
``` bash
  $ npm install && bower install
  $ mongod
```

###Run Server:

``` bash
  $ gulp #development mode
  $ gulp --production #production mode
```

###Workflow

  1. Pull remote changes
    - Use naming convention feature/<featurename> for creating feature branches, chore/<chorename> for chores
  2. Do development in feature branch
  3. Push the feature branch to github (git push origin feature/<featurename>)
  5. Make a Pull request to merge back into development branch.
