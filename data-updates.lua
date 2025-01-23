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
            end
        end
	end
    
    if recipe.results then
        for _,result in pairs(recipe.results) do
            if result.name == "nutrients" then
                result.name = "nutrient-solution"
                result.type = "fluid"
                result.amount = (result.amount or 1) * nutrient_solution_ratio
                result.percent_spoiled = nil

                recipe.ingredients = recipe.ingredients or {}
                local water_is_ingredient = false
                for _,ingredient in pairs(recipe.ingredients) do
                    if ingredient.name == "water" then
                        water_is_ingredient = true
                        ingredient.amount = (ingredient.amount or 1) + result.amount
                    end
                end
                if not water_is_ingredient then
                    table.insert(recipe.ingredients, {type = "fluid", name = "water", amount = result.amount})
                end
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
            amount = technology.research_trigger.count * nutrient_solution_ratio
        }
    end
end

-- Update biochamber to take nutrient-solution as fuel
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
            {flow_direction = "input", direction = defines.direction.west, position = {-1, 0}},
            {flow_direction = "input", direction = defines.direction.east, position = {1, 0}}
		},
        secondary_draw_orders = { north = -1 },
    },
    burns_fluid = true,
    effectivity = biochamber.energy_source.effectivity,
    emissions_per_minute = biochamber.energy_source.emissions_per_minute,
    light_flicker = biochamber.energy_source.light_flicker
}
