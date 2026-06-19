-- Kept for pipe_covers reference used by biolab and captive-biter-spawner below
local biochamber = data.raw["assembling-machine"]["biochamber"]

-- Update biolab to take nutrient-solution as fuel
if settings.startup["biolab-use-nutrient-solution"].value then
    local flow_direction = settings.startup["nutrient-solution-flow-through"].value and "input-output" or "input"

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
                east = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture.east),
                south = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture.south),
                west = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture.west)
            },
            pipe_picture_frozen = {
                north = table.deepcopy(data.raw["assembling-machine"]["electromagnetic-plant"].fluid_boxes[1].pipe_picture_frozen.north),
                east = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture_frozen.east),
                south = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture_frozen.south),
                west = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture_frozen.west)
            },
            pipe_covers = biochamber.fluid_boxes[1].pipe_covers,
            pipe_connections = {
                {flow_direction = flow_direction, direction = defines.direction.west, position = {-2, 0}},
                {flow_direction = flow_direction, direction = defines.direction.east, position = {2, 0}},
                {flow_direction = flow_direction, direction = defines.direction.south, position = {0, 2}},
                {flow_direction = flow_direction, direction = defines.direction.north, position = {0, -2}}
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
    local flow_direction = settings.startup["nutrient-solution-flow-through"].value and "input-output" or "input"

    local captive_biter_spawner = data.raw["assembling-machine"]["captive-biter-spawner"]
    captive_biter_spawner.energy_source = {
        type = "fluid",
        fluid_box = {
            volume = 20,
            filter = "nutrient-solution",
            minimum_temperature = 15,
            maximum_temperature = 100,
            pipe_picture = {
                north = table.deepcopy(data.raw["assembling-machine"]["electromagnetic-plant"].fluid_boxes[1].pipe_picture.north),
                east = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture.east),
                south = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture.south),
                west = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture.west)
            },
            pipe_picture_frozen = {
                north = table.deepcopy(data.raw["assembling-machine"]["electromagnetic-plant"].fluid_boxes[1].pipe_picture_frozen.north),
                east = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture_frozen.east),
                south = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture_frozen.south),
                west = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture_frozen.west)
            },
            pipe_covers = biochamber.fluid_boxes[1].pipe_covers,
            pipe_connections = {
                {flow_direction = flow_direction, direction = defines.direction.west, position = {-2, 0}},
                {flow_direction = flow_direction, direction = defines.direction.east, position = {2, 0}},
                {flow_direction = flow_direction, direction = defines.direction.south, position = {0, 2}},
                {flow_direction = flow_direction, direction = defines.direction.north, position = {0, -2}}
            },
            secondary_draw_orders = { north = -1 },
        },
        burns_fluid = true,
        emissions_per_minute = captive_biter_spawner.energy_source.emissions_per_minute,
    }
end
