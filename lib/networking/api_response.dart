class ApiResponse<T> {
  Status? status;
  int? code;
  T? data;
  String? message;

  ApiResponse({this.status, this.code, this.data, this.message});

  @override
  String toString() {
    return "Status : $status \n Code : $code \n Message : $message \n Data : $data";
  }
}

enum Status { success, error }
