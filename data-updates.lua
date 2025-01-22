-- Update all recipes using nutrients to use nutrient-solution
for _,recipe in pairs(data.raw.recipe) do
    if recipe.ingredients then
	    for _,ingredient in pairs(recipe.ingredients) do
            if ingredient.name == "nutrients" then
                ingredient.name = "nutrient-solution"
                ingredient.type = "fluid"
                ingredient.amount = (ingredient.amount or 1) * 2
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
                result.amount = (result.amount or 1) * 2
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
