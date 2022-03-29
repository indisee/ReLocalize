enum S: LocalizedString {
    
    ..... add you cases here .....
    

    var localizedString: String {
        return rawValue.v
    }

    init?(localizedString: String) {
        self.init(rawValue: LocalizedString(localized: localizedString))
    }
}
