local M = {}

M.bags = {}
M.tables = {}

---Set up random number generator and clear bad rolls
function M.set_up_rng()
    math.randomseed(100000 * (socket.gettime() % 1))
    for i=1,20 do
        math.random()
    end
end

---Flip a coin: 50% chance of returning true or false
function M.flip_coin()
    return math.random() > 0.5
end

---D&D-style dice roll, for example 3d6+2. Returns resulting roll value.
function M.roll_dice(num_dice, num_sides, modifier)

    num_dice = num_dice or 1
    num_sides = num_sides or 6
    modifier = modifier or 0

    local result = modifier

    for i=1,num_dice do
        result = result + math.random(num_sides)
    end

    return result
end

---Roll one or more dice with advantage or disadvantage (if advantage is not true rolls are disadvantaged). Returns the num_results sum of the highest (advantage) or lowest (disadvantage) value of all rolls.
function M.roll_special_dice(num_sides, advantage, num_dice, num_results)

    num_sides = num_sides or 6
    num_dice = num_dice or 2
    num_results = num_results or 1

    local rolls = {}
    local num_rolls = 0
    local roll = nil

    local replace_value = nil
    local replace_id = nil

    for i=1, num_dice do

        roll = M.roll_dice(1, num_sides)

        num_rolls = #rolls

        if num_rolls < num_results then
            table.insert(rolls, roll)
        elseif advantage then
            replace_value = num_sides
            replace_id = nil
            for j=1,num_rolls do
                if roll > rolls[j] and rolls[j] < replace_value then
                    replace_id = j
                    replace_value = rolls[j]
                end
            end
            if replace_id then
                rolls[replace_id] = roll
            end
        else
            replace_value = 0
            replace_id = nil
            for j=1,num_rolls do
                if roll < rolls[j] and rolls[j] > replace_value then
                    replace_id = j
                    replace_value = rolls[j]
                end
            end
            if replace_id then
                rolls[replace_id] = roll
            end
        end
    end

    local result = 0
    for i=1,num_rolls do
        result = result + rolls[i]
    end

    return result
end

---Roll a custom die. Parameter sides is a table in the format {{weight1, value1}, {weight2, value2} ...}. Returns the value of the rolled side.
function M.roll_custom_dice(sides)

    local total_weight = 0
    local num_sides = #sides

    --count up the total weight
    for i=1,num_sides do
        total_weight = total_weight + sides[i][1]
    end

    local weight_result = math.random() * total_weight

    --find and return the resulting value
    local processed_weight = 0
    for i=1,num_sides do
        if weight_result <= sides[i][1] + processed_weight then
            return sides[i][2]
        else
            processed_weight = processed_weight + sides[i][1]
        end
    end

    return 0
end

---Create a bag of green (success) and red (fail) "marbles" that you can draw from. If reset_on_success is true, the bag will be reset after the first green (success) marble is drawn, otherwise the bag will reset when all marbles have been drawn.
function M.bag_create(id, num_success, num_fail, reset_on_success)

    M.bags[id] = {success = num_success, fail = num_fail, full_success = num_success, full_fail = num_fail, reset_on_success = reset_on_success}
end
    
---Draw a marble from marble bag id. Returns true or false.
function M.bag_draw(id)

    if not M.bags[id] then
        return false
    end

    local result = math.random(1, M.bags[id].success + M.bags[id].fail)

    if result > M.bags[id].fail then
        result = true
        if M.bags[id].reset_on_success then
            M.bag_reset(id)
        else
            M.bags[id].success = M.bags[id].success - 1
        end
    else
        result = false
        M.bags[id].fail = M.bags[id].fail - 1
    end

    return result
end

---Refill a marble bag to its default number of marbles.
function M.bag_reset(id)

    if not M.bags[id] then
        return
    end

    M.bags[id].success = M.bags[id].full_success
    M.bags[id].fail = M.bags[id].full_fail
end

local function deep_copy(t)
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            target[k] = deep_copy(v)
        else
            target[k] = v
        end
    end
    setmetatable(target, meta)
    return target
end

local function splice(t,i,len)
    -- t = table
    -- i = location in table
    -- len = number of elements to remove
	len = len or 1
    if (len > 0) then
        for r=0, len do
            if(r < len) then
                table.remove(t,i + r)
            end
        end
    end
    local count = 1
    local tempT = {}
    for i=1, #t do
        if t[i] then
            tempT[count] = t[i]
            count = count + 1
        end
    end
    t = tempT
end

---Create a rollable table where entries are removed as they are rolled. Parameter rollable table format: {{weight1, value1, [reset_on_roll1]}, {weight2, value2, [reset_on_roll2]}, ...}
function M.table_create(id, rollable_table)
    M.tables[id] = {active = deep_copy(rollable_table), original = deep_copy(rollable_table)}
end

---Roll a value from a rollable table. Returns the value specified in the table.
function M.table_roll(id)
    
    if not M.tables[id] then
        return
    end

    local target_table = M.tables[id].active
    local total_weight = 0
    local num_entries = #target_table

    --count up the total weight
    for i=1,num_entries do
        total_weight = total_weight + target_table[i][1]
    end

    local weight_result = math.random() * total_weight

    --find and return the resulting value
    local result = nil
    local processed_weight = 0
    for i=1,num_entries do
        if weight_result <= target_table[i][1] + processed_weight then
            result = target_table[i][2]

            if target_table[i][3] or num_entries == 1 then
                M.table_reset(id)
            else
                splice(target_table, i, 1)
            end

            return result
        else
            processed_weight = processed_weight + target_table[i][1]
        end
    end

end

function M.table_reset(id)
    if not M.tables[id] then
        return
    end

    M.tables[id].active = deep_copy(M.tables[id].original)
end

return M