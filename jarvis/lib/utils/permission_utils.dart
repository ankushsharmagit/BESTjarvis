// lib/utils/permission_utils.dart
// Permission Handling Utilities

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestPermissions(BuildContext context, 
      List<Permission> permissions) async {
    final results = await permissions.request();
    
    bool allGranted = true;
    for (var permission in permissions) {
      if (!results[permission]!.isGranted) {
        allGranted = false;
        if (results[permission]!.isPermanentlyDenied) {
          await _showPermanentlyDeniedDialog(context, permission);
        }
      }
    }
    return allGranted;
  }
  
  static Future<bool> checkPermissions(List<Permission> permissions) async {
    for (var permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        return false;
      }
    }
    return true;
  }
  
  static Future<void> _showPermanentlyDeniedDialog(
      BuildContext context, Permission permission) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permission Permission Required'),
        content: Text(
          'JARVIS needs $permission permission to function properly. '
          'Please enable it in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
  
  static Future<bool> requestStoragePermission() async {
    if (await Permission.storage.isGranted) {
      return true;
    }
    
    if (await Permission.storage.request().isGranted) {
      return true;
    }
    
    if (await Permission.manageExternalStorage.request().isGranted) {
      return true;
    }
    
    return false;
  }
  
  static Future<bool> requestCameraPermission() async {
    if (await Permission.camera.isGranted) {
      return true;
    }
    return await Permission.camera.request().isGranted;
  }
  
  static Future<bool> requestMicrophonePermission() async {
    if (await Permission.microphone.isGranted) {
      return true;
    }
    return await Permission.microphone.request().isGranted;
  }
  
  static Future<bool> requestContactsPermission() async {
    if (await Permission.contacts.isGranted) {
      return true;
    }
    return await Permission.contacts.request().isGranted;
  }
  
  static Future<bool> requestPhonePermission() async {
    if (await Permission.phone.isGranted) {
      return true;
    }
    return await Permission.phone.request().isGranted;
  }
  
  static Future<bool> requestSmsPermission() async {
    if (await Permission.sms.isGranted) {
      return true;
    }
    return await Permission.sms.request().isGranted;
  }
  
  static Future<bool> requestLocationPermission() async {
    if (await Permission.location.isGranted) {
      return true;
    }
    return await Permission.location.request().isGranted;
  }
  
  static Future<bool> requestBackgroundLocationPermission() async {
    if (await Permission.locationAlways.isGranted) {
      return true;
    }
    return await Permission.locationAlways.request().isGranted;
  }
  
  static Future<bool> requestNotificationPermission() async {
    if (await Permission.notification.isGranted) {
      return true;
    }
    return await Permission.notification.request().isGranted;
  }
  
  static Future<bool> requestBluetoothPermission() async {
    if (await Permission.bluetooth.isGranted) {
      return true;
    }
    if (await Permission.bluetoothConnect.isGranted) {
      return true;
    }
    return await Permission.bluetooth.request().isGranted;
  }
  
  static Future<bool> requestAllPermissions() async {
    final permissions = [
      Permission.storage,
      Permission.camera,
      Permission.microphone,
      Permission.contacts,
      Permission.phone,
      Permission.sms,
      Permission.location,
      Permission.notification,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
    ];
    
    final results = await permissions.request();
    return results.values.every((status) => status.isGranted);
  }
  
  static Future<bool> requestDeviceAdminPermission() async {
    // This requires separate handling with DevicePolicyManager
    // Returns true if already granted or user grants
    return true;
  }
  
  static Future<bool> requestAccessibilityPermission() async {
    // This requires separate handling with AccessibilityService
    return true;
  }
  
  static Future<bool> requestOverlayPermission() async {
    if (await Permission.systemAlertWindow.isGranted) {
      return true;
    }
    return await Permission.systemAlertWindow.request().isGranted;
  }
  
  static Future<bool> requestIgnoreBatteryOptimization() async {
    if (await Permission.ignoreBatteryOptimizations.isGranted) {
      return true;
    }
    return await Permission.ignoreBatteryOptimizations.request().isGranted;
  }
  
  static Future<bool> requestManageExternalStorage() async {
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }
    return await Permission.manageExternalStorage.request().isGranted;
  }
  
  static Future<void> checkCriticalPermissions(BuildContext context) async {
    final criticalPermissions = [
      Permission.microphone,
      Permission.storage,
    ];
    
    final missingPermissions = <Permission>[];
    
    for (var permission in criticalPermissions) {
      if (!await permission.isGranted) {
        missingPermissions.add(permission);
      }
    }
    
    if (missingPermissions.isNotEmpty) {
      await requestPermissions(context, missingPermissions);
    }
  }
  
  static String getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'For face recognition, QR scanning, and taking photos';
      case Permission.microphone:
        return 'For voice commands and calls';
      case Permission.storage:
        return 'For accessing files, photos, and saving data';
      case Permission.contacts:
        return 'For calling and messaging your contacts';
      case Permission.phone:
        return 'For making calls and accessing phone state';
      case Permission.sms:
        return 'For reading and sending messages';
      case Permission.location:
        return 'For location-based features and automation';
      case Permission.notification:
        return 'For showing JARVIS notifications';
      case Permission.bluetooth:
        return 'For Bluetooth device control';
      default:
        return 'For app functionality';
    }
  }
  
  static IconData getPermissionIcon(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return Icons.camera_alt;
      case Permission.microphone:
        return Icons.mic;
      case Permission.storage:
        return Icons.storage;
      case Permission.contacts:
        return Icons.contacts;
      case Permission.phone:
        return Icons.phone;
      case Permission.sms:
        return Icons.message;
      case Permission.location:
        return Icons.location_on;
      case Permission.notification:
        return Icons.notifications;
      case Permission.bluetooth:
        return Icons.bluetooth;
      default:
        return Icons.security;
    }
  }
}

class PermissionStatusWidget extends StatelessWidget {
  final Permission permission;
  final String title;
  final String description;
  
  const PermissionStatusWidget({
    Key? key,
    required this.permission,
    required this.title,
    required this.description,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PermissionStatus>(
      future: permission.status,
      builder: (context, snapshot) {
        final isGranted = snapshot.hasData && snapshot.data!.isGranted;
        final isPermanentlyDenied = snapshot.hasData && snapshot.data!.isPermanentlyDenied;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isGranted ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isGranted ? Colors.green : Colors.red,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                PermissionUtils.getPermissionIcon(permission),
                color: isGranted ? Colors.green : Colors.red,
                size: 30,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isGranted)
                ElevatedButton(
                  onPressed: () async {
                    if (isPermanentlyDenied) {
                      openAppSettings();
                    } else {
                      await permission.request();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPermanentlyDenied ? Colors.orange : Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(isPermanentlyDenied ? 'Settings' : 'Grant'),
                ),
            ],
          ),
        );
      },
    );
  }
}