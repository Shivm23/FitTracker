import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Home, BookOpen, User, Sun, Moon, LogOut } from 'lucide-react';
import { useTheme } from '../contexts/ThemeContext';
import { useAuth } from '../contexts/AuthContext';

export default function Layout({ children }) {
  const location = useLocation();
  const { isDark, toggleTheme } = useTheme();
  const { user, signOut } = useAuth();

  const navigation = [
    { name: 'Home', href: '/', icon: Home },
    { name: 'Diary', href: '/diary', icon: BookOpen },
    { name: 'Profile', href: '/profile', icon: User },
  ];

  const handleSignOut = async () => {
    await signOut();
  };

  return (
    <div className="min-h-screen flex flex-col">
      {/* Header */}
      <header className="bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <Link to="/" className="flex items-center space-x-2">
              <div className="w-8 h-8 bg-gradient-to-br from-instagram-pink via-instagram-purple to-instagram-orange rounded-lg"></div>
              <span className="text-xl font-bold bg-gradient-to-r from-instagram-pink to-instagram-orange bg-clip-text text-transparent">
                NutriTracker
              </span>
            </Link>

            <div className="flex items-center space-x-4">
              <button
                onClick={toggleTheme}
                className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
              >
                {isDark ? <Sun className="w-5 h-5" /> : <Moon className="w-5 h-5" />}
              </button>
              {user && (
                <button
                  onClick={handleSignOut}
                  className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                >
                  <LogOut className="w-5 h-5" />
                </button>
              )}
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-1">
        {children}
      </main>

      {/* Bottom Navigation */}
      {user && (
        <nav className="bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700 sticky bottom-0 z-50">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-around items-center h-16">
              {navigation.map((item) => {
                const Icon = item.icon;
                const isActive = location.pathname === item.href;
                return (
                  <Link
                    key={item.name}
                    to={item.href}
                    className={`flex flex-col items-center justify-center space-y-1 px-4 py-2 rounded-lg transition-colors ${
                      isActive
                        ? 'text-primary'
                        : 'text-gray-500 dark:text-gray-400 hover:text-primary'
                    }`}
                  >
                    <Icon className="w-6 h-6" />
                    <span className="text-xs font-medium">{item.name}</span>
                  </Link>
                );
              })}
            </div>
          </div>
        </nav>
      )}
    </div>
  );
}
