import SwiftUI
import LanguagesAPI

struct ClassList: View {
    let classes: [EnrollmentVm]
    let joinClass: () -> Void
    let deleteEnrollment: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center) {
                Text("Your Classes:")
                    .font(.appSubheading)
                
                Spacer()
                
                Button(action: joinClass) {
                    Image(systemName: "plus.circle")
                        .font(.appSubheading)
                        .foregroundColor(.primary)
                }
            }
            
            if classes.isEmpty {
                Panel {
                    HStack {
                        Spacer(minLength: 0)
                        Text("You're not a member of any classes yet.")
                            .font(.appSubheading)
                            .multilineTextAlignment(.center)
                        Spacer(minLength: 0)
                    }
                }
            } else {
                ForEach(classes) { enrollment in
                    ClassItem(enrollment: enrollment, deleteEnrollment: deleteEnrollment)
                }
            }
        }
    }
}

fileprivate struct ClassItem: View {
    let enrollment: EnrollmentVm
    let deleteEnrollment: (Int) -> Void
    
    var body: some View {
        Panel {
            HStack {
                VStack {
                    Text(enrollment.className)
                        .font(.appSubheading)
                    
                    Text(enrollment.teacherName)
                }
                
                Spacer()
                
                Image(systemName: "trash")
                    .onTapGesture {
                        deleteEnrollment(enrollment.id)
                    }
            }
        }
    }
}

