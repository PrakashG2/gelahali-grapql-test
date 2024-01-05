import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:no_rest_api/models/character_model.dart';
import 'package:no_rest_api/screens/post_screen.dart';
import 'package:gql_dio_link/gql_dio_link.dart';

const String graphqlEndpoint = 'https://rickandmortyapi.com/graphql';

class PortEnv {
  static const imageUrl =
      'https://gelahali.com/media/catalog/product/cache/daf3552c7c86fb3a28eb951702361cbc';
  static const url = 'https://gelahali.com';
  static const apiPath = '/index.php/rest/V1';
  static const graphqlPath = '/graphql';
}

Future<List<CharacterModel>> getRickAndMortyCharacters() async {
  List<CharacterModel> characters = [];
  var tokenref = "4q7u1lax3on2ev6u99jxgax1pe6ctxdf";

  var api = Dio(
    BaseOptions(
      baseUrl: PortEnv.url,
    ),
  )
    ..interceptors.add(
      LogInterceptor(
        request: false,
        requestBody: false,
        requestHeader: false,
        responseBody: true,
        responseHeader: false,
        error: true,
      ),
    )
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          var token = "4q7u1lax3on2ev6u99jxgax1pe6ctxdf";
          options.headers["Authorization"] = "Bearer $token";
          return handler.next(options);
        },
        onError: (e, handler) {
          if (e is SocketException) {
            return handler.next(e);
          }
          return handler.next(e);
        },
      ),
    );

  try {
    // final GraphQLClient _graphQLClient = GraphQLClient(
    //   cache: GraphQLCache(),
    //   link: HttpLink(graphqlEndpoint),
    // );
    final DioLink httpLink =
        DioLink('${PortEnv.url}${PortEnv.graphqlPath}', client: api);
    final AuthLink authLink = AuthLink(getToken: () => 'Bearer ${tokenref}');
    final Link link = authLink.concat(httpLink);

    final GraphQLClient _graphQLClient = GraphQLClient(
      link: link,
      cache: GraphQLCache(),
    );

    final QueryOptions options = QueryOptions(
      document: gql('''
      {
        countries {
          id
          full_name_english
          full_name_locale
          two_letter_abbreviation
          three_letter_abbreviation
          available_regions {
            id
            code
            name
          }
        }
      }
    '''
    ));

    final QueryResult result = await _graphQLClient.query(options);

    if (result.hasException) {
      print("GraphQL error: ${result.exception}");
    } else {
      final List<dynamic> items = result.data?['characters']['results'] ?? [];
      characters = items.map((item) => CharacterModel.fromJson(item)).toList();
    }
  } catch (e) {
    print("Error code: $e");
    rethrow;
  }

  return characters;
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('GraphQL Data'),
        ),
        body: GraphQLListView(),
        floatingActionButton: FloatingActionButton(onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostScreen(),
            ),
          );
        }));
  }
}

class GraphQLListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CharacterModel>>(
      future: getRickAndMortyCharacters(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No data available');
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final character = snapshot.data![index];
              return ListTile(
                title: Text(character.name),
                subtitle: Text(
                    'Status: ${character.status}, Species: ${character.species},gender ${character.gender}'),
              );
            },
          );
        }
      },
    );
  }
}
