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

extension ProfileViewController {
    func requestAccess() {
        // Check if the user granted permission to access the calendar
        eventStore.requestAccess(to: .event) { [weak self] (granted, _) in
            guard granted else {
                // If access is denied, clear events and refresh the UI
                DispatchQueue.main.async {
                    self?.events.removeAll()
                    self?.calendar.reloadData()
                    self?.eventsTableView.reloadData()
                }
                return
            }
            // If access is granted, ensure the calendar exists and fetch events
            self?.createCalendarIfNeeded(calendarName: "CulturistCalendar")
            self?.fetchEventsFromCalendar(calendarName: "CulturistCalendar")
            
            DispatchQueue.main.async {
                self?.calendar.reloadData()
                self?.eventsTableView.reloadData()
            }
        }
    }
    
    func createCalendarIfNeeded(calendarName: String) {
        let calendars = eventStore.calendars(for: .event)
        if calendars.contains(where: { $0.title == calendarName }) {
            return
        }
        
        // Attempt to select a source that allows adding calendars
        let sources = eventStore.sources
        guard let source = sources.first(where: { $0.sourceType == .local || $0.sourceType == .calDAV || $0.sourceType == .exchange }) else {
            print("No valid source found to create calendar.")
            return
        }
        
        // create new calendar
        let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
        newCalendar.title = calendarName
        newCalendar.source = source
        
        do {
            try eventStore.saveCalendar(newCalendar, commit: true)
            print("Calendar '\(calendarName)' created successfully.")
        } catch {
            print("Failed to save calendar: \(error.localizedDescription)")
        }
    }
    
    func fetchEventsFromCalendar(calendarName: String) {
        let calendars = eventStore.calendars(for: .event)
        guard let calendar = calendars.first(where: { $0.title == calendarName }) else {
            events.removeAll()
            return
        }
        
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        let endDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
        events = eventStore.events(matching: predicate)
        events.sort { $0.startDate < $1.startDate }
    }
    
    func setCalendarAppearance() {
        calendar.today = Date()
        calendar.appearance.headerTitleColor = .GR1
        calendar.appearance.todayColor = .GR2
        calendar.appearance.selectionColor = .R1
        calendar.appearance.weekdayTextColor = .GR2
        calendar.appearance.eventDefaultColor = .GR1
        calendar.appearance.eventSelectionColor = .R1
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 20)
        calendar.appearance.weekdayFont = UIFont.boldSystemFont(ofSize: 17)
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 17)
        // In month mode, only the current month is displayed
        calendar.placeholderType = .fillHeadTail
        calendar.appearance.borderRadius = 1
        
    }
}

// MARK: - FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance
extension ProfileViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let matchingEvents = events.filter { Calendar.current.isDate($0.startDate, inSameDayAs: date) }
        return matchingEvents.count
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        eventsTableView.reloadData()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
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
        guard let selectedDate = selectedDate else {
            preconditionFailure("A date should be selected to display events")
        }
        let matchingEvents = events.filter({ Calendar.current.isDate($0.startDate, inSameDayAs: selectedDate) })
        // Ensure the index is valid
        guard indexPath.row < matchingEvents.count else {
            return
        }
        let event = matchingEvents[indexPath.row]
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
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completionHandler) in
            let event = matchingEvents[indexPath.row]
            self?.deleteEventWithConfirmation(event: event, at: indexPath)
            print("indexPath.row:\(indexPath.row)")
            print("indexPath:\(indexPath)")
            completionHandler(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func deleteEventWithConfirmation(event: EKEvent, at indexPath: IndexPath) {
        let ac = UIAlertController(title: nil, message: NSLocalizedString("確定要刪除此行程嗎？"), preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: NSLocalizedString("刪除行程"), style: .destructive, handler: { (_) in
            do {
                try self.eventStore.remove(event, span: .thisEvent)
                // Update the data source, removing the event from the events array
                if let index = self.events.firstIndex(where: { $0.eventIdentifier == event.eventIdentifier }) {
                    self.events.remove(at: index)
                }
                self.eventsTableView.deleteRows(at: [indexPath], with: .fade)
                self.calendar.reloadData()
                // self.eventsTableView.reloadData()
            } catch {
                print(error)
            }
        }))
        ac.addAction(UIAlertAction(title: NSLocalizedString("取消"), style: .cancel, handler: nil))
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

extension ProfileViewController: EKEventEditViewDelegate {
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        dismiss(animated: true, completion: nil)
        self.fetchEventsFromCalendar(calendarName: "CulturistCalendar")
        if action != .canceled {
            if let editedEvent = controller.event {
                // use Identifier to find
                if let index = events.firstIndex(where: { $0.eventIdentifier == editedEvent.eventIdentifier }) {
                    // use editedEvent to replace the origin one
                    events[index] = editedEvent
                }
            }
            
            DispatchQueue.main.async {
                self.calendar.reloadData()
                self.eventsTableView.reloadData()
            }
            
        }
    }
    
}
