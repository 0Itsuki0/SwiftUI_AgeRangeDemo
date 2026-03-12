
import DeclaredAgeRange
import SwiftUI

struct ContentView: View {

    @Environment(\.requestAgeRange) var requestAgeRange

    @State private var response: AgeRangeService.Response? = nil

    var body: some View {
        NavigationStack {
            List {
                Button(
                    action: {
                        Task {
                            do {
                                self.response = nil
                                ///   - threshold1: The primary age threshold for your app.
                                ///   - threshold2: An optional second age threshold that creates an additional age range.
                                ///   - threshold3: An optional third age threshold that creates a final age range.
                                let response = try await requestAgeRange(
                                    ageGates: 6,
                                    12,
                                    18
                                )
                                self.response = response
                            } catch AgeRangeService.Error.invalidRequest {
                                print("invalid request")
                            } catch AgeRangeService.Error.notAvailable {
                                print("Service not available")
                            } catch (let error) {
                                print(error)
                            }
                        }

                    },
                    label: {
                        VStack(alignment: .leading, content: {
                            Text("Request Age Range")
                                .font(.headline)
                            Text("Threshold: 6, 12, 18")
                                .font(.subheadline)
                        })
                    }
                )

                Section {
                    if let response {
                        // share
                        if case .sharing(let ageRange) = response {
                            // age range
                            if let lowerBound = ageRange.lowerBound {
                                if lowerBound >= 18 {
                                    // 18 or up. Same as checking upperBound == nil
                                    Text("Age Range: Above 18")
                                } else if lowerBound >= 12 {
                                    // 12 - 17
                                    Text("Age Range: 12 - 17")
                                } else {
                                    // 6 - 11
                                    Text("Age Range: 6 - 11")
                                }
                            } else {
                                // below the lower range
                                Text("Age Range: Under 6")
                            }

                            // declaration method, for example, self declared vs by parents
                            if let declaration = ageRange.ageRangeDeclaration {
                                Text(
                                    "Age Declared by: \(declaration.declaredBy)"
                                )
                            }

                            // any active Screen Time or Family Controls restrictions
                            Text("Active parental controls: \(ageRange.activeParentalControls.isEmpty ? "None" : ageRange.activeParentalControls.description)")

                        } else {
                            // share declined
                            Text("Age Sharing Declined.")
                        }
                    }
                }

            }
            .contentMargins(.top, 16)
            .navigationTitle("Age Range")
        }
    }
}

extension AgeRangeService.AgeRangeDeclaration {
    var declaredBy: String {
        switch self {
        case .selfDeclared:
            "Self"
        case .guardianDeclared:
            "Guardian"
        case .checkedByOtherMethod:
            "Other method"
        case .guardianCheckedByOtherMethod:
            "Other method (Guardian)"
        case .governmentIDChecked:
            "Government ID"
        case .guardianGovernmentIDChecked:
            "Government ID (Guardian)"
        case .paymentChecked:
            "Payment"
        case .guardianPaymentChecked:
            "Payment (Guardian)"
        @unknown default:
            "Unknown"
        }

    }
}
