import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { 
  LineChart, Line, AreaChart, Area, BarChart, Bar, PieChart, Pie, Cell,
  XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer 
} from 'recharts';
import { Calendar, TrendingUp, Users, DollarSign, Eye, Star, 
         MapPin, Clock, Filter, Download, RefreshCw } from 'lucide-react';

interface AnalyticsData {
  // Traffic metrics
  totalViews: number;
  uniqueVisitors: number;
  pageViews: number;
  bounceRate: number;
  avgSessionDuration: string;
  
  // Engagement metrics
  checkIns: number;
  reviews: number;
  avgRating: number;
  socialShares: number;
  photoUploads: number;
  
  // Revenue metrics
  totalRevenue: number;
  avgOrderValue: number;
  conversionRate: number;
  topSellingItems: Array<{name: string; sales: number; revenue: number}>;
  
  // Time-based data
  hourlyTraffic: Array<{hour: string; visitors: number; revenue: number}>;
  dailyMetrics: Array<{date: string; views: number; checkIns: number; revenue: number}>;
  weeklyComparison: Array<{week: string; current: number; previous: number}>;
  
  // Demographics
  ageGroups: Array<{age: string; count: number}>;
  genderBreakdown: Array<{gender: string; count: number}>;
  locationData: Array<{city: string; visitors: number}>;
  
  // Game day analytics
  gameDayPerformance: Array<{
    date: string;
    game: string;
    attendance: number;
    revenue: number;
    avgSpend: number;
  }>;
}

const AnalyticsDashboard: React.FC = () => {
  const [analyticsData, setAnalyticsData] = useState<AnalyticsData | null>(null);
  const [loading, setLoading] = useState(true);
  const [dateRange, setDateRange] = useState('7d');
  const [selectedMetric, setSelectedMetric] = useState('all');

  // Sample data - in real app, this would come from API
  const sampleData: AnalyticsData = {
    totalViews: 12543,
    uniqueVisitors: 8921,
    pageViews: 18765,
    bounceRate: 23.4,
    avgSessionDuration: '4m 32s',
    
    checkIns: 1847,
    reviews: 234,
    avgRating: 4.6,
    socialShares: 567,
    photoUploads: 892,
    
    totalRevenue: 45678.90,
    avgOrderValue: 24.75,
    conversionRate: 12.8,
    topSellingItems: [
      { name: 'Buffalo Wings', sales: 342, revenue: 4104.00 },
      { name: 'Craft Beer Flight', sales: 298, revenue: 3576.00 },
      { name: 'Loaded Nachos', sales: 267, revenue: 3204.00 },
      { name: 'BBQ Burger', sales: 234, revenue: 3276.00 },
      { name: 'Game Day Special', sales: 189, revenue: 2646.00 },
    ],
    
    hourlyTraffic: [
      { hour: '9AM', visitors: 45, revenue: 234 },
      { hour: '10AM', visitors: 67, revenue: 456 },
      { hour: '11AM', visitors: 123, revenue: 789 },
      { hour: '12PM', visitors: 234, revenue: 1456 },
      { hour: '1PM', visitors: 345, revenue: 2134 },
      { hour: '2PM', visitors: 456, revenue: 2987 },
      { hour: '3PM', visitors: 567, revenue: 3456 },
      { hour: '4PM', visitors: 678, revenue: 4123 },
      { hour: '5PM', visitors: 789, revenue: 5234 },
      { hour: '6PM', visitors: 890, revenue: 6789 },
      { hour: '7PM', visitors: 1023, revenue: 8456 },
      { hour: '8PM', visitors: 1156, revenue: 9234 },
    ],
    
    dailyMetrics: [
      { date: '2024-01-01', views: 1234, checkIns: 234, revenue: 3456 },
      { date: '2024-01-02', views: 1456, checkIns: 267, revenue: 4123 },
      { date: '2024-01-03', views: 1678, checkIns: 298, revenue: 4789 },
      { date: '2024-01-04', views: 1890, checkIns: 345, revenue: 5456 },
      { date: '2024-01-05', views: 2123, checkIns: 398, revenue: 6234 },
      { date: '2024-01-06', views: 2456, checkIns: 456, revenue: 7890 },
      { date: '2024-01-07', views: 2789, checkIns: 523, revenue: 8765 },
    ],
    
    weeklyComparison: [
      { week: 'This Week', current: 8765, previous: 7234 },
      { week: 'Last Week', current: 7234, previous: 6543 },
      { week: '2 Weeks Ago', current: 6543, previous: 5876 },
      { week: '3 Weeks Ago', current: 5876, previous: 5234 },
    ],
    
    ageGroups: [
      { age: '18-24', count: 2345 },
      { age: '25-34', count: 3456 },
      { age: '35-44', count: 2789 },
      { age: '45-54', count: 1567 },
      { age: '55+', count: 876 },
    ],
    
    genderBreakdown: [
      { gender: 'Male', count: 5678 },
      { gender: 'Female', count: 4321 },
      { gender: 'Other', count: 234 },
    ],
    
    locationData: [
      { city: 'Auburn', visitors: 3456 },
      { city: 'Montgomery', visitors: 2345 },
      { city: 'Birmingham', visitors: 1890 },
      { city: 'Mobile', visitors: 1234 },
      { city: 'Huntsville', visitors: 987 },
    ],
    
    gameDayPerformance: [
      { date: '2024-01-15', game: 'Auburn vs Alabama', attendance: 2345, revenue: 23456, avgSpend: 45.67 },
      { date: '2024-01-22', game: 'Auburn vs Georgia', attendance: 2156, revenue: 21234, avgSpend: 43.21 },
      { date: '2024-01-29', game: 'Auburn vs LSU', attendance: 2456, revenue: 25678, avgSpend: 47.89 },
    ],
  };

  useEffect(() => {
    // Simulate API call
    const fetchAnalytics = async () => {
      setLoading(true);
      await new Promise(resolve => setTimeout(resolve, 1000)); // Simulate loading
      setAnalyticsData(sampleData);
      setLoading(false);
    };

    fetchAnalytics();
  }, [dateRange]);

  const refreshData = () => {
    setLoading(true);
    setTimeout(() => {
      setAnalyticsData({...sampleData}); // Refresh with new data
      setLoading(false);
    }, 1000);
  };

  const exportData = () => {
    // In real app, this would export actual data
    const dataStr = JSON.stringify(analyticsData, null, 2);
    const dataUri = 'data:application/json;charset=utf-8,'+ encodeURIComponent(dataStr);
    
    const exportFileDefaultName = `analytics-${dateRange}-${new Date().toISOString().split('T')[0]}.json`;
    
    const linkElement = document.createElement('a');
    linkElement.setAttribute('href', dataUri);
    linkElement.setAttribute('download', exportFileDefaultName);
    linkElement.click();
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-purple-900 via-blue-900 to-purple-800 p-6">
        <div className="flex items-center justify-center h-96">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-orange-400"></div>
        </div>
      </div>
    );
  }

  if (!analyticsData) return null;

  const COLORS = ['#EA580C', '#FBBF24', '#8B5CF6', '#3B82F6', '#10B981'];

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-900 via-blue-900 to-purple-800 p-6">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-8">
          <div>
            <h1 className="text-4xl font-bold text-white mb-2">Analytics Dashboard</h1>
            <p className="text-gray-300">Comprehensive insights for your venue performance</p>
          </div>
          
          <div className="flex flex-wrap gap-4 mt-4 md:mt-0">
            {/* Date Range Selector */}
            <select 
              value={dateRange}
              onChange={(e) => setDateRange(e.target.value)}
              className="bg-white/10 border border-white/30 rounded-lg px-4 py-2 text-white backdrop-blur-sm"
            >
              <option value="1d">Last 24 Hours</option>
              <option value="7d">Last 7 Days</option>
              <option value="30d">Last 30 Days</option>
              <option value="90d">Last 90 Days</option>
            </select>
            
            {/* Action Buttons */}
            <button
              onClick={refreshData}
              className="bg-white/10 hover:bg-white/20 border border-white/30 rounded-lg px-4 py-2 text-white backdrop-blur-sm transition-all flex items-center gap-2"
            >
              <RefreshCw size={16} />
              Refresh
            </button>
            
            <button
              onClick={exportData}
              className="bg-gradient-to-r from-orange-500 to-yellow-500 hover:from-orange-600 hover:to-yellow-600 rounded-lg px-4 py-2 text-white transition-all flex items-center gap-2"
            >
              <Download size={16} />
              Export
            </button>
          </div>
        </div>

        {/* Key Metrics Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <MetricCard
            title="Total Revenue"
            value={`$${analyticsData.totalRevenue.toLocaleString()}`}
            change="+12.5%"
            icon={<DollarSign className="text-green-400" />}
            trend="up"
          />
          <MetricCard
            title="Unique Visitors"
            value={analyticsData.uniqueVisitors.toLocaleString()}
            change="+8.3%"
            icon={<Users className="text-blue-400" />}
            trend="up"
          />
          <MetricCard
            title="Check-ins"
            value={analyticsData.checkIns.toLocaleString()}
            change="+15.7%"
            icon={<MapPin className="text-purple-400" />}
            trend="up"
          />
          <MetricCard
            title="Avg Rating"
            value={analyticsData.avgRating.toFixed(1)}
            change="+0.2"
            icon={<Star className="text-yellow-400" />}
            trend="up"
          />
        </div>

        {/* Charts Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          {/* Revenue Trends */}
          <ChartCard title="Revenue Trends" subtitle="Daily revenue over time">
            <ResponsiveContainer width="100%" height={300}>
              <AreaChart data={analyticsData.dailyMetrics}>
                <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
                <XAxis dataKey="date" stroke="#9CA3AF" />
                <YAxis stroke="#9CA3AF" />
                <Tooltip 
                  contentStyle={{ 
                    backgroundColor: '#1F2937', 
                    border: '1px solid #374151',
                    borderRadius: '8px'
                  }}
                />
                <Area 
                  type="monotone" 
                  dataKey="revenue" 
                  stroke="#EA580C" 
                  fill="url(#revenueGradient)" 
                />
                <defs>
                  <linearGradient id="revenueGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#EA580C" stopOpacity={0.8}/>
                    <stop offset="95%" stopColor="#EA580C" stopOpacity={0.1}/>
                  </linearGradient>
                </defs>
              </AreaChart>
            </ResponsiveContainer>
          </ChartCard>

          {/* Hourly Traffic */}
          <ChartCard title="Hourly Traffic" subtitle="Visitor patterns throughout the day">
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={analyticsData.hourlyTraffic}>
                <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
                <XAxis dataKey="hour" stroke="#9CA3AF" />
                <YAxis stroke="#9CA3AF" />
                <Tooltip 
                  contentStyle={{ 
                    backgroundColor: '#1F2937', 
                    border: '1px solid #374151',
                    borderRadius: '8px'
                  }}
                />
                <Bar dataKey="visitors" fill="#8B5CF6" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </ChartCard>
        </div>

        {/* Demographics and Performance */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
          {/* Age Demographics */}
          <ChartCard title="Age Demographics" subtitle="Visitor age distribution">
            <ResponsiveContainer width="100%" height={250}>
              <PieChart>
                <Pie
                  data={analyticsData.ageGroups}
                  cx="50%"
                  cy="50%"
                  innerRadius={60}
                  outerRadius={100}
                  paddingAngle={5}
                  dataKey="count"
                >
                  {analyticsData.ageGroups.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
                <Legend />
              </PieChart>
            </ResponsiveContainer>
          </ChartCard>

          {/* Top Selling Items */}
          <div className="lg:col-span-2">
            <ChartCard title="Top Selling Items" subtitle="Best performing menu items">
              <div className="space-y-4">
                {analyticsData.topSellingItems.map((item, index) => (
                  <div key={item.name} className="flex items-center justify-between p-4 bg-white/5 rounded-lg">
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 bg-gradient-to-r from-orange-500 to-yellow-500 rounded-full flex items-center justify-center text-white font-bold">
                        {index + 1}
                      </div>
                      <div>
                        <p className="text-white font-medium">{item.name}</p>
                        <p className="text-gray-400 text-sm">{item.sales} sold</p>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="text-white font-bold">${item.revenue.toFixed(2)}</p>
                      <p className="text-gray-400 text-sm">Revenue</p>
                    </div>
                  </div>
                ))}
              </div>
            </ChartCard>
          </div>
        </div>

        {/* Game Day Performance */}
        <ChartCard title="Game Day Performance" subtitle="Revenue and attendance during game days">
          <div className="overflow-x-auto">
            <table className="w-full text-white">
              <thead>
                <tr className="border-b border-gray-600">
                  <th className="text-left p-4">Date</th>
                  <th className="text-left p-4">Game</th>
                  <th className="text-right p-4">Attendance</th>
                  <th className="text-right p-4">Revenue</th>
                  <th className="text-right p-4">Avg Spend</th>
                </tr>
              </thead>
              <tbody>
                {analyticsData.gameDayPerformance.map((game, index) => (
                  <tr key={index} className="border-b border-gray-700/50 hover:bg-white/5">
                    <td className="p-4">{new Date(game.date).toLocaleDateString()}</td>
                    <td className="p-4">{game.game}</td>
                    <td className="p-4 text-right">{game.attendance.toLocaleString()}</td>
                    <td className="p-4 text-right">${game.revenue.toLocaleString()}</td>
                    <td className="p-4 text-right">${game.avgSpend.toFixed(2)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </ChartCard>
      </div>
    </div>
  );
};

// Helper Components
interface MetricCardProps {
  title: string;
  value: string;
  change: string;
  icon: React.ReactNode;
  trend: 'up' | 'down';
}

const MetricCard: React.FC<MetricCardProps> = ({ title, value, change, icon, trend }) => (
  <div className="bg-white/10 backdrop-blur-sm border border-white/20 rounded-xl p-6">
    <div className="flex items-center justify-between mb-4">
      <div className="p-2 bg-white/10 rounded-lg">
        {icon}
      </div>
      <span className={`text-sm font-medium ${trend === 'up' ? 'text-green-400' : 'text-red-400'}`}>
        {change}
      </span>
    </div>
    <div>
      <p className="text-2xl font-bold text-white mb-1">{value}</p>
      <p className="text-gray-300 text-sm">{title}</p>
    </div>
  </div>
);

interface ChartCardProps {
  title: string;
  subtitle?: string;
  children: React.ReactNode;
}

const ChartCard: React.FC<ChartCardProps> = ({ title, subtitle, children }) => (
  <div className="bg-white/10 backdrop-blur-sm border border-white/20 rounded-xl p-6">
    <div className="mb-6">
      <h3 className="text-xl font-bold text-white mb-1">{title}</h3>
      {subtitle && <p className="text-gray-300 text-sm">{subtitle}</p>}
    </div>
    {children}
  </div>
);

export default AnalyticsDashboard; 