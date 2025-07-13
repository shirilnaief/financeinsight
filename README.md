# Finance Insight

A comprehensive financial dashboard application built with Flutter.

## Development

### Running the Web Application

If you encounter port conflicts when running the web development server, use one of these solutions:

#### Quick Solutions:

1. **Kill existing process:**
   ```bash
   # Linux/macOS
   kill -9 $(lsof -ti:4028)
   
   # Windows
   netstat -ano | findstr :4028
   taskkill /PID <PID> /F
   ```

2. **Use different port:**
   ```bash
   flutter run -d web-server --web-port 4029
   ```

3. **Use development scripts:**
   ```bash
   # Linux/macOS
   chmod +x scripts/run_web.sh
   ./scripts/run_web.sh [port]
   
   # Windows
   scripts\run_web.bat [port]
   ```

#### Default Development Commands:

```bash
# Run on mobile
flutter run

# Run on web (default port 4028)
flutter run -d web-server

# Run on web with specific port
flutter run -d web-server --web-port 4029

# Run on web with auto-assigned port
flutter run -d web-server --web-port 0
```

### Port Management

The development scripts automatically handle port conflicts by:
1. Checking if the desired port is available
2. Attempting to free the port if it's in use
3. Falling back to an alternative port if necessary
4. Starting the Flutter web server on the available port

### Troubleshooting

**Port Already in Use Error:**
- Use `lsof -ti:4028` (Linux/macOS) or `netstat -ano | findstr :4028` (Windows) to find the process
- Kill the process or use a different port
- Use the provided development scripts for automatic handling

**Web Server Issues:**
- Ensure Flutter web is enabled: `flutter config --enable-web`
- Check Flutter doctor: `flutter doctor`
- Clear build cache: `flutter clean && flutter pub get`

## Features

- Financial data analysis and insights
- Interactive charts and visualizations
- User profile management
- Real-time financial metrics

## Getting Started

1. Install Flutter SDK
2. Run `flutter pub get`
3. Use development scripts or manual commands to start the application