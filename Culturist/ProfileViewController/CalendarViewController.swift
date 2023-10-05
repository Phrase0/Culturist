//
//  CalendarViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/20.
//

import UIKit
import FSCalendar_Persian
import EventKit
import EventKitUI

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
        setCalendarAppearance()
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.rightBarButtonItem?.tintColor = .B2
    }
        
    @objc private func backButtonTapped() {
        self.dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestAccess()
    }
    
    @IBAction func todayBtn(_ sender: UIButton) {
        // Get the current date
        let today = Date()
        // Use the `select` method of FSCalendar to select the current month
        calendar.select(today)
        // Scroll to the current month
        calendar.setCurrentPage(today, animated: true)
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
            }
        }
    }
    
}

// MARK: - FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance
extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let matchingEvents = events.filter { Calendar.current.isDate($0.startDate, inSameDayAs: date) }
        return matchingEvents.count
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        eventsTableView.reloadData()
    }
    
    func setCalendarAppearance() {
        calendar.today = Date()
        calendar.appearance.headerTitleColor = .GR1
        calendar.appearance.todayColor = .GR2
        calendar.appearance.selectionColor = .R1
        calendar.appearance.weekdayTextColor = .GR2
        calendar.appearance.eventDefaultColor = .GR1
        calendar.appearance.eventSelectionColor = .R1
        calendar.appearance.headerTitleFont = UIFont(name: "PingFangTC-Medium", size: 20)
        calendar.appearance.weekdayFont = UIFont(name: "PingFangTC", size: 18)
        calendar.appearance.titleFont = UIFont(name: "PingFangTC", size: 18)
        // In month mode, only the current month is displayed
        calendar.placeholderType = .fillHeadTail
        calendar.appearance.borderRadius = 1
        
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        let event = events[indexPath.row]
        showEditViewController(for: event)
    }
    
    // Delete events
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        guard let selectedDate = selectedDate else {
            preconditionFailure("A date should be selected to display events")
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventsTableViewCell", for: indexPath) as? EventsTableViewCell else {
            preconditionFailure("Check cell configuration")
        }
        let matchingEvents = events.filter({ Calendar.current.isDate($0.startDate, inSameDayAs: selectedDate) })
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            let event = matchingEvents[indexPath.row]
            self.deleteEventWithConfirmation(event: event, at: indexPath)
            completionHandler(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func deleteEventWithConfirmation(event: EKEvent, at indexPath: IndexPath) {
        let ac = UIAlertController(title: nil, message: "Are you sure you want to delete this event?", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
            do {
                try self.eventStore.remove(event, span: .thisEvent)
                self.events.remove(at: indexPath.row)
                self.eventsTableView.deleteRows(at: [indexPath], with: .fade)
                self.calendar.reloadData()
                
            } catch {
                print(error)
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(ac, animated: true)
    }

    func showEditViewController(for event: EKEvent?) {
        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.eventStore = eventStore
        if let event = event {
            eventEditViewController.event = event // when set to nil the controller would not display anything
        }
        eventEditViewController.editViewDelegate = self
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        eventEditViewController.navigationBar.standardAppearance = navigationBarAppearance
        present(eventEditViewController, animated: true, completion: nil)
    }
    
}

// MARK: EKEventEditViewDelegate

extension CalendarViewController: EKEventEditViewDelegate {
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        dismiss(animated: true, completion: nil)
        
        if action != .canceled {
//            if let editedEvent = controller.event {
//                // use Identifier to find
//                if let index = events.firstIndex(where: { $0.eventIdentifier == editedEvent.eventIdentifier }) {
//                    // use editedEvent to replace the origin one
//                    events[index] = editedEvent
//                }
//            }
            self.fetchEventsFromCalendar(calendarName: "CulturistCalendar")
            DispatchQueue.main.async {
                self.calendar.reloadData()
                self.eventsTableView.reloadData()
            }
            
        }
    }

}
