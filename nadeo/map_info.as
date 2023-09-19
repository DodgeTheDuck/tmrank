namespace Nadeo {

    class MapInfo {
        string uid;
        string mapId;
        string name;
        string author;
        uint authorTime;
        uint goldTime;
        uint silverTime;
        uint bronzeTime;
        int nbLaps;
        bool valid;
        int uploadTimestamp;
        int updateTimestamp;
        bool public;
        bool playable;
        string mapStyle;
        string mapType;
        string downloadUrl;

        // custom data
        float worldRecordTime;
        string worldRecordUser;
        float personalRecord;

        MapInfo(const Json::Value &in json)
        {
            try {
                uid = json["uid"];
                mapId = json["mapId"];
                name = json["name"];
                author = json["author"];
                authorTime = json["authorTime"];
                goldTime = json["goldTime"];
                silverTime = json["silverTime"];
                bronzeTime = json["bronzeTime"];
                downloadUrl = json["downloadUrl"];
                nbLaps = json["nbLaps"];
                valid = json["valid"];
                uploadTimestamp = json["uploadTimestamp"];
                updateTimestamp = json["updateTimestamp"];
                public = json["public"];
                playable = json["playable"];
                mapStyle = json["mapStyle"];
                mapType = json["mapType"];
            } catch {
                throw("Unable to parse MapInfo json");
            }
        }
    }

}