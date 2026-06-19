-- Run in data-final-fixes so recipes added by other mods in data/data-updates are also caught
local nutrients_energy = data.raw.item["nutrients"].fuel_value:gsub("M", "000"):gsub("[kJ]", "")
local nutrient_solution_energy = data.raw.fluid["nutrient-solution"].fuel_value:gsub("M", "000"):gsub("[kJ]", "")
local nutrient_solution_ratio = nutrients_energy/nutrient_solution_energy

for _,recipe in pairs(data.raw.recipe) do
    if recipe.ingredients then
        for _,ingredient in pairs(recipe.ingredients) do
            if ingredient.name == "nutrients" then
                ingredient.name = "nutrient-solution"
                ingredient.type = "fluid"
                ingredient.amount = (ingredient.amount or 1) * nutrient_solution_ratio
                if recipe.category == "crafting" then
                    recipe.category = "crafting-with-fluid"
                end
                break
            end
        end
    end

    if recipe.results then
        for i, result in pairs(recipe.results) do
            if result.name == "nutrients" then
                if string.find(recipe.name, "-recycling") then
                    table.remove(recipe.results, i)
                    break
                end

                result.name = "nutrient-solution"
                recipe.main_product = "nutrient-solution"
                result.type = "fluid"
                result.amount = (result.amount or 1) * nutrient_solution_ratio
                result.percent_spoiled = nil

                if settings.startup["water-needed-to-make-nutrient-solution"].value then
                    recipe.ingredients = recipe.ingredients or {}
                    local water_is_ingredient = false
                    for _,ingredient in pairs(recipe.ingredients) do
                        if ingredient.name == "water" then
                            water_is_ingredient = true
                            ingredient.amount = (ingredient.amount or 1) + result.amount
                            break
                        end
                    end
                    if not water_is_ingredient then
                        table.insert(recipe.ingredients, {type = "fluid", name = "water", amount = result.amount})
                    end
                end
                break
            end
        end
    end
end

-- Update all technologies requiring nutrients to require nutrient-solution
for _,technology in pairs(data.raw.technology) do
    if technology.research_trigger
    and technology.research_trigger.item
    and technology.research_trigger.item == "nutrients" then
        technology.research_trigger = {
            type = "craft-fluid",
            fluid = "nutrient-solution",
            amount = (technology.research_trigger.count or 1) * nutrient_solution_ratio
        }
    end
end

-- Generic conversion: any entity with a burner energy source using the "nutrients" fuel
-- category, or bioflux's fuel category, gets converted to burn nutrient-solution fluid.
local _pipe_covers = data.raw["assembling-machine"]["biochamber"].fluid_boxes[1].pipe_covers
local _em_fb  = data.raw["assembling-machine"]["electromagnetic-plant"].fluid_boxes[1]
local _asm2_fb = data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1]
local _flow_direction = settings.startup["nutrient-solution-flow-through"].value and "input-output" or "input"
local _bioflux_fuel_category = data.raw.capsule["bioflux"] and data.raw.capsule["bioflux"].fuel_category

local function uses_fuel_category(source, category)
    if not source or not source.fuel_categories then return false end
    for _, cat in pairs(source.fuel_categories) do
        if cat == category then return true end
    end
    return false
end

local function collect_existing_connections(entity)
    local connections = {}
    for _, fb in pairs(entity.fluid_boxes or {}) do
        for _, conn in pairs(fb.pipe_connections or {}) do
            table.insert(connections, conn)
        end
    end
    return connections
end

local function position_taken(connections, dir, pos)
    for _, conn in pairs(connections) do
        if conn.direction == dir then
            local cx = conn.position[1] or conn.position.x
            local cy = conn.position[2] or conn.position.y
            local px = pos[1] or pos.x
            local py = pos[2] or pos.y
            if cx == px and cy == py then return true end
        end
    end
    return false
end

local function find_pipe_positions(entity, cb)
    local existing = collect_existing_connections(entity)
    local west_x  = math.ceil(cb[1][1])
    local east_x  = math.floor(cb[2][1])
    local north_y = math.ceil(cb[1][2])
    local south_y = math.floor(cb[2][2])

    local candidates = {
        {{dir = defines.direction.west,  pos = {west_x,  0}},       {dir = defines.direction.east,  pos = {east_x,  0}}},
        {{dir = defines.direction.north, pos = {0,  north_y}},      {dir = defines.direction.south, pos = {0,  south_y}}},
        {{dir = defines.direction.west,  pos = {west_x,  1}},       {dir = defines.direction.east,  pos = {east_x,  1}}},
        {{dir = defines.direction.west,  pos = {west_x, -1}},       {dir = defines.direction.east,  pos = {east_x, -1}}},
        {{dir = defines.direction.north, pos = {1,  north_y}},      {dir = defines.direction.south, pos = {1,  south_y}}},
        {{dir = defines.direction.north, pos = {-1, north_y}},      {dir = defines.direction.south, pos = {-1, south_y}}},
    }

    for _, pair in pairs(candidates) do
        if not position_taken(existing, pair[1].dir, pair[1].pos)
        and not position_taken(existing, pair[2].dir, pair[2].pos) then
            return pair[1], pair[2]
        end
    end
    return nil, nil
end

local function make_nutrient_fluid_source(entity, original)
    local conn_a, conn_b = find_pipe_positions(entity, entity.collision_box)
    if not conn_a then return nil end

    local pipe_connections = {
        {flow_direction = _flow_direction, direction = conn_a.dir, position = conn_a.pos},
        {flow_direction = _flow_direction, direction = conn_b.dir, position = conn_b.pos},
    }

    local source = table.deepcopy(original)

    -- Remove burner-only fields that have no meaning on a fluid energy source
    source.fuel_categories = nil
    source.fuel_inventory_size = nil
    source.burnt_inventory_size = nil
    source.burner_usage = nil

    -- Switch to fluid type and inject fluid-specific fields
    source.type = "fluid"
    source.burns_fluid = true
    source.scale_fluid_usage = true
    source.fluid_box = {
        volume = 10,
        filter = "nutrient-solution",
        minimum_temperature = 15,
        maximum_temperature = 100,
        pipe_picture = {
            north = table.deepcopy(_em_fb.pipe_picture.north),
            east  = table.deepcopy(_em_fb.pipe_picture.east),
            south = table.deepcopy(_asm2_fb.pipe_picture.south),
            west  = table.deepcopy(_asm2_fb.pipe_picture.west),
        },
        pipe_picture_frozen = {
            north = table.deepcopy(_em_fb.pipe_picture_frozen.north),
            east  = table.deepcopy(_em_fb.pipe_picture_frozen.east),
            south = table.deepcopy(_asm2_fb.pipe_picture_frozen.south),
            west  = table.deepcopy(_asm2_fb.pipe_picture_frozen.west),
        },
        pipe_covers = _pipe_covers,
        pipe_connections = pipe_connections,
        secondary_draw_orders = {north = -1},
    }

    return source
end

-- Entity types that expose fuel via energy_source
for _, type_name in pairs({"assembling-machine", "furnace", "mining-drill", "lab", "boiler", "reactor"}) do
    for _, entity in pairs(data.raw[type_name] or {}) do
        if uses_fuel_category(entity.energy_source, "nutrients") then
            local new_source = make_nutrient_fluid_source(entity, entity.energy_source)
            if new_source then entity.energy_source = new_source end
        end
    end
end

-- Burner-generators expose fuel via a separate `burner` field
for _, entity in pairs(data.raw["burner-generator"] or {}) do
    if uses_fuel_category(entity.burner, "nutrients") then
        local new_source = make_nutrient_fluid_source(entity, entity.burner)
        if new_source then entity.burner = new_source end
    end
end

-- Convert any other captive-spawner-type entity (bioflux fuel category) to nutrient-solution
-- when the captive biter spawner setting is enabled. The vanilla captive-biter-spawner is
-- handled explicitly in data-updates.lua; this catches equivalents added by other mods.
if settings.startup["captive-biter-spawner-use-nutrient-solution"].value and _bioflux_fuel_category then
    for _, type_name in pairs({"assembling-machine", "furnace", "mining-drill", "lab", "boiler", "reactor"}) do
        for _, entity in pairs(data.raw[type_name] or {}) do
            if uses_fuel_category(entity.energy_source, _bioflux_fuel_category) then
                local new_source = make_nutrient_fluid_source(entity, entity.energy_source)
                if new_source then entity.energy_source = new_source end
            end
        end
    end
end

-- Nerf biter egg recipe now that conversion loop has run (divides the already-multiplied amount)
if settings.startup["captive-biter-spawner-use-nutrient-solution"].value then
    local biter_nutrient_recipe = data.raw.recipe["nutrients-from-biter-egg"]
    biter_nutrient_recipe.results[1].amount = biter_nutrient_recipe.results[1].amount / nutrient_solution_ratio
    for _,ingredient in pairs(biter_nutrient_recipe.ingredients) do
        if ingredient.name == "water" then
            ingredient.amount = ingredient.amount / nutrient_solution_ratio
            break
        end
    end
end

-- Give fish breeding a use as a way to produce nutrient solution (with biochamber)
if settings.startup["fish-breeding-net-positive-nutrient-solution"].value then
    data.raw.recipe["nutrients-from-fish"].allow_productivity = true
    data.raw.recipe["nutrients-from-fish"].results[1].amount = data.raw.recipe["nutrients-from-fish"].results[1].amount / nutrient_solution_ratio
    local nutrients_from_fish_out = data.raw.recipe["nutrients-from-fish"].results[1].amount
    for _,ingredient in pairs(data.raw.recipe["nutrients-from-fish"].ingredients) do
        if ingredient.name == "water" then
            ingredient.amount = ingredient.amount / nutrient_solution_ratio
            break
        end
    end

    local fish_breeding_ingredients = data.raw.recipe["fish-breeding"].ingredients
    for i = #fish_breeding_ingredients, 1, -1 do
        local ingredient = fish_breeding_ingredients[i]
        if ingredient.name == "nutrient-solution" then
            ingredient.amount = nutrients_from_fish_out
        end
        if ingredient.name == "water" then
            table.remove(fish_breeding_ingredients, i)
        end
    end
end
