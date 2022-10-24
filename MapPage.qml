import QtQuick 2.11
import QtQuick.Window 2.11
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.12
import QtLocation 5.8
import QtPositioning 5.8
import "maplogic.js" as MapLogic

Item {
    id: top_surface
    clip: true

    function mp(x) {
        return Screen.pixelDensity * x;
    }

    Connections {
        target: sessionData

        onClearMap: {
            map.clearMapItems();
            MapLogic.tracks = [];
        }

        onSetTrack: {
            var jTrack = JSON.parse(element);

            var track = Qt.createQmlObject('import QtLocation 5.6; MapPolyline {property string memColor}', map);
            track.line.width = mp(2);
            track.memColor = jTrack.color;
            track.line.color = MapLogic.tracks_visible ? jTrack.color : "#00000000";
            MapLogic.tracks.push(track);
            map.addMapItem(MapLogic.tracks[MapLogic.tracks.length - 1]);

            for (var i = 0; i < jTrack.geoData.length; i++) {
                MapLogic.tracks[MapLogic.tracks.length - 1].addCoordinate(QtPositioning.coordinate(jTrack.geoData[i].lat, jTrack.geoData[i].long));
            }
        }

        onSetTracksVisibility: {
            MapLogic.tracks_visible = is_visible;
            for (var i = 0; i < MapLogic.tracks.length; i++) {
                MapLogic.tracks[i].line.color = MapLogic.tracks_visible ? MapLogic.tracks[i].memColor : "#00000000";
            }
        }
    }

    Plugin {
        id: mapPlugin
        name: "esri"
    }

    Map {
        id: map
        anchors.fill: parent
        plugin: mapPlugin
        center: QtPositioning.coordinate(55.7, 37.6)
        maximumZoomLevel: 17
        zoomLevel: 14
        //tilt: zoomLevel <= 17 && zoomLevel >= 21 ? 0 : (4 - (21 - zoomLevel)) / 4 * 70
        copyrightsVisible: false
        activeMapType: supportedMapTypes[1];
    }

    MapSettingsWidget {
        anchors.fill: parent
    }
}
