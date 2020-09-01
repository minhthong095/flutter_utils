import 'dart:convert';

import 'package:artemis/schema/graphql_query.dart';
import 'package:artemis/schema/graphql_response.dart';
import 'package:dio/dio.dart' as d;
import "package:gql_exec/gql_exec.dart";
import 'package:gql_http_link/gql_http_link.dart';
import 'package:gql_link/gql_link.dart';
import 'package:jose/jose.dart';
import 'package:json_annotation/json_annotation.dart';

const _serializer = const RequestSerializer();

class GraphClient {
  static d.Dio _dio;
  static const String _url = '';

  GraphClient._();

  static GraphClient get instance => GraphClient._();

  init(String xToken) {
    _dio = d.Dio(d.BaseOptions(
        baseUrl: _url,
        connectTimeout: 5000,
        receiveTimeout: 3000,
        headers: {
          "x-token": xToken,
        }));
  }

  Future<Response> rawDataExecute<T, U extends JsonSerializable>(
      GraphQLQuery<T, U> queryX) async {
    return await _request(
            Request(
              operation: Operation(
                document: queryX.document,
                operationName: queryX.operationName,
              ),
              variables: queryX.getVariablesMap(),
            ),
            _dio)
        .first;
  }

  Future<GraphQLResponse<T>> execute<T, U extends JsonSerializable>(
      GraphQLQuery<T, U> query) async {
    final response = await rawDataExecute(query);

    return GraphQLResponse<T>(
      data: response.data == null ? null : query.parse(response.data),
      errors: response.errors,
    );
  }

  Future<Response> rawBodyRawDataExecute<T, U extends JsonSerializable>(
      String query,
      {Map<String, dynamic> variables}) async {
    return await _post({
      'variables': variables == null ? {} : jsonEncode(variables),
      'query': query
    }, _dio)
        .first;
  }

  Stream<Response> _request(Request request, d.Dio dio) async* {
    dynamic body;

    try {
      body = json.encode(
        _serializer.serializeRequest(request),
      );
    } catch (e) {
      throw RequestFormatException(
        originalException: e,
        request: request,
      );
    }

    yield* _post(body, dio);
  }

  Stream<Response> _post(dynamic body, d.Dio dio) async* {
    final httpResponse = await dio.post("", data: body);

    Response response;

    try {
      response =
          AppParser().parseResponse(httpResponse.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception(
          "Parser exception in class DioClient with path 'lib/conf/base_api.dart'.");
    }

    yield Response(
      data: response.data,
      errors: response.errors,
      context: response.context.withEntry(
        HttpLinkResponseContext(
          statusCode: httpResponse.statusCode,
        ),
      ),
    );
  }
}

class AppParser extends ResponseParser {
  const AppParser();

  @override
  Response parseResponse(Map<String, dynamic> body) => Response(
        errors: (body["errors"] as List)
            ?.map(
              (dynamic error) => error == null
                  ? null
                  : parseError(error as Map<String, dynamic>),
            )
            ?.toList(),
        data: body["data"] as Map<String, dynamic>,
        context: Context().withEntry(
          ResponseExtensions(
            body["extensions"],
          ),
        ),
      );

  /// Parses a response error
  ///
  /// Extend this to add non-standard behavior
  @override
  GraphQLError parseError(Map<String, dynamic> error) => GraphQLError(
        message: error["message"] as String ?? '',
        path: error["path"] as List,
        locations: (error["locations"] as List)
            ?.map(
              (dynamic error) => error == null
                  ? null
                  : parseLocation(error as Map<String, dynamic>),
            )
            ?.toList(),
        extensions: error["extensions"] as Map<String, dynamic>,
      );

  /// Parses a response error location
  ///
  /// Extend this to add non-standard behavior
  @override
  ErrorLocation parseLocation(Map<String, dynamic> location) => ErrorLocation(
        line: location["line"] as int ?? 0,
        column: location["column"] as int ?? 0,
      );
}
