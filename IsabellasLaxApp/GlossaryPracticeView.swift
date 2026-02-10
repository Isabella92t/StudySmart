import SwiftUI

struct GlossaryPracticeView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Glosövning")
                .font(.title)
                .bold()
            Text("Här kommer övningsläge för glosor.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
        .navigationTitle("Glosor")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        GlossaryPracticeView()
    }
}
