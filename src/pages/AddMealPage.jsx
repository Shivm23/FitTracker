import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, ArrowLeft } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { useAuth } from '../contexts/AuthContext';
import { format } from 'date-fns';

export default function AddMealPage() {
  const navigate = useNavigate();
  const { user } = useAuth();
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState([]);
  const [loading, setLoading] = useState(false);
  const [showCustomForm, setShowCustomForm] = useState(false);
  const [selectedMeal, setSelectedMeal] = useState(null);
  const [mealType, setMealType] = useState('breakfast');
  const [servings, setServings] = useState(1);

  const [customMeal, setCustomMeal] = useState({
    name: '',
    calories: '',
    protein: '',
    carbs: '',
    fat: '',
    serving_size: '100',
    serving_unit: 'g',
  });

  async function handleSearch(e) {
    e.preventDefault();
    if (!searchQuery.trim()) return;

    setLoading(true);
    try {
      const { data, error } = await supabase
        .from('meals')
        .select('*')
        .eq('user_id', user.id)
        .ilike('name', `%${searchQuery}%`)
        .limit(20);

      if (error) throw error;
      setSearchResults(data || []);
    } catch (error) {
      console.error('Error searching meals:', error);
    } finally {
      setLoading(false);
    }
  }

  async function handleAddMeal(meal) {
    setSelectedMeal(meal);
  }

  async function handleSubmit(e) {
    e.preventDefault();

    try {
      let mealId = selectedMeal?.id;

      if (showCustomForm) {
        const { data: newMeal, error: mealError } = await supabase
          .from('meals')
          .insert({
            user_id: user.id,
            name: customMeal.name,
            calories: parseFloat(customMeal.calories),
            protein: parseFloat(customMeal.protein),
            carbs: parseFloat(customMeal.carbs),
            fat: parseFloat(customMeal.fat),
            serving_size: parseFloat(customMeal.serving_size),
            serving_unit: customMeal.serving_unit,
          })
          .select()
          .single();

        if (mealError) throw mealError;
        mealId = newMeal.id;
      }

      const { error: logError } = await supabase.from('meal_logs').insert({
        user_id: user.id,
        meal_id: mealId,
        meal_type: mealType,
        servings: parseFloat(servings),
        date: format(new Date(), 'yyyy-MM-dd'),
      });

      if (logError) throw logError;

      navigate('/');
    } catch (error) {
      console.error('Error adding meal:', error);
      alert('Failed to add meal. Please try again.');
    }
  }

  if (selectedMeal) {
    return (
      <div className="max-w-2xl mx-auto p-4 sm:p-6 lg:p-8">
        <button
          onClick={() => setSelectedMeal(null)}
          className="flex items-center text-gray-600 dark:text-gray-400 mb-4"
        >
          <ArrowLeft className="w-5 h-5 mr-2" />
          Back
        </button>

        <div className="card">
          <h2 className="text-2xl font-bold mb-4">Add Meal</h2>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="p-4 bg-gray-50 dark:bg-gray-700 rounded-lg">
              <h3 className="font-semibold text-lg">{selectedMeal.name}</h3>
              {selectedMeal.brand && (
                <p className="text-sm text-gray-600 dark:text-gray-400">{selectedMeal.brand}</p>
              )}
              <div className="mt-2 text-sm">
                <span className="font-semibold text-primary">{selectedMeal.calories} cal</span> per {selectedMeal.serving_size}{selectedMeal.serving_unit}
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium mb-2">Meal Type</label>
              <select
                value={mealType}
                onChange={(e) => setMealType(e.target.value)}
                className="input"
                required
              >
                <option value="breakfast">Breakfast</option>
                <option value="lunch">Lunch</option>
                <option value="dinner">Dinner</option>
                <option value="snack">Snack</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium mb-2">Servings</label>
              <input
                type="number"
                step="0.1"
                min="0.1"
                value={servings}
                onChange={(e) => setServings(e.target.value)}
                className="input"
                required
              />
            </div>

            <div className="p-4 bg-primary/10 rounded-lg">
              <div className="text-sm font-medium mb-2">Nutritional Information</div>
              <div className="grid grid-cols-2 gap-2 text-sm">
                <div>Calories: <span className="font-semibold">{Math.round(selectedMeal.calories * servings)}</span></div>
                <div>Protein: <span className="font-semibold">{Math.round(selectedMeal.protein * servings)}g</span></div>
                <div>Carbs: <span className="font-semibold">{Math.round(selectedMeal.carbs * servings)}g</span></div>
                <div>Fat: <span className="font-semibold">{Math.round(selectedMeal.fat * servings)}g</span></div>
              </div>
            </div>

            <button type="submit" className="btn-primary w-full">
              Add to Diary
            </button>
          </form>
        </div>
      </div>
    );
  }

  if (showCustomForm) {
    return (
      <div className="max-w-2xl mx-auto p-4 sm:p-6 lg:p-8">
        <button
          onClick={() => setShowCustomForm(false)}
          className="flex items-center text-gray-600 dark:text-gray-400 mb-4"
        >
          <ArrowLeft className="w-5 h-5 mr-2" />
          Back
        </button>

        <div className="card">
          <h2 className="text-2xl font-bold mb-4">Create Custom Meal</h2>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium mb-2">Meal Name</label>
              <input
                type="text"
                value={customMeal.name}
                onChange={(e) => setCustomMeal({ ...customMeal, name: e.target.value })}
                className="input"
                placeholder="e.g., Chicken Breast"
                required
              />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium mb-2">Serving Size</label>
                <input
                  type="number"
                  step="0.1"
                  value={customMeal.serving_size}
                  onChange={(e) => setCustomMeal({ ...customMeal, serving_size: e.target.value })}
                  className="input"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Unit</label>
                <select
                  value={customMeal.serving_unit}
                  onChange={(e) => setCustomMeal({ ...customMeal, serving_unit: e.target.value })}
                  className="input"
                >
                  <option value="g">grams (g)</option>
                  <option value="ml">milliliters (ml)</option>
                  <option value="oz">ounces (oz)</option>
                  <option value="cup">cup</option>
                  <option value="piece">piece</option>
                </select>
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium mb-2">Calories</label>
              <input
                type="number"
                step="0.1"
                value={customMeal.calories}
                onChange={(e) => setCustomMeal({ ...customMeal, calories: e.target.value })}
                className="input"
                placeholder="0"
                required
              />
            </div>

            <div className="grid grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium mb-2">Protein (g)</label>
                <input
                  type="number"
                  step="0.1"
                  value={customMeal.protein}
                  onChange={(e) => setCustomMeal({ ...customMeal, protein: e.target.value })}
                  className="input"
                  placeholder="0"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Carbs (g)</label>
                <input
                  type="number"
                  step="0.1"
                  value={customMeal.carbs}
                  onChange={(e) => setCustomMeal({ ...customMeal, carbs: e.target.value })}
                  className="input"
                  placeholder="0"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Fat (g)</label>
                <input
                  type="number"
                  step="0.1"
                  value={customMeal.fat}
                  onChange={(e) => setCustomMeal({ ...customMeal, fat: e.target.value })}
                  className="input"
                  placeholder="0"
                  required
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium mb-2">Meal Type</label>
              <select
                value={mealType}
                onChange={(e) => setMealType(e.target.value)}
                className="input"
                required
              >
                <option value="breakfast">Breakfast</option>
                <option value="lunch">Lunch</option>
                <option value="dinner">Dinner</option>
                <option value="snack">Snack</option>
              </select>
            </div>

            <button type="submit" className="btn-primary w-full">
              Create & Add to Diary
            </button>
          </form>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-2xl mx-auto p-4 sm:p-6 lg:p-8">
      <button
        onClick={() => navigate('/')}
        className="flex items-center text-gray-600 dark:text-gray-400 mb-4"
      >
        <ArrowLeft className="w-5 h-5 mr-2" />
        Back
      </button>

      <div className="card">
        <h2 className="text-2xl font-bold mb-4">Add Meal</h2>

        <form onSubmit={handleSearch} className="mb-6">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="input pl-10"
              placeholder="Search your meals..."
            />
          </div>
          <button type="submit" className="btn-primary w-full mt-2">
            Search
          </button>
        </form>

        <button
          onClick={() => setShowCustomForm(true)}
          className="btn-secondary w-full mb-6"
        >
          Create Custom Meal
        </button>

        {loading && (
          <div className="text-center py-8">
            <div className="w-12 h-12 border-4 border-primary border-t-transparent rounded-full animate-spin mx-auto"></div>
          </div>
        )}

        {!loading && searchResults.length > 0 && (
          <div className="space-y-3">
            <h3 className="font-semibold text-sm text-gray-600 dark:text-gray-400">Search Results</h3>
            {searchResults.map((meal) => (
              <button
                key={meal.id}
                onClick={() => handleAddMeal(meal)}
                className="w-full text-left p-4 bg-gray-50 dark:bg-gray-700 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-600 transition-colors"
              >
                <div className="flex justify-between">
                  <div>
                    <div className="font-semibold">{meal.name}</div>
                    {meal.brand && (
                      <div className="text-sm text-gray-600 dark:text-gray-400">{meal.brand}</div>
                    )}
                  </div>
                  <div className="text-right">
                    <div className="font-bold text-primary">{meal.calories} cal</div>
                    <div className="text-xs text-gray-600 dark:text-gray-400">
                      per {meal.serving_size}{meal.serving_unit}
                    </div>
                  </div>
                </div>
              </button>
            ))}
          </div>
        )}

        {!loading && searchQuery && searchResults.length === 0 && (
          <div className="text-center py-8 text-gray-500 dark:text-gray-400">
            No meals found. Try creating a custom meal instead.
          </div>
        )}
      </div>
    </div>
  );
}
