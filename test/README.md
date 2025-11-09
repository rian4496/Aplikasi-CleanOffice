# Test Suite

## Structure

```
test/
├── unit/                 # Unit tests
│   ├── services/        # Service layer tests
│   ├── providers/       # Provider tests
│   └── models/          # Model tests
├── widget/              # Widget tests
│   ├── admin/          # Admin widget tests
│   └── shared/         # Shared widget tests
└── integration/         # Integration tests
```

## Running Tests

### All tests
```bash
flutter test
```

### Unit tests only
```bash
flutter test test/unit
```

### Widget tests only
```bash
flutter test test/widget
```

### Integration tests
```bash
flutter test integration_test
```

### With coverage
```bash
flutter test --coverage
```

### View coverage report
```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Writing Tests

### Unit Test Example
```dart
test('description', () {
  // Arrange
  final input = 'test';
  
  // Act
  final result = function(input);
  
  // Assert
  expect(result, equals(expected));
});
```

### Widget Test Example
```dart
testWidgets('description', (WidgetTester tester) async {
  // Build widget
  await tester.pumpWidget(MyWidget());
  
  // Find widget
  expect(find.text('Hello'), findsOneWidget);
  
  // Interact
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();
  
  // Verify
  expect(find.text('Clicked'), findsOneWidget);
});
```

## Test Coverage Goals
- **Overall:** 80%+
- **Services:** 90%+
- **Providers:** 85%+
- **Widgets:** 75%+
- **Models:** 95%+

## TODO: Implement Tests
- [ ] Auth service tests
- [ ] Firestore service tests
- [ ] Request service tests
- [ ] Auth providers tests
- [ ] Report providers tests
- [ ] Critical widget tests
- [ ] Integration tests for main flows
