import Foundation
import Observation

@Observable
public final class FormattedPropertyViewModel<F>: ValueEditor where F: ParseableFormatStyle, F.FormatOutput == String {
    var title: String
    var placeholder: String?
    var format: F
    public var value: F.FormatInput

    public init(
        value: F.FormatInput,
        format: F,
        title: String = "",
        placeholder: String? = nil
    ) {
        self.value = value
        self.format = format
        self.title = title
        self.placeholder = placeholder
    }
}
