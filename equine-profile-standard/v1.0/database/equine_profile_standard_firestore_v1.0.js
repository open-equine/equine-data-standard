// ============================================================
// Equine Profile Standard
// Firebase Firestore Schema v1.0
// Collections: stables, horses, pedigree, owners
// Location: equine-profile-standard/v1.0/database/
// Published by Open Equine — TechXZone Pvt Ltd
// MIT Licensed | openequine.org | contact@openequine.org
// ============================================================

// ------------------------------------------------------------
// FIRESTORE COLLECTION STRUCTURE
//
// /stables/{stable_id}
// /horses/{horse_id}
// /horses/{horse_id}/pedigree/{pedigree_id}   <- subcollection
// /horses/{horse_id}/owners/{owner_id}        <- subcollection
// ------------------------------------------------------------

// ============================================================
// SECURITY RULES
// Firestore Security Rules v2
// Deploy via Firebase Console or Firebase CLI:
//   firebase deploy --only firestore:rules
// ============================================================

const firestoreRules = `
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Stables — public read, authenticated write
    match /stables/{stable_id} {
      allow read:  if true;
      allow write: if request.auth != null;
    }

    // Horses — public read, authenticated write
    match /horses/{horse_id} {
      allow read:  if true;
      allow write: if request.auth != null;

      // Pedigree subcollection
      match /pedigree/{pedigree_id} {
        allow read:  if true;
        allow write: if request.auth != null;
      }

      // Owners subcollection
      match /owners/{owner_id} {
        allow read:  if true;
        allow write: if request.auth != null;
      }
    }
  }
}
`;


// ============================================================
// COLLECTION: stables
// Path: /stables/{stable_id}
//
// Document structure:
// {
//   stable_id:       string  (document ID)
//   stable_name:     string  required
//   stable_location: string  full free text address
//   address_line1:   string
//   address_line2:   string
//   city:            string
//   state:           string
//   country:         string
//   pincode:         string  string to handle leading zeros
//   created_at:      Timestamp
//   updated_at:      Timestamp
// }
// ============================================================

// Example: Create a stable document
// import { collection, doc, setDoc, serverTimestamp } from "firebase/firestore";
//
// await setDoc(doc(db, "stables", stableId), {
//   stable_name:     "Rathore Stud Farm",
//   stable_location: "Jodhpur, Rajasthan, India",
//   city:            "Jodhpur",
//   state:           "Rajasthan",
//   country:         "India",
//   pincode:         "342001",
//   created_at:      serverTimestamp(),
//   updated_at:      serverTimestamp()
// });


// ============================================================
// COLLECTION: horses
// Path: /horses/{horse_id}
//
// Document structure:
// {
//   horse_id:    string  (document ID)
//   horse_name:  string  required
//   dob:         string  ISO 8601: YYYY-MM-DD
//   breed:       string
//   gender:      string  mare | stallion | gelding
//   color:       string
//   ueln:        string  15 char alphanumeric
//   passport_no: string  travel passport number
//   microchip:   string  15-digit ISO 11784/11785
//   created_at:  Timestamp
//   updated_at:  Timestamp
// }
// ============================================================

// Example: Create a horse document
// await setDoc(doc(db, "horses", horseId), {
//   horse_name:  "Rajputana Bahadur",
//   dob:         "2019-03-15",
//   breed:       "Marwari",
//   gender:      "stallion",
//   color:       "Bay",
//   ueln:        "IN2019MARW00001",
//   passport_no: "AIMHS-2019-00432",
//   microchip:   "985141002345678",
//   created_at:  serverTimestamp(),
//   updated_at:  serverTimestamp()
// });


// ============================================================
// SUBCOLLECTION: pedigree
// Path: /horses/{horse_id}/pedigree/{pedigree_id}
//
// Document structure:
// {
//   pedigree_id:           string  (document ID)
//   sire_name:             string
//   sire_horse_id:         string  reference to /horses/{horse_id}
//   dam_name:              string
//   dam_horse_id:          string  reference to /horses/{horse_id}
//   sire_of_sire_name:     string
//   sire_of_sire_horse_id: string
//   dam_of_sire_name:      string
//   dam_of_sire_horse_id:  string
//   sire_of_dam_name:      string
//   sire_of_dam_horse_id:  string
//   dam_of_dam_name:       string
//   dam_of_dam_horse_id:   string
//   description:           string  extended lineage notes
//   created_at:            Timestamp
//   updated_at:            Timestamp
// }
// ============================================================

// Example: Create a pedigree subcollection document
// import { collection, addDoc, serverTimestamp } from "firebase/firestore";
//
// await addDoc(collection(db, "horses", horseId, "pedigree"), {
//   sire_name:         "Desert Storm",
//   dam_name:          "Rajmahal Rani",
//   sire_of_sire_name: "Thar Thunder",
//   dam_of_sire_name:  "Marwar Princess",
//   sire_of_dam_name:  "Golden Dunes",
//   dam_of_dam_name:   "Jaipur Rose",
//   description:       "Descends from Jodhpur royal stables bloodline.",
//   created_at:        serverTimestamp(),
//   updated_at:        serverTimestamp()
// });


// ============================================================
// SUBCOLLECTION: owners
// Path: /horses/{horse_id}/owners/{owner_id}
//
// Document structure:
// {
//   owner_id:          string  (document ID)
//   owner_name:        string  required
//   owner_contact:     string  required — phone or email
//   owner_stable_id:   string  reference to /stables/{stable_id}
//   breeder_name:      string
//   breeder_contact:   string
//   breeder_stable_id: string  reference to /stables/{stable_id}
//   created_at:        Timestamp
//   updated_at:        Timestamp
// }
// ============================================================

// Example: Create an owner subcollection document
// await addDoc(collection(db, "horses", horseId, "owners"), {
//   owner_name:      "Vikram Singh Rathore",
//   owner_contact:   "+91-9876543210",
//   owner_stable_id: "stable-uuid-here",
//   breeder_name:    "Jodhpur Heritage Stables",
//   created_at:      serverTimestamp(),
//   updated_at:      serverTimestamp()
// });


// ============================================================
// COMPOSITE INDEXES
// Deploy via Firebase Console or firestore.indexes.json
// ============================================================

const firestoreIndexes = {
  indexes: [
    {
      collectionGroup: "horses",
      queryScope: "COLLECTION",
      fields: [
        { fieldPath: "breed",      order: "ASCENDING" },
        { fieldPath: "created_at", order: "DESCENDING" }
      ]
    },
    {
      collectionGroup: "horses",
      queryScope: "COLLECTION",
      fields: [
        { fieldPath: "gender",     order: "ASCENDING" },
        { fieldPath: "breed",      order: "ASCENDING" },
        { fieldPath: "created_at", order: "DESCENDING" }
      ]
    },
    {
      collectionGroup: "stables",
      queryScope: "COLLECTION",
      fields: [
        { fieldPath: "country", order: "ASCENDING" },
        { fieldPath: "city",    order: "ASCENDING" }
      ]
    }
  ],
  fieldOverrides: []
};

// ============================================================
// End of Schema
// Equine Profile Standard v1.0
// ============================================================
