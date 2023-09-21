//
//  CalendarViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/20.
//

import UIKit
import FSCalendar_Persian
import EventKit

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var calendar: FSCalendar!
    var eventStore = EKEventStore()
    var events: [EKEvent] = []
    var selectedDate: Date?
    
    @IBOutlet weak var eventsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.dataSource = self
        calendar.delegate = self
        calendar.appearance.headerTitleColor = .black
        calendar.today = Date()
        calendar.appearance.todayColor = .systemRed
        calendar.appearance.selectionColor = .blue
        calendar.appearance.weekdayTextColor = .red
        
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
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

extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let matchingEvents = events.filter { Calendar.current.isDate($0.startDate, inSameDayAs: date) }
        return matchingEvents.count
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        eventsTableView.reloadData()
    }
}

extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let selectedDate = selectedDate {
            let matchingEvents = events.filter { Calendar.current.isDate($0.startDate, inSameDayAs: selectedDate) }
            return matchingEvents.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let selectedDate = selectedDate else {
            preconditionFailure("A date should be selected to display events")
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventsTableViewCell", for: indexPath) as? EventsTableViewCell else {
            preconditionFailure("Check cell configuration")
        }

         let matchingEvents = events.filter({ Calendar.current.isDate($0.startDate, inSameDayAs: selectedDate) })
            let event = matchingEvents[indexPath.row]
            cell.configure(with: event)
        return cell
    }
}
