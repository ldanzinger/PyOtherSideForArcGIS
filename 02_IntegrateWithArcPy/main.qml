import QtQuick 2.3
import QtQuick.Controls 1.2
import io.thp.pyotherside 1.4
import ArcGIS.Runtime 10.26

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Integrate with ArcPy")

    Map {
        id: map
        anchors.fill: parent
        extent: usExtent
        ArcGISTiledMapServiceLayer {
            url: "http://services.arcgisonline.com/arcgis/rest/services/ESRI_Imagery_World_2D/MapServer"
        }

        Envelope {
            id: usExtent
            xMax: -71.54296494635823
            yMax: 63.01757682534699
            xMin: -127.79296698305882
            yMin: 20.83007529782154
            spatialReference: map.spatialReference
        }

        onMouseClicked: {
            /* call our function, and pass in the xy values. This will run through an
               arcpy search cursor, access arcpy geometry objects, run geometry operations,
               and return the NAME of the state of which the mouse was clicked */
            py.call('isWithin.getState', [mouse.mapX, mouse.mapY], function(result){
                // the result is a string returned from python.
               stateText.text = "Clicked in: %1".arg(result);
            });
        }
    }

    Text {
        id: stateText
        anchors {
            left: parent.left
            top: parent.top
            margins: 10
        }

        color: "white"
        font.pointSize: 20
    }

    Python {
        id: py

        Component.onCompleted: {
            // Add the qrc to python path
            addImportPath("qrc:/");
            stateText.text = "initializing arcpy";
            py.importModule('isWithin', function () {
                stateText.text = "arcpy initialized";
            });
        }
    }
}
