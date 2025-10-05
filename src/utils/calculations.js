// Calculate Basal Metabolic Rate using Mifflin-St Jeor Equation
export function calculateBMR(weight, height, age, gender) {
  if (gender === 'male') {
    return 10 * weight + 6.25 * height - 5 * age + 5;
  } else if (gender === 'female') {
    return 10 * weight + 6.25 * height - 5 * age - 161;
  } else {
    return 10 * weight + 6.25 * height - 5 * age - 78;
  }
}

// Calculate Total Daily Energy Expenditure
export function calculateTDEE(bmr, activityLevel) {
  const activityMultipliers = {
    sedentary: 1.2,
    lightly_active: 1.375,
    moderately_active: 1.55,
    very_active: 1.725,
    extremely_active: 1.9,
  };

  return bmr * (activityMultipliers[activityLevel] || 1.55);
}

// Calculate daily calorie goal based on weight goal
export function calculateCalorieGoal(tdee, goal, goalRate = 0.5) {
  const caloriesPerKg = 7700;
  const weeklyDeficit = goalRate * caloriesPerKg;
  const dailyAdjustment = weeklyDeficit / 7;

  if (goal === 'lose_weight') {
    return Math.round(tdee - dailyAdjustment);
  } else if (goal === 'gain_weight') {
    return Math.round(tdee + dailyAdjustment);
  } else {
    return Math.round(tdee);
  }
}

// Calculate BMI
export function calculateBMI(weight, height) {
  const heightInMeters = height / 100;
  return weight / (heightInMeters * heightInMeters);
}

// Get BMI category
export function getBMICategory(bmi) {
  if (bmi < 18.5) return 'Underweight';
  if (bmi < 25) return 'Normal';
  if (bmi < 30) return 'Overweight';
  return 'Obese';
}

// Calculate macros based on calorie goal
export function calculateMacros(calorieGoal) {
  return {
    protein: Math.round((calorieGoal * 0.3) / 4),
    carbs: Math.round((calorieGoal * 0.4) / 4),
    fat: Math.round((calorieGoal * 0.3) / 9),
  };
}

// Calculate calories burned from activity
export function calculateCaloriesBurned(metValue, weight, durationMinutes) {
  return (metValue * weight * durationMinutes) / 60;
}
