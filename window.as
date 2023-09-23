
class Window {

    private string _colComplete = Colors::colAuthor;
    private string _colNotComplete = Text::FormatOpenplanetColor(vec3(0.5, 0.5, 0.5));

    private int _mapOffset = 0;
    private int _mapLimit = 50;

    private int _leaderboardOffset = 0;
    private int _leaderboardLimit = 50;

    private bool _refreshing = false;
    private Meta::PluginCoroutine@ _refreshCr = null;

    private bool _isOpen = false;

    void Init() {

    }

    void Update(float dt) {
        if(_refreshCr != null && _refreshCr.IsRunning() == false) {
            _refreshing = false;
            @_refreshCr = null;
        }
    }

    void Show() {
        _isOpen = true;
    }

    void Render() {
        if(!_isOpen) return;
        UI::PushStyleColor(UI::Col::WindowBg, vec4(0, 0, 0, 0.991));
        bool open = false;
        if(UI::Begin("TMRankings", open)) {
            UI::SetNextWindowPos(128, 128);
            TMRank::Model::MapPackType@[] mapPackTypes = TMRank::Repository::GetMapPackTypes();
            UI::BeginTabBar("tb_tmrank", UI::TabBarFlags::Reorderable);
            for(int i = 0; i < mapPackTypes.Length; i++) {
                TMRank::Model::MapPackType@ packType = mapPackTypes[i];
                bool tabItemOpen = UI::BeginTabItem(packType.typeName);
                if(UI::IsItemClicked()) {
                    _mapOffset = 0;
                }
                if(tabItemOpen) {
                    _RenderMapList(packType.typeName);
                    UI::EndTabItem();
                }
            }
            UI::EndTabBar();
            UI::End();
        }

        if(!open) {
            _isOpen = false;
        }

        UI::PopStyleColor();
    }    

    private void _RenderMapList(const string&in type) {
        
        if(UI::BeginTable("table_tmrank_" + type, 2, UI::TableFlags::None)) {
            UI::TableSetupColumn("maps", UI::TableColumnFlags::WidthFixed, 700);
            UI::TableSetupColumn("leaderboard", UI::TableColumnFlags::WidthStretch, 0);
            UI::TableNextRow();
            UI::TableNextColumn();
            if(_DrawMapList(type)) {
                UI::TableNextColumn();
                _DrawLeaderboard(type);
            }
            UI::EndTable();
        }
    }

    private bool _DrawMapList(const string&in type) {

        TMRank::Model::Map@[] maps = TMRank::Repository::GetMapsFromType(type, _mapOffset, _mapLimit);
        int totalMaps = TMRank::Repository::GetMapCountFromType(type);

        if(maps.Length == 0) {
            _RefreshMapPack(type);
            UI::Text("Loading " + type + "...");
            return false;
        }
        
        string headerText = type +" (" + 
            (_mapOffset + 1) + 
            "-" + 
            (Math::Min(_mapOffset+_mapLimit, totalMaps)) + ")"
            + " of " + totalMaps;

        UI::Text(headerText);

        if(UI::BeginTable("table_tmrank_map_list_header", 2)) {
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 550);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 100);

            UI::TableNextRow();
            UI::TableNextColumn();
            if(UI::Button(Icons::ArrowLeft)) {
                if(_mapOffset - _mapLimit >= 0) {
                    _mapOffset -= _mapLimit;
                }
            }
            UI::SameLine();
            if(UI::Button(Icons::ArrowRight)) {
                print(maps.Length);
                if(_mapOffset + _mapLimit < totalMaps) {
                    _mapOffset += _mapLimit;
                }
            }
            UI::TableNextColumn();
            if(UI::Button(Icons::Refresh + "##1")) {
                TMRank::Repository::ClearData();
                Async::Start(TMRank::Service::Reload);
                UI::EndTable();
                return false;
            }
            UI::EndTable();
        }


        UI::Separator();

        if(UI::BeginTable("table_tmrank_personal" + type, 8, UI::TableFlags::ScrollY)) {
            UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthFixed, 200);
            UI::TableSetupColumn("PB", UI::TableColumnFlags::WidthFixed, 100);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 50);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 50);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 50);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 50);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 50);
            UI::TableSetupColumn("Score", UI::TableColumnFlags::WidthStretch, 0);
            
            UI::TableHeadersRow();

            for(uint i = 0; i < maps.Length; i++) {

                TMRank::Model::Map@ map = maps[i];
                TMRank::Model::UserMapStats@ userMapStats = TMRank::Repository::GetMapUserStats(map.uid);

                UI::TableNextRow();
                UI::TableNextColumn();
                if(UI::Button(Icons::Play + "##" + i)) {
                    startnew(Game::PlayMap, @map);
                }
                UI::SameLine();
                UI::Text(ColoredString(map.name));
                if(UI::IsItemHovered()) {
                    UI::BeginTooltip();
                    UI::Text(StripFormatCodes(map.name));
                    auto img = Images::CachedFromURL(map.img);
                    if(img.m_texture != null) {
                        UI::Image(img.m_texture, vec2(256, 256));
                    }
                    UI::EndTooltip();
                }
        
                if(userMapStats != null && userMapStats.pb > 0) {
                    UI::TableNextColumn();
                    UI::Text(Time::Format(userMapStats.pb));
                } else {
                    UI::TableNextColumn();
                }

                array<string> medals = {
                    Colors::colFinish + Icons::Circle,
                    Colors::colBronze + Icons::Circle,
                    Colors::colSilver + Icons::Circle,
                    Colors::colGold + Icons::Circle,
                    Colors::colAuthor + Icons::Circle,
                };

                array<string> pointStrings = {
                    _DoPointString(Colors::colFinish, map.finishScore, userMapStats, 99999999.0f),
                    _DoPointString(Colors::colBronze, map.bronzeScore, userMapStats, map.bronzeTime),
                    _DoPointString(Colors::colSilver, map.silverScore, userMapStats, map.silverTime),
                    _DoPointString(Colors::colGold, map.goldScore, userMapStats, map.goldTime),
                    _DoPointString(Colors::colAuthor, map.authorScore, userMapStats, map.authorTime)
                };

                array<string> medalStrings = {
                    "Finish",
                    "Bronze: " + Time::Format(map.bronzeTime),
                    "Silver: " + Time::Format(map.silverTime),
                    "Gold: " + Time::Format(map.bronzeTime),
                    "AT: " + Time::Format(map.authorTime),
                };

                for(int j = 0; j < pointStrings.Length; j++) {
                    UI::TableNextColumn();
                    UI::Text(medals[j]);
                    if(UI::IsItemHovered()) {
                        UI::BeginTooltip();
                        UI::Text(medalStrings[j]);
                        UI::EndTooltip();
                    }
                    UI::SameLine();
                    UI::Text(pointStrings[j]);
                }

                UI::TableNextColumn();
                if(userMapStats != null && userMapStats.score > 0) {
                    UI::Text(userMapStats.score + "");
                }

            }
            UI::EndTable();
        }
        return true;
    }

    private void _DrawLeaderboard(const string&in type) {

        int totalDrivers = 1000;

        string headerText = type + " Leaderboard (" + 
            (_leaderboardOffset + 1) + 
            "-" + 
            (Math::Min(_leaderboardOffset+_leaderboardLimit, totalDrivers)) + ")"
            + " of " + totalDrivers;

        UI::Text(headerText);

        if(UI::BeginTable("table_tmrank_leaderboard_header", 1)) {
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 200);
            UI::TableNextRow();
            UI::TableNextColumn();
            if(UI::Button(Icons::ArrowLeft + "##1")) {
                if(_leaderboardOffset - _leaderboardLimit >= 0) {
                    _leaderboardOffset -= _leaderboardLimit;
                }
            }
            UI::SameLine();
            if(UI::Button(Icons::ArrowRight + "##2")) {
                if(_leaderboardOffset + _leaderboardLimit < totalDrivers) {
                    _leaderboardOffset += _leaderboardLimit;
                }
            }
            UI::EndTable();
        }

        TMRank::Model::Driver@[] leaderboards = TMRank::Repository::GetLeaderboardUsers(type, _leaderboardOffset, _leaderboardLimit);
        UI::Separator();
        if(UI::BeginTable("table_tmrank_leaderboard" + type, 3, UI::TableFlags::ScrollY)) {
            UI::TableSetupColumn("Rank", UI::TableColumnFlags::WidthFixed, 48);
            UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthFixed, 200);
            UI::TableSetupColumn("Score", UI::TableColumnFlags::WidthFixed, 100);
            UI::TableHeadersRow();
            auto driver = TMRank::Repository::GetLeaderboardUser(type, Internal::NadeoServices::GetAccountID()); 
            if(driver != null) {
                _DoLeaderboardRow(type, driver, true);
            }
            for(int i = 0; i < leaderboards.Length; i++) {
                _DoLeaderboardRow(type, leaderboards[i], leaderboards[i].rank == 3);
            }
            UI::EndTable();
        }
    }

    private void _DoLeaderboardRow(const string &in mapTypeName, TMRank::Model::Driver@ driver, bool seperate = false) {
        int rank = driver.rank;
        string color = Colors::colWhite;
        if(rank == 1) color = Colors::colGold;
        if(rank == 2) color = Colors::colSilver;
        if(rank == 3) color = Colors::colBronze;
        UI::TableNextRow();
        UI::TableNextColumn();        
        UI::Text(color + rank + "");
        if(seperate) UI::Separator();
        UI::TableNextColumn();
        UI::Text(color + driver.name);
        if(seperate) UI::Separator();
        UI::TableNextColumn();
        UI::Text(color + driver.score + "");
        if(seperate) UI::Separator();
    }

    private string _DoPointString(string color, int points, TMRank::Model::UserMapStats@ userMapStats, float pointTime) {
        if(userMapStats != null && userMapStats.pb > 0) {            
            string completeColor = _colNotComplete;
            if(userMapStats.pb <= pointTime) {
                completeColor = _colComplete;
            }
            return completeColor + points;
        } else {
            return _colNotComplete + points;
        }
    }

    private void _RefreshMapPack(const string &in typeName) {
        if(!_refreshing) {
            TMRank::Model::MapPackType@ mapPackType = TMRank::Repository::GetMapPackTypeFromType(typeName);
            @_refreshCr = startnew(TMRank::Service::LoadMapData, mapPackType.typeID);
            _refreshing = true;
        }
    }

}