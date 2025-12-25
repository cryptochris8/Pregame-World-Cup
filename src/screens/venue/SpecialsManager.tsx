import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import PregameLogo from '../../assets/pregame_logo.png';

interface Special {
  id: string;
  name: string;
  description: string;
  originalPrice: number;
  specialPrice: number;
  category: 'food' | 'drink' | 'combo';
  isActive: boolean;
  startTime: string;
  endTime: string;
  gameSpecific: boolean;
  scheduledGames: string[];
  image?: string;
}

const SpecialsManager: React.FC = () => {
  const [specials, setSpecials] = useState<Special[]>([]);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [editingSpecial, setEditingSpecial] = useState<Special | null>(null);
  const [selectedCategory, setSelectedCategory] = useState<string>('all');

  // Form state
  const [formData, setFormData] = useState<Partial<Special>>({
    name: '',
    description: '',
    originalPrice: 0,
    specialPrice: 0,
    category: 'food',
    isActive: true,
    startTime: '11:00',
    endTime: '23:00',
    gameSpecific: false,
    scheduledGames: []
  });

  // Mock data - in real app, this would come from your database
  useEffect(() => {
    setSpecials([
      {
        id: '1',
        name: 'Game Day Wings',
        description: '10 buffalo wings with your choice of sauce',
        originalPrice: 16.99,
        specialPrice: 12.99,
        category: 'food',
        isActive: true,
        startTime: '11:00',
        endTime: '23:00',
        gameSpecific: true,
        scheduledGames: ['Auburn vs LSU', 'Alabama vs Georgia']
      },
      {
        id: '2',
        name: '$2 Beers',
        description: 'Domestic draft beers during game hours',
        originalPrice: 5.00,
        specialPrice: 2.00,
        category: 'drink',
        isActive: true,
        startTime: '12:00',
        endTime: '18:00',
        gameSpecific: false,
        scheduledGames: []
      },
      {
        id: '3',
        name: 'Tailgate Combo',
        description: 'Burger, fries, and a beer',
        originalPrice: 22.99,
        specialPrice: 18.99,
        category: 'combo',
        isActive: false,
        startTime: '11:00',
        endTime: '15:00',
        gameSpecific: true,
        scheduledGames: ['SEC Championship']
      }
    ]);
  }, []);

  const filteredSpecials = selectedCategory === 'all' 
    ? specials 
    : specials.filter(special => special.category === selectedCategory);

  const handleCreateSpecial = () => {
    const newSpecial: Special = {
      id: Date.now().toString(),
      name: formData.name || '',
      description: formData.description || '',
      originalPrice: formData.originalPrice || 0,
      specialPrice: formData.specialPrice || 0,
      category: formData.category || 'food',
      isActive: formData.isActive || true,
      startTime: formData.startTime || '11:00',
      endTime: formData.endTime || '23:00',
      gameSpecific: formData.gameSpecific || false,
      scheduledGames: formData.scheduledGames || []
    };

    setSpecials([...specials, newSpecial]);
    resetForm();
    setShowCreateModal(false);
  };

  const handleUpdateSpecial = () => {
    if (!editingSpecial) return;

    const updatedSpecials = specials.map(special =>
      special.id === editingSpecial.id ? { ...editingSpecial, ...formData } : special
    );

    setSpecials(updatedSpecials);
    resetForm();
    setEditingSpecial(null);
  };

  const handleDeleteSpecial = (id: string) => {
    if (window.confirm('Are you sure you want to delete this special?')) {
      setSpecials(specials.filter(special => special.id !== id));
    }
  };

  const toggleSpecialStatus = (id: string) => {
    setSpecials(specials.map(special =>
      special.id === id ? { ...special, isActive: !special.isActive } : special
    ));
  };

  const resetForm = () => {
    setFormData({
      name: '',
      description: '',
      originalPrice: 0,
      specialPrice: 0,
      category: 'food',
      isActive: true,
      startTime: '11:00',
      endTime: '23:00',
      gameSpecific: false,
      scheduledGames: []
    });
  };

  const openEditModal = (special: Special) => {
    setEditingSpecial(special);
    setFormData(special);
    setShowCreateModal(true);
  };

  const calculateDiscount = (original: number, special: number) => {
    return Math.round(((original - special) / original) * 100);
  };

  return (
    <div className="min-h-screen" style={{ background: 'var(--pregame-dark-bg)' }}>
      {/* Header */}
      <div className="pregame-gradient text-white shadow-lg">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6">
            <div className="flex items-center">
              <Link to="/venue" className="mr-4 hover:opacity-80 transition-opacity">
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                </svg>
              </Link>
              <img src={PregameLogo} alt="Pregame" className="h-10 w-auto mr-4" />
              <div>
                <h1 className="text-3xl font-bold">Game Day Specials</h1>
                <p className="text-blue-100">Create and manage your venue's food & drink specials</p>
              </div>
            </div>
            <button
              onClick={() => setShowCreateModal(true)}
              className="btn-pregame-primary px-6 py-2 rounded-lg font-medium transition-colors"
            >
              + Add New Special
            </button>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div className="pregame-card">
            <div className="flex items-center">
              <div className="p-2 rounded-lg" style={{ backgroundColor: 'rgba(34, 197, 94, 0.15)' }}>
                <svg className="w-6 h-6 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium" style={{ color: 'var(--pregame-text-muted)' }}>Active Specials</p>
                <p className="text-2xl font-bold" style={{ color: 'var(--pregame-text-light)' }}>{specials.filter(s => s.isActive).length}</p>
              </div>
            </div>
          </div>

          <div className="pregame-card">
            <div className="flex items-center">
              <div className="p-2 rounded-lg" style={{ backgroundColor: 'rgba(59, 130, 246, 0.15)' }}>
                <svg className="w-6 h-6 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
                </svg>
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium" style={{ color: 'var(--pregame-text-muted)' }}>Total Specials</p>
                <p className="text-2xl font-bold" style={{ color: 'var(--pregame-text-light)' }}>{specials.length}</p>
              </div>
            </div>
          </div>

          <div className="pregame-card">
            <div className="flex items-center">
              <div className="p-2 rounded-lg" style={{ backgroundColor: 'rgba(255, 107, 53, 0.15)' }}>
                <svg className="w-6 h-6" style={{ color: 'var(--pregame-orange)' }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
                </svg>
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium" style={{ color: 'var(--pregame-text-muted)' }}>Avg. Discount</p>
                <p className="text-2xl font-bold" style={{ color: 'var(--pregame-text-light)' }}>
                  {Math.round(specials.reduce((acc, s) => acc + calculateDiscount(s.originalPrice, s.specialPrice), 0) / specials.length || 0)}%
                </p>
              </div>
            </div>
          </div>

          <div className="pregame-card">
            <div className="flex items-center">
              <div className="p-2 rounded-lg" style={{ backgroundColor: 'rgba(168, 85, 247, 0.15)' }}>
                <svg className="w-6 h-6 text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
                </svg>
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium" style={{ color: 'var(--pregame-text-muted)' }}>Game-Specific</p>
                <p className="text-2xl font-bold" style={{ color: 'var(--pregame-text-light)' }}>{specials.filter(s => s.gameSpecific).length}</p>
              </div>
            </div>
          </div>
        </div>

        {/* Filter Tabs */}
        <div className="pregame-card mb-6">
          <div className="border-b" style={{ borderColor: 'rgba(255, 255, 255, 0.1)' }}>
            <nav className="-mb-px flex space-x-8 px-6" aria-label="Tabs">
              {[
                { key: 'all', label: 'All Specials', count: specials.length },
                { key: 'food', label: 'Food', count: specials.filter(s => s.category === 'food').length },
                { key: 'drink', label: 'Drinks', count: specials.filter(s => s.category === 'drink').length },
                { key: 'combo', label: 'Combos', count: specials.filter(s => s.category === 'combo').length }
              ].map((tab) => (
                <button
                  key={tab.key}
                  onClick={() => setSelectedCategory(tab.key)}
                  className={`${
                    selectedCategory === tab.key
                      ? 'text-orange-500'
                      : 'border-transparent hover:border-gray-300'
                  } whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm transition-colors`}
                  style={{
                    color: selectedCategory === tab.key ? 'var(--pregame-orange)' : 'var(--pregame-text-muted)',
                    borderColor: selectedCategory === tab.key ? 'var(--pregame-orange)' : 'transparent'
                  }}
                >
                  {tab.label} ({tab.count})
                </button>
              ))}
            </nav>
          </div>
        </div>

        {/* Specials Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredSpecials.map((special) => (
            <div key={special.id} className="pregame-card overflow-hidden hover:border-orange-500 transition-colors">
              <div className="p-6">
                <div className="flex justify-between items-start mb-4">
                  <div>
                    <h3 className="text-lg font-semibold" style={{ color: 'var(--pregame-text-light)' }}>{special.name}</h3>
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      special.category === 'food' ? 'bg-orange-100 text-orange-800' :
                      special.category === 'drink' ? 'bg-blue-100 text-blue-800' :
                      'bg-purple-100 text-purple-800'
                    }`}>
                      {special.category.charAt(0).toUpperCase() + special.category.slice(1)}
                    </span>
                  </div>
                  <div className="flex space-x-2">
                    <button
                      onClick={() => toggleSpecialStatus(special.id)}
                      className={`p-1 rounded ${special.isActive ? 'text-green-600 hover:bg-green-100' : 'text-gray-400 hover:bg-gray-100'}`}
                    >
                      <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                    </button>
                    <button
                      onClick={() => openEditModal(special)}
                      className="p-1 text-blue-600 hover:bg-blue-100 rounded"
                    >
                      <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                      </svg>
                    </button>
                    <button
                      onClick={() => handleDeleteSpecial(special.id)}
                      className="p-1 text-red-600 hover:bg-red-100 rounded"
                    >
                      <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                      </svg>
                    </button>
                  </div>
                </div>

                <p className="mb-4" style={{ color: 'var(--pregame-text-muted)' }}>{special.description}</p>

                <div className="flex items-center justify-between mb-4">
                  <div className="flex items-center space-x-2">
                    <span className="text-lg font-bold" style={{ color: 'var(--pregame-orange)' }}>${special.specialPrice.toFixed(2)}</span>
                    <span className="text-sm line-through" style={{ color: 'var(--pregame-text-muted)' }}>${special.originalPrice.toFixed(2)}</span>
                    <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-red-100 text-red-800">
                      {calculateDiscount(special.originalPrice, special.specialPrice)}% OFF
                    </span>
                  </div>
                </div>

                <div className="text-sm text-gray-600 mb-2">
                  <span className="font-medium">Hours:</span> {special.startTime} - {special.endTime}
                </div>

                {special.gameSpecific && (
                  <div className="text-sm text-gray-600 mb-2">
                    <span className="font-medium">Games:</span> {special.scheduledGames.length} scheduled
                  </div>
                )}

                <div className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${
                  special.isActive ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
                }`}>
                  {special.isActive ? '● Active' : '○ Inactive'}
                </div>
              </div>
            </div>
          ))}
        </div>

        {filteredSpecials.length === 0 && (
          <div className="text-center py-12">
            <svg className="w-12 h-12 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
            </svg>
            <h3 className="text-lg font-medium text-gray-900 mb-2">No specials found</h3>
            <p className="text-gray-600 mb-4">Get started by creating your first game day special!</p>
            <button
              onClick={() => setShowCreateModal(true)}
              className="bg-[#355E3B] text-white px-6 py-2 rounded-lg font-medium hover:bg-[#2d4f31] transition-colors"
            >
              Create Special
            </button>
          </div>
        )}
      </div>

      {/* Create/Edit Modal */}
      {showCreateModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-2xl font-bold text-gray-900">
                  {editingSpecial ? 'Edit Special' : 'Create New Special'}
                </h2>
                <button
                  onClick={() => {
                    setShowCreateModal(false);
                    setEditingSpecial(null);
                    resetForm();
                  }}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>

              <form className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Special Name
                    </label>
                    <input
                      type="text"
                      value={formData.name}
                      onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#355E3B]"
                      placeholder="e.g., Game Day Wings"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Category
                    </label>
                    <select
                      value={formData.category}
                      onChange={(e) => setFormData({ ...formData, category: e.target.value as 'food' | 'drink' | 'combo' })}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#355E3B]"
                    >
                      <option value="food">Food</option>
                      <option value="drink">Drink</option>
                      <option value="combo">Combo</option>
                    </select>
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Description
                  </label>
                  <textarea
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                    rows={3}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#355E3B]"
                    placeholder="Describe your special..."
                  />
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Original Price ($)
                    </label>
                    <input
                      type="number"
                      step="0.01"
                      value={formData.originalPrice}
                      onChange={(e) => setFormData({ ...formData, originalPrice: parseFloat(e.target.value) })}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#355E3B]"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Special Price ($)
                    </label>
                    <input
                      type="number"
                      step="0.01"
                      value={formData.specialPrice}
                      onChange={(e) => setFormData({ ...formData, specialPrice: parseFloat(e.target.value) })}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#355E3B]"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Start Time
                    </label>
                    <input
                      type="time"
                      value={formData.startTime}
                      onChange={(e) => setFormData({ ...formData, startTime: e.target.value })}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#355E3B]"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      End Time
                    </label>
                    <input
                      type="time"
                      value={formData.endTime}
                      onChange={(e) => setFormData({ ...formData, endTime: e.target.value })}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#355E3B]"
                    />
                  </div>
                </div>

                <div className="flex items-center">
                  <input
                    type="checkbox"
                    id="gameSpecific"
                    checked={formData.gameSpecific}
                    onChange={(e) => setFormData({ ...formData, gameSpecific: e.target.checked })}
                    className="h-4 w-4 text-[#355E3B] focus:ring-[#355E3B] border-gray-300 rounded"
                  />
                  <label htmlFor="gameSpecific" className="ml-2 block text-sm text-gray-700">
                    This special is only for specific games
                  </label>
                </div>

                <div className="flex justify-end space-x-4">
                  <button
                    type="button"
                    onClick={() => {
                      setShowCreateModal(false);
                      setEditingSpecial(null);
                      resetForm();
                    }}
                    className="px-4 py-2 text-gray-700 bg-gray-200 rounded-lg hover:bg-gray-300 transition-colors"
                  >
                    Cancel
                  </button>
                  <button
                    type="button"
                    onClick={editingSpecial ? handleUpdateSpecial : handleCreateSpecial}
                    className="px-6 py-2 bg-[#355E3B] text-white rounded-lg hover:bg-[#2d4f31] transition-colors"
                  >
                    {editingSpecial ? 'Update Special' : 'Create Special'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default SpecialsManager; 