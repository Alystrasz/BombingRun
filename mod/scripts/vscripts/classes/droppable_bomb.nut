untyped
global function InitDroppableBombClass
global var DroppableBomb

void function InitDroppableBombClass()
{
    /**
     * This gameobject is a bomb that spawns on level floor; it can be picked up by players 
     * during the match.
     * When somebody picks it, he receives a "bomb item" in his inventory, and the current 
     * droppable bomb disappears.
     */
    class DroppableBomb {
        bomb = null
        trigger = null
        
        constructor (vector origin)
        {
            // create the gameobject on map floor
            entity bomb = CreateEntity( "prop_dynamic" )
            bomb.SetValueForModelKey($"models/weapons/at_satchel_charge/at_satchel_charge.mdl")
            bomb.SetOrigin( origin )
            bomb.SetAngles( < -90, 0, 0> )
            DispatchSpawn( bomb )
            this.bomb = bomb
            bomb.kv.solid = SOLID_VPHYSICS
            bomb.SetAngularVelocity( 0, 500, 0 )

            // create pick-up trigger
            this.trigger = CreateTriggerRadiusMultiple( origin, 30, [], TRIG_FLAG_NONE)
            AddCallback_ScriptTriggerEnter( expect entity(this.trigger), void function(entity trigger, entity ent) {
                if (!IsValid( ent ))
                    return
                if (!ent.IsPlayer())
                    return

                // give bomb item to player, and tell him he picked up the bomb
                print( "Bomb picked by " + ent.GetPlayerName() )
                SetPlayerBombCount( ent, 1 )
                Remote_CallFunction_NonReplay( ent, "ServerCallback_YouHaveTheBomb" )

                // make RUI logo follow player
                this.bomb.SetParent( ent )
                this.bomb.SetOwner( ent )

                this.UpdateRUIIcon()

                // destroy the gameobject on the floor
                this.bomb.Hide()
                this.trigger.Destroy()
                this.trigger = null
            } )

            this.UpdateRUIIcon()
        }

        /**
         * Destroys all entities related to this bomb.
         * This is called between rounds to ensure there are no several bombs in a single round.
         */
        function Destroy()
        {
            if (this.trigger)
                this.trigger.Destroy()
            if (this.bomb)
                this.bomb.Destroy()
        }

        function UpdateRUIIcon()
        {
            foreach( player in GetPlayerArray() )
            {
                Remote_CallFunction_NonReplay( player, "ServerCallback_BombingRunInitBombIcon", this.bomb.GetEncodedEHandle() )
            }
        }
    }
}