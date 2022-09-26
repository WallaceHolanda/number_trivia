import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_local_data_source_test.mocks.dart';

// class MockSharedPreferences extends Mock implements SharedPreferences {}

@GenerateMocks([SharedPreferences])
void main() {
  late NumberTriviaLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('getLastNumberTrivia', () {
    final String jsonContent = fixture('trivia_cached.json');
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(jsonContent));
    test(
        'should return NumberTrivia from SharedPreferences when there is one in the cache',
        () async {
      const sharedPreferencesKey = 'CACHED_NUMBER_TRIVIA';
      when(mockSharedPreferences.getString(sharedPreferencesKey))
          .thenReturn(fixture('trivia_cached.json'));

      final result = await dataSource.getLastNumberTrivia();

      verify(mockSharedPreferences.getString(sharedPreferencesKey));
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw a CacheException when there is not a cached value',
        () async {
      const sharedPreferencesKey = CACHED_NUMBER_TRIVIA;
      when(mockSharedPreferences.getString(sharedPreferencesKey))
          .thenReturn(null);

      final call = dataSource.getLastNumberTrivia;

      expect(() => call(), throwsA(const TypeMatcher<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    const tNumberTriviaModel = NumberTriviaModel(
      number: 1,
      text: 'Test Text',
    );
    test('should call SharedPreferences to cache the data', () async {
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => true);
      await dataSource.cacheNumberTrivia(tNumberTriviaModel);
      final expectedJsonString = json.encode(tNumberTriviaModel.toJson());

      verify(await mockSharedPreferences.setString(
        CACHED_NUMBER_TRIVIA,
        expectedJsonString,
      ));
    });
  });
}
