untyped
global function InitDroppableBombClass
global var DroppableBomb

void function InitDroppableBombClass()
{
    class DroppableBomb {
        bomb = null
        trigger = null
        
        constructor (vector origin)
        {
            entity bomb = CreateEntity( "prop_dynamic" )
            bomb.SetValueForModelKey($"models/weapons/at_satchel_charge/at_satchel_charge.mdl")
            bomb.SetOrigin( origin )
            bomb.SetAngles( < -90, 0, 0> )
            DispatchSpawn( bomb )
            this.bomb = bomb

            bomb.kv.solid = SOLID_VPHYSICS
            bomb.SetAngularVelocity( 0, 500, 0 )

            // pick-up trigger
            this.trigger = CreateTriggerRadiusMultiple( origin, 30, [], TRIG_FLAG_NONE)
            AddCallback_ScriptTriggerEnter( expect entity(this.trigger), void function(entity trigger, entity ent) {
                if (!IsValid( ent ))
                    return
                if (!ent.IsPlayer())
                    return

                print( "Bomb picked by " + ent.GetPlayerName() )
                SetPlayerBombCount( ent, 1 )
                Remote_CallFunction_NonReplay( ent, "ServerCallback_YouHaveTheBomb" )

                this.bomb.Destroy()
                this.trigger.Destroy()
                this.bomb = null
                this.trigger = null
            } )
        }

        function Destroy()
        {
            if (this.trigger)
                this.trigger.Destroy()
            if (this.bomb)
                this.bomb.Destroy()
        }
    }
}