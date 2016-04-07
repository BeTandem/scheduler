#Setup Database beforeEach Calls

Database = require './utils/database_setup'
database = new Database()
database.clearDatabase()
database.addUserTask(database.USER_WITH_AUTH)
database.addMeetingTask(database.MEETING_60)
database.runTasks()