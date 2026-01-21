#!/usr/bin/swift
import EventKit
import Foundation

let store = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)

store.requestAccess(to: .event) { granted, error in
    if granted {
        let calendars = store.calendars(for: .event)

        guard let workCal = calendars.first(where: { $0.title == "Work" }) else {
            print("Work calendar not found")
            semaphore.signal()
            return
        }

        let now = Date()
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: now)!

        let predicate = store.predicateForEvents(withStart: now, end: endOfDay, calendars: [workCal])
        let events = store.events(matching: predicate)

        if events.isEmpty {
            print("No events today")
        } else {
            let sortedEvents = events.sorted { $0.startDate < $1.startDate }
            if let nextEvent = sortedEvents.first {
                let startEpoch = Int(nextEvent.startDate.timeIntervalSince1970)
                let endEpoch = Int(nextEvent.endDate.timeIntervalSince1970)
                print("\(startEpoch)|\(endEpoch)|\(nextEvent.title ?? "Untitled")")
            }
        }
    } else {
        print("Calendar access denied")
    }
    semaphore.signal()
}

semaphore.wait()
