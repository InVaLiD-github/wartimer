local timeBetweenWars = 1200 -- the amount of time the war and passive time lasts, in seconds

local warColor = Color(46, 117, 53, 150) -- R,G,B,A
local passiveColor = Color(117,46,46,150)-- R,G,B,A






































if SERVER then 

util.AddNetworkString("warTimerToClient")
util.AddNetworkString("passivewar")
util.AddNetworkString("activewar")
util.AddNetworkString("war_init")

local warCurrent = 1 -- 1 for Calm Time - 2 for Wartime
local warTimerCount = 0
local sendInitMSG = 0

timer.Create("war",timeBetweenWars,0, function()
	if warCurrent == 1 then
		warCurrent = 2
		print("Wartime has started!")
		net.Start("activewar")
		net.Broadcast()

	elseif warCurrent == 2 then
		warCurrent = 1
		print("Wartime has ended!")
		net.Start("passivewar")
		net.Broadcast()
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

timer.Create("interval",0.5,0,function()
	 local warTimerTimeLeft = timer.TimeLeft("war")
	net.Start("warTimerToClient")
	net.WriteString(tostring(warTimerTimeLeft))
	net.Broadcast()
end)

util.AddNetworkString("warOnSpawn")

   hook.Add("InitialPlayerSpawn", "OpenDerma", function(ply)

   net.Start("warOnSpawn")
   net.Send(ply)
  
end)


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
		local WarHUD = vgui.Create("DFrame")
		WarTimer = vgui.Create("DLabel",WarHUD)
		WarPanelP = vgui.Create("DPanel",WarHUD)
		WarPanelA = vgui.Create("DPanel",WarHUD)
		WarIndicator = vgui.Create("DLabel",WarHUD)
		WarBattlefield = vgui.Create("DLabel",WarHUD)
--[[                                                WARHUD CONFIG                                                   ]]--

		--FRAME
		WarHUD:SetTitle("")
		WarHUD:SetSize(274,124)
		WarHUD:SetPos(ScrW() / 2 - WarHUD:GetWide()/2,ScrH() - WarHUD:GetTall())
		WarHUD:SetDraggable(false)
		WarHUD:ShowCloseButton(false)
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
			DrawBlur(self, 10)
		end
		--PANEL
		WarPanelP:SetSize(WarHUD:GetWide() - 12, WarHUD:GetTall() - 12)
		WarPanelP:SetPos(4,6)
		function WarPanelP.Paint()
				draw.RoundedBox(5,WarPanelP:GetPos(),WarPanelP:GetPos(),WarPanelP:GetWide(),WarPanelP:GetTall(),warColor)
		end
		WarPanelA:SetSize(WarHUD:GetWide() - 12, WarHUD:GetTall() - 12)
		WarPanelA:SetPos(4,6)
		function WarPanelA.Paint()
				draw.RoundedBox(5,WarPanelA:GetPos(),WarPanelA:GetPos(),WarPanelA:GetWide(),WarPanelA:GetTall(),passiveColor)
		end
		WarTimer:SetFont("CloseCaption_Normal")
		WarTimer:SetSize(200,50)
		WarTimer:SetPos(WarHUD:GetWide() / 2 - WarTimer:GetSize()/7, WarHUD:GetTall() - WarTimer:GetSize()/4.2)

		WarIndicator:SetFont("DermaLarge")
		WarIndicator:SetSize(200,50)
		WarIndicator:SetPos(WarHUD:GetWide() / 2 - WarIndicator:GetSize()/4.8, WarHUD:GetTall() - WarIndicator:GetSize()/2.8)

		WarBattlefield:SetFont("CloseCaption_Normal")
		WarBattlefield:SetSize(200,50)
		WarBattlefield:SetPos(WarHUD:GetWide() / 2 - WarBattlefield:GetSize()/2.5, WarHUD:GetTall() - WarBattlefield:GetSize()/2)
		WarBattlefield:SetText("The Battlefield is:")
		

		net.Receive("passivewar",function()
			print("Wartime Has Ended!")
			WarPanelA:SetDisabled(true)
			WarPanelP:SetDisabled(false)
			WarIndicator:SetText("Passive")
		end)
		net.Receive("activewar",function()
			print("Wartime Has Started!")
			WarPanelA:SetDisabled(false)
			WarPanelP:SetDisabled(true)
			WarIndicator:SetText("Active")
		end)
		timer.Create("interval",0.5,0,function()
			net.Receive("warTimerToClient",function()

				local timerString = net.ReadString()
				WarTimer:SetText(tostring(string.FormattedTime( tonumber(timerString), "%02i:%02i" )))


			end)
		end)


		
end
end)

--[[                                                WARHUD CONFIG                                                   ]]--

end








