#!/usr/bin/env python3
"""
Firestore Collections Creator for Travellooply
Creates all necessary Firestore collections with sample data

Prerequisites:
- Firebase Admin SDK service account key
- Python firebase-admin package: pip install firebase-admin
"""

import sys
import os
from datetime import datetime, timedelta
import random

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
    print("✅ firebase-admin imported successfully")
except ImportError as e:
    print(f"❌ Failed to import firebase-admin: {e}")
    print("📦 Please install: pip install firebase-admin")
    sys.exit(1)

# Sample data for realistic app experience
SAMPLE_USERNAMES = [
    "TravelPro_Sarah", "Wanderer_John", "Explorer_Maria", "Nomad_Alex",
    "Backpacker_Emma", "Globetrotter_Mike", "Journey_Lisa", "Voyager_Tom"
]

COUNTRIES = ["United States", "United Kingdom", "Spain", "France", "Germany", "Italy", "Japan", "Australia"]

ACTIVITY_TYPES = ["Explore", "Coffee", "Eat", "Walk", "Nightlife", "Chill", "Photography", "Museums", "Shopping"]

SOCIAL_VIBES = ["Introvert", "Friendly", "Highly Social"]

# San Francisco coordinates for demo
SF_COORDS = [
    {"lat": 37.7749, "lng": -122.4194},  # Downtown
    {"lat": 37.7849, "lng": -122.4094},  # Financial District
    {"lat": 37.7649, "lng": -122.4294},  # Mission
    {"lat": 37.7549, "lng": -122.4394},  # Castro
]

def initialize_firebase():
    """Initialize Firebase Admin SDK"""
    # Look for Firebase Admin SDK key in /opt/flutter/
    sdk_paths = [
        '/opt/flutter/firebase-admin-sdk.json',
    ]
    
    # Also check current directory
    for file in os.listdir('.'):
        if 'adminsdk' in file.lower() and file.endswith('.json'):
            sdk_paths.insert(0, file)
    
    cred_path = None
    for path in sdk_paths:
        if os.path.exists(path):
            cred_path = path
            break
    
    if not cred_path:
        print("❌ Firebase Admin SDK key not found")
        print("\nPlease:")
        print("1. Go to Firebase Console → Project Settings → Service Accounts")
        print("2. Generate new private key (Python)")
        print("3. Save as firebase-admin-sdk.json in this directory")
        return None
    
    try:
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        print(f"✅ Firebase initialized with {cred_path}")
        return firestore.client()
    except Exception as e:
        print(f"❌ Firebase initialization error: {e}")
        return None

def create_users_collection(db):
    """Create users collection with sample data"""
    print("\n📝 Creating users collection...")
    
    users_ref = db.collection('users')
    
    for i, username in enumerate(SAMPLE_USERNAMES):
        email = f"{username.lower().replace('_', '')}@example.com"
        country = random.choice(COUNTRIES)
        coord = random.choice(SF_COORDS)
        
        user_data = {
            'username': username,
            'email': email,
            'country': country,
            'languages': ['English'] if 'United' in country else ['English', random.choice(['Spanish', 'French', 'German'])],
            'travelIntent': random.choice(ACTIVITY_TYPES),
            'preferences': random.sample(ACTIVITY_TYPES, 5),
            'socialVibe': random.choice(SOCIAL_VIBES),
            'trustScore': random.randint(60, 95),
            'location': firestore.GeoPoint(coord['lat'], coord['lng']),
            'isOnline': random.choice([True, False]),
            'createdAt': firestore.SERVER_TIMESTAMP,
            'lastSeen': firestore.SERVER_TIMESTAMP,
            'isPremium': False,
        }
        
        doc_ref = users_ref.add(user_data)
        print(f"   ✅ Created user: {username} (ID: {doc_ref[1].id})")
    
    print(f"✅ Created {len(SAMPLE_USERNAMES)} users")

def create_circles_collection(db):
    """Create circles collection with sample data"""
    print("\n🔵 Creating circles collection...")
    
    circles_ref = db.collection('circles')
    users_ref = db.collection('users')
    
    # Get user IDs for members
    users = list(users_ref.limit(8).stream())
    user_ids = [user.id for user in users]
    
    for activity in ACTIVITY_TYPES[:4]:  # Create 4 circles
        coord = random.choice(SF_COORDS)
        member_count = random.randint(3, 7)
        members = random.sample(user_ids, min(member_count, len(user_ids)))
        
        circle_data = {
            'activityType': activity,
            'memberIds': members,
            'radius': random.randint(500, 1000),
            'centerLocation': firestore.GeoPoint(coord['lat'], coord['lng']),
            'createdAt': firestore.SERVER_TIMESTAMP,
            'expiresAt': datetime.now() + timedelta(hours=random.randint(6, 24)),
            'status': 'active',
            'creatorId': members[0] if members else user_ids[0],
        }
        
        doc_ref = circles_ref.add(circle_data)
        print(f"   ✅ Created circle: {activity} with {member_count} members (ID: {doc_ref[1].id})")
    
    print(f"✅ Created 4 circles")

def create_events_collection(db):
    """Create events collection with sample data"""
    print("\n📅 Creating events collection...")
    
    events_ref = db.collection('events')
    users_ref = db.collection('users')
    circles_ref = db.collection('circles')
    
    users = list(users_ref.limit(8).stream())
    circles = list(circles_ref.limit(4).stream())
    
    user_ids = [user.id for user in users]
    circle_ids = [circle.id for circle in circles]
    
    event_descriptions = {
        'Coffee': 'Coffee Meetup at Central Cafe',
        'Photography': 'Photography Walk in Old Town',
        'Eat': 'Dinner at Local Restaurant',
        'Walk': 'Scenic Walk around the Bay',
    }
    
    for i, activity in enumerate(['Coffee', 'Photography', 'Eat', 'Walk']):
        coord = random.choice(SF_COORDS)
        participant_count = random.randint(3, 6)
        participants = random.sample(user_ids, min(participant_count, len(user_ids)))
        
        start_hours = random.randint(2, 8)
        duration_minutes = random.choice([30, 45, 60])
        
        event_data = {
            'creatorId': participants[0] if participants else user_ids[0],
            'type': activity,
            'description': event_descriptions.get(activity, f'{activity} Event'),
            'maxParticipants': random.randint(5, 10),
            'participantIds': participants,
            'startTime': datetime.now() + timedelta(hours=start_hours),
            'endTime': datetime.now() + timedelta(hours=start_hours, minutes=duration_minutes),
            'location': firestore.GeoPoint(coord['lat'], coord['lng']),
            'status': 'upcoming',
            'circleId': circle_ids[i] if i < len(circle_ids) else None,
        }
        
        doc_ref = events_ref.add(event_data)
        print(f"   ✅ Created event: {activity} (ID: {doc_ref[1].id})")
    
    print(f"✅ Created 4 events")

def create_messages_collection(db):
    """Create messages collection with sample data"""
    print("\n💬 Creating messages collection...")
    
    messages_ref = db.collection('messages')
    circles_ref = db.collection('circles')
    users_ref = db.collection('users')
    
    circles = list(circles_ref.limit(2).stream())
    users = list(users_ref.limit(4).stream())
    
    sample_messages = [
        "Hey everyone! Excited to meet you all!",
        "What time are we meeting?",
        "I'll be there in 10 minutes",
        "This place looks great!",
        "Anyone know good spots nearby?",
    ]
    
    message_count = 0
    for circle in circles:
        circle_data = circle.to_dict()
        member_ids = circle_data.get('memberIds', [])
        
        # Create 3-5 messages per circle
        for i in range(random.randint(3, 5)):
            sender_id = random.choice(member_ids) if member_ids else users[0].id
            
            message_data = {
                'circleId': circle.id,
                'senderId': sender_id,
                'message': random.choice(sample_messages),
                'timestamp': firestore.SERVER_TIMESTAMP,
                'expiresAt': datetime.now() + timedelta(hours=24),
            }
            
            messages_ref.add(message_data)
            message_count += 1
    
    print(f"✅ Created {message_count} messages")

def main():
    print("🔥 Firestore Collections Creator for Travellooply")
    print("=" * 60)
    
    # Initialize Firebase
    db = initialize_firebase()
    if not db:
        return
    
    print("\n🚀 Creating Firestore collections with sample data...")
    
    try:
        # Create all collections
        create_users_collection(db)
        create_circles_collection(db)
        create_events_collection(db)
        create_messages_collection(db)
        
        print("\n" + "=" * 60)
        print("🎉 Firestore setup complete!")
        print("\n✅ Created collections:")
        print("   - users (8 sample users)")
        print("   - circles (4 active circles)")
        print("   - events (4 upcoming events)")
        print("   - messages (sample chat messages)")
        print("\n📱 Your Travellooply app is now ready with sample data!")
        
    except Exception as e:
        print(f"\n❌ Error creating collections: {e}")
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    main()
