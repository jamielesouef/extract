import SwiftData
import Foundation

// MARK: - Model Definition
// In Swift 6, @Model classes are NOT main actor isolated by default
// They run in the context of their ModelContext's actor
@Model
final class Person {
    var name: String
    var age: Int
    var email: String
    
    init(name: String, age: Int, email: String) {
        self.name = name
        self.age = age
        self.email = email
    }
}

// MARK: - Sendable Data Transfer Objects
struct PersonData: Sendable {
    let name: String
    let age: Int
    let email: String
}

struct PersonUpdate: Sendable {
    let id: PersistentIdentifier
    let name: String?
    let age: Int?
    let email: String?
}

// MARK: - Model Actor
@ModelActor
actor PersonStore {
    
    // ✅ CORRECT: All @Model operations happen within the actor's context
    func addPerson(data: PersonData) throws {
        // Creating the model directly in the actor - no main actor issues
        let person = Person(
            name: data.name,
            age: data.age,
            email: data.email
        )
        modelContext.insert(person)
        try modelContext.save()
    }
    
    func updatePerson(_ update: PersonUpdate) throws {
        guard let person = modelContext.model(for: update.id) as? Person else {
            throw PersonStoreError.personNotFound
        }
        
        // Accessing properties within the same actor context - no isolation issues
        if let name = update.name { person.name = name }
        if let age = update.age { person.age = age }
        if let email = update.email { person.email = email }
        
        try modelContext.save()
    }
    
    func getPerson(id: PersistentIdentifier) throws -> PersonData? {
        guard let person = modelContext.model(for: id) as? Person else {
            return nil
        }
        
        // Reading properties and returning Sendable data - safe
        return PersonData(
            name: person.name,
            age: person.age,
            email: person.email
        )
    }
    
    func getAllPeople() throws -> [PersonData] {
        let descriptor = FetchDescriptor<Person>(
            sortBy: [SortDescriptor(\.name)]
        )
        let people = try modelContext.fetch(descriptor)
        
        // Converting to Sendable data within the same actor context
        return people.map { person in
            PersonData(
                name: person.name,
                age: person.age,
                email: person.email
            )
        }
    }
    
    func getPersonIDs() throws -> [PersistentIdentifier] {
        let descriptor = FetchDescriptor<Person>()
        let people = try modelContext.fetch(descriptor)
        // persistentModelID is Sendable
        return people.map(\.persistentModelID)
    }
    
    func addMultiplePeople(_ peopleData: [PersonData]) throws {
        for data in peopleData {
            let person = Person(
                name: data.name,
                age: data.age,
                email: data.email
            )
            modelContext.insert(person)
        }
        try modelContext.save()
    }
    
    func deletePerson(id: PersistentIdentifier) throws {
        guard let person = modelContext.model(for: id) as? Person else {
            throw PersonStoreError.personNotFound
        }
        modelContext.delete(person)
        try modelContext.save()
    }
}

enum PersonStoreError: Error, Sendable {
    case personNotFound
}

// MARK: - Key Rules for Swift 6 + SwiftData:

/*
✅ DO:
- Create @Model instances inside @ModelActor methods
- Access @Model properties within the same actor context  
- Return Sendable data (structs, primitives) from actor methods
- Use PersistentIdentifier for cross-actor model references
- Perform all database operations within the actor

❌ DON'T:
- Pass @Model instances between actors (they're not Sendable)
- Access @Model properties from different actor contexts
- Return @Model instances from actor methods
- Create @Model instances outside their intended actor context

The key insight: @Model objects are bound to their ModelContext's actor.
In @ModelActor, that's the actor itself, so everything works smoothly.
*/