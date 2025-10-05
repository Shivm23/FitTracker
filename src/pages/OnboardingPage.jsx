import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { User, Activity, Target, Check } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { useAuth } from '../contexts/AuthContext';

export default function OnboardingPage() {
  const navigate = useNavigate();
  const { user } = useAuth();
  const [step, setStep] = useState(1);
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    age: 30,
    gender: 'other',
    height: 170,
    weight: 70,
    activity_level: 'moderately_active',
    goal: 'maintain_weight',
    goal_rate: 0.5,
  });

  async function handleSubmit() {
    setLoading(true);
    try {
      const { error } = await supabase.from('users').insert({
        id: user.id,
        ...formData,
      });

      if (error) throw error;

      navigate('/');
    } catch (error) {
      console.error('Error creating profile:', error);
      alert('Failed to create profile. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  const totalSteps = 3;

  return (
    <div className="min-h-screen flex items-center justify-center p-4">
      <div className="max-w-2xl w-full">
        <div className="text-center mb-8">
          <div className="w-16 h-16 bg-gradient-to-br from-instagram-pink via-instagram-purple to-instagram-orange rounded-2xl mx-auto mb-4"></div>
          <h1 className="text-3xl font-bold mb-2">Welcome to NutriTracker</h1>
          <p className="text-gray-600 dark:text-gray-400">
            Let's personalize your experience
          </p>
        </div>

        <div className="card">
          {/* Progress Bar */}
          <div className="mb-8">
            <div className="flex justify-between mb-2">
              <span className="text-sm font-medium">Step {step} of {totalSteps}</span>
              <span className="text-sm text-gray-600 dark:text-gray-400">
                {Math.round((step / totalSteps) * 100)}%
              </span>
            </div>
            <div className="h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden">
              <div
                className="h-full bg-gradient-to-r from-instagram-pink to-instagram-orange transition-all duration-300"
                style={{ width: `${(step / totalSteps) * 100}%` }}
              ></div>
            </div>
          </div>

          {/* Step 1: Basic Info */}
          {step === 1 && (
            <div className="space-y-6">
              <div className="flex items-center space-x-3 mb-6">
                <div className="w-10 h-10 bg-primary/10 rounded-lg flex items-center justify-center">
                  <User className="w-6 h-6 text-primary" />
                </div>
                <h2 className="text-2xl font-bold">About You</h2>
              </div>

              <div>
                <label className="block text-sm font-medium mb-2">What's your age?</label>
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
                <label className="block text-sm font-medium mb-2">What's your gender?</label>
                <div className="grid grid-cols-3 gap-3">
                  {['male', 'female', 'other'].map((gender) => (
                    <button
                      key={gender}
                      type="button"
                      onClick={() => setFormData({ ...formData, gender })}
                      className={`p-4 rounded-lg border-2 transition-colors ${
                        formData.gender === gender
                          ? 'border-primary bg-primary/10'
                          : 'border-gray-300 dark:border-gray-600 hover:border-primary/50'
                      }`}
                    >
                      <div className="font-semibold capitalize">{gender}</div>
                    </button>
                  ))}
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

              <button
                onClick={() => setStep(2)}
                className="btn-primary w-full"
              >
                Continue
              </button>
            </div>
          )}

          {/* Step 2: Activity Level */}
          {step === 2 && (
            <div className="space-y-6">
              <div className="flex items-center space-x-3 mb-6">
                <div className="w-10 h-10 bg-secondary/10 rounded-lg flex items-center justify-center">
                  <Activity className="w-6 h-6 text-secondary" />
                </div>
                <h2 className="text-2xl font-bold">Activity Level</h2>
              </div>

              <div className="space-y-3">
                {[
                  { value: 'sedentary', label: 'Sedentary', desc: 'Little or no exercise' },
                  { value: 'lightly_active', label: 'Lightly Active', desc: '1-3 days/week' },
                  { value: 'moderately_active', label: 'Moderately Active', desc: '3-5 days/week' },
                  { value: 'very_active', label: 'Very Active', desc: '6-7 days/week' },
                  { value: 'extremely_active', label: 'Extremely Active', desc: 'Athlete level' },
                ].map((level) => (
                  <button
                    key={level.value}
                    type="button"
                    onClick={() => setFormData({ ...formData, activity_level: level.value })}
                    className={`w-full p-4 rounded-lg border-2 transition-colors text-left ${
                      formData.activity_level === level.value
                        ? 'border-secondary bg-secondary/10'
                        : 'border-gray-300 dark:border-gray-600 hover:border-secondary/50'
                    }`}
                  >
                    <div className="flex items-center justify-between">
                      <div>
                        <div className="font-semibold">{level.label}</div>
                        <div className="text-sm text-gray-600 dark:text-gray-400">{level.desc}</div>
                      </div>
                      {formData.activity_level === level.value && (
                        <Check className="w-5 h-5 text-secondary" />
                      )}
                    </div>
                  </button>
                ))}
              </div>

              <div className="flex space-x-3">
                <button
                  onClick={() => setStep(1)}
                  className="btn-secondary flex-1"
                >
                  Back
                </button>
                <button
                  onClick={() => setStep(3)}
                  className="btn-primary flex-1"
                >
                  Continue
                </button>
              </div>
            </div>
          )}

          {/* Step 3: Goal */}
          {step === 3 && (
            <div className="space-y-6">
              <div className="flex items-center space-x-3 mb-6">
                <div className="w-10 h-10 bg-tertiary/10 rounded-lg flex items-center justify-center">
                  <Target className="w-6 h-6 text-tertiary" />
                </div>
                <h2 className="text-2xl font-bold">Your Goal</h2>
              </div>

              <div className="space-y-3">
                {[
                  { value: 'lose_weight', label: 'Lose Weight', desc: 'Create a calorie deficit' },
                  { value: 'maintain_weight', label: 'Maintain Weight', desc: 'Stay at current weight' },
                  { value: 'gain_weight', label: 'Gain Weight', desc: 'Create a calorie surplus' },
                ].map((goalOption) => (
                  <button
                    key={goalOption.value}
                    type="button"
                    onClick={() => setFormData({ ...formData, goal: goalOption.value })}
                    className={`w-full p-4 rounded-lg border-2 transition-colors text-left ${
                      formData.goal === goalOption.value
                        ? 'border-tertiary bg-tertiary/10'
                        : 'border-gray-300 dark:border-gray-600 hover:border-tertiary/50'
                    }`}
                  >
                    <div className="flex items-center justify-between">
                      <div>
                        <div className="font-semibold">{goalOption.label}</div>
                        <div className="text-sm text-gray-600 dark:text-gray-400">{goalOption.desc}</div>
                      </div>
                      {formData.goal === goalOption.value && (
                        <Check className="w-5 h-5 text-tertiary" />
                      )}
                    </div>
                  </button>
                ))}
              </div>

              {formData.goal !== 'maintain_weight' && (
                <div>
                  <label className="block text-sm font-medium mb-2">
                    Target rate (kg/week)
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
                <button
                  onClick={() => setStep(2)}
                  className="btn-secondary flex-1"
                >
                  Back
                </button>
                <button
                  onClick={handleSubmit}
                  disabled={loading}
                  className="btn-primary flex-1 disabled:opacity-50"
                >
                  {loading ? 'Creating...' : 'Complete Setup'}
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
