---
title: Making a Small "Star Attraction" Game with Gemini 2.0 Flash
layout: post
keywords: html5 canvas game llm gemini gemini-2.0-flash
---

This is an experiment to recreate the basics of <a href="https://store.steampowered.com/app/1519770/nbody/" target="_blank">Sokpop's n-body</a> game in HTML5 canvas using the new Gemini 2.0 Flash. The game is a simple physics-based game where you shoot a comet towards a target while other stars or suns attract the comet you shoot. The game is simple but has a nice feel to it.

Why Gemini 2.0 Flash? It's a state of the art model, with a big context window, and it's cheap. If I were to build a game building service, I would use this model.

This is the game after 23 iterations:
<iframe id="iframe-23" src="/star-attraction-game/23.html" width="920" height="518"></iframe>

## Iteration 1

Prompt:
<p>
<a href="/star-attraction-game/game.png" target="_blank"><img src="/star-attraction-game/game.png" width="200"></a>
</p>
```
Look at this picture of a simple game. Can you rebuild something similar in html5/javascript/canvas/webgl? First describe the gameplay before you give me code. Fit all the code in a single index.html. The gameplay is that there is a line going from a certain point to the cursor of the player. When the player clicks it shoots a "star" or "bullet" from the start point towards the cursor. The velocity depends on how long the line was. The stars you see in the level all attract to the "star" towards them based on how big they are. The goal of the player is to shoot the "star" into one of the other small points that spawn on the level.
```
Output:

<iframe id="iframe-1" src="/star-attraction-game/1.html" width="920" height="518"></iframe>
<p style="margin-top: 1px"><button onclick="document.getElementById('iframe-1').src = '/star-attraction-game/1.html'" class="button">Reload</button></p>

## Iteration 2

Prompt:
```
The ball is moving much too fast, it goes out of the window in much less than a second.
```
Output:

<iframe id="iframe-2" src="/star-attraction-game/2.html" width="920" height="518"></iframe>
<p style="margin-top: 1px"><button onclick="document.getElementById('iframe-2').src = '/star-attraction-game/2.html'" class="button">Reload</button></p>


## Iteration 3

Prompt:
```
It's still too fast, make it about 1/3 the speed. The gravity effect can also be stronger.
```
Output:

<iframe id="iframe-3" src="/star-attraction-game/3.html" width="920" height="518"></iframe>
<p style="margin-top: 1px"><button onclick="document.getElementById('iframe-3').src = '/star-attraction-game/3.html'" class="button">Reload</button></p>

## Iteration 4

Prompt:
```
When a ball hits a star it should disappear. Also randomize the spawn locations.
```
Output:

<iframe id="iframe-4" src="/star-attraction-game/4.html" width="920" height="518"></iframe>
<p style="margin-top: 1px"><button onclick="document.getElementById('iframe-4').src = '/star-attraction-game/4.html'" class="button">Reload</button></p>

## Iteration 5

Prompt:
```
Only the ball should disappear, not the star. Also randomize the player and "goal" starting positions. Also spawn 5 "goals" to try to hit.
```
Output:

<iframe id="iframe-5" src="/star-attraction-game/5.html" width="920" height="518"></iframe>
<p style="margin-top: 1px"><button onclick="document.getElementById('iframe-5').src = '/star-attraction-game/5.html'" class="button">Reload</button></p>

## Iteration 6

Prompt:
```
Make the attraction slightly less. Make sure the planets spawn a bit away from each other spread out over the level. Make sure things don't spawn on top of each other.
```
Output:

<iframe id="iframe-6" src="/star-attraction-game/6.html" width="920" height="518"></iframe>
<p style="margin-top: 1px"><button onclick="document.getElementById('iframe-6').src = '/star-attraction-game/6.html'" class="button">Reload</button></p>

## Iteration 7

Prompt:
```
Can you try and generate random but interesting levels. Just make it 1 target you need to hit, but make it so that you have to shoot past some suns and use their gravity. So maybe spawn the suns around the center, and the player and target at the edges almost opposite of each other.
```
Output:

**The generated code contained a bug and didn't render anything.**

## Iteration 8

Prompt:
```
Uncaught SyntaxError: Illegal break statement
```
Output:

**The generated code contained a bug and didn't render anything.**

## Iteration 9

Prompt:
```
Uncaught ReferenceError: mouseX is not defined
  at draw (index.html:243:28)
  at gameLoop (index.html:276:13)
  at index.html:282:9
```
Output:

<iframe id="iframe-9" src="/star-attraction-game/9.html" width="920" height="518"></iframe>
<p style="margin-top: 1px"><button onclick="document.getElementById('iframe-9').src = '/star-attraction-game/9.html'" class="button">Reload</button></p>

## Iteration 10

Prompt:
```
Make the attraction slightly less. Spawn the suns a bit further away from the center. Make sure the target always spawns at the other side of the screen from the player.
```
Output:

<iframe id="iframe-10" src="/star-attraction-game/10.html" width="920" height="518"></iframe>
<p style="margin-top: 1px"><button onclick="document.getElementById('iframe-10').src = '/star-attraction-game/10.html'" class="button">Reload</button></p>

## Iteration 11

Prompt:
```
The target is impossible to hit. How about we spawn the target somewhere in the center of the screen as well.
```
Output:

<iframe id="iframe-11" src="/star-attraction-game/11.html" width="920" height="518"></iframe>
<p style="margin-top: 1px"><button onclick="document.getElementById('iframe-11').src = '/star-attraction-game/11.html'" class="button">Reload</button></p>

## Iteration 12

Prompt:
```
Let me shoot more than 1 ball at once.
```
Output:

<iframe id="iframe-12" src="/star-attraction-game/12.html" width="920" height="518"></iframe>
<p style="margin-top: 1px"><button onclick="document.getElementById('iframe-12').src = '/star-attraction-game/12.html'" class="button">Reload</button></p>

## Iteration 13

Prompt:
```
Don't hide the line to my cursor
```
Output:

<iframe id="iframe-13" src="/star-attraction-game/13.html" width="920" height="518"></iframe>


## Iteration 14

Prompt:
```
Keep score of how many times I have hit a target. Add a maximum of 10 balls I can shoot before it automatically goes to the next level.
```
Output:

<iframe id="iframe-14" src="/star-attraction-game/14.html" width="920" height="518"></iframe>
<p style="margin-top: 1px"><button onclick="document.getElementById('iframe-14').src = '/star-attraction-game/14.html'" class="button">Reload</button></p>

## Iteration 15

Prompt:
```
Show how many balls I have left
```
Output:

<iframe id="iframe-15" src="/star-attraction-game/15.html" width="920" height="518"></iframe>
<p style="margin-top: 1px"><button onclick="document.getElementById('iframe-15').src = '/star-attraction-game/15.html'" class="button">Reload</button></p>

## Iteration 16

Prompt:
```
Make the multiplier for how long the line to my cursor is higher. So not a linear increase but something higher so it's easier to shoot really slow and really faster.
Can you give the balls a bit of a trail of lets say 50 pixels long roughly.
Can you animate the target a bit, like make it get slightly bigger and smaller in a loop to pull attention to it.
And if possible can you add a slight "glow" to the suns?
```
Output:

<iframe id="iframe-16" src="/star-attraction-game/16.html" width="920" height="518"></iframe>
<p style="margin-top: 1px"><button onclick="document.getElementById('iframe-16').src = '/star-attraction-game/16.html'" class="button">Reload</button></p>

## Iteration 17

Prompt:
```
Clicking does nothing now, it doesn't spawn a projectile
```
Output:

<iframe id="iframe-17" src="/star-attraction-game/17.html" width="920" height="518"></iframe>
<p style="margin-top: 1px"><button onclick="document.getElementById('iframe-17').src = '/star-attraction-game/17.html'" class="button">Reload</button></p>

## Iteration 18

Prompt:
```
It's still not spawning anything, or it's invisible, or too fast to see maybe?
```
Output:

<iframe id="iframe-18" src="/star-attraction-game/18.html" width="920" height="518"></iframe>
<p style="margin-top: 1px"><button onclick="document.getElementById('iframe-18').src = '/star-attraction-game/18.html'" class="button">Reload</button></p>

## Iteration 19

Prompt:
```
Here is the full console output when I click once:
index.html:198 mousedown event fired
index.html:220 Distance: 764.0013213656673 Launch Power: 583.6980190484857
index.html:221 velocityX: -583.6970095233698 velocityY -1.0855941237020146
index.html:233 Projectile created {
  "x": -146.58347811458736,
  "y": 303.23863471160234,
  "radius": 5,
  "velocityX": -572.087447711346,
  "velocityY": -1.0830314354706363,
  "active": false,
  "trail": [
    {
      "x": 431.2826306847521,
      "y": 304.33260585854237
    },
    {
      "x": -146.58347811458736,
      "y": 303.23863471160234
    }
  ]
}
```
Output:

<iframe id="iframe-19" src="/star-attraction-game/19.html" width="920" height="518"></iframe>
<p style="margin-top: 1px"><button onclick="document.getElementById('iframe-19').src = '/star-attraction-game/19.html'" class="button">Reload</button></p>

**Note:** This was the only time Gemini didn't output the full result, it only gave a `canvas.addEventListener('mousedown', ... )` replacement I had to manually apply.

## Iteration 20

Prompt:
```
Now it works, but can you put a limit on the velocity cause it can go too fast now. And make the increase from the line to my cursor getting longer slightly less to give more control.
```
Output:

<iframe id="iframe-20" src="/star-attraction-game/20.html" width="920" height="518"></iframe>
<p style="margin-top: 1px"><button onclick="document.getElementById('iframe-20').src = '/star-attraction-game/20.html'" class="button">Reload</button></p>

## Iteration 21

Prompt:
```
Make the max velocity about 2/3 of what it is now.
Sometimes the game completely flips out and keeps respawning the level over and over as fast as possible.
```
Output:

<iframe id="iframe-21" src="/star-attraction-game/21.html" width="920" height="518"></iframe>
<p style="margin-top: 1px"><button onclick="document.getElementById('iframe-21').src = '/star-attraction-game/21.html'" class="button">Reload</button></p>

## Iteration 22

Prompt:
```
Reduce the max velocity further by about a half. The endless respawning is still sometimes happening. It doesn't print anything in the console about it.
```
Output:

<iframe id="iframe-22" src="/star-attraction-game/22.html" width="920" height="518"></iframe>
<p style="margin-top: 1px"><button onclick="document.getElementById('iframe-22').src = '/star-attraction-game/22.html'" class="button">Reload</button></p>

## Iteration 23

Prompt:
```
Can you make the increase of making the line longer slightly stronger again.

The respawning over and over seems to happen when the amount of shots I have left is 0. The amount of shots doesn't reset each new level like it should.
```
Output:

<iframe id="iframe-23" src="/star-attraction-game/23.html" width="920" height="518"></iframe>
<p style="margin-top: 1px"><button onclick="document.getElementById('iframe-23').src = '/star-attraction-game/23.html'" class="button">Reload</button></p>

## Final Thoughts

At this point I thought the game was good enough and stopped iterating. It was a fun experiment to see how far I could get with just a few prompts and not doing anything with code myself. The game is simple but has a nice feel to it. I hope you enjoyed this little journey through the development of this small game with Gemini 2.0 Flash.

