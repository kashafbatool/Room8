import SwiftUI

// MARK: - Calendar View
struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var showingAddItem = false
    @State private var showingAddQuietHours = false
    @State private var displayMode: DisplayMode = .calendar
    @State private var currentMonth = Date()
    @State private var selectedDate = Date()
    private let calendar = Calendar.current

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                Picker("Display Mode", selection: $displayMode) {
                    ForEach(DisplayMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if displayMode == .list {
                    listView
                } else {
                    calendarView
                }
            }
            .navigationTitle("Calendar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddItem = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddCalendarItemView(viewModel: viewModel, isPresented: $showingAddItem)
            }
            .sheet(isPresented: $showingAddQuietHours) {
                AddQuietHoursView(viewModel: viewModel, isPresented: $showingAddQuietHours)
            }
        }
    }

    private var listView: some View {
        List {
            quietHoursSection
            if viewModel.sortedItems.isEmpty {
                emptyState
            } else {
                ForEach(viewModel.sortedItems) { item in
                    CalendarItemRow(item: item)
                }
                .onDelete(perform: viewModel.deleteItems)
            }
        }
    }

    private var calendarView: some View {
        ScrollView {
            VStack(spacing: 12) {
                monthHeader
                weekHeader
                monthGrid
                selectedDaySection
                quietHoursSectionCompact
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
    }

    private var monthHeader: some View {
        HStack {
            Button {
                currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
            } label: {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(monthTitle(for: currentMonth))
                .font(.headline)
            Spacer()
            Button {
                currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.top, 4)
    }

    private var weekHeader: some View {
        let symbols = calendar.shortWeekdaySymbols
        return HStack {
            ForEach(symbols, id: \.self) { symbol in
                Text(symbol.uppercased())
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var monthGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(monthDays(for: currentMonth).indices, id: \.self) { index in
                let date = monthDays(for: currentMonth)[index]
                CalendarDayCell(
                    date: date,
                    isSelected: date.map { calendar.isDate($0, inSameDayAs: selectedDate) } ?? false,
                    hasItems: date.map { hasItems(on: $0) } ?? false,
                    onSelect: { selectedDate = $0 }
                )
            }
        }
    }

    private var selectedDaySection: some View {
        let items = items(on: selectedDate)
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(selectedDate, style: .date)
                    .font(.headline)
                Spacer()
                Button("Today") {
                    selectedDate = Date()
                    currentMonth = Date()
                }
                .font(.caption)
            }
            if items.isEmpty {
                Text("No items for this day")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(items) { item in
                    CalendarItemRow(item: item)
                }
            }
        }
        .padding(.top, 8)
    }

    private var quietHoursSection: some View {
        Section(header: Text("Quiet Hours & Sleep")) {
            if viewModel.quietHours.isEmpty {
                Text("No quiet hours set")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.quietHours) { schedule in
                    QuietHoursRow(schedule: schedule)
                }
                .onDelete(perform: viewModel.deleteQuietHours)
            }

            Button("Add Quiet Hours") {
                showingAddQuietHours = true
            }
        }
    }

    private var quietHoursSectionCompact: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Quiet Hours & Sleep")
                    .font(.headline)
                Spacer()
                Button("Add") {
                    showingAddQuietHours = true
                }
                .font(.caption)
            }

            if viewModel.quietHours.isEmpty {
                Text("No quiet hours set")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.quietHours) { schedule in
                    QuietHoursRow(schedule: schedule)
                }
            }
        }
        .padding(.top, 8)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar")
                .font(.system(size: 36))
                .foregroundColor(.secondary)
            Text("No calendar items yet")
                .font(.headline)
            Text("Add chores, events, or expense due dates")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func monthDays(for date: Date) -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let range = calendar.range(of: .day, in: .month, for: date) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let leading = (firstWeekday - calendar.firstWeekday + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: leading)
        for day in range {
            if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start) {
                days.append(dayDate)
            }
        }

        return days
    }

    private func items(on date: Date) -> [CalendarItem] {
        viewModel.items.filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.date < $1.date }
    }

    private func hasItems(on date: Date) -> Bool {
        viewModel.items.contains { calendar.isDate($0.date, inSameDayAs: date) }
    }
}

// MARK: - Calendar Item Row
private struct CalendarItemRow: View {
    let item: CalendarItem

    private var typeColor: Color {
        switch item.type {
        case .chore:
            return .blue
        case .event:
            return .purple
        case .expense:
            return .green
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(item.title)
                    .font(.headline)
                Spacer()
                Text(item.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 8) {
                Text(item.type.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(typeColor.opacity(0.2))
                    .foregroundColor(typeColor)
                    .cornerRadius(4)

                if item.type == .expense, let amount = item.amount {
                    Text(String(format: "$%.2f", amount))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if let notes = item.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Calendar Day Cell
private struct CalendarDayCell: View {
    let date: Date?
    let isSelected: Bool
    let hasItems: Bool
    let onSelect: (Date) -> Void

    var body: some View {
        Button {
            if let date = date {
                onSelect(date)
            }
        } label: {
            VStack(spacing: 4) {
                Text(dayNumber)
                    .font(.callout)
                    .foregroundColor(isSelected ? .white : .primary)
                    .frame(maxWidth: .infinity)
                if hasItems {
                    Circle()
                        .fill(isSelected ? Color.white : Color.blue)
                        .frame(width: 6, height: 6)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.blue : Color.clear)
            .cornerRadius(8)
        }
        .disabled(date == nil)
    }

    private var dayNumber: String {
        guard let date = date else { return "" }
        let day = Calendar.current.component(.day, from: date)
        return "\(day)"
    }
}

// MARK: - Display Mode
private enum DisplayMode: String, CaseIterable {
    case calendar = "Calendar"
    case list = "List"
}

// MARK: - Quiet Hours Row
private struct QuietHoursRow: View {
    let schedule: QuietHoursSchedule

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(schedule.type.rawValue)
                    .font(.headline)
                Spacer()
                Text(timeRangeText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(daysText)
                .font(.caption)
                .foregroundColor(.secondary)
            if let notes = schedule.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }

    private var timeRangeText: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: schedule.startTime)) - \(formatter.string(from: schedule.endTime))"
    }

    private var daysText: String {
        let symbols = Calendar.current.shortWeekdaySymbols
        let labels = schedule.daysOfWeek.compactMap { index -> String? in
            let i = index - 1
            guard i >= 0 && i < symbols.count else { return nil }
            return symbols[i]
        }
        return labels.isEmpty ? "No days selected" : labels.joined(separator: ", ")
    }
}

// MARK: - Add Calendar Item View
private struct AddCalendarItemView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Binding var isPresented: Bool

    @State private var title = ""
    @State private var type: CalendarItem.ItemType = .chore
    @State private var date = Date()
    @State private var notes = ""
    @State private var amountText = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Title", text: $title)
                    Picker("Type", selection: $type) {
                        ForEach(CalendarItem.ItemType.allCases, id: \.self) { itemType in
                            Text(itemType.rawValue).tag(itemType)
                        }
                    }
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }

                if type == .expense {
                    Section(header: Text("Amount")) {
                        TextField("Amount", text: $amountText)
                            .keyboardType(.decimalPad)
                    }
                }

                Section(header: Text("Notes")) {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.addItem(
                            title: title,
                            type: type,
                            date: date,
                            notes: notes,
                            amount: parsedAmount()
                        )
                        isPresented = false
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func parsedAmount() -> Double? {
        let trimmed = amountText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let value = Double(trimmed) else { return nil }
        return value
    }
}

// MARK: - Add Quiet Hours View
private struct AddQuietHoursView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Binding var isPresented: Bool

    @State private var type: QuietHoursSchedule.ScheduleType = .quiet
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var selectedDays: Set<Int> = []
    @State private var notes = ""

    private let calendar = Calendar.current

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Type")) {
                    Picker("Schedule", selection: $type) {
                        ForEach(QuietHoursSchedule.ScheduleType.allCases, id: \.self) { scheduleType in
                            Text(scheduleType.rawValue).tag(scheduleType)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Time")) {
                    DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End", selection: $endTime, displayedComponents: .hourAndMinute)
                }

                Section(header: Text("Days")) {
                    let symbols = calendar.shortWeekdaySymbols
                    ForEach(symbols.indices, id: \.self) { index in
                        let weekday = index + 1
                        Button {
                            toggleDay(weekday)
                        } label: {
                            HStack {
                                Text(symbols[index])
                                Spacer()
                                if selectedDays.contains(weekday) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }

                Section(header: Text("Notes")) {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .navigationTitle("Quiet Hours")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.addQuietHours(
                            type: type,
                            startTime: startTime,
                            endTime: endTime,
                            daysOfWeek: selectedDays.sorted(),
                            notes: notes
                        )
                        isPresented = false
                    }
                    .disabled(selectedDays.isEmpty)
                }
            }
        }
    }

    private func toggleDay(_ weekday: Int) {
        if selectedDays.contains(weekday) {
            selectedDays.remove(weekday)
        } else {
            selectedDays.insert(weekday)
        }
    }
}

#Preview {
    CalendarView()
}
