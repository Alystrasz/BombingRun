untyped
global function InitDroppableBombClass
global var DroppableBomb

void function InitDroppableBombClass()
{
    class DroppableBomb {
        bomb = null

        constructor (vector origin, vector initialVelocity = <0, 0, 0>)
        {
            entity bomb = CreateEntity( "prop_dynamic" )
            bomb.SetValueForModelKey($"models/weapons/at_satchel_charge/at_satchel_charge.mdl")
            bomb.SetOrigin( origin )
            bomb.SetAngles( < -90, 0, 0> )
            DispatchSpawn( bomb )
            this.bomb = bomb

            bomb.kv.solid = SOLID_VPHYSICS
            bomb.SetVelocity( initialVelocity )
            bomb.SetAngularVelocity( 0, 500, 0 )
        }
    }
}