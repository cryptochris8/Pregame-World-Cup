import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pregame_world_cup/services/espn_service.dart';
import 'package:pregame_world_cup/features/venue_portal/venue_portal.dart';
import 'package:pregame_world_cup/injection_container.dart' as di;

/// Enhanced venue dashboard powered by ESPN API
/// Provides actionable intelligence for game day planning
class VenueIntelligenceDashboard extends StatefulWidget {
  final String venueId;
  final String venueName;

  const VenueIntelligenceDashboard({
    super.key,
    required this.venueId,
    required this.venueName,
  });

  @override
  State<VenueIntelligenceDashboard> createState() => _VenueIntelligenceDashboardState();
}

class _VenueIntelligenceDashboardState extends State<VenueIntelligenceDashboard> {
  final ESPNService _espnService = ESPNService();
  List<Map<String, dynamic>> _upcomingGames = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGameIntelligence();
  }

  Future<void> _loadGameIntelligence() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get current games from ESPN
      final currentGames = await _espnService.getCurrentGames();
      
      setState(() {
        _upcomingGames = currentGames.take(5).toList(); // Show first 5 games
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load game intelligence: $e';
      });
    }
  }

  void _openVenuePortal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => di.sl<VenueEnhancementCubit>()
            ..loadEnhancement(widget.venueId, venueName: widget.venueName),
          child: VenuePortalHomeScreen(
            venueId: widget.venueId,
            venueName: widget.venueName,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.venueName,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'ESPN Game Intelligence',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGameIntelligence,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Venue Portal',
            onPressed: _openVenuePortal,
          ),
        ],
      ),
      body: _isLoading 
        ? _buildLoadingScreen()
        : _errorMessage != null 
          ? _buildErrorScreen()
          : _buildDashboard(),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)),
          SizedBox(height: 16),
          Text('Loading ESPN Game Intelligence...', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(_errorMessage!, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadGameIntelligence, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _loadGameIntelligence,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ESPN Connection Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.withOpacity(0.2), Colors.green.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ESPN API Connected', style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Real-time game intelligence active', style: TextStyle(color: Colors.green, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text('${_upcomingGames.length} games', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // Venue Portal CTA
            _buildVenuePortalCard(),

            const SizedBox(height: 24),

            const Text('ESPN Game Intelligence', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            if (_upcomingGames.isEmpty)
              _buildNoGamesCard()
            else
              ..._upcomingGames.map((game) => _buildSimpleGameCard(game)),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleGameCard(Map<String, dynamic> game) {
    // Extract basic game info
    final gameName = game['name'] ?? 'Unknown Game';
    final gameDate = game['date'] ?? '';
    final status = game['status']?['type']?['name'] ?? 'Scheduled';
    
    // Mock crowd factor calculation
    final crowdFactor = 1.5 + (game['id'].hashCode % 15) / 10.0; // Mock: 1.5-3.0x
    final isHighImpact = crowdFactor >= 2.0;
    final projectedRevenue = (2500 * crowdFactor).round();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1E293B),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    gameName,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isHighImpact ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${crowdFactor.toStringAsFixed(1)}x',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Game details
            Text('Date: $gameDate', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text('Status: $status', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            
            const SizedBox(height: 12),
            
            // Revenue projection
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.attach_money, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Projected Revenue: \$$projectedRevenue',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Basic recommendations
            _buildSimpleRecommendations(crowdFactor, isHighImpact),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleRecommendations(double crowdFactor, bool isHighImpact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recommendations', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        
        if (isHighImpact) ...[
          _buildRecommendationRow(Icons.people, 'Staff 2-3x normal levels', Colors.blue),
          _buildRecommendationRow(Icons.inventory, 'Stock extra beer and wings', Colors.orange),
          _buildRecommendationRow(Icons.campaign, 'Promote on social media', Colors.purple),
        ] else ...[
          _buildRecommendationRow(Icons.people, 'Normal staffing adequate', Colors.green),
          _buildRecommendationRow(Icons.inventory, 'Standard inventory levels', Colors.green),
        ],
      ],
    );
  }

  Widget _buildRecommendationRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: color, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildVenuePortalCard() {
    return GestureDetector(
      onTap: _openVenuePortal,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.withOpacity(0.2), Colors.orange.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.store, color: Colors.amber, size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Venue Owner Portal',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage broadcasts, specials, TV setup & more',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.amber, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNoGamesCard() {
    return const Card(
      color: Color(0xFF1E293B),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.sports_soccer, size: 64, color: Colors.white38),
            SizedBox(height: 16),
            Text('No upcoming games found', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Game intelligence will appear here when upcoming games are scheduled.', style: TextStyle(color: Colors.white54, fontSize: 14), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
} 