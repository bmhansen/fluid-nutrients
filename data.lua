-- Add New Fluids
data:extend({
    {
        type = "fluid",
        name = "nutrient-solution",
        icon = "__fluid-nutrients__/gfx/nutrient-solution.png",
        subgroup = "fluid",
        order = "b[new-fluid]-d[gleba]-a[nutrient-solution]",
        default_temperature = 15,
        max_temperature = 100,
        fuel_value = "1MJ",
        base_color = {0.6, 0.6, 0.9},
        flow_color = {0.7, 0.7, 0.95},
        auto_barrel = true
    }
})
