Very limited chat application

This app uses Firestore as a backend and local storage


To get things up and running you first need a new project at Firebase

Create a new project and follow the directions

When the project is created, click on the iOS icon to register the app. Fill in the bundle id and download the config file.

Add the config to the Assets folder

Then run pod install, and build and run the app. The app should communicate with firebase and you should get the goahead.

Then, create a new database in locked mode and wait for firebase to finish.

Click on Authentication and select sign-in method, choose email and just enable it (no email link)

One more step. Open database and select rules. Add the following:

// Allow read/write access on all documents to any user signed in to the application
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth.uid != null;
    }
  }
}

Give it a few minutes to update and if everything goes well the app should be testable.


Time to test. Register a user in the app, it should be created in the firebase users table.

Log in and that should be it. It could be useful to have at least two users registered to test the chat.


If everything works, and users are logged in, they should show in the Contacts tab, and clicking new will create a conversation


