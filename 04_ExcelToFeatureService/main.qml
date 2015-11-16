import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import ArcGIS.Runtime 10.26
import ArcGIS.Extras 1.0
import io.thp.pyotherside 1.4

ApplicationWindow {
    id: root
    title: qsTr("Excel to Feature Service")
    width: 640
    height: 480
    visible: true

    property string statusString

    Map {
        id: map
        anchors.fill: parent
        ArcGISTiledMapServiceLayer {
            url: "http://services.arcgisonline.com/arcgis/rest/services/World_Topo_Map/MapServer"
        }

        Envelope {
            id: usExtent
            xMax: -15000000
            yMax: 2000000
            xMin: -7000000
            yMin: 8000000
            spatialReference: SpatialReference {
                wkid: 102100
            }
        }
    }

    Rectangle {
        id: controlRect
        anchors {
            left: parent.left
            top: parent.top
            margins: 10
        }
        width: 180
        height: 50
        color: "lightgrey"
        opacity: .8
        radius: 5
        border {
            width: 1
            color: "darkgrey"
        }

        Button {
            anchors.centerIn: parent
            text: "Select Excel"
            width: 145
            height: 35

            onClicked: {
                visible = false;
                fileDialog.open();
            }
        }

        Rectangle {
            id: busyWindow
            anchors.fill: parent
            color: "transparent"
            visible: false


            Row {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    margins: 10
                }

                spacing: 10

                BusyIndicator {
                    width: 20
                    height: 20
                }

                Text {
                    text: statusString
                }
            }
        }
    }

    FileDialog {
        id: fileDialog
        nameFilters: ["Excel files (*.xls *.xlsx)"]

        onAccepted: {
            busyWindow.visible = true;
            var inputExcel = System.resolvedPath(fileDialog.fileUrl);

            //import the module
            py.importModule('excelToFeatureService', function () {
                statusString = "converting Excel";
                // call our conversion function and pass in the excel spreadsheet
                py.call('excelToFeatureService.convert', [inputExcel, 0, System.temporaryFolder.path + "/tmpCsv.csv"], function(result){
                    // the result is the path to the output CSV. Pass this to the portal item
                    portalItem.fileContentPath = result;
                    portalAddItem.addItem(portalItem);
                });
            });
        }
    }

    // Create the portal item
    PortalItemInfo {
        id: portalItem
        title: "excel 2 service"
        itemType: Enums.PortalItemTypeCSV
        file: "excel 2 service.csv"
        tags: ["csv", "excel"]
    }

    // Add the CSV to the portal
    PortalAddItem {
        id: portalAddItem

        onRequestStatusChanged: {
            if (requestStatus === Enums.PortalRequestStatusCompleted) {
                statusString = "csv added to portal";
                portalAnalyzeParameters.itemId = portalAddItem.itemId;
                // Once the add is complete, analyze the item for publishing
                portalAnalyze.analyze(portalAnalyzeParameters);
            } else if (requestStatus === Enums.PortalRequestStatusInProgress) {
                statusString = "adding to portal";
            }
        }
    }

    // Create params for analyzing the CSV for publishing
    PortalAnalyzeParameters {
        id: portalAnalyzeParameters
        fileType: Enums.PortalFileTypeCSV
    }

    // Create the portal analyze task for publishing the feature service
    PortalAnalyze {
        id: portalAnalyze

        onRequestStatusChanged: {
            if (requestStatus === Enums.PortalRequestStatusCompleted) {
                statusString = "analyzing complete";
                var params = publishParameters;
                params.name = "fs";
                var sms = ArcGISRuntime.createObject("SimpleMarkerSymbol");
                sms.style = Enums.SimpleMarkerSymbolStyleCircle;
                sms.color = "red";
                sms.size = 8;
                params.layerInfo.drawingInfo.renderer.symbol = sms;
                params.layerInfo.capabilities = "Create,Delete,Query,Update,Editing,Sync";
                params.layerInfo.hasAttachments = true;
                portalPublishParams.itemId = portalAddItem.itemId;
                portalPublishParams.fileType = Enums.PortalFileTypeCSV;
                portalPublishParams.publishParameters = params;
                // Once the analyze is complete, publish the item
                portalPublish.publishItem(portalPublishParams);
            } else if (requestStatus === Enums.PortalRequestStatusInProgress) {
                statusString = "analyzing for publishing";
            }
        }
    }

    // Create params for publishing the item
    PortalPublishItemParameters {
        id: portalPublishParams
        fileType: Enums.PortalFileTypeCSV
    }

    // Create the Publish Task
    PortalPublishItem {
        id: portalPublish

        onRequestStatusChanged: {
            if (requestStatus === Enums.PortalRequestStatusCompleted) {
                statusString = "publish complete";
                // Once the publish is complete, consume the new feature service and add to the map
                var fst = ArcGISRuntime.createObject("GeodatabaseFeatureServiceTable");
                fst.url = portalPublish.services[0].serviceUrl + "/0";
                var uc = ArcGISRuntime.createObject("UserCredentials");
                uc.userName = portalDialog.portal.credentials.userName;
                uc.password = portalDialog.portal.credentials.password;
                fst.credentials = uc;
                var fl = ArcGISRuntime.createObject("FeatureLayer");
                fl.featureTable = fst;
                map.addLayer(fl);
                controlRect.visible = false;
            } else if (requestStatus === Enums.PortalRequestStatusErrored) {
                console.log("error", JSON.stringify(requestError.json), requestError.details)
            } else if (requestStatus === Enums.PortalRequestStatusInProgress) {
                statusString = "publishing service";
            }
        }
    }

    // Create dialog for user to sign into portal
    PortalDialog {
        id: portalDialog

        onSignInCompleted: {
            if (portal) {
                portalAddItem.portal = portal;
                portalPublish.portal = portal;
                portalAnalyze.portal = portal;
            }
            map.zoomTo(usExtent);
        }
    }

    Python {
        id: py

        Component.onCompleted: {
            // Add the script directory to python path
            addImportPath("qrc:/");
        }
    }
}
