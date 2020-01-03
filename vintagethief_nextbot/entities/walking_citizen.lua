AddCSLuaFile()

ENT.Base   = "base_nextbot"
ENT.Spawnable   = true

function coroutine.waitt( seconds )
local endtime = CurTime() + seconds
while ( true ) do
if ( endtime < CurTime() or panic == true ) then return end
coroutine.yield()
end
end

local citizens = { 1 = {"models/Humans/Group01/female_01.mdl", "models/humans/group01/female_02.mdl", "models/humans/group01/female_03.mdl",
 "models/humans/group01/female_04.mdl", "models/humans/group01/female_05.mdl", "models/humans/group01/female_06.mdl", "models/humans/group01/female_07.mdl"  }
2 = {"models/Humans/Group01/Male_01.mdl", "models/Humans/Group01/Male_02.mdl", "models/Humans/Group01/Male_03.mdl", "models/Humans/Group01/Male_04.mdl",
  "models/Humans/Group01/Male_05.mdl", "models/Humans/Group01/Male_06.mdl", "models/Humans/Group01/Male_07.mdl", "models/Humans/Group01/Male_08.mdl", "models/Humans/Group01/Male_09.mdl" }}

function ENT:Initialize()
  
  self:SetModel( table.Random( citizens ) )
  self.LoseTargetDist	= 2000
  self.SearchRadius 	= 1000

	self.ToDo = 0
	self.idletime = 0
	panic = false
	self.running = false
end

function ENT:MoveToPos_fixed( pos, options )
local options = options or {}
local path = Path( "Follow" )
local first_try = 0

path:SetMinLookAheadDistance( options.lookahead or 300 )
path:SetGoalTolerance( options.tolerance or 20 )
path:Compute( self, pos )
if ( !path:IsValid() ) then return "failed" end
while ( path:IsValid() ) do
path:Update( self )
if ( options.draw ) then
path:Draw()
end

if (panic == true and options.running == false) then
return "panic"
end

if ( self.loco:IsStuck() ) then
self:HandleStuck()
return "stuck"
end

if (self:GetVelocity( ):Length2D( )   == 0) then
first_try = first_try+1	
if(first_try > 10) then
return "stuck"
end
	
end

if ( options.maxage ) then
if ( path:GetAge() > options.maxage ) then return "timeout" end
end

if ( options.repath ) then
if ( path:GetAge() > options.repath ) then path:Compute( self, pos ) end
end
coroutine.yield()
end
return "ok"
end

function ENT:walk()

			self:StartActivity( ACT_WALK )			-- Walk anmimation
			self.loco:SetDesiredSpeed( 80 )		-- Walk speed
			self.running = true
			self:MoveToPos_fixed( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * math.random( 250, 900 ),  {running = false}) 
			self.running = false
end

function ENT:run()
			self:StartActivity( ACT_RUN )			-- Run anmimation
			self.loco:SetDesiredSpeed( 190 )		-- Run speed
			self.running = true
			
			self:MoveToPos_fixed( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * math.random( 250, 350 )) 
			self.running = false
end



function ENT:RunBehaviour()

	-- This function is called when the entity is first spawned. It acts as a giant loop that will run as long as the NPC exists
	while ( true ) do
	
		

		self.ToDo = math.random( 0, 30 )
			if (panic == false) then
				self.idletime = math.Rand( 0, 2 )
				--play random animation, sometimes
				
				 if     self.ToDo == 0 then self:walk() 
				elseif  self.ToDo == 1 then self:PlaySequenceAndWait( "checkmale", 0.5 )
				elseif  self.ToDo == 2 then self:PlaySequenceAndWait( "d2_coast03_PostBattle_Idle01_Entry", 1 )
				elseif  self.ToDo == 3 then self:PlaySequenceAndWait( "cheer1", 1 )
				elseif  self.ToDo == 4 then self:PlaySequenceAndWait( "d1_t01_BreakRoom_WatchBreen", 1 )
				elseif  self.ToDo == 5 then self:PlaySequenceAndWait( "p_bouncingout", 1 )
				elseif  self.ToDo == 6 then self:PlaySequenceAndWait( "photo_react_startle", 1 )
				elseif  self.ToDo == 7 then self:PlaySequenceAndWait( "Wave_close", 1 )
				
				
				
				else     self:walk() 
				end
				
			else
				if self.ToDo > 15 then
					if self.gender == 0 then
					--Play female sounds
					self.Entity:EmitSound( "ambient/voices/f_scream1.wav", self:GetPos(), self:EntIndex(), 2, 1, 1, 0, 100 )
					else
					--Play Male sounds
					self.Entity:EmitSound( "ambient/voices/m_scream1.wav", self:GetPos(), self:EntIndex(), 2, 1, 1, 0, 100 )
					end
				end
				--play random animation, sometimes
			 if     self.ToDo == 0 then self:run()
			 elseif  self.ToDo == 1 then self:PlaySequenceAndWait( "cower_Idle", 1 )
			 elseif  self.ToDo == 2 then self:PlaySequenceAndWait( "arrestidle", 1 )
			 elseif  self.ToDo == 3 then self:PlaySequenceAndWait( "b_d2_coast03_PostBattle_Idle02default", 1 )
			 elseif  self.ToDo == 4 then self:PlaySequenceAndWait( "Fear_Reaction_Idle", 1 )
			 elseif  self.ToDo == 5 then self:PlaySequenceAndWait( "hg_chest_twistLdefault", 1 )
			 elseif  self.ToDo == 6 then self:PlaySequenceAndWait( "spreadwallidle", 1 )
			
			 else	self:run()
			 end
			 self.idletime = 0
		end
		self:StartActivity( ACT_IDLE )
		coroutine.waitt( self.idletime ) 	--wait random time on idle (0.4 sec to 4 sec) end
		
	end

end	





function ENT:OnKilled( damageinfo )
self:BecomeRagdoll( damageinfo )
end

function ENT:unpanic()
if ( timer.Exists( "timer_panic" ) ) then timer.Remove( "timer_panic" ) end
timer.Create( "timer_panic", math.random( 8, 15 ), 1, function() panic = false end ) 
end

function ENT:OnInjured(damageinfo)
					if self.gender == 0 then
					--Play female sounds
					self.Entity:EmitSound( "ambient/voices/citizen_beaten2.wav", self:GetPos(), self:EntIndex(), 2, 1, 1, 0, 100 )
					else
					--Play Male sounds
					self.Entity:EmitSound( "ambient/voices/citizen_beaten5.wav", self:GetPos(), self:EntIndex(), 2, 1, 1, 0, 100 )
					end
					
	panic = true
	self.idletime = 0
	if (self.running == false) then self:StartActivity( ACT_IDLE ) end
	self:unpanic()
end

list.Set( "NPC", "vintage_thief_citizens", {
	Class = "vintage_thief_citizens", 
	Name = "Citizen", 
	Author = "Vintage Thief",
	Category = "Citizens",
	Model = "models/humans/group01/male_05.mdl"
} )