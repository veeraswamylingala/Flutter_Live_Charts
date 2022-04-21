import 'dart:convert';

GroupsModel productFromJson(String str) =>
    GroupsModel.fromJson(json.decode(str));

String productToJson(GroupsModel data) => json.encode(data.toJson());

class GroupsModel {
  GroupsModel({
    required this.curtrendtitle,
    required this.pointname,
    required this.uppervalue,
    required this.lowervalue,
    required this.pencolor,
  });

  String curtrendtitle;
  String? pointname;
  int uppervalue;
  int lowervalue;
  int pencolor;

  factory GroupsModel.fromJson(Map<String, dynamic> json) => GroupsModel(
        curtrendtitle: json["CURTRENDTITLE"],
        pointname: json["POINTNAME"],
        uppervalue: json["UPPERVALUE"],
        lowervalue: json["LOWERVALUE"],
        pencolor: json["PENCOLOR"],
      );

  Map<String, dynamic> toJson() => {
        "CURTRENDTITLE": curtrendtitle,
        "POINTNAME": pointname,
        "UPPERVALUE": uppervalue,
        "LOWERVALUE": lowervalue,
        "PENCOLOR": pencolor,
      };
}
