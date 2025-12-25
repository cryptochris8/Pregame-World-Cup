import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../config/token_config.dart';
import '../../domain/entities/token_entities.dart';

/// Service for interacting with Base blockchain
class BaseBlockchainService {
  final http.Client _httpClient;
  final BaseNetworkConfig _network;

  BaseBlockchainService({
    http.Client? httpClient,
    BaseNetworkConfig? network,
  })  : _httpClient = httpClient ?? http.Client(),
        _network = network ?? TokenConfig.activeNetwork;

  /// Get ETH balance for an address
  Future<BigInt> getEthBalance(String address) async {
    try {
      final response = await _rpcCall('eth_getBalance', [address, 'latest']);
      return BigInt.parse(response.replaceFirst('0x', ''), radix: 16);
    } catch (e) {
      throw BlockchainException('Failed to get ETH balance: $e');
    }
  }

  /// Get $PRE token balance for an address
  Future<TokenBalance> getTokenBalance(String address) async {
    final contractAddress = TokenConfig.contractAddress;
    if (contractAddress.isEmpty) {
      // Token not yet deployed - return mock balance for development
      return _getMockBalance(address);
    }

    try {
      // Encode balanceOf(address) call
      final data = _encodeBalanceOf(address);
      final response = await _rpcCall('eth_call', [
        {'to': contractAddress, 'data': data},
        'latest',
      ]);

      final rawBalance = BigInt.parse(response.replaceFirst('0x', ''), radix: 16);
      return TokenBalance(
        rawBalance: rawBalance,
        decimals: TokenConfig.tokenDecimals,
        symbol: TokenConfig.tokenSymbol,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw BlockchainException('Failed to get token balance: $e');
    }
  }

  /// Get current gas price
  Future<BigInt> getGasPrice() async {
    try {
      final response = await _rpcCall('eth_gasPrice', []);
      return BigInt.parse(response.replaceFirst('0x', ''), radix: 16);
    } catch (e) {
      throw BlockchainException('Failed to get gas price: $e');
    }
  }

  /// Get current block number
  Future<int> getBlockNumber() async {
    try {
      final response = await _rpcCall('eth_blockNumber', []);
      return int.parse(response.replaceFirst('0x', ''), radix: 16);
    } catch (e) {
      throw BlockchainException('Failed to get block number: $e');
    }
  }

  /// Get transaction receipt
  Future<Map<String, dynamic>?> getTransactionReceipt(String txHash) async {
    try {
      final response = await _rpcCall('eth_getTransactionReceipt', [txHash]);
      return response as Map<String, dynamic>?;
    } catch (e) {
      throw BlockchainException('Failed to get transaction receipt: $e');
    }
  }

  /// Wait for transaction confirmation
  Future<bool> waitForConfirmation(String txHash, {int maxAttempts = 30}) async {
    for (var i = 0; i < maxAttempts; i++) {
      final receipt = await getTransactionReceipt(txHash);
      if (receipt != null) {
        final status = receipt['status'];
        return status == '0x1';
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    return false;
  }

  /// Get network info
  Map<String, dynamic> getNetworkInfo() {
    return {
      'name': _network.name,
      'chainId': _network.chainId,
      'chainIdHex': _network.chainIdHex,
      'rpcUrl': _network.rpcUrl,
      'blockExplorer': _network.blockExplorer,
      'isTestnet': _network.isTestnet,
    };
  }

  /// Check if network is available
  Future<bool> isNetworkAvailable() async {
    try {
      await getBlockNumber();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validate an Ethereum address
  bool isValidAddress(String address) {
    if (!address.startsWith('0x')) return false;
    if (address.length != 42) return false;
    try {
      BigInt.parse(address.substring(2), radix: 16);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get explorer URL for transaction
  String getTxExplorerUrl(String txHash) => _network.txUrl(txHash);

  /// Get explorer URL for address
  String getAddressExplorerUrl(String address) => _network.addressUrl(address);

  /// Get explorer URL for token
  String getTokenExplorerUrl() => _network.tokenUrl(TokenConfig.contractAddress);

  // Private methods

  Future<dynamic> _rpcCall(String method, List<dynamic> params) async {
    final body = jsonEncode({
      'jsonrpc': '2.0',
      'id': DateTime.now().millisecondsSinceEpoch,
      'method': method,
      'params': params,
    });

    final response = await _httpClient.post(
      Uri.parse(_network.rpcUrl),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw BlockchainException('RPC call failed: ${response.statusCode}');
    }

    final json = jsonDecode(response.body);
    if (json['error'] != null) {
      throw BlockchainException('RPC error: ${json['error']['message']}');
    }

    return json['result'];
  }

  String _encodeBalanceOf(String address) {
    // Function selector for balanceOf(address)
    const selector = '0x70a08231';
    // Pad address to 32 bytes
    final paddedAddress = address.substring(2).padLeft(64, '0');
    return '$selector$paddedAddress';
  }

  /// Mock balance for development (before token deployment)
  TokenBalance _getMockBalance(String address) {
    // Generate a deterministic mock balance based on address
    final hash = address.hashCode.abs();
    final mockAmount = (hash % 10000) + 100; // 100 to 10,100 tokens
    final rawBalance = BigInt.from(mockAmount) * BigInt.from(10).pow(18);

    return TokenBalance(
      rawBalance: rawBalance,
      decimals: TokenConfig.tokenDecimals,
      symbol: TokenConfig.tokenSymbol,
      lastUpdated: DateTime.now(),
    );
  }

  void dispose() {
    _httpClient.close();
  }
}

/// Exception for blockchain operations
class BlockchainException implements Exception {
  final String message;
  BlockchainException(this.message);

  @override
  String toString() => 'BlockchainException: $message';
}

/// Service for wallet connection (WalletConnect / deep links)
class WalletConnectionService {
  WalletConnection? _currentConnection;
  final _connectionController = StreamController<WalletConnection?>.broadcast();

  Stream<WalletConnection?> get connectionStream => _connectionController.stream;
  WalletConnection? get currentConnection => _currentConnection;
  bool get isConnected => _currentConnection?.isConnected ?? false;

  /// Connect to Coinbase Wallet
  Future<WalletConnection> connectCoinbaseWallet() async {
    // In production, this would use Coinbase Wallet SDK
    // For now, simulate connection for development
    return _simulateConnection(WalletProvider.coinbaseWallet);
  }

  /// Connect via WalletConnect
  Future<WalletConnection> connectWalletConnect() async {
    // In production, this would use WalletConnect v2
    return _simulateConnection(WalletProvider.walletConnect);
  }

  /// Connect to MetaMask
  Future<WalletConnection> connectMetaMask() async {
    // In production, this would use MetaMask SDK
    return _simulateConnection(WalletProvider.metaMask);
  }

  /// Disconnect current wallet
  Future<void> disconnect() async {
    _currentConnection = _currentConnection?.copyWith(isConnected: false);
    _connectionController.add(null);
    _currentConnection = null;
  }

  /// Restore previous session
  Future<WalletConnection?> restoreSession() async {
    // In production, this would check for persisted session
    return null;
  }

  /// Request signature from wallet
  Future<String> signMessage(String message) async {
    if (_currentConnection == null) {
      throw WalletException('No wallet connected');
    }
    // In production, this would request signature via wallet
    throw WalletException('Signing not implemented in development mode');
  }

  /// Send transaction via wallet
  Future<String> sendTransaction({
    required String to,
    required BigInt value,
    String? data,
  }) async {
    if (_currentConnection == null) {
      throw WalletException('No wallet connected');
    }
    // In production, this would send transaction via wallet
    throw WalletException('Transactions not implemented in development mode');
  }

  // Development simulation
  Future<WalletConnection> _simulateConnection(WalletProvider provider) async {
    await Future.delayed(const Duration(seconds: 1));

    // Generate a mock address
    final mockAddress = '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16).padLeft(40, '0')}';

    _currentConnection = WalletConnection(
      address: mockAddress,
      provider: provider,
      connectedAt: DateTime.now(),
      isConnected: true,
    );

    _connectionController.add(_currentConnection);
    return _currentConnection!;
  }

  void dispose() {
    _connectionController.close();
  }
}

/// Exception for wallet operations
class WalletException implements Exception {
  final String message;
  WalletException(this.message);

  @override
  String toString() => 'WalletException: $message';
}
