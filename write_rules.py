with open('firestore.rules', 'w', encoding='utf-8') as f:
    f.write("""rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}""")
print("Rules file written")