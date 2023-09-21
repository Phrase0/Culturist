//
//  CalendarViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/20.
//

import UIKit
import FSCalendar_Persian
import EventKit

class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {
    
    @IBOutlet weak var calendar: FSCalendar!
    var eventStore = EKEventStore()
    var events: [EKEvent] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.dataSource = self
        calendar.delegate = self
        calendar.appearance.headerTitleColor = .black
        calendar.today = nil
        // calendar.appearance.selectionColor = .blue
        calendar.appearance.weekdayTextColor = .red
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestAccess()
    }
    
    func requestAccess() {
        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted {
                self.fetchEventsFromCalendar(calendarName: "CulturistCalendar")
                DispatchQueue.main.async {
                    self.calendar.reloadData()
                }
            }
        }
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let matchingEvents = events.filter { Calendar.current.isDate($0.startDate, inSameDayAs: date) }
        return matchingEvents.count
    }
    
    func fetchEventsFromCalendar(calendarName: String) {
    let calendars = eventStore.calendars(for: .event)
    
    for calendar in calendars {
        if calendar.title == calendarName {
            // set event start time
            let startDate = Date()
            // set event end time
            let endDate = Calendar.current.date(byAdding: .year, value: 1, to: startDate)!
            let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
            events = eventStore.events(matching: predicate)
            print("My:\(events)")
        }
    }
}

}
