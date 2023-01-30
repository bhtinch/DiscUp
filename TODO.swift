//
//  TODO.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 8/27/22.
//

/*
 DONE:
 -  BUY Screens converted over
 -  SELL Screens converted over
 -  Change Settings to Profile (MVP)
 
 TODO:
 -  Connect back end to UI (MVP) - had to pause to implement a login screen into the start up flow before can test back end
 -  Connect Messaging (MVP)
 -  Login Screen Update (MVP)
 -  Update UI screens Nav bar and titles (MVP)
 -  Edge, Error, and Loading (MVP)
 -  Improved Search (MVP)
 -  Login with Apple / Google / Facebook
 
 FIREBASE NOTES:
 Realtime DB vs Firestore
 -  RTDB's queries are too limited to support product searching (you can only sort OR filter in one query, but not both)
 -  Firestore is pay per transaction operation (read, write, delete)
 -  RTDB is pay per data quantity transferred, no limit on number of fetches (more or less)
 
 -  RTDB is simple and efficient but limited on querying and customization
 -  Firestore is more query-able and flexible
 
 Firestore Data Structure
 -  going to use a subcollection structure
 
 -  POSTINGDAY / {itemID}    where structure is 'COLLECTION / {document} / COLLECTION / {document} / ...'
 
 -  Firestore only allows a single range clause per compound query, which means performing query of lat and long within a bounding box is not possible
    i.e. minLat < someLat < maxLat && minLong < someLong < maxLong
 
 -  so have to use Geohash solution to create single string - see Firestore docs under 'solutions' section
 -  use helper library - pod 'GeoFire/Utils'
 -  see firestore-smoketest reference project @ /Users/btincher/Documents/Reference Projects/snippets-ios/firestore/swift
 
 -  can possibly create a new collection for every new day, so that market item results can be more quickly fetched
 
 -  query current day, within radius of location (geohash value), sorted by posting time... then can repeat query for previous day(s) to get more results if/when needed
 
 -  All day collections will be written to and read based on the user provided timezone (timezone provided in the fetch query, or timezone of the item location being saved)
 
 -  In this way, a user will see the current items that are available for the timezone that is applicable (usually will just be the user's current location timezone, but user could do a custom search in a different timezone or add an item to a timezone that is not their current physical location.
 */
