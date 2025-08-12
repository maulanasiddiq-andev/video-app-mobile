class BaseResponse<T> {
  final bool succeed;
  final List<String> messages;
  final T? data;

  BaseResponse({
    this.data,
    required this.messages,
    required this.succeed
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromjsonT) => BaseResponse(
    data: json['data'] != null ? fromjsonT(json['data']) : null, 
    messages: List<String>.from(json['messages']), 
    succeed: json['succeed']
  );
}