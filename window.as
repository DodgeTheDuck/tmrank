
class Window {

    private UI::Font@ _fontTitle;
    private UI::Font@ _fontHeader;
    private UI::Font@ _fontInfo;

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

    Window() {
        @_fontTitle = UI::LoadFont("DroidSans-Bold.ttf", 32);
        @_fontHeader = UI::LoadFont("DroidSans-Bold.ttf", 24);
        @_fontInfo = UI::LoadFont("DroidSans-Bold.ttf", 18);
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
        if(UI::Begin("TMRank", open)) {
            
            auto mapPacks = TMRank::Cache::GetMapPacks();
            
            UI::BeginTabBar("tb_tmrank", UI::TabBarFlags::Reorderable);

            // Draw about tab

            if(UI::BeginTabItem("About")) {
                _RenderAbout();
                UI::EndTabItem();
            }

            // Draw each map pack tab
            for(int i = 0; i < mapPacks.Length; i++) {
                auto mapPack = mapPacks[i];
                bool tabOpen = UI::BeginTabItem(mapPack.TypeName);
                if(UI::IsItemClicked()) {
                    _mapOffset = 0;
                    _leaderboardOffset = 0;
                }
                if(tabOpen) {
                    _RenderTab(mapPack);
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

    private void _RenderAbout() {
        UI::PushFont(_fontTitle);
        UI::Text("Welcome to TMRank");
        UI::PopFont();
        UI::Separator();
        UI::PushFont(_fontInfo);
        UI::PushStyleColor(UI::Col::Text, vec4(0.8, 0.8, 0.8, 1.0));
        UI::Text("Please wait a few seconds for the map packs to load.");
        UI::Text("TMRank is a community driven map-style completion and ranking system.");
        UI::PopStyleColor();
        UI::PopFont();

        UI::PushFont(_fontHeader);
        UI::Text("How It Works");
        UI::PopFont();
        UI::Separator();
        UI::Text("This plugin is essentially a front-end for Spl1nes website");
        UI::SameLine();
        UI::TextDisabled(Icons::ExternalLink);
        if (UI::IsItemClicked()) OpenBrowserURL("https://tmrank.jingga.app/");
        if(UI::IsItemHovered()) {
            UI::BeginTooltip();
            UI::Text("Click to open the website");
            UI::EndTooltip();
        }
        UI::SameLine();
        UI::Text(". Points for the leaderboard ");
        UI::Text("are gained by finishing maps and obtaining medals within the various map styles. ");
        UI::Text("\n");
        UI::Text("Map completion, score and rankings are updated every 24h. ");        
        UI::Text("\n");

        UI::PushFont(_fontHeader);
        UI::Text("Contribution");
        UI::PopFont();
        UI::Separator();
        UI::Text("Please see Spl1nes TMRank github for information.");
        UI::SameLine();
        UI::TextDisabled(Icons::ExternalLink);
        if (UI::IsItemClicked()) OpenBrowserURL("https://github.com/spl1nes/tmrank");
        if(UI::IsItemHovered()) {
            UI::BeginTooltip();
            UI::Text("Click to open the website");
            UI::EndTooltip();
        }
        UI::SameLine();

    }

    private void _RenderTab(TMRank::Model::MapPack@ mapPack) {
        if(UI::BeginTable("table_tmrank_" + mapPack.TypeName, 2, UI::TableFlags::None)) {
            UI::TableSetupColumn("maps", UI::TableColumnFlags::WidthFixed, 700);
            UI::TableSetupColumn("leaderboard", UI::TableColumnFlags::WidthStretch, 0);
            UI::TableNextRow();
            UI::TableNextColumn();
            if(_DrawMapList(mapPack)) {
                UI::TableNextColumn();
                _DrawLeaderboard(mapPack);
            }
            UI::EndTable();
        }
    }

    private bool _DrawMapList(TMRank::Model::MapPack@ mapPack) {

        auto maps = mapPack.GetMaps();
        
        string headerText = mapPack.TypeName +" (" + 
            (_mapOffset + 1) + 
            "-" + 
            (Math::Min(_mapOffset+_mapLimit, maps.Length)) + ")"
            + " of " + maps.Length;

        UI::Text(headerText);

        if(UI::BeginTable("table_tmrank_map_list_header", 1)) {
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 550);

            UI::TableNextRow();
            UI::TableNextColumn();
            if(UI::Button(Icons::ArrowLeft)) {
                if(_mapOffset - _mapLimit >= 0) {
                    _mapOffset -= _mapLimit;
                }
            }
            UI::SameLine();
            if(UI::Button(Icons::ArrowRight)) {
                if(_mapOffset + _mapLimit < maps.Length) {
                    _mapOffset += _mapLimit;
                }
            }            
            UI::EndTable();
        }


        UI::Separator();

        if(UI::BeginTable("table_tmrank_personal" + mapPack.TypeName, 8, UI::TableFlags::ScrollY)) {
            UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthFixed, 200);
            UI::TableSetupColumn("PB", UI::TableColumnFlags::WidthFixed, 100);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 50);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 50);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 50);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 50);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 50);
            UI::TableSetupColumn("Score", UI::TableColumnFlags::WidthStretch, 0);
            
            UI::TableHeadersRow();

            auto maps = mapPack.GetMaps();

            for(uint i = _mapOffset; i < Math::Min(_mapOffset + _mapLimit, maps.Length); i++) {

                auto map = maps[i];

                UI::TableNextRow();
                UI::TableNextColumn();
                if(UI::Button(Icons::Play + "##" + i)) {
                    _isOpen = false;
                    startnew(Game::PlayMap, @map);
                }
                UI::SameLine();
                UI::Text(ColoredString(map.Name));
                if(UI::IsItemHovered()) {
                    UI::BeginTooltip();
                    UI::Text(StripFormatCodes(map.Name));
                    auto img = Util::Images::CachedFromURL(map.Img);
                    if(img.m_texture != null) {
                        UI::Image(img.m_texture, vec2(256, 256));
                    }
                    UI::EndTooltip();
                }
        
                if(map.UserStats != null && map.UserStats.PB > 0) {
                    UI::TableNextColumn();
                    UI::Text(Time::Format(map.UserStats.PB));
                } else {
                    UI::TableNextColumn();
                }

                array<string> pointStrings = {
                    _DoPointString(map.FinishScore, map.UserStats, 9999999),
                    _DoPointString(map.BronzeScore, map.UserStats, map.BronzeTime),
                    _DoPointString(map.SilverScore, map.UserStats, map.SilverTime),
                    _DoPointString(map.GoldScore, map.UserStats, map.GoldTime),
                    _DoPointString(map.AuthorScore, map.UserStats, map.AuthorTime)
                };

                array<string> medalStrings = {
                    "Finish",
                    "Bronze: " + Time::Format(map.BronzeTime),
                    "Silver: " + Time::Format(map.SilverTime),
                    "Gold: " + Time::Format(map.BronzeTime),
                    "AT: " + Time::Format(map.AuthorTime),
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
                if(map.UserStats != null && map.UserStats.Score > 0) {
                    UI::Text(map.UserStats.Score + "");
                }

            }
            UI::EndTable();
        }
        return true;
    }

    private string _DoPointString(int points, TMRank::Model::UserMapStats@ userStats, uint pointTime) {
        if(userStats != null && userStats.PB > 0) {            
            string completeColor = _colNotAchieved;
            if(userStats.PB <= pointTime) {
                completeColor = _colAchieved;
            }
            return completeColor + points;
        } else {
            return _colNotAchieved + points;
        }
    }


    private void _DrawLeaderboard(TMRank::Model::MapPack@ mapPack) {

        auto drivers = mapPack.GetDrivers();
        int totalDrivers = drivers.Length;

        string headerText = mapPack.TypeName + " Leaderboard (" + 
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

        UI::Separator();
        _DrawUserStats(mapPack);
        UI::Separator();
        if(UI::BeginTable("table_tmrank_leaderboard" + mapPack.TypeName, 5, UI::TableFlags::ScrollY)) {
            UI::TableSetupColumn("Rank", UI::TableColumnFlags::WidthFixed, 48);
            UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthFixed, 200);
            UI::TableSetupColumn("Score", UI::TableColumnFlags::WidthFixed, 100);
            UI::TableSetupColumn("Finishes", UI::TableColumnFlags::WidthFixed, 100);
            UI::TableSetupColumn("ATs", UI::TableColumnFlags::WidthFixed, 100);
            UI::TableHeadersRow();
            for(int i = _leaderboardOffset; i < Math::Min(_leaderboardOffset + _leaderboardLimit, drivers.Length); i++) {
                _DoLeaderboardRow(mapPack.TypeName, drivers[i], drivers[i].rank == 3);
            }
            UI::EndTable();
        }
    }

    private void _DrawUserStats(TMRank::Model::MapPack@ mapPack) {
        auto packStats = mapPack.GetUserPackStats();
        if(packStats != null) {
            UI::Text(packStats.Username);
            UI::Separator();
            UI::Text("Rank: " + packStats.Rank);
            UI::Text("Maps: " + mapPack.GetMaps().Length);

            float percFinish = float(packStats.Finishes) / float(mapPack.GetMaps().Length) * 100.0;
            float percAuthor = float(packStats.Authors) / float(mapPack.GetMaps().Length) * 100.0;
            float percGold = float(packStats.Golds) / float(mapPack.GetMaps().Length) * 100.0;

            UI::Text(_medalIcons[0] + Colors::WHITE + " Finishes: " + packStats.Finishes + Colors::MAP_FINISH + " (" + Text::Format("%1.2f", percFinish) + "%)");
            UI::Text(_medalIcons[4] + Colors::WHITE + " ATs: " + packStats.Authors + Colors::MAP_FINISH + " (" + Text::Format("%1.2f", percAuthor) + "%)");
            UI::Text(_medalIcons[3] + Colors::WHITE + " Golds: " + packStats.Golds + Colors::MAP_FINISH + " (" + Text::Format("%1.2f", percGold) + "%)");
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
        UI::TableNextColumn();
        UI::Text(color + driver.finishes + "");
        if(seperate) UI::Separator();
        UI::TableNextColumn();
        UI::Text(color + driver.authors + "");
        if(seperate) UI::Separator();
    }

}