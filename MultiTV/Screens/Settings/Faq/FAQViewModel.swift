struct FAQModel {
    let title: String
    let subtitle: String
}

final class FAQViewModel {
    
    let models: [FAQModel] = [
        .init(
            title: "How do I connect the app to my TV?".localized,
            subtitle: "To connect the app to your TV, make sure both your TV and phone are connected to the same Wi-Fi network. Open the app and select your TV from the list of available devices. If the TV is not appearing, check your Wi-Fi connection".localized
        ),
        .init(
            title: "Does the app support all TV models?".localized,
            subtitle: "The app supports most TVs from brands like Samsung, LG, Fire Stick and Roku".localized
        ),
        .init(
            title: "I’ve tried connecting, but nothing happens. What can I do?".localized,
            subtitle: "• Update the app: Ensure that you’re using the latest version of the app. Go to your app store and check for updates. • Reconnect Wi-Fi: Try reconnecting both your phone and TV to the Wi-Fi network. Sometimes, reconnecting to the network can help solve connectivity issues. • Restart your router: If your devices are on the same network but still not connecting, restarting your Wi-Fi router might resolve the issue".localized
        ),
        .init(
            title: "What should I do if the TV doesn’t respond to commands?".localized,
            subtitle: "Make sure both your TV and phone are connected to the same Wi-Fi network and that the app is up-to-date. If the issue persists, try restarting the app or your TV".localized
        ),
        .init(
            title: "Can I use the app without an internet connection?".localized,
            subtitle: "An internet connection is required to set up and control your TV via the app. However, some features may be available offline if your TV is connected via Bluetooth".localized
        ),
        .init(
            title: "The app keeps disconnecting from my TV. How can I fix this?".localized,
            subtitle: "• Stable Wi-Fi connection: Make sure your Wi-Fi connection is stable. Unstable Wi-Fi can cause frequent disconnections. • Reduce interference: Move your devices closer to the router to avoid interference from other wireless devices. • Update firmware: Ensure your TV firmware and the app are up to date, as outdated software can cause connection issues.".localized
        )
    ]
}
