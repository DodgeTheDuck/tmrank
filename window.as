
class Window {

    private string colFinish = Text::FormatOpenplanetColor(vec3(0.5, 0.5, 0.5));
    private string colBronze = Text::FormatOpenplanetColor(vec3(0.80, 0.49, 0.19));
    private string colSilver = Text::FormatOpenplanetColor(vec3(0.75, 0.75, 0.75));
    private string colGold = Text::FormatOpenplanetColor(vec3(1.0, 0.84, 0.0));
    private string colAuthor = Text::FormatOpenplanetColor(vec3(0.2, 0.80, 0.1));

    private string colComplete = colAuthor;
    private string colNotComplete = Text::FormatOpenplanetColor(vec3(0.5, 0.5, 0.5));

    void Init() {

    }

    void Update(float dt) {

    }

    void Render() {
        UI::Begin("TMRankings", UI::WindowFlags::NoCollapse);
            UI::BeginTabBar("tb_tmrank");
                if(UI::BeginTabItem("RPG")) {
                    _RenderMapList("RPG");
                    UI::EndTabItem();
                }
                if(UI::BeginTabItem("Trial")) {
                    _RenderMapList("Trial");
                    UI::EndTabItem();
                }
                if(UI::BeginTabItem("SOTD")) {
                    _RenderMapList("SOTD");
                    UI::EndTabItem();
                }
            UI::EndTabBar();
        UI::End();
    }

    private void _RenderMapList(string type) {
        UI::BeginTable("table_tmrank_" + type, 9, UI::TableFlags::ScrollY);
        UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthFixed, 256);
        UI::TableSetupColumn("PB", UI::TableColumnFlags::WidthFixed, 100);
        UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 30);
        UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 30);
        UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 30);
        UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 30);
        UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 30);
        UI::TableSetupColumn("Points", UI::TableColumnFlags::WidthFixed, 64);
        UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 64);
        array<TMRank::MapData@> maps = TMRank::Service::GetMapsFromStyle(type);

        UI::TableHeadersRow();

        for(uint i = 0; i < maps.Length; i++) {

            TMRank::MapData@ map = maps[i];
            Nadeo::MapInfo@ mapInfo = Nadeo::Repository::GetMapFromUid(map.uid);

            if(mapInfo == null) continue;

            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text(ColoredString(mapInfo.name));

            if(mapInfo.personalRecord != 0) {
                UI::TableNextColumn();
                UI::Text(Time::Format(mapInfo.personalRecord));
            } else {
                UI::TableNextColumn();
            }

            int points = 0;

            array<string> pointStrings = {
                _DoPointString(colFinish, map.ptFinish, mapInfo.personalRecord, 999999999, points, points),
                _DoPointString(colBronze, map.ptBronze, mapInfo.personalRecord, mapInfo.bronzeTime, points, points),
                _DoPointString(colSilver, map.ptSilver, mapInfo.personalRecord, mapInfo.silverTime, points, points),
                _DoPointString(colGold, map.ptGold, mapInfo.personalRecord, mapInfo.goldTime, points, points),
                _DoPointString(colAuthor, map.ptAuthor, mapInfo.personalRecord, mapInfo.authorTime, points, points)
            };

            array<float> times = {
                0,
                mapInfo.bronzeTime,
                mapInfo.silverTime,
                mapInfo.goldTime,
                mapInfo.authorTime
            };

            for(int j = 0; j < pointStrings.Length; j++) {
                UI::TableNextColumn();
                UI::Text(pointStrings[j]);
                if(times[j] > 0 && UI::IsItemHovered()) {
                    UI::BeginTooltip();
                    UI::Text(Time::Format(times[j], false));
                    UI::EndTooltip();
                }
            }
            UI::TableNextColumn();
            if(points > 0) {
                UI::Text(Text::Format("%i", points));
            }

            UI::TableNextColumn();
            if(UI::Button(Icons::Play + "##" + i)) {
                startnew(Game::PlayMap, @mapInfo);
            }

        }

        UI::EndTable();
    }

    private string _DoPointString(string color, int points, float myTime, float pointTime, int&in currentPoints, int&out pointAccumulator) {
        if(myTime != 0) {            
            string completeColor = colNotComplete;
            if(myTime <= pointTime) {
                pointAccumulator = currentPoints + points;
                completeColor = colComplete;
            } else {
                pointAccumulator = currentPoints;
            }
            return color + "[" + completeColor + points + color + "]";
        } else {
            pointAccumulator = currentPoints;
            return color + "[" + colNotComplete + points + color + "]";
        }
    }

}