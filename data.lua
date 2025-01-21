-- Add Fluids
data:extend({
    {
        type = "fluid",
        name = "nutrient-solution",
        icon = "__fluid-nutrients__/gfx/nutrient-solution.png",
        subgroup = "fluid",
        order = "b[new-fluid]-d[gleba]-a[nutrient-solution]",
        default_temperature = 20,
        max_temperature = 100,
        heat_capacity = "2kJ",
        base_color = {0.6, 0.6, 0.9},
        flow_color = {0.7, 0.7, 0.95},
        auto_barrel = false
    }
})

-- Add Recipes
data:extend({
    {
        type = "recipe",
        name = "nutrient-solution-from-spoilage",
        icon = "__space-age__/graphics/icons/nutrients-from-spoilage.png",
        category = "organic-or-chemistry",
        subgroup = "agriculture-processes",
        order = "c[nutrient-solution]-a[nutrient-solution-from-spoilage]",
        enabled = false,
        allow_productivity = true,
        energy_required = 2,
        ingredients = {
            {
                type = "item",
                name = "spoilage",
                amount = 10
            }, {
                type = "fluid",
                name = "water",
                amount = 10
            }
        },
        results = {
            {
                type = "fluid",
                name = "nutrient-solution",
                amount = 10
            }
        },
        crafting_machine_tint = {
            primary = {
                r = 0.8,
                g = 0.9,
                b = 1,
                a = 1.000
            },
            secondary = {
                r = 0.5,
                g = 0.5,
                b = 0.8,
                a = 1.000
            }
        }
    }
})

-- Update technologies
table.insert(data.raw.technology["agriculture"].effects, {
    type = "unlock-recipe",
    recipe = "nutrient-solution-from-spoilage"
})

-- Disable vanilla recipes
data.raw.recipe["nutrients-from-spoilage"].enabled = false
