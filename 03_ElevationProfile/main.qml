import QtQuick 2.3
import QtQuick.Controls 1.2
import io.thp.pyotherside 1.4
import ArcGIS.Runtime 10.26

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Elevation Profile")

    Map {
        id: map
        anchors.fill: parent
        extent: trailExtent

        ArcGISTiledMapServiceLayer {
            url: "http://services.arcgisonline.com/arcgis/rest/services/USA_Topo_Maps/MapServer"
        }

        FeatureLayer {
            featureTable: gdbFt
        }

        GeodatabaseFeatureTable {
            id: gdbFt
            geodatabase: gdb
            featureServiceLayerId: 0

            onQueryFeaturesStatusChanged: {
                if (queryFeaturesStatus === Enums.QueryFeaturesStatusCompleted) {
                    // obtain the first feature in the table through the iterator
                    var iter = queryFeaturesResult.iterator;
                    if (iter.hasNext()) {
                        var feat = iter.first();
                        // pass in the QmlFeature object (derives from QObject) into python
                        py.call('elevationProfile.plot_chart', [feat], function(){
                            console.log("complete");
                        });
                    }
                }
            }
        }

        Geodatabase {
            id: gdb
            path: "C:\\Users\\luca6804\\Desktop\\PyOtherSide\\data\\Trail\\data\\default.geodatabase"
        }

        Envelope {
            id: trailExtent
            xMax: -13012199.57222103
            yMax: 4052509.2508569774
            xMin: -13025202.090808606
            yMin: 4042757.36191629
            spatialReference: map.spatialReference
        }
    }

    Button {
        anchors {
            left: parent.left
            top: parent.top
            margins: 10
        }
        text: qsTr("Get Elevation Profile")
        onClicked: {
            // query for features
            var query = ArcGISRuntime.createObject("Query", {where: "1=1", maxFeatures: 1});
            gdbFt.queryFeatures(query);
        }
    }

    Python {
        id: py

        Component.onCompleted: {
            // Add the qrc to python path
            addImportPath("qrc:/");
            py.importModule('elevationProfile', function () {
                console.log("python module imported");
            });
        }
    }
}
