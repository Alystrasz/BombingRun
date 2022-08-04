# Bombing Run

Custom "Global Offensive" gamemode for Titanfall2.

It requires you to plant a bomb in a base, and defend it until it explodes to get the win.

![A pilot is defusing a bomb.](https://raw.githubusercontent.com/Alystrasz/BombingRun/master/assets/defusing_screenshot.png)

## Changelog

#### v0.0.3

* Update Thunderstore upload CI configuration

#### v0.0.2

* Update Thunderstore upload CI configuration

#### v0.0.1 (initial release)

* Players can carry a bomb
* When killed, bomb holder will drop it
* Bomb can be planted in enemy base
* When planted, bomb can be defused

## Development

### Gamemode configuration

#### Rules

By setting `br_rules` configuration variable, you can use given rules sets:
* **0 (default rules)**: one bomb spawns at the center of the map, both teams must fight for the bomb control, respawn is enabled.
* **1 (TODO)**: one team must plant the bomb, the other must prevent it from doing so; roles are switched at half-time; respawn is disabled.
* **2 (TODO)**: both teams must plant the bomb in the enemy base; respawn is disabled.

#### Bomb ticks

You can setup bomb ticking duration (= time from bomb planted to bomb explosion) by setting number of ticks for each of the following duration:
* 2 seconds
* 1 second
* 0.5 second

By default, the bomb will tick 5 times with 2 seconds delay between ticks, 5 times with 1 second delay, and 10 times with 0.5 second delay before exploding.

### Classes

##### Bomb

When creating a new `Bomb()`, a bomb appears on the floor, which is defusable by the enemy team. Bomb ticking duration can be modified through convars.

##### BombingZone

By instanciating a `BombingZone`, you can declare a zone where bombs can be planted.

It will send a message to nearby bomb holder (indicating that he can go and plant the bomb there), and will prevent him from moving when planting the bomb.

### TODOs

#### Features

- [x] Statistics (bombs planted/defused, deaths)
- [x] Put some light effects on the bomb
- [x] Bomb holder indicator (YOU HAVE THE BOMB)
- [ ] Bomb carrying system (being able to give the bomb to somebody else)
- [ ] Translate prompt messages
- [ ] Init bomb icon on sides switch
- [ ] Hide RUI bomb icon to bomb holder
- [x] Chat team messages
- [x] Bomb sites UI indicators

### Credits

Publication CI stolen from [https://github.com/GreenTF/NSModTemplate](https://github.com/GreenTF/NSModTemplate)
