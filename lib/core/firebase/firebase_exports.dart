// Centralized Firebase exports to eliminate redundant imports across the codebase
// This file consolidates all Firebase-related imports in one place

// Core Firebase
export 'package:firebase_core/firebase_core.dart';
export 'package:firebase_auth/firebase_auth.dart';
export 'package:cloud_firestore/cloud_firestore.dart';
export 'package:firebase_storage/firebase_storage.dart';
export 'package:firebase_app_check/firebase_app_check.dart';

// Firebase configuration
export '../../firebase_options.dart'; 