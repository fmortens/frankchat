== Hi ==

so this is a very limited chat application just to show how swift and Firestore can be used.

A lot of improvements to be done, but for now it only has basic functionality. I would want to improve stuff like this later:

* Better error handling
* Better structuring of code
* Better performance
* Notifications and sound
* Search for contacts rather than show everything

== Setup ==
To get things up and running you first need a new project at Firebase, so go ahead and set one up. Just follow the instructions.

When the project has been created, click on the iOS icon to register the app. Just fill in the bundle id and download the config file. Add that to the Assets folder.

Then run "pod install" I am assuming pod is installed, btw. Then build and run the app. The app should communicate with firebase and you should get the goahead on the firebase console (in the browser).

Now, before you do anything, create a new database in "locked mode" and wait for firebase to finish.

Click on Authentication and select sign-in method, choose "email" and just enable it (no email link).

One more step: Open database and select "rules". Add the following (replace with):

// Allow read/write access on all documents to any user signed in to the application
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth.uid != null;
    }
  }
}

Give it a few minutes to update and if everything goes well the app should be testable.

== Time to test ==
Register a user in the app, it should be created in the firebase users table.

Log in and that should be it. It could be useful to have at least two users registered to test the chat.

If everything works, and users are logged in, they should show in the Contacts tab, and clicking new will create a conversation


