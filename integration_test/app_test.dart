import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/pages/signup_page.dart';
import '../lib/pages/login_page.dart';
import '../lib/pages/home_page.dart';

void main() {
  setUpAll(() async {
    // Initialize Firebase
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  testWidgets('Signup, Login, and HomePage Navigation Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => const SignupPage(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomePage(),
        },
      ),
    );

    // 1. Signup Workflow
    expect(find.text('Create Account'), findsOneWidget);

    // Enter valid Full Name
    await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');

    // Enter valid Email
    await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');

    // Enter valid Password
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');

    // Enter valid Phone Number
    await tester.enterText(find.byType(TextFormField).at(3), '12345678902');

    // Tap the "Sign Up" button
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // Verify navigation to LoginScreen
    expect(find.text('Welcome Back!'), findsOneWidget);

    // 2. Login Workflow
    // Enter the same Email
    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');

    // Enter the same Password
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');

    // Tap the "Login" button
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify navigation to HomePage
    expect(find.byType(HomePage), findsOneWidget);

    // 3. HomePage Navigation Tests
    // Find the My Events button
    final myEventsButton = find.text('My Events');

    // Ensure the button is present
    expect(myEventsButton, findsOneWidget);

    // Tap the button
    await tester.tap(myEventsButton);
    await tester.pumpAndSettle();

    // Verify navigation to the My Events page
    expect(find.text('Event List'), findsOneWidget); // Replace with a unique identifier for the My Events page.

    // Return to HomePage
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Find the Add Friend button
    final addFriendButton = find.text('Add Friend');

    // Ensure the button is present
    expect(addFriendButton, findsOneWidget);

    // Tap the button
    await tester.tap(addFriendButton);
    await tester.pumpAndSettle();

    // Verify navigation to Add Friend page
    expect(find.text('Add Friend'), findsOneWidget); // Replace with a unique identifier for the Add Friend page.
  });
}
