//
//  Constant.swift
//  Recipes
//
//  Created by Aser Eid on 13/08/2024.
//

import Foundation
class Constant {
    static let appKey = "bce211ea96b9c56573acd00b2b8e7030"
    static let appId = "6b9f094f"
    static let baseURL = "https://api.edamam.com/api/recipes/v2?type=public&app_id=\(appId)&app_key=\(appKey)"
    static let mainCategories = ["All" , "health", "diet", "mealType", "cuisineType"]
    static let healthSubCategories = [
            "alcohol-cocktail",
            "alcohol-free",
            "celery-free",
            "crustacean-free",
            "dairy-free",
            "DASH",
            "egg-free",
            "fish-free",
            "fodmap-free",
            "gluten-free",
            "immuno-supportive",
            "keto-friendly",
            "kidney-friendly",
            "kosher",
            "low-fat-abs",
            "low-potassium",
            "low-sugar",
            "lupine-free",
            "Mediterranean",
            "mollusk-free",
            "mustard-free",
            "no-oil-added",
            "paleo",
            "peanut-free",
            "pescatarian",
            "pork-free",
            "red-meat-free",
            "sesame-free",
            "shellfish-free",
            "soy-free",
            "sugar-conscious",
            "sulfite-free",
            "tree-nut-free",
            "vegan",
            "vegetarian",
            "wheat-free"
        ]
    static let dietaryOptions = [
            "balanced",
            "high-fiber",
            "high-protein",
            "low-carb",
            "low-fat",
            "low-sodium"
        ]
    static let fields = "&field=source&field=image&field=label"
    static let mealTypes = ["Breakfast", "Dinner", "Lunch", "Snack", "Teatime"]
    static let cuisines = [
        "American",
        "Asian",
        "British",
        "Caribbean",
        "Central Europe",
        "Chinese",
        "Eastern Europe",
        "French",
        "Indian",
        "Italian",
        "Japanese",
        "Kosher",
        "Mediterranean",
        "Mexican",
        "Middle Eastern",
        "Nordic",
        "South American",
        "South East Asian"
    ]
}
