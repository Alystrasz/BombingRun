# Bombing Run

Custom "Global Offensive" gamemode for Titanfall2.

It requires you to plant a bomb in a base, and defend it until it explodes to get the win.

## Classes

##### Bomb

When creating a new `Bomb()`, a bomb appears on the floor, which is defusable by the enemy team. Bomb ticking duration can be modified through convars.

##### BombingZone

By instanciating a `BombingZone`, you can declare a zone where bombs can be planted.

It will send a message to nearby bomb holder (indicating that he can go and plant the bomb there), and will prevent him from moving when planting the bomb.

## TODOs

#### Features

- [x] Statistics (bombs planted/defused, deaths)
- [x] Put some light effects on the bomb
- [ ] Bomb holder indicator (YOU HAVE THE BOMB)
- [ ] Bomb carrying system (being able to give the bomb to somebody else)
- [x] Chat team messages
- [x] Bomb sites UI indicators

#### Fixes

- [ ] If bomb has been planted, whole attacking team dying should not end round