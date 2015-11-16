import QtQuick 2.3
import QtQuick.Controls 1.3
import io.thp.pyotherside 1.4

ApplicationWindow {
    width: 400
    height: width
    visible: true

    Rectangle {
        anchors.fill: parent
        color: "red"

        Column {
            anchors.centerIn: parent
            spacing: 5

            TextField {
                id: name
                placeholderText: "ex: Luke"
                width: 150
            }

            Button {
                text: "Print Name"
                width: 150
                onClicked: {
                    //import the module
                    py.importModule('helloworld', function () {
                        // call our function, and pass in a text value
                        py.call('helloworld.get_name', [name.text], function(result){
                            // the result is a string returned from python.
                            textLabel.text = result;
                        });
                    });
                }
            }

            Text {
                id: textLabel
                font.pixelSize: 20
            }
        }

        Python {
            id: py

            Component.onCompleted: {
                // Add the qrc to python path
                addImportPath("qrc:/");
            }
        }
    }
}
