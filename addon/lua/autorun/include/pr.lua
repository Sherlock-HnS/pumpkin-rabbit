AddCSLuaFile()

pk_pills.packStart('Pumpkin Rabbit','Pumpkin Rabbit','icon/none.png')

pk_pills.register("pill_PRtoybox",{

    printName="Pumpkin Rabbit",
	
    model="models/birdlecandles/PumpkinRabbit.mdl",
	
	modelScale="10",

    muteSteps = true,
	
    anims={
        default={
            idle="idle",
			run="run",
            walk="walk",
			attack="kill",
			jumpscare="kill",
            crouch="cidle",
        },
    },
	
    moveSpeed={
        walk=50,
        run=540,
        ducked=32,
    },
	
    sounds={
		melee="dark/PR/kill.mp3",
		jumpscare="dark/PR/kill.mp3",
		loop_stare="dark/PR/idle.wav",
        killvoice = pk_pills.helpers.makeList("dark/PR/killvoice#.mp3", 3),
        highlight = pk_pills.helpers.makeList("dark/PR/highlight#.mp3", 3),
        laugh = pk_pills.helpers.makeList("dark/PR/laugh#.mp3", 3),
    },
	

    type="ply",

    camera={
        dist=170
    },
	
    jumpPower=0,
	
    health=250000,
	
	movePoseMode="xy",
		aim={
		xPose="aim_yaw",
		yPose="aim_pitch",
		nocrosshair = true
	},
	
	canAim=function(ply,ent)
		return ent.active
	end,

init = function(ply, ent)
    if not IsValid(ent) then return end

    local timerName = "CheckPlaySoundPR" .. ent:EntIndex()
    local soundObj = CreateSound(ent, "dark/PR/idle.wav")
    local targetVolume = 1
    local currentVolume = 0
    local fadeSpeed = 0.7

    soundObj:Play()
    soundObj:ChangeVolume(0, 0) -- start muted

    -- Timer to replay the sound every 30 seconds
    timer.Create(timerName .. "_Replay", 30, 0, function()
        if not IsValid(ent) or not IsValid(ply) then
            if soundObj then soundObj:Stop() end
            timer.Remove(timerName .. "_Replay")
            return
        end

        soundObj:Stop()
        soundObj:Play()
        soundObj:ChangeVolume(currentVolume, 0)
    end)

    -- Timer to adjust volume smoothly every 0.1 seconds
    timer.Create(timerName, 0.1, 0, function()
        if not IsValid(ent) or not IsValid(ply) then
            if soundObj then soundObj:Stop() end
            timer.Remove(timerName)
            timer.Remove(timerName .. "_Replay")
            return
        end

        -- Mute if certain lines are playing
        if ent.killlineplaying or ent.highlightlineplaying or ent.laughlineplaying then
            targetVolume = 0
        else
            local speed = ply:GetVelocity():Length2D()
            if speed > 80 then
                targetVolume = 0.35
            else
                targetVolume = 1
            end
        end

        -- Tween volume
        currentVolume = Lerp(fadeSpeed, currentVolume, targetVolume)
        soundObj:ChangeVolume(currentVolume, 0)
    end)
end,



	
--Left Click Attack Function
attack = {
    mode = 'trigger',
    func = function(ply, ent)
        local entity = nil

        -- Find the nearest player or NPC to the trigger entity
        for k, v in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 200)) do
            if v:IsPlayer() or v:IsNextBot() or v:IsNPC() then
                if v == ent or v == ply then continue end
                if (v:IsPlayer() and v:Team() ~= TEAM_SPECTATOR) or (v:IsNPC() or v:IsNextBot()) and v:Health() > 0 then
                    entity = v
                    break
                end
            end
        end

        if SherlockHNS and IsValid(entity) and entity:IsPlayer() then
            return pk_pills.playHNSJumpscare(ply, ent, entity, 2.85, {
                camera = "PILLSJUMPCAM",
                offset = 95,
                animation = "jumpscare",
                sound = "jumpscare",
            })
        end

        if IsValid(entity) then
            local pill = ent:GetPuppet()

            -- Handling players
            if entity:IsPlayer() then
                entity:Freeze(true)
                entity:AddFlags(FL_NOTARGET)
                entity:DrawViewModel(false)
                entity:SetActiveWeapon(nil)

                -- Start the jump scare camera effect
                net.Start('PILLSJUMPCAM')
                net.WriteEntity(pill)
                net.WriteBool(true)
                net.Send(entity)
            else
                -- Disable NPC's future thinking to simulate freezing them
                entity:NextThink(CurTime() + 1e9) 
            end

            -- Move the entity into position relative to the pill
            entity:SetPos(pill:GetPos() + pill:GetForward() * 95)

            ply:Freeze(true)

            -- Play the animation and sound for the entity performing the attack
            ent:PillAnim('jumpscare')
            ent:PillSound('jumpscare')
            timer.Simple(4, function()
                ent.killlineplaying = true
                ent:PillSound('killvoice')
            end)


             timer.Simple(0.8, function()

                local offset = ply:GetRight() * math.Rand(0, 0) +
                ply:GetForward() * math.Rand(85, 85) +
		        ply:GetUp() * math.Rand(60, 60)
                
                local effectdata = EffectData()
                effectdata:SetOrigin(ply:GetPos() + offset)
                effectdata:SetNormal(ent:GetAngles():Forward())
                effectdata:SetMagnitude(3)
                effectdata:SetScale(15)
                effectdata:SetColor(0)
                effectdata:SetFlags(3)
                util.Effect("BloodImpact", effectdata)
            end)


            timer.Simple(2.85, function()

                local offset = ply:GetRight() * math.Rand(0, 0) +
                ply:GetForward() * math.Rand(95, 95) +
		        ply:GetUp() * math.Rand(65, 65)
                
                local effectdata = EffectData()
                effectdata:SetOrigin(ply:GetPos() + offset)
                effectdata:SetNormal(ent:GetAngles():Forward())
                effectdata:SetMagnitude(3)
                effectdata:SetScale(15)
                effectdata:SetColor(0)
                effectdata:SetFlags(3)
                util.Effect("bloodspray", effectdata)
                effectdata:SetOrigin(ply:GetPos() + offset)
                effectdata:SetNormal(ent:GetAngles():Forward())
                effectdata:SetMagnitude(3)
                effectdata:SetScale(15)
                effectdata:SetColor(0)
                effectdata:SetFlags(3)
                util.Effect("BloodImpact", effectdata)
                effectdata:SetOrigin(ply:GetPos() + offset)
                effectdata:SetNormal(ent:GetAngles():Forward())
                effectdata:SetMagnitude(3)
                effectdata:SetScale(15)
                effectdata:SetColor(0)
                effectdata:SetFlags(3)
                util.Effect("BloodSplash", effectdata)
            end)

            -- Timer to handle the next steps after the animation
            timer.Simple(2.85, function()
                if not IsValid(entity) or not IsValid(ent) then return end

                

                -- Handling NPCs
                if entity:IsNPC() or entity:IsNextBot() then
                    local headBone = entity:LookupBone("ValveBiped.Bip01_Head1")
                    if headBone then
                        entity:ManipulateBoneScale(headBone, Vector(0, 0, 0))
                    end
                end

                -- Handling Players
                if entity:IsPlayer() then
                    local finalRagdoll = ents.Create("prop_ragdoll")
                    finalRagdoll:SetModel(entity:GetModel())
                    finalRagdoll:SetPos(entity:GetPos())
                    finalRagdoll:SetAngles(entity:GetAngles())
                    finalRagdoll:Spawn()

                    -- Set ragdoll physics
                    for i = 0, entity:GetBoneCount() - 1 do
                        local phys = finalRagdoll:GetPhysicsObjectNum(i)
                        if IsValid(phys) then
                            local pos, ang = entity:GetBonePosition(i)
                            phys:SetPos(pos)
                            phys:SetAngles(ang)
                            phys:Wake()
                        end
                    end

                    -- Manipulate head bone
                    local headBone = finalRagdoll:LookupBone("ValveBiped.Bip01_Head1")
                    if headBone then
                        finalRagdoll:ManipulateBoneScale(headBone, Vector(0, 0, 0))
                    end
                end

                -- Freeze and reset player settings
                ply:Freeze(false)

                -- Kill the player or damage the NPC
                if entity:IsPlayer() then
                    entity:Kill(ply)
                    net.Start('PILLSJUMPCAM')
                    net.WriteEntity(pill)
                    net.WriteBool(false)
                    net.Send(entity)
                    entity:RemoveFlags(FL_NOTARGET)
                    entity:Freeze(false)
                    entity:DrawViewModel(true)
                else
                    entity:NextThink(CurTime()) 
                    entity:TakeDamage(1e9, ply)
                end
            end)
        else
            -- No valid target, perform normal attack animation
        end

        timer.Simple(3, function()
            ply.OnHold = false
        end)

        -- Timer to reset hold state
        timer.Simple(10, function()
            ent.killlineplaying = false
        end)
    end,
},

attack2 = {
    mode = "trigger",
    func = function(ply, ent)
        if not IsValid(ply) then return end

        ent.highlightlineplaying = true

        local cooldown = 60
        local lastUse = ply._lastWallUse or 0
        local now = CurTime()

        if now - lastUse < cooldown then
            local timeLeft = math.ceil(cooldown - (now - lastUse))
            ply:ChatPrint("Highlight on cooldown: " .. timeLeft .. "s left.")
            return
        end

        if ply.OnHold then return end

        ent:PillSound("highlight")
        ply:SetNWBool("PRwallhaks", true)
        ply.wallsdelay = true
        ply._lastWallUse = now
        timer.Simple(5, function()
            ent.highlightlineplaying = false
        end)

        timer.Simple(10, function()
            if IsValid(ply) then
                ply:SetNWBool("PRwallhaks", false)
            end
        end)

        timer.Simple(cooldown, function()
            if IsValid(ply) then
                ply.wallsdelay = false
            end
        end)
    end,
},




    noragdoll=true,
	
	-- R click function
   	reload=function(ply,ent)
        ent.laughlineplaying = true
        ent:PillSound('laugh')
        ent.laughonhold = true
        timer.Simple(2.5, function()
            ent.laughonhold = false
        end)
        timer.Simple(4, function()
            ent.laughlineplaying = false
        end)
	end,
	
    -- F Click function
    flashlight=function(ply,ent)

    end,
	
	-- Jump Attack Spacebar Function 
    jump = function(ply, ent)
	    
    end
}, function(form)
    -- The legacy damage branches are for Sandbox and NPCs.
    form.hnsKillAPI = true
    form.hnsAbilities = {
        { id = "attack", name = "Ataque", key = IN_ATTACK, OnUse = form.attack.func },
        { id = "highlight", name = "Revelar jogadores", key = IN_ATTACK2, cooldown = 60, duration = 10,
            CanUse = function(ply) return not ply.OnHold end,
            OnUse = function(ply, ent)
                ent:PillSound("highlight")
                ply:SetNWBool("PRwallhaks", true)
            end,
            OnEnd = function(ply) if IsValid(ply) then ply:SetNWBool("PRwallhaks", false) end end },
        { id = "laugh", name = "Risada", key = IN_RELOAD, OnUse = form.reload },
    }
    form.attack, form.attack2, form.reload = nil, nil, nil
end)



