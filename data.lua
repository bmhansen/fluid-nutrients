-- Add New Fluid
data:extend({
    {
        type = "fluid",
        name = "nutrient-solution",
        icon = "__fluid-nutrients__/gfx/nutrient-solution.png",
        subgroup = "fluid",
        order = "b[new-fluid]-d[gleba]-a[nutrient-solution]",
        default_temperature = 15,
        max_temperature = 100,
        fuel_value = "200kJ",
        base_color = {0.6, 0.6, 0.9},
        flow_color = {0.7, 0.7, 0.95},
        auto_barrel = true
    }
})

-- Update recipe icons
data.raw.recipe["nutrients-from-spoilage"].icon = "__fluid-nutrients__/gfx/nutrient-solution-from-spoilage.png"
data.raw.recipe["nutrients-from-yumako-mash"].icon = "__fluid-nutrients__/gfx/nutrient-solution-from-yumako-mash.png"
data.raw.recipe["nutrients-from-bioflux"].icon = "__fluid-nutrients__/gfx/nutrient-solution-from-bioflux.png"
data.raw.recipe["nutrients-from-fish"].icon = "__fluid-nutrients__/gfx/nutrient-solution-from-fish.png"
data.raw.recipe["nutrients-from-biter-egg"].icon = "__fluid-nutrients__/gfx/nutrient-solution-from-biter-egg.png"

-- TODO:
-- fix empty nutrient-solution to be pizza alert icon instead of fuel
