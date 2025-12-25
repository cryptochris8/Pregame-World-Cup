// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_intelligence.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameIntelligenceAdapter extends TypeAdapter<GameIntelligence> {
  @override
  final int typeId = 21;

  @override
  GameIntelligence read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameIntelligence(
      gameId: fields[0] as String,
      homeTeam: fields[1] as String,
      awayTeam: fields[2] as String,
      homeTeamRank: fields[3] as int?,
      awayTeamRank: fields[4] as int?,
      crowdFactor: fields[5] as double,
      isRivalryGame: fields[6] as bool,
      hasChampionshipImplications: fields[7] as bool,
      broadcastNetwork: fields[8] as String,
      expectedTvAudience: fields[9] as double,
      keyStorylines: (fields[10] as List).cast<String>(),
      teamStats: (fields[11] as Map).cast<String, dynamic>(),
      lastUpdated: fields[12] as DateTime,
      confidenceScore: fields[13] as double,
      venueRecommendations: fields[14] as VenueRecommendations,
    );
  }

  @override
  void write(BinaryWriter writer, GameIntelligence obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.gameId)
      ..writeByte(1)
      ..write(obj.homeTeam)
      ..writeByte(2)
      ..write(obj.awayTeam)
      ..writeByte(3)
      ..write(obj.homeTeamRank)
      ..writeByte(4)
      ..write(obj.awayTeamRank)
      ..writeByte(5)
      ..write(obj.crowdFactor)
      ..writeByte(6)
      ..write(obj.isRivalryGame)
      ..writeByte(7)
      ..write(obj.hasChampionshipImplications)
      ..writeByte(8)
      ..write(obj.broadcastNetwork)
      ..writeByte(9)
      ..write(obj.expectedTvAudience)
      ..writeByte(10)
      ..write(obj.keyStorylines)
      ..writeByte(11)
      ..write(obj.teamStats)
      ..writeByte(12)
      ..write(obj.lastUpdated)
      ..writeByte(13)
      ..write(obj.confidenceScore)
      ..writeByte(14)
      ..write(obj.venueRecommendations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameIntelligenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VenueRecommendationsAdapter extends TypeAdapter<VenueRecommendations> {
  @override
  final int typeId = 22;

  @override
  VenueRecommendations read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VenueRecommendations(
      expectedTrafficIncrease: fields[0] as double,
      staffingRecommendation: fields[1] as String,
      suggestedSpecials: (fields[2] as List).cast<String>(),
      inventoryAdvice: fields[3] as String,
      marketingOpportunity: fields[4] as String,
      revenueProjection: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, VenueRecommendations obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.expectedTrafficIncrease)
      ..writeByte(1)
      ..write(obj.staffingRecommendation)
      ..writeByte(2)
      ..write(obj.suggestedSpecials)
      ..writeByte(3)
      ..write(obj.inventoryAdvice)
      ..writeByte(4)
      ..write(obj.marketingOpportunity)
      ..writeByte(5)
      ..write(obj.revenueProjection);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VenueRecommendationsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
