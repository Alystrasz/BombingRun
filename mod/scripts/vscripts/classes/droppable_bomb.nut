untyped
global function InitDroppableBombClass
global var DroppableBomb

void function InitDroppableBombClass()
{
    class DroppableBomb {
        bomb = null
        
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
            entity bombTrigger = CreateTriggerRadiusMultiple( origin, 30, [], TRIG_FLAG_NONE)
            AddCallback_ScriptTriggerEnter( bombTrigger, void function(entity trigger, entity ent) {
                if (!IsValid( ent ))
                    return
                if (!ent.IsPlayer())
                    return

                print( "Bomb picked by " + ent.GetPlayerName() )
                SetPlayerBombCount( ent, 1 )

                this.bomb.Destroy()
                trigger.Destroy()
            } )
        }
    }
}