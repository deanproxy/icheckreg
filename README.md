This is my first shot at an iOS product. I'm using my checkreg app to make it native.

Things I have learned so far:

1. To hook up a button, create a method that returns `IBAction` in your controller and then CTRL+CLICK+Drag from that button to the View Controller icon in the storyboard icon bar under the current view (There are usually two icons there including First Responder. IT's the icon on the right.)
2. To hook up form elements (or even table cells), CTRL+CLICK+Drag that element to the header file of the object you want to hook those components up to.  You can access text fields by self.whatever.text (it's an NSString).


