abstract class BaseService {
  Future<T> get<T>(String endpoint);
  Future<T> post<T>(String endpoint, dynamic data);
  Future<T> put<T>(String endpoint, dynamic data);
  Future<T> delete<T>(String endpoint);
}
