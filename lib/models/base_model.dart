abstract class BaseModel {
  Map<String, dynamic> toJson();
  void fromJson(Map<String, dynamic> json);
}
