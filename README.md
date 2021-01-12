# Dicebag
A module of probability functions designed specifically for games.

Inspired by this excellent blog post: https://www.redblobgames.com/articles/probability/damage-rolls.html

## Installation
You can use Dicebag in your own project by adding this project as a [Defold library dependency](http://www.defold.com/manuals/libraries/). Open your game.project file and in the dependencies field under project add:

	https://github.com/8bitskull/dicebag/archive/master.zip

In order to avoid the introduction of breaking changes, it is recommended to add a specific release rather than the master version. A list of all releases can be found [here](https://github.com/8bitskull/dicebag/releases).

Once added, you must require the main Lua module via:

```
local dicebag = require("dicebag.dicebag")
```
Then you can use the Dicebag functions, for example via:

```
print(dicebag.flip_coin())
```


# Usage
### dicebag.set_up_rng(seed)
Sets up the randomseed and clears the first number of random rolls.

**PARAMETERS**
* `seed` (number) - optional seed, if not specified a seed will be generated using socket.gettime().

**RETURNS**
* `seed` (number) - the number used to seed the random function.

### dicebag.flip_coin()
Flip a coin.

**RETURNS**
* `result` (boolean) - true or false (50% chance).

### dicebag.roll_dice(num_dice, num_sides, modifier)
Roll a number of dice, D&D-style. An example would be rolling 3d6+2. Returns the sum of the resulting roll.

**PARAMETERS**
* `num_dice` (number) - Number of dice to roll.
* `num_sides` (number) - Number of sides on the dice.
* `modifier` (number) - Number to add to the result.

**RETURNS**
* `result` (number) - Sum of rolled dice plus modifier.

### dicebag.roll_special_dice(num_sides, advantage, num_dice, num_results)
Roll a number of dice and choose one (or more) of the highest (advantage) or lowest (disadvantage) results. Returns the sum of the relevant dice rolls.

**PARAMETERS**
* `num_sides` (number) - Number of sides on the dice.
* `advantage` (boolean) - If true, the highest rolls will be selected, otherwise the lowest values will be selected.
* `num_dice` (number) - Number of dice to roll.
* `num_results` (number) - How many of the highest (advantage) or lowest (disadvantage) dice to sum up.

**RETURNS**
* `result` (number) - Sum of the highest (advantage) or lowest (disadvantage) dice rolls.

### dicebag.roll_custom_dice(sides)
Roll a custom die. This die can have sides with different weights and different values.

**PARAMETERS**
* `sides` (table) - A table describing the sides of the die in the format `{{weight1, value1}, {weight2, value2} ...}`. Note that the value can be any variable type, not just numbers.

**RETURNS**
* `value` (any) - The value as specified in table `sides`.

### dicebag.bag_create(id, num_success, num_fail, reset_on_success)
Create a marble bag of green (success) and red (fails) 'marbles'. This allows you to, for example, make an unlikely event more and more likely the more fails are accumulated.

**PARAMETERS**
* `id` (string, number, hash) - A unique identifier for the marble bag.
* `num_success` (number) - The number of success marbles in the bag.
* `num_fails` (number) -  The number of fails marbles in the bag.
* `reset_on_success` (boolean) - Whether or not the bag should reset when a successful result is drawn. If false or nil the bag will reset when all marbles have been drawn.

### dicebag.bag_draw(id)
Draw a marble from a previously created bag.

**PARAMETERS**
* `id` (string, number, hash) - A unique identifier for the marble bag.

**RETURNS**
* `result` (boolean)

### dicebag.bag_reset(id)
Manually reset a marble bag. Will also be called when a marble bag is empty, or a success is drawn in a bag where `reset_on_success` is true.

**PARAMETERS**
* `id` (string, number, hash) - A unique identifier for the marble bag.

### dicebag.table_create(id, rollable_table)
Create a rollable table. This is similar to a marble bag, except each entry can have a different weight, and can return any value (not just a boolean).

**PARAMETERS**
* `id` (string, number, hash) - A unique identifier for the rollable table.
* `rollable_table` (table) - A table of weights, values and reset flags.

Table `rollable_table` has the format: {{weight1, value1, [reset_on_roll1]}, {weight2, value2, [reset_on_roll2]}, ...} where the parameters are:
* `weight` (number) - The relative probability of drawing the value.
* `value` (any) - The value to be returned if drawn.
* `reset_on_roll` (boolean) - Whether or not the table should be reset when this value is drawn. If all of these are false, the table will reset when all values have been drawn.

### dicebag.table_roll(id)
Draw a random value from the rollable table created in dicebag.table_create. The value will be removed from the table. If `reset_on_roll` is true, the table will reset. Otherwise, the table will reset when all values are drawn.

**PARAMETERS**
* `id` (string, number, hash) - A unique identifier for the rollable table.

**RETURNS**
* `value` (any) - The value specified in dicebag.table_create.

### dicebag.table_reset(id)
Manually reset a rollable table. Will also be called when the rollable table is empty, or a drawn value where `reset_on_roll` is true.

**PARAMETERS**
* `id` (string, number, hash) - A unique identifier for the rollable table.
