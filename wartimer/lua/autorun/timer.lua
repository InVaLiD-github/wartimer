local timeBetweenWars = 1200 -- the amount of time the war and passive time lasts, in seconds

local warColor = Color(100, 0, 0, 150) -- R,G,B,A
local passiveColor = Color(0,100,0,150)-- R,G,B,A

local team1Name = "Allied"
local team2Name = "Axis"

local team1Category = "Allied"
local team2Category = "Axis"

local team1Color = Color(10,50,10, 120)
local team2Color = Color(50,10,10, 120)





--[[END OF CONFIG]]--
--[[I don't recommend changing anything below this line, you might break it.]]

























local team1 = {}
local team2 = {}

if SERVER then 

util.AddNetworkString("warTimerToClient")
util.AddNetworkString("passivewar")
util.AddNetworkString("activewar")
util.AddNetworkString("war_init")
util.AddNetworkString("team1ScoresToClient")
util.AddNetworkString("team2ScoresToClient")




local function wartimerTeamFrags(index)

	local warTimerTFscore = 0
	for id,pl in pairs( index ) do
		if pl:Frags() != nil then
			warTimerTFscore = warTimerTFscore + pl:Frags()
		end
	end
	return warTimerTFscore

end




local warCurrent = 1 -- 1 for Calm Time - 2 for Wartime
local warTimerCount = 0
local sendInitMSG = 0

timer.Create("war",timeBetweenWars,0, function()
	if warCurrent == 1 then
		warCurrent = 2
		PrintMessage(HUD_PRINTCENTER, "THE BATTLEFIELD IS NOW ACTIVE.")
		print("Wartime has started!")
		net.Start("activewar")
		net.Broadcast()
		for id2,pl2 in pairs(player.GetAll()) do
			pl2:SetFrags(0)
			pl2:SetDeaths(0)
		end 


		local team1Frags = 0
		local team2Frags = 0
			timer.Create("scoreint", 5, 0 ,function()
				for i,v in pairs(player.GetAll()) do
					if RPExtraTeams[v:Team()].category == team1Category then
						if table.HasValue(team1, v) == false then
							table.insert(team1, v)
						end
					elseif RPExtraTeams[v:Team()].category == team2Category then
						if table.HasValue(team2, v) == false then
							table.insert(team2, v)
						end
					end
				end
			end)
	elseif warCurrent == 2 then
		timer.Remove("scoreint")
		warCurrent = 1
		print("Wartime has ended!")
		net.Start("passivewar")
		net.Broadcast()
		print("------WAR SUMMARY------" .. "\n" .. team1Name .. "\n" .. wartimerTeamFrags(team1) .. "\n" .. team2Name .. "\n" .. wartimerTeamFrags(team2) )
		PrintMessage(HUD_PRINTTALK, "------WAR SUMMARY------" .. "\n" .. team1Name .. "\n" .. wartimerTeamFrags(team1) .. "\n" .. team2Name .. "\n" .. wartimerTeamFrags(team2))
		if wartimerTeamFrags(team1) > wartimerTeamFrags(team2) then
			PrintMessage(HUD_PRINTCENTER, "The "..team1Name.." have won the war!")
		elseif wartimerTeamFrags(team2) > wartimerTeamFrags(team1) then
			PrintMessage(HUD_PRINTCENTER, "The "..team2Name.." have won the war!")
		elseif wartimerTeamFrags(team1) == wartimerTeamFrags(team2) then
			PrintMessage(HUD_PRINTCENTER, "The war was a tie.")
		end
	end
end)
timer.Start("war")

net.Receive("war_init",function()

	if warCurrent == 2 then
		net.Start("activewar")
		net.Broadcast()
	elseif warCurrent == 1 then

		net.Start("passivewar")
		net.Broadcast()

	end


end)

timer.Create("interval",0.10,0,function()
	 local warTimerTimeLeft = timer.TimeLeft("war")
	net.Start("warTimerToClient")
	net.WriteString(tostring(warTimerTimeLeft))
	net.Broadcast()
end)
timer.Create("intervalA",1,0,function()

	net.Start("team1ScoresToClient")
	net.WriteString(tostring(wartimerTeamFrags(team1)))
	net.Broadcast()

end)
timer.Create("intervalB",1,0,function()

	net.Start("team2ScoresToClient")
	net.WriteString(tostring(wartimerTeamFrags(team2)))
	net.Broadcast()

end)


util.AddNetworkString("warOnSpawn")

   hook.Add("InitialPlayerSpawn", "OpenDerma", function(ply)

   net.Start("warOnSpawn")
   net.Send(ply)
  
end)






print("[WARTIMER] ".."\n".."sv loaded!")

end
if CLIENT then

local Loaded = 0

hook.Add( "InitPostEntity", "warplayerspawned", function(ply)
	Loaded = 1
	if Loaded == 1 then
		net.Start("war_init")
		net.SendToServer()
	end

	if Loaded == 1 then

		local frame = vgui.Create("DFrame")
		local WarHUD = vgui.Create("DPanel", frame)
		WarCover = vgui.Create("DPanel", WarHUD)
		WarTimer = vgui.Create("DLabel",WarHUD)
		WarPanelP = vgui.Create("DPanel",WarHUD)
		WarPanelA = vgui.Create("DPanel",WarHUD)
		WarIndicator = vgui.Create("DLabel",WarHUD)
		TeamBG = vgui.Create("DPanel", frame)
		TeamPanel = vgui.Create("DPanel", TeamBG)
		TeamInner1 = vgui.Create("DPanel", TeamPanel)
		TeamInner2 = vgui.Create("DPanel", TeamPanel)
		Team1Score = vgui.Create("DLabel", TeamInner)
		Team2Score = vgui.Create("DLabel", TeamInner)

--[[                                                WARHUD CONFIG                                                   ]]--

		--FRAME
		frame:SetTitle("")
		frame:SetSize(250,100) --250,100
		frame:SetPos(ScrW() / 2 - frame:GetWide()/2,ScrH() - frame:GetTall())
		frame:SetDraggable(true)
		frame:ShowCloseButton(false)
		function frame.Paint()
			draw.RoundedBox(0,WarPanelP:GetPos(),WarPanelP:GetPos(),WarPanelP:GetWide(),WarPanelP:GetTall(),Color(255,255,255,0))
		end

		WarHUD:SetSize(124,60)
		WarHUD:SetPos(frame:GetWide() / 2 - WarHUD:GetWide() / 2 - 1, WarHUD:GetTall() - frame:GetTall() / 2)
		local blur = Material("pp/blurscreen")
			local function DrawBlur(panel, amount)
			local x, y = WarHUD:LocalToScreen(0, 0)
			local scrW, scrH = ScrW(), ScrH()
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(blur)
			for i = 1, 3 do
				blur:SetFloat("$blur", (i / 3) * (amount or 6))
				blur:Recompute()
				render.UpdateScreenEffectTexture()
				surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
			end
			end
		function WarHUD.Paint()
			DrawBlur(self, 5)

		end

		--COVER
		WarCover:SetSize(WarHUD:GetWide(), WarHUD:GetTall())
		WarCover:SetPos(0,0)
		function WarCover.Paint()
				draw.RoundedBoxEx(0,WarCover:GetPos(),WarCover:GetPos(),WarCover:GetWide(),WarCover:GetTall(),Color(0,0,0,150),false,false,false,false)
		end

		--PANEL
		WarPanelP:SetSize(WarHUD:GetWide() - 11.5, WarHUD:GetTall() - 11)
		WarPanelP:SetPos(4,6)
		function WarPanelP.Paint()
				draw.RoundedBox(0,WarPanelP:GetPos(),WarPanelP:GetPos(),WarPanelP:GetWide(),WarPanelP:GetTall(),Color(255,255,255,5))
		end

		WarPanelA:SetSize(WarHUD:GetWide() - 11.5, WarHUD:GetTall() - 11.)
		WarPanelA:SetPos(4,6)
		function WarPanelA.Paint()
				draw.RoundedBox(0,WarPanelA:GetPos(),WarPanelA:GetPos(),WarPanelA:GetWide(),WarPanelA:GetTall(),Color(255,255,255,5))
		end
		WarTimer:SetFont("CloseCaption_Normal")
		WarTimer:SetSize(200,50)
		WarTimer:SetPos(WarHUD:GetWide() / 2 - WarTimer:GetSize()/7, WarHUD:GetTall() - WarTimer:GetSize()/3.2)

		WarIndicator:SetFont("HudHintTextLarge")
		WarIndicator:SetSize(200,50)
		WarIndicator:SetPos(WarHUD:GetWide() / 2 - WarIndicator:GetSize()/8 * 1.25, WarHUD:GetTall() - WarIndicator:GetSize()/4.6)
		

		net.Receive("passivewar",function()
			print("Wartime Has Ended!")
			WarPanelA:SetDisabled(true)
			WarPanelP:SetDisabled(false)
			WarIndicator:SetText("PASSIVE")
			WarIndicator:SetColor(Color(250,250,250))
		end)
		net.Receive("activewar",function()
			print("Wartime Has Started!")
			WarPanelA:SetDisabled(false)
			WarPanelP:SetDisabled(true)
			WarIndicator:SetText("ACTIVE")
			WarIndicator:SetColor(Color(250,0,0))
		end)
		timer.Create("interval",0.5,0,function()
			net.Receive("warTimerToClient",function()

				local timerString = net.ReadString()
				WarTimer:SetText(tostring(string.FormattedTime( tonumber(timerString), "%02i:%02i" )))


			end)
		end)

		TeamBG:SetSize(250,35)
		TeamBG:SetPos(frame:GetWide() / 2 - TeamBG:GetWide() / 2, WarCover:GetPos() + TeamBG:GetTall()*2)
		local blur2 = Material("pp/blurscreen")
			local function DrawBlur2(panel, amount)
			local x, y = TeamBG:LocalToScreen(0, 0)
			local scrW, scrH = ScrW(), ScrH()
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(blur2)
			for i = 1, 3 do
				blur2:SetFloat("$blur", (i / 3) * (amount or 6))
				blur2:Recompute()
				render.UpdateScreenEffectTexture()
				surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
			end
			end
		function TeamBG.Paint()
			DrawBlur2(self, 5)
		end


		local team1ClientScore = 0
		local team2ClientScore = 0
		timer.Create("updateScoresForRender", 3,0,function()
			net.Receive("team1ScoresToClient",function()
				local timerString1 = net.ReadString()
				team1ClientScore = tonumber(timerString1)
				
			end)
			net.Receive("team2ScoresToClient",function()
				local timerString2 = net.ReadString()
				team2ClientScore = tonumber(timerString2)
				
			end)
		end)

		TeamPanel:SetSize(TeamBG:GetWide(), TeamBG:GetTall())
		TeamPanel:SetPos(TeamBG:GetPos(), TeamBG:GetPos())
		function TeamPanel.Paint()
		 draw.RoundedBoxEx(0,TeamPanel:GetPos(),TeamPanel:GetPos(),TeamPanel:GetWide(),TeamPanel:GetTall(),Color(0,0,0,150),false,false,false,false)
		end
		timer.Create("barmovement", 0.2, 0, function()
			if team2ClientScore != 0 or nil && team1ClientScore != 0 or nil then
				TeamInner1:SetSize(TeamBG:GetWide() / 2 / team2ClientScore * team1ClientScore, TeamBG:GetTall())
				TeamInner1:SetPos(TeamBG:GetPos(), TeamBG:GetPos())
				function TeamInner1.Paint()
					draw.RoundedBoxEx(0,TeamInner1:GetPos(),TeamInner1:GetPos(),TeamInner1:GetWide(),TeamInner1:GetTall(),team1Color,false,false,false,false)
				end
			else
				TeamInner1:SetSize(TeamBG:GetWide() / 2 , TeamBG:GetTall())
				TeamInner1:SetPos(TeamBG:GetPos(), TeamBG:GetPos())
				function TeamInner1.Paint()
					draw.RoundedBoxEx(0,TeamInner1:GetPos(),TeamInner1:GetPos(),TeamInner1:GetWide(),TeamInner1:GetTall(),team1Color,false,false,false,false)
				end
			end

			if team1ClientScore != 0 or nil && team2ClientScore != 0 or nil then
				TeamInner2:SetSize(TeamBG:GetWide() / 2 / team1ClientScore * team2ClientScore, TeamBG:GetTall())
				TeamInner2:SetPos(TeamBG:GetPos() + TeamInner2:GetWide() + team1ClientScore, TeamBG:GetPos())
				function TeamInner2.Paint()
					draw.RoundedBox(0,TeamBG:GetPos(),TeamBG:GetPos(),TeamInner2:GetWide(),TeamInner2:GetTall(),team2Color)
				end
			else
				TeamInner2:SetSize(TeamBG:GetWide() / 2, TeamBG:GetTall())
				TeamInner2:SetPos(TeamBG:GetPos() + TeamInner2:GetWide(), TeamBG:GetPos())
				function TeamInner2.Paint()
					draw.RoundedBox(0,TeamBG:GetPos(),TeamBG:GetPos(),TeamInner2:GetWide(),TeamInner2:GetTall(),team2Color)
				end
			end
		end)
		Team1Score:SetFont("DermaDefault")
		Team1Score:SetPos(TeamInner1:GetPos() / 2 - TeamInner1:GetWide(), TeamInner1:GetTall() / 2.5)
		Team1Score:SetText("0")

		Team2Score:SetFont("DermaDefault")
		Team2Score:SetPos(TeamInner2:GetPos() / 2 - TeamInner2:GetWide(), TeamInner2:GetTall() / 2.5)
		Team2Score:SetText("0")
		-- Scores Labels

		timer.Create("updateScores", 3,0,function()
				Team1Score:SetText(team1ClientScore)
				Team2Score:SetText(team2ClientScore)
		end)
end
end)

--[[                                                WARHUD CONFIG                                                   ]]--

end








