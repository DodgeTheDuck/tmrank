
class Window {

    private string _colAchieved = Colors::MEDAL_AUTHOR;
    private string _colNotAchieved = Text::FormatOpenplanetColor(vec3(0.5, 0.5, 0.5));
    private int _mapOffset = 0;
    private int _mapLimit = 20;
    private int _leaderboardOffset = 0;
    private int _leaderboardLimit = 40;
    private bool _refreshing = false;
    private Meta::PluginCoroutine@ _refreshCr = null;
    private bool _isOpen = false;

    // UI data cache
    private string _tabTypeCache = "";
    private TMRank::Model::Map@[] _mapCache = {};
    private TMRank::Model::Driver@[] _leaderboardCache = {};

    private array<string> _medalIcons = {
        Colors::MAP_FINISH + Icons::Circle,
        Colors::MEDAL_BRONZE + Icons::Circle,
        Colors::MEDAL_SILVER + Icons::Circle,
        Colors::MEDAL_GOLD + Icons::Circle,
        Colors::MEDAL_AUTHOR + Icons::Circle,
    };

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
        if(UI::Begin("TMRank", open)) {
            
            TMRank::Model::MapPackType@[] mapPackTypes = TMRank::Repository::GetMapPackTypes();
            
            UI::BeginTabBar("tb_tmrank", UI::TabBarFlags::Reorderable);
            // Draw each map pack tab
            for(int i = 0; i < mapPackTypes.Length; i++) {
                TMRank::Model::MapPackType@ packType = mapPackTypes[i];

                // Handle tab logic
                bool tabItemOpen = UI::BeginTabItem(packType.typeName);
                if(UI::IsItemClicked()) {
                    _TabItemClicked(packType.typeName);
                } 
                if(tabItemOpen) {
                    _RenderTab(packType.typeName);
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

    private void _RenderTab(const string&in type) {
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
        _tabTypeCache = type;
    }

    private bool _DrawMapList(const string&in type) {

        if(_mapCache.Length == 0 || _tabTypeCache != type) {
            _mapCache = TMRank::Repository::GetMapsFromType(type, _mapOffset, _mapLimit);
        }

        int totalMaps = TMRank::Repository::GetMapCountFromType(type);

        if(_mapCache.Length == 0) {
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
                _ClearMapCache();
            }
            UI::SameLine();
            if(UI::Button(Icons::ArrowRight)) {
                print(_mapCache.Length);
                if(_mapOffset + _mapLimit < totalMaps) {
                    _mapOffset += _mapLimit;
                }
                _ClearMapCache();
            }
            UI::TableNextColumn();
            if(UI::Button(Icons::Refresh + "##1")) {
                TMRank::Repository::ClearData();
                Async::Start(TMRank::Service::Reload);
                _ClearLeaderboardCache();
                _ClearMapCache();
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

            for(uint i = 0; i < _mapCache.Length; i++) {

                TMRank::Model::Map@ map = _mapCache[i];
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

                array<string> pointStrings = {
                    _DoPointString(Colors::MAP_FINISH, map.finishScore, userMapStats, 9999999),
                    _DoPointString(Colors::MEDAL_BRONZE, map.bronzeScore, userMapStats, map.bronzeTime),
                    _DoPointString(Colors::MEDAL_SILVER, map.silverScore, userMapStats, map.silverTime),
                    _DoPointString(Colors::MEDAL_GOLD, map.goldScore, userMapStats, map.goldTime),
                    _DoPointString(Colors::MEDAL_AUTHOR, map.authorScore, userMapStats, map.authorTime)
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
                    UI::Text(_medalIcons[j]);
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

        int totalDrivers = TMRank::Service::LEADERBOARD_MAX;

        if(_leaderboardCache.Length == 0) {
            _leaderboardCache = TMRank::Repository::GetLeaderboardUsers(type, _leaderboardOffset, _leaderboardLimit);
        }

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
                _ClearLeaderboardCache();
            }
            UI::SameLine();
            if(UI::Button(Icons::ArrowRight + "##2")) {
                if(_leaderboardOffset + _leaderboardLimit < totalDrivers) {
                    _leaderboardOffset += _leaderboardLimit;
                }
                _ClearLeaderboardCache();
            }
            UI::EndTable();
        }

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
            for(int i = 0; i < _leaderboardCache.Length; i++) {
                _DoLeaderboardRow(type, _leaderboardCache[i], _leaderboardCache[i].rank == 3);
            }
            UI::EndTable();
        }
    }

    private void _DoLeaderboardRow(const string &in mapTypeName, TMRank::Model::Driver@ driver, bool seperate = false) {
        int rank = driver.rank;
        string color = Colors::WHITE;
        if(rank == 1) color = Colors::MEDAL_GOLD;
        if(rank == 2) color = Colors::MEDAL_SILVER;
        if(rank == 3) color = Colors::MEDAL_BRONZE;
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

    private string _DoPointString(string color, int points, TMRank::Model::UserMapStats@ userMapStats, uint pointTime) {
        if(userMapStats != null && userMapStats.pb > 0) {            
            string completeColor = _colNotAchieved;
            if(userMapStats.pb <= pointTime) {
                completeColor = _colAchieved;
            }
            return completeColor + points;
        } else {
            return _colNotAchieved + points;
        }
    }

    private void _RefreshMapPack(const string &in typeName) {
        if(!_refreshing) {
            TMRank::Model::MapPackType@ mapPackType = TMRank::Repository::GetMapPackTypeFromType(typeName);
            @_refreshCr = startnew(TMRank::Service::LoadMapData, mapPackType.typeID);
            _refreshing = true;
        }
    }

    private void _ClearMapCache() {
        _mapCache.Resize(0);
    }

    private void _ClearLeaderboardCache() {
        _leaderboardCache.Resize(0);
    }

    private void _TabItemClicked(const string &in tabType) {
        _mapOffset = 0;
    }

}