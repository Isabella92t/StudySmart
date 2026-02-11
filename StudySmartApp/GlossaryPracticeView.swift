import SwiftUI

struct GlossaryPracticeView: View {
    var body: some View {
        
        
        VStack(spacing: 16) {
            Text("Öva")
                .font(.title)
                .bold()
            Text("Här kan du testa dina kunskaper genom att endast få fram frågorna och skriva svaret.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        GlossaryPracticeView()
    }
}
