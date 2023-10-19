//
//  EventsTableViewCell.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/21.
//

import UIKit
import EventKit

class EventsTableViewCell: UITableViewCell {

    @IBOutlet var calendarColorView: UIView!
    @IBOutlet var eventTitleLabel: UILabel!
    @IBOutlet var eventDateLabel: UILabel!
    @IBOutlet var eventDurationLabel: UILabel!
    
    private static var relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter
    }()
    
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    func configure(with event: EKEvent) {
        eventTitleLabel.text = event.title
        calendarColorView.backgroundColor = event.color
        eventDurationLabel.text = event.isAllDay ? "all day" : formatDate(forNonAllDayEvent: event)
        eventDateLabel.text = EventsTableViewCell.relativeDateFormatter.localizedString(for: event.startDate, relativeTo: Date()).uppercased()
    }
    
    private func formatDate(forNonAllDayEvent event: EKEvent) -> String {
        return "\(EventsTableViewCell.dateFormatter.string(from: event.startDate)) - \(EventsTableViewCell.dateFormatter.string(from: event.endDate))"
    }

}
