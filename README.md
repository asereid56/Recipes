# 🍽️ Recipe Search iOS Application

## Overview
The Recipe Search iOS application allows users to search for recipes based on specific ingredients or recipe names. Users can filter the results by various health preferences. Each recipe displays key information, and users can navigate to a detailed view for more specifics.

## Features

### 🔍 Search
- **Search Bar:** Users can enter a recipe name or food ingredient in the search bar.
- **Recipe List View:** Upon tapping the search button, a list view displays with the following data for each recipe:
  - 📷 Recipe’s image
  - 📝 Recipe’s title
  - 🏷️ Source
- **Health Filters:** Users can select from health filters (Low Sugar, Dairy-Free, Vegan). Only recipes matching the selected filter will be shown.
- **"ALL" Tab:** Selecting the "ALL" tab in the filters bar displays all recipes without filtration.
- **Scrollable Filters:** The filters section is scrollable horizontally, allowing users to see and select all available filters.
- **Pagination:** The application loads the next page of results when the user scrolls to the bottom of the list, if more recipes are available.
- **Initial State:** No search results are displayed when the application launches until a search query is entered.

### 📄 Details
- **Recipe Details:** When a user selects a recipe, a new screen displays with:
  - 📷 Recipe’s image
  - 📝 Recipe title
  - 🔢 Calories and Total Weight
  - ⏲️ Total Time
- **Navigation:** Users can easily return to the main screen from the details view.

## 🛠️ Technologies Used
- **MVVM:** Design pattern used for separating concerns.
- **Combine:** Framework for handling asynchronous events.
- **Alamofire:** Networking library for making API requests.
- **Reachability:** To monitor network connectivity.
- **Kingfisher:** Library for downloading and caching images.
