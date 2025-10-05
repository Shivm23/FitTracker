import React, { useEffect, useState } from 'react';
import { Plus, TrendingUp, Flame, Activity } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { useAuth } from '../contexts/AuthContext';
import { calculateBMR, calculateTDEE, calculateCalorieGoal, calculateMacros } from '../utils/calculations';
import { format } from 'date-fns';
import { useNavigate } from 'react-router-dom';

export default function HomePage() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [profile, setProfile] = useState(null);
  const [todayMeals, setTodayMeals] = useState([]);
  const [todayActivities, setTodayActivities] = useState([]);
  const [loading, setLoading] = useState(true);

  const today = format(new Date(), 'yyyy-MM-dd');

  useEffect(() => {
    if (user) {
      loadData();
    }
  }, [user]);

  async function loadData() {
    try {
      const [profileRes, mealsRes, activitiesRes] = await Promise.all([
        supabase.from('users').select('*').eq('id', user.id).maybeSingle(),
        supabase
          .from('meal_logs')
          .select('*, meals(*)')
          .eq('user_id', user.id)
          .eq('date', today),
        supabase
          .from('activities')
          .select('*')
          .eq('user_id', user.id)
          .eq('date', today),
      ]);

      if (profileRes.data) {
        setProfile(profileRes.data);
      }
      setTodayMeals(mealsRes.data || []);
      setTodayActivities(activitiesRes.data || []);
    } catch (error) {
      console.error('Error loading data:', error);
    } finally {
      setLoading(false);
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="w-16 h-16 border-4 border-primary border-t-transparent rounded-full animate-spin mx-auto"></div>
          <p className="mt-4 text-gray-600 dark:text-gray-400">Loading...</p>
        </div>
      </div>
    );
  }

  if (!profile) {
    return (
      <div className="max-w-2xl mx-auto p-6">
        <div className="card text-center">
          <h2 className="text-2xl font-bold mb-4">Welcome to NutriTracker!</h2>
          <p className="text-gray-600 dark:text-gray-400 mb-6">
            Complete your profile to start tracking your nutrition
          </p>
          <button
            onClick={() => navigate('/onboarding')}
            className="btn-primary"
          >
            Get Started
          </button>
        </div>
      </div>
    );
  }

  const bmr = calculateBMR(profile.weight, profile.height, profile.age, profile.gender);
  const tdee = calculateTDEE(bmr, profile.activity_level);
  const calorieGoal = calculateCalorieGoal(tdee, profile.goal, profile.goal_rate);
  const macros = calculateMacros(calorieGoal);

  const consumedCalories = todayMeals.reduce((sum, log) => {
    return sum + (log.meals.calories * log.servings);
  }, 0);

  const consumedProtein = todayMeals.reduce((sum, log) => {
    return sum + (log.meals.protein * log.servings);
  }, 0);

  const consumedCarbs = todayMeals.reduce((sum, log) => {
    return sum + (log.meals.carbs * log.servings);
  }, 0);

  const consumedFat = todayMeals.reduce((sum, log) => {
    return sum + (log.meals.fat * log.servings);
  }, 0);

  const burnedCalories = todayActivities.reduce((sum, activity) => {
    return sum + activity.calories_burned;
  }, 0);

  const netCalories = consumedCalories - burnedCalories;
  const remainingCalories = calorieGoal - netCalories;

  return (
    <div className="max-w-7xl mx-auto p-4 sm:p-6 lg:p-8 space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">Today</h1>
          <p className="text-gray-600 dark:text-gray-400">{format(new Date(), 'EEEE, MMMM d')}</p>
        </div>
      </div>

      {/* Calorie Dashboard */}
      <div className="card bg-gradient-to-br from-instagram-pink/10 to-instagram-purple/10 border-2 border-primary/20">
        <div className="text-center mb-6">
          <div className="text-5xl font-bold bg-gradient-to-r from-instagram-pink to-instagram-orange bg-clip-text text-transparent">
            {Math.round(remainingCalories)}
          </div>
          <div className="text-sm text-gray-600 dark:text-gray-400 mt-1">
            calories remaining
          </div>
        </div>

        <div className="grid grid-cols-3 gap-4 text-center">
          <div>
            <div className="text-2xl font-bold text-secondary">{Math.round(consumedCalories)}</div>
            <div className="text-xs text-gray-600 dark:text-gray-400">consumed</div>
          </div>
          <div>
            <div className="text-2xl font-bold text-tertiary">{Math.round(burnedCalories)}</div>
            <div className="text-xs text-gray-600 dark:text-gray-400">burned</div>
          </div>
          <div>
            <div className="text-2xl font-bold text-primary">{calorieGoal}</div>
            <div className="text-xs text-gray-600 dark:text-gray-400">goal</div>
          </div>
        </div>

        <div className="mt-6">
          <div className="relative pt-1">
            <div className="overflow-hidden h-4 text-xs flex rounded-full bg-gray-200 dark:bg-gray-700">
              <div
                style={{ width: `${Math.min((netCalories / calorieGoal) * 100, 100)}%` }}
                className="shadow-none flex flex-col text-center whitespace-nowrap text-white justify-center bg-gradient-to-r from-instagram-pink to-instagram-orange transition-all"
              ></div>
            </div>
          </div>
        </div>
      </div>

      {/* Macros */}
      <div className="grid grid-cols-3 gap-4">
        <div className="card text-center">
          <div className="text-2xl font-bold text-primary">{Math.round(consumedProtein)}g</div>
          <div className="text-sm text-gray-600 dark:text-gray-400">Protein</div>
          <div className="text-xs text-gray-500 dark:text-gray-500">of {macros.protein}g</div>
        </div>
        <div className="card text-center">
          <div className="text-2xl font-bold text-secondary">{Math.round(consumedCarbs)}g</div>
          <div className="text-sm text-gray-600 dark:text-gray-400">Carbs</div>
          <div className="text-xs text-gray-500 dark:text-gray-500">of {macros.carbs}g</div>
        </div>
        <div className="card text-center">
          <div className="text-2xl font-bold text-tertiary">{Math.round(consumedFat)}g</div>
          <div className="text-sm text-gray-600 dark:text-gray-400">Fat</div>
          <div className="text-xs text-gray-500 dark:text-gray-500">of {macros.fat}g</div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-2 gap-4">
        <button
          onClick={() => navigate('/meals/add')}
          className="card hover:shadow-lg transition-shadow flex items-center justify-center space-x-2 p-6"
        >
          <Plus className="w-6 h-6 text-primary" />
          <span className="font-semibold">Add Meal</span>
        </button>
        <button
          onClick={() => navigate('/activities/add')}
          className="card hover:shadow-lg transition-shadow flex items-center justify-center space-x-2 p-6"
        >
          <Activity className="w-6 h-6 text-secondary" />
          <span className="font-semibold">Add Activity</span>
        </button>
      </div>

      {/* Today's Meals */}
      <div className="card">
        <h2 className="text-xl font-bold mb-4 flex items-center">
          <Flame className="w-5 h-5 mr-2 text-primary" />
          Today's Meals
        </h2>
        {todayMeals.length === 0 ? (
          <p className="text-center text-gray-500 dark:text-gray-400 py-8">
            No meals logged yet today
          </p>
        ) : (
          <div className="space-y-3">
            {todayMeals.map((log) => (
              <div key={log.id} className="flex justify-between items-center p-3 bg-gray-50 dark:bg-gray-700 rounded-lg">
                <div>
                  <div className="font-semibold">{log.meals.name}</div>
                  <div className="text-sm text-gray-600 dark:text-gray-400">
                    {log.meal_type.charAt(0).toUpperCase() + log.meal_type.slice(1)} • {log.servings} serving(s)
                  </div>
                </div>
                <div className="text-right">
                  <div className="font-bold text-primary">{Math.round(log.meals.calories * log.servings)} cal</div>
                  <div className="text-xs text-gray-600 dark:text-gray-400">
                    P: {Math.round(log.meals.protein * log.servings)}g •
                    C: {Math.round(log.meals.carbs * log.servings)}g •
                    F: {Math.round(log.meals.fat * log.servings)}g
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Today's Activities */}
      <div className="card">
        <h2 className="text-xl font-bold mb-4 flex items-center">
          <TrendingUp className="w-5 h-5 mr-2 text-secondary" />
          Today's Activities
        </h2>
        {todayActivities.length === 0 ? (
          <p className="text-center text-gray-500 dark:text-gray-400 py-8">
            No activities logged yet today
          </p>
        ) : (
          <div className="space-y-3">
            {todayActivities.map((activity) => (
              <div key={activity.id} className="flex justify-between items-center p-3 bg-gray-50 dark:bg-gray-700 rounded-lg">
                <div>
                  <div className="font-semibold">{activity.name}</div>
                  <div className="text-sm text-gray-600 dark:text-gray-400">
                    {activity.duration_minutes} minutes
                  </div>
                </div>
                <div className="text-right">
                  <div className="font-bold text-secondary">{Math.round(activity.calories_burned)} cal</div>
                  <div className="text-xs text-gray-600 dark:text-gray-400">
                    MET: {activity.met_value}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
