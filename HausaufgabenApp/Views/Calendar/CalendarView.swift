import SwiftUI

/// Der Kalender: ein Monat auf einen Blick, darunter der gewählte Tag.
///
/// Unter dem Raster steht alles, was an dem Tag ansteht – die eingetragenen
/// Termine, die Hausaufgaben und die Stunden aus dem Stundenplan.
struct CalendarView: View {
    @EnvironmentObject private var store: AppStore

    /// Erster Tag des angezeigten Monats.
    @State private var monthStart = SchoolCalendar.startOfMonth(Date())
    @State private var selectedDay = SchoolCalendar.startOfDay(Date())
    @State private var editingEvent: CalendarEvent?
    @State private var editingHoliday: Holiday?

    private var calendar: Calendar { SchoolCalendar.calendar }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    monthCard
                    dayCard
                    upcomingCard
                    holidayCard
                }
                .padding(16)
                .padding(.bottom, 24)
            }
            .background(DoodleCanvas())
            .navigationTitle("Kalender")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Heute") { goToToday() }
                        .disabled(isShowingToday)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            newEvent()
                        } label: {
                            Label("Termin eintragen", systemImage: "calendar.badge.plus")
                        }
                        Button {
                            newHoliday()
                        } label: {
                            Label("Ferien eintragen", systemImage: "sun.max.fill")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Eintragen")
                }
            }
            .sheet(item: $editingEvent) { event in
                EventEditorView(event: event)
                    .environmentObject(store)
            }
            .sheet(item: $editingHoliday) { holiday in
                HolidayEditorView(holiday: holiday)
                    .environmentObject(store)
            }
        }
    }

    // MARK: - Der Monat

    private var monthCard: some View {
        VStack(spacing: 10) {
            monthHeader
            weekdayHeader
            monthGrid
            dotLegend
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }

    private var monthHeader: some View {
        HStack {
            Button {
                step(by: -1)
            } label: {
                Image(systemName: "chevron.left").font(.body.weight(.semibold))
            }
            .keyboardShortcut(.leftArrow, modifiers: .command)
            .accessibilityLabel("Voriger Monat")

            Spacer(minLength: 0)

            Text(SchoolCalendar.monthYear(monthStart))
                .font(.headline)

            Spacer(minLength: 0)

            Button {
                step(by: 1)
            } label: {
                Image(systemName: "chevron.right").font(.body.weight(.semibold))
            }
            .keyboardShortcut(.rightArrow, modifiers: .command)
            .accessibilityLabel("Nächster Monat")
        }
        .buttonStyle(.plain)
        .foregroundStyle(.tint)
    }

    private var weekdayHeader: some View {
        HStack(spacing: 4) {
            ForEach(1...7, id: \.self) { index in
                Text(SchoolCalendar.weekdayShortName(index))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(index >= 6 ? Color.secondary : Color.primary.opacity(0.75))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var monthGrid: some View {
        let days = SchoolCalendar.gridDays(forMonthOf: monthStart)
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7),
                         spacing: 4) {
            ForEach(days, id: \.self) { day in
                dayCell(day)
            }
        }
    }

    private func dayCell(_ day: Date) -> some View {
        let isInMonth = calendar.isDate(day, equalTo: monthStart, toGranularity: .month)
        let isSelected = SchoolCalendar.isSameDay(day, selectedDay)
        let isToday = SchoolCalendar.isToday(day)
        let dayEvents = store.events(on: day)
        let openHomework = store.homeworkEntries(on: day).filter { !$0.isDone && $0.hasText }.count
        let isHoliday = store.isSchoolFree(on: day)

        return Button {
            Haptics.tap()
            selectedDay = SchoolCalendar.startOfDay(day)
        } label: {
            VStack(spacing: 3) {
                Text("\(calendar.component(.day, from: day))")
                    .font(.system(size: 16, weight: isToday ? .bold : .regular, design: .rounded))
                    .foregroundStyle(cellTextColor(isInMonth: isInMonth,
                                                   isSelected: isSelected,
                                                   isToday: isToday))

                // Punkte unter dem Tag: grün für Ferien, je Termin einer in
                // seiner Farbe, grau für offene Hausaufgaben.
                HStack(spacing: 2.5) {
                    if isHoliday {
                        Circle()
                            .fill(Holiday.tint)
                            .frame(width: 5, height: 5)
                    }
                    ForEach(dayEvents.prefix(isHoliday ? 2 : 3)) { event in
                        Circle()
                            .fill(event.kind.tint)
                            .frame(width: 5, height: 5)
                    }
                    if openHomework > 0 {
                        Circle()
                            .fill(Color.secondary.opacity(0.55))
                            .frame(width: 5, height: 5)
                    }
                }
                .frame(height: 5)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
            .background(cellBackground(isSelected: isSelected, isToday: isToday))
            .background(holidayBackground(day))
            .contentShape(RoundedRectangle(cornerRadius: 9))
        }
        .buttonStyle(.plain)
        .opacity(isInMonth ? 1 : 0.38)
        .accessibilityLabel(cellAccessibilityLabel(day, events: dayEvents.count, homework: openHomework))
    }

    private func cellTextColor(isInMonth: Bool, isSelected: Bool, isToday: Bool) -> Color {
        if isSelected { return .white }
        if isToday { return .accentColor }
        return .primary
    }

    @ViewBuilder
    private func cellBackground(isSelected: Bool, isToday: Bool) -> some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 9).fill(Color.accentColor)
        } else if isToday {
            RoundedRectangle(cornerRadius: 9).strokeBorder(Color.accentColor, lineWidth: 1.5)
        } else {
            Color.clear
        }
    }

    /// Was die Punkte unter den Tagen bedeuten.
    private var dotLegend: some View {
        HStack(spacing: 14) {
            legendItem(color: Holiday.tint, text: "Ferien / Feiertag")
            legendItem(color: EventKind.exam.tint, text: "Termin")
            legendItem(color: Color.secondary.opacity(0.55), text: "Hausaufgaben offen")
            Spacer(minLength: 0)
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
        .padding(.top, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Die Punkte unter den Tagen: grün heißt Ferien oder Feiertag, ein farbiger Punkt ein Termin, ein grauer offene Hausaufgaben")
    }

    private func legendItem(color: Color, text: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
            Text(text)
        }
    }

    /// Ferientage bekommen eine ruhige Fläche – so sieht man den Zeitraum
    /// am Stück, ohne dass es mit der Auswahl kollidiert.
    @ViewBuilder
    private func holidayBackground(_ day: Date) -> some View {
        if store.isSchoolFree(on: day) {
            RoundedRectangle(cornerRadius: 9).fill(Holiday.fill)
        } else {
            Color.clear
        }
    }

    private func cellAccessibilityLabel(_ day: Date, events: Int, homework: Int) -> String {
        var text = "\(SchoolCalendar.weekdayName(SchoolCalendar.weekdayIndex(of: day))), \(SchoolCalendar.dayMonth(day))"
        if SchoolCalendar.isToday(day) { text += ", heute" }
        if let ferien = store.holiday(on: day) {
            text += ", \(ferien.displayName)"
            if ferien.isStart(day) { text += ", erster Ferientag" }
            if ferien.isEnd(day) { text += ", letzter Ferientag" }
        } else if let feiertag = store.publicHoliday(on: day) {
            text += ", \(feiertag.name), schulfrei"
        }
        if events > 0 { text += ", \(events) \(events == 1 ? "Termin" : "Termine")" }
        if homework > 0 { text += ", \(homework) offene Hausaufgaben" }
        return text
    }

    // MARK: - Was als Nächstes kommt

    private var upcoming: [CalendarEvent] { store.upcomingEvents(limit: 3) }

    @ViewBuilder
    private var upcomingCard: some View {
        if !upcoming.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Text("Als Nächstes")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 14)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                ForEach(upcoming) { event in
                    if event.id != upcoming.first?.id {
                        Divider().padding(.leading, 52)
                    }
                    Button {
                        if let day = event.date {
                            withAnimation {
                                selectedDay = SchoolCalendar.startOfDay(day)
                                monthStart = SchoolCalendar.startOfMonth(day)
                            }
                        }
                    } label: {
                        EventRow(event: event,
                                 subject: store.subject(id: event.subjectID),
                                 countdown: countdownText(for: event))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 4)
            .background(Color(.secondarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        }
    }

    private func countdownText(for event: CalendarEvent) -> String? {
        guard let tage = store.daysUntil(event) else { return nil }
        switch tage {
        case ..<0:  return nil
        case 0:     return "heute"
        case 1:     return "morgen"
        case 2:     return "übermorgen"
        default:    return "in \(tage) Tagen"
        }
    }

    // MARK: - Der gewählte Tag

    private var dayCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            dayHeader
            dayHolidayNote

            if dayEvents.isEmpty, !hasDayBanner {
                emptyDayHint
            } else if !dayEvents.isEmpty {
                ForEach(dayEvents) { event in
                    Divider().padding(.leading, 52)
                    Button {
                        editingEvent = event
                    } label: {
                        EventRow(event: event,
                                 subject: store.subject(id: event.subjectID),
                                 countdown: nil,
                                 showsChevron: true)
                    }
                    .buttonStyle(.plain)
                }
            }

            Divider().padding(.leading, 52)
            addButton

            homeworkSummary
            lessonSummary
        }
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }

    private var dayEvents: [CalendarEvent] { store.events(on: selectedDay) }

    /// Was für ein Tag ist das? Ferien, Feiertag, Wochenende – hier steht es.
    /// Fällt ein Feiertag in die Ferien, steht beides da.
    @ViewBuilder
    private var dayHolidayNote: some View {
        if let ferien = store.holiday(on: selectedDay) {
            freeDayBanner(title: ferien.displayName,
                          detail: holidayDayText(ferien),
                          action: { editingHoliday = ferien })
        }

        if let feiertag = store.publicHoliday(on: selectedDay) {
            freeDayBanner(title: feiertag.name,
                          detail: publicHolidayDetail(feiertag),
                          action: nil)
        }

        // Kein freier Tag, aber auch kein Schultag: das Wochenende.
        if !store.isSchoolFree(on: selectedDay), isWeekend {
            weekendBanner
        }
    }

    private func publicHolidayDetail(_ feiertag: PublicHoliday) -> String {
        var text = "Gesetzlicher Feiertag"
        if store.settings.federalState.isSet {
            text += " in \(store.settings.federalState.name)"
        }
        if let note = feiertag.note {
            text += " – \(note)"
        }
        if store.holiday(on: selectedDay) != nil {
            text += " · fällt in die Ferien"
        }
        return text
    }

    /// Ist der gewählte Tag laut Einstellungen kein Schultag?
    private var isWeekend: Bool {
        !store.settings.weekdays.contains(SchoolCalendar.weekdayIndex(of: selectedDay))
    }

    private var weekendBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "moon.zzz.fill")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 30, height: 30)
                .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text("Wochenende")
                    .font(.subheadline.weight(.semibold))
                Text("Kein Schultag")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 10)
    }

    /// Der grüne Streifen über dem Tag – für Ferien und Feiertage gleich.
    @ViewBuilder
    private func freeDayBanner(title: String, detail: String, action: (() -> Void)?) -> some View {
        let inhalt = HStack(spacing: 10) {
            Image(systemName: "sun.max.fill")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Holiday.tint)
                .frame(width: 30, height: 30)
                .background(Holiday.fill, in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            if action != nil {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 10)

        if let action {
            Button(action: action) {
                inhalt.contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        } else {
            inhalt
        }
    }

    private func holidayDayText(_ ferien: Holiday) -> String {
        if ferien.isStart(selectedDay) { return "Erster Ferientag · \(ferien.dayCount) Tage lang" }
        if ferien.isEnd(selectedDay) {
            if let danach = store.firstSchoolDay(after: ferien) {
                return "Letzter Ferientag · wieder Schule am \(SchoolCalendar.weekdayName(SchoolCalendar.weekdayIndex(of: danach)))"
            }
            return "Letzter Ferientag"
        }
        if let nummer = ferien.dayNumber(of: selectedDay) {
            return "Ferien · Tag \(nummer) von \(ferien.dayCount)"
        }
        return "Ferien"
    }

    private var dayHeader: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(SchoolCalendar.weekdayName(SchoolCalendar.weekdayIndex(of: selectedDay)))
                .font(.headline)
            Text(SchoolCalendar.dayMonth(selectedDay))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)

            if store.isSchoolFree(on: selectedDay) {
                Text("Frei")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Holiday.tint)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Holiday.fill, in: Capsule())
            }

            if SchoolCalendar.isToday(selectedDay) {
                Text("Heute")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.accentColor, in: Capsule())
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 10)
    }

    /// Steht über dem Tag schon ein Hinweis (Ferien, Feiertag, Wochenende)?
    /// Dann braucht es das „hier steht nichts“ nicht mehr.
    private var hasDayBanner: Bool {
        store.isSchoolFree(on: selectedDay) || isWeekend
    }

    private var emptyDayHint: some View {
        Text("An diesem Tag steht nichts im Kalender.")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 14)
            .padding(.bottom, 12)
    }

    private var addButton: some View {
        Button(action: newEvent) {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                Text("Termin eintragen")
                    .font(.subheadline)
                Spacer(minLength: 0)
            }
            .foregroundStyle(.tint)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    /// Was an dem Tag aufgegeben ist – zum Nachsehen, geändert wird es im Heft.
    private var dayHomework: [HomeworkEntry] {
        store.homeworkEntries(on: selectedDay).filter(\.hasText)
    }

    @ViewBuilder
    private var homeworkSummary: some View {
        if !dayHomework.isEmpty {
            Divider().padding(.leading, 52)
            VStack(alignment: .leading, spacing: 7) {
                Text("Hausaufgaben an diesem Tag")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                ForEach(dayHomework) { entry in
                    HStack(alignment: .top, spacing: 8) {
                        if let subject = store.subject(id: entry.subjectID) {
                            SubjectBadge(subject: subject, width: 36, dimmed: entry.isDone)
                        }
                        Text(entry.text)
                            .font(.footnote)
                            .foregroundStyle(entry.isDone ? .secondary : .primary)
                            .strikethrough(entry.isDone, color: .secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
    }

    /// Die Stunden des Tages laut Stundenplan.
    private var daySubjects: [Subject] {
        store.subjects(onWeekday: SchoolCalendar.weekdayIndex(of: selectedDay))
    }

    @ViewBuilder
    private var lessonSummary: some View {
        // An freien Tagen fällt der Unterricht aus – dann wäre die Liste falsch.
        if !daySubjects.isEmpty, !store.isSchoolFree(on: selectedDay) {
            Divider().padding(.leading, 52)
            VStack(alignment: .leading, spacing: 7) {
                Text("Stunden an diesem Tag")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                HStack(spacing: 5) {
                    ForEach(daySubjects) { subject in
                        SubjectBadge(subject: subject, width: 36)
                    }
                    Spacer(minLength: 0)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Ferien

    private var holidayCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Text("Ferien")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 8)

            if store.holidays.isEmpty {
                Text("Noch keine Ferien eingetragen. Trag sie aus dem Ferienplan deiner Schule ein – dann siehst du im Kalender, wann sie anfangen und wann sie enden.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 12)
            } else {
                ForEach(store.sortedHolidays) { ferien in
                    if ferien.id != store.sortedHolidays.first?.id {
                        Divider().padding(.leading, 14)
                    }
                    Button {
                        showHoliday(ferien)
                    } label: {
                        HolidayRow(holiday: ferien,
                                   status: holidayStatus(ferien),
                                   firstSchoolDay: store.firstSchoolDay(after: ferien))
                    }
                    .buttonStyle(.plain)
                }
            }

            Divider().padding(.leading, 14)

            Text(holidayFooter)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)

            Divider().padding(.leading, 14)

            Button(action: newHoliday) {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    Text("Ferien eintragen")
                        .font(.subheadline)
                    Spacer(minLength: 0)
                }
                .foregroundStyle(.tint)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }

    private var holidayFooter: String {
        let land = store.settings.federalState
        if land.isSet {
            return "Die gesetzlichen Feiertage in \(land.name) rechnet Homy selbst aus und zeigt sie grün an. "
                + "Die Schulferien legt jedes Land für jedes Schuljahr neu fest – die trägst du hier selbst ein."
        }
        return "Stell in den Einstellungen dein Bundesland ein, dann zeigt Homy die gesetzlichen Feiertage von selbst. "
            + "Die Schulferien trägst du hier ein – die sind in jedem Land und jedem Schuljahr anders."
    }

    /// „läuft gerade“, „in 23 Tagen“, „vorbei“
    private func holidayStatus(_ ferien: Holiday) -> String? {
        if ferien.isRunning() {
            if let nummer = ferien.dayNumber(of: Date()) {
                return "Tag \(nummer) von \(ferien.dayCount)"
            }
            return "läuft gerade"
        }
        if ferien.isOver() { return "vorbei" }
        guard let tage = store.daysUntilStart(of: ferien) else { return nil }
        switch tage {
        case 0:  return "ab heute"
        case 1:  return "ab morgen"
        default: return "in \(tage) Tagen"
        }
    }

    /// Zu den Ferien springen und sie zum Ändern öffnen.
    private func showHoliday(_ ferien: Holiday) {
        if let (start, _) = ferien.orderedDates {
            withAnimation {
                selectedDay = start
                monthStart = SchoolCalendar.startOfMonth(start)
            }
        }
        editingHoliday = ferien
    }

    private func newHoliday() {
        Haptics.tap()
        let key = SchoolCalendar.dayKey(selectedDay)
        editingHoliday = Holiday(startDayKey: key, endDayKey: key)
    }

    // MARK: - Aktionen

    private var isShowingToday: Bool {
        SchoolCalendar.isToday(selectedDay)
            && calendar.isDate(monthStart, equalTo: Date(), toGranularity: .month)
    }

    private func goToToday() {
        Haptics.tap()
        withAnimation {
            selectedDay = SchoolCalendar.startOfDay(Date())
            monthStart = SchoolCalendar.startOfMonth(Date())
        }
    }

    private func step(by months: Int) {
        guard let neu = calendar.date(byAdding: .month, value: months, to: monthStart) else { return }
        Haptics.tap()
        withAnimation(.easeInOut(duration: 0.18)) {
            monthStart = SchoolCalendar.startOfMonth(neu)
        }
    }

    private func newEvent() {
        Haptics.tap()
        editingEvent = CalendarEvent(dayKey: SchoolCalendar.dayKey(selectedDay),
                                     reminder: store.settings.defaultReminder)
    }
}

/// Eine Zeile mit einem Termin: Symbol, Titel, Einzelheiten.
struct EventRow: View {
    let event: CalendarEvent
    var subject: Subject?
    var countdown: String?
    var showsChevron: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: event.kind.symbol)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(event.kind.tint)
                .frame(width: 30, height: 30)
                .background(event.kind.fill, in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(event.displayTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if !detailLine.isEmpty {
                    Text(detailLine)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let countdown {
                Text(countdown)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(event.kind.tint)
                    .padding(.top, 2)
            }

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .padding(.top, 3)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .contentShape(Rectangle())
    }

    private var detailLine: String {
        var parts: [String] = []
        if event.hasTitle { parts.append(event.kind.title) }
        if let subject { parts.append(subject.displayName) }
        if let zeit = event.timeText { parts.append(zeit) }
        if let day = event.date, countdown != nil {
            parts.append(SchoolCalendar.shortDate(day))
        }
        if event.reminder != .none {
            parts.append("🔔")
        }
        return parts.joined(separator: " · ")
    }
}

/// Eine Zeile in der Ferienliste: Name, Anfang, Ende, Dauer.
struct HolidayRow: View {
    let holiday: Holiday
    var status: String?
    /// Der erste Tag, an dem wirklich wieder Schule ist.
    var firstSchoolDay: Date?

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "sun.max.fill")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Holiday.tint)
                .frame(width: 30, height: 30)
                .background(Holiday.fill, in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(holiday.displayName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)

                    Spacer(minLength: 0)

                    if let status {
                        Text(status)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(holiday.isOver() ? Color.secondary : Holiday.tint)
                    }
                }

                // Anfang und Ende jeweils mit Wochentag – darum geht es hier.
                VStack(alignment: .leading, spacing: 2) {
                    rangeLine(label: "Von", text: holiday.startText)
                    rangeLine(label: "Bis", text: holiday.endText)
                }

                Text(footerText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(holiday.displayName), von \(holiday.startText) bis \(holiday.endText)")
    }

    private func rangeLine(label: String, text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 26, alignment: .leading)
            Text(text)
                .font(.footnote)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var footerText: String {
        var text = holiday.dayCount == 1 ? "1 Tag" : "\(holiday.dayCount) Tage"
        if let firstSchoolDay {
            text += " · wieder Schule am \(Holiday.longWeekdayText(firstSchoolDay))"
        }
        if !holiday.note.isEmpty {
            text += "\n" + holiday.note
        }
        return text
    }
}
