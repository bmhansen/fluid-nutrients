-- Update all recipes using nutrients to use nutrient-solution
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

-- Update biochamber to take nutrient-solution as fuel
local biochamber_flow_direction
if settings.startup["biochamber-nutrient-solution-flow-through"].value then
    biochamber_flow_direction = "input-output"
else
    biochamber_flow_direction = "input"
end

local biochamber = data.raw["assembling-machine"]["biochamber"]
biochamber.energy_source = {
    type = "fluid",
    fluid_box = {
        volume = 10,
		filter = "nutrient-solution",
		minimum_temperature = 15,
		maximum_temperature = 100,
        pipe_picture = {
            north = table.deepcopy(data.raw["assembling-machine"]["electromagnetic-plant"].fluid_boxes[1].pipe_picture.north),
            east = table.deepcopy(data.raw["assembling-machine"]["electromagnetic-plant"].fluid_boxes[1].pipe_picture.east),
            south = util.empty_sprite(),
            west = util.empty_sprite(),
        },
        pipe_picture_frozen = {
            north = table.deepcopy(data.raw["assembling-machine"]["electromagnetic-plant"].fluid_boxes[1].pipe_picture_frozen.north),
            east = table.deepcopy(data.raw["assembling-machine"]["electromagnetic-plant"].fluid_boxes[1].pipe_picture_frozen.east),
            south = util.empty_sprite(),
            west = util.empty_sprite(),
        },
        pipe_covers = biochamber.fluid_boxes[1].pipe_covers,
		pipe_connections = {
            {flow_direction = biochamber_flow_direction, direction = defines.direction.west, position = {-1, 0}},
            {flow_direction = biochamber_flow_direction, direction = defines.direction.east, position = {1, 0}}
		},
        secondary_draw_orders = { north = -1 },
    },
    burns_fluid = true,
    scale_fluid_usage = true,
    effectivity = biochamber.energy_source.effectivity,
    emissions_per_minute = biochamber.energy_source.emissions_per_minute,
    light_flicker = biochamber.energy_source.light_flicker
}

-- Update biolab to take nutrient-solution as fuel
if settings.startup["biolab-use-nutrient-solution"].value then
    local biolab = data.raw["lab"]["biolab"]
    biolab.energy_source = {
        type = "fluid",
        fluid_box = {
            volume = 20,
            filter = "nutrient-solution",
            minimum_temperature = 15,
            maximum_temperature = 100,
            pipe_picture = {
                north = table.deepcopy(data.raw["assembling-machine"]["electromagnetic-plant"].fluid_boxes[1].pipe_picture.north),
                east = data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture.east,
                south = data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture.south,
                west = data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture.west
            },
            pipe_picture_frozen = {
                north = table.deepcopy(data.raw["assembling-machine"]["electromagnetic-plant"].fluid_boxes[1].pipe_picture_frozen.north),
                east = data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture_frozen.east,
                south = data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture_frozen.south,
                west = data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture_frozen.west
            },
            pipe_covers = biochamber.fluid_boxes[1].pipe_covers,
            pipe_connections = {
                {flow_direction = "input", direction = defines.direction.west, position = {-2, 0}},
                {flow_direction = "input", direction = defines.direction.east, position = {2, 0}},
                {flow_direction = "input", direction = defines.direction.south, position = {0, 2}},
                {flow_direction = "input", direction = defines.direction.north, position = {0, -2}}
            },
            secondary_draw_orders = { north = -1 },
        },
        burns_fluid = true,
        scale_fluid_usage = true,
        emissions_per_minute = biolab.energy_source.emissions_per_minute,
    }
end

-- Update captive biter spawner to take nutrient-solution as fuel
if settings.startup["captive-biter-spawner-use-nutrient-solution"].value then
    local captive_biter_spawner = data.raw["assembling-machine"]["captive-biter-spawner"]
    captive_biter_spawner.energy_source = {
        type = "fluid",
        fluid_box = {
            volume = 20,
            filter = "nutrient-solution",
            minimum_temperature = 15,
            masaximum_temperature = 100,
            pipe_picture = {
                north = table.deepcopy(data.raw["assembling-machine"]["electromagnetic-plant"].fluid_boxes[1].pipe_picture.north),
                east = data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture.east,
                south = data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture.south,
                west = data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture.west
            },
            pipe_picture_frozen = {
                north = table.deepcopy(data.raw["assembling-machine"]["electromagnetic-plant"].fluid_boxes[1].pipe_picture_frozen.north),
                east = data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture_frozen.east,
                south = data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture_frozen.south,
                west = data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture_frozen.west
            },
            pipe_covers = biochamber.fluid_boxes[1].pipe_covers,
            pipe_connections = {
                {flow_direction = "input", direction = defines.direction.west, position = {-2, 0}},
                {flow_direction = "input", direction = defines.direction.east, position = {2, 0}},
                {flow_direction = "input", direction = defines.direction.south, position = {0, 2}},
                {flow_direction = "input", direction = defines.direction.north, position = {0, -2}}
            },
            secondary_draw_orders = { north = -1 },
        },
        burns_fluid = true,
        emissions_per_minute = captive_biter_spawner.energy_source.emissions_per_minute,
    }

    -- Also nerf biter egg to nutrient solution recipe
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
