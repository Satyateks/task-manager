Full-Stack Task Manager

A full-stack Task Manager application built as part of a technical assignment.

The application allows authenticated users to create, assign, update, search, filter, and manage tasks for team members.

Tech Stack
Backend
Node.js
Express.js
MySQL
JWT Authentication
Refresh Tokens
bcrypt
REST APIs
Input validation
Proper HTTP status codes and error handling
Frontend
Flutter
Dart
BLoC / Cubit
Dio
SharedPreferences
Material 3 UI
Features
Authentication
User signup
User login
JWT-based authentication
Access token and refresh token implementation
Persistent login
Automatic access token refresh
Logout
Password hashing using bcrypt
Task Management
Create task
View task list
View task details
Edit task
Delete task
Update task status
Assign task to team member
Due date
Search tasks by title
Filter tasks by status
Team Members
View team members
Display name and email
Assign tasks to team members
UI/UX
Clean Material 3 interface
Form validation
Loading states
Empty states
Error states
Retry functionality
Pull-to-refresh
Delete confirmation
Responsive layout
Project Structure
task-manager/
│
├── backend/
│   ├── src/
│   │   ├── config/
│   │   ├── controllers/
│   │   ├── middleware/
│   │   ├── routes/
│   │   ├── utils/
│   │   └── app.js
│   │
│   ├── .env
│   ├── package.json
│   └── README.md
│
├── flutter_app/
│   ├── lib/
│   │   ├── core/
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   ├── tasks/
│   │   │   └── team/
│   │   └── main.dart
│   │
│   ├── pubspec.yaml
│   └── README.md
│
└── README.md

Architecture
Backend

The backend follows a layered structure:

Routes
   ↓
Controllers
   ↓
Database


Authentication is handled using JWT middleware.

Refresh tokens are stored securely in the database as hashes rather than storing plain refresh tokens.

Flutter

The Flutter application follows a feature-based architecture:

UI
 ↓
BLoC / Cubit
 ↓
Repository
 ↓
API Client
 ↓
REST API


BLoC/Cubit was selected because it provides clear separation between UI and business logic, predictable state transitions, and makes the application easier to test and maintain.

Authentication Flow
Login / Signup
      ↓
Backend validates credentials
      ↓
Password verified using bcrypt
      ↓
Access Token + Refresh Token
      ↓
Flutter stores tokens locally
      ↓
Authenticated user
      ↓
Task List


When the access token expires:

API Request
    ↓
401 Unauthorized
    ↓
Refresh Token
    ↓
New Access Token
    ↓
Retry Original Request

API Endpoints
Authentication
Method	Endpoint	Description
POST	/api/auth/signup	Register a new user
POST	/api/auth/login	Login
POST	/api/auth/refresh	Refresh access token
POST	/api/auth/logout	Logout
GET	/api/auth/me	Get current user
Tasks
Method	Endpoint	Description
POST	/api/tasks	Create task
GET	/api/tasks	Get tasks
GET	/api/tasks/:id	Get task details
PUT	/api/tasks/:id	Update task
DELETE	/api/tasks/:id	Delete task
Team Members
Method	Endpoint	Description
GET	/api/users	Get team members
Database

The application uses MySQL.

Main tables:

users
refresh_tokens
tasks

Task relationships
users
  │
  ├── created_by ──────> tasks
  │
  └── assignee_id ─────> tasks


The assignee_id relationship uses ON DELETE SET NULL, so deleting a team member does not automatically delete their assigned tasks.

Environment Variables

Create a .env file inside the backend directory.

PORT=5000

DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=task_manager

JWT_ACCESS_SECRET=your_access_secret
JWT_REFRESH_SECRET=your_refresh_secret

ACCESS_TOKEN_EXPIRES_IN=15m
REFRESH_TOKEN_EXPIRES_IN=7d


Do not commit .env to GitHub.

Backend Setup

Go to the backend directory:

cd backend


Install dependencies:

npm install


Create the MySQL database:

CREATE DATABASE task_manager;


Create the required tables using the SQL scripts provided in the backend/database directory.

Configure .env.

Start the development server:

npm run dev


Or:

npm start


The API will run at:

http://localhost:5000

Flutter Setup

Go to the Flutter application:

cd flutter_app


Install dependencies:

flutter pub get


Run the application:

flutter run

Android Emulator API URL

For Android Emulator, use:

http://10.0.2.2:5000/api


For a physical Android device, replace 10.0.2.2 with the local IP address of the machine running the backend.

Application Flow
App Launch
    ↓
Check Saved Session
    ↓
Authenticated?
   / \
 Yes  No
  ↓    ↓
Tasks Login
       ↓
   Existing User?
      /     \
    Yes      No
     ↓        ↓
   Login    Signup
     ↓        ↓
     └──→ Task List


From the main application:

Task List
 ├── Search
 ├── Filter
 ├── Add Task
 └── Task Details
       ├── Edit
       ├── Update Status
       └── Delete

Team Members
 └── View users

Validation & Error Handling

The application handles:

Required field validation
Email validation
Password validation
Password confirmation
Invalid task status
Invalid assignee
Unauthorized requests
Expired access tokens
Invalid refresh tokens
Network errors
Empty task lists
Empty team member lists
Server errors
Security Considerations
Passwords are never stored as plain text.
Passwords are hashed using bcrypt.
Protected endpoints require JWT authentication.
Refresh tokens are stored as hashes in the database.
JWT secrets are stored in environment variables.
.env is excluded from version control.
Users can only access tasks they created or are assigned to.
Screenshots

Add screenshots here before submission:

Login
[Add Login Screenshot]

Task List
[Add Task List Screenshot]

Create / Edit Task
[Add Create/Edit Task Screenshot]

Team Members
[Add Team Members Screenshot]

Task Details
[Add Task Details Screenshot]

Testing

Backend API can be tested using Postman.

Recommended test flow:

1. Signup
2. Login
3. Copy access token
4. Get current user
5. Get team members
6. Create task
7. Get tasks
8. Get task details
9. Update task
10. Delete task
11. Refresh token
12. Logout

Optional Improvements

Possible future improvements:

Pagination
Sorting
Offline support
API tests
Flutter widget tests
Database migrations
Seed data
Swagger/OpenAPI documentation
Role-based permissions
Time Tracking

Approximate development time:

Start: [DD/MM/YYYY HH:MM]
Finish: [DD/MM/YYYY HH:MM]

Total: Approximately 4–6 hours

Submission

The GitHub repository contains:

Backend source code
Flutter application
Database scripts
README documentation
Setup instructions
Architecture/design decisions
API documentation
Screenshots
Author

Developed as part of the Full-Stack Task Manager technical assignment.
