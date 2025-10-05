import React, { useEffect, useState } from 'react';
import { ChevronLeft, ChevronRight, Trash2 } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { useAuth } from '../contexts/AuthContext';
import { format, startOfMonth, endOfMonth, eachDayOfInterval, isSameDay, addMonths, subMonths } from 'date-fns';

export default function DiaryPage() {
  const { user } = useAuth();
  const [currentDate, setCurrentDate] = useState(new Date());
  const [selectedDate, setSelectedDate] = useState(new Date());
  const [monthLogs, setMonthLogs] = useState([]);
  const [selectedDayMeals, setSelectedDayMeals] = useState([]);
  const [selectedDayActivities, setSelectedDayActivities] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (user) {
      loadMonthData();
    }
  }, [user, currentDate]);

  useEffect(() => {
    if (user) {
      loadDayData();
    }
  }, [user, selectedDate]);

  async function loadMonthData() {
    try {
      const start = format(startOfMonth(currentDate), 'yyyy-MM-dd');
      const end = format(endOfMonth(currentDate), 'yyyy-MM-dd');

      const { data, error } = await supabase
        .from('meal_logs')
        .select('date')
        .eq('user_id', user.id)
        .gte('date', start)
        .lte('date', end);

      if (error) throw error;
      setMonthLogs(data || []);
    } catch (error) {
      console.error('Error loading month data:', error);
    } finally {
      setLoading(false);
    }
  }

  async function loadDayData() {
    try {
      const dateStr = format(selectedDate, 'yyyy-MM-dd');

      const [mealsRes, activitiesRes] = await Promise.all([
        supabase
          .from('meal_logs')
          .select('*, meals(*)')
          .eq('user_id', user.id)
          .eq('date', dateStr)
          .order('created_at', { ascending: false }),
        supabase
          .from('activities')
          .select('*')
          .eq('user_id', user.id)
          .eq('date', dateStr)
          .order('created_at', { ascending: false }),
      ]);

      setSelectedDayMeals(mealsRes.data || []);
      setSelectedDayActivities(activitiesRes.data || []);
    } catch (error) {
      console.error('Error loading day data:', error);
    }
  }

  async function handleDeleteMeal(id) {
    if (!confirm('Delete this meal?')) return;

    try {
      const { error } = await supabase.from('meal_logs').delete().eq('id', id);
      if (error) throw error;
      loadDayData();
    } catch (error) {
      console.error('Error deleting meal:', error);
    }
  }

  async function handleDeleteActivity(id) {
    if (!confirm('Delete this activity?')) return;

    try {
      const { error } = await supabase.from('activities').delete().eq('id', id);
      if (error) throw error;
      loadDayData();
    } catch (error) {
      console.error('Error deleting activity:', error);
    }
  }

  const daysInMonth = eachDayOfInterval({
    start: startOfMonth(currentDate),
    end: endOfMonth(currentDate),
  });

  const hasLogsOnDay = (day) => {
    const dayStr = format(day, 'yyyy-MM-dd');
    return monthLogs.some((log) => log.date === dayStr);
  };

  const totalCalories = selectedDayMeals.reduce((sum, log) => {
    return sum + log.meals.calories * log.servings;
  }, 0);

  const totalBurned = selectedDayActivities.reduce((sum, activity) => {
    return sum + activity.calories_burned;
  }, 0);

  const netCalories = totalCalories - totalBurned;

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="w-16 h-16 border-4 border-primary border-t-transparent rounded-full animate-spin"></div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto p-4 sm:p-6 lg:p-8 space-y-6">
      <h1 className="text-3xl font-bold">Diary</h1>

      {/* Calendar */}
      <div className="card">
        <div className="flex justify-between items-center mb-4">
          <button
            onClick={() => setCurrentDate(subMonths(currentDate, 1))}
            className="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg"
          >
            <ChevronLeft className="w-5 h-5" />
          </button>
          <h2 className="text-xl font-bold">{format(currentDate, 'MMMM yyyy')}</h2>
          <button
            onClick={() => setCurrentDate(addMonths(currentDate, 1))}
            className="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg"
          >
            <ChevronRight className="w-5 h-5" />
          </button>
        </div>

        <div className="grid grid-cols-7 gap-2">
          {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) => (
            <div key={day} className="text-center text-sm font-semibold text-gray-600 dark:text-gray-400 py-2">
              {day}
            </div>
          ))}
          {daysInMonth.map((day) => {
            const isSelected = isSameDay(day, selectedDate);
            const hasLogs = hasLogsOnDay(day);
            const isToday = isSameDay(day, new Date());

            return (
              <button
                key={day.toString()}
                onClick={() => setSelectedDate(day)}
                className={`aspect-square p-2 rounded-lg text-sm transition-colors relative ${
                  isSelected
                    ? 'bg-primary text-white font-bold'
                    : isToday
                    ? 'bg-primary/20 font-semibold'
                    : 'hover:bg-gray-100 dark:hover:bg-gray-700'
                }`}
              >
                {format(day, 'd')}
                {hasLogs && (
                  <div className="absolute bottom-1 left-1/2 transform -translate-x-1/2 w-1 h-1 bg-secondary rounded-full"></div>
                )}
              </button>
            );
          })}
        </div>
      </div>

      {/* Selected Day Summary */}
      <div className="card bg-gradient-to-br from-instagram-pink/10 to-instagram-purple/10">
        <h2 className="text-xl font-bold mb-4">{format(selectedDate, 'EEEE, MMMM d, yyyy')}</h2>
        <div className="grid grid-cols-3 gap-4 text-center">
          <div>
            <div className="text-2xl font-bold text-primary">{Math.round(totalCalories)}</div>
            <div className="text-sm text-gray-600 dark:text-gray-400">Consumed</div>
          </div>
          <div>
            <div className="text-2xl font-bold text-secondary">{Math.round(totalBurned)}</div>
            <div className="text-sm text-gray-600 dark:text-gray-400">Burned</div>
          </div>
          <div>
            <div className="text-2xl font-bold text-tertiary">{Math.round(netCalories)}</div>
            <div className="text-sm text-gray-600 dark:text-gray-400">Net</div>
          </div>
        </div>
      </div>

      {/* Meals */}
      <div className="card">
        <h2 className="text-xl font-bold mb-4">Meals</h2>
        {selectedDayMeals.length === 0 ? (
          <p className="text-center text-gray-500 dark:text-gray-400 py-8">
            No meals logged for this day
          </p>
        ) : (
          <div className="space-y-3">
            {selectedDayMeals.map((log) => (
              <div
                key={log.id}
                className="flex justify-between items-start p-3 bg-gray-50 dark:bg-gray-700 rounded-lg"
              >
                <div className="flex-1">
                  <div className="font-semibold">{log.meals.name}</div>
                  <div className="text-sm text-gray-600 dark:text-gray-400">
                    {log.meal_type.charAt(0).toUpperCase() + log.meal_type.slice(1)} • {log.servings} serving(s)
                  </div>
                  <div className="text-sm mt-1">
                    <span className="font-bold text-primary">{Math.round(log.meals.calories * log.servings)} cal</span>
                    {' • '}
                    P: {Math.round(log.meals.protein * log.servings)}g
                    {' • '}
                    C: {Math.round(log.meals.carbs * log.servings)}g
                    {' • '}
                    F: {Math.round(log.meals.fat * log.servings)}g
                  </div>
                </div>
                <button
                  onClick={() => handleDeleteMeal(log.id)}
                  className="p-2 hover:bg-red-100 dark:hover:bg-red-900/20 rounded-lg transition-colors"
                >
                  <Trash2 className="w-4 h-4 text-red-500" />
                </button>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Activities */}
      <div className="card">
        <h2 className="text-xl font-bold mb-4">Activities</h2>
        {selectedDayActivities.length === 0 ? (
          <p className="text-center text-gray-500 dark:text-gray-400 py-8">
            No activities logged for this day
          </p>
        ) : (
          <div className="space-y-3">
            {selectedDayActivities.map((activity) => (
              <div
                key={activity.id}
                className="flex justify-between items-start p-3 bg-gray-50 dark:bg-gray-700 rounded-lg"
              >
                <div className="flex-1">
                  <div className="font-semibold">{activity.name}</div>
                  <div className="text-sm text-gray-600 dark:text-gray-400">
                    {activity.duration_minutes} minutes • MET: {activity.met_value}
                  </div>
                  <div className="text-sm mt-1">
                    <span className="font-bold text-secondary">{Math.round(activity.calories_burned)} cal burned</span>
                  </div>
                </div>
                <button
                  onClick={() => handleDeleteActivity(activity.id)}
                  className="p-2 hover:bg-red-100 dark:hover:bg-red-900/20 rounded-lg transition-colors"
                >
                  <Trash2 className="w-4 h-4 text-red-500" />
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
