// lib/services/communication/contact_service.dart
// Complete Contact Management Service

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../utils/logger.dart';
import '../../utils/error_handler.dart';

class ContactService {
  static final ContactService _instance = ContactService._internal();
  factory ContactService() => _instance;
  ContactService._internal();
  
  List<Contact> _contacts = [];
  bool _isInitialized = false;
  bool _hasPermission = false;
  
  Future<void> initialize() async {
    try {
      final status = await Permission.contacts.status;
      if (status.isGranted) {
        _hasPermission = true;
        await _loadContacts();
        _isInitialized = true;
        Logger().info('Contact service initialized with ${_contacts.length} contacts', tag: 'CONTACT');
      } else {
        Logger().warning('Contact permission not granted', tag: 'CONTACT');
      }
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'Contact Init');
    }
  }
  
  Future<bool> requestPermission() async {
    final status = await Permission.contacts.request();
    _hasPermission = status.isGranted;
    if (_hasPermission) {
      await _loadContacts();
      _isInitialized = true;
    }
    return _hasPermission;
  }
  
  Future<void> _loadContacts() async {
    try {
      _contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );
      Logger().info('Loaded ${_contacts.length} contacts', tag: 'CONTACT');
    } catch (e) {
      Logger().error('Error loading contacts', tag: 'CONTACT', error: e);
      _contacts = [];
    }
  }
  
  Future<List<Contact>> getAllContacts() async {
    if (!_hasPermission) {
      final granted = await requestPermission();
      if (!granted) return [];
    }
    if (!_isInitialized) await _loadContacts();
    return _contacts;
  }
  
  Future<Contact?> findContactByName(String name) async {
    if (!_hasPermission) return null;
    
    final lowerName = name.toLowerCase().trim();
    
    // Exact match first
    for (var contact in _contacts) {
      if (contact.displayName.toLowerCase() == lowerName) {
        return contact;
      }
    }
    
    // Partial match
    for (var contact in _contacts) {
      if (contact.displayName.toLowerCase().contains(lowerName)) {
        return contact;
      }
    }
    
    return null;
  }
  
  Future<Contact?> findContactByNumber(String number) async {
    if (!_hasPermission) return null;
    
    final cleanNumber = number.replaceAll(RegExp(r'[^0-9+]'), '');
    
    for (var contact in _contacts) {
      for (var phone in contact.phones) {
        final contactNumber = phone.number.replaceAll(RegExp(r'[^0-9+]'), '');
        if (contactNumber == cleanNumber || contactNumber.contains(cleanNumber)) {
          return contact;
        }
      }
    }
    
    return null;
  }
  
  Future<List<Contact>> searchContacts(String query) async {
    if (!_hasPermission) return [];
    
    final lowerQuery = query.toLowerCase().trim();
    final results = <Contact>[];
    
    for (var contact in _contacts) {
      if (contact.displayName.toLowerCase().contains(lowerQuery)) {
        results.add(contact);
      }
    }
    
    return results;
  }
  
  Future<List<Map<String, dynamic>>> getContactsForDisplay() async {
    final contacts = await getAllContacts();
    final result = <Map<String, dynamic>>[];
    
    for (var contact in contacts) {
      result.add({
        'id': contact.id,
        'name': contact.displayName,
        'phoneNumbers': contact.phones.map((p) => p.number).toList(),
        'emails': contact.emails.map((e) => e.address).toList(),
        'hasPhoto': contact.photo != null,
      });
    }
    
    return result;
  }
  
  Future<bool> addContact({
    required String firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
  }) async {
    try {
      if (!_hasPermission) return false;
      
      final contact = Contact()
        ..name.first = firstName
        ..name.last = lastName ?? '';
      
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        contact.phones.add(Phone(phoneNumber));
      }
      if (email != null && email.isNotEmpty) {
        contact.emails.add(Email(email));
      }
      
      await contact.insert();
      await _loadContacts(); // Refresh list
      Logger().info('Added contact: $firstName', tag: 'CONTACT');
      return true;
      
    } catch (e) {
      Logger().error('Add contact error', tag: 'CONTACT', error: e);
      return false;
    }
  }
  
  Future<bool> updateContact(Contact contact) async {
    try {
      if (!_hasPermission) return false;
      
      await contact.update();
      await _loadContacts();
      Logger().info('Updated contact: ${contact.displayName}', tag: 'CONTACT');
      return true;
    } catch (e) {
      Logger().error('Update contact error', tag: 'CONTACT', error: e);
      return false;
    }
  }
  
  Future<bool> deleteContact(String contactId) async {
    try {
      if (!_hasPermission) return false;
      
      final contact = _contacts.firstWhere((c) => c.id == contactId);
      await contact.delete();
      await _loadContacts();
      Logger().info('Deleted contact: ${contact.displayName}', tag: 'CONTACT');
      return true;
    } catch (e) {
      Logger().error('Delete contact error', tag: 'CONTACT', error: e);
      return false;
    }
  }
  
  Future<String?> getContactName(String number) async {
    final contact = await findContactByNumber(number);
    return contact?.displayName;
  }
  
  Future<List<String>> getContactNumbers(String name) async {
    final contact = await findContactByName(name);
    if (contact != null) {
      return contact.phones.map((p) => p.number).toList();
    }
    return [];
  }
  
  Future<Map<String, dynamic>> getContactStats() async {
    if (!_hasPermission) {
      return {
        'total': 0,
        'withPhone': 0,
        'withEmail': 0,
        'withPhoto': 0,
        'hasPermission': false,
      };
    }
    
    int total = _contacts.length;
    int withPhone = _contacts.where((c) => c.phones.isNotEmpty).length;
    int withEmail = _contacts.where((c) => c.emails.isNotEmpty).length;
    int withPhoto = _contacts.where((c) => c.photo != null).length;
    
    return {
      'total': total,
      'withPhone': withPhone,
      'withEmail': withEmail,
      'withPhoto': withPhoto,
      'hasPermission': true,
    };
  }
  
  Future<bool> hasPermission() async {
    return await Permission.contacts.isGranted;
  }
  
  void refresh() async {
    await _loadContacts();
  }
}