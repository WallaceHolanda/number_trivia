import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_remote_data_source_test.mocks.dart';

// class MockHttpClient extends Mock implements http.Client {}
@GenerateMocks([http.Client])
void main() {
  late NumberTriviaRemoteDataSourceImpl dataSource;
  late MockClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(
      client: mockHttpClient,
    );
  });

  void setUpMockHttpClientSuccess200() {
    const testUrl = 'http://numberapi.com/1';
    when(mockHttpClient.get(Uri.parse(testUrl), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientFailure404() {
    const testUrl = 'http://numberapi.com/1';
    when(mockHttpClient.get(Uri.parse(testUrl), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(
      json.decode(
        fixture('trivia.json'),
      ),
    );
    const tNumber = 1;
    const tUrl = 'http://numberapi.com/';
    const String testUrl = "$tUrl$tNumber";

    test(
      '''should perform a GET request on a URL with 
      number being the endpoint and with application/json''',
      () async {
        setUpMockHttpClientSuccess200();
        dataSource.getConcreteNumberTrivia(tNumber);
        verify(mockHttpClient.get(
          Uri.parse(testUrl),
          headers: {
            'Content-Type': 'application/json',
          },
        ));
      },
    );

    test('should return NumberTrivia when the response code is 200 (success)',
        () async {
      setUpMockHttpClientSuccess200();
      final result = await dataSource.getConcreteNumberTrivia(tNumber);
      expect(result, equals(tNumberTriviaModel));
    });

    test(
        'should throw a ServerException when the response code is 404 or other',
        () async {
      // arrange
      setUpMockHttpClientFailure404();

      // act
      final call = dataSource.getConcreteNumberTrivia;

      // asset
      expect(
        () => call(tNumber),
        throwsA(const TypeMatcher<ServerException>()),
      );
    });
  });

  void setUpRandomMockHttpClientSuccess200() {
    const testUrl = 'http://numberapi.com/random';
    when(mockHttpClient.get(Uri.parse(testUrl), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpRandomMockHttpClientFailure404() {
    const testUrl = 'http://numberapi.com/random';
    when(mockHttpClient.get(Uri.parse(testUrl), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(
      json.decode(
        fixture('trivia.json'),
      ),
    );

    const randomTriviaUrl = 'http://numberapi.com/random';

    test(
      '''should perform a GET request on a URL with 
      number being the endpoint and with application/json''',
      () async {
        setUpRandomMockHttpClientSuccess200();
        dataSource.getRandomNumberTrivia();
        verify(mockHttpClient.get(
          Uri.parse(randomTriviaUrl),
          headers: {
            'Content-Type': 'application/json',
          },
        ));
      },
    );

    test('should return NumberTrivia when the response code is 200 (success)',
        () async {
      setUpRandomMockHttpClientSuccess200();
      final result = await dataSource.getRandomNumberTrivia();
      expect(result, equals(tNumberTriviaModel));
    });

    test(
        'should throw a ServerException when the response code is 404 or other',
        () async {
      // arrange
      setUpRandomMockHttpClientFailure404();

      // act
      final call = dataSource.getRandomNumberTrivia;

      // asset
      expect(
        () => call(),
        throwsA(const TypeMatcher<ServerException>()),
      );
    });
  });
}
