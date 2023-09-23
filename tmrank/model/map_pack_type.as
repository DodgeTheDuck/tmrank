
namespace TMRank {
    namespace Model {

        class MapPackType {

            int typeID;
            string typeName;

            MapPackType(const Json::Value &in json) {
                try {
                    typeID = json["type_id"];
                    typeName = json["type_name"];
                } catch {
                    throw("Unable to parse MapPackType json");
                }
            }

        }
    }
}