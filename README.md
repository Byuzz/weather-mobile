# WeatherTech Mobile Application

A comprehensive Flutter mobile application for WeatherTech IoT Dashboard that connects to your existing Node.js backend API and MySQL database.

## Features

### 🏠 Dashboard
- Real-time sensor readings (Temperature, Humidity, Light, Pressure, Air Quality)
- Glassmorphic UI design with gradient backgrounds
- Fan control with ON/OFF buttons and loading indicators
- Automatic data polling every 4 seconds

### 📍 GPS Tracking
- Interactive map using flutter_map and OpenStreetMap
- Real-time GPS coordinates display
- Automatic marker position updates

### 🖥️ System Health
- CPU Load monitoring with progress indicators
- RAM Usage tracking
- System uptime display
- Combined transceiver and gateway health status

### 📊 History
- Temperature and humidity trend charts using fl_chart
- Historical data logs in scrollable ListView
- Interactive line charts with gradient fills

### 👤 Profile
- User account management
- Team members display (static data)
- Logout functionality with token clearing

## Authentication Flow

1. **Splash Screen**: Checks for existing authentication token
2. **Login Screen**: Username/password authentication with your Node.js API
3. **Register Screen**: New user registration with form validation
4. **Token Management**: Automatic token storage and validation

## Technical Stack

### Dependencies
- **HTTP**: API communication with your Node.js backend
- **Provider**: State management for authentication and sensor data
- **Shared Preferences**: Local storage for authentication tokens
- **Flutter Map**: Interactive maps for GPS tracking
- **FL Chart**: Beautiful charts for data visualization
- **Google Fonts**: Custom typography with Poppins font
- **Glassmorphism**: Modern UI with semi-transparent cards

### Design Features
- Weather-themed gradient backgrounds (Blue/Purple)
- Glassmorphic card design
- Responsive layout for mobile devices
- Loading states and error handling
- Snackbar notifications for user feedback

## API Integration

The app connects to your existing WeatherTech backend at:
```
Base URL: https://ir64-iot.weathertech.tech
```

### Endpoints Used:
- `POST /api/auth/login` - User authentication
- `POST /api/auth/register` - New user registration
- `GET /api/latest/sensor` - Latest sensor readings
- `GET /api/latest/sensor_system` - GPS and transceiver data
- `GET /api/latest/gateway_system` - Gateway health data
- `GET /api/history` - Historical sensor data
- `POST /api/control/fan` - Fan control commands

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── services/
│   └── api_service.dart      # API communication layer
├── providers/
│   ├── auth_provider.dart    # Authentication state
│   └── sensor_provider.dart  # Sensor data management
└── screens/
    ├── splash_screen.dart    # Token validation
    ├── login_screen.dart     # User login
    ├── register_screen.dart  # User registration
    ├── main_screen.dart      # Bottom navigation
    ├── dashboard_tab.dart    # Sensor dashboard
    ├── gps_tab.dart          # GPS tracking
    ├── system_tab.dart       # System health
    ├── history_tab.dart      # Data history
    └── profile_tab.dart      # User profile
```

## Getting Started

1. **Clone the repository**
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Create assets directories**:
   ```bash
   mkdir -p assets/images assets/icons assets/fonts
   ```
4. **Add font files** (optional):
   - Download Poppins font family
   - Place in `assets/fonts/` directory
5. **Run the app**:
   ```bash
   flutter run
   ```

## Configuration

### Backend URL
The app is configured to use your existing backend URL:
```dart
static const String baseUrl = 'https://ir64-iot.weathertech.tech';
```

### Polling Interval
Sensor data is automatically refreshed every 4 seconds:
```dart
_pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
  fetchSensorData();
});
```

## Error Handling

The app includes comprehensive error handling:
- Network connection errors
- API response errors
- Authentication failures
- Data parsing errors
- UI feedback through Snackbars

## Security Features

- Secure token storage using SharedPreferences
- Automatic token validation on app startup
- Proper logout with token clearing
- Form validation for login/registration

## UI/UX Features

- **Glassmorphism Design**: Semi-transparent cards with backdrop blur
- **Gradient Backgrounds**: Weather-themed blue/purple gradients
- **Responsive Layout**: Optimized for mobile devices
- **Loading States**: Progress indicators for async operations
- **Error Messages**: User-friendly error notifications
- **Pull-to-Refresh**: Refresh data with swipe gesture

## Future Enhancements

- Push notifications for alerts
- Dark/light theme toggle
- Data export functionality
- Offline mode with local caching
- Advanced chart interactions
- Real-time notifications

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License.

## Support

For issues and questions, please create an issue in the repository or contact the development team.