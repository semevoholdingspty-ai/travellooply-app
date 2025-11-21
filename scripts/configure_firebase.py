#!/usr/bin/env python3
"""
Firebase Configuration Script for Travellooply
Helps configure Firebase by creating necessary files from user input
"""

import json
import os
import sys

def create_firebase_options(config):
    """Create firebase_options.dart from configuration"""
    
    template = f'''import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {{
  static FirebaseOptions get currentPlatform {{
    if (kIsWeb) {{
      return web;
    }}
    switch (defaultTargetPlatform) {{
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }}
  }}

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: '{config['web']['apiKey']}',
    appId: '{config['web']['appId']}',
    messagingSenderId: '{config['web']['messagingSenderId']}',
    projectId: '{config['web']['projectId']}',
    authDomain: '{config['web']['authDomain']}',
    storageBucket: '{config['web']['storageBucket']}',
    measurementId: '{config['web'].get('measurementId', '')}',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: '{config['android']['apiKey']}',
    appId: '{config['android']['appId']}',
    messagingSenderId: '{config['android']['messagingSenderId']}',
    projectId: '{config['android']['projectId']}',
    storageBucket: '{config['android']['storageBucket']}',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: '{config.get('ios', {}).get('apiKey', 'YOUR_IOS_API_KEY')}',
    appId: '{config.get('ios', {}).get('appId', 'YOUR_IOS_APP_ID')}',
    messagingSenderId: '{config.get('ios', {}).get('messagingSenderId', 'YOUR_SENDER_ID')}',
    projectId: '{config.get('ios', {}).get('projectId', 'YOUR_PROJECT_ID')}',
    storageBucket: '{config.get('ios', {}).get('storageBucket', 'YOUR_PROJECT.appspot.com')}',
    iosBundleId: 'com.travellooply.app',
  );
}}
'''
    
    return template

def extract_android_config(google_services_path):
    """Extract Android configuration from google-services.json"""
    try:
        with open(google_services_path, 'r') as f:
            data = json.load(f)
        
        client = data['client'][0]
        project = data['project_info']
        
        return {
            'apiKey': client['api_key'][0]['current_key'],
            'appId': client['client_info']['mobilesdk_app_id'],
            'messagingSenderId': project['project_number'],
            'projectId': project['project_id'],
            'storageBucket': project['storage_bucket'],
        }
    except Exception as e:
        print(f"Error extracting Android config: {e}")
        return None

def main():
    print("🔥 Firebase Configuration Script for Travellooply")
    print("=" * 60)
    
    # Check for google-services.json
    google_services_path = 'android/app/google-services.json'
    
    if not os.path.exists(google_services_path):
        print("\n⚠️  google-services.json not found at android/app/")
        print("\nPlease:")
        print("1. Download google-services.json from Firebase Console")
        print("2. Place it at: android/app/google-services.json")
        print("3. Run this script again")
        return
    
    print(f"\n✅ Found google-services.json")
    
    # Extract Android configuration
    android_config = extract_android_config(google_services_path)
    
    if not android_config:
        print("❌ Failed to extract Android configuration")
        return
    
    print("✅ Extracted Android configuration")
    print(f"   Project ID: {android_config['projectId']}")
    print(f"   App ID: {android_config['appId']}")
    
    # Get Web configuration
    print("\n📱 Now, please provide your Web app configuration:")
    print("(You can find this in Firebase Console → Project Settings → Web Apps)")
    print("\nEnter the firebaseConfig object values:")
    
    web_config = {}
    
    web_config['apiKey'] = input("\nWeb API Key: ").strip()
    web_config['appId'] = input("Web App ID: ").strip()
    web_config['messagingSenderId'] = input("Messaging Sender ID: ").strip()
    web_config['projectId'] = input("Project ID: ").strip()
    web_config['authDomain'] = input("Auth Domain (e.g., project-id.firebaseapp.com): ").strip()
    web_config['storageBucket'] = input("Storage Bucket (e.g., project-id.appspot.com): ").strip()
    web_config['measurementId'] = input("Measurement ID (optional, press Enter to skip): ").strip()
    
    # Create firebase_options.dart
    config = {
        'web': web_config,
        'android': android_config,
    }
    
    firebase_options_content = create_firebase_options(config)
    
    # Write firebase_options.dart
    output_path = 'lib/firebase_options.dart'
    with open(output_path, 'w') as f:
        f.write(firebase_options_content)
    
    print(f"\n✅ Created {output_path}")
    
    # Update firebase_config.dart
    config_file_path = 'lib/config/firebase_config.dart'
    if os.path.exists(config_file_path):
        with open(config_file_path, 'r') as f:
            content = f.read()
        
        content = content.replace(
            'static const bool USE_REAL_FIREBASE = false;',
            'static const bool USE_REAL_FIREBASE = true;'
        )
        
        with open(config_file_path, 'w') as f:
            f.write(content)
        
        print(f"✅ Updated {config_file_path} to use real Firebase")
    
    print("\n" + "=" * 60)
    print("🎉 Firebase configuration complete!")
    print("\nNext steps:")
    print("1. Rebuild your Flutter app: flutter build web --release")
    print("2. The app will now use real Firebase services")
    print("3. Create Firestore collections using the provided schema")
    print("\n📚 See FIREBASE_SETUP.md for detailed instructions")

if __name__ == '__main__':
    main()
