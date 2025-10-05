import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { useAuth } from '../contexts/AuthContext';
import { calculateCaloriesBurned } from '../utils/calculations';
import { format } from 'date-fns';

const COMMON_ACTIVITIES = [
  { name: 'Walking (moderate pace)', met: 3.5 },
  { name: 'Running (6 mph)', met: 9.8 },
  { name: 'Cycling (moderate)', met: 6.8 },
  { name: 'Swimming', met: 7.0 },
  { name: 'Yoga', met: 2.5 },
  { name: 'Weight Training', met: 6.0 },
  { name: 'Dancing', met: 4.5 },
  { name: 'Hiking', met: 6.0 },
  { name: 'Basketball', met: 6.5 },
  { name: 'Soccer', met: 7.0 },
];

export default function AddActivityPage() {
  const navigate = useNavigate();
  const { user } = useAuth();
  const [userWeight, setUserWeight] = useState(70);
  const [activity, setActivity] = useState({
    name: '',
    duration_minutes: 30,
    met_value: 3.5,
  });
  const [loading, setLoading] = useState(false);

  React.useEffect(() => {
    loadUserWeight();
  }, [user]);

  async function loadUserWeight() {
    const { data } = await supabase
      .from('users')
      .select('weight')
      .eq('id', user.id)
      .maybeSingle();

    if (data) {
      setUserWeight(data.weight);
    }
  }

  function handleActivitySelect(commonActivity) {
    setActivity({
      ...activity,
      name: commonActivity.name,
      met_value: commonActivity.met,
    });
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setLoading(true);

    try {
      const caloriesBurned = calculateCaloriesBurned(
        activity.met_value,
        userWeight,
        activity.duration_minutes
      );

      const { error } = await supabase.from('activities').insert({
        user_id: user.id,
        name: activity.name,
        duration_minutes: activity.duration_minutes,
        calories_burned: caloriesBurned,
        met_value: activity.met_value,
        date: format(new Date(), 'yyyy-MM-dd'),
      });

      if (error) throw error;

      navigate('/');
    } catch (error) {
      console.error('Error adding activity:', error);
      alert('Failed to add activity. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  const estimatedCalories = calculateCaloriesBurned(
    activity.met_value,
    userWeight,
    activity.duration_minutes
  );

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
        <h2 className="text-2xl font-bold mb-6">Add Activity</h2>

        <div className="mb-6">
          <h3 className="text-sm font-medium mb-3">Common Activities</h3>
          <div className="grid grid-cols-2 gap-2">
            {COMMON_ACTIVITIES.map((item) => (
              <button
                key={item.name}
                onClick={() => handleActivitySelect(item)}
                className={`p-3 rounded-lg text-left text-sm transition-colors ${
                  activity.name === item.name
                    ? 'bg-primary text-white'
                    : 'bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600'
                }`}
              >
                <div className="font-semibold">{item.name}</div>
                <div className="text-xs opacity-75">MET: {item.met}</div>
              </button>
            ))}
          </div>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium mb-2">Activity Name</label>
            <input
              type="text"
              value={activity.name}
              onChange={(e) => setActivity({ ...activity, name: e.target.value })}
              className="input"
              placeholder="e.g., Morning jog"
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium mb-2">Duration (minutes)</label>
            <input
              type="number"
              min="1"
              value={activity.duration_minutes}
              onChange={(e) => setActivity({ ...activity, duration_minutes: parseInt(e.target.value) })}
              className="input"
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium mb-2">
              MET Value (Metabolic Equivalent)
            </label>
            <input
              type="number"
              step="0.1"
              min="1"
              value={activity.met_value}
              onChange={(e) => setActivity({ ...activity, met_value: parseFloat(e.target.value) })}
              className="input"
              required
            />
            <p className="text-xs text-gray-500 mt-1">
              Higher MET = more intense activity (Light: 2-4, Moderate: 4-6, Vigorous: 6+)
            </p>
          </div>

          <div className="p-4 bg-secondary/10 rounded-lg">
            <div className="text-sm font-medium mb-1">Estimated Calories Burned</div>
            <div className="text-3xl font-bold text-secondary">
              {Math.round(estimatedCalories)} cal
            </div>
            <div className="text-xs text-gray-600 dark:text-gray-400 mt-1">
              Based on your weight of {userWeight} kg
            </div>
          </div>

          <button
            type="submit"
            disabled={loading}
            className="btn-primary w-full disabled:opacity-50"
          >
            {loading ? 'Adding...' : 'Add Activity'}
          </button>
        </form>
      </div>
    </div>
  );
}
