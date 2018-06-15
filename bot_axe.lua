-----------------------------------------
 
local fountainLocation = Vector(-5923.0, -5337.0, 384.0);
local fountainRadius = 400.0;
local lastUpdate = GameTime();
local state = "STOP"
local lastState = "STOP"
 
--------------------------------------------------------------------------------

function GetTowerLocation(nTower)
    return GetTower(GetTeam(), nTower):GetLocation()
end

function chat(bot, message) 
    if state ~= lastState then
        bot:ActionImmediate_Chat( "Alexa: " .. message, false )
    end
end

function updateState()
    local deaths = GetHeroDeaths(0);
    local kills = GetHeroKills(0);

    local alexaDeaths = GetHeroDeaths(1);
    local alexaKills = GetHeroDeaths(1);
    local req = CreateRemoteHTTPRequest("localhost/cgi-bin/first.pl?");
    req:SetHTTPRequestRawPostBody("application/json", "{\"playerKills\":" .. kills .. ", \"playerDeaths\":" .. deaths ..
        ", \"alexaKills\":" .. alexaKills .. ", \"alexaDeaths\":" .. alexaDeaths .. "}");
    req:Send( function( result )
        print( "POST response:\n" );
        print("+" .. result["Body"] .. "+");
        state = result["Body"];
    end )
end

function Think()
    local npcBot = GetBot();
    local player = GetTeamMember(1)

    local angle = math.rad(math.fmod(npcBot:GetFacing()+30, 360)); -- Calculate next position's angle
    local newLocation = npcBot:GetLocation()
    if state == "DefendBottomTower" then
        newLocation = GetTowerLocation(TOWER_BOT_1)
        chat(npcBot, "I'm going to defend the bottom tower")
    elseif state == "DefendTopTower" then
        newLocation = GetTowerLocation(TOWER_TOP_1)
        chat(npcBot, "I'm going to defend the top tower")
    elseif state == "DefendMidTower" then
        newLocation = GetTowerLocation(TOWER_MID_1)
        chat(npcBot, "I'm going to defend the middle tower")
    elseif state == "DefendMe" then
        newLocation = player:GetLocation()
        chat(npcBot, "I'm coming to help you, noob!")
    elseif state == "RunAroundTheFountain" then
        newLocation = Vector(fountainLocation.x+fountainRadius*math.cos(angle), fountainLocation.y+fountainRadius*math.sin(angle), fountainLocation.z);
        chat(npcBot, "I'm going to run around the fountain")
    end
    lastState = state
    if GetUnitToLocationDistance(npcBot, newLocation) < 1000.0 then
        npcBot:Action_AttackMove(newLocation)
    else
        npcBot:Action_MoveToLocation(newLocation)
    end
    DebugDrawLine(npcBot:GetLocation(), newLocation, 255, 0, 0)

    if GameTime() - lastUpdate > 2.0 then
        lastUpdate = GameTime();

 	    updateState()
    end
end

 
