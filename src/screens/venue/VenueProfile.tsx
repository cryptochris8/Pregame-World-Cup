import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import PregameLogo from '../../assets/pregame_logo.png';

interface VenueProfileData {
  name: string;
  description: string;
  address: string;
  phone: string;
  email: string;
  website: string;
  capacity: number;
  venueType: string;
  amenities: string[];
  regularHours: {
    [key: string]: { open: string; close: string; isClosed: boolean };
  };
  gameDayHours: {
    [key: string]: { open: string; close: string; isClosed: boolean };
  };
  socialMedia: {
    facebook?: string;
    instagram?: string;
    twitter?: string;
  };
}

const VenueProfile: React.FC = () => {
  const [activeTab, setActiveTab] = useState('basic');
  const [isEditing, setIsEditing] = useState(false);
  const [profileData, setProfileData] = useState<VenueProfileData>({
    name: "The Sports Den",
    description: "Auburn's premier sports bar and grill featuring 20+ HD TVs, game day specials, and the best atmosphere for watching SEC football!",
    address: "123 College Street, Auburn, AL 36830",
    phone: "(334) 555-0123",
    email: "info@thesportsden.com",
    website: "www.thesportsden.com",
    capacity: 150,
    venueType: "Sports Bar",
    amenities: ["Large TVs", "Outdoor Seating", "Live Music", "Game Day Specials", "Parking"],
    regularHours: {
      monday: { open: "11:00", close: "22:00", isClosed: false },
      tuesday: { open: "11:00", close: "22:00", isClosed: false },
      wednesday: { open: "11:00", close: "22:00", isClosed: false },
      thursday: { open: "11:00", close: "23:00", isClosed: false },
      friday: { open: "11:00", close: "24:00", isClosed: false },
      saturday: { open: "10:00", close: "24:00", isClosed: false },
      sunday: { open: "12:00", close: "22:00", isClosed: false }
    },
    gameDayHours: {
      monday: { open: "10:00", close: "24:00", isClosed: false },
      tuesday: { open: "10:00", close: "24:00", isClosed: false },
      wednesday: { open: "10:00", close: "24:00", isClosed: false },
      thursday: { open: "10:00", close: "24:00", isClosed: false },
      friday: { open: "09:00", close: "02:00", isClosed: false },
      saturday: { open: "08:00", close: "02:00", isClosed: false },
      sunday: { open: "10:00", close: "24:00", isClosed: false }
    },
    socialMedia: {
      facebook: "thesportsdenauburn",
      instagram: "@sportsden_auburn",
      twitter: "@SportsdenAU"
    }
  });

  const [uploadedImages, setUploadedImages] = useState<string[]>([
    "/api/placeholder/300/200", // Mock image URLs
    "/api/placeholder/300/200",
    "/api/placeholder/300/200"
  ]);

  const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
  const dayLabels = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  const availableAmenities = [
    "Large TVs", "Outdoor Seating", "Live Music", "Game Day Specials", 
    "Parking", "WiFi", "Pool Tables", "Dartboards", "Private Events",
    "Full Bar", "Kitchen", "Takeout", "Delivery", "Group Reservations"
  ];

  const handleSaveProfile = () => {
    // In real app, this would save to your database
    setIsEditing(false);
    console.log('Saving profile:', profileData);
  };

  const handleImageUpload = (event: React.ChangeEvent<HTMLInputElement>) => {
    const files = event.target.files;
    if (files) {
      // In real app, upload to your storage service
      const newImages = Array.from(files).map(file => URL.createObjectURL(file));
      setUploadedImages([...uploadedImages, ...newImages]);
    }
  };

  const removeImage = (index: number) => {
    setUploadedImages(uploadedImages.filter((_, i) => i !== index));
  };

  const toggleAmenity = (amenity: string) => {
    const updatedAmenities = profileData.amenities.includes(amenity)
      ? profileData.amenities.filter(a => a !== amenity)
      : [...profileData.amenities, amenity];
    
    setProfileData({ ...profileData, amenities: updatedAmenities });
  };

  const updateHours = (day: string, type: 'regular' | 'gameDay', field: string, value: string | boolean) => {
    const hoursKey = `${type}Hours` as keyof VenueProfileData;
    const currentHours = profileData[hoursKey] as any;
    const currentDayHours = currentHours[day] || { open: '09:00', close: '17:00', isClosed: false };
    
    setProfileData({
      ...profileData,
      [hoursKey]: {
        ...currentHours,
        [day]: {
          ...currentDayHours,
          [field]: value
        }
      }
    });
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
                <h1 className="text-3xl font-bold">Venue Profile</h1>
                <p className="text-blue-100">Manage your venue information and settings</p>
              </div>
            </div>
            <button
              onClick={() => isEditing ? handleSaveProfile() : setIsEditing(true)}
              className="btn-pregame-primary px-6 py-2 rounded-lg font-medium transition-colors"
            >
              {isEditing ? 'Save Changes' : 'Edit Profile'}
            </button>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Tab Navigation */}
        <div className="bg-white rounded-lg shadow mb-6">
          <div className="border-b border-gray-200">
            <nav className="-mb-px flex space-x-8 px-6" aria-label="Tabs">
              {[
                { key: 'basic', label: 'Basic Info', icon: '📍' },
                { key: 'hours', label: 'Hours', icon: '🕒' },
                { key: 'photos', label: 'Photos', icon: '📸' },
                { key: 'amenities', label: 'Amenities', icon: '⚡' }
              ].map((tab) => (
                <button
                  key={tab.key}
                  onClick={() => setActiveTab(tab.key)}
                  className={`${
                    activeTab === tab.key
                      ? 'border-[#355E3B] text-[#355E3B]'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  } whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm flex items-center`}
                >
                  <span className="mr-2">{tab.icon}</span>
                  {tab.label}
                </button>
              ))}
            </nav>
          </div>
        </div>

        {/* Tab Content */}
        <div className="bg-white rounded-lg shadow">
          {/* Basic Info Tab */}
          {activeTab === 'basic' && (
            <div className="p-6">
              <h2 className="text-xl font-bold text-gray-900 mb-6">Basic Information</h2>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Venue Name
                  </label>
                  <input
                    type="text"
                    value={profileData.name}
                    onChange={(e) => setProfileData({ ...profileData, name: e.target.value })}
                    disabled={!isEditing}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#355E3B] disabled:bg-gray-100"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Venue Type
                  </label>
                  <select
                    value={profileData.venueType}
                    onChange={(e) => setProfileData({ ...profileData, venueType: e.target.value })}
                    disabled={!isEditing}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#355E3B] disabled:bg-gray-100"
                  >
                    <option value="Sports Bar">Sports Bar</option>
                    <option value="Restaurant">Restaurant</option>
                    <option value="Brewery">Brewery</option>
                    <option value="Pub">Pub</option>
                    <option value="Grill">Grill</option>
                    <option value="Cafe">Cafe</option>
                  </select>
                </div>

                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Description
                  </label>
                  <textarea
                    value={profileData.description}
                    onChange={(e) => setProfileData({ ...profileData, description: e.target.value })}
                    disabled={!isEditing}
                    rows={4}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#355E3B] disabled:bg-gray-100"
                    placeholder="Describe your venue, atmosphere, and what makes it special..."
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Address
                  </label>
                  <input
                    type="text"
                    value={profileData.address}
                    onChange={(e) => setProfileData({ ...profileData, address: e.target.value })}
                    disabled={!isEditing}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#355E3B] disabled:bg-gray-100"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Capacity
                  </label>
                  <input
                    type="number"
                    value={profileData.capacity}
                    onChange={(e) => setProfileData({ ...profileData, capacity: parseInt(e.target.value) })}
                    disabled={!isEditing}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#355E3B] disabled:bg-gray-100"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Phone Number
                  </label>
                  <input
                    type="tel"
                    value={profileData.phone}
                    onChange={(e) => setProfileData({ ...profileData, phone: e.target.value })}
                    disabled={!isEditing}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#355E3B] disabled:bg-gray-100"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Email
                  </label>
                  <input
                    type="email"
                    value={profileData.email}
                    onChange={(e) => setProfileData({ ...profileData, email: e.target.value })}
                    disabled={!isEditing}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#355E3B] disabled:bg-gray-100"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Website
                  </label>
                  <input
                    type="url"
                    value={profileData.website}
                    onChange={(e) => setProfileData({ ...profileData, website: e.target.value })}
                    disabled={!isEditing}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#355E3B] disabled:bg-gray-100"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Facebook
                  </label>
                  <input
                    type="text"
                    value={profileData.socialMedia.facebook || ''}
                    onChange={(e) => setProfileData({ 
                      ...profileData, 
                      socialMedia: { ...profileData.socialMedia, facebook: e.target.value }
                    })}
                    disabled={!isEditing}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#355E3B] disabled:bg-gray-100"
                    placeholder="username or page name"
                  />
                </div>
              </div>
            </div>
          )}

          {/* Hours Tab */}
          {activeTab === 'hours' && (
            <div className="p-6">
              <h2 className="text-xl font-bold text-gray-900 mb-6">Operating Hours</h2>
              
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                {/* Regular Hours */}
                <div>
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Regular Hours</h3>
                  <div className="space-y-3">
                    {days.map((day, index) => (
                      <div key={day} className="flex items-center space-x-4">
                        <div className="w-20 text-sm font-medium text-gray-700">
                          {dayLabels[index]}
                        </div>
                        <div className="flex items-center space-x-2">
                          <input
                            type="checkbox"
                            checked={!profileData.regularHours[day].isClosed}
                            onChange={(e) => updateHours(day, 'regular', 'isClosed', !e.target.checked)}
                            disabled={!isEditing}
                            className="h-4 w-4 text-[#355E3B] focus:ring-[#355E3B] border-gray-300 rounded"
                          />
                          <span className="text-sm text-gray-600">Open</span>
                        </div>
                        {!profileData.regularHours[day].isClosed && (
                          <>
                            <input
                              type="time"
                              value={profileData.regularHours[day].open}
                              onChange={(e) => updateHours(day, 'regular', 'open', e.target.value)}
                              disabled={!isEditing}
                              className="px-2 py-1 text-sm border border-gray-300 rounded focus:outline-none focus:ring-1 focus:ring-[#355E3B] disabled:bg-gray-100"
                            />
                            <span className="text-gray-500">to</span>
                            <input
                              type="time"
                              value={profileData.regularHours[day].close}
                              onChange={(e) => updateHours(day, 'regular', 'close', e.target.value)}
                              disabled={!isEditing}
                              className="px-2 py-1 text-sm border border-gray-300 rounded focus:outline-none focus:ring-1 focus:ring-[#355E3B] disabled:bg-gray-100"
                            />
                          </>
                        )}
                      </div>
                    ))}
                  </div>
                </div>

                {/* Game Day Hours */}
                <div>
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Game Day Hours</h3>
                  <div className="space-y-3">
                    {days.map((day, index) => (
                      <div key={day} className="flex items-center space-x-4">
                        <div className="w-20 text-sm font-medium text-gray-700">
                          {dayLabels[index]}
                        </div>
                        <div className="flex items-center space-x-2">
                          <input
                            type="checkbox"
                            checked={!profileData.gameDayHours[day].isClosed}
                            onChange={(e) => updateHours(day, 'gameDay', 'isClosed', !e.target.checked)}
                            disabled={!isEditing}
                            className="h-4 w-4 text-[#355E3B] focus:ring-[#355E3B] border-gray-300 rounded"
                          />
                          <span className="text-sm text-gray-600">Open</span>
                        </div>
                        {!profileData.gameDayHours[day].isClosed && (
                          <>
                            <input
                              type="time"
                              value={profileData.gameDayHours[day].open}
                              onChange={(e) => updateHours(day, 'gameDay', 'open', e.target.value)}
                              disabled={!isEditing}
                              className="px-2 py-1 text-sm border border-gray-300 rounded focus:outline-none focus:ring-1 focus:ring-[#355E3B] disabled:bg-gray-100"
                            />
                            <span className="text-gray-500">to</span>
                            <input
                              type="time"
                              value={profileData.gameDayHours[day].close}
                              onChange={(e) => updateHours(day, 'gameDay', 'close', e.target.value)}
                              disabled={!isEditing}
                              className="px-2 py-1 text-sm border border-gray-300 rounded focus:outline-none focus:ring-1 focus:ring-[#355E3B] disabled:bg-gray-100"
                            />
                          </>
                        )}
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Photos Tab */}
          {activeTab === 'photos' && (
            <div className="p-6">
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-xl font-bold text-gray-900">Venue Photos</h2>
                {isEditing && (
                  <label className="bg-[#355E3B] text-white px-4 py-2 rounded-lg cursor-pointer hover:bg-[#2d4f31] transition-colors">
                    Upload Photos
                    <input
                      type="file"
                      multiple
                      accept="image/*"
                      onChange={handleImageUpload}
                      className="hidden"
                    />
                  </label>
                )}
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {uploadedImages.map((image, index) => (
                  <div key={index} className="relative group">
                    <img
                      src={image}
                      alt={`Venue photo ${index + 1}`}
                      className="w-full h-48 object-cover rounded-lg shadow"
                    />
                    {isEditing && (
                      <button
                        onClick={() => removeImage(index)}
                        className="absolute top-2 right-2 bg-red-600 text-white p-1 rounded-full opacity-0 group-hover:opacity-100 transition-opacity"
                      >
                        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                        </svg>
                      </button>
                    )}
                  </div>
                ))}
                
                {uploadedImages.length === 0 && (
                  <div className="col-span-full text-center py-12 border-2 border-dashed border-gray-300 rounded-lg">
                    <svg className="w-12 h-12 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>
                    <h3 className="text-lg font-medium text-gray-900 mb-2">No photos uploaded</h3>
                    <p className="text-gray-600">Upload photos to showcase your venue to fans!</p>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* Amenities Tab */}
          {activeTab === 'amenities' && (
            <div className="p-6">
              <h2 className="text-xl font-bold text-gray-900 mb-6">Venue Amenities</h2>
              <p className="text-gray-600 mb-6">Select the amenities available at your venue to help fans find what they're looking for.</p>
              
              <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                {availableAmenities.map((amenity) => (
                  <div key={amenity} className="flex items-center">
                    <input
                      type="checkbox"
                      id={amenity}
                      checked={profileData.amenities.includes(amenity)}
                      onChange={() => toggleAmenity(amenity)}
                      disabled={!isEditing}
                      className="h-4 w-4 text-[#355E3B] focus:ring-[#355E3B] border-gray-300 rounded"
                    />
                    <label htmlFor={amenity} className="ml-2 text-sm text-gray-700">
                      {amenity}
                    </label>
                  </div>
                ))}
              </div>

              {profileData.amenities.length > 0 && (
                <div className="mt-8">
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Selected Amenities</h3>
                  <div className="flex flex-wrap gap-2">
                    {profileData.amenities.map((amenity) => (
                      <span
                        key={amenity}
                        className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-[#355E3B] text-white"
                      >
                        {amenity}
                      </span>
                    ))}
                  </div>
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default VenueProfile; 