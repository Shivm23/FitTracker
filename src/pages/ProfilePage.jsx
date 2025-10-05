import React, { useEffect, useState } from 'react';
import { User, Activity, Target, Scale, Ruler } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { useAuth } from '../contexts/AuthContext';
import { calculateBMI, getBMICategory, calculateBMR, calculateTDEE, calculateCalorieGoal } from '../utils/calculations';

export default function ProfilePage() {
  const { user } = useAuth();
  const [profile, setProfile] = useState(null);
  const [editing, setEditing] = useState(false);
  const [loading, setLoading] = useState(true);
  const [formData, setFormData] = useState({
    height: 170,
    weight: 70,
    age: 30,
    gender: 'other',
    activity_level: 'moderately_active',
    goal: 'maintain_weight',
    goal_rate: 0.5,
  });

  useEffect(() => {
    if (user) {
      loadProfile();
    }
  }, [user]);

  async function loadProfile() {
    try {
      const { data, error } = await supabase
        .from('users')
        .select('*')
        .eq('id', user.id)
        .maybeSingle();

      if (error) throw error;

      if (data) {
        setProfile(data);
        setFormData(data);
      }
    } catch (error) {
      console.error('Error loading profile:', error);
    } finally {
      setLoading(false);
    }
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setLoading(true);

    try {
      if (profile) {
        const { error } = await supabase
          .from('users')
          .update({ ...formData, updated_at: new Date().toISOString() })
          .eq('id', user.id);

        if (error) throw error;
      } else {
        const { error } = await supabase.from('users').insert({
          id: user.id,
          ...formData,
        });

        if (error) throw error;
      }

      await loadProfile();
      setEditing(false);
    } catch (error) {
      console.error('Error saving profile:', error);
      alert('Failed to save profile. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  if (loading && !profile) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="w-16 h-16 border-4 border-primary border-t-transparent rounded-full animate-spin"></div>
      </div>
    );
  }

  if (!profile && !editing) {
    return (
      <div className="max-w-2xl mx-auto p-4 sm:p-6 lg:p-8">
        <div className="card text-center">
          <User className="w-16 h-16 mx-auto text-gray-400 mb-4" />
          <h2 className="text-2xl font-bold mb-4">Complete Your Profile</h2>
          <p className="text-gray-600 dark:text-gray-400 mb-6">
            Tell us about yourself to get personalized nutrition recommendations
          </p>
          <button onClick={() => setEditing(true)} className="btn-primary">
            Set Up Profile
          </button>
        </div>
      </div>
    );
  }

  if (editing) {
    return (
      <div className="max-w-2xl mx-auto p-4 sm:p-6 lg:p-8">
        <div className="card">
          <h2 className="text-2xl font-bold mb-6">{profile ? 'Edit Profile' : 'Create Profile'}</h2>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium mb-2">Age</label>
                <input
                  type="number"
                  min="1"
                  max="120"
                  value={formData.age}
                  onChange={(e) => setFormData({ ...formData, age: parseInt(e.target.value) })}
                  className="input"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Gender</label>
                <select
                  value={formData.gender}
                  onChange={(e) => setFormData({ ...formData, gender: e.target.value })}
                  className="input"
                  required
                >
                  <option value="male">Male</option>
                  <option value="female">Female</option>
                  <option value="other">Other</option>
                </select>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium mb-2">Height (cm)</label>
                <input
                  type="number"
                  min="100"
                  max="250"
                  value={formData.height}
                  onChange={(e) => setFormData({ ...formData, height: parseInt(e.target.value) })}
                  className="input"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Weight (kg)</label>
                <input
                  type="number"
                  step="0.1"
                  min="30"
                  max="300"
                  value={formData.weight}
                  onChange={(e) => setFormData({ ...formData, weight: parseFloat(e.target.value) })}
                  className="input"
                  required
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium mb-2">Activity Level</label>
              <select
                value={formData.activity_level}
                onChange={(e) => setFormData({ ...formData, activity_level: e.target.value })}
                className="input"
                required
              >
                <option value="sedentary">Sedentary (little or no exercise)</option>
                <option value="lightly_active">Lightly Active (1-3 days/week)</option>
                <option value="moderately_active">Moderately Active (3-5 days/week)</option>
                <option value="very_active">Very Active (6-7 days/week)</option>
                <option value="extremely_active">Extremely Active (athlete)</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium mb-2">Goal</label>
              <select
                value={formData.goal}
                onChange={(e) => setFormData({ ...formData, goal: e.target.value })}
                className="input"
                required
              >
                <option value="lose_weight">Lose Weight</option>
                <option value="maintain_weight">Maintain Weight</option>
                <option value="gain_weight">Gain Weight</option>
              </select>
            </div>

            {formData.goal !== 'maintain_weight' && (
              <div>
                <label className="block text-sm font-medium mb-2">
                  Goal Rate (kg/week)
                </label>
                <input
                  type="number"
                  step="0.1"
                  min="0.1"
                  max="1.5"
                  value={formData.goal_rate}
                  onChange={(e) => setFormData({ ...formData, goal_rate: parseFloat(e.target.value) })}
                  className="input"
                  required
                />
                <p className="text-xs text-gray-500 mt-1">
                  Recommended: 0.5 kg/week for sustainable progress
                </p>
              </div>
            )}

            <div className="flex space-x-3">
              <button type="submit" className="btn-primary flex-1" disabled={loading}>
                {loading ? 'Saving...' : 'Save Profile'}
              </button>
              {profile && (
                <button
                  type="button"
                  onClick={() => {
                    setEditing(false);
                    setFormData(profile);
                  }}
                  className="btn-secondary"
                >
                  Cancel
                </button>
              )}
            </div>
          </form>
        </div>
      </div>
    );
  }

  const bmi = calculateBMI(profile.weight, profile.height);
  const bmiCategory = getBMICategory(bmi);
  const bmr = calculateBMR(profile.weight, profile.height, profile.age, profile.gender);
  const tdee = calculateTDEE(bmr, profile.activity_level);
  const calorieGoal = calculateCalorieGoal(tdee, profile.goal, profile.goal_rate);

  return (
    <div className="max-w-7xl mx-auto p-4 sm:p-6 lg:p-8 space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold">Profile</h1>
        <button onClick={() => setEditing(true)} className="btn-primary">
          Edit Profile
        </button>
      </div>

      {/* BMI Card */}
      <div className="card bg-gradient-to-br from-instagram-pink/10 to-instagram-purple/10">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-lg font-semibold mb-2">Body Mass Index (BMI)</h2>
            <div className="text-4xl font-bold bg-gradient-to-r from-instagram-pink to-instagram-orange bg-clip-text text-transparent">
              {bmi.toFixed(1)}
            </div>
            <div className="text-sm text-gray-600 dark:text-gray-400 mt-1">{bmiCategory}</div>
          </div>
          <Scale className="w-16 h-16 text-primary opacity-20" />
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-2 gap-4">
        <div className="card">
          <div className="flex items-center space-x-3">
            <Ruler className="w-8 h-8 text-primary" />
            <div>
              <div className="text-sm text-gray-600 dark:text-gray-400">Height</div>
              <div className="text-2xl font-bold">{profile.height} cm</div>
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center space-x-3">
            <Scale className="w-8 h-8 text-secondary" />
            <div>
              <div className="text-sm text-gray-600 dark:text-gray-400">Weight</div>
              <div className="text-2xl font-bold">{profile.weight} kg</div>
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center space-x-3">
            <User className="w-8 h-8 text-tertiary" />
            <div>
              <div className="text-sm text-gray-600 dark:text-gray-400">Age</div>
              <div className="text-2xl font-bold">{profile.age} years</div>
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center space-x-3">
            <Activity className="w-8 h-8 text-primary" />
            <div>
              <div className="text-sm text-gray-600 dark:text-gray-400">Gender</div>
              <div className="text-xl font-bold capitalize">{profile.gender}</div>
            </div>
          </div>
        </div>
      </div>

      {/* Calorie Information */}
      <div className="card">
        <h2 className="text-xl font-bold mb-4 flex items-center">
          <Target className="w-5 h-5 mr-2 text-primary" />
          Daily Calorie Information
        </h2>
        <div className="space-y-3">
          <div className="flex justify-between items-center p-3 bg-gray-50 dark:bg-gray-700 rounded-lg">
            <span className="text-sm">Basal Metabolic Rate (BMR)</span>
            <span className="font-bold">{Math.round(bmr)} cal</span>
          </div>
          <div className="flex justify-between items-center p-3 bg-gray-50 dark:bg-gray-700 rounded-lg">
            <span className="text-sm">Total Daily Energy Expenditure (TDEE)</span>
            <span className="font-bold">{Math.round(tdee)} cal</span>
          </div>
          <div className="flex justify-between items-center p-3 bg-primary/10 rounded-lg border-2 border-primary/20">
            <span className="text-sm font-semibold">Daily Calorie Goal</span>
            <span className="font-bold text-primary text-lg">{calorieGoal} cal</span>
          </div>
        </div>
      </div>

      {/* Goal Information */}
      <div className="card">
        <h2 className="text-xl font-bold mb-4">Your Goal</h2>
        <div className="space-y-2">
          <div className="flex justify-between">
            <span className="text-gray-600 dark:text-gray-400">Activity Level</span>
            <span className="font-semibold capitalize">{profile.activity_level.replace('_', ' ')}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-gray-600 dark:text-gray-400">Weight Goal</span>
            <span className="font-semibold capitalize">{profile.goal.replace('_', ' ')}</span>
          </div>
          {profile.goal !== 'maintain_weight' && (
            <div className="flex justify-between">
              <span className="text-gray-600 dark:text-gray-400">Target Rate</span>
              <span className="font-semibold">{profile.goal_rate} kg/week</span>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
