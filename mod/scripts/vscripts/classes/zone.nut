untyped
global var BombingZone
global function InitBombingZoneClass

void function InitBombingZoneClass()
{
    class BombingZone {
        name = null
        volumeMins = null
        volumeMaxs = null

        constructor(string name, var volumeMins, vector volumeMax)
        {
            this.name = name
            this.volumeMins = volumeMins
            this.volumeMaxs = volumeMax
        }

        function CheckForBombPlant()
        {
            thread this._CheckForBombPlant()
        }

        function _CheckForBombPlant() {
            table times = {}
            float currTime = Time()
            int bombPlantDelay = 3

            while(true)
            {
                float currTime = Time()
                foreach(player in GetPlayerArray())
                {
                    if (PointIsWithinBounds( player.GetOrigin(), expect vector(this.volumeMins), expect vector(this.volumeMaxs) ) && player.UseButtonPressed())
                    {
                        if (currTime - times[player.GetPlayerName()] >= bombPlantDelay)
                        {
                            // plant bomb
							round.bomb = expect entity(Bomb(player).bomb)

							print(player.GetPlayerName() + " triggered entity action.");
                            player.MovementEnable()
                            return
                        }
                        player.MovementDisable()
                        player.ConsumeDoubleJump()
                    } else
                    {
                        times[player.GetPlayerName()] <- currTime
                        player.MovementEnable()
                    }
                }
                WaitFrame()
            }
        }
    }
}
