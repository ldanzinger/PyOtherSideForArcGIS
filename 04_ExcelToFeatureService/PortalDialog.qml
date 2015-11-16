import QtQuick 2.0
import ArcGIS.Runtime 10.26
import ArcGIS.Runtime.Toolkit.Dialogs 1.0

UserCredentialsDialog {
    id: portalSignInDialog

    property string errorString
    property bool signedIn: false
    property string portalUrl: "https://arcgis.com"
    property Portal portal
    signal signInCompleted
    signal signInErrored(var error)
    visible: false

    onAccepted: {
        busy = true;
        portal = ArcGISRuntime.createObject("Portal", {url: portalUrl});
        portal.signInComplete.connect(function () {
            signedIn = true;
            signInCompleted();
            busy = false;
            visible = false;
        });
        portal.signInError.connect(function (error) {
            visible = false;
            signInErrored(error);
            errorString = "Error during sign in.\n" + error.code + ": " + error.message + "\n" + error.details;
            busy = false;
            console.log(errorString);
        });
        userCredentials.userName = username;
        userCredentials.password = password;
        portal.credentials = userCredentials;
        portal.signIn();
    }

    Component.onCompleted: {
        portalSignInDialog.visible = true;
        portalSignInDialog.contentItem.height = Math.min(portalSignInDialog.contentItem.screenHeight, portalSignInDialog.contentItem.scaledHeight)
        portalSignInDialog.contentItem.width = Math.min(portalSignInDialog.contentItem.screenWidth, portalSignInDialog.contentItem.scaledWidth)
        if(Qt.platform.os !== "ios" && Qt.platform.os != "android") {
            portalSignInDialog.height = Math.min(portalSignInDialog.contentItem.screenHeight, portalSignInDialog.contentItem.scaledHeight)
            portalSignInDialog.width = Math.min(portalSignInDialog.contentItem.screenWidth, portalSignInDialog.contentItem.scaledWidth)
        }
    }

    UserCredentials {
        id: userCredentials
    }
}
