import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../contants/dio_client.dart';
import '../contants/end_point.dart';
import '../data/models/task_models.dart';

part 'repository.g.dart';

class Api {
  Api._();
  static final Api _api = Api._();
  static Api get instance => _api;

  RestClientApi get restClient => RestClientApi(dioClient(Endpoints.baseUrl));
}

@RestApi(baseUrl: Endpoints.baseUrl)
abstract class RestClientApi {
  factory RestClientApi(Dio dio, {String baseUrl}) = _RestClientApi;

  @POST(Endpoints.tasks)
  Future<void> createTask(@Body() Map<String, dynamic> body);

  @GET(Endpoints.tasksRange)
  Future<TasksRangeResponse> getTasksRange(
    @Query('fromDate') String fromDate,
    @Query('toDate') String toDate,
    @Query('includeDone') bool includeDone,
    @Query('includeCancelled') bool includeCancelled,
  );

  @PATCH(Endpoints.tasks + '{id}')
  Future<void> updateTask(@Path('id') String id, @Body() Map<String, dynamic> body);

  @GET(Endpoints.tasksCount)
  Future<TasksCountResponse> getTasksCount(
    @Query('fromDate') String fromDate,
    @Query('toDate') String toDate,
    @Query('includeDone') bool includeDone,
    @Query('includeCancelled') bool includeCancelled,
  );

  @POST(Endpoints.login)
  Future<void> login( @Query('timezone') String timezone);
}
